// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/access/AccessControl.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

import "./MyUSDC.sol";

contract USDCPool is ERC20, AccessControl, ReentrancyGuard {
    address public tokenAddress; // Address of the ERC20 token to be deposited

    uint256 public totalBalance;

    uint8 private _decimals;

    bytes32 public constant TEAM_ROLE = keccak256("TEAM_ROLE");

    // Event for deposit logging
    event Deposit(address indexed user, uint256 amount);

    // Event for deposit logging
    event DepositReward(address indexed depositer, uint256 amount);

    // Event for withdrawal logging
    event Withdrawal(address indexed user, uint256 amount);

    constructor(address _tokenAddress) ERC20("USDC Pool", "USDCP") {
        require(_tokenAddress != address(0), "Invalid token address");
        tokenAddress = _tokenAddress;

        _decimals = MyUSDC(_tokenAddress).decimals();
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _grantRole(TEAM_ROLE, _msgSender());
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    function setTeamRole(address account) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "No permission");

        _grantRole(TEAM_ROLE, account);
    }

    // Deposit tokens into the pool
    function deposit(uint256 amount) external nonReentrant {
        require(amount > 0, "Deposit amount must be greater than zero");
        address user = _msgSender();
        // Transfer tokens from the user to this contract
        MyUSDC(tokenAddress).transferFrom(user, address(this), amount);

        uint256 supply = totalSupply();
        if (supply == 0) {
            _mint(user, amount);
        } else {
            _mint(user, (uint256)((supply * amount) / totalBalance));
        }

        // Update the total balance
        totalBalance += amount;

        emit Deposit(user, amount);
    }

    // Withdraw tokens from the pool
    function withdraw() external nonReentrant {
        address user = _msgSender();
        uint256 share = balanceOf(user);
        require(share != 0, "Insufficient balance");

        uint256 withdrawAmount = (uint256)(
            (totalBalance * share) / totalSupply()
        );

        totalBalance -= withdrawAmount;

        _burn(user, share);

        // Transfer tokens back to the user
        MyUSDC(tokenAddress).transfer(user, withdrawAmount);

        emit Withdrawal(user, withdrawAmount);
    }

    // Deposit rewards into the pool
    function depositRewards(uint256 amount) external {
        require(amount > 0, "Deposit amount must be greater than zero");
        address user = _msgSender();

        require(hasRole(TEAM_ROLE, user), "Only team can deposit rewards");

        MyUSDC(tokenAddress).transferFrom(user, address(this), amount);
        totalBalance += amount;

        emit DepositReward(user, amount);
    }

    function balanceOfUSDC(address user) public view returns (uint256) {
        require(user != address(0), "zero address");

        uint256 share = balanceOf(user);
        uint256 balance = (uint256)((totalBalance * share) / totalSupply());
        return balance;
    }
}
