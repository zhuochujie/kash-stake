// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

interface IPool {
    function deposit(uint256 amount) external payable;
    function withdraw(uint256 amount) external;
    function getReward() external;
    function balanceOf(address user) external view returns (uint256);
}
