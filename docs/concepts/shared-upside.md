# Shared upside

Shared Upside is Midway's core incentive: a share of every application's $FWA purchaser rewards
funds a weekly draw among the applications that acquired in that cycle.

## Draws start off

`SharedUpside` starts in cycle 1 with `drawsEnabled() == false`. Activity from every application
accrues into cycle 1's weights exactly as in any cycle, and the 25% reward skim (see
[Fees](fees.md)) accrues into the cycle pot. `checkpoint` is a no-op while draws are off, so cycle 1
does not close, and no randomness request is made while draws are off.

The owner enables draws once, one way:

```solidity
function enableDraws() external;
```

`enableDraws` schedules the first close at the next cycle boundary after the call. That close is a
normal draw: a VRF-selected winner weighted by all activity recorded since launch, paid the
configured payout share of everything accumulated since genesis. There is no separate launch gate,
minimum application count, or per-application counting floor: the owner's judgment that the
applications using Midway are a real population replaces a formula guessing at what "enough" means,
and the switch is one-way so it is a commitment.

From cycle 2 on, cycles close on the configured interval. Mainnet cycles run on a `cycleInterval` of
604,800 seconds (one week), starting from a genesis timestamp; see
[Launch configuration](../reference/launch-configuration.md) for the exact values.

## Draws

The payout is `sharedUpside.payoutBps` (85% at launch) of the cycle's accumulated pot to one winner,
with the remainder retained as the next cycle's seed. Odds are proportional to an application's
recorded successful spend in that cycle. `SharedUpside.claimAward` migrates the award into the
winning application's `SharedUpsideAward` pot on `RewardVault`; `RewardVault.payout` or
`payoutRewards` then moves it to `sharedUpsideAwardRecipientOf(applicationId)`.

An activated cycle saves its pot, weights, recipients, payout rate, and VRF route. Lost randomness
can be retried through that same saved coordinator, key, and subscription; a retry cannot change the
competition or skip the cycle. An award does not expire and remains in the application's `RewardVault`
pot until paid out.

## The activity outbox

`recordActivity` is called from inside settlement. A failure sets the record `pending` and returns;
`retrySharedUpsideActivity` drives it later, permissionlessly. A Shared Upside fault never blocks a
settlement or a refund.
