# Force

Welcome to the 6th solution in my Ethernaut series!
Today we will discuss a problem called Force.

This challenge is here to familiarise us with the concept of Delegatecalls and how it works, how it can be used to delegate operations to on-chain libraries, and what the implications it has on execution scope.

## The goal
- The goal of this level is to make the balance of the contract greater than zero

## Code review
  
Let's take a look of the target contract:
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract Force {/*

                   MEOW ?
         /\_/\   /
    ____/ o o \
  /~____  =ø= /
 (______)__m_m)

*/}
```
WOW! such emptiness!
We have a beautifully empty contract here. Not emptier than my wallet tho lol!

### State Variables

### Constructor

### Functions

## Vulnerability

- The usual ways one can provide a way to accept Ether in a contract is by defining functions like "fallback" and "receive" and use "payable" decorators. But if it is not desired to accept Ether on the contract then simply not defining these functions and decorators is not enough. Even if nothing is defined, we cannot stop the contract from receiving Ether into its wallet address.
- The vulnerability in this level is a feature in solidity called selfdestruct(address) function. This function destroys the current contract on the blockchain and the amount of Ether stored in the contract's wallet is then sent to the address specified in the argument of the selfdestruct function. 
- Reasons one might use the selfdestruct() function are:
	- Spring Cleaning: Cleaning up old contracts or contracts that have completed their task. It comes in handy to move the Ether, then destroy the contract.
	- A way to upgrade contracts where one can destroy the old once and replace it with a new one. This method of upgrade is not recommended.
	- Break Glass: If there is an emergency and the creator needs to prevent any further damage from happening they could call the selfdestruct() function.
- The problems with the selfdestruct() function are that if it is really desired to not accept Ether in ways other than specified in the contract, then it becomes a problem. For e.g. lets look at a DOS attack. Consider a game which accepts Ether in denominations of 1 Ether and computes all the steps of the game in multiples of 1 Ether. Now the vulernability in this contract would be if the contract uses this.balance in the logic. Then anyone can send Ether other than multiples of 1 Ether to the contract using the selfdestruct() function and break the game as the logic is using this.balance (which is the contract's current balance) balance of the contract would not remain in multiples of 1 Ether and the game wont be functional. Hence Denial of service.

## How to avoid the vulnerability

- Avoiding Eth to be forcibly sent to the contract wallet is not possible. Hence, dont rely on "this.balance" while computing anything in the contract's logic as that value can be manipulated. Instead save the balance in another variable and compute the logic there.

## Solution

The attack contract is pretty straightforward. 

- Constructor: The constructor takes an address of the target contract as argument and uses it while creating an object of Force contract so we can interact with it. 
- Attack() function is a payable function. This function will first check if the caller has send some value greater than zero as we want to make sure there is some value in our contract before we perform the selfdestruct. 
- Next we create an attack address to which the self destruct function will send all the Ether. 
- The final step is selfdestruct(address) and we are all set!

### Attack execution
The attack execution is straightforward.
- Get the address of target contract before deploying Attack contract as our constructor needs the target contract address to interact with it. Use the command ```await contract.address```.
- Check the Ether balance of the target contract just to make sure before you execute the attack what the balance was. Use the command ```await getBalance(contract.address)```. The result should come back as 0.
- Deploy the attack contract with the target contract's address as the argument to the constructor. 
- Now that we have the attack contract deployed, you can call the attack function. Dont forget to send a little amount of Wei.
- Once that is done, again check the balance of the target contract to see it increased by 3 Wei.
- Boom! you have sent a contract some Ether even when there was no way for it to accept any!

## Conclusion

Contract's balance can be easily manipulated, so never rely on Contract's balance to perform any logical computations. 