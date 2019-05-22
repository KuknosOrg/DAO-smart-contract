pragma solidity >=0.4.21 <0.6.0;

import "./Ownable.sol";
import "./AccessToken.sol";

contract Voting is Ownable, AccessToken {

  struct Proposal {
      uint id;
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
      address contractAddress;
  }

  Proposal[] proposals;

  mapping (uint => mapping(address => int8)) public votesReceived;

  address[] public voters;

  constructor(address[] memory _voters, uint _voterTokensCount) AccessToken(_voterTokensCount) public {
    voters = _voters;
    renewToken(voters);
  }

  function renewYearTokens() public onlyVoters  {
    renewToken(voters);
  }

  modifier onlyVoters() {
    require(inVoters(msg.sender),"only valid voters can do this transaction");
    _;
  }

  function voteForProposal(uint _proposalIndex, int8 _vote) public onlyVoters {
      Proposal memory proposal = proposals[_proposalIndex];
      require(proposal.author != address(0), "proposal not found");
      require(proposal.startDate < getTime(), "voting is not started");
      require(proposal.endDate > getTime(), "voting was finished");
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

  function getProposal(uint index) public view returns (
      uint, string memory, uint, uint, uint, address, string memory, bytes32, uint, uint, uint, address, bool, bool, uint, uint ) {
      Proposal memory proposal = proposals[index];
      uint total = proposal.up + proposal.down;
      return (
            proposal.id,
            proposal.title,
            proposal.ProposalType,
            proposal.startDate,
            proposal.endDate,
            proposal.author,
            proposal.url,
            proposal.hashCode,
            proposal.registerDate,
            proposal.up,
            proposal.down,
            proposal.contractAddress,
            getTime() < proposal.startDate, // isNotStarted
            getTime() >= proposal.endDate, // isExpired
            proposal.up * 100 / total, // up percentage
            proposal.down * 100 / total // down percentage
        );
  }


   function votersList() public view returns (address[] memory) {
      return voters;
  }

  function registerProposal(
      uint id,
      string memory title,
      uint ProposalType,
      uint startDate,
      uint endDate,
      string memory url,
      bytes32 hashCode,
      address contractAddress
      ) public onlyVoters useToken(1) {
          proposals.push(Proposal(id, title, ProposalType, startDate, endDate, msg.sender, url,hashCode, getTime(), 0, 0, contractAddress));
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