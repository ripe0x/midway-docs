# What Midway is

[FWA](https://fwa.fun) is an on-chain protocol where a purchaser pays for a randomly selected,
NFT-backed position. The result arrives later. A request can fulfill, expire, or refund, and a
fulfilled purchaser may receive ETH, $FWA, or an NFT.

Midway is the application layer for FWA. An application does three things and Midway does the rest:

1. **Register.** One transaction: `MidwayRegistry.registerApplication(recipient, referrer, account)`.
   When `account` is the caller, the binding is immediate.
2. **Fund.** One transaction per acquisition: `MidwayBuyer.acquire()` with at least
   `quoteAcquisition().totalRequired` attached. The quote is read inside the call and any ETH above
   it returns to the caller in the same transaction.
3. **Receive.** ETH proceeds and refunds are pushed to the account with no action from the
   application. $FWA is delivered by `RewardVault.payout`, callable by the application admin, the
   account, or the account's operator.

An application never learns FWA's vocabulary, chooses an FWA-side fee cap, derives a payment pad, or
discovers which engine holds a request. It never writes a keeper: every lifecycle action is
permissionless, and `nextAction` tells any caller what to do next.

Midway provides two products:

- **Managed settlement:** the request settles for ETH with no price input. Anyone may drive it; the
  payout target was fixed at acquisition and no permissionless caller can redirect it.
- **Shared Upside:** a share of every application's $FWA purchaser rewards funds a recurring draw
  among the applications that acquired since launch.

Your application still decides how users deposit, how balances are tracked, who owns each request,
and what happens with a $FWA payout or a Shared Upside award. Midway does not define your game,
vault, pool, round, or treasury rules.

## The lifecycle in one table

| Concept | What happens | Who receives the result? |
|---|---|---|
| ETH settlement | `settleForEth` accepts FWA's depositor bid | The request's recorded account |
| $FWA settlement | The account or its operator calls `settleForFwat(id, minOut)` | The application's `RewardVault` pot, paid out to the recipient the registry names |
| NFT delivery | The account or its operator calls `deliverNFT(id, to)` when `canDeliverNFT` allows it | The address the caller names |
| Forced or stuck outcome | The keeper recovers it into the request's incident record | Delivered through the same `deliverNFT` path once recovered |
| Force-safe ETH delivery | Midway pays normally first; if the recipient rejects it, a temporary helper force-transfers it in the same transaction | The intended account still receives the ETH |

Force-safe delivery does not execute the recipient's `receive()` function. Applications must
reconcile Midway events and actual ETH balances instead of relying only on callbacks.
