---
description: Start implementation of a planned feature or task. Runs the full pipeline from understanding through testing.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, Agent
argument-hint: "<task description or 'continue'>"
---

# Develop

Start implementation. This command runs the full development pipeline:
understand → design → build → verify.

**Usage:**

- `/agentic:develop Implement the token refresh logic from the plan`
- `/agentic:develop continue` — continue from where the last session left off

## Prerequisites

This command works best after `/agentic:plan` has produced an approved plan.
If no plan exists, the command will create a lightweight plan first.

## Workflow

### Step 0: Create Progress Tracker

Before starting any work, create a task list that maps the full pipeline
for this task. Each task names the responsible agent and describes the
concrete step. Example:

1. "Scout the relevant modules" — scout (skip if already done)
2. "Design implementation approach" — architect (skip if plan exists)
3. "Implement feature X and its tests" — developer
4. "Review for correctness" — reviewer-correctness
5. "Review for security" — reviewer-security
6. "Review for maintainability" — reviewer-maintainability
7. "Audit test coverage" — tester-coverage
8. "Audit test craft" — tester-artisan
9. "Audit testability" — tester-architect
10. "Refine if needed" — refiner (optional)

Steps 4–9 run in parallel.

Mark tasks `in_progress` as you start them and `completed` when done.
Skip tasks that were already covered by a prior `/agentic:plan` run.

### Step 1: Establish Context

If `$ARGUMENTS` contains "continue":

1. Check `git log --oneline -5` for recent commits
2. Check `git diff` for unstaged changes (work in progress)
3. Check `git diff --cached` for staged changes
4. Present your understanding of the current state to the user for confirmation
   before proceeding

Otherwise, determine the task:

- Is there an existing plan from `/agentic:plan`? Use it.
- Is `$ARGUMENTS` a clear, self-contained task? Proceed directly.
- Is the task ambiguous? Ask the user to clarify, or suggest running
  `/agentic:plan` first.

### Step 2: Reconnaissance (if needed)

If the task touches unfamiliar code:

1. Deploy **scout** to map the relevant modules
2. If the scout returns insufficient context, ask the user for guidance
3. Deploy **analyst** if the scout reveals complexity

Skip this step if a recent `/agentic:plan` already covered the codebase.

### Step 3: Design (if needed)

If no architecture plan exists:

1. Deploy **architect** to produce a lightweight implementation plan
2. Present the plan to the user for approval
3. Wait for confirmation before proceeding
4. If the user rejects the plan, iterate on the design or ask for
   clarification. Do not proceed to implementation without approval.

Skip this step if `/agentic:plan` already produced an approved design.

### Step 4: Implement

Deploy **developer** with a briefing concrete enough that the developer
can start coding immediately — no interpretation, no planning needed.

**Required in every developer briefing:**

1. **Implementation plan** — Pass through the architect's full plan, not a
   summary. Must include: files to create/modify, interfaces/signatures,
   implementation order, and edge cases to handle.
2. **Scout report** — Codebase patterns, naming conventions, file structure.
3. **Scope boundary** — What is in scope, what is explicitly out.
4. **Test command** — How to run the test suite.

**Rule of thumb:** If you can read your briefing and immediately know which
file to open and what to type, it's concrete enough. If you'd need to
"figure out the approach first" — it's too vague and the developer will
plan instead of code.

The developer implements incrementally. After each logical unit:

- Verify the code compiles/parses
- **Write the tests for that unit in the same step** — the developer
  is the sole author of tests (the tester specialists are advisory,
  never write code)
- Run existing tests to catch regressions

### Step 5: Verify

Launch **six agents in parallel** — the reviewer trio + the tester
trio. All six are advisory; none of them modifies files.

**reviewer-correctness** — Logic, concurrency, error handling, edge
cases, plan alignment. Confidence-scored findings (threshold 80).

**reviewer-security** — Injection, AuthN/AuthZ, secrets, input
validation at trust boundaries, data exposure. Confidence-scored
findings (threshold 80). Include Trust boundaries and Deployment
context in the briefing when determinable from the diff.

**reviewer-maintainability** — Naming, conventions, complexity,
cohesion, coupling, readability, abstraction fit. Confidence-scored
findings (threshold 80).

**tester-coverage** — Behavioral coverage audit. Identifies scenarios
the developer's tests missed: boundaries, state transitions,
regressions, concurrency. Produces Test Specifications the developer
implements.

**tester-artisan** — Test craft audit. Reviews the tests the
developer wrote (and the pre-existing tests) for readability, naming,
DAMP, helper design, and anti-patterns. Produces rename/split/delete
recommendations.

**tester-architect** — Testability audit. Asks whether the code is
structurally testable. Flags coupling, mock coercion, and design
smells visible through test pain. Can return BLOCKING when the
architecture forces principle violations.

### Step 6: Iterate

If any reviewer or any tester found issues:

1. Summarize findings across all six lenses for the user, preserving
   the lens label on each finding
2. Ask whether to fix now or note for later
3. If fixing: send the developer back with the consolidated
   findings and Master Test Advisory transformed into concrete
   instructions. The developer implements both code fixes AND the
   tester trio's test specifications — they are the sole author of
   tests.
4. Re-run verification after fixes — only re-deploy the specialist(s)
   whose lens flagged issues

**Special case: `tester-architect` BLOCKING.** When the testability
verdict is BLOCKING, the code cannot be cleanly tested in its current
shape. Route to the architect for a testability refactor before
writing more tests. The developer implements the refactor, then Step 5
re-runs on the refactored shape.

Repeat until every specialist passes and tests are green, or the user
decides to stop.

### Step 7: Refine (optional)

If `reviewer-maintainability` flagged complexity, deep nesting, or
convoluted logic (severity Warning or above), or if the user requests
simplification:

1. Ask the user whether to simplify before committing
2. If yes: deploy the **refiner** with the maintainability findings and
   the current file list
3. The refiner simplifies incrementally, verifying tests after each change
4. Re-run **tester-artisan** and **tester-architect** to confirm the
   simplification did not regress craft or testability

Skip this step if the code is already clean and `reviewer-maintainability`
had no complexity-related findings.

### Step 8: Summary

When complete, present:

```
## Development Summary

### What was built
<brief description>

### Files changed
- `path/file.ts` — created / modified (what changed)

### Test results
- X tests written, all passing
- Coverage: X% for new code

### Review findings
- X issues found, X fixed, X deferred

### Next steps
- <any remaining work or follow-up tasks>
```

Suggest running `/agentic:commit` to commit the changes.
