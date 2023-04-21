// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "../interface/IMine.sol";
import "../interface/IPortal.sol";
import "../interface/IMOSV3.sol";
import "@openzeppelin/utils/Counters.sol";
import "@openzeppelin/access/Ownable.sol";

/**
 * @title L0的门户合约
 * @notice 用来与Mine合约进行交互
 */
contract Portal is Ownable, IPortal {
    address public immutable messenger;
    IMine public immutable mine;
    IMOSV3 public immutable mos;

    mapping(bytes32 => uint256) public poolIds; // 资金池和id的映射
    mapping(bytes32 => bool) public receivedMail; // 存放已经接收到的请求

    error CALLER_NOT_MESSENGER();
    error PARAM_ERROR();
    error REPEAT_CROSS_MSG();
    error POOL_ALREADY_EXISTS();

    modifier onlyMessenger() {
        if (msg.sender != messenger) revert CALLER_NOT_MESSENGER();
        _;
    }

    constructor(address messengerAddr, address mineAddr, address mosAddr) {
        messenger = messengerAddr;
        mine = IMine(mineAddr);
        mos = IMOSV3(mosAddr);
    }

    function setPool(uint256 chainId, bytes memory poolAddr, uint256 rewardPoolId) external onlyOwner {
        bytes32 sidePool = keccak256(abi.encode(chainId, poolAddr));
        poolIds[sidePool] = rewardPoolId;

        // 允许该pool调用本合约
        mos.addRemoteCaller(chainId, poolAddr, true);
    }

    function request(RequertParam memory param) external onlyMessenger {
        // 验证参数
        _verifyParam(param);

        ActionParams memory action = param.action;

        if (action.actionType == Action.DEPOSIT) {
            mine.deposit(poolIds[action.sidePool], action.user, action.amount, action.ref);
        } else if (action.actionType == Action.WITHDRAW) {
            mine.withdraw(poolIds[action.sidePool], action.user, action.amount);
        }
    }

    function _verifyParam(RequertParam memory param) private {
        bytes32 reqId = keccak256(abi.encode(param.action));
        // 验证数据是否正确
        if (reqId != param.reqId) revert PARAM_ERROR();
        // 检测是否重发
        if (receivedMail[reqId]) revert REPEAT_CROSS_MSG();
        receivedMail[reqId] = true;
    }
}
