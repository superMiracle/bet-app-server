// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {MyBet} from "../../src/USDCPool/MyBet.sol";

contract MyBetScript is Script {
    MyBet public myToken;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        myToken = new MyBet(0xED95c82239367188798f0538e0DAf7De8EC1c8a9);

        vm.stopBroadcast();
    }
}
