# Register an application

Registration is self-service and does not require operator approval. One call binds the application
record and its first account together when the account is the caller:

```solidity
uint256 applicationId = registry.registerApplication(
    purchaserRewardRecipient,
    referrer,
    account
);
```

| Input | What it is | What you need to decide |
|---|---|---|
| `purchaserRewardRecipient` | Address `RewardVault.payout` sends the application's claimed $FWA purchaser rewards to | Use a treasury or distributor that can receive $FWA |
| `referrer` | Immutable record of who introduced this application to Midway; nothing pays it in v1 | Use the actual referrer if one exists, otherwise zero |
| `account` | The address that will call `MidwayBuyer.acquire()` | Pass `msg.sender` to bind immediately, or `address(0)` to register with no account yet |
| `msg.sender` | Initial application admin | Use an address the team can operate safely |

When `account == msg.sender`, the account binds in this same transaction: `msg.sender` calling for
itself already proves control, so there is no separate accept step. Passing any other address
invites that address; it must accept with `acceptApplication(applicationId)` before it can acquire.
See [Join an account](join-an-account.md) for a second account or one deployed after registration.

The returned `applicationId` identifies the application in account bindings, rewards, activity, and
Shared Upside awards. Registration means this builder created a Midway record. It is not a Midway
endorsement or verification badge.

The application can later change either recipient with `setPurchaserRewardRecipient` or
`setSharedUpsideAwardRecipient`, application admin only. `RewardVault.payout` resolves the recipient
from registry state at payout time, so a correction redirects only what has not been paid out yet; it
never touches a $FWA balance already sent.
