// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IMarket.sol";
import "./interfaces/IReputationSystem.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

/**
 * @title Market
 * @dev Implementation of a binary prediction market with reputation system
 */
contract Market is IMarket, ReentrancyGuard {
    using Math for uint256;

    // Constants for price calculations
    uint256 private constant SCALE = 1e18;
    uint256 private constant MIN_PRICE = SCALE / 100; // 0.01
    uint256 private constant MAX_PRICE = 99 * SCALE / 100; // 0.99
    uint256 private constant BASE_FEE = 2 * SCALE / 100; // 2% base fee

    // Market properties
    string public question;
    uint256 public resolutionTime;
    address public creator;
    IERC20 public collateralToken;
    MarketStatus public status;
    MarketOutcome public outcome;
    IReputationSystem public reputationSystem;

    // Liquidity pool state
    uint256 public totalYesShares;
    uint256 public totalNoShares;
    uint256 public liquidityPool;

    // User positions
    mapping(address => uint256) public yesBalances;
    mapping(address => uint256) public noBalances;
    
    // Claimed status tracking
    mapping(address => bool) public hasClaimed;

    // Modifiers
    modifier onlyBeforeResolution() {
        require(block.timestamp < resolutionTime, "Market: Too late");
        _;
    }

    modifier onlyAfterResolution() {
        require(block.timestamp >= resolutionTime, "Market: Too early");
        _;
    }

    modifier onlyTrading() {
        require(status == MarketStatus.TRADING, "Market: Not trading");
        _;
    }

    /**
     * @dev Initializes the market with given parameters
     */
    function initialize(
        string memory _question,
        uint256 _resolutionTime,
        address _creator,
        address _reputationSystem
    ) external override {
        require(bytes(question).length == 0, "Already initialized");
        require(_resolutionTime > block.timestamp, "Invalid resolution time");
        require(_reputationSystem != address(0), "Invalid reputation system");
        
        question = _question;
        resolutionTime = _resolutionTime;
        creator = _creator;
        status = MarketStatus.TRADING;
        reputationSystem = IReputationSystem(_reputationSystem);
        
        emit MarketCreated(address(this), _question, _resolutionTime, _creator);
    }

    /**
     * @dev Calculates effective fee rate after reputation discount
     */
    function calculateEffectiveFee(address user) public view returns (uint256) {
        uint256 discount = reputationSystem.calculateFeeDiscount(user);
        return BASE_FEE - ((BASE_FEE * discount) / SCALE);
    }

    /**
     * @dev Calculates the price for a given amount of shares
     */
    function calculatePrice(uint256 pool, uint256 shares) internal pure returns (uint256) {
        uint256 newPool = pool + shares;
        return (newPool * newPool - pool * pool) / (2 * SCALE);
    }

    /**
     * @dev Get current price of YES outcome
     */
    function getCurrentPrice() public view returns (uint256) {
        uint256 totalLiquidity = totalYesShares + totalNoShares;
        if (totalLiquidity == 0) return SCALE / 2; // 50% if no liquidity
        return (totalYesShares * SCALE) / totalLiquidity;
    }

    /**
     * @dev Buys outcome tokens
     */
    function buy(bool isYes, uint256 amount) 
        external 
        override 
        onlyTrading 
        onlyBeforeResolution 
        nonReentrant 
        returns (uint256)
    {
        require(amount > 0, "Amount must be positive");
        
        uint256 fee = (amount * calculateEffectiveFee(msg.sender)) / SCALE;
        uint256 effectiveAmount = amount - fee;
        
        uint256 shares;
        if (isYes) {
            shares = calculatePrice(totalYesShares, effectiveAmount);
            totalYesShares += shares;
            yesBalances[msg.sender] += shares;
        } else {
            shares = calculatePrice(totalNoShares, effectiveAmount);
            totalNoShares += shares;
            noBalances[msg.sender] += shares;
        }
        
        liquidityPool += effectiveAmount;
        require(collateralToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        
        // Record position for reputation
        reputationSystem.recordPosition(
            address(this),
            msg.sender,
            shares,
            isYes,
            getCurrentPrice()
        );
        
        emit Trade(msg.sender, isYes, amount, shares);
        return shares;
    }

    /**
     * @dev Sells outcome tokens
     */
    function sell(bool isYes, uint256 shares)
        external
        override
        onlyTrading
        onlyBeforeResolution
        nonReentrant
        returns (uint256)
    {
        require(shares > 0, "Shares must be positive");
        
        uint256 amount;
        if (isYes) {
            require(yesBalances[msg.sender] >= shares, "Insufficient yes shares");
            amount = calculatePrice(totalYesShares - shares, shares);
            totalYesShares -= shares;
            yesBalances[msg.sender] -= shares;
        } else {
            require(noBalances[msg.sender] >= shares, "Insufficient no shares");
            amount = calculatePrice(totalNoShares - shares, shares);
            totalNoShares -= shares;
            noBalances[msg.sender] -= shares;
        }
        
        uint256 fee = (amount * calculateEffectiveFee(msg.sender)) / SCALE;
        uint256 effectiveAmount = amount - fee;
        
        liquidityPool -= effectiveAmount;
        require(collateralToken.transfer(msg.sender, effectiveAmount), "Transfer failed");
        
        emit Trade(msg.sender, isYes, effectiveAmount, shares);
        return effectiveAmount;
    }

    /**
     * @dev Resolves the market with final outcome
     */
    function resolve(MarketOutcome _outcome)
        external
        override
        onlyAfterResolution
        nonReentrant
    {
        require(status == MarketStatus.TRADING, "Already resolved");
        require(_outcome != MarketOutcome.UNRESOLVED, "Invalid outcome");
        
        // Calculate voting weight if resolver is not creator
        if (msg.sender != creator) {
            uint256 weight = reputationSystem.calculateVotingWeight(msg.sender);
            require(weight >= 2 * SCALE, "Insufficient reputation to resolve");
        }
        
        status = MarketStatus.RESOLVED;
        outcome = _outcome;
        
        emit MarketResolved(address(this), _outcome, msg.sender);
    }

    /**
     * @dev Claims winnings after market resolution
     */
    function claim()
        external
        override
        nonReentrant
        returns (uint256)
    {
        require(status == MarketStatus.RESOLVED, "Not resolved");
        require(!hasClaimed[msg.sender], "Already claimed");
        
        uint256 amount;
        bool isWinner;
        
        if (outcome == MarketOutcome.YES) {
            amount = yesBalances[msg.sender];
            isWinner = true;
        } else if (outcome == MarketOutcome.NO) {
            amount = noBalances[msg.sender];
            isWinner = true;
        } else if (outcome == MarketOutcome.INVALID) {
            // Return proportional amount of liquidity pool for invalid outcome
            uint256 totalShares = yesBalances[msg.sender] + noBalances[msg.sender];
            amount = (totalShares * liquidityPool) / (totalYesShares + totalNoShares);
        }
        
        if (amount > 0) {
            // Update reputation if it was a valid outcome
            if (isWinner) {
                reputationSystem.updateReputation(
                    address(this),
                    msg.sender,
                    outcome == MarketOutcome.YES
                );
            }
            
            // Reset balances and mark as claimed
            yesBalances[msg.sender] = 0;
            noBalances[msg.sender] = 0;
            hasClaimed[msg.sender] = true;
            
            require(collateralToken.transfer(msg.sender, amount), "Transfer failed");
        }
        
        return amount;
    }

    /**
     * @dev View functions for market information
     */
    function getMarketInfo() external view returns (
        string memory _question,
        uint256 _resolutionTime,
        address _creator,
        MarketStatus _status,
        MarketOutcome _outcome,
        uint256 _currentPrice,
        uint256 _liquidityPool
    ) {
        return (
            question,
            resolutionTime,
            creator,
            status,
            outcome,
            getCurrentPrice(),
            liquidityPool
        );
    }

    /**
     * @dev View function for user position
     */
    function getUserPosition(address user) external view returns (
        uint256 yesShares,
        uint256 noShares,
        bool claimed
    ) {
        return (
            yesBalances[user],
            noBalances[user],
            hasClaimed[user]
        );
    }
}