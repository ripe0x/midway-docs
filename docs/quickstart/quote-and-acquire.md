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
immediately before acquisition, use an explicit nonzero maximum, and show any tolerance to the user.

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

Managed mode uses the familiar FWA-shaped call:

```solidity
uint256 midwayRequestId = midwayBuyer.acquire{value: q.totalRequired}(
    q.fwaFee + q.midwayFee,
    minWeightedValue
);
```

| Input | Plain meaning |
|---|---|
| `msg.value` | ETH available for FWA spend and the refundable Midway fee buffer; it may include deliberate price tolerance |
| `maxAcquisitionFee` | Highest `fwaFee + midwayFee` the account accepts; zero disables this protection |
| `minWeightedValue` | FWA pool-value safety floor; zero disables this protection |

A positive `maxAcquisitionFee` is always enforced. If it is too small to express as a positive FWA
fee cap, the call fails with `CapTooLow` instead of translating it into FWA's cap-disabled zero value.

The caller must be an active account belonging to an application that currently has access.
`MidwayBuyer` does not accept a caller-selected payout address. Save `midwayRequestId` in the
application's own accounting: it is the permanent Midway identifier.
