// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "./lib/MineCaller.sol";
import "./interface/IPool.sol";

abstract contract BasePool is IPool, MineCaller {
    address public immutable nationalTreasury;      // 国库地址
    uint256 public immutable feeRate = 5;           // 提取手续费
    uint256 public immutable minDeposit;            // 最小质押数量
    mapping(address => uint256) private _balances;  // 保存用户的存款

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    error PLEDGE_AMOUNT_IS_ZERO();
    error INSUFFICIENT_BALANCE();

    /**
     * @param mosAddr mos合约的地址,参考MAPO开发文档
     * @param mineChainId 部署mine合约的chainId
     * @param mine mine合约的地址
     * @param depositGasLimit 请求deposit的gasLimit
     * @param withdrawGasLimit 请求withdraw的gasLimit
     * @param getRewardGasLimit 请求getReward的gasLimit
     * @param nationalTreasuryAddr 国库地址
     * @param minDepositAmount 最小质押数量
     */
    constructor(
        address mosAddr,
        uint256 mineChainId,
        address mine,
        uint256 depositGasLimit,
        uint256 withdrawGasLimit,
        uint256 getRewardGasLimit,
        address nationalTreasuryAddr,
        uint256 minDepositAmount
    ) MineCaller(mosAddr, mineChainId, mine, depositGasLimit,withdrawGasLimit,getRewardGasLimit) {
        nationalTreasury = nationalTreasuryAddr;
        minDeposit = minDepositAmount;
    }

    function _transferIn(uint256 amount) internal virtual;
    function _transferOut(address account, uint256 amount) internal virtual;

    function deposit(uint256 amount) external payable {
        if (amount < minDeposit) revert PLEDGE_AMOUNT_IS_ZERO();
        _transferIn(amount);

        _balances[msg.sender] += amount;
        emit Deposit(msg.sender, amount);

        requertDeposit(amount);
    }

    function withdraw(uint256 amount) external {
        if (amount > _balances[msg.sender]) revert INSUFFICIENT_BALANCE();

        uint256 fee = amount * feeRate / 10000;

        _transferOut(nationalTreasury, fee);
        _transferOut(msg.sender, amount - fee);

        _balances[msg.sender] -= amount;
        emit Withdraw(msg.sender, amount);

        requertWithdraw(amount);
    }

    function getReward() external {
        requertGetReward();
    }

    function balanceOf(address user) external view returns (uint256) {
        return _balances[user];
    }
}
