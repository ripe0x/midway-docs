# Is Midway a fit?

Midway is intended for contract teams building games, treasury products, pooled acquisition systems,
vaults, or other products on top of FWA.

It is a good fit when:

- the normal result should be ETH, with an optional account-driven $FWA settlement or NFT delivery;
- you want every request isolated from every other request;
- you do not want to rebuild FWA's deadlines, refunds, forced-outcome handling, or reward claims; and
- Shared Upside adds value for your users, treasury, or community.

It may not be a good fit when:

- your product must be the direct FWA purchaser itself;
- it needs NFT delivery from a collection the engine's delivery rule denies (section on
  [restricted assets](../security/limits-and-restricted-assets.md));
- it cannot tolerate the operator's forward-only configuration changes; or
- it needs a complete storage-compatible replacement for every FWA getter.

The simplest application uses one contract as its Midway account, calls `acquire()` for every
request, and lets Midway's keeper drive settlement to ETH.
