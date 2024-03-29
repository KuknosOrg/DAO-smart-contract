pragma solidity >=0.4.21 <0.6.0;

contract AccessToken {

  uint constant YEAR_SECONDS = 365 * 24 * 60 * 60;

  uint public lastTokenIssueDate;

  uint public accessTokensCount = 50;

  mapping(address => uint) public balanceOf;

  constructor(uint _accessTokensCount) public{
    lastTokenIssueDate = getTime();
    accessTokensCount = _accessTokensCount;
  }

  modifier useToken(uint count) {
      require(balanceOf[msg.sender] >= count, "you have not enough token");
      _;
      balanceOf[msg.sender] -= count;
  }

  function renewToken(address[] memory voters, bool force) internal {
      if(lastTokenIssueDate > 0 && !force) {
          uint endDate = lastTokenIssueDate + YEAR_SECONDS;
          require(endDate < getTime(), "you must renew tokens after one year");
      }
      issueAccessToken(voters, accessTokensCount);
      lastTokenIssueDate = getTime();
  }

  function issueAccessToken(address[] memory _members, uint count) internal {
      for(uint i = 0; i < _members.length; i++) {
         setAccessToken(_members[i], count);
      }
  }

  function setAccessToken(address _member, uint count) internal {
      balanceOf[_member] = count;
  }

  function setAccessTokensCount(uint count) internal {
    accessTokensCount = count;
  }

  function getTime() internal view returns (uint) {
        return block.timestamp;
  }

}