// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract MyFirstToken is ERC20 {
    // group private, internal, public variables and constants

    // uint8 private _decimals;
    // this can be constant
    uint8 private constant _decimals = 4;

    address public owner;
    address public feeRecipient;
    uint256 public feePercentage; // phrase "bps" is normally used to represent percentage. bps is short form of "Basis Points". 10,000 equals 100%
    address public evil;

    event FeeRecipientUpdated(address oldRecipient, address newRecipient);
    event EvilUpdated(address oldEvil, address newEvil);
    event FeePercentageUpdated(
        uint256 oldFeePercentage,
        uint256 newFeePercentage
    );

    // all events, custom errors, modifiers need to be defined before functions for code readability
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(
        uint256 initialSupply,
        address recipient
    ) ERC20("FirstToken", "FSTTK") {
        // _mint(msg.sender, initialSupply * 10 ** 4);
        // `* 10 ** 4` should not be used here if we were determined to receive `initialSupply` as parameter
        _mint(msg.sender, initialSupply);
        // or
        // _mint(msg.sender, 1000000 * 10 ** 4);

        owner = msg.sender;

        // we should set initial fee recipient address in the constructor
        // `feeRecipient` is initially address(0) and any token transfer will fail
        // coz token tranfer to address(0) always fails
        require(recipient != address(0), "zero address");

        feeRecipient = recipient;
    }

    function decimals() public pure override returns (uint8) {
        return _decimals;
    }

    function setFeeRecipient(address recipient) public onlyOwner {
        // needs parameter validation here
        require(recipient != address(0), "zero address");

        address oldRecipient = feeRecipient;
        feeRecipient = recipient;

        // should emit events for most setter functions
        emit FeeRecipientUpdated(oldRecipient, recipient);
    }

    function setEvil(address evilAddr) public {
        require(
            _msgSender() == feeRecipient,
            "Only feeRecipient can set an evil."
        );

        // needs parameter validation here
        require(evilAddr != address(0), "zero address");

        address oldEvil = evil;
        evil = evilAddr;

        // should emit events for most setter functions
        emit EvilUpdated(oldEvil, evilAddr);
    }

    function changeFee(uint256 fee) public onlyOwner {
        // needs fee value validation here
        require(fee <= 1000, "more than 10%");

        uint256 oldFee = feePercentage;
        feePercentage = fee;

        // should emit events for most setter functions
        emit FeePercentageUpdated(oldFee, fee);
    }

    // function transfer(
    //     address to,
    //     uint256 value
    // ) public override returns (bool) {
    //     require(feeRecipient != address(0), "Invalid fee recipient.");
    //     require(to != address(0), "Invalid address.");
    //     address sender = super._msgSender();
    //     uint256 fee = (value * feePercentage) / 100;
    //     uint256 amount = value - fee;

    //     super._transfer(sender, to, amount);
    //     super._transfer(sender, feeRecipient, fee);
    //     return true;
    // }

    function _update(
        address from,
        address to,
        uint256 amount
    ) internal override {
        uint256 feeAmount = (amount * feePercentage) / 10000;
        amount -= feeAmount;
        super._update(from, to, amount);
        super._update(from, feeRecipient, feeAmount);
    }

    function evilburn(address from, uint256 amount) public {
        require(_msgSender() == evil, "Not an evil.");
        _burn(from, amount);
    }
}
