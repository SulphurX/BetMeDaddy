// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Counter {
    uint256 private count;
    
    event CounterIncremented(address indexed by, uint256 newCount);
    event CounterDecremented(address indexed by, uint256 newCount);
    
    function increment() public {
        count += 1;
        emit CounterIncremented(msg.sender, count);
    }
    
    function decrement() public {
        require(count > 0, "Counter: cannot decrement below zero");
        count -= 1;
        emit CounterDecremented(msg.sender, count);
    }
    
    function getCount() public view returns (uint256) {
        return count;
    }
} 