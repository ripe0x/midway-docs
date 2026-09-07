# Request lifecycle

## The real FWA timeline

After allocation, the purchaser initially controls the choice between keeping the NFT, accepting the
depositor's ETH bid, or accepting the bid as $FWA.

FWA source defaults currently use:

- `settlementWindow`: 24 hours; and
- `finalizeWindow`: 7 days.

Both values are live mutable FWA configuration. `requestStatus` returns the actual deadlines for
each request (`settlementDeadline`, `finalizeDeadline`), derived from FWA inside the engine.
Applications and keepers should read those fields instead of hard-coding 24 hours or 7 days.

After `settlementWindow`:

- `depositorReclaimNFT` returns the NFT to the depositor and pays discounted backing ETH to the
  purchaser; or
- `depositorReclaimBacking` returns backing to the depositor and sends the NFT to the purchaser.

After `finalizeWindow`, anyone may finalize FWA's default NFT-to-purchaser outcome.

Midway cannot guarantee ETH after the purchaser-only settlement window. Once FWA has exchanged the
ETH backstop for an NFT, no downstream contract can recreate that ETH.

## Fulfillment and settlement are separate transactions

Contracts do not execute automatically. FWA fulfillment makes a result available; a later transaction
must synchronize and settle it. `syncRequest` reads FWA state and advances the Midway state;
`autoResolve` drives a request to its terminal outcome without reading any price.

A healthy Midway deployment should settle a fulfilled request within minutes. The full FWA window is
disaster-recovery headroom, not a planned waiting period. Missing it indicates a serious keeper, RPC,
indexer, chain, configuration, FWA-compatibility, or contract incident.

## What can happen

| FWA or Midway result | What Midway does | Application result |
|---|---|---|
| Pending | Waits for FWA processing | No final payment yet |
| Fulfilled, `autoSettleEth == true` | Anyone calls `settleForEth`, accepting the live FWA ETH bid | ETH pushed to the recorded account |
| Fulfilled, `autoSettleEth == false` | The account or its operator chooses `settleForFwat(id, minOut)` or `deliverNFT(id, to)` | $FWA credited to the application's `RewardVault` pot, or the NFT delivered to the named address |
| Refunded | `withdrawRefunds` sends the fee-reserve refund | Full refund; no Midway fee |
| FWA forced outcome | `recoverForcedOutcome` classifies it and records an incident | ETH recovered directly, or the NFT recovered for delivery through `deliverNFT` |
| Stuck NFT | `recoverStuckNFT` recovers it into the incident record | NFT delivery through `deliverNFT` once recovered |
| Unknown custody | Preserves what can be proven and records an incident | No false ETH or NFT guarantee |

`nextAction(midwayRequestId)` returns the single action a caller should take on a request right now,
so neither an application nor its keeper needs to hold a copy of this table.
