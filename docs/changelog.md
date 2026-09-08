# Changelog

- 2026-09-08, Ethereum Sepolia. First midway-v1 graph on Sepolia, deployed from commit `86d3e152`
  (blocks 11662947 to 11662963) and unpaused at block 11663012. Open access from Unix time
  1788895140; RewardVault is a FWAToken distributor. Shape Chase registered as application 1 and
  resolved a request end to end through live FWA and Chainlink VRF. The earlier Sepolia graph
  (commit `9ccbfb18`) stays retired. See [Testnet](guides/testnet.md) and
  [Deployments](reference/deployments.md).
- 2026-09-08, Ethereum mainnet. Midway v1 deployed from commit `9b8315bb` at blocks 25933616 to
  25933650. Ownership and operator authority were handed off to the Midway admin. The graph remains
  paused, Shared Upside draws remain disabled, and the FWAToken distributor grant for `RewardVault`
  is outstanding. `midway-v0.1` is retired, superseded before third-party use. See
  [Deployments](reference/deployments.md).
- 2026-09-07, Ethereum mainnet. Midway unpaused for acquisitions, under curated access with one
  operator-allowlisted application. `MidwayRegistry.setApplicationAllowed(1, true)`
  ([`0x29058cc4...4a50b`](https://evm.now/tx/0x29058cc47b373ab43bab09c76d055748999b9aa8f3c1a8268819c91cf094a50b?chainId=1),
  block 25926339) then `MidwayBuyer.setAcquisitionsPaused(false)`
  ([`0x2c53f635...03023`](https://evm.now/tx/0x2c53f635ac0592b2f1e5b4d76965b43807e7491d6ffbec6d53b6fa1913303023?chainId=1),
  block 25926395). Access stays curated; the operator allowlists applications. FWAT reward legs
  remain pending the distributor grant.
- midway-v0.1, Ethereum mainnet, deployed 2026-09-06, unpaused since block 25926395. Curated access;
  the operator allowlists applications. FWAT reward legs pending the distributor grant. Adds
  RewardSplitter V2, which splits purchaser FWAT rewards three ways at harvest: treasury, Shared
  Upside, and the application. Supersedes midway-v1-audit-rc11, which was retired before activation.
- midway-v1-audit-rc11, Ethereum mainnet, deployed 2026-09-04 in a paused state. Retired 2026-09-06,
  superseded before activation.
