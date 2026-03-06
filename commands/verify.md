---
description: Run a multi-agent quality gate on current changes. Checks correctness, complexity, and tests in parallel.
allowed-tools: Read, Grep, Glob, Bash(git *), Bash(gh *), Bash(npm *), Bash(npx *), Bash(pnpm *), Bash(yarn *), Agent
argument-hint: "[--base <branch>] [--staged]"
---

# Verify

Pre-ship quality gate. Deploys three parallel agents to answer one question:
**are these changes ready to ship?**

**When to use this vs `/agentic:review`:**
Use **verify** as the final check before committing or creating a PR — it runs
correctness review, complexity analysis, AND tests together. Use **review** for
a focused code review without running tests or checking complexity.

**Usage:**

- `/agentic:verify` — verify all changes on the current branch vs. default branch
- `/agentic:verify --staged` — verify only staged changes
- `/agentic:verify --base develop` — verify against a specific base branch

## What It Checks

Three agents run in parallel, each with a different lens:

| Agent                      | Focus                                                         | Mode            |
| -------------------------- | ------------------------------------------------------------- | --------------- |
| **Reviewer** (correctness) | Bugs, security, conventions                                   | Read-only       |
| **Reviewer** (complexity)  | Simplification opportunities, over-engineering, readability   | Read-only       |
| **Tester**                 | Run existing tests — or write tests if none cover the changes | Write or Assess |

## Rules

- **Never modify source code.** This command verifies. It does not fix.
  The tester may create test files, but source code is untouched.
- **Never skip agents.** All three run, every time. A partial quality gate
  is a false quality gate.
- **Present findings honestly.** Don't soften blocking issues. Don't inflate
  advisory notes. Signal over noise.

## Workflow

### Step 1: Detect Scope

Run in parallel:

```bash
git branch --show-current
```

```bash
gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name' 2>/dev/null || echo 'main'
```

```bash
git diff --stat
```

```bash
git diff --cached --stat
```

Determine the scope:

- If `$ARGUMENTS` contains `--staged` — scope is staged changes only
  (`git diff --cached`)
- If `$ARGUMENTS` contains `--base <branch>` — scope is diff against
  that branch (`git diff <branch>...HEAD`)
- Otherwise — scope is diff against the repo's default branch
  (`git diff <default>...HEAD`)

If there are no changes in scope, report "Nothing to verify." and stop.

### Step 2: Gather Context

```bash
git diff <scope> --stat
```

```bash
git diff <scope>
```

```bash
git log <base>..HEAD --oneline
```

Read the full diff. Identify:

- Which files changed and how
- Which test files exist for the changed code
- Whether the project has a test runner configured (`package.json` scripts,
  test config files)

### Step 3: Deploy Agents

Launch all three in parallel. Brief each precisely:

**Reviewer 1 — Correctness:**

> Scope: <changed files>. Diff baseline: <base branch or staged>.
> Context: <summary of what changed and why, derived from commits>.
> **Focus: correctness, security, and convention adherence.**
> Ignore complexity and style preferences — the other reviewer handles that.

**Reviewer 2 — Complexity:**

> Scope: <changed files>. Diff baseline: <base branch or staged>.
> Context: <summary of what changed and why, derived from commits>.
> **Focus: complexity and simplification opportunities.** Flag:
> over-engineering, unnecessary abstractions, functions that do too much,
> deep nesting, code that could be simpler without losing clarity.
> Do NOT flag style preferences. Only flag genuine complexity.

**Tester:**

Determine mode based on test coverage:

- Test files exist for the changed code → `mode: assess` (analyze gaps,
  run existing tests)
- No test files cover the changed code → `mode: write` (create tests,
  then run them)
- Mixed (some covered, some not) → `mode: write` (fill the gaps)

> Files changed: <list>. Test command: <from package.json or config>.
> Test framework: <detected>. Mode: <write or assess>.
> Dev notes: <brief context about what changed>.

### Step 4: Synthesize Results

When all three agents return:

1. **Deduplicate** — If both reviewers flag the same issue, report it once
   with the higher severity.

2. **Categorize findings:**
   - **Blocking** — Bugs, security issues, test failures. Must fix before shipping.
   - **Warning** — Significant concerns. Should fix, but not necessarily now.
   - **Advisory** — Suggestions, minor improvements. Nice to fix.

3. **Produce the Quality Report:**

```markdown
## Quality Report: <scope description>

**Verdict:** PASS | FAIL | CONDITIONAL

### Blocking

- <findings that must be fixed — empty if none>

### Warnings

- <findings that should be fixed — empty if none>

### Advisory

- <suggestions and minor improvements — empty if none>

### Simplification Opportunities

- <complexity reviewer's findings — empty if code is clean>

### Test Results

- Tests run: <count> passed, <count> failed
- Tests written: <count new tests, if tester was in write mode>
- Coverage gaps: <remaining gaps identified>

### Verdict Reasoning

<1-2 sentences explaining the verdict>
```

### Step 5: Verdict

- **PASS** — No blocking findings. Tests green. Ship it.
- **FAIL** — Blocking findings or test failures. List what needs fixing.
- **CONDITIONAL** — Warnings only, no blockers. Present findings and let
  the user decide.

### Step 6: Suggest Next Steps

Based on the verdict:

- **PASS** → "All green. Ready for `/agentic:commit` or `/agentic:pr`."
- **FAIL** → "These findings need fixing. Should I send the developer to
  address them?" (If yes, transition to developer with specific findings.)
- **CONDITIONAL** → "Warnings but no blockers. Fix now or ship as-is?"
- **Simplification findings** → "Simplification opportunities detected.
  `/agentic:simplify` can handle these."
