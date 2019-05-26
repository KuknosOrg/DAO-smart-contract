pragma solidity >=0.4.21 <0.6.0;

contract AccessToken {

  uint constant YEAR_SECONDS = 365 * 24 * 60 * 60;

  uint public lastTokenIssueDate;

  uint public accessTokensCount;

  mapping(address => uint) public balanceOf;

  constructor(uint _accessTokensCount) public {
    accessTokensCount = _accessTokensCount;
  }

  modifier useToken(uint count) {
      require(balanceOf[msg.sender] >= count, "you have not enough token");
      _;
      balanceOf[msg.sender] -= count;
  }

  function renewToken(address[] memory voters) internal {
      if(lastTokenIssueDate > 0) {
          uint endDate = lastTokenIssueDate + YEAR_SECONDS;
          require(endDate < getTime(), "you must renew tokens after one year");
      }
      issueAccessToken(voters, accessTokensCount);
      lastTokenIssueDate = getTime();
  }

  function issueAccessToken(address[] memory _voters, uint count) private {
      for(uint i = 0; i < _voters.length; i++) {
         balanceOf[_voters[i]] = count;
      }
  }

  function getTime() internal view returns (uint) {
        return block.timestamp;
  }

}