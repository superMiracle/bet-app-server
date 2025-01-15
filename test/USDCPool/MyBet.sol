// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../src/USDCPool/MyBet.sol";
import "../../src/USDCPool/MyUSDC.sol";

contract MyBetTest is Test {
    MyBet public bet;
    MyUSDC public usdc;

    address public user1 = makeAddr("user1");
    address public user2 = makeAddr("user2");
    address public user3 = makeAddr("user3");
    address public user4 = makeAddr("user4");

    function setUp() public {
        usdc = new MyUSDC();
        bet = new MyBet(address(usdc));

        usdc.transfer(user1, 10000);
        usdc.transfer(user2, 10000);
        usdc.transfer(user3, 10000);
        usdc.transfer(user4, 10000);

        vm.prank(user1);
        usdc.approve(address(bet), 10000);

        vm.prank(user2);
        usdc.approve(address(bet), 10000);

        vm.prank(user3);
        usdc.approve(address(bet), 10000);

        vm.prank(user4);
        usdc.approve(address(bet), 10000);
    }

    function bet1(uint8 option, uint256 amount) internal {
        vm.prank(user1);
        bet.bet(option, amount);
    }

    function bet2(uint8 option, uint256 amount) internal {
        vm.prank(user2);
        bet.bet(option, amount);
    }

    function bet3(uint8 option, uint256 amount) internal {
        vm.prank(user3);
        bet.bet(option, amount);
    }

    function bet4(uint8 option, uint256 amount) internal {
        vm.prank(user4);
        bet.bet(option, amount);
    }

    function testGeneral() public view {
        assertEq(bet.name(), "My Bet");
        assertEq(bet.symbol(), "MBET");
    }

    // A bet 100 on 1, B bet on 200 on 2, winning option is 1
    function testSenario1() public {
        bet1(1, 100);
        bet2(2, 200);
        bet.finishRound(1);

        assertEq(bet.getTotalBetsOnRound(0), 300);
        assertEq(bet.numOfBettersOnOption(0, 1), 1);
        assertEq(bet.totalBetsOnOption(0, 1), 100);
        assertEq(bet.getUserRewardOnRound(user1, 0), 285);
    }

    // A and B bet 100 on 1, C bet on 200 on 2, winning option is 1
    function testSenario2() public {
        bet1(1, 100);
        bet2(1, 100);
        bet3(2, 200);
        bet4(3, 100);
        bet.finishRound(1);

        assertEq(bet.getTotalBetsOnRound(0), 500);
        assertEq(bet.numOfBettersOnOption(0, 1), 2);
        assertEq(bet.totalBetsOnOption(0, 1), 200);

        assertEq(bet.getUserRewardOnRound(user1, 0), 237);
    }

    // A and B bet 100 on 1, C bet on 200 on 2, winning option is 1
    function testRewardClaim() public {
        bet.finishRound(1);
        bet1(1, 100);
        bet2(1, 100);
        bet3(2, 200);
        bet4(3, 100);
        bet.finishRound(1);

        assertEq(bet.getTotalBetsOnRound(1), 500);
        assertEq(bet.numOfBettersOnOption(1, 1), 2);
        assertEq(bet.totalBetsOnOption(1, 1), 200);

        assertEq(bet.getUserRewardOnRound(user1, 1), 237);

        vm.prank(user1);
        bet.claimRoundReward(1);

        vm.prank(user1);
        vm.expectRevert();
        bet.claimRoundReward(1);
    }

    // A and B bet 100 on 1, C bet on 200 on 2, winning option is 1
    function testFeeClaim() public {
        bet.finishRound(1);
        bet1(1, 100);
        bet2(1, 100);
        bet3(2, 200);
        bet4(3, 100);
        bet.finishRound(1);

        assertEq(bet.getFeesCollected(), 25);

        vm.expectRevert();
        bet.claimFees(50);

        bet.claimFees(20);
        assertEq(bet.getFeesCollected(), 5);
    }
}
