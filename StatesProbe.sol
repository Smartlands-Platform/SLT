pragma solidity ^0.4.16;

import "./Ownable.sol";

contract StatesProbe is Ownable {

// StateMachine <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    enum Stages {
        NotStarted,
        FirstIteration,
        SecondIteration,
        Finished
    }

    uint public startTime = 0;
    Stages public stage = Stages.NotStarted;

    function nextStage() internal {
        stage = Stages(uint(stage) + 1);
    }
    
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
        nextStage();
    }
    
    modifier timedTransitions() {
        // if (stage == Stages.FirstIteration && now >= startTime + 30 days)
        if (stage == Stages.FirstIteration && now >= startTime + 2 minutes)
            nextStage();
        // if (stage == Stages.SecondIteration && now >= startTime + 45 days)
        if (stage == Stages.SecondIteration && now >= startTime + 4 minutes)
            nextStage();
        _;
    }
// StateMachine >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 

    function start() onlyOwner atStage(Stages.NotStarted) transitionNext {
        startTime = now;
        lastStart++;
    }
    
    uint public lastPay = 100;
    uint public lastStart = 0;
    
    function ()
    payable 
    timedTransitions 
    atStages(Stages.FirstIteration, Stages.SecondIteration) 
    {
        lastPay = uint(stage);
    }
}