pragma solidity >=0.4.21 <0.6.0;

import "./Voting.sol";
import "./Config.sol";

contract KuknosDAO is Voting, Config {

    enum ProposalTypes { AddAnchor, RemoveAnchor, ChangeAnchorMember, RenewAccessToken, ChangeConfig }

    struct AddAnchorProposal {
        string name;
        string url;
        address[] members;
        uint executionTime;
    }

    struct RemoveAnchorProposal {
        string name;
        uint executionTime;
    }

    struct RenewAccessTockenProposal {
        string name;
        uint count;
        uint executionTime;
    }

    mapping ( uint => AddAnchorProposal ) public addAnchorProposals;

    mapping ( uint => RemoveAnchorProposal ) public removeAnchorProposal;

    mapping ( uint => RenewAccessTockenProposal ) public renewAccessTockenProposal;

    uint public internalProposalsCount = 0;

    constructor(uint _voterTokensCount) public Voting(_voterTokensCount) {
    }

    function addNewAnchor(string memory _name, string memory _url, address[] memory _members) public onlyOwner {
        addAnchorWithToken(_name, _url, _members);
    }

    function addAnchorWithToken(string memory _name, string memory _url, address[] memory _members) internal {
        addAnchor(_name, _url, _members);
        issueAccessToken(_members, accessTokensCount);
    }

    function contractIsActive() public view returns(bool) {
        return contractHasNoOwener();
    }


    function checkProposalUpPercentage(uint _id, ProposalTypes pType) internal view returns(uint) {
        (,,,uint proposalType, address contractAddress,, bool isFinished, uint upPercentage,) = getProposalStatus(_id);
        require(proposalType == uint(pType), "type mismatch");
        require(contractAddress == address(this), "the propsal is not an internal proposal");
        require(isFinished,"the propsal is not finished");
        return upPercentage;
    }

    // Add new Anchor Proposal
    function registerAddAnchorProposal(
      string memory _anchorName,
      string memory _anchorUrl,
      address[] memory _members,
      uint _startDate,
      uint _endDate,
      string memory _url,
      string memory _hashCode
      ) public onlyMembers {
          require(bytes(_anchorName).length > 0, "select name for anchor");
          internalProposalsCount++;
          uint id = registerInternalProposal(
              internalProposalsCount,
              "add anchor",
              uint(ProposalTypes.AddAnchor),
              _startDate,
              _endDate,
              _url,
              _hashCode);
          addAnchorProposals[id] = AddAnchorProposal(_anchorName, _anchorUrl, _members, 0);
    }

    function runAddAnchorProposal(uint _id) internal onlyMembers {
        AddAnchorProposal memory proposal = addAnchorProposals[_id];
        require(bytes(proposal.name).length > 0, "propsal not found");
        require(proposal.executionTime == 0, "the proposal executed before");
        uint upPercentage = checkProposalUpPercentage(_id, ProposalTypes.AddAnchor);
        if (upPercentage >= addAnchorThreshold) {
            addAnchorWithToken(proposal.name, proposal.url, proposal.members);
        }
        addAnchorProposals[_id].executionTime = getTime();
    }

    // Remove an anchor proposal
    function registerRemoveAnchorProposal(
      string memory _anchorName,
      uint _startDate,
      uint _endDate,
      string memory _url,
      string memory _hashCode
      ) public onlyMembers {
          require(bytes(_anchorName).length > 0, "select name for anchor");
          internalProposalsCount++;
          uint id = registerInternalProposal(
              internalProposalsCount,
              "remove anchor",
              uint(ProposalTypes.RemoveAnchor),
              _startDate,
              _endDate,
              _url,
              _hashCode);
          removeAnchorProposal[id] = RemoveAnchorProposal(_anchorName, 0);
    }

    function runRemoveAnchorProposal(uint _id) internal onlyMembers {
        RemoveAnchorProposal memory proposal = removeAnchorProposal[_id];
        require(bytes(proposal.name).length > 0, "propsal not found");
        require(proposal.executionTime == 0, "the proposal executed before");
        uint upPercentage = checkProposalUpPercentage(_id, ProposalTypes.RemoveAnchor);
        if (upPercentage >= removeAnchorThreshold) {
            deleteAnchor(proposal.name);
        }
        removeAnchorProposal[_id].executionTime = getTime();
    }

    // set AccessToken proposal
    function registerSetAccessTokenProposal(
      uint count,
      uint _startDate,
      uint _endDate,
      string memory _url,
      string memory _hashCode
      ) public onlyMembers {
          internalProposalsCount++;
          uint id = registerInternalProposal(
              internalProposalsCount,
              "set access tocken",
              uint(ProposalTypes.RenewAccessToken),
              _startDate,
              _endDate,
              _url,
              _hashCode);
          renewAccessTockenProposal[id] = RenewAccessTockenProposal("set access tocken", count, 0);
    }

    function runSetAccessTockenProposal(uint _id) internal onlyMembers {
        RenewAccessTockenProposal memory proposal = renewAccessTockenProposal[_id];
        require(bytes(proposal.name).length > 0, "propsal not found");
        require(proposal.executionTime == 0, "the proposal executed before");
        uint upPercentage = checkProposalUpPercentage(_id, ProposalTypes.RenewAccessToken);
        if (upPercentage >= renewAccessTokenThreshold) {
            renewToken(members, true);
        }
        renewAccessTockenProposal[_id].executionTime = getTime();
    }


}