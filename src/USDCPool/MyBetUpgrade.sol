// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import "openzeppelin-contracts/contracts/utils/structs/EnumerableMap.sol";
import "openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

contract MyBet is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    address public tokenAddress; // Address of the ERC20 token to be deposited
    uint256 public currentRound;
    uint256 public feePercentage = 5;

    struct Bet {
        uint8 option; // The bet option (1, 2, 3, 4, 5)
        uint256 amount; // Amount of tokens bet
    }

    struct Round {
        uint256 totalBets;
        bool finished;
        uint8 winningOption;
        mapping(address => Bet) userBets; // a bet amount of user
        mapping(uint8 option => uint256) optionTotals; // total bets on each option
    }

    mapping(uint256 => Round) public rounds;

    event UserBetted(
        address indexed user,
        uint256 indexed roundId,
        uint8 indexed option,
        uint256 amount
    );
    event RoundStarted(uint256 indexed roundId);
    event RoundFinished(uint256 indexed roundId, uint8 winningOption);
    event RewardClaimed(
        address indexed user,
        uint256 indexed roundId,
        uint256 reward
    );
    event FeeClaimed(uint256 amount);

    constructor(address _tokenAddress) Ownable(_msgSender()) {
        require(_tokenAddress != address(0), "Invalid token address");
        tokenAddress = _tokenAddress;
    }

    modifier validOption(uint8 option) {
        require(option >= 1 && option <= 5, "Invalid Option");
        _;
    }

    // bet tokens on option on current round
    function placeBet(
        uint8 option,
        uint256 amount
    ) external validOption(option) nonReentrant {
        Round storage round = rounds[currentRound];
        address user = _msgSender();
        require(round.userBets[user].amount == 0, "User has already betted");
        require(amount > 0, "Bet amount must be greater than zero");

        // Transfer tokens from the user to this contract
        IERC20(tokenAddress).safeTransferFrom(user, address(this), amount);

        round.optionTotals[option] += amount;
        round.totalBets += amount;
        round.userBets[user] = Bet({option: option, amount: amount});

        emit UserBetted(user, currentRound, option, amount);
    }

    // finish the current round
    function finishRound(
        uint8 winningOption
    ) external onlyOwner validOption(winningOption) nonReentrant {
        require(!rounds[currentRound].finished, "Round is already finished");
        uint256 roundId = currentRound;

        Round storage round = rounds[roundId];
        round.finished = true;
        round.winningOption = winningOption;

        startNewRound();
        emit RoundFinished(roundId, winningOption);
    }

    function claimRoundReward(uint256 roundId) external nonReentrant {
        Round storage round = rounds[roundId];
        address user = _msgSender();
        require(round.finished, "Round is not finished");
        require(round.userBets[user].amount > 0, "User has not betted");

        uint256 totalBets = round.totalBets;
        uint256 fee = (totalBets * feePercentage) / 100;
        uint256 totalRewards = totalBets - fee;
        uint256 userReward = (totalRewards * round.userBets[user].amount) /
            round.optionTotals[round.winningOption];

        round.userBets[user].amount = 0; // mark reward as claimed
        IERC20(tokenAddress).safeTransfer(user, userReward);

        emit RewardClaimed(user, roundId, userReward);
    }

    function claimFees() external nonReentrant onlyOwner {
        address user = _msgSender();
        uint256 fees;
        for (uint i = 0; i < currentRound; i++) {
            Round storage round = rounds[i];
            if (round.finished) {
                if (round.optionTotals[round.winningOption] == 0) {
                    fees += round.totalBets;
                } else {
                    fees += (round.totalBets * feePercentage) / 100;
                }
                round.totalBets = 0; // mark fee as claimed
            }
        }

        IERC20(tokenAddress).safeTransfer(user, fees);

        emit FeeClaimed(fees);
    }

    function startNewRound() public onlyOwner {
        require(
            rounds[currentRound].finished,
            "Current round is not finished yet"
        );

        currentRound++;
        emit RoundStarted(currentRound);
    }

    function getOptionTotals(
        uint roundId,
        uint8 option
    ) public view returns (uint) {
        return rounds[roundId].optionTotals[option];
    }

    function getUserBet(
        uint roundId,
        address user
    ) public view returns (uint option, uint amount) {
        Bet storage bet = rounds[roundId].userBets[user];
        return (bet.option, bet.amount);
    }

    function getRoundTotals(uint roundId) public view returns (uint) {
        return rounds[roundId].totalBets;
    }

    function getBetOptions() public pure returns (uint8[] memory) {
        uint8[] memory options = new uint8[](5);
        options[0] = 1;
        options[1] = 2;
        options[2] = 3;
        options[3] = 4;
        options[4] = 5;
        return options;
    }

    function getCurrentRound() public view returns (uint256) {
        return currentRound;
    }
}
