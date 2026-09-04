# Join an account

The application admin invites the contract that will buy through Midway:

```solidity
registry.inviteAccount(applicationId, account);
```

That exact contract accepts:

```solidity
registry.acceptApplication(applicationId);
```

The two steps prevent an application from permanently claiming an unrelated address. The account's
application binding does not change later. The application may disable it for new acquisitions while
historical request exits remain available.

Most builders should stop at one account. Additional accounts are useful for an upgraded treasury or
a separately funded vault, not as a default architecture.
