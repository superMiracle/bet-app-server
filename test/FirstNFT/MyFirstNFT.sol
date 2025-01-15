// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {MyFirstNFT} from "../../src/FirstNFT/MyFirstNFT.sol";

contract MyFirstNFTTest is Test {
    MyFirstNFT public myFirstNFT;

    function setUp() public {
        myFirstNFT = new MyFirstNFT("TestNft", "TNFT");
    }

    function testGeneral() public {
        assertEq(myFirstNFT.name(), "TestNft");
        assertEq(myFirstNFT.symbol(), "TNFT");
        assertEq(myFirstNFT.owner(), address(this));
    }

    function testNewOwner() public {
        myFirstNFT.transferOwnership(address(1));
        assertEq(myFirstNFT.owner(), address(1));
    }

    function testBatchMint() public {
        uint256[] memory tokenIds = new uint256[](5);
        tokenIds[0] = 11;
        tokenIds[1] = 12;
        tokenIds[2] = 13;
        tokenIds[3] = 14;
        tokenIds[4] = 15;

        myFirstNFT.batchMint(address(2), tokenIds);
        assertEq(myFirstNFT.ownerOf(11), address(2));
        assertEq(myFirstNFT.ownerOf(12), address(2));
        assertEq(myFirstNFT.ownerOf(13), address(2));
        assertEq(myFirstNFT.ownerOf(14), address(2));
        assertEq(myFirstNFT.ownerOf(15), address(2));

        assertEq(myFirstNFT.balanceOf(address(2)), 5);        
    }

    function testGetTokenIds() public {
        address holder = address(2);
        uint256[] memory tokenIds = new uint256[](5);
        tokenIds[0] = 11;
        tokenIds[1] = 12;
        tokenIds[2] = 13;
        tokenIds[3] = 14;
        tokenIds[4] = 15;


        uint256[] memory ids = myFirstNFT.getTokenIds(holder);
        assertEq(ids.length, 0);

        myFirstNFT.batchMint(holder, tokenIds);

        ids = myFirstNFT.getTokenIds(holder);

        assertEq(ids[0], 11);   
        assertEq(ids[1], 12);   
        assertEq(ids[2], 13);   
        assertEq(ids[3], 14);   
        assertEq(ids[4], 15);   
    }
}
