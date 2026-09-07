# What to index

Index the Buyer only. `MidwayBuyer` is the only address an integrator indexes; every request-scoped
event is emitted from its own frame, once, after the engine call returns:

- `MidwayAcquired`: a new request, its engine, `RequestBuyer` clone, account, and `autoSettleEth`.
- `MidwayRequestSynchronized`: state and listing after a `syncRequest` pass.
- `MidwaySettled`: ETH or $FWA settlement, kind and amount.
- `MidwayNftDelivered`: NFT delivery, collection and token id.
- `MidwayRefunded`: a refund paid to the account.
- `MidwayEconomicsFinalized`: spend, fee, and refund for a terminal request.
- `MidwayIncident`: a forced or stuck asset recorded against a request.
- `MidwayRewardsClaimed`: an epoch or accrued reward claim, by kind and claimer.
- `MidwayRewardsPaidOut`: an application pot paid out, by kind and recipient.

There is no engine-to-Buyer callback and no second address to track. The engine keeps its own events
only for what the Buyer's frame cannot see: activity outbox delivery, operator configuration, and
FWA's own queue verbs (`processAcquisitions`, `activateListings`). None of those are request-scoped
and none are needed to track a request's lifecycle.

Track `MidwayRegistry` separately only if the application needs to observe registration, account
binding, or recipient changes; a request itself never needs a registry read to resolve who gets paid,
since the Buyer's events carry the account directly.
