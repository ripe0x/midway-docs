# Batch and paced acquisitions

Midway v1 includes an optional first-party `MidwayBatchAccount` for builders that want to fund and
configure a campaign once, then let permissionless callers submit its acquisitions over time. A
campaign can target 100 requests, for example, while setting acquisition-fee, total-payment, and FWA
pool-value caps.

The Batch Account is a normal account invited into one application. It quotes immediately before
every purchase, saves every returned Midway request ID, and is the immutable account that receives
the resulting ETH and refunds. After each request is accepted, the normal Midway Engine independently
handles its processing, settlement, refunds, forced outcomes, and purchaser rewards.

Campaigns use bounded crank transactions rather than attempting all 100 acquisitions atomically.
They support an optional `minRequestInterval`:

- with a zero interval, one crank may create a caller-bounded number of requests while gas, budget,
  and live quotes permit; and
- with a nonzero interval, a crank creates at most one request once `lastRequestAt +
  minRequestInterval` has passed, matching MegaRip's paced-pull pattern.

Each iteration takes a new quote because earlier requests may move live FWA pricing. If a later quote
or acquisition fails, the crank stops without reverting requests it already created. An underfunded,
capped, paused, inaccessible, or expired campaign stops cleanly and leaves uncommitted funds
recoverable by the application. `processAcquisitions(maxCount)` still means processing work already
queued inside FWA. It does not create campaign requests.

The module does not guarantee that the target count will execute or promise 100 requests in one
transaction. It provides managed, paced submission while keeping each accepted request on Midway's
ordinary isolated lifecycle. Custom application accounts remain supported for teams with different
funding, payout, or end-user accounting rules.
