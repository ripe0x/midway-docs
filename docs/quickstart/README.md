# Overview

## Decisions to make

| Decision | What it means | Simple starting choice |
|---|---|---|
| Application admin | Address allowed to manage your Midway application record | Project multisig |
| Application account | Contract that calls `MidwayBuyer` and receives request ETH | One application treasury contract |
| Reward recipient | Address receiving the application's share of FWA purchaser rewards | Treasury, or a reward distributor that can satisfy FWA's token-transfer rules |
| Award recipient | Address controlling any Shared Upside award credited to the application | Treasury or dedicated distributor |
| Referrer | Builder or community that introduced the application to Midway | Zero address if there was no referrer |
| Managed default | ETH pays the recorded account. $FWA first attempts a protected token buy and atomically falls back to ETH on failure | ETH |
| Resolution mode | Managed lets anyone execute the application's saved default. Manual reserves the choice for the account | Managed |

Only addresses that directly call `MidwayBuyer` need to join the application. Frontends, keepers,
users, and ordinary administrators do not need to be application accounts.

An application might use another account later for a contract upgrade or for a truly separate vault.
It does not need one account per user or one account per Midway request.

## Five steps to a first request

1. [Register an application](register-an-application.md): create your application record.
2. [Join an account](join-an-account.md): invite and accept the contract that will call `MidwayBuyer`.
3. [Curated launch access](curated-launch-access.md): get the application admitted while launch access
   is curated.
4. [Quote and acquire](quote-and-acquire.md): quote immediately before acquiring.
5. [Quote and acquire](quote-and-acquire.md): acquire and save the returned Midway request ID.

See [Examples](examples.md) for a full application account and award recipient contract.
