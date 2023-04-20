// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.18;

library AddressUtils {
    /**
     * Convert variables of bytes to address
     * @param bytesValue Bytes that need to be converted to address
     */
    function fromBytes(bytes memory bytesValue) internal pure returns (address addr) {
        assembly {
            addr := mload(add(bytesValue, 20))
        }
    }

    /**
     * Convert variables of address to bytes
     * @param self Address that need to be converted to bytes
     */
    function toBytes(address self) internal pure returns (bytes memory b) {
        b = abi.encodePacked(self);
    }

    /**
     * Convert variables of bytes32 to address
     * @param bytes32Value Bytes32 that need to be converted to address
     */
    function fromBytes32(bytes32 bytes32Value) internal pure returns (address) {
        return address(uint160(uint256(bytes32Value)));
    }

    /**
     * Convert variables of address to bytes32
     * @param addressValue Bytes that need to be converted to address
     */
    function toBytes32(address addressValue) internal pure returns (bytes32) {
        return bytes32(bytes20(addressValue));
    }
}
