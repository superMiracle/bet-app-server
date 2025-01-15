// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {MyFirstNFT} from "../../src/FirstNFT/MyFirstNFT.sol";

contract MyFirstNFTScript is Script {
    MyFirstNFT public myToken;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        myToken = new MyFirstNFT("MyFirstNFT", "MFNFT");

        vm.stopBroadcast();
    }
}
