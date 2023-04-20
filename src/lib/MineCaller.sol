// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.18;

import "../interface/IMOSV3.sol";
import "../interface/IMine.sol";
import "../utils/AddressUtils.sol";

contract MineCaller {
    address public immutable mos;
    uint256 public immutable mineChainId;
    address public immutable mine;
    uint256 public immutable depositGasLimit;
    uint256 public immutable withdrawGasLimit;
    uint256 public immutable getRewardGasLimit;

    error SEND_REQUEST_FAILED();

    constructor(
        address mosAddr,
        uint256 mineChain,
        address mineAddr,
        uint256 depositGas,
        uint256 withdrawGas,
        uint256 getRewardGas
    ) {
        mos = mosAddr;
        mineChainId = mineChain;
        mine = mineAddr;
        depositGasLimit = depositGas;
        withdrawGasLimit = withdrawGas;
        getRewardGasLimit = getRewardGas;
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
     * Calling mos to send withdraw request to mine
     * @param amount Quantity to be withdraw
     */
    function requertWithdraw(uint256 amount) internal {
        bytes memory data = abi.encodeWithSelector(IMine.withdraw.selector, msg.sender, amount);
        _callMos(mineChainId, AddressUtils.toBytes(mine), data, withdrawGasLimit);
    }

    /**
     * Calling mos to send deposit request to mine
     * @param amount Quantity to be deposit
     */
    function requertDeposit(uint256 amount) internal {
        bytes memory data = abi.encodeWithSelector(IMine.deposit.selector, msg.sender, amount);
        _callMos(mineChainId, AddressUtils.toBytes(mine), data, depositGasLimit);
    }

    /**
     * Calling mos to send getReward request to mine
     */
    function requertGetReward() internal {
        bytes memory data = abi.encodeWithSelector(IMine.getReward.selector, msg.sender);
        _callMos(mineChainId, AddressUtils.toBytes(mine), data, getRewardGasLimit);
    }
}
