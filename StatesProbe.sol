pragma solidity ^0.4.16;

import "./BaseToken.sol";

contract BountyProbe {

    enum Stages {
        NotStarted,
        FirstIteration,
        SecondIteration,
        Finished
    }
    
    uint public price = 1 szabo; // 0.001 ether / 1000 (3 decimalUnits of token)
    BaseToken public tokenReward;
    
    uint public startTime = 0;
    
    Stages public stage = Stages.NotStarted;

    modifier atStage(Stages _stage) {
        require(stage == _stage);
        _;
    }

    function nextStage() internal {
        stage = Stages(uint(stage) + 1);
    }
    
    modifier timedTransitions() {
        if (stage == Stages.FirstIteration && now >= startTime + 30 days)
            nextStage();
        if (stage == Stages.SecondIteration && now >= startTime + 45 days)
            nextStage();
        _;
    }

    function () payable {
        uint amount = msg.value;
        require(amount >= 5 ether);
        tokenReward.transfer(msg.sender, amount / price);
    }

    function calculateFirstBounty(uint _amount) constant returns (uint amount) {

    }
    
    function calculateSecondBounty(uint _amount) constant returns (uint amount) {

    }
    
    function one() constant returns (uint amount) {
        return 1 ether;
    }
}