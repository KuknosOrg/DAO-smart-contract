pragma solidity >=0.4.21 <0.6.0;

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
      int test = findMember(member);
      require(test >= 0, "member not exist");
      require(members.length >= 0, "members is emplty");
      uint index = uint(test);
      if(index != members.length - 1){
          members[index] = members[members.length - 1];
      }
      delete members[members.length - 1];
      members.length--;
  }

  function membersCount() public view returns (uint) {
      return members.length;
  }

   function membersList() public view returns (address[] memory) {
      return members;
  }

  function inMembers(address member) private view returns (bool) {
      if(findMember(member) >= 0){
          return true;
      } else {
          return false;
      }
  }

  function findMember(address member) private view returns (int) {
      if(member == address(0)){
          return -1;
      }
      for(uint i = 0; i < members.length; i++) {
          if (members[i] == member) {
             return int(i);
          }
      }
      return -1;
  }
}