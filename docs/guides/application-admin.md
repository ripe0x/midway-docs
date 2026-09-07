# Application admin

## Settlement objective

There is no intentional delay. Midway's keeper synchronizes and settles a fulfilled request
immediately, normally within minutes. An application does not need to write or run a keeper: every
lifecycle action is permissionless, and `nextAction` is the single authority for what happens next,
so a keeper (Midway's or anyone else's) reads it and holds no separate copy of the state machine.

New acquisitions may be paused while `autoResolve`, `settleForEth`, refunds, forced-outcome recovery,
reward claims, and payouts remain available.

## Permissionless lifecycle actions

An application admin manages the application's record, accounts, and recipients in
`MidwayRegistry`. Every action below is available to any caller, not only the admin or the account:

| Action | Who may call it? | Purpose |
|---|---|---|
| `syncRequest(ids)` | Anyone | Reads FWA state and advances Midway state |
| `autoResolve(ids)` | Anyone | Drives each request to its terminal outcome; reads no price |
| `settleForEth(ids)` | Anyone | Accepts FWA's depositor bid and pays the recorded account |
| `withdrawRefunds(ids)` | Anyone | Sends each finalized request's fee-reserve refund to its account |
| `claimEpochRewards(ids, epochs)` | Anyone | Claims closed-epoch $FWA purchaser rewards into the application pot |
| `claimAccruedRewards(ids, minOut)` | Anyone | Claims accrued $FWA rewards under a spot-derived bound |
| `payoutRewards(applicationIds, kind)` | Anyone | Pays each application's pot to its registry-named recipient |
| `recoverForcedOutcome(ids)` | Anyone | Classifies and records a forced FWA outcome |
| `recoverStuckNFT(ids)` | Anyone | Recovers an NFT stuck on a request's clone |
| `retrySharedUpsideActivity(ids)` | Anyone | Retries a pending Shared Upside activity record |
| `settleForFwat(id, minOut)` | Account or account operator | Settles for $FWA under the caller's own slippage bound |
| `deliverNFT(id, to)` | Account or account operator | Delivers the request's NFT to the named address |
| `makeManaged(id)` | Account or account operator | Sets `autoSettleEth` to true; one way |

"Anyone may call" never means "anyone may choose the recipient." ETH settlement and refunds pay the
account snapshotted at acquisition. $FWA payout resolves its recipient from registry state at call
time. No permissionless caller can redirect either one.
