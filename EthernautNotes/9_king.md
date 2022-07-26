# King

Welcome to my Ethernaut solution series!
Today we will discuss the 9th problem called King.
This smart contract is a game where the player needs to become the king and stay as the king. The way he can become the king is to pay the contract more than the already existing prize. Once that is done, whoever was king before gets the amount of ether as a payout. The new value of prize is set to the amount which was paid by the player. This means that if the player wants to get his investment back, someone else has to become the king and pay the player out. Basically it is a ponzie scheme. The catch is that once the player submits the instance, Ethernaut will send more money than the player did and will take away the king status from the player.

The goal of this challenge is:
1. Become the king and stay as the king even after submitting the instance to Ethernaut.

Let's take a look of the contract code:
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract King {

  address payable king;
  uint public prize;
  address payable public owner;

  constructor() public payable {
    owner = msg.sender;  
    king = msg.sender;
    prize = msg.value;
  }

  receive() external payable {
    require(msg.value >= prize || msg.sender == owner);
    king.transfer(msg.value);
    king = msg.sender;
    prize = msg.value;
  }

  function _king() public view returns (address payable) {
    return king;
  }
}
```

## Code review

### State Variables
We have three variables declared for the contract.
- King is a public payable address variable. This variable will hold the value of the address of the account who is the current king of the game. Player's goal is to get our contracts address as the value of this variable.
- Prize is a public unsigned integer which hold the value of the prize money. The player will try to send Eth amount greater than this value to become the king. 
- owner is the public payable address which will hold the address value of the owner of the contract.

### Constructor
The constructor is straight forward. It initialized the owner and king to the values of the address of sender, which means whoever deploys the contract in the first place will become the owner and also the king at the begining. Also the amount sent to the contract initially becomes the value of the prize variable. 

### Functions
This contract has just two functions:
- We have a receive function which is external and payable. As we have covered in the previous challenges, a receive function is triggered by default when a ether is sent to the contract without specifying any function name.
- In this function we have a require condition at first which checks for two conditions with an OR clause. We need to fulfill the require condition by either becoming the owner or sending ether in the transaction greater than the value of the variable prize. Becoming the owner does not seem achievable by looking at the code. Also the amount of ether to be sent is not too high so we will take that option.
- The value sent by the player in the transaction is transfered to the previous king. Then the player becomes the new king and the amount sent by the player is then set as the prize value for someone else to beat.
- We have another function which is basically a getter function which returns the current king address.

## Vulnerability
This contract has a two part vulnerability.
1. The smart contract uses the .transfer() function to send eth. This puts a gas limit of 2300 for code execution.

## How to avoid the vulnerability

## Solution

