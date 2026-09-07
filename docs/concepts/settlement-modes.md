# Settlement modes

## Managed settlement (ETH only)

Managed settlement pays ETH and needs no price. `settleForEth(midwayRequestIds)` accepts FWA's live
depositor bid and pays the recorded account. It is permissionless: the payout target was snapshotted
at acquisition, so a permissionless caller advances the request and never chooses a recipient.

Every application's default is set with `MidwayRegistry.setDefaultAutoSettleEth(applicationId, bool)`
and snapshotted into each request at acquisition, or overridden per request with
`acquire(bool autoSettleEth)`. When `autoSettleEth == true`, Midway's keeper (or any other caller)
drives the request to ETH with no further input from the application. When it is `false`, only the
account or its operator can move the request, through `settleForFwat` or `deliverNFT`.

`autoResolve` and `settleForEth` read no price and cannot revert on price. An optional-module
failure, such as a Shared Upside recording error, never blocks ETH settlement or a refund.

## Account-selected $FWA settlement

The recorded account or its operator calls `settleForFwat(midwayRequestId, minOut)` while FWA still
gives the purchaser its settlement choice:

```solidity
uint256 amount = midwayBuyer.settleForFwat(midwayRequestId, minOut);
```

This is a swap, so it needs a slippage bound, and the account supplies its own `minOut`. FWA's
discounted ETH bid buys $FWA; the request's `RequestBuyer` measures the tokens actually received and
deposits them into the application's `RewardVault` pot. `RewardVault.payout` then moves that pot to
the recipient the registry names.

Midway never settles for $FWA on a permissionless caller's behalf: a settlement Midway drives reads
no price, and a token swap needs a slippage bound that belongs to whoever bears the slippage. An
application that wants $FWA calls `settleForFwat` itself, or takes ETH and buys $FWA on its own
terms.

`settleForFwat` reverts `FwatSettlementUnavailable` when `RewardVault` is not currently a FWAToken
distributor, instead of surfacing FWAToken's bare transfer-lock error. Check
`readiness(account).distributorGranted` before calling it.

## NFT delivery

The account or its operator calls `deliverNFT(midwayRequestId, to)` to deliver the request's NFT,
whether it came from a fulfilled allocation or from a recovered forced or stuck outcome:

```solidity
(bool allowed, KeepDenialReason reason) = midwayBuyer.canDeliverNFT(midwayRequestId);
```

Check `canDeliverNFT` before committing to delivery. The engine's delivery rule is inline: FWA's own
token-pack collections always settle for ETH since their contents are $FWA, and any other collection
is deliverable unless a gas-bounded `transfersRestricted()` probe reports it restricted. A restricted
collection forces ETH settlement instead.

## Force-safe ETH delivery

Every ETH path uses `forceSafeTransferETH`. Midway tries a normal call first; if the recipient
rejects it, Midway force-transfers the balance to the intended account in the same transaction. This
means:

- the recipient's `receive()` function may not run;
- callback-only accounting is unsafe; and
- applications should reconcile Midway events and observed balances.
