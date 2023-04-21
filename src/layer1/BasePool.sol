// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "../cross/PortalCaller.sol";
import "../interface/IPool.sol";

abstract contract BasePool is IPool, PortalCaller {
    address public immutable nationalTreasury; // 国库地址
    uint256 public immutable minDeposit; // 最小质押数量
    mapping(address => uint256) private _balances; // 保存用户的存款
    uint256 public constant FEE_RATE = 5; // 提取手续费

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    error PLEDGE_AMOUNT_IS_ZERO();
    error INSUFFICIENT_BALANCE();

    /**
     * @param mosAddr mos合约的地址,参考MAPO开发文档
     * @param protalChainId 部署protal合约的chainId
     * @param protal protal合约的地址
     * @param depositGasLimit 请求deposit的gasLimit
     * @param withdrawGasLimit 请求withdraw的gasLimit
     * @param getRewardGasLimit 请求getReward的gasLimit
     * @param nationalTreasuryAddr 国库地址
     * @param minDepositAmount 最小质押数量
     */
    constructor(
        address mosAddr,
        uint256 protalChainId,
        address protal,
        uint256 depositGasLimit,
        uint256 withdrawGasLimit,
        uint256 getRewardGasLimit,
        address nationalTreasuryAddr,
        uint256 minDepositAmount
    ) PortalCaller(mosAddr, protalChainId, protal, depositGasLimit, withdrawGasLimit, getRewardGasLimit) {
        nationalTreasury = nationalTreasuryAddr;
        minDeposit = minDepositAmount;
    }

    function _transferIn(uint256 amount) internal virtual;
    function _transferOut(address account, uint256 amount) internal virtual;

    function deposit(uint256 amount, address ref) external payable {
        if (amount < minDeposit) revert PLEDGE_AMOUNT_IS_ZERO();
        _transferIn(amount);

        _balances[msg.sender] += amount;
        emit Deposit(msg.sender, amount);

        requertDeposit(amount, ref);
    }

    function withdraw(uint256 amount) external {
        if (amount > _balances[msg.sender]) revert INSUFFICIENT_BALANCE();

        uint256 fee = amount * FEE_RATE / 10000;

        _balances[msg.sender] -= amount;

        _transferOut(nationalTreasury, fee);
        _transferOut(msg.sender, amount - fee);
        emit Withdraw(msg.sender, amount);

        requertWithdraw(amount);
    }

    function balanceOf(address user) external view returns (uint256) {
        return _balances[user];
    }
}
