import { readFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const rootDir = resolve(dirname(fileURLToPath(import.meta.url)), "..");

export const commandMap = [
  ["plan", "agentic-plan.md"],
  ["develop", "agentic-develop.md"],
  ["review", "agentic-review.md"],
  ["verify", "agentic-verify.md"],
  ["simplify", "agentic-simplify.md"],
  ["polish", "agentic-polish.md"],
  ["commit", "agentic-commit.md"],
  ["pr", "agentic-pr.md"],
];

export const agentMap = [
  ["lead", "lead.md"],
  ["scout", "scout.md"],
  ["analyst", "analyst.md"],
  ["architect", "architect.md"],
  ["developer", "developer.md"],
  ["reviewer-correctness", "reviewer-correctness.md"],
  ["reviewer-security", "reviewer-security.md"],
  ["reviewer-maintainability", "reviewer-maintainability.md"],
  ["tester-scout", "tester-scout.md"],
  ["tester-artisan", "tester-artisan.md"],
  ["tester-architect", "tester-architect.md"],
  ["refiner", "refiner.md"],
];

const OPEN_CODE_AGENT_CONFIG = {
  lead: {
    mode: "primary",
    color: "primary",
    tools: { skill: true, task: true },
    permission: {
      task: {
        "*": "deny",
        scout: "allow",
        analyst: "allow",
        architect: "allow",
        developer: "allow",
        "reviewer-correctness": "allow",
        "reviewer-security": "allow",
        "reviewer-maintainability": "allow",
        "tester-scout": "allow",
        "tester-artisan": "allow",
        "tester-architect": "allow",
        refiner: "allow",
      },
      bash: {
        "*": "allow",
        "git add *": "deny",
        "git stage *": "deny",
        "git push *": "deny",
        "git stash *": "deny",
        "git reset *": "deny",
        "git checkout *": "deny",
        "git restore *": "deny",
        "git clean *": "deny",
        "git rebase *": "deny",
        "git merge *": "deny",
        "git cherry-pick *": "deny",
        "git revert *": "deny",
        "git rm *": "deny",
      },
    },
  },
  scout: {
    mode: "subagent",
    hidden: true,
    color: "success",
    tools: { write: false, edit: false, task: false, skill: false },
    permission: {
      bash: {
        "*": "deny",
        "wc *": "allow",
        "ls *": "allow",
        "tree *": "allow",
        "jq *": "allow",
        "git log *": "allow",
        "git show *": "allow",
        "git blame *": "allow",
        "git diff *": "allow",
        "git status *": "allow",
        "git shortlog *": "allow",
        "git ls-tree *": "allow",
        "git ls-files *": "allow",
        "git rev-parse *": "allow",
      },
    },
  },
  analyst: {
    mode: "subagent",
    hidden: true,
    color: "info",
    tools: { write: false, edit: false, task: false, skill: true },
    permission: {
      bash: {
        "*": "deny",
        "wc *": "allow",
        "ls *": "allow",
        "tree *": "allow",
        "jq *": "allow",
        "git log *": "allow",
        "git show *": "allow",
        "git blame *": "allow",
        "git diff *": "allow",
        "git status *": "allow",
        "git shortlog *": "allow",
        "git ls-tree *": "allow",
        "git ls-files *": "allow",
        "git rev-parse *": "allow",
      },
    },
  },
  architect: {
    mode: "subagent",
    hidden: true,
    color: "warning",
    tools: { write: false, edit: false, task: false, skill: true },
    permission: {
      bash: {
        "*": "deny",
        "wc *": "allow",
        "ls *": "allow",
        "tree *": "allow",
        "jq *": "allow",
        "git log *": "allow",
        "git show *": "allow",
        "git blame *": "allow",
        "git diff *": "allow",
        "git status *": "allow",
        "git shortlog *": "allow",
        "git ls-tree *": "allow",
        "git ls-files *": "allow",
        "git rev-parse *": "allow",
      },
    },
  },
  developer: {
    mode: "subagent",
    hidden: true,
    color: "accent",
    tools: { task: false, skill: true },
    permission: {
      bash: {
        "*": "allow",
        "git add *": "deny",
        "git stage *": "deny",
        "git push *": "deny",
        "git stash *": "deny",
        "git reset *": "deny",
        "git checkout *": "deny",
        "git restore *": "deny",
        "git clean *": "deny",
        "git rebase *": "deny",
        "git merge *": "deny",
        "git cherry-pick *": "deny",
        "git revert *": "deny",
        "git rm *": "deny",
      },
    },
  },
  "reviewer-correctness": {
    mode: "subagent",
    hidden: true,
    color: "warning",
    tools: { write: false, edit: false, task: false, skill: true },
    permission: {
      bash: {
        "*": "deny",
        "wc *": "allow",
        "ls *": "allow",
        "tree *": "allow",
        "jq *": "allow",
        "git log *": "allow",
        "git show *": "allow",
        "git blame *": "allow",
        "git diff *": "allow",
        "git status *": "allow",
        "git shortlog *": "allow",
        "git ls-tree *": "allow",
        "git ls-files *": "allow",
        "git rev-parse *": "allow",
        "gh pr view *": "allow",
        "gh pr list *": "allow",
        "gh pr diff *": "allow",
        "gh pr status *": "allow",
        "gh pr checks *": "allow",
      },
    },
  },
  "reviewer-security": {
    mode: "subagent",
    hidden: true,
    color: "error",
    tools: { write: false, edit: false, task: false, skill: true },
    permission: {
      bash: {
        "*": "deny",
        "wc *": "allow",
        "ls *": "allow",
        "tree *": "allow",
        "jq *": "allow",
        "git log *": "allow",
        "git show *": "allow",
        "git blame *": "allow",
        "git diff *": "allow",
        "git status *": "allow",
        "git shortlog *": "allow",
        "git ls-tree *": "allow",
        "git ls-files *": "allow",
        "git rev-parse *": "allow",
        "gh pr view *": "allow",
        "gh pr list *": "allow",
        "gh pr diff *": "allow",
        "gh pr status *": "allow",
        "gh pr checks *": "allow",
      },
    },
  },
  "reviewer-maintainability": {
    mode: "subagent",
    hidden: true,
    color: "info",
    tools: { write: false, edit: false, task: false, skill: true },
    permission: {
      bash: {
        "*": "deny",
        "wc *": "allow",
        "ls *": "allow",
        "tree *": "allow",
        "jq *": "allow",
        "git log *": "allow",
        "git show *": "allow",
        "git blame *": "allow",
        "git diff *": "allow",
        "git status *": "allow",
        "git shortlog *": "allow",
        "git ls-tree *": "allow",
        "git ls-files *": "allow",
        "git rev-parse *": "allow",
        "gh pr view *": "allow",
        "gh pr list *": "allow",
        "gh pr diff *": "allow",
        "gh pr status *": "allow",
        "gh pr checks *": "allow",
      },
    },
  },
  "tester-scout": {
    mode: "subagent",
    hidden: true,
    color: "success",
    tools: { write: false, edit: false, task: false, skill: true },
    permission: {
      bash: {
        "*": "deny",
        "wc *": "allow",
        "ls *": "allow",
        "tree *": "allow",
        "jq *": "allow",
        "git log *": "allow",
        "git show *": "allow",
        "git blame *": "allow",
        "git diff *": "allow",
        "git status *": "allow",
        "git shortlog *": "allow",
        "git ls-tree *": "allow",
        "git ls-files *": "allow",
        "git rev-parse *": "allow",
        "npm test *": "allow",
        "npm run test*": "allow",
        "npx *": "allow",
        "pnpm *": "allow",
        "yarn *": "allow",
        "node *": "allow",
      },
    },
  },
  "tester-artisan": {
    mode: "subagent",
    hidden: true,
    color: "warning",
    tools: { write: false, edit: false, task: false, skill: true },
    permission: {
      bash: {
        "*": "deny",
        "wc *": "allow",
        "ls *": "allow",
        "tree *": "allow",
        "jq *": "allow",
        "git log *": "allow",
        "git show *": "allow",
        "git blame *": "allow",
        "git diff *": "allow",
        "git status *": "allow",
        "git shortlog *": "allow",
        "git ls-tree *": "allow",
        "git ls-files *": "allow",
        "git rev-parse *": "allow",
        "npm test *": "allow",
        "npm run test*": "allow",
        "npx *": "allow",
        "pnpm *": "allow",
        "yarn *": "allow",
        "node *": "allow",
      },
    },
  },
  "tester-architect": {
    mode: "subagent",
    hidden: true,
    color: "info",
    tools: { write: false, edit: false, task: false, skill: true },
    permission: {
      bash: {
        "*": "deny",
        "wc *": "allow",
        "ls *": "allow",
        "tree *": "allow",
        "jq *": "allow",
        "git log *": "allow",
        "git show *": "allow",
        "git blame *": "allow",
        "git diff *": "allow",
        "git status *": "allow",
        "git shortlog *": "allow",
        "git ls-tree *": "allow",
        "git ls-files *": "allow",
        "git rev-parse *": "allow",
        "npm test *": "allow",
        "npm run test*": "allow",
        "npx *": "allow",
        "pnpm *": "allow",
        "yarn *": "allow",
        "node *": "allow",
      },
    },
  },
  refiner: {
    mode: "subagent",
    hidden: true,
    color: "accent",
    tools: { task: false, skill: true },
    permission: {
      bash: {
        "*": "allow",
        "git add *": "deny",
        "git stage *": "deny",
        "git push *": "deny",
        "git stash *": "deny",
        "git reset *": "deny",
        "git checkout *": "deny",
        "git restore *": "deny",
        "git clean *": "deny",
        "git rebase *": "deny",
        "git merge *": "deny",
        "git cherry-pick *": "deny",
        "git revert *": "deny",
        "git rm *": "deny",
      },
    },
  },
};

const toLines = (value) => value.replace(/\r\n/g, "\n").split("\n");

export const splitFrontmatter = (content) => {
  const match = content.match(/^---\n([\s\S]*?)\n---\n\n?/);
  if (!match) {
    return { rawFrontmatter: "", body: content };
  }

  return {
    rawFrontmatter: match[1],
    body: content.slice(match[0].length),
  };
};

export const parseFrontmatter = (rawFrontmatter) => {
  const lines = toLines(rawFrontmatter);
  const result = {};

  for (let index = 0; index < lines.length; index += 1) {
    const line = lines[index];
    if (!line.trim()) {
      continue;
    }

    const match = line.match(/^([A-Za-z0-9_-]+):\s*(.*)$/);
    if (!match) {
      continue;
    }

    const [, key, rawValue] = match;

    if (rawValue === ">" || rawValue === "|") {
      const folded = [];
      index += 1;

      while (index < lines.length && (lines[index].startsWith("  ") || lines[index] === "")) {
        folded.push(lines[index].replace(/^  /, ""));
        index += 1;
      }

      index -= 1;
      const normalized = rawValue === ">" ? folded.join(" ") : folded.join("\n");
      result[key] = normalized.replace(/\s+/g, " ").trim();
      continue;
    }

    if (rawValue === "") {
      const listValues = [];
      index += 1;

      while (index < lines.length && lines[index].startsWith("  - ")) {
        listValues.push(lines[index].slice(4).trim());
        index += 1;
      }

      index -= 1;
      result[key] = listValues;
      continue;
    }

    result[key] = rawValue.trim();
  }

  return result;
};

const toOpenCodeSyntax = (content) => content.replace(/\/agentic:([a-z-]+)/g, "/agentic-$1");

const renderKey = (key) => {
  if (/^[A-Za-z0-9_-]+$/.test(key)) {
    return key;
  }

  return JSON.stringify(key);
};

const renderScalar = (value) => {
  if (typeof value === "boolean") {
    return value ? "true" : "false";
  }

  if (typeof value === "number") {
    return String(value);
  }

  return JSON.stringify(String(value));
};

const renderYaml = (entries, indent = "") => {
  const lines = [];

  for (const [key, value] of Object.entries(entries)) {
    if (value === undefined) {
      continue;
    }

    if (Array.isArray(value)) {
      lines.push(`${indent}${renderKey(key)}:`);
      for (const item of value) {
        lines.push(`${indent}  - ${renderScalar(item)}`);
      }
      continue;
    }

    if (value && typeof value === "object") {
      lines.push(`${indent}${renderKey(key)}:`);
      lines.push(renderYaml(value, `${indent}  `));
      continue;
    }

    lines.push(`${indent}${renderKey(key)}: ${renderScalar(value)}`);
  }

  return lines.join("\n");
};

const buildSkillPreamble = (skills) => {
  if (!Array.isArray(skills) || skills.length === 0) {
    return "";
  }

  const lines = [
    "## Skills To Load",
    "",
    `Load these bundled skills proactively when they apply: ${skills.map((skill) => `\`${skill}\``).join(", ")}.`,
    "",
  ];

  return lines.join("\n");
};

export const generateOpenCodeCommandContent = (sourceName) => {
  const sourcePath = resolve(rootDir, "commands", `${sourceName}.md`);
  const sourceContent = readFileSync(sourcePath, "utf8");
  const { rawFrontmatter, body } = splitFrontmatter(sourceContent);
  const frontmatter = parseFrontmatter(rawFrontmatter);

  const output = [
    "---",
    renderYaml({
      description: frontmatter.description ?? "",
      agent: "lead",
    }),
    "---",
    "",
    "<!-- Generated by pnpm run sync:opencode-commands -->",
    "",
    toOpenCodeSyntax(body).trimEnd(),
    "",
  ];

  return output.join("\n");
};

export const generateOpenCodeAgentContent = (sourceName) => {
  const sourcePath = resolve(rootDir, "agents", `${sourceName}.md`);
  const sourceContent = readFileSync(sourcePath, "utf8");
  const { rawFrontmatter, body } = splitFrontmatter(sourceContent);
  const frontmatter = parseFrontmatter(rawFrontmatter);
  const config = OPEN_CODE_AGENT_CONFIG[sourceName];

  if (!config) {
    throw new Error(`Missing OpenCode config for agent '${sourceName}'`);
  }

  const preamble = buildSkillPreamble(frontmatter.skills);
  const output = [
    "---",
    renderYaml({
      description: frontmatter.description ?? "",
      mode: config.mode,
      hidden: config.hidden,
      color: config.color,
      tools: config.tools,
      permission: config.permission,
    }),
    "---",
    "",
    "<!-- Generated by pnpm run sync:opencode-agents -->",
    "",
    preamble,
    toOpenCodeSyntax(body).trimEnd(),
    "",
  ];

  return output.join("\n");
};

export const normalizeGeneratedContent = (content) => content.replace(/\r\n/g, "\n").trim();
