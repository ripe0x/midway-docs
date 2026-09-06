# Overview

This section holds deployment addresses, launch configuration, and the full contract reference. The
[Deployments](deployments.md), [Launch configuration](launch-configuration.md), and
[Contracts](contracts/README.md) pages are generated from release data and are not hand edited.

## Component map

```text
application account
       |
       v
stable MidwayBuyer ----------> stable MidwayRegistry
       |
       v
active immutable Engine -----> one RequestBuyer -----> pinned FWA version
       |                              |
       |                              +---- request refund / forced ETH / NFT
       |
       +---- live AssetPolicy
       +---- fixed RewardSplitter ----> RewardVault (application pot)
       |                          +--> SharedUpside pot ----> application award balance
       |                          +--> protocol treasury (reward split share)
       +---- protocol treasury (Midway fee)
```

An application may use a first-party `MidwayBatchAccount` in the application account position. The
Batch Account adds campaign funding, caps, pacing, and request indexing but receives no special
Engine privilege.

- **MidwayBuyer** is the stable public address and global request-number space.
- **MidwayBatchAccount** is an optional per-application campaign scheduler that submits ordinary
  Midway acquisitions through bounded permissionless cranks.
- **MidwayEngine** is an immutable integration for one FWA and module version.
- **RequestBuyer** is the direct FWA purchaser for exactly one request.
- **MidwayRegistry** records self-service applications, accounts, recipients, referrers, and launch access.
- **RewardVault** holds $FWA with a separate attributed balance for each owner.
- **RewardSplitter** splits application purchaser rewards three ways at harvest: treasury, Shared Upside, and the application. The Shared Upside share is the only source of the Shared Upside pot on mainnet; the Midway ETH fee goes to treasury in full.
- **FwaConversionFloor** bounds every engine driven $FWA buy with the strictest of a spot relative floor, FWAToken's own floor, and an optional operator floor.
- **SharedUpside** records spend weight and recurring awards.

There is no separate Kernel. `MidwayBuyer` owns the active-Engine and fee configuration for new
requests. Activating a new Engine marks the old one exit-only. Every historical request continues to
route to the Engine saved when it was acquired.

## Why every request gets its own RequestBuyer

FWA can push ETH or record a refund without including a request ID in the transfer. A shared purchaser
account would need ordering and balance guesses to decide which request owns the value.

One `RequestBuyer` per request makes the refund credit, forced ETH, NFT, stuck-recipient record, fee
buffer, and FWA purchaser rewards belong to exactly one request by construction.

## Historical compatibility

The stable `MidwayBuyer` preserves FWA's quote, `acquire(uint256,uint256)`, and
`processAcquisitions(uint256)` shapes where practical. It is not a complete `IFWA` getter or storage
replacement.

New FWA incompatibility is handled by activating a new immutable Engine and RequestBuyer version for
future activity. Old Engines retain permissionless historical exits.

## Before production

Midway still requires:

- completion and freeze of the launch implementation and ABI;
- complete unit, invariant, adversarial, and mainnet-fork verification;
- an external security review of the final deployment commit;
- verified addresses, bytecode, owners, roles, caps, fee settings, and cycle genesis;
- live FWA protocol, $FWA pool, and randomness configuration readbacks;
- redundant keeper, indexer, alerting, and incident-response ownership;
- a published production keeper SLA and deadline alert schedule;
- a limited-value canary launch; and
- a public deployment manifest and current-configuration page.

Midway is deployed on Ethereum mainnet and currently paused. These gates track readiness for
activation, not whether a live deployment exists.
