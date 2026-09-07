# Midway

[FWA](https://fwa.fun) is an on-chain protocol where a purchaser pays for a randomly selected,
NFT-backed position. The result arrives later: a request can fulfill, expire, or refund, and a
fulfilled purchaser may receive ETH, $FWA, or an NFT.

Midway is the application layer for FWA. An application registers once, funds one acquisition per
request through the `MidwayBuyer`, and receives the result at the account it named. Midway owns
everything between those two facts: it drives the FWA lifecycle, settles for ETH with no price
input, and delivers $FWA or an NFT on the account's own terms.

{% hint style="warning" %}
Midway v1 is not yet deployed on Ethereum mainnet. The v1 graph replaces `midway-v0.1`, which is
retired. See [Deployments](reference/deployments.md) for current status and no addresses until
launch.
{% endhint %}

Start with the [Quickstart](quickstart/README.md) to register an application and make your first
request. Read [Concepts](concepts/request-lifecycle.md) for how requests and settlement work, the
[Reference](reference/README.md) for deployment addresses and contract details, and
[Security and trust](security/operator-powers.md) for operator powers and known limits.
