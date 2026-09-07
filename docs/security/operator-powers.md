# Operator powers

Midway launches without timelocks. Each authority is a multisig. Every lever below is forward only:
it changes future requests or future cycles, never a request that already exists.

## Authorities

| Authority | Controls | Transfer |
|---|---|---|
| MidwayBuyer owner | `setActiveEngine`, `setMidwayFeeConfig`, `setAcquisitionsPaused`, rescue functions | two step |
| RewardVault owner | `setDepositor`, `sweepUnattributed` | two step |
| SharedUpside owner | `enableDraws`, `setVrfConfig`, `scheduleCycleConfig` | two step |
| ChainlinkVrfAdapter owner | VRF request routing | two step |
| Registry operator | `MidwayRegistry.setApplicationAllowed`, `scheduleOpenAccess`; `RewardSplitter.setSplit`, `setTreasury` | two step |
| Application admin | one application's status, recipients, default settlement, and accounts inside `MidwayRegistry` | two step, per application |

Current addresses are on the [Deployments](../reference/deployments.md) page. Each authority above
is a separate two-step role even where the same multisig holds several of them at launch.

## What each authority can change

| Lever | Call | Authority | Scope and cap |
|---|---|---|---|
| New acquisitions | `MidwayBuyer.setAcquisitionsPaused(bool)` | MidwayBuyer owner | Blocks new requests. Every historical exit, refund, and settlement keeps working. |
| Active engine | `MidwayBuyer.setActiveEngine(address)` | MidwayBuyer owner | Future requests use the new engine. The displaced engine becomes exit only, permanently. Runs full engine validation (id, `midwayBuyer`, `registry`, same graph). |
| Midway fee | `MidwayBuyer.setMidwayFeeConfig(cfg)` | MidwayBuyer owner | Future acquisitions only. Hard cap 300 bps, and cannot exceed the active engine's `maxMidwayFeeBps()`. Each request snapshots the fee config at acquisition. |
| Reward split | `RewardSplitter.setSplit(treasuryBps, skimBps)` | Registry operator | Applies at the next harvest. Treasury share capped at `MAX_TREASURY_BPS` 2000 bps, Shared Upside share capped at `MAX_SKIM_BPS` 3000 bps. No timelock. |
| Reward treasury address | `RewardSplitter.setTreasury(address)` | Registry operator | Applies at the next harvest. Nonzero. No timelock. |
| Application allowlist | `MidwayRegistry.setApplicationAllowed(id, bool)` | Registry operator | Curated launch only. Stops working once open access begins. |
| Open access schedule | `MidwayRegistry.scheduleOpenAccess(effectiveAt)` | Registry operator | Plain future timestamp, no relation to any Shared Upside cycle boundary. One way, once. |
| Shared Upside draws | `SharedUpside.enableDraws()` | SharedUpside owner | One way. Schedules the first close at the next cycle boundary; that close pays out every activity recorded since launch. |
| Shared Upside cycle config | `SharedUpside.scheduleCycleConfig(cfg)` | SharedUpside owner | `payoutBps` and `vrfRetryDelay` for a future cycle. Cannot change a saved past cycle. |
| Shared Upside randomness | `SharedUpside.setVrfConfig(...)` | SharedUpside owner | Coordinator, key hash, subscription. Cannot change saved weights or a completed draw. |
| RewardVault depositor allowlist | `RewardVault.setDepositor(address, bool)` | RewardVault owner | Gates future ingress. Held pots are untouched. |

## One-way actions

- `SharedUpside.enableDraws()`: once called, draws stay on forever. There is no disable.
- `MidwayRegistry.scheduleOpenAccess(t)`: once `t` passes, every registered application is admitted
  and the allowlist can never be used again. There is no cancel.
- Displacing an engine with `setActiveEngine` locks the old engine to exit only.

## What no authority can do

No lever changes an existing request's account, engine, `RequestBuyer`, saved fee terms, referrer, or
`autoSettleEth`. ETH settlement and refunds always pay the recorded account, never the transaction
caller. $FWA payout always resolves its recipient from registry state at call time, never from a
caller argument. Optional modules (Shared Upside activity recording) cannot redirect or block ETH or
refunds.

## Gaps with no operator halt

- `SharedUpside` has no pause once draws are enabled. Cycle configuration changes take effect next
  cycle. An in-progress cycle's payout cannot be halted. Containment is the acquisitions pause plus
  the randomness re-point.
- Attributed pot balances in `RewardVault` cannot be frozen. The owner can cut off a depositor's
  future ingress, not an existing pot.
- A compromised application admin key has no protocol-level override. Setting an account's status is
  application admin only.
