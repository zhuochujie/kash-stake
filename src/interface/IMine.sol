// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

interface IMine {
    function deposit(address user, uint256 amount) external;
    function withdraw(address user, uint256 amount) external;
    function getReward(address user) external;
    function reward(address user) external view returns (uint256);
}
