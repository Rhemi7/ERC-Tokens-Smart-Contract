//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract RhemiInu {
    mapping(address => uint256) balances;

    //Accounts allowed to withdraw
    mapping(address => mapping(address => uint256)) allowedAccounts;

    // cost of token to one ETH
    uint256 public cost = 1000;

    uint256 public totalSupply;
    uint256 public decimals;
    string public name;
    string public symbol;

    //Contructor to assign the total number of tokens
    //created to the address of the contract owner

    constructor(
        uint256 _total,
        uint256 _decimals,
        string memory _name,
        string memory _symbol
    ) {
        totalSupply = _total;
        decimals = _decimals;
        name = _name;
        symbol = _symbol;

        balances[msg.sender] = totalSupply;
    }

    event Approval(
        address indexed tokenOwner,
        address indexed spender,
        uint256 tokens
    );

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Print(uint256 value);

    function getTotalSupply() public view returns (uint256) {
        return totalSupply;
    }

    //Get balance of a wallet
    function balanceOfWallet(address walletOwner)
        public
        view
        returns (uint256)
    {
        return balances[walletOwner];
    }

    function transferToken(uint256 tokenAmount, address receiver)
        public
        returns (bool)
    {
        require(
            tokenAmount <= balances[msg.sender],
            "You do not have enough tokens in your wallet"
        );
        // calculatePrice(tokenAmount);
        balances[msg.sender] = balances[msg.sender] - tokenAmount;
        balances[receiver] = balances[receiver] + tokenAmount;
        emit Transfer(msg.sender, receiver, tokenAmount);
        return true;
    }

    function approve(address delegate, uint256 tokenAmount)
        public
        returns (bool)
    {
        allowedAccounts[msg.sender][delegate] = tokenAmount;
        emit Approval(msg.sender, delegate, tokenAmount);
        return true;
    }

    function getTokensApproved(address owner, address delegate)
        public
        view
        returns (uint256)
    {
        return allowedAccounts[owner][delegate];
    }

    function transferByDelegate(
        address owner,
        address thirdParty,
        uint256 tokens
    ) public returns (bool) {
        require(tokens <= balances[owner], "Insufficient balance");
        require(tokens <= allowedAccounts[owner][msg.sender]);
        balances[owner] = balances[owner] - tokens;
        allowedAccounts[owner][msg.sender] =
            allowedAccounts[owner][msg.sender] -
            tokens;
        balances[thirdParty] = balances[thirdParty] + tokens;
        return true;
    }

    // Function for converting ETH paid into value of token
    function calculateTokens(uint256 value) public view returns (uint256) {
        uint256 newValue = (value * cost) / 10**18;
        return newValue;
    }

    // Function for Eth sent into contract address
    function buyToken(address _rec) public payable returns (bool) {
        uint256 _amount = msg.value;
        uint256 tokensToBUY = calculateTokens(_amount);
        emit Print(tokensToBUY);
        require(transferToken(tokensToBUY, _rec), "");
        return true;
    }
}
