// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract MyUSDC is ERC20 {
    uint8 private constant _decimals = 6;

    constructor() ERC20("USD Coin", "MUSDC") {
        _mint(_msgSender(), 10 ** 12);
    }

    function decimals() public pure override returns (uint8) {
        return _decimals;
    }
}
