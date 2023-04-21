// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.18;

import "../../src/interface/IMOSV3.sol";
import "../../src/utils/AddressUtils.sol";
import "@openzeppelin/utils/Address.sol";

contract MOS is IMOSV3 {
    using Address for address;
    event TransferOut(uint256 _toChain, address _target,bytes callData, address _feeToken);

    function getMessageFee(uint256 _toChain, address _feeToken, uint256 _gasLimit)
        external
        view
        override
        returns (uint256, address)
    {
        if (_toChain != 0 && _feeToken != address(0) && _gasLimit >= 0) {}
        return (0, address(this));
    }

    function transferOut(uint256 _toChain, bytes memory _messageData, address _feeToken)
        external
        payable
        override
        returns (bool)
    {
        MessageData memory data = abi.decode(_messageData,(MessageData));
        bytes memory callData = data.payload;
        address target = AddressUtils.fromBytes(data.target);
        emit TransferOut(_toChain, target,callData, _feeToken);
        target.functionCall(
            callData
        );
        return true;
    }

    function addRemoteCaller(uint256 _fromChain, bytes memory _fromAddress, bool _tag) external override {}
}
