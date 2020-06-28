/**
 *Submitted for verification at Etherscan.io on 2020-06-03
*/

pragma solidity 0.6.0;

contract HappyGuess{
    
    uint public numOfPlayers;
    
    mapping(uint => address) winnerAddresses;
    
    mapping(uint => uint) winnerNumber;
    
    uint currentNumOfPlayers;
    
    mapping(uint => mapping(address => uint)) bettingRecord;
    
    mapping(uint => address[]) participantAddress;
    
    mapping(uint => uint[]) currentNumbers;
    
    uint period;
    
    constructor() public {
        numOfPlayers = 3;
        period = 0;
    }
    
    //Set the number of players
    function setNumOfPlayers(uint _players) public {
        require(_players >= 3, "The number of players cannot be less than 3.");
        require(currentNumOfPlayers == 0, "The number of players cannot be less than 3.");
        numOfPlayers = _players;
    }
    
    //Start betting
    function startGame(uint _number) public payable {
        require(msg.value == 1 ether, "The bet amount must be equal to 1ETH.");
        require(_number > 0, "The number is greater than 0");
        require(_number <= 50, "The number is less than or equal to 50");
        require(currentNumOfPlayers < currentNumOfPlayers + 1, "currentNumOfPlayers overflow.");
        require(currentNumOfPlayers + 1 <= numOfPlayers, "The number of players is full.");
        require(bettingRecord[period][msg.sender] == 0, "This address is already betted, please don't bet repeatedly.");
        
        currentNumOfPlayers += 1;
        
        participantAddress[period].push(msg.sender);
        bettingRecord[period][msg.sender] = _number;
        currentNumbers[period].push(_number);
        
        if(currentNumOfPlayers == numOfPlayers) {
            
            uint middleNumber = uint(keccak256(abi.encodePacked(block.difficulty, now, block.gaslimit, block.number)));
            
            require(middleNumber != 0, "God decided that no one is winning now.");
            
            while(middleNumber % 100 == 0) {
                middleNumber = middleNumber / 100;
            }
            
            uint winningNumbers;
            uint standardNumber = middleNumber % 100 / 2 == 0 ? 1 : middleNumber % 100 / 2;
            
            for(uint i = 0; i < numOfPlayers; i++) {
                uint subRes;
                uint sr = 
                bettingRecord[period][participantAddress[period][i]] 
                >= 
                standardNumber 
                ? 
                bettingRecord[period][participantAddress[period][i]] - standardNumber 
                :
                standardNumber - bettingRecord[period][participantAddress[period][i]];
                if(i == 0) {
                  subRes = sr;
                  winningNumbers = bettingRecord[period][participantAddress[period][i]];
                }
                
                if(sr < subRes) {
                  winningNumbers = bettingRecord[period][participantAddress[period][i]];
                }
                
                if(subRes == 0) {
                  winningNumbers = bettingRecord[period][participantAddress[period][i]];
                  break;
                }
            }
            
            for(uint i = 0; i < numOfPlayers; i++) {
                if(bettingRecord[period][participantAddress[period][i]] == winningNumbers) {
                    payable(participantAddress[period][i]).transfer(address(this).balance);
                    winnerAddresses[period] = participantAddress[period][i];
                    winnerNumber[period] = winningNumbers;
                }
            }
            currentNumOfPlayers = 0;
            period += 1;
        }
    }
    
    //View the total prize pool
    function getTotalMoney() public view returns(uint) {
        return address(this).balance;
    }
    
    //Current period
    function getPeriod() public view returns(uint) {
        return period;
    }
    
    //Current players
    function getCurrentPlayers() public view returns(uint) {
        return currentNumOfPlayers;
    }
    
    //Past winning addresses & number
    function getWinnerAddresses() public view returns(address[] memory winnerAddress, uint[] memory winnerNum) {
        if(period == 0) {
           return (winnerAddress, winnerNum);
        } else {
           winnerAddress = new address[](period);
           winnerNum = new uint[](period);
           for(uint i = 0; i < period; i++) {
               winnerAddress[i] = winnerAddresses[i];
               winnerNum[i] = winnerNumber[i];
           }
           return (winnerAddress, winnerNum);
        }
    }
    
    //Current bet number
    function getCurrentNumbers() public view returns(uint[] memory) {
        return currentNumbers[period];
    }
}
