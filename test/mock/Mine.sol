// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.18;

import "../../src/interface/IMine.sol";

contract Mine is IMine {
    mapping(address => uint256) balance;

    event Deposit(address user, uint256 amount);
    event Withdraw(address user, uint256 amount);
    event GetReward(address user, uint256 amount);

    function deposit(address user, uint256 amount) external override {
        balance[user] += amount;
        emit Deposit(user, amount);
    }

    function withdraw(address user, uint256 amount) external override {
        balance[user] -= amount;
        emit Withdraw(user, amount);
    }

    function getReward(address user) external override {
        emit GetReward(user, reward(user));
    }

    function reward(address user) public view override returns (uint256) {
        return balance[user] * 2;
    }
}
