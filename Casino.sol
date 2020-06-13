pragma solidity ^0.5.0;
/* 
This is a roulette variation where both the numbers and colors "spin". In other words, you could land on Red 27 once,
then on Black 27 another time.

Player's address must be admitted before placing bets. For testing purposes I removed the requirement for there to be at least 3 unique addresses betting.
Players can only make 1 bet per address.

Improvements that should be added in the future are commented on the bottom.
*/

contract CasinoGame {
    uint gameNumber;
    enum gameType {
        Roulette
        
    }
    
}


contract CasinoGameRoulette {
    //move to Treasury
    uint256 gameBalance;
    uint numBetsMapped;
    //first game = 0, second game =1...
    uint gameNumber;
    
    //used for "Random" number generator
    uint256 summationOfAllBetData;
    //will be used when delay is implemented --- bool wheelHasSpun;
    
    //RouletteWheelVariables
    uint WheelNumberMin;
    uint WheelNumberMax;
    uint WheelNumberRed;
    uint WheelNumberBlack;
    
    
    //constructor that initializes all related instances and sets game defaults
        
    //sets up the roulette game 
    constructor() public payable {
        gameBalance=0;
        numBetsMapped=0;
        summationOfAllBetData=0;
        
        WheelNumberMin=0;
        WheelNumberMax=36;
        WheelNumberRed=1;
        WheelNumberBlack=2;
    }
    
    modifier runBeforeSpin {
       //modifier for when a delay is implemented --- require(wheelHasSpun==false,"Too Late");
       //modifier to ensure at least 3 players (or addresses at play) --- require(admittedPlayers.length>2);
       require(admittedPlayers.length==numBetsMapped);
        _;
    }
    
    /* Manage Players in game */
    address[] admittedPlayers;
    
    function getAdmittedPlayers() public view returns(address[] memory) {
       return(admittedPlayers);
    }
    function verifyAdmittedPlayersAddress(address inputAddress) public view returns(bool) {
       bool bAddressIsValid;
       //add if(admittedPlayers.length==0){ return false; }
       for (uint i=0; i<admittedPlayers.length; i++) {
            if(admittedPlayers[i] == inputAddress){
                 bAddressIsValid=true;
            }
       }
       return(bAddressIsValid);
    }
    //add treasury check that chips were distributed
    function admitPlayer(address _address) external {
        bool alreadyAdmitted;
        
        alreadyAdmitted=checkInArrayOfAddresses(_address,admittedPlayers);
        
        if(!alreadyAdmitted) {
            admittedPlayers.push(_address);
        }
        else {
            revert("Already Admitted");
        }
    }
    function getPlayerCount() public view returns(uint count) {
        return admittedPlayers.length;
    }

    modifier onlyAdmittedPlayers(address playerAddress) {
        bool playerIsAdmitted;
        playerIsAdmitted=verifyAdmittedPlayersAddress(playerAddress);
        require(playerIsAdmitted);
        _;
    }
    
    //will become expensive as array grows. Should replace with mapping 
    function checkInArrayOfAddresses(address _address, address[] memory addressArray) internal view returns (bool) {
        bool bInArray;
        for(uint i=0;i<addressArray.length;i++) {
            if(addressArray[i]==_address) {
                bInArray=true;
            }
        }
        return bInArray;
    }
    struct admittedPlayerStruct {
        address payable playerAddressPayable;
        //uint...
    }
 
    struct Bet {
        address player;
        uint numChipsPlaced;
        uint colorBetOn;
        uint numberBetOn;
        uint256 betBlockNumber;
    }
    
    
    address[] myBetsIndexByAddressKey;
    mapping(address => Bet) public myBets;
    mapping(uint256 => Bet) public unorderedListOfBets;

    function setBet(address playerAddress,uint inputNumChips,uint inputNumberBetOn,uint inputColorBetOn) onlyAdmittedPlayers(playerAddress) public {
        //Bet storage UserBet = myBets[playerAddress];
        
        
        myBets[playerAddress].player=playerAddress;
        myBets[playerAddress].numChipsPlaced=inputNumChips;
        myBets[playerAddress].numberBetOn=inputNumberBetOn;
        myBets[playerAddress].colorBetOn=inputColorBetOn;
        myBets[playerAddress].betBlockNumber=block.number;
        
        //Index
        myBetsIndexByAddressKey.push(playerAddress);
        
        summationOfAllBetData = uint256(keccak256(abi.encodePacked(playerAddress,inputNumChips,inputColorBetOn,inputNumberBetOn,summationOfAllBetData)));
        numBetsMapped++;
        gameBalance+=inputNumChips;
    }
    
    function getBet(address playerAddress) view public returns(uint) {
        return myBets[playerAddress].numberBetOn;
    }
    
    function getSummationOfAllBetData() view public returns(uint256) {
        return summationOfAllBetData;
    }
    
     

    
    function rouletteModByNumColors(uint256 inputRandColor) view public returns(uint256) {
        uint256 return_random_color = (inputRandColor % 2)+1;
        return return_random_color;
    }
    function rouletteModByNumSlots(uint256 inputRand) view public returns(uint256) {
        uint256 return_random_number = inputRand % 37;
        return return_random_number;
    }
    function spinTheWheel() public view returns(uint256, uint256) {
       
        uint256 selectedWheelNumber;
        uint256 selectedWheelColor;
        bool playerWon;
        selectedWheelNumber=rouletteModByNumSlots(summationOfAllBetData);
        selectedWheelColor=rouletteModByNumColors(summationOfAllBetData);
       
       //will be added when function is no longer "view" --- is "view" for testing purposes
       // distributeWinnings(selectedWheelNumber,selectedWheelColor);
        
        if(selectedWheelNumber==unorderedListOfBets[0].numberBetOn){
            playerWon=true;
        }
        //will be added when function is no longer "view" --- is "view" for testing purposes   
        //gameNumber++;
       
        return (selectedWheelNumber,selectedWheelColor);
        //emit RouletteWheelResults(selectedWheelNumber,selectedWheelColor);
       
               /*        
        
        uint8 wheelResult;
            //Spin the wheel, 
            bytes32 blockHash= block.blockhash(playerblock);
            //security check that the Hash is not empty
 if (blockHash==0) throw;
        // generate the hash for RNG from the blockHash and the player's address
            bytes32 shaPlayer = sha3(playerSpinned, blockHash);
        // get the final wheel result
        wheelResult = uint8(uint256(shaPlayer)%37);
            //check result against bet and pay if win
        checkBetResult(wheelResult, playerSpinned, blockHash, shaPlayer);*/
       
     
    }
    
   // Winner[] winners; 
    
    //event RouletteResults(address[],uint8,)
    //[] winners,winningNum,winningColor,
    
//NOTE BENE!!!!
//MUST ADD PLAYERS TO MAPPING
    address[] playersIndexByAddress;
    struct Player {
        bool bWon;
    }
    mapping (address => Player) roulettePlayers;

    address[] winnersIndexByAddress;
    struct Winner {
        uint betMultiplier;
        uint256 numChipsWon;
    }
    mapping(address => Winner) winners;
   

    event RouletteWinners(address[],uint8,uint8);
    
    function distributeWinnings(uint256 inputSelectedWheelNumber,uint256 inputSelectedWheelColor) payable public {
        
        //some logic...
        //address tempAddress;
        //bool bIsAWinner;
        
        for(uint i=0;i<myBetsIndexByAddressKey.length;i++) {
            roulettePlayers[myBetsIndexByAddressKey[i]].bWon=checkBets(myBetsIndexByAddressKey[i],inputSelectedWheelNumber,inputSelectedWheelColor);
            
            if(roulettePlayers[myBetsIndexByAddressKey[i]].bWon==true) {
                winnersIndexByAddress.push(myBetsIndexByAddressKey[i]);
            }
        }
        
    }
    
    function checkBets(address keyAddress,uint256 inputSelectedWheelNumber,uint256 inputSelectedWheelColor) public returns(bool) {
        bool bWinningStatus;
        uint myBetsLength=myBetsIndexByAddressKey.length;
        
        if(myBets[keyAddress].numberBetOn==inputSelectedWheelNumber) {
            if(myBets[keyAddress].colorBetOn==inputSelectedWheelColor) {
                bWinningStatus=true;
            }
        }
        
        return(bWinningStatus);
    }
    
    event RouletteWheelResults(uint256,uint256);
    
    function spinTheWheelEmitter() public {
       
       uint256 selectedWheelNumber;
       uint256 selectedWheelColor;
       bool playerWon;
       selectedWheelNumber=rouletteModByNumSlots(summationOfAllBetData);
       selectedWheelColor=rouletteModByNumColors(summationOfAllBetData);
       
       distributeWinnings(selectedWheelNumber,selectedWheelColor);
       
       if(selectedWheelNumber==unorderedListOfBets[0].numberBetOn){
           playerWon=true;
       }
       
       gameNumber++;
       
       emit RouletteWheelResults(selectedWheelNumber,selectedWheelColor);

    }
    
     
    //function betOnRouge(uint8 betAmount,) payable public
    
    //function betOnNoir(uint8 betAmount,) payable public
    
    //function betOnManque(uint8 betAmount,) payable public
    
    //function betOnPasse(uint8 betAmount,) payable public
    
    //function betOnPair(uint8 betAmount,) payable public
    
    //function betOnImpair(uint8 betAmount,) payable public
     
    function betOnNumber(uint8 betAmount, uint8 rouletteWheelNumberGuess) payable public {
    /* 
       A bet is valid when:
       1 - the value of the bet is correct (=betAmount)
       2 - betType is known (between 0 and 5)
       3 - the option betted is valid (don't bet on 37!)
       4 - the bank has sufficient funds to pay the bet
    */

    /*
    require(number >= 0 && number <= numberRange[betType]);        // 3
    uint payoutForThisBet = payouts[betType] * msg.value;
    uint provisionalBalance = necessaryBalance + payoutForThisBet;
    require(provisionalBalance < address(this).balance);           // 4
    
    
    // we are good to go
    necessaryBalance += payoutForThisBet;
    bets.push(Bet({
      betType: betType,
      player: msg.sender,
      number: number
    }));
    
    */
  }
     
}

