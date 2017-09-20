// This Token Contract implements the standard token functionality (https://github.com/ethereum/EIPs/issues/20)
// You can find more complex example in https://github.com/ConsenSys/Tokens 
pragma solidity ^0.4.8;

import "./BaseToken.sol";

contract SmartlandsToken is BaseToken {

    string public name = "Smartlands Token";
    uint8 public decimals = 3;
    string public symbol = "SLT";
    string public version = '0.1';

    function SmartlandsToken(
        uint256 _initialAmount
        ) {
        balances[msg.sender] = _initialAmount;
        totalSupply = _initialAmount;
    }
}