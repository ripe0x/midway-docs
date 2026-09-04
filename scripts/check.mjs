// CI check for the docs tree. Node built-ins only, no dependencies.
//
// 1. Every path linked from docs/SUMMARY.md must exist.
// 2. No .md file under docs/ (except the generated reference pages) may
//    contain what looks like an Ethereum address.
// 3. No file under docs/ may contain an em dash or en dash.
// 4. No file under docs/ may reference the private source repo, a local
//    filesystem path, or a secret-shaped term.
// 5. scripts/render.mjs, run into a scratch directory, must produce output
//    byte-identical to the committed reference pages.

import { readFileSync, readdirSync, statSync, existsSync, mkdtempSync, rmSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { tmpdir } from "node:os";
import { execFileSync } from "node:child_process";

const root = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const docsDir = path.join(root, "docs");
const summaryPath = path.join(docsDir, "SUMMARY.md");

const failures = [];

function walk(dir) {
  const out = [];
  for (const entry of readdirSync(dir)) {
    const full = path.join(dir, entry);
    const stat = statSync(full);
    if (stat.isDirectory()) out.push(...walk(full));
    else out.push(full);
  }
  return out;
}

// 1. every path in docs/SUMMARY.md must exist
const summary = readFileSync(summaryPath, "utf8");
const linkRe = /\]\(([^)]+\.md)\)/g;
let match;
while ((match = linkRe.exec(summary))) {
  const target = path.join(docsDir, match[1]);
  if (!existsSync(target)) {
    failures.push(`SUMMARY.md links to missing file: ${match[1]}`);
  }
}

const allDocsFiles = walk(docsDir);
const generatedRefPages = new Set([
  path.join(docsDir, "reference", "deployments.md"),
  path.join(docsDir, "reference", "launch-configuration.md"),
]);
const contractsDir = path.join(docsDir, "reference", "contracts");

const addressRe = /0x[0-9a-fA-F]{40}/g;
const emDash = "—";
const enDash = "–";
const bannedStrings = ["fwa-roll", "/Users/", "keystore", "PRIVATE_KEY"];

for (const file of allDocsFiles) {
  if (!file.endsWith(".md")) continue;
  const rel = path.relative(docsDir, file);
  const content = readFileSync(file, "utf8");
  const lines = content.split("\n");

  const isGeneratedRefPage =
    generatedRefPages.has(file) || file.startsWith(contractsDir + path.sep);

  lines.forEach((line, i) => {
    const lineNo = i + 1;

    // 2. no addresses outside generated reference pages
    if (!isGeneratedRefPage && addressRe.test(line)) {
      failures.push(`docs/${rel}:${lineNo}: contains what looks like an address`);
    }
    addressRe.lastIndex = 0;

    // 3. no em dash or en dash
    if (line.includes(emDash) || line.includes(enDash)) {
      failures.push(`docs/${rel}:${lineNo}: contains an em dash or en dash`);
    }

    // 4. no banned strings
    for (const needle of bannedStrings) {
      if (line.includes(needle)) {
        failures.push(`docs/${rel}:${lineNo}: contains banned string "${needle}"`);
      }
    }
  });
}

// 5. rendered output must match the committed reference pages exactly
const scratchDir = mkdtempSync(path.join(tmpdir(), "midway-docs-render-"));
try {
  execFileSync(process.execPath, [path.join(root, "scripts", "render.mjs"), scratchDir], {
    stdio: "pipe",
  });

  const rendered = walk(scratchDir);
  for (const file of rendered) {
    const rel = path.relative(scratchDir, file);
    const committed = path.join(docsDir, "reference", rel);
    if (!existsSync(committed)) {
      failures.push(`render output has no committed counterpart: docs/reference/${rel}`);
      continue;
    }
    const renderedContent = readFileSync(file, "utf8");
    const committedContent = readFileSync(committed, "utf8");
    if (renderedContent !== committedContent) {
      failures.push(`docs/reference/${rel} is stale: run "npm run render"`);
    }
  }
} finally {
  rmSync(scratchDir, { recursive: true, force: true });
}

if (failures.length > 0) {
  console.error(`check failed with ${failures.length} issue(s):\n`);
  for (const f of failures) console.error(`  - ${f}`);
  process.exit(1);
}

console.log("check passed");
