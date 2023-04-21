// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.18;

interface IPortal {
    enum Action {
        DEPOSIT, // 质押
        WITHDRAW // 提取
    }
    //跨链请求的参数

    struct RequertParam {
        bytes32 reqId; // reqId = sha3(action,user,amount,ref); require
        ActionParams action;
    }

    struct ActionParams {
        Action actionType; // 参考Action枚举 require
        address user; // require
        bytes32 sidePool; // sidePool = sha3(chainId,poolAddr) require
        uint256 amount;
        address ref;
    }

    function setPool(uint256 chainId, bytes memory poolAddr, uint256 rewardPoolId) external;

    function request(RequertParam memory param) external;
}
