# Operator powers

Midway launches without timelocks. Each authority is a multisig. Every lever below is forward only: it changes future requests or future cycles, never a request that already exists.

## Authorities

| Authority | Controls | Transfer |
|---|---|---|
| Midway owner | MidwayBuyer, RewardVault, ReferralRewards, SharedUpside, ChainlinkVrfAdapter | two step per contract |
| Registry operator | MidwayRegistry, RewardSplitter split and treasury address, FwaConversionFloor settings, the conversion floor pointer | two step |
| Asset policy operator | AssetPolicy | two step |
| Application admin | one application's accounts and status inside MidwayRegistry | two step, per application |

Current addresses are on the [Deployments](../reference/deployments.md) page.

## What each authority can change

| Lever | Call | Authority | Scope and cap |
|---|---|---|---|
| New acquisitions | `MidwayBuyer.setAcquisitionsPaused(bool)` | Midway owner | Blocks new requests. Every historical exit, refund, and settlement keeps working. |
| Active engine | `MidwayBuyer.setActiveEngine(address)` | Midway owner | Future requests use the new engine. The displaced engine becomes exit only, permanently. |
| Midway fee | `MidwayBuyer.setMidwayFeeConfig(cfg)` | Midway owner | Future acquisitions only. Hard cap 300 bps. Each request snapshots the fee config at acquisition. |
| Reward split | `RewardSplitter.setSplit(treasuryBps, skimBps)` | Registry operator | Applies at the next harvest. Treasury share capped at 2000 bps, shared-upside share capped at 3000 bps. No timelock. |
| Reward treasury address | `RewardSplitter.setTreasury(address)` | Registry operator | Applies at the next harvest. Nonzero. No timelock. |
| FWAT conversion slippage cap | `FwaConversionFloor.setSlippageCapBps(bps)` | Registry operator | At most 1000. Zero disables the spot leg. No timelock. |
| FWAT conversion observation window | `FwaConversionFloor.setObservationWindowBlocks(blocks)`, `setMinObservations(count)` | Registry operator | Window 8 to 7200 blocks. |
| FWAT conversion absolute floor | `FwaConversionFloor.setFloorRate(rate)` | Registry operator | Zero (off) or at least 1e15 FWAT per ETH, 1e18 scaled. |
| Conversion floor contract | `MidwayRegistry.setConversionFloor(address)` | Registry operator | Points at another FwaConversionFloor. Zero address refuses every engine driven FWAT buy until re set. |
| Shared Upside randomness | `SharedUpside.setVrfConfig(...)` | Midway owner | Coordinator, key hash, subscription. Cannot change saved weights or a completed draw. |
| Asset policy | `AssetPolicy.setPolicy(collection, cfg)` | Asset policy operator | Affects unresolved and future manual NFT delivery only. |
| Depositor ingress | `RewardVault.setDepositor(address, bool)` | Midway owner | Gates future ingress. Held pots are untouched. |
| Application allowlist | `MidwayRegistry.setApplicationAllowed(...)` | Registry operator | Curated launch only. Stops working once open access begins. |

## One way actions

- `MidwayRegistry.scheduleOpenAccess(t)`: once `t` passes, every registered application is admitted and the allowlist can never be used again. There is no cancel.
- `MidwayRegistry.setCycleBoundarySource(address)`: set once.
- Displacing an engine with `setActiveEngine` locks the old engine to exit only.

## What no authority can do

No lever changes an existing request's account, engine, RequestBuyer, saved fee terms, refund, ETH payment, FWAT credit, reward route, or recorded award. Settlement and refunds always pay the recorded application account, never the transaction caller. Optional modules (rewards, referral, Shared Upside) cannot redirect or block ETH or refunds.

## Gaps with no operator halt

- SharedUpside has no pause. Cycle configuration changes take effect next cycle. An in progress cycle's payout cannot be halted. Containment is the acquisition pause plus the randomness re point.
- Attributed pot balances in RewardVault cannot be frozen. The owner can cut off a depositor's future ingress, not an existing pot.
- A compromised application admin key has no protocol level override. Blocking an application account is application admin only.
