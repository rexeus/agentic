---
description: Run a multi-agent quality gate on current changes. Checks correctness, complexity, and tests in parallel.
allowed-tools: Read, Grep, Glob, Bash(git *), Bash(gh *), Bash(npm *), Bash(npx *), Bash(pnpm *), Bash(yarn *), Agent
argument-hint: "[--base <branch>] [--staged]"
---

# Verify

Pre-ship quality gate. Deploys four parallel agents to answer one question:
**are these changes ready to ship?**

**When to use this vs `/agentic:review`:**
Use **verify** as the final check before committing or creating a PR — it runs
the full reviewer trio _and_ tests together. Use **review** for a focused code
review that stops short of running or writing tests.

**Usage:**

- `/agentic:verify` — verify all changes on the current branch vs. default branch
- `/agentic:verify --staged` — verify only staged changes
- `/agentic:verify --base develop` — verify against a specific base branch

## What It Checks

Four agents run in parallel, each a distinct specialist with its own lens:

| Agent                        | Focus                                                         | Mode            |
| ---------------------------- | ------------------------------------------------------------- | --------------- |
| **reviewer-correctness**     | Logic, concurrency, error handling, edge cases                | Read-only       |
| **reviewer-security**        | Injection, AuthN/AuthZ, secrets, input validation, exposure   | Read-only       |
| **reviewer-maintainability** | Naming, conventions, complexity, coupling, readability        | Read-only       |
| **tester**                   | Run existing tests — or write tests if none cover the changes | Write or Assess |

## Rules

- **Never modify source code.** This command verifies. It does not fix.
  The tester may create test files, but source code is untouched.
- **Never skip agents.** All four run, every time. A partial quality gate
  is a false quality gate. If a lens does not apply to the diff (e.g.,
  a pure-internal refactor with no trust boundary touched), the
  specialist still runs and returns a short PASS — the fact that it
  looked and found nothing is itself evidence.
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

Launch all four in parallel. Brief each precisely. Each reviewer is a
distinct specialist — do not fan out a single briefing with differing
"focus" overrides.

**`reviewer-correctness`:**

> Scope: <changed files>. Diff baseline: <base branch or staged>.
> Context: <summary of what changed and why, derived from commits>.
> Focus areas (optional): <specific correctness concerns suggested by
> the diff, e.g., "concurrency on shared state introduced at <file>",
> "new error path in <handler>">.

**`reviewer-security`:**

> Scope: <changed files>. Diff baseline: <base branch or staged>.
> Context: <summary of what changed and why, derived from commits>.
> Trust boundaries: <untrusted inputs that cross into this diff:
> public HTTP, user input, filesystem, env vars, message queues — or
> "none identified in this diff" if the change is internal>.
> Deployment context: <public vs internal, multi-tenant vs
> single-tenant, known data sensitivity — or "unknown" if not
> determinable from the repo>.

**`reviewer-maintainability`:**

> Scope: <changed files>. Diff baseline: <base branch or staged>.
> Context: <summary of what changed and why, derived from commits>.
> The agent reads CLAUDE.md and neighboring code itself; do not
> pre-summarize project conventions.

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

When all four agents return:

1. **Preserve the lens label.** Every reviewer finding carries its
   lens tag (`[correctness]`, `[security]`, `[maintainability]`) so
   the human can see which specialist flagged what.

2. **Deduplicate only at the intersection.** Two reviewers flagging
   literally the same line for literally the same reason collapse into
   one finding tagged with both lenses. Two reviewers seeing related
   issues from their own angles remain separate findings — do not
   compress away the perspective.

3. **Categorize findings:**
   - **Blocking** — Critical findings from any reviewer, or test
     failures. Must fix before shipping.
   - **Warning** — Significant concerns from any reviewer. Should fix,
     but not necessarily now.
   - **Advisory** — Suggestions, minor improvements. Nice to fix.

4. **Produce the Quality Report:**

```markdown
## Quality Report: <scope description>

**Verdict:** PASS | FAIL | CONDITIONAL
**Lens verdicts:** correctness: <...> | security: <...> | maintainability: <...>

### Blocking

- <findings that must be fixed — empty if none, lens labels preserved>

### Warnings

- <findings that should be fixed — empty if none, lens labels preserved>

### Advisory

- <suggestions and minor improvements — empty if none>

### Simplification Opportunities

- <maintainability findings tagged as complexity — empty if code is clean>

### Test Results

- Tests run: <count> passed, <count> failed
- Tests written: <count new tests, if tester was in write mode>
- Coverage gaps: <remaining gaps identified>

### Verdict Reasoning

<1-2 sentences explaining the verdict, naming which lens drove it>
```

### Step 5: Verdict

The composite verdict is the **worst** across the three lens verdicts
and the test result — one FAIL anywhere fails the gate.

- **PASS** — All three lenses PASS and tests are green. Ship it.
- **FAIL** — Any lens FAIL, or test failures. List what needs fixing
  with its lens label intact.
- **CONDITIONAL** — Warnings only, no blockers, tests green. Present
  findings and let the user decide.

### Step 6: Suggest Next Steps

Based on the verdict:

- **PASS** → "All green. Ready for `/agentic:commit` or `/agentic:pr`."
- **FAIL** → "These findings need fixing. Should I send the developer to
  address them?" (If yes, transition to developer with specific findings.)
- **CONDITIONAL** → "Warnings but no blockers. Fix now or ship as-is?"
- **Simplification findings** → "Simplification opportunities detected.
  `/agentic:simplify` can handle these."
