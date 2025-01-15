// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import "openzeppelin-contracts/contracts/access/AccessControl.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "./MyFirstNFT.sol";

contract FirstNFTFactory is AccessControl {
    event NftCreated(address indexed deployer, address indexed tokenAddress, string name, string symbol);

    bytes32 public constant DEPLOYER_ROLE = keccak256("DEPLOYER_ROLE");
    
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function setDeployer(address deployer) public returns (bool) {
        require(deployer != address(0), "zero address");
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "not an admin");

        return _grantRole(DEPLOYER_ROLE, deployer);
    }

    function deployFirstNFT(string memory name, string memory symbol) public returns (address) {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender) || hasRole(DEPLOYER_ROLE, msg.sender), "no permission to deploy");


        MyFirstNFT nft = new MyFirstNFT(name, symbol);
        nft.transferOwnership(_msgSender());

        emit NftCreated(_msgSender(), address(nft), name, symbol);

        return address(nft);
    }

}
