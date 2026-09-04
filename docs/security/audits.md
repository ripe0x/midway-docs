# Audits and review

Midway v1 shipped as release `midway-v1-audit-rc11` after these review passes, all against frozen tags in the protocol repository:

| Pass | Scope | Outcome |
|---|---|---|
| Internal review, RC1 to RC8 | Full Midway core, fork tests against the live FWA contracts | Findings fixed before the RC8 package |
| Delta review, RC9 to RC11 | FWAT conversion floor (observed price window), package validation | Findings fixed before the RC11 package |
| Independent review, RC11 | Full package: contracts, decoded deployment plan, keeper, Sepolia proof | One high finding on package funding, fixed by resealing; three low and informational findings dispositioned |

The independent RC11 pass was run by a reviewing agent under the owner's direction, not by a third party security firm. Its findings and dispositions are recorded with the release.

Contract source is verified on chain at every address on the [Deployments](../reference/deployments.md) page. The deployed runtime code hashes are recorded in the release data.
