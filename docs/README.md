# Midway

[FWA](https://fwa.fun) is an on-chain protocol where a purchaser pays for a randomly selected,
NFT-backed position. The result arrives later: a request can fulfill, expire, or refund, and a
fulfilled purchaser may receive ETH, $FWA, or an NFT.

Midway is the application layer for FWA. An application buys through one stable `MidwayBuyer`
address. Midway isolates each request, operates the FWA lifecycle, normally turns fulfilled
positions into ETH, and pays the result to the application account recorded when the request began.
Midway provides two products: Managed Settlement, which returns the resolved economic result without
your application rebuilding FWA's deadlines, refunds, or reward claims, and Shared Upside, a
recurring cross-application $FWA award funded by part of FWA purchaser rewards.

{% hint style="warning" %}
Midway is deployed on Ethereum mainnet, release midway-v1-audit-rc11. It is currently paused.
Activation is pending.
{% endhint %}

Start with the [Quickstart](quickstart/README.md) to register an application and make your first
request. Read [Concepts](concepts/request-lifecycle.md) for how requests and settlement work, the
[Reference](reference/README.md) for deployment addresses and contract details, and
[Security and trust](security/operator-powers.md) for operator powers and known limits.
