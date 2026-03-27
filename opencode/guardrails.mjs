import { readFileSync } from "node:fs";
import { execSync } from "node:child_process";

const SECRET_ASSIGNMENT_QUOTED =
  /(password|passwd|secret|api_?key|access_?key|private_?key)"?[\t ]*[:=][\t ]*["'][^\s"']{4,}/i;
const SECRET_ASSIGNMENT_UNQUOTED =
  /(password|passwd|secret|api_?key|access_?key|private_?key)[\t ]*=[\t ]*[^\s"'=,;}{]{4,}/i;
const TOKEN_PATTERN =
  /(sk-[a-zA-Z0-9]{20,}|ghp_[a-zA-Z0-9]{36,}|gho_[a-zA-Z0-9]{36,}|github_pat_[a-zA-Z0-9_]{20,}|aws_[a-zA-Z0-9/+=]{20,}|AKIA[A-Z0-9]{16}|sk_live_[a-zA-Z0-9]{20,}|sk_test_[a-zA-Z0-9]{20,}|xoxb-[a-zA-Z0-9-]{20,}|xoxp-[a-zA-Z0-9-]{20,})/;
const COMMIT_TYPES = "feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert";
const COMMIT_HEADER_RE = new RegExp(`^(${COMMIT_TYPES})(\\([a-zA-Z0-9_./-]+\\))?!?:[\\t ].+`);

let conventionalHistoryCache;

const JS_TS_FILE_RE = /\.(ts|tsx|js|jsx|mjs|cjs)$/;
const BINARY_OR_GENERATED_RE =
  /\.(png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot|lock|min\.js|min\.css|map)$/;

const getFirstString = (...values) => {
  for (const value of values) {
    if (typeof value === "string" && value.length > 0) {
      return value;
    }
  }
  return "";
};

export const extractFilePath = (args) =>
  getFirstString(args?.filePath, args?.file_path, args?.path);

export const extractWriteContent = (args) =>
  getFirstString(args?.content, args?.newString, args?.new_string);

export const findSecretViolations = ({ filePath, content }) => {
  if (!content) {
    return [];
  }

  const fileLabel = filePath ?? "file";
  const violations = [];

  if (SECRET_ASSIGNMENT_QUOTED.test(content) || SECRET_ASSIGNMENT_UNQUOTED.test(content)) {
    violations.push(
      `Possible hardcoded secret detected - do not write credentials to ${fileLabel}`,
    );
  }

  if (TOKEN_PATTERN.test(content)) {
    violations.push(`Possible API token detected - do not write tokens to ${fileLabel}`);
  }

  return violations;
};

const extractCommitMessage = (command) => {
  if (!command || !/(^|&&|;|\|)[\t ]*git[\t ]+commit/.test(command)) {
    return "";
  }

  const heredocMatch = command.match(/cat <<\s*(["']?)EOF\1\s*\n([\s\S]*?)\nEOF\n?/);
  if (heredocMatch && heredocMatch[2]) {
    return heredocMatch[2].trim();
  }

  const quotedMatch = command.match(/-[a-z]*m[\t ]*["']([^"']+)["']/);
  if (quotedMatch && quotedMatch[1]) {
    return quotedMatch[1];
  }

  return "";
};

export const validateConventionalCommitCommand = (command) => {
  const message = extractCommitMessage(command);

  if (!message) {
    return [];
  }

  if (!projectUsesConventionalCommits()) {
    return [];
  }

  const header = message.split("\n")[0] ?? "";
  const issues = [];

  if (!new RegExp(`^(${COMMIT_TYPES})`).test(header)) {
    issues.push(`First line must start with a valid type (${COMMIT_TYPES})`);
  }

  if (!COMMIT_HEADER_RE.test(header)) {
    issues.push("Format must be: type[optional scope]: description - colon and space required");
  }

  const description = header.replace(/^[^:]*:[\t ]*/, "");
  if (description) {
    const firstChar = description[0];
    if (/[A-Z]/.test(firstChar)) {
      issues.push("Description should start lowercase after ': '");
    }

    if (description.endsWith(".")) {
      issues.push("Description should not end with a period");
    }
  }

  if (header.length > 100) {
    issues.push(`First line exceeds 100 characters (found ${header.length})`);
  }

  return issues;
};

const projectUsesConventionalCommits = () => {
  if (typeof conventionalHistoryCache === "boolean") {
    return conventionalHistoryCache;
  }

  try {
    const recent = execSync("git log --format=%s -10", {
      encoding: "utf8",
      stdio: ["ignore", "pipe", "ignore"],
    })
      .split("\n")
      .map((line) => line.trim())
      .filter(Boolean);

    if (recent.length < 4) {
      conventionalHistoryCache = true;
      return conventionalHistoryCache;
    }

    const typeMatcher = new RegExp(`^(${COMMIT_TYPES})`);
    const matching = recent.filter((line) => typeMatcher.test(line)).length;
    conventionalHistoryCache = matching >= Math.floor(recent.length / 2);
    return conventionalHistoryCache;
  } catch {
    conventionalHistoryCache = true;
    return conventionalHistoryCache;
  }
};

export const getConventionWarningsForFile = (filePath) => {
  if (!filePath || BINARY_OR_GENERATED_RE.test(filePath)) {
    return [];
  }

  let content;
  try {
    content = readFileSync(filePath, "utf8");
  } catch {
    return [];
  }

  const warnings = [];

  if (/^(<<<<<<<|=======|>>>>>>>)/m.test(content)) {
    warnings.push(`Merge conflict markers found in ${filePath} - resolve before committing`);
  }

  if (JS_TS_FILE_RE.test(filePath)) {
    if (/(console\.log|console\.debug|\bdebugger\b)/.test(content)) {
      warnings.push(`Debug statement found in ${filePath} - remove before committing`);
    }

    if (/(^|[^A-Za-z])TODO([^(A-Za-z)]|$)/.test(content)) {
      warnings.push(`Unowned TODO in ${filePath} - use TODO(name) or TODO(#123)`);
    }
  }

  return warnings;
};
