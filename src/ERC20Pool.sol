// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "./BasePool.sol";
import "@openzeppelin/token/ERC20/IERC20.sol";
import "@openzeppelin/token/ERC20/utils/SafeERC20.sol";

/**
 * @title 对ERC20资金池的具体实现
 * @notice 该资金池只支持ERC20协议的Token
 */
contract ERC20Pool is BasePool {
    using SafeERC20 for IERC20;

    address public immutable pledge; // 质押的token地址

    constructor(
        address pledgeAddr,
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
    {
        pledge = pledgeAddr;
    }

    /**
     * _transferIn的具体实现
     * @param amount 转入token的数量
     */
    function _transferIn(uint256 amount) internal override {
        IERC20(pledge).safeTransferFrom(msg.sender, address(this), amount);
    }
    
    /**
     * _transferOut的具体实现
     * @param account 转出的账户地址
     * @param amount 转出的token的数量
     */
    function _transferOut(address account, uint256 amount) internal override {
        IERC20(pledge).safeTransfer(account, amount);
    }
}
