pragma solidity ^0.5.0;

contract SingleTreasury {

    mapping (address => uint) private balances;
    address public owner;

    // Constructor is "payable" so it can receive the initial funding of 30, 

    constructor() public payable {
        require(msg.value >= 30 wei, "30 wei  funding required");
        /* Set the owner to the creator of this contract */
        owner = msg.sender;
        playerCount=1;
    }
    
    uint private playerCount;
    struct Players {
        address playerAddr;
        uint balance;
    }
    address[] playerlist; 

    /**
     *Adds funds to the Treasury, in case you clean out the house but want to keep playing 
     */
    function addFunds() public payable returns(uint,bytes32,uint) {

        uint balance = address(this).balance;
        balance += msg.value;
        uint amountAdded = balance-address(this).balance;

        return(address(this).balance,"Thanks...",amountAdded);
    }
    
    function depositEthForChips() public payable returns(uint) {
        balances[msg.sender]+=msg.value;
       
       //insert register player logic here 
        playerCount++;
        
        return(balances[msg.sender]);
    }
    
    function getPlayerBalance() public view returns (uint) {
        return balances[msg.sender];
    }
    
    function getTreasuryBalance() public view returns (uint) {
        
        return (address(this).balance)-balances[msg.sender];
    }
}
