# Overview

## Decisions to make

| Decision | What it means | Simple starting choice |
|---|---|---|
| Application admin | Address allowed to manage your Midway application record | Project multisig |
| Account | Contract that calls `MidwayBuyer.acquire()` and receives request ETH | One application treasury contract |
| Purchaser reward recipient | Address `RewardVault.payout` sends the application's $FWA purchaser rewards to | Treasury, or a distributor that can satisfy FWAToken's transfer rules |
| Shared Upside award recipient | Address `RewardVault.payout` sends a Shared Upside award to | Treasury or dedicated distributor |
| Referrer | Builder or community that introduced the application to Midway; recorded, not paid, in v1 | Zero address if there was no referrer |
| Account operator | Address the account authorizes to call `settleForFwat`, `deliverNFT`, and `makeManaged` on its behalf | None, until the account needs one |
| Default `autoSettleEth` | Whether a permissionless caller may drive future requests to ETH by default | `true` |

Only the address that calls `MidwayBuyer.acquire()` needs to be a bound account. Frontends, keepers,
and users do not need to be accounts.

## Four steps to a first request

1. [Register an application](register-an-application.md): one call binds the application and its
   account together.
2. [Curated launch access](curated-launch-access.md): get the application admitted while launch
   access is curated.
3. [Quote and acquire](quote-and-acquire.md): quote and acquire in one call.
4. Follow the request with [`requestStatus`](quote-and-acquire.md#follow-the-request) and
   `nextAction` until it settles.

See [Examples](examples.md) for a minimal account contract.
