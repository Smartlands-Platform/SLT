pragma solidity ^0.4.16;

import "./Ownable.sol";
import "./SmartlandsToken.sol";

contract SmartlandsCrowdsale is Ownable {
    SmartlandsToken public tokenReward;
    mapping(address => uint256) public balanceOf;
    uint public fundingGoal = 2 * 1 ether;
    uint public price = 1 szabo; // 0.001 ether / 1000 (3 decimalUnits of token)
    
    bool public isFundsLocked = true;

    event GoalReached(address _beneficiary, uint _amountRaised);
    event FundTransfer(address _backer, uint _amount, bool _isContribution);

// StateMachine <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    enum Stages {
        NotStarted,
        FirstIteration,
        SecondIteration,
        Finished,
        FinishedAheadOfTime
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
    
    modifier transition(Stages _stage) {
        _;
        stage = _stage;
    }
    
    modifier timedTransitions () {
        // if (stage == Stages.FirstIteration && now >= startTime + 30 days)
        // if (stage == Stages.SecondIteration && now >= startTime + 45 days)
        require(stage > Stages.NotStarted);
        if (stage < Stages.FinishedAheadOfTime) {
            uint diff = now - startTime;
            if (diff >= 5 minutes && diff < 10 minutes && stage != Stages.SecondIteration) {
                stage = Stages.SecondIteration;
            } else if (diff >= 10 minutes && stage != Stages.Finished) {
                stage = Stages.Finished;
            }
        }
        _;
    }
// StateMachine >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 

    /**
     * Constrctor function
     *
     * Setup the owner
     */
    function SmartlandsCrowdsale (address _addressOfTokenUsedAsReward)
    {
        tokenReward = SmartlandsToken(_addressOfTokenUsedAsReward);
    }

    /**
     * Fallback function
     *
     * The function without name is the default function that is called whenever anyone sends funds to a contract
     */
    function () payable 
    timedTransitions 
    atStages(Stages.FirstIteration, Stages.SecondIteration) 
    {
        uint amount = msg.value;
        // require(amount >= 5 ether);
        
        balanceOf[msg.sender] += amount;
        tokenReward.transfer(msg.sender, calculateBonus(amount) / price);
        FundTransfer(msg.sender, amount, true);
    }
    
    function calculateFirstBonus (uint _amount) internal constant returns (uint amount) {
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
    
    function calculateSecondBonus (uint _amount) internal constant returns (uint amount) {
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

    function calculateBonus (uint _amount) constant returns (uint amount) {
        if (stage == Stages.FirstIteration) {
            return calculateFirstBonus(_amount);
        } else if(stage == Stages.SecondIteration) {
            return calculateSecondBonus(_amount);
        } else {
            return _amount;
        }
    }
    
    function startCrowdsale ()
    onlyOwner
    atStage(Stages.NotStarted)
    transitionNext 
    {
        startTime = now;
    }
    
    function unlockFunds () 
    onlyOwner
    {
        isFundsLocked = false;
    }
    
    function finishAheadOfTime () // move to payable?
    onlyOwner
    transition(Stages.FinishedAheadOfTime)
    {
        require(isGoalReached());
        GoalReached(owner, this.balance);
    }

    /**
     * Check if goal was reached
     *
     * Checks if the goal has been reached
     */
    function isGoalReached() constant returns (bool isReached) {
        return this.balance >= fundingGoal;
    }
    
    function timeToEnd() constant returns (uint time) {
        require(stage > Stages.NotStarted && stage < Stages.Finished);
        return (startTime + 10 minutes - now) / 1 minutes;
    }
    
    /**
     * Withdraw the funds
     *
     * Checks to see if goal or time limit has been reached, and if so, and the funding goal was reached,
     * sends the entire amount to the beneficiary. If goal was not reached, each contributor can withdraw
     * the amount they contributed.
     */
    function safeWithdrawal()
    timedTransitions
    atStages(Stages.Finished, Stages.FinishedAheadOfTime)
    {
        if (isGoalReached() && owner == msg.sender) {
            uint amountRaised = this.balance;
            if (owner.send(amountRaised)) {
                FundTransfer(owner, amountRaised, false);
            }
        }
        
        if (!isGoalReached() || !isFundsLocked) {
            uint amount = balanceOf[msg.sender];
            if (amount > 0 && msg.sender.send(amount)) {
                balanceOf[msg.sender] = 0;
                FundTransfer(msg.sender, amount, false);
            }
        } 
    }
}
