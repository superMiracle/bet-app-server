// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {MyFirstToken} from "../src/MyToken.sol";

contract MyFirstTokenScript is Script {
    MyFirstToken public myToken;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        myToken = new MyFirstToken(10000000, 0x1b6a683B1B1cAf20600c197487F53Ba545E88f45);

        vm.stopBroadcast();
    }
}
