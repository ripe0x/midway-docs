# Known limitations

These are properties of Midway v1 that builders should design around. None of them is a bug.

1. **ETH is not guaranteed after FWA finalizes to an NFT.** See [Limits](limits-and-restricted-assets.md).
2. **FWAT settlement depends on FWA and on the pool price.** FWA can disable it, and the conversion floor can refuse a buy when the pool has too few observations or the price moved past the cap. A managed FWAT preference falls back to ETH. An explicit account choice reverts, and the account can retry or exit to ETH.
3. **Credited FWAT leaves RewardVault only with FWAToken's distributor permission.** That permission is granted by the FWAToken owner, not by Midway. Until it is granted, FWAT credits accumulate in the vault and cannot be withdrawn.
4. **Shared Upside cycles need Chainlink VRF.** A cycle whose draw is not answered waits and retries. Weights and pot are saved and do not change during the wait.
5. **No timelock on operator levers.** The controls are multisigs and hard caps. See [Operator powers](operator-powers.md).
6. **Liveness depends on FWA's queue and on someone calling.** Midway does not run itself. A keeper is expected, and every lifecycle action is permissionless so any party can step in.
7. **Manual NFT delivery is default deny.** Most collections are ETH only until the asset policy approves them.
8. **Requests are not migrated between engines.** A request keeps the engine it started with. New behavior arrives only with a new engine and only for future requests.
9. **Not included in v1:** NFT auctions or price discovery, paid NFT delivery to third parties, sponsorship, reward callbacks, referral trees, lending or leverage, plugins or delegatecall modules, a governance token.
