# Quote and acquire

## Acquire

`acquire()` reads the quote inside the call and returns any excess ETH to the caller in the same
transaction. There is nothing to compute beforehand beyond a small pad:

```solidity
AcquisitionQuote memory q = midwayBuyer.quoteAcquisition();
uint256 midwayRequestId = midwayBuyer.acquire{value: q.totalRequired * 105 / 100}();
```

Pad `totalRequired` because FWA prices the VRF leg at the gas price of the block that includes the
transaction, so a quote read slightly earlier can fall short by the time it lands. 105% (a 5% pad) is
a reasonable default; widen it in a busier mempool. Unused ETH refunds to `msg.sender` inside
`acquire` itself; the account never needs a separate withdrawal step for it.

`acquire(bool autoSettleEth)` takes one more argument to set this specific request's settlement
default, overriding the application's saved default for this request only:

```solidity
uint256 midwayRequestId = midwayBuyer.acquire{value: q.totalRequired * 105 / 100}(false);
```

`autoSettleEth == true` lets a permissionless caller (Midway's keeper, or anyone) drive the request
to ETH settlement. `false` keeps the outcome for the account: only the account or its operator may
settle it, for $FWA or ETH.

The caller must be an active account belonging to an application that currently has access.
`MidwayBuyer` does not accept a caller-selected payout address; the account that calls `acquire` is
the account that gets paid. Save `midwayRequestId` in the application's own accounting: it is the
permanent Midway identifier.

### The quote

```solidity
struct AcquisitionQuote {
    uint256 fwaFee;
    uint256 vrfFee;
    uint256 midwayFee;
    uint256 totalRequired;
}
```

| Field | Plain meaning |
|---|---|
| `fwaFee` | Current FWA acquisition fee |
| `vrfFee` | FWA charge for random selection |
| `midwayFee` | Midway fee reserved for this quote |
| `totalRequired` | ETH required for this quote |

The engine passes `fwaFee` to FWA as FWA's own fee cap, so nothing derives a cap and nothing can get
a reverse-derived cap wrong. There is no `minWeightedValue` or pool-value floor to set: FWA's
weighted-backing floor is not an application input.

## Check readiness first

```solidity
Readiness memory r = midwayBuyer.readiness(account);
```

```solidity
struct Readiness {
    bool acquisitionsPaused;
    bool accountActive;
    bool applicationAllowed;
    bool fwaPriced;
    uint256 totalRequired;
    uint256 unfulfilledVrf;
    uint256 activeListings;
    bool distributorGranted;
    bool canAcquireNow;
}
```

`canAcquireNow` is the conjunction of every acquisition precondition. `distributorGranted` reports
whether `RewardVault` currently holds FWAToken distributor status; it gates the $FWA payout path, not
acquisition, which is why it is reported separately.

## Follow the request

```solidity
RequestStatus memory s = midwayBuyer.requestStatus(midwayRequestId);
```

One call returns the engine, the recorded account, state, `autoSettleEth`, spend and fee figures,
refund figures, both FWA deadlines, and the single action to take next:

```solidity
(NextAction action, bool callableNow) = midwayBuyer.nextAction(midwayRequestId);
```

`nextAction` is the authority for what happens next. An application that wants its own keeper reads
this instead of holding a copy of the state machine. Most applications let Midway's keeper drive the
request and only read `requestStatus` to display state to a user.
