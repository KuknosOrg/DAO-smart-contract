pragma solidity >=0.4.21 <0.6.0;

import "./Ownable.sol";
import "./AccessToken.sol";
import "./Anchors.sol";

contract Voting is Ownable, AccessToken, Anchors {

  struct Proposal {
    uint id;
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
    uint8 membersCount;
  }

  struct Vote {
    int8 vote;
    string description;
  }

  Proposal[] proposals;

  mapping (uint => mapping(address => Vote)) public votesReceived;

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

  function voteForProposal(uint _proposalIndex, int8 _vote, string memory _description) public onlyMembers {
    Proposal memory proposal = proposals[_proposalIndex];
    require(proposal.author != address(0), "proposal not found");
    require(proposal.startDate < getTime(), "voting is not started");
    require(proposal.endDate > getTime(), "voting was finished");
    require(votesReceived[_proposalIndex][msg.sender].vote == 0, "your vote registered later");
    require(_vote != 0, "you must set up or down with 1 or -1 value");
    if(_vote > 0) {
      votesReceived[_proposalIndex][msg.sender] = Vote(1,_description);
      proposals[_proposalIndex].up += 1;
    } else {
      votesReceived[_proposalIndex][msg.sender] = Vote(-1,_description);
      proposals[_proposalIndex].down += 1;
    }
  }

  function getProposal(uint index) public view returns (
    string memory title,
    uint32 proposalType,
    uint32 registerDate,
    uint32 startDate,
    uint32 endDate,
    address author,
    string memory url,
    string memory hashCode,
    address contractAddress,
    uint8 threshold
    ) {
    Proposal memory proposal = proposals[index];
    return (
        proposal.title,
        proposal.proposalType,
        proposal.registerDate,
        proposal.startDate,
        proposal.endDate,
        proposal.author,
        proposal.url,
        proposal.hashCode,
        proposal.contractAddress,
        proposal.threshold
    );
  }

  function getProposalsCount() public view returns (uint) {
    return proposals.length;
  }

  function getProposalStatus(uint index) public view returns (
    uint id ,
    uint16 up,
    uint16 down,
    uint32 proposalType,
    address contractAddress,
    bool isNotStarted,
    bool isExpired,
    uint16 upPercentage,
    uint16 downPercentage,
    bool isSucceed ) {
    Proposal memory proposal = proposals[index];
    uint total = proposal.membersCount;
    return (
      proposal.id,
      proposal.up,
      proposal.down,
      proposal.proposalType,
      proposal.contractAddress,
      getTime() < proposal.startDate, // isNotStarted
      getTime() >= proposal.endDate, // isExpired
      total == 0 ? 0 : uint16(proposal.up * 100 / total),
      total == 0 ? 0 : uint16(proposal.down * 100 / total),
      total == 0 ? false :(proposal.up * 100 / total) >= proposal.threshold
    );
  }

  function registerProposal(
    uint id,
    string memory title,
    uint32 proposalType,
    uint32 startDate,
    uint32 endDate,
    string memory url,
    string memory hashCode,
    address contractAddress,
    uint8 threshold
    ) public onlyMembers useToken(1) returns (uint) {
        require(contractAddress != address(this), "using internal contract for external proposal is invalid");
        return proposals.push(
          Proposal(id, title, proposalType, startDate, endDate, msg.sender, url,hashCode, uint32(getTime()), 0, 0, contractAddress, threshold, uint8(membersCount()))
        ) - 1;
  }

  function registerInternalProposal(
    uint id,
    string memory title,
    uint32 proposalType,
    uint32 startDate,
    uint32 endDate,
    string memory url,
    string memory hashCode,
    uint8 threshold
    ) internal onlyMembers useToken(1) returns (uint) {
        return proposals.push(
          Proposal(id, title, proposalType, startDate, endDate, msg.sender, url,hashCode, uint32(getTime()), 0, 0, address(this), threshold, uint8(membersCount()))
        ) - 1;
  }
}