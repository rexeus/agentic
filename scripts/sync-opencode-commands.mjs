import { mkdirSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

import { commandMap, generateOpenCodeCommandContent } from "./opencode-sync-lib.mjs";

const rootDir = resolve(dirname(fileURLToPath(import.meta.url)), "..");

for (const [sourceName, targetName] of commandMap) {
  const targetPath = resolve(rootDir, "assets", "opencode", "commands", targetName);
  mkdirSync(dirname(targetPath), { recursive: true });
  writeFileSync(targetPath, generateOpenCodeCommandContent(sourceName), "utf8");
  console.log(`synced ${targetName}`);
}
