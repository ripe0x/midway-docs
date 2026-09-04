# What to index

At minimum, track:

- application and account changes in `MidwayRegistry`;
- every request ID, Engine, application, account, and `RequestBuyer` from `MidwayBuyer`;
- request state, fee, ETH settlement, $FWA settlement, refund, forced-outcome, and incident events;
- reward splits and referral credits; and
- Shared Upside activity, failed gates, randomness attempts, awards, and claims.

FWA sees the request-specific `RequestBuyer` as purchaser. Use Midway's saved route to find the real
application account. Continue indexing every historical Engine learned from `MidwayBuyer`.
