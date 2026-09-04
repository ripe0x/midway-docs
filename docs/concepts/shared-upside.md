# Shared upside

## Curated weekly activation

Mainnet Shared Upside cycles run on a `cycleInterval` of 604,800 seconds, one week, starting from a
genesis timestamp of unix 1788825600.

During curated launch access, a weekly cycle activates only when all of these are true:

- combined qualifying successful spend is at least `1 ETH`;
- at least three curated applications participate; and
- each of those three contributes at least `0.1 ETH` of successful spend.

The `0.1 ETH` floor is only an anti-dust counting rule. Successful spend below it still receives full
spend-proportional weight and remains eligible to win: it simply does not count as one of the three
applications needed to activate the draw.

Example:

```text
MegaRip        0.65 ETH  -> 65% of weight, counts toward the app gate
Application B 0.20 ETH  -> 20% of weight, counts toward the app gate
Application C 0.14 ETH  -> 14% of weight, counts toward the app gate
Application D 0.01 ETH  ->  1% of weight, does not count toward the app gate
Total          1.00 ETH  -> cycle activates
```

If a gate fails:

- no winner is fabricated;
- no randomness is requested;
- the $FWA pot rolls forward; and
- that week's weights expire instead of accumulating into the first later draw.

The gate ensures the network exists before the pot is drawn. It does not cap MegaRip's weight or
promise equal odds after activation.

## Open access cycles

The curated-to-open switch is one-way and takes effect at a scheduled cycle boundary. Open cycles
remove the application approval, three-application gate, and per-application counting floor because
permissionless identities can Sybil an identity-count rule.

Open cycles keep the combined successful-spend activation floor. If it fails, the pot still rolls and
the week's weights expire.

## Awards and purchaser rewards

The weekly payout is 85% of drawable $FWA to one application, with 15% retained as the next seed.
Odds are proportional to successful spend.

FWA purchaser rewards are claimed from each request-specific account. `RewardSplitter` skims a share
of gross FWAT rewards into Shared Upside. The launch skim is 2,500 basis points, so the application
receives 75% and 25% joins Shared Upside. The registry operator can change the skim with
`setSkimBps`, up to the hard cap `MAX_SKIM_BPS` of 3,000 basis points (30%). The rate is read live at
harvest, so a change applies to any request not yet harvested, which is what lets the operator retune
the split as the $FWA price moves. The application share always goes to the reward recipient saved
when that request was created, even if the application changes its Registry recipient before
harvesting.

Midway does not maintain a receiver allowlist or block an application's saved reward recipient.
`RewardVault` must be added to the FWAToken distributor allowlist so it can pay those recipients. A
recipient contract can receive that payment, but a contract that will distribute $FWA onward must
also be registered. On mainnet, the FWA team must review and approve the contract. Without that
registration, FWAToken's transfer lock blocks the contract's outbound distribution; the restriction
does not come from Midway.

An activated cycle saves its pot, weights, recipients, payout rate, and VRF route. Lost randomness
can be retried through that same saved coordinator, key, and subscription. Configuration changes
apply only to future cycles. A retry cannot change the competition or skip the cycle. An award does
not expire and remains in an isolated `RewardVault` balance until claimed.
