# data/

This directory holds the four JSON files that `scripts/render.mjs` reads to
generate the reference pages under `docs/reference/`:

- `mainnet.json`: deployed contract addresses on mainnet
- `sepolia.json`: deployed contract addresses on Sepolia
- `config.json`: launch configuration values (fees, limits, parameters)
- `reference.json`: contract-level reference data (functions, events, roles)

These files are exported from the protocol repository as part of each
release. They are the only place a contract address is allowed to appear in
this repository. Do not hand-edit the generated pages in
`docs/reference/deployments.md`, `docs/reference/launch-configuration.md`,
or `docs/reference/contracts/`; edit the source data and re-run
`npm run render` instead.

No file in this directory or generated from it may contain a private key,
an API key, an RPC URL with an embedded key, or any other secret.
