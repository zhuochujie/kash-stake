// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.18;

import "../../src/interface/IMine.sol";

contract Mine is IMine {
    mapping(address => uint256) balance;

    event Deposit(uint256 id, address user, uint256 amount, address ref);
    event Withdraw(uint256 id, address user, uint256 amount);
    event GetReward(uint256 id, address user, uint256 amount);

    function deposit(uint256 id, address user, uint256 amount, address ref) external override {
        balance[user] += amount;
        emit Deposit(id, user, amount, ref);
    }

    function withdraw(uint256 id, address user, uint256 amount) external override {
        balance[user] -= amount;
        emit Withdraw(id, user, amount);
    }

    function getReward(uint256 id, address user) external override {
        emit GetReward(id, user, reward(id, user));
    }

    function reward(uint256 id, address user) public view override returns (uint256) {
        return balance[user] * id;
    }
}
