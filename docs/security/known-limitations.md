# Known limitations

These are properties of Midway v1 that builders should design around. None of them is a bug.

1. **ETH is not guaranteed after FWA finalizes to an NFT.** See [Limits](limits-and-restricted-assets.md).
2. **$FWA settlement depends on FWA and on the account's own slippage bound.** FWA can disable it,
   and `settleForFwat` reverts when the pool cannot fill the account's `minOut`. There is no
   automatic fallback to ETH for an account-driven settlement; the account decides.
3. **Credited $FWA leaves `RewardVault` only with FWAToken's distributor permission.** That
   permission is granted by the FWAToken owner, not by Midway. Until it is granted, $FWA credits
   accumulate in the vault and `settleForFwat` and payout revert.
4. **Shared Upside draws need Chainlink VRF, once enabled.** A cycle whose draw is not answered waits
   and retries. Weights and pot are saved and do not change during the wait. Before `enableDraws`,
   no randomness is requested at all.
5. **No timelock on operator levers.** The controls are multisigs and hard caps. See
   [Operator powers](operator-powers.md).
6. **Liveness depends on FWA's queue and on someone calling.** Midway does not run itself. A keeper
   is expected, and every lifecycle action is permissionless so any party can step in; `nextAction`
   is the authority for what to call.
7. **NFT delivery is denied for a restricted collection.** The engine's inline delivery rule forces
   ETH settlement instead. See [Restricted assets](limits-and-restricted-assets.md).
8. **Requests are not migrated between engines.** A request keeps the engine it started with. New
   behavior arrives only with a new engine and only for future requests.
9. **`enableDraws` is one way.** Once Shared Upside draws are on, there is no owner switch to turn
   them back off.
10. **Not included in v1:** NFT auctions or price discovery, paid NFT delivery to third parties,
    sponsorship, reward callbacks, referral trees, lending or leverage, plugins or delegatecall
    modules, a governance token, and batched account infrastructure (Campaigns is the first-party
    batching product).
