pragma solidity ^0.4.16;

import "./BaseToken.sol";

contract BountyProbe {

    uint public price = 1 szabo; // 0.001 ether / 1000 (3 decimalUnits of token)
    BaseToken public tokenReward;
    
    uint public startTime = 0;

    function () payable {
        uint amount = msg.value;
        require(amount >= 5 ether);
        tokenReward.transfer(msg.sender, amount / price);
    }

    function calculateFirstBounty(uint _amount) constant returns (uint amount) {
        if (_amount >= 5 ether && _amount < 10 ether) {
            return _amount * 115 / 100;
        } else if (_amount >= 10 ether && _amount < 20 ether) {
            return _amount * 120 / 100;
        } else if (_amount >= 20 ether && _amount < 50 ether) {
            return _amount * 125 / 100;
        } else if (_amount >= 50 ether && _amount < 100 ether) {
            return _amount * 130 / 100;
        } else if (_amount >= 100 ether && _amount < 300 ether) {
            return _amount * 140 / 100;
        } else if (_amount >= 300 ether && _amount < 1000 ether) {
            return _amount * 150 / 100;
        } else if (_amount >= 1000 ether && _amount < 2000 ether) {
            return _amount * 160 / 100;
        } else if (_amount >= 2000 ether && _amount < 3000 ether) {
            return _amount * 175 / 100;
        } else if (_amount >= 3000 ether) {
            return _amount * 2;
        } else {
            return _amount;
        }
    }
    
    function calculateSecondBounty(uint _amount) constant returns (uint amount) {
        require(startTime > 0);
        uint diff = now - startTime - 30;
        if (diff < 1 days) {
            return _amount * 110 / 100;
        } else if (diff >= 1 days && diff < 5 days) {
            return _amount * 106 / 100;
        } else if (diff >= 5 days && diff < 10 days) {
            return _amount * 103 / 100;
        } else if (diff >= 10 days && diff < 15 days) {
            return _amount;
        } else {
            return _amount;
        }
    }
    
    function one() constant returns (uint amount) {
        return 1 ether;
    }
}