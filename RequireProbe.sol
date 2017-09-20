pragma solidity ^0.4.16;

import "./BaseToken.sol";

contract RequireProbe {

    uint public price = 1 szabo; // 0.001 ether / 1000 (3 decimalUnits of token)
    BaseToken public tokenReward;

    function () payable {
        uint amount = msg.value;
        require(amount >= 5 ether);
        tokenReward.transfer(msg.sender, amount / price);
    }

}