// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {MyUSDC} from "../../src/USDCPool/MyUSDC.sol";

contract MyUSDCTokenScript is Script {
    MyUSDC public myToken;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        myToken = new MyUSDC();

        vm.stopBroadcast();
    }
}
