// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IMidwayRewardVaultExample {
    function transfer(address recipient, uint256 amount) external;
}

/// @notice Small educational award-pot controller for a Shared Upside application.
contract ExampleMidwayAwardRecipient {
    bytes32 public constant AWARD_RECEIVER_ID = keccak256("MIDWAY_AWARD_RECEIVER_V1");

    IMidwayRewardVaultExample public immutable rewardVault;
    address public immutable owner;

    error Unauthorized();
    error ZeroAddress();

    event AwardTokensSent(address indexed recipient, uint256 amount);

    constructor(address rewardVault_, address owner_) {
        if (rewardVault_ == address(0) || owner_ == address(0)) revert ZeroAddress();
        rewardVault = IMidwayRewardVaultExample(rewardVault_);
        owner = owner_;
    }

    function awardReceiverId() external pure returns (bytes32) {
        return AWARD_RECEIVER_ID;
    }

    /// @notice The receiver controls the RewardVault balance attributed to this contract.
    function awardPot() external view returns (address) {
        return address(this);
    }

    /// @notice Example treasury use. A real application may distribute awards with different rules.
    function sendAwardTokens(address recipient, uint256 amount) external {
        if (msg.sender != owner) revert Unauthorized();
        if (recipient == address(0)) revert ZeroAddress();
        rewardVault.transfer(recipient, amount);
        emit AwardTokensSent(recipient, amount);
    }
}
