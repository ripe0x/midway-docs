# Fees

## Midway fee (ETH)

The launch Midway fee is 50 basis points of terminal fulfilled measured FWA spend, hard capped in
code at 300 basis points. The fee model has one leg: the whole charged fee goes to the treasury
recipient.

- Fulfilled requests pay from the acquisition-time fee reserve.
- Refunded requests pay no Midway fee.
- The remainder of the reserve refunds to the recorded account.
- The same measured successful spend is used for both fee calculation and Shared Upside weight.

Testnet values may differ. See the [Testnet](../guides/testnet.md) guide.

### Exact fee rules

Let:

- `u` be the raw FWA acquisition fee;
- `v` be the FWA randomness fee;
- `r` be Midway's fee rate in basis points; and
- `B = 10_000`.

The quote is:

```text
midwayFee = floor((u + v) x r / B)
totalRequired = u + v + midwayFee
```

At terminal synchronization:

```text
fulfilled spend = measured FWA debit
chargedFee = floor(spend x savedRate / 10_000)
refund = reserve - chargedFee

refunded spend = 0
chargedFee = 0
refund = reserve
```

The fee reserve conserves exactly: `chargedFee + refund == reserve`, and the engine reverts when
`chargedFee > reserve`.

## Purchaser reward split ($FWA)

FWA purchaser rewards are claimed per request, then split at harvest by `RewardSplitter` into the
application's pot on `RewardVault`. The launch split is 10% treasury, 25% Shared Upside, and the
65% remainder to the application. The registry operator can change the treasury and Shared Upside
shares together with `setSplit(treasuryBps, skimBps)`, bounded independently by `MAX_TREASURY_BPS`
(2,000 basis points, 20%) and `MAX_SKIM_BPS` (3,000 basis points, 30%). The operator can also repoint
the treasury pot address with `setTreasury`. Both bps values are read live at harvest, so a change
applies to any request not yet harvested.

`payoutRewards` and `RewardVault.payout` are permissionless: the recipient is resolved from registry
state at call time, so an application does nothing to be paid once the pot has a balance. `payout`
moves the pot to `purchaserRewardRecipientOf(applicationId)` or `sharedUpsideAwardRecipientOf(applicationId)`,
read at the moment of payout.

`RewardVault` must be added to the FWAToken distributor allowlist before any $FWA can leave it. On
mainnet, the FWAToken owner reviews and grants that status. Until it is granted, $FWA credits
accumulate in the vault and `settleForFwat` reverts `FwatSettlementUnavailable`.
