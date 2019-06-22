pragma solidity >=0.4.21 <0.6.0;

import "./Ownable.sol";
import "./AccessToken.sol";
import "./Anchors.sol";

contract Voting is Ownable, AccessToken, Anchors {

  struct Proposal {
    string title;
    uint32 proposalType;
    uint32 startDate;
    uint32 endDate;
    address author;
    string url;
    string hashCode;
    uint32 registerDate;
    uint16 up;
    uint16 down;
    address contractAddress;
    uint8 threshold;
    uint id;
  }

  Proposal[] public proposals;

  mapping (uint => mapping(address => int8)) public votesReceived;

  constructor(uint _voterTokensCount) AccessToken(_voterTokensCount) public {
  }

  modifier onlyMembers() {
    require(contractHasNoOwener(), "this contract is in config mode");
    require(inMembers(msg.sender), "only valid members can do this transaction");
    _;
  }

  function renewYearTokens() public onlyMembers  {
    renewToken(members, false);
  }

  function voteForProposal(uint _proposalIndex, int8 _vote) public onlyMembers {
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

  function getProposal(uint index) public view returns ( 
    string memory,
    uint32,
    uint32,
    uint32,
    address,
    string memory,
    string memory,
    uint32,
    address,
    uint8,
    uint
    ) {
    Proposal memory proposal = proposals[index];
    return (
      proposal.title,
      proposal.proposalType,
      proposal.startDate,
      proposal.endDate,
      proposal.author,
      proposal.url,
      proposal.hashCode,
      proposal.registerDate,
      proposal.contractAddress,
      proposal.threshold,
      proposal.id
    );
  }

  function getProposalsCount() public view returns (uint) {
    return proposals.length;
  }

  function getProposalStatus(uint index) public view returns ( uint, uint, uint, address, bool, bool,uint,uint, bool ) {
    Proposal memory proposal = proposals[index];
    uint total = proposal.up + proposal.down;
    return (
      proposal.up,
      proposal.down,
      proposal.proposalType,
      proposal.contractAddress,
      getTime() < proposal.startDate, // isNotStarted
      getTime() >= proposal.endDate, // isExpired
      proposal.up * 100 / total,
      proposal.up * 100 / total,
      (proposal.up * 100 / total) >= proposal.threshold
    );
  }

  function registerProposal(
    string memory title,
    uint32 proposalType,
    uint32 startDate,
    uint32 endDate,
    string memory url,
    string memory hashCode,
    address contractAddress,
    uint8 threshold
    ) public onlyMembers useToken(1) {
        require(contractAddress != address(this), "using internal contract for external proposal is invalid");
        proposals.push(
          Proposal(title, proposalType, startDate, endDate, msg.sender, url,hashCode, uint32(getTime()), 0, 0, contractAddress, threshold,0)
        );
  }

  function registerInternalProposal(
    string memory title,
    uint32 proposalType,
    uint32 startDate,
    uint32 endDate,
    string memory url,
    string memory hashCode,
    uint8 threshold
    ) internal onlyMembers useToken(1) returns (uint) {
        return proposals.push(
          Proposal(title, proposalType, startDate, endDate, msg.sender, url,hashCode, uint32(getTime()), 0, 0, address(this), threshold,0)
        );
  }
}