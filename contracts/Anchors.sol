pragma solidity >=0.4.21 <0.6.0;

import "./library/Utils.sol";
import "./Members.sol";
import "./AccessToken.sol";

contract Anchors is Members {

    struct Anchor {
        bytes32 nameHash;
        string name;
        string url;
    }

    // each anchor maximum members count
    uint maxmMembersCount = 2;

    Anchor[] anchors;

    mapping( bytes32 => address[] ) anchorMembers;

    function addAnchor(string memory _name, string memory _url, address[] memory _members) internal {
        bytes32 nameHash = Utils.strToHash(_name);
        require(!inAnchors(nameHash),"dubpicate anchor");
        require(_members.length <= maxmMembersCount, "members are more than valid memebers count");
        anchors.push(Anchor(nameHash, _name, _url));
        for(uint i = 0; i < _members.length; i++){
          addMemberForAnchor(nameHash, _members[i]);
        }
    }

    function deleteAnchor(string memory name) internal {
        bytes32 nameHash = Utils.strToHash(name);
        require(anchors.length >= 0, "anchors is emplty");
        address[] memory members = anchorMembers[nameHash];
        for(uint i = 0; i < members.length; i++){
          removeAnchorMember(nameHash, members[i]);
        }

        removeAnchorFromArray(anchors, getIndex(nameHash));
    }

    function addAnchorMember(bytes32 anchor, address member) internal {
        getIndex(anchor);
        require(anchorMembers[anchor].length <= maxmMembersCount, "the anchor has maximum members");
        addMemberForAnchor(anchor, member);
    }

    function removeAnchorMember(bytes32 anchor, address member) internal {
        getIndex(anchor);
        Utils.removeAddressFromArray(anchorMembers[anchor], member);
        deleteMember(member);
    }

    function changeAnchorMember(bytes32 anchor, address oldMember, address newMember) internal {
        removeAnchorMember(anchor, oldMember);
        addAnchorMember(anchor, newMember);
    }

    function addMemberForAnchor(bytes32 anchor, address member) private {
        anchorMembers[anchor].push(member);
        addMember(member);
    }

    function inAnchors(bytes32 name) private view returns (bool) {
        return findAnchor(name) >= 0;
    }

    function findAnchor(bytes32 nameHash) private view returns (int) {
        if(nameHash == Utils.strToHash("")){
            return -1;
        }
        for(uint i = 0; i < anchors.length; i++) {
            if (anchors[i].nameHash == nameHash) {
               return int(i);
            }
        }
        return -1;
    }

    function removeAnchorFromArray(Anchor[] storage list, uint index ) private {
        require(list.length > 0, "address array is empty");
        if(index != list.length - 1){
            list[index] = list[list.length - 1];
        }
        delete list[list.length - 1];
        list.length--;
    }

    function getIndex(bytes32 anchor) private view returns(uint) {
        int test = findAnchor(anchor);
        require(test >= 0, "anchor not exist");
        return uint(test);
    }

}