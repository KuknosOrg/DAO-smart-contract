pragma solidity >=0.4.21 <0.6.0;

contract Config {

    enum ChangeConfigType {
        AddAnchorThreshold,
        RemoveAnchorThreshold,
        RenewAccessTokenThreshold,
        ChangeAnchorMemberThreshold,
        ChangeConfigThreshold
    }

    uint8 public addAnchorThreshold = 51;

    uint8 public removeAnchorThreshold = 80;

    uint8 public renewAccessTokenThreshold = 51;

    uint8 public changeAnchorMemberThreshold = 51;

    uint8 public changeConfigThreshold = 80;

    function setConfig(ChangeConfigType configType, uint8 value) internal {

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