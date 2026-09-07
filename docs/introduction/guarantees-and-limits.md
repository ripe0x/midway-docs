# Guarantees and limits

## What Midway does not do

Midway v1 excludes:

- NFT auctions, an Opportunity Market, or general price discovery;
- third-party paid NFT delivery or paid incident sales;
- weekly sponsorship;
- reward callbacks;
- referral trees or user-level referral attribution (the referrer field is recorded, not paid);
- lending, credit, leverage, or a governance token;
- arbitrary plugins, arbitrary external calls, or delegatecall modules; and
- a complete `IFWA` storage or getter replacement.

## Request guarantees

For every accepted request:

- the account, applicationId, engine, `RequestBuyer` clone, referrer, fee rate, fee recipient, and
  `autoSettleEth` are frozen at acquisition and never change;
- ETH settlement and refunds pay the recorded account, never the transaction caller;
- $FWA payout resolves its recipient from registry state at payout time, never from a caller
  argument;
- an acquisitions pause blocks new requests only; every historical exit, refund, and settlement
  keeps working;
- a new active engine changes only future requests; the displaced engine stays exit only,
  permanently;
- Shared Upside activity recording is an outbox with a permissionless retry, and its failure never
  blocks a settlement or a refund; and
- no permissionless call reads a pool price except the accrued-reward claim, whose bound is a
  constant applied to spot inside the engine.

## Honest limitation

Midway cannot guarantee ETH forever. FWA's live purchaser-only window can end, after which a
depositor or public finalizer may exchange the ETH backstop for an NFT. No downstream contract can
recreate that ETH after the FWA transition.

Midway operates immediately and records the resulting forced ETH, forced NFT, stuck NFT, or unknown
custody accurately. It does not describe an NFT incident as successful ETH settlement.

See [Limits and restricted assets](../security/limits-and-restricted-assets.md) for the full pause
and failure matrix and the current restricted-asset list.
