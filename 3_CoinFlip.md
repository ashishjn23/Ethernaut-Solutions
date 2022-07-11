# CoinFlip

Welcome to the Ethernaut series with me!
Today we will discuss the 3rd problem called CoinFlip.
This smart contract is a coin flipping game where the player needs to get a winning streak by guessing the outcome of a coin. 

The goal of this challenge is:
1. Guess the correct outcome 10 times in a row

Let's take a look of the contract code:
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import '@openzeppelin/contracts/math/SafeMath.sol';

contract CoinFlip {

  using SafeMath for uint256;
  uint256 public consecutiveWins;
  uint256 lastHash;
  uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

  constructor() public {
    consecutiveWins = 0;
  }

  function flip(bool _guess) public returns (bool) {
    uint256 blockValue = uint256(blockhash(block.number.sub(1)));

    if (lastHash == blockValue) {
      revert();
    }

    lastHash = blockValue;
    uint256 coinFlip = blockValue.div(FACTOR);
    bool side = coinFlip == 1 ? true : false;

    if (side == _guess) {
      consecutiveWins++;
      return true;
    } else {
      consecutiveWins = 0;
      return false;
    }
  }
}
```
## Code review

### State Variables
We have three variables declared for the contract. 
- consecutiveWins is the public uint variable holding the wins in a row for the player. We need to somehow increment this value to 10 to win this game.
- FACTOR is the variable holding a constant value which is used as a part of the process of creating entropy.
- lastHash is a variable which stores the value of a hash of the last block of our Rinkby blockchain. It is a state variable which is used to compare if the privious call to this function had the same hash value. We will discuss this variable in detail later.

### Constructor
- The variable consecutiveWins needs to be initialised to Zero for every instance of the game.

### Functions
- We just have one function in this problem. The flip function takes in a parameter which is a bool. This is the guess provided by the player to play the game and predict the outcome as heads or tails mapped to True or False.
- The function also returns a bool which specifies that the guess by the player was correct or not.
The first part 
- lets look at line 18:
```solidity
uint256 blockValue = uint256(blockhash(block.number.sub(1)));
```
- Here block.number will give us the current block number, but as this block isnt mined yet, the contract cannot use it to create a hash. So we take the last mined block and compute a hash of that block number.
- Then we convert it to uint256 and store it in the variable blockValue. This variable is not needed in all instances, hence, it is not a state variable.
- Now the state variable lastHash is compared with blockValue to check if the last blockValue variable value is used again. The contract need to have a unique value everytime the function is called.

- on line 25, the value stored in the local variable blockValue is divided by the long number in the variable FACTOR. This action is done to increase the randomness. 
```solidity
uint256 coinFlip = blockValue.div(FACTOR);
```
- The value of coinFlip is compared to 1. If it matches then the variable side is True else False.
- Next it compares the the player's guess with the variable side. We need to match this variable 10 times in a row.

### Vulnerability

- 
- The flawed way of using randomness is using globally accessible variables for seeds. 