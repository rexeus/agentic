---
description: Independent multi-agent code review. Reviews different aspects in parallel with specialized agents.
allowed-tools: Bash(git *), Bash(gh *), Read, Grep, Glob, Agent
argument-hint: "[PR-number | --staged | --branch | --commits=N]"
---

# Review

Run an independent, multi-agent code review. Different agents examine different
aspects of the code in parallel for thorough, unbiased analysis.

**When to use this vs `/agentic:verify`:**
Use **review** when you want a focused code review — finding bugs, security
issues, and convention violations. Use **verify** when you want a full pre-ship
quality gate that also runs tests and checks for simplification opportunities.

**Usage:**

- `/agentic:review` — will ask what to review
- `/agentic:review 42` — review PR #42
- `/agentic:review --staged` — review staged changes
- `/agentic:review --branch` — review current branch vs base
- `/agentic:review --commits=3` — review the last 3 commits

## Workflow

### Step 1: Determine Scope

Parse `$ARGUMENTS` to determine what to review:

- **Number** → PR review via `gh pr diff <number>`
- **`--staged`** → staged changes via `git diff --cached`
- **`--branch`** → branch diff. Detect the default branch dynamically via
  `git symbolic-ref refs/remotes/origin/HEAD`, then `git diff <base>...HEAD`
- **`--commits=N`** → recent commits via `git diff HEAD~N...HEAD`
- **No arguments** → Ask the user:
  "What should I review? Options:
  1. A pull request (provide PR number)
  2. Staged changes (--staged)
  3. Current branch vs main (--branch)
  4. Recent commits (--commits=N)"

Do NOT guess. If the scope is unclear, ask.

### Step 2: Gather Context

Collect in parallel:

- The diff (from the determined scope)
- CLAUDE.md files in the repository and affected directories
- PR description and comments (if reviewing a PR)
- Recent commit messages for context

If the diff is empty, report "Nothing to review." and stop.

### Step 3: Parallel Review

Launch 3 review agents in parallel, each with the full diff and context:

**Agent 1: Correctness Review** (reviewer agent)
Focus: Logic errors, bugs, null access, race conditions, missing error handling.
Lens: Correctness + Security + Plan Alignment from the reviewer's review lenses.

**Agent 2: Convention Review** (reviewer agent)
Focus: Naming, structure, patterns, CLAUDE.md compliance, code style.
Lens: Conventions + Quality Patterns from the reviewer's review lenses.

**Agent 3: Test Coverage Assessment** (tester agent, assessment mode)
Focus: Are the changes adequately tested? What edge cases are missing?
Mode: Read-only assessment. Do NOT write tests — only assess and report gaps.
This overrides the tester's default write mode for this specific use case.

Each agent scores findings with confidence (0-100). Threshold: 80.

### Step 4: Synthesize

Collect findings from all 3 agents. Deduplicate (same issue found by
multiple agents counts once, with the highest confidence score).

### Step 5: Output

```
## Code Review

**Scope:** <what was reviewed>
**Files:** <count>
**Findings:** <count> (<critical> critical, <warnings> warnings, <suggestions> suggestions)

### Critical
**[Critical | 95]** `file:line` — description
Why: explanation

### Warnings
**[Warning | 85]** `file:line` — description
Why: explanation

### Suggestions
**[Suggestion | 82]** `file:line` — description

### Test Coverage
- Covered: <what's tested>
- Gaps: <what's missing>
- Recommended: <specific tests to add>

---
**Confidence threshold: 80.** Lower-confidence findings were excluded.
To address findings: `/agentic:develop continue`
```

### False Positive Policy

Do NOT flag:

- Pre-existing issues not in the current diff
- Style preferences not in CLAUDE.md or conventions skill
- Issues linters or type checkers catch automatically
- Runtime-dependent speculative issues
- Explicitly suppressed issues (ignore comments)
