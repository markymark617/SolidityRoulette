pragma solidity ^0.5.0;

//takes chips in Bets
contract CasinoGameRoulette {

}

//exchanges chips for ether and vice versa
//registers all players
contract CasinoTreasury {
    uint public casinoTreasuryBalance;
    event ReceiveEth(uint value);
    
    function() external payable {
        emit ReceiveEth(msg.value);
        casinoTreasuryBalance+=msg.value;
    }
    function getBalance() public view returns(uint) {
        return(address(this).balance);
    }
    function getAddress() public view returns(address) {
        return (address(this));
    }
    

}

//exchanges ether for chips and vice versa
//deposit and withdraw ether for exchange with Treasury
contract CasinoPlayerAccount {
    
    CasinoTreasury private casinoTreasuryInstance;
    
    constructor() public {
        casinoTreasuryInstance = new CasinoTreasury();
    }
    
    function getBalance() view public returns(uint) {
        return(address(this).balance);
    }
    
    function getBalanceOfInstance() view public returns(uint) {
        return(casinoTreasuryInstance.getBalance());
    }
    
    function sendEth(address payable _receiver) public payable {
        //deprecated for better error handling ---> _receiver.send(msg.value);
        _receiver.transfer(msg.value);
    }
    
    //fallback that transfers ether CasinoPlayerAccount receives to the Treasury
    function() external payable {
        address(casinoTreasuryInstance).transfer(msg.value);
    }
}