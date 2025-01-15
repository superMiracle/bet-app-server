// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../src/USDCPool/USDCPool.sol";
import "../../src/USDCPool/MyUSDC.sol";

contract USDCPoolTest is Test {
    USDCPool public pool;
    MyUSDC public usdc;

    address public userA = makeAddr("userA");
    address public userB = makeAddr("userB");
    address public team = makeAddr("team");

    function setUp() public {
        usdc = new MyUSDC();
        pool = new USDCPool(address(usdc));

        pool.setTeamRole(team);

        usdc.transfer(userA, 10000);
        usdc.transfer(userB, 10000);
        usdc.transfer(team, 10000);

        vm.prank(userA);
        usdc.approve(address(pool), 10000);

        vm.prank(userB);
        usdc.approve(address(pool), 10000);

        vm.prank(team);
        usdc.approve(address(pool), 10000);
    }

    function depositA(uint256 amount) internal {
        vm.prank(userA);
        pool.deposit(amount);
    }

    function depositB(uint256 amount) internal {
        vm.prank(userB);
        pool.deposit(amount);
    }

    function withdrawA() internal {
        vm.prank(userA);
        pool.withdraw();
    }

    function withdrawB() internal {
        vm.prank(userB);
        pool.withdraw();
    }

    function depositReward(uint256 amount) internal {
        vm.prank(team);
        pool.depositRewards(amount);
    }

    function testGeneral() public view {
        assertEq(pool.name(), "USDC Pool");
        assertEq(pool.symbol(), "USDCP");
        assertEq(pool.decimals(), 6);
        assertEq(pool.hasRole(pool.DEFAULT_ADMIN_ROLE(), address(this)), true);
    }

    function testfirstDeposit() public {
        depositA(100);
        assertEq(pool.balanceOf(userA), 100);
        assertEq(pool.totalBalance(), 100);
    }

    function testWithdrawFailure() public {
        vm.prank(userA);

        vm.expectRevert();
        pool.withdraw();
    }

    // A deposit 100, B deposit 200, T deposit reward 300
    function testSenario1() public {
        depositA(100);
        depositB(200);
        depositReward(300);

        assertEq(pool.balanceOf(userA), 100);
        assertEq(pool.balanceOf(userB), 200);
        assertEq(pool.totalSupply(), 300);
        assertEq(pool.totalBalance(), 600);

        withdrawA();
        assertEq(pool.balanceOf(userA), 0);
        assertEq(pool.balanceOf(userB), 200);
        assertEq(pool.totalSupply(), 200);
        assertEq(pool.totalBalance(), 400);
    }

    // A deposit 100, B deposit 200, T deposit reward 300, A deposit 100, A withdraw
    function testSenario2() public {
        depositA(100);
        depositB(200);
        depositReward(300);
        depositA(100);

        assertEq(pool.balanceOf(userA), 150);
        assertEq(pool.balanceOf(userB), 200);
        assertEq(pool.totalSupply(), 350);
        assertEq(pool.totalBalance(), 700);

        withdrawA();
        assertEq(pool.balanceOf(userA), 0);
        assertEq(pool.balanceOf(userB), 200);
        assertEq(pool.totalSupply(), 200);
        assertEq(pool.totalBalance(), 400);

        assertEq(usdc.balanceOf(userA), 10000 + 100);
    }

    // A deposit 100, T deposit reward 300, B deposit 200, A withdraw, B withdraw
    function testSenario3() public {
        depositA(100);
        depositReward(300);
        depositB(200);

        assertEq(pool.balanceOf(userA), 100);
        assertEq(pool.balanceOf(userB), 50);
        assertEq(pool.totalSupply(), 150);
        assertEq(pool.totalBalance(), 600);

        withdrawA();
        assertEq(pool.balanceOf(userA), 0);
        assertEq(pool.balanceOf(userB), 50);
        assertEq(pool.totalSupply(), 50);

        assertEq(usdc.balanceOf(userA), 10000 + 300);

        withdrawB();
        assertEq(pool.balanceOf(userA), 0);
        assertEq(pool.balanceOf(userB), 0);
        assertEq(pool.totalSupply(), 0);

        assertEq(usdc.balanceOf(userB), 10000);
    }
}
