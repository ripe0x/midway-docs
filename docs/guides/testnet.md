# Testnet

Midway v1 is deployed on Ethereum Sepolia since 2026-09-08. Do not send real funds to Sepolia
contracts, and do not reuse a Sepolia address in a mainnet transaction. Testnet settings are
deliberately faster and less gated than the mainnet configuration so builders can exercise the full
lifecycle.

| Item | Value |
|---|---|
| Network | Ethereum Sepolia (`11155111`) |
| Status | Deployed and unpaused. Open access: any registered application may acquire. |
| Addresses | Sepolia section on [Deployments](../reference/deployments.md) |
| FWA testnet | [FWA testnet documentation](https://www.fwa.fun/docs/testnet) |
| Public RPC | `https://ethereum-sepolia-rpc.publicnode.com` or `https://sepolia.gateway.tenderly.co` |

## How Sepolia differs from mainnet

- **Access is open.** `MidwayRegistry.scheduleOpenAccess` ran at deployment, so
  `registerApplication` is the only step before `acquire`. No operator allowlisting.
- **$FWA legs work.** `RewardVault` is already a FWAToken distributor, so `settleForFwat`,
  `claimEpochRewards`, `claimAccruedRewards` and `payoutRewards` all move tokens. Check
  `readiness(account).distributorGranted` anyway; it is the same read you will make on mainnet.
- **Shared Upside cycles are 5 minutes** with draws off, so activity records and the cycle ledger can
  be watched quickly. Enabling draws is an owner action.
- **FWA Sepolia is small and cheap.** A handful of listings, a pool fee around 0.0034 ETH and a VRF
  fee that depends on gas price (about 0.001 ETH at 2 gwei). Odds on any one listing are therefore
  far higher than on mainnet; do not read economics from it. FWA Sepolia's settlement window is 24
  hours and its finalize window 7 days, versus 1 hour and 1 hour on mainnet at the time of writing.
  Its deposit whitelist is disabled, so any ERC721 can be listed.
- **Chainlink VRF is live.** A Sepolia acquisition settles through the real coordinator, usually within
  a minute or two. Read `requestStatus(id).state` until it leaves `Pending`.

## Walkthrough

1. Register: `MidwayRegistry.registerApplication(rewardRecipient, address(0), account)` from the
   account itself so it binds immediately. A contract account should do this from its own code so it
   is also the application admin (see [Application admin](application-admin.md)).
2. Quote and acquire: `MidwayBuyer.quoteAcquisition()` at a real gas price (the VRF leg prices off
   `tx.gasprice`; an `eth_call` at gas price 0 omits it), then `acquire(false)` with a few percent
   above `totalRequired`; the excess returns in the same call.
3. Wait for the draw, then settle: `settleForEth([id])` (anyone), or `deliverNFT(id, to)` from the
   account. Budget gas from an estimate: a delivery that also triggers downstream work in your
   contract can need several million gas.

A complete v1 application, Shape Chase, runs on this graph as application 1. Its first request was
resolved end to end through live FWA and Chainlink VRF on the deployment day.
