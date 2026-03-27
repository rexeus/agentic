import { readFileSync, writeFileSync } from "node:fs";
import { resolve } from "node:path";
import { fileURLToPath } from "node:url";

const rootDir = fileURLToPath(new URL("../", import.meta.url));

const readJson = (relativePath) => {
  const filePath = resolve(rootDir, relativePath);
  return {
    filePath,
    data: JSON.parse(readFileSync(filePath, "utf8")),
  };
};

const writeJson = (filePath, data) => {
  writeFileSync(filePath, `${JSON.stringify(data, null, 2)}\n`, "utf8");
};

const isCheckMode = process.argv.includes("--check");

const { data: packageJson } = readJson("package.json");
const sourceVersion = packageJson.version;

if (typeof sourceVersion !== "string" || sourceVersion.length === 0) {
  throw new Error("package.json version is missing or invalid");
}

const mismatches = [];

const pluginFile = readJson(".claude-plugin/plugin.json");
if (pluginFile.data.version !== sourceVersion) {
  mismatches.push(`.claude-plugin/plugin.json version: ${pluginFile.data.version ?? "<missing>"}`);
  pluginFile.data.version = sourceVersion;
}

const marketplaceFile = readJson(".claude-plugin/marketplace.json");
if (!Array.isArray(marketplaceFile.data.plugins)) {
  throw new Error(".claude-plugin/marketplace.json has invalid plugins format");
}

for (const plugin of marketplaceFile.data.plugins) {
  if (plugin?.name === "agentic" && plugin.version !== sourceVersion) {
    mismatches.push(
      `.claude-plugin/marketplace.json plugin '${plugin.name}' version: ${plugin.version ?? "<missing>"}`,
    );
    plugin.version = sourceVersion;
  }
}

if (isCheckMode) {
  if (mismatches.length > 0) {
    console.error("Version mismatch detected against package.json:");
    for (const mismatch of mismatches) {
      console.error(`- ${mismatch}`);
    }
    process.exit(1);
  }

  console.log("Versions are in sync.");
  process.exit(0);
}

if (mismatches.length > 0) {
  writeJson(pluginFile.filePath, pluginFile.data);
  writeJson(marketplaceFile.filePath, marketplaceFile.data);
  console.log("Synced versions from package.json to Claude plugin metadata files.");
} else {
  console.log("Versions already in sync.");
}
