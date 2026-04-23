---
description: Simplify existing code. Reduces complexity, improves readability, and removes unnecessary abstractions — without changing behavior.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, Agent
argument-hint: "<file, function, or module to simplify>"
---

# Simplify

Simplify existing code. This command takes working code and distills it
to its essence — fewer moving parts, same behavior, clearer intent.

**Usage:**

- `/agentic:simplify src/auth/session.ts` — simplify a specific file
- `/agentic:simplify src/payments/` — simplify a module
- `/agentic:simplify the checkout flow` — simplify by concept

## Philosophy

Elegance is achieved not when there is nothing left to add, but when there
is nothing left to take away. This command exists to turn working code into
_inevitable_ code — so clear that no one would think to write it differently.

## Workflow

### Step 1: Determine Scope

Parse `$ARGUMENTS` to understand what to simplify:

- **File path** → simplify that file
- **Directory** → simplify the module
- **Concept** → scout for relevant files, then simplify
- **No arguments** → Ask the user:
  "What should I simplify? Options:
  1. A specific file (provide path)
  2. A module or directory
  3. Recent changes (`--recent` for last commit's files)
  4. Complexity hotspots (`--hotspots` for auto-detection)"

If `--recent` is specified, get changed files from `git diff HEAD~1 --name-only`.

If `--hotspots` is specified, deploy the **scout** to identify files with
high nesting, long functions, or excessive complexity.

### Step 2: Understand Before Simplifying

Deploy the **analyst** to study the target code:

- What is this code's purpose?
- How does data flow through it?
- What are the dependencies and callers?
- Where is the accidental complexity vs. essential complexity?

This step is critical. You cannot simplify what you do not understand.
Accidental complexity can be removed. Essential complexity cannot.

### Step 3: Establish Baseline

Before any changes:

1. Run the full test suite — record the result
2. Note line counts for files in scope
3. Identify the specific complexities to address

If tests are not passing before you start, **stop**. Report the failing
tests and ask the user how to proceed. Never simplify broken code.

### Step 4: Simplify

Deploy the **refiner** with:

- The analyst's findings (from step 2)
- The baseline metrics (from step 3)
- Clear scope boundaries

The refiner works incrementally — one simplification at a time,
verifying tests after each change.

### Step 5: Verify

Run the existing test suite, then deploy **tester-artisan** and
**tester-architect** in parallel to confirm:

- All existing tests still pass (raw execution: `pnpm test` etc.)
- No behavior has changed (tester-architect verifies testability did
  not regress)
- Test craft stayed intact (tester-artisan confirms no readability
  drift introduced by the simplification)

`tester-scout` is not deployed for simplify — the refiner adds no
behavior, so coverage is unchanged by construction.

If either tester finds regressions, send the refiner back to revert
the problematic simplification. If tester-artisan specifies a test
rewrite, the developer implements it in a separate follow-up.

### Step 6: Summary

When complete, present:

```
## Simplification Summary

### Scope
<what was simplified>

### Before → After
- Lines: <before> → <after> (<net change>)
- Files touched: <count>

### Simplifications
1. **<description>** — `path/file.ts`
   <what changed and why it's simpler>

2. **<description>** — ...

### Preserved
- All <count> tests passing
- No behavior changes

### Left Alone
- <areas considered but intentionally untouched, with reasoning>

### Next Steps
- <any follow-up work or deeper simplifications the user could consider>
```

Suggest running `/agentic:review --staged` to verify the simplifications,
then `/agentic:commit` to commit them.
