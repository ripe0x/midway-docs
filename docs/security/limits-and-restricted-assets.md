# Limits and restricted assets

## Limits

- Midway cannot guarantee ETH forever. FWA's purchaser-only window can end. After that a depositor
  or public finalizer may exchange the ETH backstop for an NFT, and no downstream contract can
  recreate that ETH. Midway records the resulting forced ETH, forced NFT, stuck NFT, or unknown
  custody accurately and never reports an NFT incident as ETH settlement.
- FWA can disable token settlement. Account-selected $FWA settlement (`settleForFwat`) works only
  while the request is still allocated inside FWA's purchaser-only window.
- $FWA settlement needs a slippage bound. Midway never derives one on a permissionless caller's
  behalf; the account or its operator supplies its own `minOut`. The one exception is the accrued
  reward claim, whose bound is a constant applied to live pool spot inside the engine, sized for a
  per-request cap of about 0.002 ETH.
- A keeper improves availability. It is never trusted with payout addresses. Any caller may perform
  permissionless lifecycle work.
- The engine's delivery rule can deny manual NFT delivery for a restricted collection at any time.
- ERC-721 collections can revert, claim success without moving the NFT, report a false owner, or
  change behavior later. The engine proves ownership before transferring, which reduces risk and
  cannot make a malicious collection honest.
- A randomness coordinator can delay a Shared Upside draw. It cannot change saved weights or the
  payout.
- Application deposits, user balances, games, and award distribution are the application's
  responsibility.

## Pause and failure matrix

| Failure or action | New acquisitions | Historical exits |
|---|---|---|
| Acquisitions pause | blocked | continue |
| Curated application removed | future account acquisitions blocked | continue |
| Open access effective | all registered applications admitted | unchanged |
| New engine activated | uses the new engine | saved old engine continues, exit only |
| Registry recipient or `autoSettleEth` default change | future snapshots only | saved routes unchanged |
| Delivery rule denies a collection | manual NFT delivery denied, forces ETH | ETH and refunds continue |
| $FWA settlement disabled or slips | `settleForFwat` reverts | ETH settlement path unaffected |
| Shared Upside activity failure | activity outbox waits, retryable | ETH and refunds continue |
| Reward claim or payout failure | claim or payout waits, retryable | ETH and refunds continue |
| Keeper offline | no automatic progress | any caller may act |
| Randomness missing | activated cycle waits and retries | requests unaffected |

## Restricted assets

Unsupported means unsupported for NFT delivery. It does not restrict acquisition or ETH or $FWA
settlement.

Two collections are ETH only at launch, hardcoded as constants in the engine because their contents
are $FWA and delivering the wrapper instead of the ETH is not an outcome an application wants:

| Collection | Address |
|---|---|
| Locked FWA Token Packs | see [Deployments](../reference/deployments.md) |
| FWA Token Packs | see [Deployments](../reference/deployments.md) |

Every other collection is deliverable unless a gas-bounded `transfersRestricted()` probe on the
collection conclusively reports restrictions, in which case delivery is denied and ETH settlement is
forced instead. A probe that reverts, returns the wrong width, or returns a non-boolean word counts
as unrestricted. `canDeliverNFT` answers this before the application commits to delivery.

Managed ETH settlement never depends on the delivery rule.
