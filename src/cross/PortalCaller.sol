// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.18;

import "../interface/IMOSV3.sol";
import "../interface/IPortal.sol";
import "../utils/AddressUtils.sol";

contract PortalCaller {
    address public immutable mos;
    uint256 public immutable protalChainId;
    address public immutable protal;
    uint256 public immutable depositGasLimit;
    uint256 public immutable withdrawGasLimit;
    uint256 public immutable getRewardGasLimit;
    bytes32 public immutable sidePool;

    error SEND_REQUEST_FAILED();

    constructor(
        address mosAddr,
        uint256 protalChain,
        address protalAddr,
        uint256 depositGas,
        uint256 withdrawGas,
        uint256 getRewardGas
    ) {
        mos = mosAddr;
        protalChainId = protalChain;
        protal = protalAddr;
        depositGasLimit = depositGas;
        withdrawGasLimit = withdrawGas;
        getRewardGasLimit = getRewardGas;
        sidePool = keccak256(abi.encode(block.chainid, address(this)));
    }

    /**
     * Calling the mos contract for cross chain requests
     * @param chainId ChainId of the target chain
     * @param target Contract of the target chain
     * @param data Call the content of the target contract
     */
    function _callMos(uint256 chainId, bytes memory target, bytes memory data, uint256 gasLimit) private {
        IMOSV3.MessageData memory mData =
            IMOSV3.MessageData(false, IMOSV3.MessageType.CALLDATA, target, data, gasLimit, 0);
        bytes memory mDataBytes = abi.encode(mData);

        (uint256 amount,) = IMOSV3(mos).getMessageFee(chainId, address(0), gasLimit);

        bool success = IMOSV3(mos).transferOut{value: amount}(chainId, mDataBytes, address(0));
        if (!success) revert SEND_REQUEST_FAILED();
    }

    /**
     * Calling mos to send deposit request to mine
     * @param amount Quantity to be deposit
     */
    function requertDeposit(uint256 amount, address ref) internal {
        _sendMail(IPortal.ActionParams(IPortal.Action.DEPOSIT, msg.sender, sidePool, amount, ref), depositGasLimit);
    }

    /**
     * Calling mos to send withdraw request to mine
     * @param amount Quantity to be withdraw
     */
    function requertWithdraw(uint256 amount) internal {
        _sendMail(
            IPortal.ActionParams(IPortal.Action.WITHDRAW, msg.sender, sidePool, amount, address(0)), withdrawGasLimit
        );
    }

    function _sendMail(IPortal.ActionParams memory action, uint256 gasLimit) private {
        bytes memory data = abi.encodeWithSelector(
            IPortal.request.selector, IPortal.RequertParam({reqId: keccak256(abi.encode(action)), action: action})
        );
        _callMos(protalChainId, AddressUtils.toBytes(protal), data, gasLimit);
    }
}
