# Fallout

Welcome to the Ethernaut series with me!
Today we will discuss the 2nd problem Fallout.

The goal of this challenge is to:
1. Take ownership of the contract.

Let's take a look at the target contract:
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import '@openzeppelin/contracts/math/SafeMath.sol';

contract Fallout {
  
  using SafeMath for uint256;
  mapping (address => uint) allocations;
  address payable public owner;


  /* constructor */
  function Fal1out() public payable {
    owner = msg.sender;
    allocations[owner] = msg.value;
  }

  modifier onlyOwner {
	        require(
	            msg.sender == owner,
	            "caller is not the owner"
	        );
	        _;
	    }

  function allocate() public payable {
    allocations[msg.sender] = allocations[msg.sender].add(msg.value);
  }

  function sendAllocation(address payable allocator) public {
    require(allocations[allocator] > 0);
    allocator.transfer(allocations[allocator]);
  }

  function collectAllocations() public onlyOwner {
    msg.sender.transfer(address(this).balance);
  }

  function allocatorBalance(address allocator) public view returns (uint) {
    return allocations[allocator];
  }
}
```

## Code review
If you have followed solution to the last problem, this one is a little similar. It has two variables declared. 
- First is a similar public payable mapping with the Address -> uint as the key and value.
- Second is the public payable owner containing the owner of the contract.

### Constructor
- Here we have a function which they have marked as the constructor. This function has a name matching the contract.

```
  /* constructor */
  function Fal1out() public payable {
    owner = msg.sender;
    allocations[owner] = msg.value;
  }
```

- the sender of the msg becomes the owner and the value sent while calling the function gets assigned in the allocations mapping for the owner.

### Code body
- The contract has 4 functions and a modifier defined.
- The modifier is created to check if in the function where it is decorated, the caller is the owner or not.
- The allocate function..
## I am not going to waste your time explaining the remaining of the code as nothing in the code body is usefull for the problem.

## Vulnerability
- This is problem is a tricky one. We vulnerability lies in the constructor definition. If you notice closely, the constructor name is Fal1out and not Fallout! XD The second "l" is a one.
- You must have figured out by now that anyone can call this function at any time and not just during initiation as its not a constructor!
- Solidity devs changed the practice of constructor definition to use the keyword "constructor" instead of using the contract name. This avoids such mistakes of misspelling the constructor names. 
- As the Fal1out function makes the caller the owner of the contract, and the function being public, makes it vulnerable.

## Solution

- The solution is strightforward. The only concept we needed to know was the constructor nomenclature and find the minute detail of the misspelling in the "Fal1out" function name.
- We just have to execute the vulnerable function and become the owner. as simple as that!
```
await contract.Fal1out()
```

## Done!

Thanks for following the series with me!
See you in the next one. Bye!