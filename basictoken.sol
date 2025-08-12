// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract BasicToken {
    string public name = "BasicToken";
    string public symbol = "BTK";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    address public owner;
    bool public paused = false;
    
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public blacklisted;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Mint(address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);
    event Pause();
    event Unpause();
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }
    
    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }
    
    modifier notBlacklisted(address _address) {
        require(!blacklisted[_address], "Address is blacklisted");
        _;
    }
    
    constructor(uint256 _initialSupply) {
        owner = msg.sender;
        totalSupply = _initialSupply * 10**decimals;
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }
    
    // Function 1: Transfer tokens with custom features (pause and blacklist protection)
    function transfer(address _to, uint256 _value) 
        public 
        whenNotPaused 
        notBlacklisted(msg.sender) 
        notBlacklisted(_to) 
        returns (bool success) 
    {
        require(_to != address(0), "Invalid address");
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    
    // Function 2: Mint new tokens (only owner)
    function mint(address _to, uint256 _amount) 
        public 
        onlyOwner 
        whenNotPaused 
        notBlacklisted(_to) 
        returns (bool success) 
    {
        require(_to != address(0), "Invalid address");
        require(_amount > 0, "Amount must be greater than 0");
        
        totalSupply += _amount;
        balanceOf[_to] += _amount;
        
        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }
    
    // Function 3: Burn tokens from sender's balance
    function burn(uint256 _amount) 
        public 
        whenNotPaused 
        notBlacklisted(msg.sender) 
        returns (bool success) 
    {
        require(balanceOf[msg.sender] >= _amount, "Insufficient balance");
        require(_amount > 0, "Amount must be greater than 0");
        
        balanceOf[msg.sender] -= _amount;
        totalSupply -= _amount;
        
        emit Burn(msg.sender, _amount);
        emit Transfer(msg.sender, address(0), _amount);
        return true;
    }
    
    // Function 4: Toggle pause state (only owner)
    function togglePause() public onlyOwner returns (bool) {
        paused = !paused;
        if (paused) {
            emit Pause();
        } else {
            emit Unpause();
        }
        return paused;
    }
    
    // Function 5: Blacklist/Unblacklist addresses (only owner)
    function setBlacklistStatus(address _address, bool _status) 
        public 
        onlyOwner 
        returns (bool success) 
    {
        require(_address != address(0), "Invalid address");
        require(_address != owner, "Cannot blacklist owner");
        
        blacklisted[_address] = _status;
        return true;
    }
    
    // Standard ERC20 approve function
    function approve(address _spender, uint256 _value) 
        public 
        whenNotPaused 
        notBlacklisted(msg.sender) 
        notBlacklisted(_spender) 
        returns (bool success) 
    {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    // Standard ERC20 transferFrom function
    function transferFrom(address _from, address _to, uint256 _value) 
        public 
        whenNotPaused 
        notBlacklisted(_from) 
        notBlacklisted(_to) 
        notBlacklisted(msg.sender) 
        returns (bool success) 
    {
        require(_to != address(0), "Invalid address");
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "Allowance exceeded");
        
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        
        emit Transfer(_from, _to, _value);
        return true;
    }
}
