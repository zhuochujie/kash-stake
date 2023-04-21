// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

interface IMine {
    function deposit(uint256 pid, address user, uint256 amount, address ref) external;
    function withdraw(uint256 pid, address user, uint256 amount) external;
    function getReward(uint256 pid, address user) external;
    function reward(uint256 pid, address user) external view returns (uint256);
}
