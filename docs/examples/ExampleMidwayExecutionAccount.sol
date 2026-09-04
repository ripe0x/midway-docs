// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

enum MidwayResolutionMode {
    Managed,
    Manual
}

interface IMidwayRegistryExample {
    function acceptApplication(uint256 applicationId) external;
}

interface IMidwayBuyerExample {
    function quoteAcquisitionPrice() external view returns (uint256 fee, uint256 vrfFee, uint256 totalRequired);

    function acquire(uint256 maxAcquisitionFee, uint256 minWeightedValue)
        external
        payable
        returns (uint256 midwayRequestId);

    function acquireWithMode(uint256 maxAcquisitionFee, uint256 minWeightedValue, MidwayResolutionMode mode)
        external
        payable
        returns (uint256 midwayRequestId);

    function acceptBidAsTokens(uint256 midwayRequestId, uint256 minOut) external returns (uint256 amount);
}

interface IRewardVaultExample {
    function potOf(address owner) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external;
}

/// @notice Small educational example of an application-owned Midway execution account.
/// @dev Applications still need their own deposit, user-accounting, and access-control design.
contract ExampleMidwayExecutionAccount {
    IMidwayRegistryExample public immutable registry;
    IMidwayBuyerExample public immutable midwayBuyer;
    IRewardVaultExample public immutable rewardVault;
    address public immutable owner;

    uint256 public applicationId;
    mapping(uint256 midwayRequestId => bool createdByThisAccount) public requestCreated;

    error Unauthorized();
    error ZeroAddress();
    error AlreadyRegistered();
    error UnknownRequest();
    error InsufficientPayment();
    error EthTransferFailed();

    event ApplicationAccepted(uint256 indexed applicationId);
    event ManagedRequestCreated(uint256 indexed midwayRequestId, uint256 amountSentToBuyer);
    event ManualRequestCreated(uint256 indexed midwayRequestId, uint256 amountSentToBuyer);
    event FwaSettlementCredited(uint256 indexed midwayRequestId, uint256 amount);
    event EthWithdrawn(address indexed recipient, uint256 amount);
    event FwaWithdrawn(address indexed recipient, uint256 amount);

    constructor(address registry_, address midwayBuyer_, address rewardVault_, address owner_) {
        if (registry_ == address(0) || midwayBuyer_ == address(0) || rewardVault_ == address(0) || owner_ == address(0))
        {
            revert ZeroAddress();
        }
        registry = IMidwayRegistryExample(registry_);
        midwayBuyer = IMidwayBuyerExample(midwayBuyer_);
        rewardVault = IRewardVaultExample(rewardVault_);
        owner = owner_;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert Unauthorized();
        _;
    }

    /// @notice Accepts an invitation previously created by the application admin.
    function acceptMidwayApplication(uint256 applicationId_) external onlyOwner {
        if (applicationId != 0) revert AlreadyRegistered();
        registry.acceptApplication(applicationId_);
        applicationId = applicationId_;
        emit ApplicationAccepted(applicationId_);
    }

    /// @notice Quotes immediately before acquiring, while the owner supplies explicit safety limits.
    function acquireManaged(uint256 maxAcquisitionFee, uint256 minWeightedValue)
        external
        payable
        onlyOwner
        returns (uint256 midwayRequestId)
    {
        (,, uint256 required) = midwayBuyer.quoteAcquisitionPrice();
        if (msg.value < required) revert InsufficientPayment();

        uint256 startingBalance = address(this).balance - msg.value;
        midwayRequestId = midwayBuyer.acquire{value: msg.value}(maxAcquisitionFee, minWeightedValue);
        requestCreated[midwayRequestId] = true;
        emit ManagedRequestCreated(midwayRequestId, msg.value);

        uint256 returnedDuringAcquisition = address(this).balance - startingBalance;
        if (returnedDuringAcquisition != 0) _sendEth(payable(msg.sender), returnedDuringAcquisition);
    }

    /// @notice Uses Manual mode so a permissionless keeper cannot settle in ETH before this account
    /// chooses between $FWA and a supported NFT.
    function acquireManual(uint256 maxAcquisitionFee, uint256 minWeightedValue)
        external
        payable
        onlyOwner
        returns (uint256 midwayRequestId)
    {
        (,, uint256 required) = midwayBuyer.quoteAcquisitionPrice();
        if (msg.value < required) revert InsufficientPayment();

        uint256 startingBalance = address(this).balance - msg.value;
        midwayRequestId = midwayBuyer.acquireWithMode{value: msg.value}(
            maxAcquisitionFee, minWeightedValue, MidwayResolutionMode.Manual
        );
        requestCreated[midwayRequestId] = true;
        emit ManualRequestCreated(midwayRequestId, msg.value);

        uint256 returnedDuringAcquisition = address(this).balance - startingBalance;
        if (returnedDuringAcquisition != 0) _sendEth(payable(msg.sender), returnedDuringAcquisition);
    }

    /// @notice Accepts the request's live FWA bid as at least `minOut` $FWA. Midway credits the
    /// measured output to this contract's RewardVault pot.
    function settleAsFwa(uint256 midwayRequestId, uint256 minOut) external onlyOwner returns (uint256 amount) {
        if (!requestCreated[midwayRequestId]) revert UnknownRequest();
        amount = midwayBuyer.acceptBidAsTokens(midwayRequestId, minOut);
        emit FwaSettlementCredited(midwayRequestId, amount);
    }

    /// @notice Withdraws $FWA already credited to this contract's RewardVault pot.
    function withdrawFwa(address recipient, uint256 amount) external onlyOwner {
        if (recipient == address(0)) revert ZeroAddress();
        rewardVault.transfer(recipient, amount);
        emit FwaWithdrawn(recipient, amount);
    }

    /// @notice Withdraws settlement ETH, refunds, or other ETH owned by the application account.
    function withdrawEth(address payable recipient, uint256 amount) external onlyOwner {
        if (recipient == address(0)) revert ZeroAddress();
        _sendEth(recipient, amount);
        emit EthWithdrawn(recipient, amount);
    }

    function _sendEth(address payable recipient, uint256 amount) private {
        (bool ok,) = recipient.call{value: amount}("");
        if (!ok) revert EthTransferFailed();
    }

    receive() external payable {}
}
