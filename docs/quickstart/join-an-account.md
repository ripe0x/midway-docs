# Join an account

Most applications bind their only account at registration by passing it directly to
`registerApplication`. This page covers a second account, or an account contract deployed after the
application already exists.

The application admin invites the address:

```solidity
registry.inviteAccount(applicationId, account);
```

That exact address accepts:

```solidity
registry.acceptApplication(applicationId);
```

The two steps prevent an application from permanently claiming an unrelated address. An account's
binding does not change later. The application may set an account's status inactive for new
acquisitions while its historical request exits remain available.

## Account operators

An account contract that cannot easily add a forwarder per verb can instead name an operator:

```solidity
registry.setAccountOperator(account, operator);
```

Callable by the account itself or by the application admin. The operator can call the account-only
`MidwayBuyer` verbs (`settleForFwat`, `deliverNFT`, `makeManaged`) and `RewardVault.payout` on the
account's behalf. It cannot call `acquire`, cannot change the account binding, and cannot change any
recipient. Passing the zero address clears it.

Most builders should stop at one account. Additional accounts are useful for an upgraded treasury or
a separately funded vault, not as a default architecture.
