# King

Welcome to my Ethernaut solution series!
Today we will discuss the 9th problem called King.
This smart contract is a game where the player needs to become the king and stay as the king. The way he can become the king is to pay the contract more than the already existing prize. Once that is done, whoever was king before gets the amount of ether as a payout. The new value of prize is set to the amount which was paid by the player. This means that if the player wants to get his investment back, someone else has to become the king and pay the player out. Basically it is a ponzie scheme. The catch is that once the player submits the instance, Ethernaut will send more money than the player did and will take away the king status from the player.

## The goal
1. Become the king and stay as the king even after submitting the instance to Ethernaut.

## Code review

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
1. The smart contract uses the .transfer() function to send eth which puts a gas limit of 2300 for code execution. This in a way provides protection from re-entrancy attack by limiting the execution for the code on the EVM. But this also sets a limit to how much gas can be consumed while execution of the contract in the EVM. The transfer function's limit was designed with the idea in mind that current establishment of how much gas is sent and is needed for certain opcodes will remain same. This is in fact not true and the gas requirements are going to increase over time. The limit is going to create an issue in the future and hence it is adviced to avoid the usage of .transfer() function.
2.  The second and the main vulnerability is that the contract does not handle errors correctly. It continues execution without realising that something has errored out. This vulnerability is (not completely) a version of re-entrancy where the sequence of Check-effect-interact is not maintained and the interaction phase happens before effect phase. The phases are below:
Check: ```require(msg.value >= prize || msg.sender == owner);```
interact: ```king.transfer(msg.value);```
effect: ```king = msg.sender; prize = msg.value;```
Here if the interact phase fails to receive a response for the .transfer() function then effect phase does not get executed. And due to the poor handling of errors, the code partially gets executed and the value of king does not update.  

## How to avoid the vulnerability

The steps by which we can avoid the vulenrabilities:
1. Use of call() function instead of Transfer() function. Call function does not have any limitations set for gas.
2. The sequence of the Check-Effect-Interact phases should be maintained. The interact phase should happen after the effect phase is executed.

## Solution

Below is the attack contract.
```solidity
contract KingAttack {
    
    constructor(address _targetAddress) public payable {
        address(_targetAddress).call{value: msg.value}("");
    }

    fallback() external payable{
        revert("Wait for it!");
    }
}
```
### Code Review and analysis

The attack contract is pretty straightforward. 

- Constructor: The constructor takes the address of the target contract to interact with it. The constructor then executes call() function on the target address and sends the amount of ether specified by the player while deploying the contract. As the amount of ether is sent, the receive() function is called in the target contract.
- Receive() function: This function in the target contract then executes the previously discussed (Vulnerable) Check-Interact-Effect pattern of the code. 
- The line ```require(msg.value >= prize || msg.sender == owner);``` contains two conditions separated with an OR. Hence satisfying any one is sufficient. Either be the owner of the contract, or send more amount than the current value of prize variable. Here, as the value of prize variable is small enough, we can take that route.
- The next part is the Interact phase ```king.transfer(msg.value);```. As the variable King currently holds the address of the previous king, the amount we send to the contract to become the king is now transfered as a payout.
- Now we come to the Effect phase which is two part. Firstly, the variable king is updated with msg.sender value, which is our Attack contract address. Secondly, the prize variable is updated to the value we sent to the contract to become the king. Now the new prize value is set for the next participant to beat and become king. 
- Now that we are king, next step is to retain that status! As described in the problem description, once we submit the instance to Ethernaut, the Ethernaut system will try to take back the king status from us by sending some amount to the contract. We need to avoid that. 
- As soon as we submit the contract instance, Ethernaut will send some amount of ether to the target contract. Hence, the receive() function will be triggered once again.
- Now for the require statementl, as Ethernaut is the owner of the contract, they dont even need to send more ether than currently set Prize value. The second part of require statement checks for owner which they satisfy.
- This time msg.sender is Ethernaut and king is the Attack contract! So the amount in the msg.value is transfered to the Attack contract. To receive the Ether our Attack contract's fallback() function is going to be executed.
- To avoid Ethernaut taking the king status, the fallback() function in our Attack contract is going to help us. The only statement in the fallback function is revert() statment. This will rollback the current task and get back to the last state. So we are just stopping Ethernaut to become the king. The main problem with the target contract is that they do not handle this scenario and there is no further actions. We remain king!!

### Attack execution
- Get the address of target contract while deploying Attack contract as our constructor needs the target contract address to interact with it. Use the command ```await contract.address```
- To know the exact amount of Ether we need to send, execute ```await contract.prize()``` and check the zeroth element in the "words" array. That value corresponds the amount of wei the player needs to beat in order to become the king. It is easier to send in Ether denomination rather than in wei. To get the amount in ether use ```await web3.utils.fromwei('<amount in wei>', 'ether')``` command.
- Before you deploy the Attack contract, just check the value of the variable king using the command ```await contract.king()```. Make a note of it in your head.
- Then go ahead and deploy the contract.
- Once the contract is deployed, again check the king variable's value. It should be updated to our Attack contract's address now! you can also verify the value of prize variable and confirm that has changed to the amount we sent while deploying the contract.
- Once we have the king variable value updated, go ahead and submit the instance to Ethernaut. This will call the fallback() function in our Attack contract and fail to update the king back to Ethernaut's address.
- And that's it! we have successfully solved the challenge!