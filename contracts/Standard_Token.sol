/*Most, basic default, standardised Token contract.
Allows the creation of a token with a finite issued amount to the creator.

Based on standardised APIs: https://github.com/ethereum/wiki/wiki/Standardized_Contract_APIs
.*/

contract Token {
    function totalSupply() constant returns (uint256 supply) {}
    function balanceOf(address _owner) constant returns (uint256 balance) {}
    function transfer(address _to, uint256 _value) returns (bool success) {}
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}
    function approve(address _spender, uint256 _value) returns (bool success) {}
    function unapprove(address _spender) returns (bool success) {}
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approved(address indexed _owner, address indexed _spender, uint256 _value);
    event Unapproved(address indexed _owner, address indexed _spender);
}

contract Standard_Token is Token {
    function Standard_Token(uint256 _initial_amount) {
        balances[msg.sender] = _initial_amount;
        total_supply = _initial_amount;
    }

    function transfer(address _to, uint256 _value) returns (bool success) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        //if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    //NOTE: This function suffers from a bug atm. It is a hack. It only works if arranged like this.
    //Here be dragons.
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        //same as above. Replace this line with the following if you want to protect against wrapping uints.
        //if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            Transfer(_from, _to, _value);
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function unapprove(address _spender) returns (bool success) {
        allowed[msg.sender][_spender] = 0;
        Unapproved(msg.sender, _spender);
        return true;
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        //this is a check to make sure you don't wrap around for approving max (2^256 -1)
        if(allowed[msg.sender][_spender] + _value > allowed[msg.sender][_spender]) {
          allowed[msg.sender][_spender] += _value;
          Approved(msg.sender, _spender, _value);
          return true;
        } else { return false; }
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    function totalSupply() constant returns (uint256 _total) {
        return total_supply;
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 total_supply;
}