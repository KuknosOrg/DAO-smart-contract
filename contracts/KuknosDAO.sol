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

    mapping ( uint => AddAnchorProposal ) public addAnchorProposals;

    mapping ( uint => RemoveAnchorProposal ) public removeAnchorProposal;

    uint public internalProposalsCount = 0;

    constructor(address[] memory _voters, uint _voterTokensCount) public Voting(_voters, _voterTokensCount) {

    }

    function registerAddAnchorProposal(
      string memory _anchorName,
      string memory _anchorUrl,
      address[] memory _members,
      uint _startDate,
      uint _endDate,
      string memory _url,
      bytes32 _hashCode
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
        uint upPercentage = checkProposalUpPercentage(_id);
        if( upPercentage >= addAnchorThreshold ) {
            addAnchor(proposal.name, proposal.url, proposal.members);
        }
        addAnchorProposals[_id].executionTime = getTime();
    }

    function checkProposalUpPercentage(uint _id) internal view returns(uint) {
        (,,, address contractAddress,, bool isFinished, uint upPercentage,) = getProposalStatus(_id);
        require(contractAddress == address(this), "the propsal is not an internal proposal");
        require(isFinished,"the propsal is not finished");
        return upPercentage;
    }

    function registerRemoveAnchorProposal(
      string memory _anchorName,
      uint _startDate,
      uint _endDate,
      string memory _url,
      bytes32 _hashCode
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
        uint upPercentage = checkProposalUpPercentage(_id);
        if( upPercentage >= removeAnchorThreshold ) {
            deleteAnchor(proposal.name);
        }
        removeAnchorProposal[_id].executionTime = getTime();
    }


}