pragma solidity >=0.4.21 <0.6.0;

import "./Ownable.sol";

contract Voting is Ownable {

  struct Proposal {
      string title;
      uint ProposalType;
      uint startDate;
      uint endDate;
      address author;
      string url;
      bytes32 hashCode;
      uint registerDate;
      uint up;
      uint down;
  }

  Proposal[] proposals;

  mapping (uint => mapping(address => int8)) public votesReceived;

  address[] public voters;

  bytes32[] public candidateList;


  constructor(address[] memory _voters) public {
    voters = _voters;
  }

  modifier onlyVoters() {
    require(inVoters(msg.sender),"only valid voters can do this transaction");
    _;
  }

  function voteForProposal(uint _proposalIndex, int8 _vote) public onlyVoters {
      Proposal memory proposal = proposals[_proposalIndex];
      require(proposal.author != address(0), "proposal not found");
      require(proposal.startDate < block.timestamp , "voting is not started");
      require(proposal.endDate > block.timestamp , "voting was finished");
      require(votesReceived[_proposalIndex][msg.sender] == 0, "your vote registered later");
      require(_vote != 0, "you must set up or down with 1 or -1 value");
      if(_vote > 0) {
          votesReceived[_proposalIndex][msg.sender] = 1;
          proposals[_proposalIndex].up += 1;
      } else {
          votesReceived[_proposalIndex][msg.sender] = -1;
          proposals[_proposalIndex].down += 1;
      }
  }

  function votersCount() public view returns (uint) {
      return voters.length;
  }

  function getProposalsCount() public view returns (uint) {
      return proposals.length;
  }

  function getProposal(uint index) public view returns (string memory, uint , uint, uint, address, string memory, bytes32, uint, uint, uint ) {
      Proposal memory proposal = proposals[index];
      return (
          proposal.title,
          proposal.ProposalType,
          proposal.startDate,
          proposal.endDate,
          proposal.author,
          proposal.url,
          proposal.hashCode,
          proposal.registerDate,
          proposal.up,
          proposal.down);
  }


   function votersList() public view returns (address[] memory) {
      return voters;
  }

  function registerProposal(
      string memory title,
      uint ProposalType,
      uint startDate,
      uint endDate,
      string memory url,
      bytes32 hashCode) public onlyVoters {
         proposals.push(Proposal(title, ProposalType, startDate, endDate, msg.sender, url,hashCode, block.timestamp, 0 ,0));
  }

  function inVoters(address caller) private view returns (bool) {
      if(caller == address(0)){
          return false;
      }
      for(uint i = 0; i < voters.length; i++) {
          if (voters[i] == caller) {
             return true;
          }
      }
    return false;
  }
}