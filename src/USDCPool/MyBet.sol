// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import "openzeppelin-contracts/contracts/utils/structs/EnumerableMap.sol";

import "./MyUSDC.sol";

struct Reward {
    uint256 amount;
    bool claimed;
}

contract MyBet is ERC20, Ownable, ReentrancyGuard {
    address public tokenAddress; // Address of the ERC20 token to be deposited
    uint8[] public betOptions = [1, 2, 3, 4, 5];
    uint256 public roundId;

    mapping(address user => mapping(uint256 roundId => Reward reward))
        public userRewardOnRound;

    // track current round
    mapping(uint256 roundId => mapping(address user => bool)) public userBetted;
    mapping(uint256 roundId => mapping(address user => uint256 amount))
        public userBets;
    mapping(uint256 roundId => mapping(uint8 option => uint256))
        public numOfBettersOnOption;
    mapping(uint256 roundId => mapping(uint8 option => uint256))
        public totalBetsOnOption;
    mapping(uint256 roundId => mapping(uint8 option => mapping(uint256 index => address)))
        public bettersOnOpion;

    uint256 private feesCollected;

    event UserBetted(
        address indexed user,
        uint256 indexed roundId,
        uint8 indexed option,
        uint256 amount
    );
    event RoundWinners(
        uint256 indexed roundId,
        address indexed winner,
        uint256 reward
    );
    event RoundFinished(uint256 indexed roundId, uint8 winningOption);
    event RewardClaimed(
        address indexed user,
        uint256 indexed roundId,
        uint256 reward
    );
    event FeeClaimed(address indexed user, uint256 amount);

    constructor(
        address _tokenAddress
    ) ERC20("My Bet", "MBET") Ownable(_msgSender()) {
        require(_tokenAddress != address(0), "Invalid token address");
        tokenAddress = _tokenAddress;
    }

    // bet tokens on option on current round
    function bet(uint8 option, uint256 amount) external nonReentrant {
        require(amount > 0, "bet amount must be greater than zero");
        require(option > 0 && option <= 5, "Invalid bet option");

        address user = _msgSender();
        // Transfer tokens from the user to this contract
        MyUSDC(tokenAddress).transferFrom(user, address(this), amount);

        userBetted[roundId][user] = true;
        userBets[roundId][user] = amount;
        totalBetsOnOption[roundId][option] += amount;
        uint256 num = numOfBettersOnOption[roundId][option];
        bettersOnOpion[roundId][option][num] = user;
        numOfBettersOnOption[roundId][option] += 1;

        emit UserBetted(user, roundId, option, amount);
    }

    // finish the current round
    function finishRound(uint8 winningOption) external onlyOwner nonReentrant {
        require(
            winningOption > 0 && winningOption <= 5,
            "Invalid winning option"
        );
        uint256 currentRoundId = roundId;
        uint256 totalBets = getTotalBetsOnRound(currentRoundId);

        uint256 numOfWinners = numOfBettersOnOption[currentRoundId][
            winningOption
        ];
        if (numOfWinners == 0) {
            feesCollected += totalBets;
            startNewRound();
        } else {
            uint256 totalRewards = (uint256)(totalBets * 95) / 100;

            uint256 fees = totalBets - totalRewards;
            feesCollected += fees;

            for (uint256 i = 0; i < numOfWinners; i++) {
                address winner = bettersOnOpion[currentRoundId][winningOption][
                    i
                ];
                uint256 winnerBetAmount = userBets[currentRoundId][winner];
                uint256 winnerReward = (totalRewards * winnerBetAmount) /
                    totalBetsOnOption[currentRoundId][winningOption];
                userRewardOnRound[winner][currentRoundId] = Reward({
                    amount: winnerReward,
                    claimed: false
                });

                emit RoundWinners(currentRoundId, winner, winnerReward);
            }
            startNewRound();
        }
        emit RoundFinished(currentRoundId, winningOption);
    }

    function claimRoundReward(uint256 rid) external nonReentrant {
        address user = _msgSender();
        require(userBetted[rid][user], "User has not betted on this round");
        require(
            !userRewardOnRound[user][rid].claimed,
            "Reward already claimed"
        );
        require(userRewardOnRound[user][rid].amount > 0, "No reward to claim");

        uint256 reward = userRewardOnRound[user][rid].amount;
        userRewardOnRound[user][rid].claimed = true;
        MyUSDC(tokenAddress).transfer(user, reward);

        emit RewardClaimed(user, rid, reward);
    }

    function claimFees(uint256 amount) external nonReentrant onlyOwner {
        address user = _msgSender();
        require(feesCollected > amount, "Insufficient fee collected");

        feesCollected -= amount;
        MyUSDC(tokenAddress).transfer(user, amount);

        emit FeeClaimed(user, amount);
    }

    function startNewRound() public onlyOwner {
        roundId += 1;
    }

    function getTotalBetsOnRound(uint256 rid) public view returns (uint256) {
        uint256 totalBets = 0;
        for (uint8 i = 0; i < betOptions.length; i++) {
            totalBets += totalBetsOnOption[rid][betOptions[i]];
        }
        return totalBets;
    }

    function getUserRewardOnRound(
        address user,
        uint256 rid
    ) public view returns (uint256) {
        return userRewardOnRound[user][rid].amount;
    }

    function getBetsOnOption(
        uint256 rid,
        uint8 option
    ) public view returns (uint256) {
        return totalBetsOnOption[rid][option];
    }

    function getBetOptions() public view returns (uint8[] memory) {
        return betOptions;
    }

    function getCurrentRound() public view returns (uint256) {
        return roundId;
    }

    function getFeesCollected() public view onlyOwner returns (uint256) {
        return feesCollected;
    }
}
