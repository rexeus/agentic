import { mkdirSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

import { agentMap, generateOpenCodeAgentContent } from "./opencode-sync-lib.mjs";

const rootDir = resolve(dirname(fileURLToPath(import.meta.url)), "..");

for (const [sourceName, targetName] of agentMap) {
  const targetPath = resolve(rootDir, "assets", "opencode", "agents", targetName);
  mkdirSync(dirname(targetPath), { recursive: true });
  writeFileSync(targetPath, generateOpenCodeAgentContent(sourceName), "utf8");
  console.log(`synced ${targetName}`);
}
