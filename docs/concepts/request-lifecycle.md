# Request lifecycle

## The real FWA timeline

After allocation, the purchaser initially controls the choice between keeping the NFT, accepting the
depositor's ETH bid, or accepting the bid as $FWA.

FWA source defaults currently use:

- `settlementWindow`: 24 hours; and
- `finalizeWindow`: 7 days.

Both values are live mutable FWA configuration. Applications and keepers must read the actual values
on-chain instead of hard-coding 24 hours or 7 days.

After `settlementWindow`:

- `depositorReclaimNFT` returns the NFT to the depositor and pays discounted backing ETH to the
  purchaser; or
- `depositorReclaimBacking` returns backing to the depositor and sends the NFT to the purchaser.

After `finalizeWindow`, anyone may finalize FWA's default NFT-to-purchaser outcome.

Midway cannot guarantee ETH after the purchaser-only settlement window. Once FWA has exchanged the
ETH backstop for an NFT, no downstream contract can recreate that ETH.

## Fulfillment and settlement are separate transactions

Contracts do not execute automatically. FWA fulfillment makes a result available; a later transaction
must synchronize and settle it.

A healthy Midway deployment should settle a fulfilled Managed request within minutes. The full FWA
window is disaster-recovery headroom, not a planned waiting period. Missing it indicates a serious
keeper, RPC, indexer, chain, configuration, FWA-compatibility, or contract incident.

## What can happen

| FWA or Midway result | What Midway does | Application result |
|---|---|---|
| Pending | Waits for FWA processing | No final payment yet |
| Fulfilled, Managed with ETH default | Accepts the live FWA ETH bid | Measured ETH proceeds plus unused fee buffer |
| Fulfilled, Managed with $FWA default | Attempts FWA's token bid at FWAToken's live protocol floor, then atomically falls back to ETH on any failure | Measured $FWA vault credit when successful; otherwise ETH |
| Fulfilled, Manual | Waits for the application to choose $FWA, request supported NFT delivery, or switch permanently to Managed | $FWA, NFT, or ETH |
| Refunded | Withdraws the FWA refund | FWA refund plus the full Midway fee buffer; no Midway fee |
| Expired | Finalizes zero qualifying spend | Recoverable FWA value plus the full Midway fee buffer; no Midway fee |
| FWA `ForcedEth` | Recovers forced backing ETH from the request account | ETH paid to the recorded application account |
| Forced or stuck NFT | Records the exact isolated incident and retries supported recovery | NFT delivery when provable, otherwise an incident record |
| Unknown custody | Preserves what can be proven and records uncertainty | No false ETH or NFT guarantee |
