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
active immutable FwaEngineV1 -> one RequestBuyer -----> pinned FWA version
       |                              |
       |                              +---- request refund / forced ETH / NFT
       |
       +---- fixed RewardSplitter ----> RewardVault (application pot)
       |                          +--> SharedUpside pot ----> application award balance
       |                          +--> protocol treasury (reward split share)
       +---- protocol treasury (Midway fee)
```

- **MidwayBuyer** is the stable public address and the only address an integrator indexes.
- **FwaEngineV1** is an immutable integration for one FWA and module version, including the inline
  NFT delivery rule (two constants and one probe, no policy contract).
- **RequestBuyer** is the direct FWA purchaser for exactly one request.
- **MidwayRegistry** records self-service applications, accounts, recipients, referrers, account
  operators, and launch access.
- **RewardVault** holds $FWA in a pot per application and pot kind, paid out by the permissionless
  `payout`.
- **RewardSplitter** splits application purchaser rewards three ways at harvest: treasury, Shared
  Upside, and the application. The Shared Upside share is the only source of the Shared Upside pot;
  the Midway ETH fee goes to treasury in full.
- **SharedUpside** records spend weight and recurring awards. Draws start off; the owner enables them
  once with `enableDraws()`.
- **ChainlinkVrfAdapter** routes Shared Upside's randomness requests.

There is no separate Kernel. `MidwayBuyer` owns the active-engine and fee configuration for new
requests. Activating a new engine marks the old one exit-only. Every historical request continues to
route to the engine saved when it was acquired.

## Why every request gets its own RequestBuyer

FWA can push ETH or record a refund without including a request ID in the transfer. A shared
purchaser account would need ordering and balance guesses to decide which request owns the value.

One `RequestBuyer` per request makes the refund credit, forced ETH, NFT, stuck-recipient record, fee
reserve, and FWA purchaser rewards belong to exactly one request by construction. No request's stuck
NFT, failed token buy, or hostile collection can reach another request's ETH.

## Historical compatibility

`MidwayBuyer` is not a complete `IFWA` getter or storage replacement. It is a fresh graph: v1 is not
a storage-compatible upgrade of `midway-v0.1`, which is retired, superseded before third-party use.
There is nothing to migrate; no v0.1 acquisition was ever made.

New FWA incompatibility is handled by activating a new immutable engine and `RequestBuyer`
implementation for future activity. Old engines retain permissionless historical exits.

## Before production

Midway v1 requires, before the graph is unpaused:

- the FWAToken owner granting the v1 `RewardVault` distributor status;
- the v1 `ChainlinkVrfAdapter` registered on the VRF subscription and the v0.1 adapter removed;
- the Shared Upside launch cycle configuration applied and its readback asserted;
- the mainnet keeper profile live on at least two writer cells, confirmed advancing a request end to
  end;
- midway-tester and this documentation site current on the v1 API; and
- a full audit delta on the rewritten and changed contracts.

Midway v1 is not yet deployed. See [Deployments](deployments.md) for current status.
