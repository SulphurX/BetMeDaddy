// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IReputationSystem.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

/**
 * @title ReputationSystem
 * @dev Implementation of reputation scoring and difficulty multiplier system
 */
contract ReputationSystem is IReputationSystem, Ownable, ReentrancyGuard {
    using Math for uint256;

    // Constants for calculations
    uint256 private constant SCALE = 1e18;
    uint256 private constant BASE_REPUTATION_REWARD = 100 * SCALE;
    uint256 private constant MAX_DIFFICULTY_MULTIPLIER = 5 * SCALE;
    uint256 private constant MIN_DIFFICULTY_MULTIPLIER = SCALE;
    uint256 private constant MAX_DISCOUNT = 50 * SCALE / 100; // 50%
    uint256 private constant MAX_VOTING_WEIGHT = 3 * SCALE;   // 3x
    uint256 private constant REPUTATION_THRESHOLD = 1000000 * SCALE;

    // Reputation state
    mapping(address => uint256) private userReputation;
    mapping(address => uint256) private totalPredictions;
    mapping(address => uint256) private correctPredictions;
    
    // Market consensus tracking
    struct MarketConsensus {
        uint256 finalPrice;
        uint256 totalStaked;
        bool resolved;
        mapping(address => Position) userPositions;
    }
    
    // Track consensus for each market
    mapping(address => MarketConsensus) private marketConsensus;
    
    // Whitelist of market factory contracts that can interact
    mapping(address => bool) public whitelistedFactories;

    // Modifiers
    modifier onlyWhitelistedFactory() {
        require(whitelistedFactories[msg.sender], "Not authorized");
        _;
    }

    /**
     * @dev Whitelist a market factory contract
     */
    function whitelistFactory(address factory) external onlyOwner {
        whitelistedFactories[factory] = true;
    }

    /**
     * @dev Remove a market factory from whitelist
     */
    function removeFactory(address factory) external onlyOwner {
        whitelistedFactories[factory] = false;
    }

    /**
     * @dev Records a user's position in a market
     */
    function recordPosition(
        address market,
        address user,
        uint256 stake,
        bool isYes,
        uint256 currentPrice
    ) external override onlyWhitelistedFactory {
        MarketConsensus storage consensus = marketConsensus[market];
        require(!consensus.resolved, "Market already resolved");
        
        Position storage position = consensus.userPositions[user];
        require(position.stake == 0, "Position already recorded");
        
        position.stake = stake;
        position.isYes = isYes;
        position.entryPrice = currentPrice;
        position.claimed = false;
        
        consensus.totalStaked += stake;
        
        emit MarketRecorded(market, user, stake, isYes, currentPrice);
    }

    /**
     * @dev Calculate difficulty multiplier based on price deviation
     */
    function calculateDifficultyMultiplier(
        uint256 finalPrice,
        bool outcome
    ) public pure returns (uint256) {
        uint256 deviation;
        if (outcome) {
            // YES outcome
            deviation = SCALE - finalPrice;
        } else {
            // NO outcome
            deviation = finalPrice;
        }
        
        return MIN_DIFFICULTY_MULTIPLIER + 
            (deviation * (MAX_DIFFICULTY_MULTIPLIER - MIN_DIFFICULTY_MULTIPLIER)) / SCALE;
    }

    /**
     * @dev Updates user reputation after market resolution
     */
    function updateReputation(
        address market,
        address user,
        bool outcome
    ) external override onlyWhitelistedFactory nonReentrant returns (uint256) {
        MarketConsensus storage consensus = marketConsensus[market];
        require(!consensus.resolved, "Already resolved");
        
        Position storage position = consensus.userPositions[user];
        require(!position.claimed, "Already claimed");
        require(position.stake > 0, "No position");
        
        consensus.resolved = true;
        consensus.finalPrice = position.entryPrice;
        position.claimed = true;
        
        uint256 multiplier = calculateDifficultyMultiplier(
            consensus.finalPrice,
            outcome
        );
        
        totalPredictions[user]++;
        
        uint256 reputationChange = 0;
        if (position.isYes == outcome) {
            correctPredictions[user]++;
            
            uint256 stakeWeight = (position.stake * SCALE) / consensus.totalStaked;
            reputationChange = (BASE_REPUTATION_REWARD * multiplier * stakeWeight) / (SCALE * SCALE);
            
            uint256 oldReputation = userReputation[user];
            userReputation[user] += reputationChange;
            
            emit ReputationUpdated(
                user,
                oldReputation,
                userReputation[user],
                multiplier
            );
        }
        
        return reputationChange;
    }

    /**
     * @dev Calculate fee discount based on reputation
     */
    function calculateFeeDiscount(
        address user
    ) external view override returns (uint256) {
        uint256 reputation = userReputation[user];
        
        if (reputation >= REPUTATION_THRESHOLD) {
            return MAX_DISCOUNT;
        }
        
        return (reputation * MAX_DISCOUNT) / REPUTATION_THRESHOLD;
    }

    /**
     * @dev Calculate voting weight based on reputation
     */
    function calculateVotingWeight(
        address user
    ) external view override returns (uint256) {
        uint256 reputation = userReputation[user];
        
        if (reputation >= REPUTATION_THRESHOLD) {
            return MAX_VOTING_WEIGHT;
        }
        
        return SCALE + ((reputation * (MAX_VOTING_WEIGHT - SCALE)) / REPUTATION_THRESHOLD);
    }

    /**
     * @dev Get user's current reputation
     */
    function getUserReputation(
        address user
    ) external view override returns (uint256) {
        return userReputation[user];
    }

    /**
     * @dev Get user's complete stats
     */
    function getUserStats(
        address user
    ) external view override returns (
        uint256 reputation,
        uint256 predictions,
        uint256 correct
    ) {
        return (
            userReputation[user],
            totalPredictions[user],
            correctPredictions[user]
        );
    }
}