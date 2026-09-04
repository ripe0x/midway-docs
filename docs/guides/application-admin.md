# Application admin

## Settlement objective

There is no intentional monitoring delay. Midway should synchronize and settle immediately after FWA
fulfillment, normally within minutes.

Production operation requires:

- redundant event-driven keepers;
- direct state polling so missed events do not become missed settlements;
- multiple RPC providers;
- permissionless fallback callers;
- deadline warnings and pages calculated from live FWA configuration;
- monitoring of old exit-only Engines as well as the current Engine; and
- a published keeper service level and alert schedule before launch.

New acquisitions may be paused while processing, Managed settlement and ETH fallback, refunds,
forced recovery, reward harvesting, activity retry, cycle checkpointing, randomness retry, and award
claims remain available.

## Permissionless lifecycle actions

An application admin manages the application's record, accounts, and recipients in `MidwayRegistry`.
Every action below is available to any caller, not only the admin:

| Action | Who may call it? | Purpose |
|---|---|---|
| `processAcquisitions(maxCount)` | Anyone | Process a bounded number of FWA requests |
| `syncRequest(midwayRequestId)` | Anyone | Copy FWA state and finalize Midway accounting |
| `autoResolve(midwayRequestId)` | Anyone | Execute the saved ETH or $FWA-first Managed policy |
| `acceptBidAsTokens(id, minOut)` | Recorded account | Accept the live FWA bid as measured $FWA credited to its vault pot |
| `withdrawRefunds(ids)` | Anyone | Send exact refunds to their recorded accounts |
| `recoverForcedOutcome(id)` | Anyone | Classify and recover a forced FWA outcome |
| `recoverStuckNFT(id)` | Anyone | Retry a recorded FWA stuck-NFT delivery |
| `retrySharedUpsideActivity(id)` | Anyone | Retry Shared Upside recording after a temporary failure |
| `claimEpochRewards` | Request account | Claim closed-epoch FWA purchaser rewards to their saved route |
| `claimAccruedRewards` | Recorded account | Convert accrued purchaser rewards using the account's `minOut` |
| `optIntoManaged(id)` | Recorded account | Permanently change a Manual request to Managed |
| `keepNFTTo(id, recipient)` | Recorded account | Request supported NFT delivery |

"Anyone may call" never means "anyone may choose the recipient." Request ownership and payouts were
fixed at acquisition.
