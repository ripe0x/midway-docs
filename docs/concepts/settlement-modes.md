# Settlement modes

## Managed settlement

Managed is the default. The application admin chooses ETH or `$FWA` as its prospective Managed
outcome, and every acquisition saves that preference immutably. Anyone may submit the settlement
transaction, but a keeper or public caller cannot change the outcome, price bound, or recipient.

ETH settlement does not depend on Asset Policy, rewards, Shared Upside, prize conversion, or referral
accounting. An optional-module failure does not block ETH or refunds.

For an ETH-default request, `autoResolve` accepts FWA's live ETH bid. For a `$FWA`-default request,
it reads FWAToken's live `buybackSqrtPriceLimitX96`, converts that square-root price into the minimum
token output, accounts for FWA's one-percent buy-hook fee, and calls FWA's normal
`acceptBidAsTokens` path. If the floor cannot be read, FWA disables the route, the pool cannot fully
fill, output misses the floor, or the token transfer fails, Midway accepts the same ETH bid in the
same transaction. Atomic rollback means the failed token attempt cannot consume the listing first.

This is a broad protocol loss bound, not a best-price oracle. Applications do not maintain it. A
five-percent change in the square-root limit represents roughly a 9.75% change in the underlying
price before the one-percent hook fee.

This is `$FWA`-preferred, not `$FWA`-or-nothing. Use Manual mode for a strict token choice or when the
application wants to supply a request-specific absolute `minOut` at settlement time.

## Account-selected $FWA settlement

The recorded application account may call `acceptBidAsTokens(midwayRequestId, minOut)` while FWA
still gives the purchaser its settlement choice. FWA uses the discounted ETH bid to buy $FWA. The
request-specific `RequestBuyer` measures the tokens actually received and sends them to
`RewardVault`, where Midway credits a pot owned by the recorded account.

The account chooses `minOut`, its minimum acceptable $FWA amount. Passing zero disables this slippage
protection and is not recommended for production transactions.

This account-selected path remains useful even with a Managed `$FWA` default:

- Manual requests can require `$FWA` rather than accepting automatic ETH fallback;
- the account supplies an absolute request-specific `minOut` instead of using FWA's protocol floor;
- a failed or under-minimum token purchase leaves the request unresolved; and
- a Manual request can later switch permanently to Managed while FWA's settlement window remains open.

After a successful token settlement, the account calls `RewardVault.transfer(recipient, amount)` to
withdraw its credited `$FWA`.

## Manual NFT choice

Manual mode preserves the recorded account's choice between $FWA and supported NFT custody. The
application may request NFT delivery only while live `AssetPolicy` permits the collection and delivery
can be positively checked. $FWA settlement does not deliver the NFT to the application and does not
depend on NFT Asset Policy.

A Manual request may permanently switch to Managed. An ETH-only or restricted-asset safety signal may
also open the permissionless ETH path. Midway never accepts third-party payment for an NFT in the
launch design.

## Force-safe ETH delivery

Midway first uses a normal ETH call. If the recipient rejects it, Midway creates a temporary helper
and uses same-transaction `selfdestruct` to transfer the helper's balance to the intended account.

This prevents a reverting recipient from blocking settlement. It also means:

- the recipient's `receive()` function may not run;
- callback-only accounting is unsafe; and
- applications should reconcile Midway events and observed balances.
