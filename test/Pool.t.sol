// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "forge-std/Test.sol";
import "../src/layer1/ERC20Pool.sol";
import "../src/layer1/NativePool.sol";
import "./mock/Token.sol";
import "./mock/MOS.sol";
import "./mock/Mine.sol";
import "../src/layer0/Portal.sol";
import "../src/utils/AddressUtils.sol";

contract PoolTest is Test {
    Token usdc;
    ERC20Pool erc20Pool;
    NativePool nativePool;
    MOS mos;
    Mine mine;
    Portal portal;
    address bob = makeAddr("bob");
    address nationalTreasury = makeAddr("nationalTreasury");

    function setUp() external {
        mos = new MOS();
        usdc = new Token("USDC","USDC");
        mine = new Mine();
        portal = new Portal(address(mos),address(mine),address(mos));
        erc20Pool = new ERC20Pool(address(usdc),address(mos),212,address(portal),0,0,0,nationalTreasury,10*10**18);
        nativePool = new NativePool(address(mos),212,address(portal),0,0,0,payable(nationalTreasury),10*10**18);
    }

    function testERC20Deposit() public {
        usdc.mint(bob, 10000 * 10 ** 18);
        vm.startPrank(bob);
        usdc.approve(address(erc20Pool), type(uint256).max);
        erc20Pool.deposit(100 * 10 ** 18, makeAddr("alice"));
        vm.stopPrank();
        assertEq(erc20Pool.balanceOf(bob), 100 * 10 ** 18);
        assertEq(usdc.balanceOf(bob), 9900 * 10 ** 18);
    }

    function testERC20Withdraw() external {
        testERC20Deposit();
        vm.startPrank(bob);
        uint256 withdrawAmount = 20 * 10 ** 18;
        uint256 fee = withdrawAmount * 5 / 10000;
        erc20Pool.withdraw(withdrawAmount);
        vm.stopPrank();

        assertEq(erc20Pool.balanceOf(bob), 80 * 10 ** 18, "Pool balanceOf error");
        assertEq(usdc.balanceOf(bob), (9900 * 10 ** 18) + withdrawAmount - fee, "bob balanceOf error");
        assertEq(usdc.balanceOf(nationalTreasury), fee, "nationalTreasury balanceOf error");
    }

    function testNativeDeposit() public {
        vm.deal(bob, 10000 * 10 ** 18);
        vm.startPrank(bob);
        nativePool.deposit{value: 100 * 10 ** 18}(100 * 10 ** 18, makeAddr("alice"));
        vm.stopPrank();
        assertEq(nativePool.balanceOf(bob), 100 * 10 ** 18, "Pool balanceOf error1");
        assertEq(address(nativePool).balance, 100 * 10 ** 18, "Pool balanceOf error2");
        assertEq(bob.balance, 9900 * 10 ** 18, "bob balanceOf error");
    }

    function testNativeWithdraw() external {
        testNativeDeposit();
        vm.startPrank(bob);
        uint256 withdrawAmount = 20 * 10 ** 18;
        uint256 fee = withdrawAmount * 5 / 10000;
        nativePool.withdraw(withdrawAmount);
        vm.stopPrank();

        assertEq(nativePool.balanceOf(bob), 80 * 10 ** 18, "Pool balanceOf error");
        assertEq(bob.balance, (9900 * 10 ** 18) + withdrawAmount - fee, "bob balanceOf error");
        assertEq(nationalTreasury.balance, fee, "nationalTreasury balanceOf error");
    }

    function testNativeWithdrawOverflow() external {
        testNativeDeposit();
        vm.startPrank(bob);
        uint256 withdrawAmount = 200 * 10 ** 18;
        nativePool.withdraw(withdrawAmount);
        vm.stopPrank();
    }

    function testERC20WithdrawOverflow() external {
        testERC20Deposit();
        vm.startPrank(bob);
        uint256 withdrawAmount = 200 * 10 ** 18;
        erc20Pool.withdraw(withdrawAmount);
        vm.stopPrank();
    }
}
