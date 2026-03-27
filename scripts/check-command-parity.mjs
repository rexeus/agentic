import { readFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

import {
  commandMap,
  generateOpenCodeCommandContent,
  normalizeGeneratedContent,
} from "./opencode-sync-lib.mjs";

const rootDir = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const failures = [];

for (const [sourceName, targetName] of commandMap) {
  const targetPath = resolve(rootDir, "assets", "opencode", "commands", targetName);
  const actual = normalizeGeneratedContent(readFileSync(targetPath, "utf8"));
  const expected = normalizeGeneratedContent(generateOpenCodeCommandContent(sourceName));

  if (actual !== expected) {
    failures.push({ sourceName, targetPath });
  }
}

if (failures.length > 0) {
  console.error("Command parity check failed. The following files are out of sync:");
  for (const failure of failures) {
    console.error(`- ${failure.sourceName}: ${failure.targetPath}`);
  }
  console.error("Run: pnpm run sync:opencode-commands");
  process.exit(1);
}

console.log("OpenCode command files are in parity with Claude command files.");
