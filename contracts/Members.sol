pragma solidity >=0.4.21 <0.6.0;

import "./library/Utils.sol";

contract Members {

  address[] public members;

  function addMember(address member) internal {
      require(!inMembers(member),"dubpicate member");
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

  function inMembers(address member) internal view returns (bool) {
      return Utils.findIndex(members, member) >= 0;
  }

}