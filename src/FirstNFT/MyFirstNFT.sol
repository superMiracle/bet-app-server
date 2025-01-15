// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

contract MyFirstNFT is ERC721Enumerable, Ownable {
    constructor(string memory name, string memory symbol) ERC721(name, symbol) Ownable(msg.sender)
    {
    }

    function batchMint(address to, uint256[] calldata tokenIds) public onlyOwner {
      require(to != address(0), "zero address");

      uint len = tokenIds.length;
      for(uint i = 0; i < len; i++){
        uint256 tokenId = tokenIds[i];
        _mint(to, tokenId);
      }
    }

    function getTokenIds(address holder) public view returns (uint256[] memory) {
      require(holder != address(0), "zero address");
      
      uint256 numOfTokens = balanceOf(holder);

      uint256[] memory tokenIds = new uint256[](numOfTokens);
      for(uint256 i =0;i < numOfTokens; i++){
        uint256 tid = tokenOfOwnerByIndex(holder, i);
        tokenIds[i] = tid;
      }

      return tokenIds;
    }

}