contract CFORun {
    address public cfo;
    constructor(address cfoAddress) public {
        cfo = cfoAddress;
    }
    modifier onlyOwner() {
        require(msg.sender == cfo);
        _;
    }
}

contract CasinoTreasury is CFORun {
    
    //values in eth
    uint256 totalCasinoBalance;
    uint256 chipValue = 100 finney;
    uint256 fee;
    address cfo;
    //values in numChips
    uint MaxBet=1000;
    uint minBet=5;
    address[] bannedPlayers;

    function getChipValue() public returns(uint256) {
        return(chipValue);
    }
    function setChipValue(uint256 newValue) external onlyOwner {
        if(newValue>=0) {
            chipValue=newValue;
        }
    }
    
    function takeProfits() internal {
        //uint amount = address(this).balance - maxAmountAllowedInTheBank;
        //if (amount > 0) {
        //    cfo.transfer(amount);
    //    }
    }
    
//*********************************************************************************************************************************    
//*********************************************************************************************************************************
    //will be added to AdmitPlayer
    mapping (address => bool) public wallets;
    function addWallet(address wallet) external onlyOwner {
        wallets[wallet] = true;
    }
//*********************************************************************************************************************************
//*********************************************************************************************************************************

    constructor(bytes32 _name) public {
        cfo=msg.sender;
    }

    
    
    //blacklistedPlayers[]
    
    /*
    contract Ownable {
    address public owner;
    constructor() public {
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}

pragma solidity ^0.4.24;
import "./Ownable.sol";

contract MyContract is Ownable {
    mapping (address => bool) public wallets;
    function addWallet(address wallet) external onlyOwner {
        wallets[wallet] = true;
    }
}

//optional way to distribute winnings:
    function mapWinningsToWinners() internal {
       uint256 winnings;
       //use array of Winner struct --- winners;
       
       
   }



    */
    
    
}

