 pragma solidity ^0.4.16;

import "./Destructible.sol";
import "./SmartlandsToken.sol";

contract SmartlandsPresale is Destructible {
    SmartlandsToken public tokenReward;
    mapping(address => uint256) public balanceOf;
    
    uint public price = 1 szabo; // 0.001 ether / 1000 (3 decimalUnits of token)
    uint public period = 15 minutes;
    
    uint public totalAmountRaised = 0;

    event FundTransfer (address _backer, uint _amount, bool _isContribution);

// StateMachine <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    enum Stages {
        NotStarted,
        InProgress,
        Finished
    }

    uint public startTime = 0; // temporary public
    Stages public stage = Stages.NotStarted;

    modifier atStage (Stages _stage) {
        require(stage == _stage);
        _;
    }
    
    modifier transitionNext () {
        _;
        stage = Stages(uint(stage) + 1);
    }
    
    modifier timedTransitions () {
        require(stage > Stages.NotStarted);
        uint diff = now - startTime;
        if (diff >= period && stage != Stages.Finished) {
            stage = Stages.Finished;
        }
        _;
    }
// StateMachine >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 

    function SmartlandsPresale (address _addressOfTokenUsedAsReward)
    {
        require(_addressOfTokenUsedAsReward != 0x0);
        tokenReward = SmartlandsToken(_addressOfTokenUsedAsReward);
    }

    function () payable 
    timedTransitions 
    atStage(Stages.InProgress) 
    {
        uint amount = msg.value;
        // require(amount >= 5 ether);
        
        totalAmountRaised += amount;
        balanceOf[msg.sender] += amount;
        tokenReward.transfer(msg.sender, calculateBonus(amount) / price);
        
        FundTransfer(msg.sender, amount, true);
    }
    
    function calculateBonus (uint _amount) internal constant returns (uint amount) {
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
    
    function startPresale ()
    onlyOwner
    atStage(Stages.NotStarted)
    transitionNext 
    {
        startTime = now;
    }
    
    function minutesToEnd () constant returns (uint _time) {
        require(stage > Stages.NotStarted && stage < Stages.Finished);
        uint endTime = startTime + period;
        uint toEndTime = endTime - now;
        return toEndTime < period ? toEndTime / 1 minutes : 0;
    }
    
    function amountLeft () constant returns (uint _balance) {
        return this.balance;
    }
    
    function safeWithdrawal (address _tokenReceiver)
    onlyOwner
    timedTransitions
    atStage(Stages.Finished)
    {
        require(_tokenReceiver != 0x0);
        uint amountRaised = this.balance;
        owner.transfer(amountRaised);
        tokenReward.transfer(_tokenReceiver, tokenReward.balanceOf(this));
        
        FundTransfer(owner, amountRaised, false);
    }
}
