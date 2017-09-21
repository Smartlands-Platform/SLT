pragma solidity ^0.4.16;

import "./Ownable.sol";

contract CrowdsaleProbe is Ownable {

// StateMachine <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    enum Stages {
        NotStarted,
        FirstIteration,
        SecondIteration,
        Finished
    }

    uint public startTime = 0;
    Stages public stage = Stages.NotStarted;

    modifier atStage(Stages _stage) {
        require(stage == _stage);
        _;
    }
    
    modifier atStages(Stages _first, Stages _second) {
        require(stage == _first || stage == _second);
        _;
    }
    
    modifier transitionNext() {
        _;
        stage = Stages(uint(stage) + 1);
    }
    
    modifier timedTransitions() {
        // if (stage == Stages.FirstIteration && now >= startTime + 30 days)
        // if (stage == Stages.SecondIteration && now >= startTime + 45 days)
        require(stage > Stages.NotStarted);
        uint diff = now - startTime;
        if (diff >= 2 minutes && diff < 4 minutes && stage != Stages.SecondIteration) {
            stage = Stages.SecondIteration;
        } else if (diff >= 4 minutes && stage != Stages.Finished) {
            stage = Stages.Finished;
        }
        _;
    }
// StateMachine >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 

    function start() onlyOwner atStage(Stages.NotStarted) transitionNext {
        startTime = now;
    }
    
    function () payable 
    timedTransitions 
    atStages(Stages.FirstIteration, Stages.SecondIteration) 
    {
        lastpay = uint(stage); 
    }
    
    uint public lastpay = 100;
    uint public stageWithdrawal = 100;
    
    function safeWithdrawal ()
    timedTransitions
    atStage(Stages.Finished)
    {
        stageWithdrawal = uint(stage);
    }
    
    function time() constant returns (uint _minutes) {
        require(stage > Stages.NotStarted);
        return (now - startTime) / 1 minutes;
    }
}