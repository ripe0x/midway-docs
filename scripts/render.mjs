// Generates docs/reference/deployments.md, docs/reference/launch-configuration.md,
// and docs/reference/contracts/*.md from the JSON files in data/.
// Placeholder: wires up the data read, does not render pages yet.

import { existsSync, readdirSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const root = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const dataDir = path.join(root, "data");

const files = existsSync(dataDir)
  ? readdirSync(dataDir).filter((f) => f.endsWith(".json"))
  : [];

if (files.length === 0) {
  console.log("no data files yet");
  process.exit(0);
}

console.log(`found ${files.length} data file(s): ${files.join(", ")}`);
console.log("rendering is not implemented yet");
