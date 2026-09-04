# Guarantees and limits

## What Midway does not do

Midway v1 excludes:

- NFT auctions, an Opportunity Market, or general price discovery;
- third-party paid NFT delivery or paid incident sales;
- weekly sponsorship;
- reward callbacks;
- referral trees or user-level referral attribution;
- lending, credit, leverage, or a governance token;
- arbitrary plugins, arbitrary external calls, or delegatecall modules;
- a complete `IFWA` storage or getter replacement; and
- migration of historical launch-candidate `MidwayBuyer` requests into Midway request records.

## Request guarantees

For every accepted request:

- application ID, application account, Engine, `RequestBuyer`, upstream FWA request, mode, award
  recipient, referrer, fee rate, fee split, and fee recipients are immutable;
- Refunded and Expired requests pay no Midway fee and create no Shared Upside weight;
- Fulfilled requests use the same measured FWA debit as fee base and weight base;
- settlement and refunds pay the recorded account, never the transaction caller;
- an acquisition pause does not pause any historical exit;
- a new active Engine changes only future requests;
- existing requests never acquire new behavior retroactively;
- Asset Policy failure may deny NFT delivery but not ETH or refunds; and
- optional reward, referral, reserve, or Shared Upside work cannot redirect ETH or refunds.

## Honest limitation

Midway cannot guarantee ETH forever. FWA's live purchaser-only window can end, after which a
depositor or public finalizer may exchange the ETH backstop for an NFT. No downstream contract can
recreate that ETH after the FWA transition.

Midway operates immediately and records the resulting forced ETH, forced NFT, stuck NFT, or unknown
custody accurately. It does not describe an NFT incident as successful ETH settlement.

See [Limits and restricted assets](../security/limits-and-restricted-assets.md) for the full pause
and failure matrix and the current restricted-asset list.
