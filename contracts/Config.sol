pragma solidity >=0.4.21 <0.6.0;

contract Config {

    uint public addAnchorThreshold = 51;

    uint public removeAnchorThreshold = 80;

    uint public renewAccessTokenThreshold = 51;

    uint public changeAnchorMemberThreshold = 51;

    uint public changeConfig = 80;

    function setAddAnchorThreshold(uint value) internal {
        addAnchorThreshold = value;
    }

    function setRemoveAnchorThreshold(uint value) internal {
        removeAnchorThreshold = value;
    }

    function setRenewAccessTokenThreshold(uint value) internal {
        renewAccessTokenThreshold = value;
    }

    function setcChangeAnchorMemberThreshold(uint value) internal {
        changeAnchorMemberThreshold = value;
    }

    function setChangeConfig(uint value) internal {
        changeConfig = value;
    }
}