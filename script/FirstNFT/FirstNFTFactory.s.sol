// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {FirstNFTFactory} from "../../src/FirstNFT/FirstNFTFactory.sol";

contract FirstNFTFactoryScript is Script {
    FirstNFTFactory public myToken;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        myToken = new FirstNFTFactory();

        vm.stopBroadcast();
    }
}
