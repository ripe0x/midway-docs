# Limits and restricted assets

## Limits

- Midway cannot guarantee ETH forever. FWA's purchaser only window can end. After that a depositor or public finalizer may exchange the ETH backstop for an NFT, and no downstream contract can recreate that ETH. Midway records the resulting forced ETH, forced NFT, stuck NFT, or unknown custody accurately and never reports an NFT incident as ETH settlement.
- FWA can disable token settlement. Account selected FWAT settlement works only while the request is still allocated inside FWA's purchaser only window.
- A FWAT conversion is bounded by the conversion floor, which is the strictest of a spot relative leg, FWAToken's own floor when armed, and an optional operator set absolute rate. A spot relative floor bounds a same block sandwich to the cap times trade size and cannot prevent it. Managed FWAT settlement is opted into per application with that cap as the accepted worst case.
- A keeper improves availability. It is never trusted with payout addresses. Any caller may perform lifecycle work.
- Live asset policy may change an unresolved manual NFT delivery.
- ERC-721 collections can revert, claim success without moving the NFT, report a false owner, or change behavior later. A positive ownership check reduces risk and cannot make a malicious collection honest.
- A randomness coordinator can delay a draw. It cannot change saved weights or the payout.
- Application deposits, user balances, games, and award distribution are the application's responsibility.

## Pause and failure matrix

| Failure or action | New acquisitions | Historical exits |
|---|---|---|
| Acquisition pause | blocked | continue |
| Curated application removed | future account acquisitions blocked | continue |
| Open access effective | all active registered accounts admitted | unchanged |
| New engine activated | uses the new engine | saved old engine continues |
| Registry recipient or managed policy change | future snapshots only | saved routes unchanged |
| Asset policy failure | manual NFT delivery denied | ETH and refunds continue |
| FWA token settlement disabled or slips | explicit account choice reverts | managed FWAT preference falls back to ETH atomically |
| SharedUpside failure | activity outbox waits | ETH and refunds continue |
| Referral credit failure | amount falls back to treasury | ETH and refunds continue |
| Reward failure | optional work waits | ETH and refunds continue |
| Keeper offline | no automatic progress | any caller may act |
| Randomness missing | activated cycle waits and retries | requests unaffected |

## Restricted assets

Unsupported means unsupported for manual NFT delivery. It does not restrict acquisition, managed ETH settlement, or FWAT settlement.

Two collections are ETH only at launch because their transfer restrictions previously made forced custody delivery fail:

| Collection | Address |
|---|---|
| Locked FWA Token Packs | see [Deployments](../reference/deployments.md) |
| FWA Token Packs | see [Deployments](../reference/deployments.md) |

Every other collection is denied manual NFT delivery until the live asset policy approves it. A collection is denied when it is explicitly ETH only, when its bounded `transfersRestricted()` probe conclusively reports restrictions, or when it has not been approved. A failed or unclear probe is not evidence that delivery is safe.

Managed ETH never depends on the NFT allowlist. Manual delivery is default deny and needs current policy approval plus a positive delivery check.
