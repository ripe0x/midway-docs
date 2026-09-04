# Register an application

Registration is self-service and does not require operator approval:

```solidity
uint256 applicationId = registry.registerApplication(
    purchaserRewardRecipient,
    referrer
);
```

New applications default to Managed ETH. An application that wants `$FWA` by default sets its
prospective policy before acquiring:

```solidity
registry.setManagedSettlement(
    applicationId,
    ManagedSettlement.Fwa
);
```

Applications maintain no `$FWA` exchange rate. Midway reads FWAToken's live protocol-owned buyback
price floor at settlement and uses it to protect the token purchase. Policy changes affect only later
acquisitions; the FWA price floor remains live so protection follows FWA's current protocol setting.

| Input | What it is | What you need to decide |
|---|---|---|
| `purchaserRewardRecipient` | Address that receives the application's share of claimed FWA rewards | Use a treasury or distributor that can receive $FWA |
| `referrer` | Permanent reserved record of who introduced this application to Midway; the v1 referral rate is zero | Use the actual referrer if one exists, otherwise zero |
| `msg.sender` | Initial application admin | Use an address the team can operate safely |

The returned `applicationId` identifies the application in account bindings, rewards, activity, and
Shared Upside awards. Registration means this builder created a Midway record. It is not a Midway
endorsement or verification badge.

The application can later choose a different reward or award recipient. Midway saves both recipients
when each request is created. A later change applies only to later requests: it cannot redirect an
old request's unclaimed purchaser rewards or an already recorded award.
