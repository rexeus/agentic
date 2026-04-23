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

Launch four agents in parallel — the three reviewer specialists plus a
read-only tester — each with the full diff and context. Every reviewer
is a distinct specialist with its own identity and loaded skills; the
briefings share core fields and differ only where the lens demands it.

**Agent 1: `reviewer-correctness`**
Lens: logic errors, concurrency, error handling, edge cases, resource
lifecycle, plan alignment.
Briefing: Scope, Diff baseline, Context. Add Focus areas only when a
specific correctness concern applies (e.g., "concurrency on the
counter", "failure path when upstream is unreachable").

**Agent 2: `reviewer-security`**
Lens: injection, AuthN/AuthZ, secrets, input validation at trust
boundaries, data exposure, SSRF/deserialization, crypto, supply chain.
Briefing: Scope, Diff baseline, Context. Add Trust boundaries and
Deployment context when identifiable from the diff or repo (public
endpoint vs internal tool, multi-tenant vs single-tenant).

**Agent 3: `reviewer-maintainability`**
Lens: naming, conventions, complexity, cohesion, coupling,
readability, abstraction fit.
Briefing: Scope, Diff baseline, Context. The agent reads CLAUDE.md and
neighboring code itself — do not pre-summarize project conventions.

**Agent 4: `tester` (assessment mode)**
Focus: Are the changes adequately tested? What edge cases are missing?
Mode: Read-only assessment. Do NOT write tests — only assess and report
gaps. This overrides the tester's default advisory scope only to the
extent that no test files are produced for this specific use case.

Each agent scores findings with confidence (0-100). Threshold: 80.

### Step 4: Synthesize

Collect findings from all four agents. Preserve the lens label on every
reviewer finding (`[correctness]`, `[security]`, `[maintainability]`)
so the reader can see which specialist flagged what. Deduplicate only
when two reviewers flag literally the same line for the same reason —
when a finding genuinely sits at the intersection of two lenses,
report it once with both lenses listed.

### Step 5: Output

```
## Code Review

**Scope:** <what was reviewed>
**Files:** <count>
**Findings:** <count> (<critical> critical, <warnings> warnings, <suggestions> suggestions)
**Lens verdicts:** correctness: <PASS|FAIL|CONDITIONAL> | security: <...> | maintainability: <...>

### Critical
**[Critical | 95 | correctness]** `file:line` — description
Why: explanation

### Warnings
**[Warning | 85 | security]** `file:line` — description
Why: explanation

### Suggestions
**[Suggestion | 82 | maintainability]** `file:line` — description

### Test Coverage
- Covered: <what's tested>
- Gaps: <what's missing>
- Recommended: <specific tests to add>

---
**Confidence threshold: 80.** Lower-confidence findings were excluded.
**Composite verdict:** worst of the three lens verdicts.
To address findings: `/agentic:develop continue`
```

### False Positive Policy

Do NOT flag:

- Style preferences not codified in agent instruction files
  (CLAUDE.md, AGENTS.md, or equivalent) or the conventions skill
- Issues linters or type checkers catch automatically
- Runtime-dependent speculative issues
- Explicitly suppressed issues (ignore comments)
- Pre-existing Warning- or Suggestion-severity issues outside the
  current diff

### Pre-existing Critical Findings

Do flag pre-existing **Critical**-severity issues that the current
work naturally surfaces in adjacent code. Tag them `[pre-existing]`
next to the file:line reference so the reader sees the scope
immediately. Do not expand the net to hunt — only report what the
diff puts in front of you.
