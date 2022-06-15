// SPDX-License-Identifier: MIT
//["abc", "qwerty", "ggg"]
//["0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2", "0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db", "0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB"]
pragma solidity ^0.8.9;

contract Ballot 
{  
     struct Voter {
        mapping(uint => bool) voted;
        mapping(uint => uint) vote;
    }

    struct Candidate {
        string name;   
        address candidateAddress;
        uint number;
        uint votingNumber;
        uint voteCount;
    }

    struct Voting {
        uint numberOfVating;
        uint candidatesAmount;
        uint votersAmount;
    }
    
    address public owner;
    mapping(address => Voter) voters;
    mapping(uint => mapping(uint => Candidate)) public candidates;
    mapping(uint => Voting) public votings;
    mapping(string => Candidate) nameToCandidate;

    uint startTime;
    mapping(uint => uint) endTime;
    uint voteCost = 100;
    uint timeOfVoting = 60;//259200;
    uint votingAmount;

    uint start;

    constructor(address _owner) {
        owner = _owner;
        start = block.timestamp;
    }

    function getStart() external view returns(uint time) {
        return(start);
    }

    modifier onlySmartContractOwner() {
        require(msg.sender == owner, "Only owner can start and end the voting");
        _;
    }

    modifier votingIsOpen(uint _votingNumber) {
        require(block.timestamp <= endTime[_votingNumber], "Voting is closed");
        _;
    }

    modifier votingIsClosed(uint _votingNumber) {
        require(block.timestamp >= endTime[_votingNumber], "Voting is open");
        _;
    }

    function createVoting(string[] memory candidateNames, address[] memory candidateAddresses) public onlySmartContractOwner {
        votingAmount++;
        votings[votingAmount].candidatesAmount =candidateNames.length;
        votings[votingAmount].numberOfVating = votingAmount;
        for (uint i = 0; i < votings[votingAmount].candidatesAmount; i++) {
            Candidate memory candidate = Candidate({
            name: candidateNames[i],
            candidateAddress: candidateAddresses[i],
            number: i+1,
            votingNumber: votingAmount,
            voteCount: 0
        });
            candidates[votingAmount][i+1] = candidate;
            nameToCandidate[candidateNames[i]] = candidate;
        }
         startTime = block.timestamp;
         endTime[votingAmount] = startTime + timeOfVoting;
    }

    function vote(uint votingNumber, uint candidateNumber) public payable votingIsOpen(votingNumber) {
        Voter storage sender = voters[msg.sender];
        require(candidateNumber >= 1 && candidateNumber <= votings[votingNumber].candidatesAmount, "Invalid candidate number");
        require(!sender.voted[votingNumber], "Already voted.");
        require(msg.value == voteCost, "Invalid Amount");     
        sender.voted[votingNumber] = true;
        sender.vote[votingNumber] = candidateNumber;
        candidates[votingNumber][candidateNumber].voteCount++;
        nameToCandidate[candidates[votingNumber][candidateNumber].name].voteCount++;
        votings[votingNumber].votersAmount++;
    }

    function closeVoting(uint votingNumber) public payable votingIsClosed(votingNumber) {
        uint winningCandidate = candidates[votingNumber][1].voteCount;
        uint winnerNumber = candidates[votingNumber][1].number;
        for (uint i = 2; i <= votings[votingNumber].candidatesAmount; i++) {
            if (winningCandidate < candidates[votingNumber][i].voteCount) {
                winningCandidate = candidates[votingNumber][i].voteCount;
                winnerNumber = candidates[votingNumber][i].number;
            }
        }

        address payable winner = payable(candidates[votingNumber][winnerNumber].candidateAddress);
        uint reward = votings[votingNumber].votersAmount * voteCost;
        winner.transfer(reward * 9/10);
    }

    function withdrawBalance(address payable receiver) onlySmartContractOwner public payable {
        receiver.transfer(address(this).balance);
    }

    function votingDates(string memory candidateName) public view returns(uint _votingNumber, uint _candidateNumber, uint _votesAmount) {
        return(nameToCandidate[candidateName].votingNumber, nameToCandidate[candidateName].number, nameToCandidate[candidateName].voteCount);
    }

    function balance() public view returns(uint _balance) {
        return(address(this).balance);
    }
} 