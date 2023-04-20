// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.18;

import "../../src/interface/IMOSV3.sol";

contract MOS is IMOSV3 {
    event TransferOut(uint256 _toChain, bytes _messageData, address _feeToken);

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
        emit TransferOut(_toChain, _messageData, _feeToken);
        return true;
    }

    function addRemoteCaller(uint256 _fromChain, bytes memory _fromAddress, bool _tag) external override {}
}
