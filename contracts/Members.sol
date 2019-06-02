pragma solidity >=0.4.21 <0.6.0;

import "./library/Utils.sol";

contract Members {

  address[] public members;

  constructor(address[] memory _members) public {
    members = _members;
  }

  modifier onlyMembers() {
    require(inMembers(msg.sender),"only valid members can do this transaction");
    _;
  }

  function addMember(address member) internal {
      require(!inMembers(msg.sender),"dubpicate member");
      members.push(member);
  }

  function deleteMember(address member) internal {
      Utils.removeAddressFromArray(members, member);
  }

  function membersCount() public view returns (uint) {
      return members.length;
  }

   function membersList() public view returns (address[] memory) {
      return members;
  }

  function inMembers(address member) private view returns (bool) {
      return Utils.findIndex(members, member) >= 0;
  }

}