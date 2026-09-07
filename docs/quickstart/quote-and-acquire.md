# Quote and acquire

## Quote immediately before acquiring

The intended structured quote is:

```solidity
AcquisitionQuote memory q = midwayBuyer.quoteAcquisition();
```

| Quote field | Plain meaning |
|---|---|
| `fwaFee` | Current FWA acquisition fee |
| `vrfFee` | FWA charge for random selection |
| `midwayFee` | Midway fee reserved for the current quote |
| `totalRequired` | ETH required for the current quote |

Quotes can move before a transaction lands because FWA configuration and pool state are live. Quote
immediately before acquisition and pad the value you send; see [Acquire](#acquire-and-save-the-midway-request-id)
below.

FWA can also activate staged listings while an acquisition is running, which may change its fee after
an earlier read. An exact-payment integration should prepare the pool and then quote again:

```solidity
midwayBuyer.activateListings(maxListingsToActivate);
AcquisitionQuote memory q = midwayBuyer.quoteAcquisition();
```

`maxListingsToActivate` is the most staged FWA listings to process in this transaction. Choose a
small gas-bounded number and repeat if needed. If your application instead sends extra ETH as price
tolerance, Midway derives its temporary fee buffer from the full amount sent. Unused FWA funding and
unused Midway buffer return to the recorded application account. The fee is still charged only on
actual successful FWA spend.

The FWA-shaped three-value quote remains available for easier migration:

```solidity
(uint256 inclusiveFee, uint256 vrfFee, uint256 totalRequired) =
    midwayBuyer.quoteAcquisitionPrice();
```

`inclusiveFee` is `fwaFee + midwayFee`; `vrfFee` remains separate to match FWA's quote shape.

## Acquire and save the Midway request ID

The simplest call reads the quote and sends it padded, with both safety limits left at zero:

```solidity
AcquisitionQuote memory q = midwayBuyer.quoteAcquisition();
uint256 midwayRequestId = midwayBuyer.acquire{value: q.totalRequired * 105 / 100}(0, 0);
```

Send more than `totalRequired`: FWA prices the VRF leg at the gas price of the block that includes
the transaction, so the exact quoted total can fall short by the time it lands. Unused ETH refunds
to the recorded application account at settlement, so padding costs nothing beyond a temporary
balance. 105% (a 5% pad) is a reasonable default; widen it in a busier mempool.

`acquireWithMode` takes the same first two arguments plus an explicit resolution mode:

```solidity
uint256 midwayRequestId = midwayBuyer.acquireWithMode{value: q.totalRequired * 105 / 100}(
    0, 0, mode
);
```

The caller must be an active account belonging to an application that currently has access.
`MidwayBuyer` does not accept a caller-selected payout address. Save `midwayRequestId` in the
application's own accounting: it is the permanent Midway identifier.

### Advanced: bounding the request

`acquire` and `acquireWithMode` take two optional safety limits. Zero, the default above, disables
both.

| Input | What it bounds | Zero means |
|---|---|---|
| `maxAcquisitionFee` | Highest `fwaFee + midwayFee` the account accepts | No fee cap; the acquisition is bounded only by `msg.value` |
| `minWeightedValue` | FWA pool-value safety floor for the acquisition | No floor; the value is passed straight through to FWA |

A positive `maxAcquisitionFee` is always enforced. If it is too small to express as a positive FWA
fee cap, the call fails with `CapTooLow` instead of translating it into FWA's cap-disabled zero value.

Set these when the integration needs a hard ceiling on fee or a hard floor on pool value, for
example a user-facing flow quoting with explicit slippage tolerance.