contract CasinoPlayer {
    
    address playerAddress;
    uint256 accountBalance;
    bytes32 casinoPlayerName;
    
    CasinoTreasury public treasuryInstance;
    
    function getmsgSender() public view returns(address) {
       return(msg.sender);
   }
   
   
   
   
   /*
    function checkBetValue() private returns(uint256 playerBetValue)
    {
        if (msg.value < minGamble) throw;
    if (msg.value > currentMaxGamble) //if above max, send difference back
    {
            playerBetValue=currentMaxGamble;
    }
        else
        { playerBetValue=msg.value; }
        return;
    }

*/



    //RequestChips()
    
    //SubmitBet






    //cashInChips()
    
    //function GameBuyIn(uint8 numChips) public {  
        
    //}

    //getChipBalance

    //buyChips


    
}

/*
Improvements that should be added in the future:
Contract will write to interfaces, such as 'contract RouletteTable is Roulettable, Tablable'

where we also import:
contract CasinoGame is Gameable, PlayerApprovable, 

library RouletteRules ==> using RouletteRules for RouletteRules.currRouletteTableInstance;

interface Casinoable
interface PlayerApprovable
interface Casinoable,  <--- will be added another day and will import .
CasinoTable is Tablable, PlayerApprovable (where player is first checked that their 
balance is atleast greater than the bet limit), casinoable, etc.. Player and game will be abstracted, 
actions will happen on casinoTable and will have better encapsulation and abstraction. 

Future additions will also include:
noSendEth modifiers to economise on gas
improved search + sort for datastructs like admittedPlayers

treasury will be updgraded to be able to manage multiple games and multiple game types

++chips will become ERC20 tokens++

//struct casinoGameDealer << May no longer be necessary

Notes about the game:
Currently any number can become either red or black. For example, if you roll 25 in one round, it may be black. If you roll 25 again, it may be red the next time.
We can remove this one day by mapping every other number as either red or black.

*/