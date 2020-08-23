pragma solidity ^0.5.0;

import "../common/ERC20Token.sol";
import "../common/AccessController.sol";








/**
 * Simple treasury with no logic for players, betting, token access, 
 */
contract Treasury {

    mapping (address => uint) private balances;
    address public owner;
    
    event MadeDeposit(address depositorAddress, uint256 depositAmount, uint256 currBalance);
    event WithdrawalAlert(address withdrawalAddress, uint256 withdrawalAmount, uint256 currBalance);

    // Constructor is "payable" so it can receive the initial funding of 30, 

    constructor() public payable {
        require(msg.value >= 30 wei, "30 wei  funding required");
        /* Set the owner to the creator of this contract */
        owner = msg.sender;
    }

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
        emit MadeDeposit(msg.sender,msg.value,balances[msg.sender]+msg.value);
        return(balances[msg.sender]);
    }
    
    

    function withdraw(uint256 withdrawalAmount) public returns (uint currBalance) {

        if (withdrawalAmount <= balances[msg.sender] && balances[msg.sender]>0) {
            balances[msg.sender] -= withdrawalAmount;
            msg.sender.transfer(withdrawalAmount);
            emit WithdrawalAlert(msg.sender,withdrawalAmount,balances[msg.sender]-withdrawalAmount);
        }
        else {
            revert("Withdrawal Denied");
        }
        return balances[msg.sender];
    }
    
    function getPlayerBalance() public view returns (uint) {
        return balances[msg.sender];
    }
    
    function getTreasuryBalance() public view returns (uint) {
        
        return (address(this).balance)-balances[msg.sender];
    }




    //function migrateTreasury()
}
