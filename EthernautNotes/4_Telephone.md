# King

Welcome to the next solution in my Ethernaut series!
Today we will discuss the 4th problem called Telephone.

This challenge is nothing fancy. Just a contract we need to take control over. There is just one condition we need to satisfy and the contract lets us take the ownership.

## The goal
- Claim ownership of the contract.

## Code review
  
Let's take a look of the contract code:
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Telephone {

  address public owner;

  constructor() public {
    owner = msg.sender;
  }

  function changeOwner(address _owner) public {
    if (tx.origin != msg.sender) {
      owner = _owner;
    }
  }
}
```

### State Variables
We have just one variables declared for the contract.
- Owner is the variable which holds an address for the owner of the contract. 

### Constructor
The constructor is straight forward. It initialized the owner with the address of whoever deploys the contract.

### Functions
This contract has just one function:
- The changeOwner function takes an address as argument. It then updates the owner to that address. But it has a require statement which first check and makes sure that transaction origin ```tx.origin``` is not equal to the sender of the message ```msg.sender```

## Vulnerability
- The vulnerability in this contract is very similar to Cross-Site Request Forgery. Let us first understand the difference between transaction origin and message sender is:
- Message sender is the immediate address from which the communication to the contract has happened. Message sender can be an Externally Owned Account(EOA) and also another contract.
- Transaction origin refers to the address from where the transaction originated. This can only be an (EOA. Lets understand transaction chains:
	- Suppose there are three contracts A, B and C. There is also an EOA James. 
	- James triggers a contract A. A then executes a function in B by sending a transaction to it.
	- B then execute a function in C by sending a transaction. Now in the contract C, msg.sender is address of contract B as B is the immediate sender of communication. But the transaction origin is the address of James as he is the originator of the chain of transactions. As you can see the transaction origin cannot be a contract address.
- Confusion in tx.origin and msg.sender can lead to phishing-style attacks.
- In this problem, while calling the function changeOwner() the message sender and transaction origin should not be the same.

## How to avoid the vulnerability

The way by which we can avoid the vulenrabilities is by not using transaction origin to validate the users as attacker can force the victim to execute a malicious contract. 

## Solution

Below is the attack contract.
```solidity
pragma solidity ^0.8.0;

import "./Telephone.sol";

contract Attack {
    Telephone telephoneContract;

    constructor(Telephone _telephoneContract) {
        telephoneContract = Telephone(_telephoneContract);
    }

    function attack() public {
        telephoneContract.changeOwner(msg.sender);
    }
}

```
### Code Review and analysis

The attack contract is pretty straightforward. 

- Constructor: The constructor takes the address of the target contract to interact with it by using the address to create an object of the telephoneContract contract.
- The only other function is attack(). This function will call the function changeOwner() with the argument of msg.sender from the attack contract, which will be the player's address as in attack contract the msg.sender is the player. As the changeOwner() function is called by our Attack contract, the msg.sender in the target contract will reflect the address of attack contract. Although, the tx.origin will be player's address.

### Attack execution
- Get the address of target contract while deploying Attack contract as our constructor needs the target contract address to interact with it. Use the command ```await contract.address```
- Before trying to attack the target contract, use the command ```await contract.owner()``` which is a public getter function in the target contract to know the current owner of the contract.
- Also try the command ```await contract.changeOnwer()``` to change the contract. As here the player is the message.sender and tx.origin, the require statement in the function will fail.
- Now go ahead and deploy the Attack contract using the target contract's address as the input to the constructor. 
- This will create an instance of attack contract which has the telephoneContract object created pointing to the instance of target contract.
- The next and final step is to call the function attack() on the attack contract. This will call the target contract's changeOwner function.
- check the owner value again by executing command ```await contract.owner()``` and verify that the player address is now the owner variable's value.
- And Voila! we have successfully solved the challenge!