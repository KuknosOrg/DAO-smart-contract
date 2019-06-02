pragma solidity >=0.4.21 <0.6.0;

library Utils{

    function strToHash(string memory str) internal pure returns (bytes32) {
        return keccak256(abi.encode(str));
    }

    function findIndex(address[] memory list, address adr ) internal pure returns (int) {
        if(adr == address(0)){
            return -1;
        }
        for(uint i = 0; i < list.length; i++) {
            if (list[i] == adr) {
               return int(i);
            }
        }
        return -1;
    }

    function removeArrayIndex(address[] storage list, uint index ) internal{
        require(list.length > 0, "address array is empty");
        if(index != list.length - 1){
            list[index] = list[list.length - 1];
        }
        delete list[list.length - 1];
        list.length--;
    }

    function removeAddressFromArray(address[] storage list, address adr) internal {
        int test = findIndex(list,adr);
        require(test >= 0, "address not found");
        removeArrayIndex(list,uint(test));
    }
}