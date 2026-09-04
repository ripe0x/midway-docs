# Fees

## Midway fee

The launch Midway fee is 50 basis points of terminal fulfilled measured FWA spend, hard capped in
code at 300 basis points.

- Fulfilled requests pay from the acquisition-time fee buffer.
- Refunded and expired requests pay no Midway fee.
- Unused buffer returns to the recorded application account.
- The same measured successful spend is used for both fee calculation and Shared Upside weight.

The launch split is 100% to the protocol treasury. The referral share is 0%: the v1 referral rate is
zero.

Testnet values differ. See the [Testnet](../guides/testnet.md) guide.

## Exact fee rules

Let:

- `u` be the raw FWA acquisition fee;
- `v` be the FWA randomness fee;
- `r` be Midway's fee rate in basis points; and
- `B = 10_000`.

The quote is:

```text
midwayFee = floor((u + v) × r / B)
totalRequired = u + v + midwayFee
```

At terminal synchronization:

```text
fulfilled spend = measured FWA debit
charged fee = floor(spend × savedRate / 10_000)

refunded or expired spend = 0
charged fee = 0
```

The fee buffer must always conserve exactly:

```text
net treasury + referral + shared upside + fee refund == original Midway fee reserve
```
