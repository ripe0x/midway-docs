// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IMidwayRegistryExample {
    function acceptApplication(uint256 applicationId) external;
    function setAccountOperator(address account, address operator) external;
}

struct AcquisitionQuoteExample {
    uint256 fwaFee;
    uint256 vrfFee;
    uint256 midwayFee;
    uint256 totalRequired;
}

interface IMidwayBuyerExample {
    function quoteAcquisition() external view returns (AcquisitionQuoteExample memory);
    function acquire() external payable returns (uint256 midwayRequestId);
    function acquire(bool autoSettleEth) external payable returns (uint256 midwayRequestId);
}

/// @notice Minimal Midway account contract, reduced to what an account operator cannot cover:
///         accepting the application invitation, calling `acquire`, naming an operator, and
///         receiving pushed ETH. Everything else (`settleForFwat`, `deliverNFT`, `makeManaged`,
///         `RewardVault.payout`) an operator can drive directly against `MidwayBuyer` and
///         `RewardVault` without going through this contract at all.
/// @dev Applications still need their own deposit, user-accounting, and access-control design.
contract ExampleMidwayExecutionAccount {
    IMidwayRegistryExample public immutable registry;
    IMidwayBuyerExample public immutable midwayBuyer;
    address public immutable owner;

    error Unauthorized();
    error ZeroAddress();

    event ApplicationAccepted(uint256 indexed applicationId);
    event RequestCreated(uint256 indexed midwayRequestId, uint256 amountSent);

    constructor(address registry_, address midwayBuyer_, address owner_) {
        if (registry_ == address(0) || midwayBuyer_ == address(0) || owner_ == address(0)) {
            revert ZeroAddress();
        }
        registry = IMidwayRegistryExample(registry_);
        midwayBuyer = IMidwayBuyerExample(midwayBuyer_);
        owner = owner_;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert Unauthorized();
        _;
    }

    /// @notice Accepts an invitation previously created by the application admin. Not needed when
    ///         this contract was passed directly as the account to `registerApplication`.
    function acceptMidwayApplication(uint256 applicationId) external onlyOwner {
        registry.acceptApplication(applicationId);
        emit ApplicationAccepted(applicationId);
    }

    /// @notice Names the address allowed to call the account-only Midway verbs on this account's
    ///         behalf. Account-only: an operator cannot grant itself this power.
    function setOperator(address operator) external onlyOwner {
        registry.setAccountOperator(address(this), operator);
    }

    /// @notice Quotes and acquires in one call, padding the quote and using the application's saved
    ///         settlement default. Excess ETH refunds to this contract inside `acquire` itself.
    function acquire() external payable onlyOwner returns (uint256 midwayRequestId) {
        AcquisitionQuoteExample memory q = midwayBuyer.quoteAcquisition();
        uint256 padded = q.totalRequired * 105 / 100;
        midwayRequestId = midwayBuyer.acquire{value: padded}();
        emit RequestCreated(midwayRequestId, padded);
    }

    /// @notice Withdraws ETH this account received from settlement, a refund, or a fee-reserve
    ///         refund.
    function withdrawEth(address payable recipient, uint256 amount) external onlyOwner {
        if (recipient == address(0)) revert ZeroAddress();
        (bool ok,) = recipient.call{value: amount}("");
        require(ok, "eth transfer failed");
    }

    receive() external payable {}
}
