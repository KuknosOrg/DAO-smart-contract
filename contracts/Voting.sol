pragma solidity >=0.4.21 <0.6.0;

import "./Ownable.sol";
import "./AccessToken.sol";
import "./Anchors.sol";

contract Voting is Ownable, AccessToken, Anchors {

  struct Proposal {
    uint id;
    string title;
    uint proposalType;
    uint startDate;
    uint endDate;
    address author;
    string url;
    string hashCode;
    uint registerDate;
    uint up;
    uint down;
    address contractAddress;
  }

  Proposal[] public proposals;

  mapping (uint => mapping(address => int8)) public votesReceived;

  constructor(uint _voterTokensCount) AccessToken(_voterTokensCount) public {
  }

  modifier onlyMembers() {
    require(contractHasNoOwener(), "this contract is in config mode");
    require(inMembers(msg.sender),"only valid members can do this transaction");
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
  function getProposalsCount() public view returns (uint) {
    return proposals.length;
  }

  function getProposalStatus(uint index) public view returns ( uint, uint, uint, uint, address, bool, bool, uint, uint ) {
    Proposal memory proposal = proposals[index];
    uint total = proposal.up + proposal.down;
    return (
      proposal.id,
      proposal.up,
      proposal.down,
      proposal.proposalType,
      proposal.contractAddress,
      getTime() < proposal.startDate, // isNotStarted
      getTime() >= proposal.endDate, // isExpired
      proposal.up * 100 / total, // up percentage
      proposal.down * 100 / total // down percentage
    );
  }

  function registerProposal(
    uint id,
    string memory title,
    uint proposalType,
    uint startDate,
    uint endDate,
    string memory url,
    string memory hashCode,
    address contractAddress
    ) public onlyMembers useToken(1) {
        require(contractAddress != address(this), "using internal contract for external proposal is invalid");
        proposals.push(Proposal(id, title, proposalType, startDate, endDate, msg.sender, url,hashCode, getTime(), 0, 0, contractAddress));
  }

  function registerInternalProposal(
    uint id,
    string memory title,
    uint proposalType,
    uint startDate,
    uint endDate,
    string memory url,
    string memory hashCode
    ) internal onlyMembers useToken(1) returns (uint) {
        return proposals.push(Proposal(id, title, proposalType, startDate, endDate, msg.sender, url,hashCode, getTime(), 0, 0, address(this)));
  }
}