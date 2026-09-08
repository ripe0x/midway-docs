# Midway

[FWA](https://fwa.fun) is an on-chain protocol where a purchaser pays for a randomly selected,
NFT-backed position. The result arrives later: a request can fulfill, expire, or refund, and a
fulfilled purchaser may receive ETH, $FWA, or an NFT.

Midway is the application layer for FWA. An application registers once, funds one acquisition per
request through the `MidwayBuyer`, and receives the result at the account it named. Midway owns
everything between those two facts: it drives the FWA lifecycle, settles for ETH with no price
input, and delivers $FWA or an NFT on the account's own terms.

{% hint style="info" %}
Midway v1 is deployed and unpaused on Ethereum mainnet under curated access. ETH settlement and NFT
delivery are live. $FWA settlement and reward payouts remain pending the RewardVault distributor
grant. See [Deployments](reference/deployments.md) for verified addresses and current status.
{% endhint %}

Start with the [Quickstart](quickstart/README.md) to register an application and make your first
request. Read [Concepts](concepts/request-lifecycle.md) for how requests and settlement work, the
[Reference](reference/README.md) for deployment addresses and contract details, and
[Security and trust](security/operator-powers.md) for operator powers and known limits.
