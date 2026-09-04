# What Midway is

[FWA](https://fwa.fun) is an on-chain protocol where a purchaser pays for a randomly selected,
NFT-backed position. The result arrives later. A request can fulfill, expire, or refund, and a
fulfilled purchaser may receive ETH, $FWA, or an NFT.

Midway is the application layer for FWA. An application buys through one stable `MidwayBuyer`
address. Midway isolates each request, operates the FWA lifecycle, normally turns fulfilled
positions into ETH, and pays the result to the application account recorded when the request began.

Midway provides two products:

- **Managed Settlement:** applications receive the resolved economic result without rebuilding FWA
  deadlines, refunds, ETH acceptance, forced outcomes, restricted-asset handling, or reward claims.
- **Shared Upside:** successful Midway activity receives weight in a recurring cross-application
  $FWA award funded by part of FWA purchaser rewards.

Your application still decides how users deposit, how balances are tracked, who owns each request,
and what happens if the application wins an award. Midway does not define your game, vault, pool,
round, or treasury rules.

## The lifecycle in one table

These five ideas sound similar but describe different actions:

| Concept | What happens | Who receives the result? |
|---|---|---|
| Managed ETH settlement | Midway accepts the depositor's ETH bid | The request's recorded application account receives ETH |
| Account-selected $FWA settlement | The application accepts the same bid as $FWA before FWA's purchaser-only window closes | The recorded account receives a measured `RewardVault` credit |
| Manual NFT choice | The application chooses to keep an NFT while the collection is supported | The application chooses the NFT recipient |
| FWA `ForcedEth` outcome | After the purchaser-only window, the depositor reclaims the NFT and FWA pays discounted backing ETH | The request-specific `RequestBuyer`, which forwards the ETH to the application account |
| Force-safe ETH delivery | Midway pays normally first; if the recipient rejects ETH, a temporary helper force-transfers it in the same transaction | The intended application account still receives the ETH |

Force-safe delivery does not execute the recipient's `receive()` function. Applications must
reconcile Midway events and actual ETH balances instead of relying only on callbacks.
