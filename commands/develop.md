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

Deploy **developer** with:

- The architecture plan (from step 3 or from `/agentic:plan`)
- The scout/analyst findings (from step 2)
- Clear scope boundaries

The developer implements incrementally. After each logical unit:

- Verify the code compiles/parses
- Run existing tests to catch regressions

### Step 5: Verify

Launch in parallel:

**reviewer** — Analyze the implementation for:

- Correctness, security, convention adherence
- Alignment with the architecture plan
- Confidence-scored findings (threshold 80)

**tester** — Write and run tests for:

- New functionality (unit tests)
- Edge cases identified in the plan
- Integration points

### Step 6: Iterate

If the reviewer or tester found issues:

1. Summarize all findings for the user
2. Ask whether to fix now or note for later
3. If fixing: send the developer back with specific findings
4. Re-run verification after fixes

Repeat until the reviewer passes and tests are green,
or the user decides to stop.

### Step 7: Refine (optional)

If the reviewer flagged complexity, deep nesting, or convoluted logic
(severity Warning or above), or if the user requests simplification:

1. Ask the user whether to simplify before committing
2. If yes: deploy the **refiner** with the reviewer's findings and the
   current file list
3. The refiner simplifies incrementally, verifying tests after each change
4. Re-run the **tester** to confirm nothing broke

Skip this step if the code is already clean and the reviewer had no
complexity-related findings.

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
