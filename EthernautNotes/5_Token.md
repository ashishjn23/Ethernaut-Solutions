# Token

Welcome to the next solution in my Ethernaut series!
Today we will discuss the 5th problem called Telephone.

This smart contract has a mapping called as balance which contains the balance of tokens for every user who wants to interact with the contract. It also has a transfer function to send these tokens to any other address. The mapping will get appended for any of the addresses on which this transfer function is called.

## The goal
- The player is given 20 tokens. The goal is to increase player's balance of tokens.

## Code review
  
Let's take a look of the contract code:
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract Token {

  mapping(address => uint) balances;
  uint public totalSupply;

  constructor(uint _initialSupply) public {
    balances[msg.sender] = totalSupply = _initialSupply;
  }

  function transfer(address _to, uint _value) public returns (bool) {
    require(balances[msg.sender] - _value >= 0);
    balances[msg.sender] -= _value;
    balances[_to] += _value;
    return true;
  }

  function balanceOf(address _owner) public view returns (uint balance) {
    return balances[_owner];
  }
}
```

### State Variables
We have two variables declared for the contract.
- We have a mapping called as "balances" which has key value pair of address to uint. This suggests that every address will have an associated uint assigned to it, which will hold the balance of token for that address.
- totalSupply is the value of total supply of tokens in the contract. This variable is not crutial to solve the challenge.

### Constructor
The constructor is straight forward. It initialized the token balance of the owner of the contract with the initial supply of tokens.

### Functions
This contract has two function:
- Transfer() function takes two arguments: an address variable "to", an address to which the token would be transfered and a uint variable "value" which will be the amount of tokens to be sent using this function. 
- This function first has a require statement ```require(balances[msg.sender] - _value >= 0);``` which checks if the balance of the caller of the function i.e. msg.sender has a balance of tokens more than the amount being sent in the current transaction.
- Then the balance of the sender in the "balance" mapping is reduced by the "value" amount and in the next statment, the "value" amount of tokens are added to the balance of address specified in the "to" variable.

## Vulnerability

- The vulnerability in this contract is Integer overflow. 
- Before we understand Integer overflow, lets learn few prerequisites:
	- If an "unsigned" integer exceeds the maximum value in a given situation, it simply just wraps around using modular arithmetic. This is basically the same as the odometer in the car ticking over from 999,999 all the way back to zero.
	- For eg. if we were to add 1 to the maximum unsigned short integer value of ```65,535 bits```, which in binary is: ```1111 1111 1111 1111```, it would simply roll over back to: ```0000 0000 0000 0000```, and not ```1 1111 1111 1111 1111```.
	- In our case, we have an integer underflow where if we subtract some value from 0, we wrap around to the maximum number. So if we subtract 1 from 0, we get 65535 in an Unsigned integer.
	- This underflow if the unsigned integer is going to help us get lots of tokens in the balance mapping in our contract!

## How to avoid the vulnerability

- Use OpenZepplin's SafeMath utility contract while performing arithmetic operations in your smart contract. This library checks for overflows while performing those calculations.
- The way this library checks for overflow is by doing the following:
```solidity
function add(a, b){
	uint c = a + b
	if (c < a) return (false, 0);
	return (true, c);
}
```
- The steps are:
```solidity
using SafeMath for uint256;		// use this statement to import the library
myNumber.add(anotherNumber);	// This is an e.g. to perform addition.
```

## Solution

- To solve the problem, we need to take advantage of the underflow weakness on two lines ```require(balances[msg.sender] - _value >= 0);``` and ```balances[msg.sender] -= _value;```
- On both these lines, if the value of the "_value" variable is more than the value of balances[msg.sender] then an integer underflow happends as both balances and _value contain unsigned integers.

### Attack execution
We do not need an attack script to solve this problem. We should solve this problem by interacing via the browser console.
- Firstly, get the balance of the player using the command ```await contract.balanceOf(player)```.
- Now, we can proceed to perform the attack. To do that we need one address which cannot be the player's or the contract address. This can be any address in the wild. To get this just go to https://rinkeby.etherscan.io/ and pick up any random address and use it for next step.
- Next we need to interact with the contract by calling the transfer function. This function takes two arguments: an address and a value. 
- As discussed before get any address.
- The value is going to be one greater than the player's balance as we need to perform an integer underflow. As we have checked the player balance which should be 20, provide 21 as the second argument.
- Execute ```await contract.transfer('<random address>', 21)```
- That's it for the attack. Now go ahead and check the player's balance again. This time it should be a much much greater value.
- And it is done!

## Conclusion

Integer under/over flow can be very costly, so use proper protection while performing arithmetic operations.