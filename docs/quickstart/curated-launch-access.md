# Curated launch access

Application registration remains open during the launch phase, but only applications admitted to the
curated allowlist may create requests. An admitted application receives the same fee and Shared
Upside treatment as every other admitted application: there is no fee-paying second class.

Curated access is temporary. The operator can schedule a one-way switch to open access at any future
timestamp with `MidwayRegistry.scheduleOpenAccess(effectiveAt)`. That timestamp is a plain deadline;
it carries no relationship to a Shared Upside cycle boundary. Once it passes:

- every registered application may acquire;
- no application approval is required;
- the curated allowlist can no longer be used; and
- the operator does not maintain an application roster.

Removing an application from the allowlist during the curated phase blocks only later acquisitions.
It cannot change a request Midway already accepted.
