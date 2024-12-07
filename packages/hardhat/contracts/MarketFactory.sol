// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IMarket.sol";
import "./interfaces/IReputationSystem.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title MarketFactory
 * @dev Factory contract for creating and tracking prediction markets
 */
contract MarketFactory is Ownable, ReentrancyGuard {
    using Clones for address;

    // State variables
    address public implementation;
    address public reputationSystem;
    uint256 public marketCount;
    
    // Enhanced market tracking with more efficient storage
    mapping(uint256 => address) public marketById;
    mapping(address => uint256) public marketIds;
    
    // Events
    event ImplementationUpdated(
        address indexed oldImpl, 
        address indexed newImpl,
        uint256 timestamp
    );
    
    event ReputationSystemUpdated(
        address indexed oldSystem,
        address indexed newSystem,
        uint256 timestamp
    );
    
    event MarketCreated(
        uint256 indexed marketId,
        address indexed market,
        string question,
        uint256 resolutionTime,
        address indexed creator,
        uint256 timestamp
    );

    // Custom errors
    error InvalidImplementation();
    error InvalidReputationSystem();
    error InvalidRange();
    error RangeOutOfBounds();
    error MarketInitializationFailed();

    /**
     * @dev Constructor sets the implementation contract and reputation system
     */
    constructor(address _implementation, address _reputationSystem) {
        if (_implementation == address(0)) revert InvalidImplementation();
        if (_reputationSystem == address(0)) revert InvalidReputationSystem();
        
        implementation = _implementation;
        reputationSystem = _reputationSystem;
    }

    /**
     * @dev Updates the implementation contract
     */
    function setImplementation(address _implementation) external onlyOwner {
        if (_implementation == address(0)) revert InvalidImplementation();
        
        address oldImpl = implementation;
        implementation = _implementation;
        
        emit ImplementationUpdated(
            oldImpl, 
            _implementation,
            block.timestamp
        );
    }

    /**
     * @dev Updates the reputation system contract
     */
    function setReputationSystem(address _reputationSystem) external onlyOwner {
        if (_reputationSystem == address(0)) revert InvalidReputationSystem();
        
        address oldSystem = reputationSystem;
        reputationSystem = _reputationSystem;
        
        emit ReputationSystemUpdated(
            oldSystem,
            _reputationSystem,
            block.timestamp
        );
    }

    /**
     * @dev Creates a new prediction market
     */
    function createMarket(
        string calldata question,
        uint256 resolutionTime
    ) external nonReentrant returns (address market) {
        // Increment market count first to avoid reentrancy
        uint256 newMarketId = ++marketCount;
        
        // Clone the implementation contract
        market = implementation.clone();
        
        // Initialize the market with try-catch
        try IMarket(market).initialize(
            question,
            resolutionTime,
            msg.sender,
            reputationSystem
        ) {
            // Track the new market
            marketById[newMarketId] = market;
            marketIds[market] = newMarketId;
            
            // Whitelist the market in reputation system
            IReputationSystem(reputationSystem).whitelistFactory(address(this));
            
            emit MarketCreated(
                newMarketId,
                market,
                question,
                resolutionTime,
                msg.sender,
                block.timestamp
            );
            
            return market;
        } catch {
            revert MarketInitializationFailed();
        }
    }

    /**
     * @dev Returns a list of markets within the given range
     */
    function getMarkets(uint256 start, uint256 end) 
        external 
        view 
        returns (address[] memory result) 
    {
        if (start >= end) revert InvalidRange();
        if (end > marketCount) revert RangeOutOfBounds();
        
        result = new address[](end - start);
        for (uint256 i = start; i < end; i++) {
            result[i - start] = marketById[i + 1];
        }
    }

    /**
     * @dev Checks if an address is a market created by this factory
     */
    function isMarket(address market) external view returns (bool) {
        return marketIds[market] != 0;
    }
}