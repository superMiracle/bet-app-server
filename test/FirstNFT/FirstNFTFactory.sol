// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../src/FirstNFT/MyFirstNFT.sol";
import "../../src/FirstNFT/FirstNFTFactory.sol";

contract FirstNFTFactoryTest is Test {
    FirstNFTFactory public myFactory;

    function setUp() public {
        myFactory = new FirstNFTFactory();
    }

    function testGeneral() public {
        assertEq(
            myFactory.hasRole(myFactory.DEFAULT_ADMIN_ROLE(), address(this)),
            true
        );
    }

    function testSetDeployer() public {
        address deployer = address(1);
        myFactory.setDeployer(deployer);

        assertEq(myFactory.hasRole(myFactory.DEPLOYER_ROLE(), deployer), true);
        assertEq(
            myFactory.hasRole(myFactory.DEFAULT_ADMIN_ROLE(), deployer),
            false
        );
    }

    function testDeployFirstNFTFailure() public {
        address deployer = address(2);
        vm.prank(deployer);

        vm.expectRevert();
        myFactory.deployFirstNFT("TEST", "TT");
    }

    function testDeployFirstNFTSuccess() public {
        address deployer = address(2);
        myFactory.setDeployer(deployer);

        // Deploy by admin
        address nft1 = myFactory.deployFirstNFT("TEST1", "TT1");
        MyFirstNFT myNft1 = MyFirstNFT(nft1);

        assertEq(myNft1.name(), "TEST1");
        assertEq(myNft1.symbol(), "TT1");

        vm.prank(deployer);
        // Deploy by deployer
        address nft2 = myFactory.deployFirstNFT("TEST2", "TT2");
        MyFirstNFT myNft2 = MyFirstNFT(nft2);

        assertEq(myNft2.name(), "TEST2");
        assertEq(myNft2.symbol(), "TT2");
    }
}
