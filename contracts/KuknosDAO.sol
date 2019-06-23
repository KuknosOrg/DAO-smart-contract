pragma solidity >=0.4.21 <0.6.0;

import "./Voting.sol";
import "./Config.sol";

contract KuknosDAO is Voting, Config {

    enum ProposalTypes { AddAnchor, UpdateAnchor, RemoveAnchor, ChangeAnchorMember, RenewAccessToken, ChangeConfig }

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

    struct ChangeConfigProposal {
        string name;
        uint8 value;
        uint executionTime;
    }

    mapping ( uint => AddAnchorProposal ) public addOrUpdateAnchorProposals;

    mapping ( uint => RemoveAnchorProposal ) public removeAnchorProposal;

    mapping ( uint => RenewAccessTockenProposal ) public renewAccessTockenProposal;

    mapping ( uint => ChangeConfigProposal ) public changeConfigProposal;

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

    function updateAnchorWithToken(string memory _name, string memory _url, address[] memory _members) internal {
        deleteAnchor(_name);
        addAnchorWithToken(_name, _url, _members);
    }



    function checkProposalResult(uint _id, ProposalTypes pType) internal view returns(bool) {
        (,,,uint32 proposalType, address contractAddress,, bool isFinished,,,bool successful) = getProposalStatus(_id);
        require(proposalType == uint(pType), "type mismatch");
        require(contractAddress == address(this), "the propsal is not an internal proposal");
        require(isFinished,"the propsal is not finished");
        return successful;
    }

    // Add new Anchor Proposal
    function registerAddOrUpdateAnchorProposal(
      string memory _anchorName,
      string memory _anchorUrl,
      address[] memory _members,
      uint32 _startDate,
      uint32 _endDate,
      string memory _url,
      string memory _hashCode,
      ProposalTypes _type
      ) public onlyMembers {
          require(_type == ProposalTypes.AddAnchor || _type == ProposalTypes.UpdateAnchor, "choose valide type");
          require(bytes(_anchorName).length > 0, "select name for anchor");
          internalProposalsCount++;
          uint id = registerInternalProposal(
              internalProposalsCount,
              "add anchor",
              uint32(_type),
              _startDate,
              _endDate,
              _url,
              _hashCode,
              addAnchorThreshold);
          addOrUpdateAnchorProposals[id] = AddAnchorProposal(_anchorName, _anchorUrl, _members, 0);
    }

    function runAddOrUpdateAnchorProposal(uint _id, ProposalTypes _type) public onlyMembers {
        require(_type == ProposalTypes.AddAnchor || _type == ProposalTypes.UpdateAnchor, "choose valide type");
        AddAnchorProposal memory proposal = addOrUpdateAnchorProposals[_id];
        require(bytes(proposal.name).length > 0, "propsal not found");
        require(proposal.executionTime == 0, "the proposal executed before");
        if (checkProposalResult(_id, ProposalTypes(_type))) {
            if(_type == ProposalTypes.AddAnchor){
                addAnchorWithToken(proposal.name, proposal.url, proposal.members);
            }else{
                updateAnchorWithToken(proposal.name, proposal.url, proposal.members);
            }
        }
        addOrUpdateAnchorProposals[_id].executionTime = getTime();
    }

    // Remove an anchor proposal
    function registerRemoveAnchorProposal(
      string memory _anchorName,
      uint32 _startDate,
      uint32 _endDate,
      string memory _url,
      string memory _hashCode
      ) public onlyMembers {
          require(bytes(_anchorName).length > 0, "select name for anchor");
          internalProposalsCount++;
          uint id = registerInternalProposal(
              internalProposalsCount,
              "remove anchor",
              uint32(ProposalTypes.RemoveAnchor),
              _startDate,
              _endDate,
              _url,
              _hashCode,
              removeAnchorThreshold);
          removeAnchorProposal[id] = RemoveAnchorProposal(_anchorName, 0);
    }

    function runRemoveAnchorProposal(uint _id) public onlyMembers {
        RemoveAnchorProposal memory proposal = removeAnchorProposal[_id];
        require(bytes(proposal.name).length > 0, "propsal not found");
        require(proposal.executionTime == 0, "the proposal executed before");
        if (checkProposalResult(_id, ProposalTypes.RemoveAnchor)) {
            deleteAnchor(proposal.name);
        }
        removeAnchorProposal[_id].executionTime = getTime();
    }

    // set AccessToken proposal
    function registerSetAccessTokenProposal(
      uint count,
      uint32 _startDate,
      uint32 _endDate,
      string memory _url,
      string memory _hashCode
      ) public onlyMembers {
          internalProposalsCount++;
          uint id = registerInternalProposal(
              internalProposalsCount,
              "set access tocken",
              uint32(ProposalTypes.RenewAccessToken),
              _startDate,
              _endDate,
              _url,
              _hashCode,
              renewAccessTokenThreshold);
          renewAccessTockenProposal[id] = RenewAccessTockenProposal("set access tocken", count, 0);
    }

    function runSetAccessTockenProposal(uint _id) public onlyMembers {
        RenewAccessTockenProposal memory proposal = renewAccessTockenProposal[_id];
        require(bytes(proposal.name).length > 0, "propsal not found");
        require(proposal.executionTime == 0, "the proposal executed before");
        if (checkProposalResult(_id, ProposalTypes.RenewAccessToken)) {
            renewToken(members, true);
        }
        renewAccessTockenProposal[_id].executionTime = getTime();
    }

    // set AccessToken proposal
    function addChangeConfigProposal(
      uint8 newValue,
      uint32 _startDate,
      uint32 _endDate,
      string memory _url,
      string memory _hashCode
      ) public onlyMembers {
          internalProposalsCount++;
          uint id = registerInternalProposal(
              internalProposalsCount,
              "change config",
              uint32(ProposalTypes.ChangeConfig),
              _startDate,
              _endDate,
              _url,
              _hashCode,
              changeConfigThreshold);
          changeConfigProposal[id] = ChangeConfigProposal("change config", newValue, 0);
    }

    function runChangeConfigProposal(uint _id) public onlyMembers {
        ChangeConfigProposal memory proposal = changeConfigProposal[_id];
        require(bytes(proposal.name).length > 0, "propsal not found");
        require(proposal.executionTime == 0, "the proposal executed before");
        if (checkProposalResult(_id, ProposalTypes.ChangeConfig)) {
            renewToken(members, true);
        }
        renewAccessTockenProposal[_id].executionTime = getTime();
    }


}