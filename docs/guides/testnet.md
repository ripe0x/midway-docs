# Testnet

Midway is deployed on Ethereum Sepolia for integration testing. Do not send real funds to Sepolia
contracts, and do not reuse a Sepolia address in a mainnet transaction. Read the live acquisition
status before testing. Testnet settings are deliberately faster and less gated than the mainnet
configuration so builders can exercise the full lifecycle.

| Item | Value |
|---|---|
| Network | Ethereum Sepolia (`11155111`) |
| Status | Testnet only. Read live contract state before submitting an acquisition. |
| Testnet cadence | Ten-minute Shared Upside cycles. One application and at least 1 wei of qualifying activity can activate a funded cycle. |
| Addresses | See the Sepolia table on the [Deployments](../reference/deployments.md) page. |
| FWA testnet | [FWA testnet documentation](https://www.fwa.fun/docs/testnet) |

The existing FWA mainnet application and the Sepolia contracts are separate deployments. Do not
substitute a Sepolia address into a mainnet transaction.

Two FWA permissions are separate:

- `RewardVault` must be a FWAToken distributor so credited `$FWA` can leave the vault. On Sepolia,
  registration is permissionless through FWA's `FWATokenDistributorOwner.setDistributor(integrationAddress)`.
  On mainnet, the FWA team must review and approve the contract.
- The Sepolia graph also carries a `PrizeReserve` adapter that must be an authorized FWA protocol buyer
  when the FWA hook has external buys closed. The mainnet graph has no PrizeReserve: the whole Midway
  fee goes to treasury and the Shared Upside pot is fed by the reward skim.
