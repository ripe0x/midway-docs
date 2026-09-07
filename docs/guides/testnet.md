# Testnet

Midway v1 is not yet deployed on Ethereum Sepolia. Once deployed, do not send real funds to Sepolia
contracts, and do not reuse a Sepolia address in a mainnet transaction. Read the live acquisition
status before testing. Testnet settings are deliberately faster and less gated than the mainnet
configuration so builders can exercise the full lifecycle.

| Item | Value |
|---|---|
| Network | Ethereum Sepolia (`11155111`) |
| Status | Not yet deployed. See the Sepolia section on [Deployments](../reference/deployments.md). |
| Addresses | See the Sepolia section on [Deployments](../reference/deployments.md) once deployed. |
| FWA testnet | [FWA testnet documentation](https://www.fwa.fun/docs/testnet) |

`RewardVault` must be a FWAToken distributor before credited $FWA can leave it. On Sepolia,
registration is permissionless through FWA's `FWATokenDistributorOwner.setDistributor(integrationAddress)`.
On mainnet, the FWAToken owner reviews and approves the contract. Check
`readiness(account).distributorGranted` on either network before relying on `settleForFwat`.
