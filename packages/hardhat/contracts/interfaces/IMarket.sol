// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title IMarket
 * @dev Interface for prediction market contracts
 */
interface IMarket {
    /// @dev Market outcome states
    enum MarketOutcome { UNRESOLVED, YES, NO, INVALID }
    
    /// @dev Market status states
    enum MarketStatus { TRADING, CLOSED, RESOLVED }
    
    /// @dev Emitted when market is created
    event MarketCreated(
        address indexed market,
        string question,
        uint256 resolutionTime,
        address indexed creator
    );
    
    /// @dev Emitted when a trade occurs
    event Trade(
        address indexed trader,
        bool isYes,
        uint256 amount,
        uint256 shares
    );
    
    /// @dev Emitted when market is resolved
    event MarketResolved(
        address indexed market,
        MarketOutcome outcome,
        address indexed resolver
    );
    
    /**
     * @dev Initializes a new market
     * @param _question Question being predicted
     * @param _resolutionTime Time when market can be resolved
     * @param _creator Address of market creator
     * @param _reputationSystem Address of reputation system contract
     */
    function initialize(
        string memory _question,
        uint256 _resolutionTime,
        address _creator,
        address _reputationSystem
    ) external;
    
    /**
     * @dev Buys outcome tokens
     * @param isYes True for YES tokens, false for NO tokens
     * @param amount Amount of collateral to spend
     * @return shares Amount of outcome tokens received
     */
    function buy(bool isYes, uint256 amount) external returns (uint256 shares);
    
    /**
     * @dev Sells outcome tokens
     * @param isYes True for YES tokens, false for NO tokens
     * @param shares Amount of outcome tokens to sell
     * @return amount Amount of collateral received
     */
    function sell(bool isYes, uint256 shares) external returns (uint256 amount);
    
    /**
     * @dev Resolves the market
     * @param outcome Final outcome of the market
     */
    function resolve(MarketOutcome outcome) external;
    
    /**
     * @dev Claims winnings after market resolution
     * @return amount Amount of collateral received
     */
    function claim() external returns (uint256 amount);
}