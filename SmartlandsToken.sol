// This Token Contract implements the standard token functionality (https://github.com/ethereum/EIPs/issues/20)
// You can find more complex example in https://github.com/ConsenSys/Tokens 
pragma solidity ^0.4.8;

import "./BaseToken.sol";

contract SmartlandsToken is BaseToken {
    event Burn(address indexed burner, uint256 value);

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
    
    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint256 _value) public {
        require(_value > 0);
        require(_value <= balances[msg.sender]);
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        address burner = msg.sender;
        balances[burner] -= _value;
        totalSupply -= _value;
        Burn(burner, _value);
    }
}