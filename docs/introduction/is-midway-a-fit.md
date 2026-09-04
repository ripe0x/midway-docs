# Is Midway a fit?

Midway is intended for contract teams building games, treasury products, pooled acquisition systems,
vaults, or other products on top of FWA.

It is a good fit when:

- the normal result should be ETH, with an optional account-controlled $FWA or supported-NFT choice;
- you want every FWA request isolated from every other request;
- you do not want to rebuild refund, deadline, forced-outcome, and reward operations; and
- Shared Upside adds value for your users, treasury, or community.

It may not be a good fit when:

- your product must be the direct FWA purchaser itself;
- it requires Manual NFT delivery from a collection Midway does not currently support;
- it cannot tolerate immediate operator changes to future configuration; or
- it needs a complete storage-compatible replacement for every FWA getter.

The simplest application uses one treasury contract as its Midway account and chooses Managed
settlement for every request.
