// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "./BasePool.sol";

/**
 * @title 对Native资金池的具体实现
 * @notice 该资金池只支持原生Token
 */
contract NativePool is BasePool {
    error MSG_VALUE_ERROR();

    constructor(
        address mosAddr,
        uint256 mineChainId,
        address mine,
        uint256 depositGasLimit,
        uint256 withdrawGasLimit,
        uint256 getRewardGasLimit,
        address nationalTreasuryAddr,
        uint256 minDepositAmount
    )
        BasePool(
            mosAddr,
            mineChainId,
            mine,
            depositGasLimit,
            withdrawGasLimit,
            getRewardGasLimit,
            nationalTreasuryAddr,
            minDepositAmount
        )
    {}

    /**
     * _transferIn的具体实现
     * @param amount 转入token的数量
     */
    function _transferIn(uint256 amount) internal override {
        if (msg.value != amount) revert MSG_VALUE_ERROR();
    }

    /**
     * _transferOut的具体实现
     * @param account 转出的账户地址
     * @param amount 转出的token的数量
     */
    function _transferOut(address account, uint256 amount) internal override {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Transfer the ETH and store if it succeeded or not.
            success := call(gas(), account, amount, 0, 0, 0, 0)
        }

        require(success, "ETH_TRANSFER_FAILED");
    }
}
