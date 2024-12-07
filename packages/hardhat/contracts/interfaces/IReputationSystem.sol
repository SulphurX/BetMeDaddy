// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title IReputationSystem
 * @dev Interface for reputation system integration
 */
interface IReputationSystem {
    struct Position {
        uint256 stake;
        bool isYes;
        uint256 entryPrice;
        bool claimed;
    }

    event ReputationUpdated(
        address indexed user,
        uint256 oldReputation,
        uint256 newReputation,
        uint256 difficultyMultiplier
    );

    event MarketRecorded(
        address indexed market,
        address indexed user,
        uint256 stake,
        bool isYes,
        uint256 entryPrice
    );

    function recordPosition(
        address market,
        address user,
        uint256 stake,
        bool isYes,
        uint256 currentPrice
    ) external;

    function updateReputation(
        address market,
        address user,
        bool outcome
    ) external returns (uint256 reputationChange);

    function calculateFeeDiscount(address user) external view returns (uint256);
    
    function calculateVotingWeight(address user) external view returns (uint256);
    
    function getUserReputation(address user) external view returns (uint256);
    
    function getUserStats(address user) external view returns (
        uint256 reputation,
        uint256 totalPredictions,
        uint256 correctPredictions
    );
}