# Changelog

- midway-v1 rework in progress. Fresh graph: `MidwayBuyer`, `MidwayRegistry`, `FwaEngineV1`,
  `RewardVault`, `RewardSplitter`, and `SharedUpside` are rewritten or changed; `AssetPolicy`,
  `FwaConversionFloor`, `FwaPriceFloor`, `ReferralRewards`, and the batch account infrastructure are
  removed from the launch graph. `midway-v0.1` moves to retired, superseded before third-party use.
  Not yet deployed; see [Deployments](reference/deployments.md).
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
