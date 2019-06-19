pragma solidity >=0.4.21 <0.6.0;

contract Config {

    enum ChangeConfigType {
        AddAnchorThreshold,
        RemoveAnchorThreshold,
        RenewAccessTokenThreshold,
        ChangeAnchorMemberThreshold,
        ChangeConfigThreshold
    }

    uint public addAnchorThreshold = 51;

    uint public removeAnchorThreshold = 80;

    uint public renewAccessTokenThreshold = 51;

    uint public changeAnchorMemberThreshold = 51;

    uint public changeConfigThreshold = 80;

    function setConfig(ChangeConfigType configType, uint value) internal {
        
        if(configType == ChangeConfigType.AddAnchorThreshold) {
             addAnchorThreshold = value;
        }
    
        if(configType == ChangeConfigType.RemoveAnchorThreshold) {
            removeAnchorThreshold = value;
        }

        if(configType == ChangeConfigType.RenewAccessTokenThreshold) {
             renewAccessTokenThreshold = value;
        }

        if(configType == ChangeConfigType.ChangeAnchorMemberThreshold) {
            changeAnchorMemberThreshold = value;
        }

        if(configType == ChangeConfigType.ChangeConfigThreshold) {
            changeConfigThreshold = value;
        }
    }

}