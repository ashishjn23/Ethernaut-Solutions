# Fallback

Hello World to the first problem in the Ethernaut series: Fallback!

To beat this level the player needs to
1. claim ownership of the contract: The public address defined in the contract should contain player's address.
2. Reduce the balance of the contract to 0: The value of the contract's balance should be drained to 0!

Let's look at the contract code:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import '@openzeppelin/contracts/math/SafeMath.sol';

contract Fallback {

  using SafeMath for uint256;
  mapping(address => uint) public contributions;
  address payable public owner;

  constructor() public {
    owner = msg.sender;
    contributions[msg.sender] = 1000 * (1 ether);
  }

  modifier onlyOwner {
        require(
            msg.sender == owner,
            "caller is not the owner"
        );
        _;
    }

  function contribute() public payable {
    require(msg.value < 0.001 ether);
    contributions[msg.sender] += msg.value;
    if(contributions[msg.sender] > contributions[owner]) {
      owner = msg.sender;
    }
  }

  function getContribution() public view returns (uint) {
    return contributions[msg.sender];
  }

  function withdraw() public onlyOwner {
    owner.transfer(address(this).balance);
  }

  receive() external payable {
    require(msg.value > 0 && contributions[msg.sender] > 0);
    owner = msg.sender;
  }
}
```

## Let's quickly go over some of the important aspects of the contract code:

- We have a solidity contract named Fallback. The next few lines are the declaration of the usage of library "SafeMath" which we are foing to utilize for the operations of basic maths but this library is needed to perform those operations without the security vulnerabilities.

```solidity
  using SafeMath for uint256;
  mapping(address => uint) public contributions;
  address payable public owner;
  ```

The 2 variables contributions and owner are defined.
- "contributions" is a mapping with address as the key and uint as the value in the key value pair. The value of contributions corresponding to every address will be stored in this mapping variable. 
- "owner" is a payable and public variable which holds the address of the owner of the contract. By now you must have got to know that the value of this variable should be modified and should be updated with the player's address.

Then we have the definition of the constructor:
```solidity
  constructor() public {
    owner = msg.sender;
    contributions[msg.sender] = 1000 * (1 ether);
  }
```
- The msg.sender becomes the owner of the contract. But the msg.sender value when the constructor is run will be the address of the one who deploys the contract. Which would definitely not be you!! ;p
- Then the contributions mapping variable for the key of the owner/deployer address(then msg.sender) will be assigned the value of 1000 ether! (Lucky guy!)

I am assuming the "onlyOwner" Modifier concept is known. If not follow this: [onlyOwner](https://docs.openzeppelin.com/contracts/2.x/api/ownership#Ownable-onlyOwner--)

Now, in the below function:
```solidity
  function contribute() public payable {
    require(msg.value < 0.001 ether);
    contributions[msg.sender] += msg.value;
    if(contributions[msg.sender] > contributions[owner]) {
      owner = msg.sender;
    }
  }
```
- This is a public payable function. It first check if the value sent using this function is greater that 0.001 ether. If so, the contributions mapping variable value for the sender of the function (which would be the player) will get incremented by msg.value. And finaly, if the contributions of the sender of the msg(in this case player) has reached and surpassed the owner's contributions (1000 ether) then the player becomes the onwer! 
- But as you can see that the limit of sending ether is 0.001 ether at a time. Which means player will have to run this function 1000 * 1000 times! which is so big, I cant even try to calculate! XD
- Hence, this is a function just created to trick the player and is not of any use to solve the problem.

Next we have a helper function which returns the contributions value for the sender of the message.

```solidity
  function getContribution() public view returns (uint) {
    return contributions[msg.sender];
  }
```

here we have a function which is actually usefull to solving the problem
```solidity
  function withdraw() public onlyOwner {
    owner.transfer(address(this).balance);
  }
```
- In this function, the onlyOwner modifier is used. This modifier actually checks if the caller of the function is the owner of the contract. Only then the function is executed further. 
- If the function is really called by the owner, then all the ether balance corresponding to the contract address is transfered out to the owner! This is exactly what will help us complete the 2nd task of draining the balance of the contract address. But, we need to become the onwer first.

The last but the most important function of the code is the "recieve" function.
```solidity
  receive() external payable {
    require(msg.value > 0 && contributions[msg.sender] > 0);
    owner = msg.sender;
  }
```
- As you can see it is not a normal function. It does not have the "function" identifier as a normal function has. It's a receive function now known as a fallback function (the name of the challenge!). 
- The purpose of this function is: Anytime ether is sent to this contract, and the sender doesnt specify any function name while sending (I will show how that can be done later) then the ether is transfere to the contract address and this fallback/receive function is executed. 

## Vulnerability
- The receive function is the main culprit as it is public and makes the caller the owner immediately (after checking 2 conditions, but still!)
- Only 2 checks specified here are not enough to stop us from becoming the owner.  
- In this contract's case, the msg.value is checked to be greater than 0 and the contributions of the sender need to be more than 0. Once these conditions are met, the msg.sender becomes the owner. This is what we want right!
- If the player is able to send any amount of ether without specifying any function name and has contriburted something earlier, then the player becomes the owner!


## Solution
Now that we have covered all the functions, lets understand the solution steps to the problem.
- First of all, Let's get a new instance of the smart contract by clicking the blue button after the smart contract on the ethernaut problem page.
- Open the console and check the contract.owner address and player address.
- As we have already tried to understand all the functions, we have understood that the receive function is the key to solving this problem. The way we can use the receive function is by sending money to the smart contract without specifying any function name. This will trigger the receive function. But we can't yet just do that as there is a requirement that the msg sender should have contributed some ether to the contract.
- Now the first step is to use the contribute function and get some ether associated to our address in the contributions mapping by performing below actions in the console:
```solidity
await contract.contribute({value: 4})
```
- This will add the value 4 to our existing 0 in the mapping contributions. This was required if we needed to use the receive function and now we are a part of the contributors list. To check if the contributions mapping value corresponding to the player's address has increased by 4 Wei use the following command, this will return the sender's corresponding value in the mapping.
```solidity
await contract.getContribution()
```
- Once the player has some ether assigned in the contributions mapping, one of the conditions in the require statement in the receive function is met. The only other condition in that require statement is msg.value should be greater than 0 while calling the receive function. This can be taken care of while triggering the function.
- Now we can go ahead and call the receive function by using the following RPC command on the contract to send a transaction (with some minimum ether, in this case 4 Wei). 
```solidity
await contract.sendTransaction({value: 4})
```
- This will trigger the following code on line 54:
```solidity
owner = msg.sender;
```
- Go ahead and check the owner of the contract by using the following command:
```solidity
await contract.owner()
```
- Viola! you will see your address as the owner of the contract!!
- Now the final step of solving this problem is executing the withdraw function:
```solidity
await contract.withdraw()
```
This will execute the following code, which will send the balance of the contract's ether balance to the owner's address. And by now the player is the owner! So the final step of the problem is completed!
```solidity
owner.transfer(address(this).balance);
```
- Go ahead and perform the final check by executing the final command and check if player's address has the balance. Also check if the contract's address balance is 0.
```
await getBalance(player)
await getBalance(contract.address)
```



## Hope you found the explanation helpful and were able to understand the solution in detail! See you in the next post!