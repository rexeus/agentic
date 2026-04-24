---
name: test-advisory-format
description: The Test Advisory output format used by all tester specialists (tester-coverage, tester-artisan, tester-architect) and understood by the Lead for synthesis. Defines sections, severity tags, dual verdict, and the specification template. Loaded whenever a task produces or consumes a Test Advisory.
user-invocable: false
---

# Test Advisory Format

All tester specialists produce output in this exact format. The Lead
merges specialist advisories into a single master advisory of the
same shape.

## Top-Level Structure

```
## Test Advisory: <target> — <your specialization>

**Execution:** PASS | FAIL | N/A
**Quality:** CLEAN | CONCERNS | BLOCKING
**Lens:** coverage | craft | testability

### Test Suite Status
### Existing Test Audit
### Test Specifications
### Failures in Existing Tests
### Characterization Tests Needed
### Trade-offs and Design Concerns
### Summary for Developer
```

Sections not applicable are stated as "N/A" with a one-line reason,
never silently omitted.

## Verdict Rules

Two independent dimensions.

### Execution

- All existing tests for the affected code green: **PASS**
- Any existing test red: **FAIL**
- No tests exist for the affected code: **N/A**

### Quality

- New specifications clean, existing tests follow principles, no
  anti-patterns: **CLEAN**
- Specifications are sound, but existing tests have Advisory-level
  issues, or minor trade-offs were accepted with reasoning:
  **CONCERNS**
- Code is structurally untestable without violating principles, or
  existing tests have Blocking violations that block further work:
  **BLOCKING**

A BLOCKING Quality with PASS Execution is a valid and important
combination: the tests happen to work, but the foundation is unsound.
This is the signal to send the developer back to design.

## Section Templates

### Test Suite Status

```
- Tests run: X passed, Y failed
- Affected modules with existing test files: <list>
- Affected modules without existing test files: <list>
```

### Existing Test Audit

One block per concerning test, or `No concerns found.` when clean.

```
[Severity] `<file>:<line>` (`<test name>`)
Principle violated: <name>
Evidence: <one-line summary of the problematic pattern>
Recommendation: <rewrite | split | delete | refactor to fake>
```

Severity is `Blocking` (must be addressed before merge) or `Advisory`
(should be addressed, does not block).

When the finding concerns a pre-existing test (not introduced by the
current diff) and severity is Blocking, append `[pre-existing]` to
the file:line reference:

```
[Blocking] `<file>:<line> [pre-existing]` (`<test name>`)
```

Advisory-level pre-existing issues are out of scope — see `testing-core`
for the full rule.

### Test Specifications

One block per test the developer should add.

```
**Behavior:** <what is being verified>
**Scope:** unit | integration | edge | regression | characterization
**Setup:** <what to arrange; name the fake or fixture to use>
**Action:** <what to invoke>
**Assertion:** <what to verify>
**Notes:** <principle reminders; e.g., "use in-memory fake, not mock">
```

Each field is a single line or short list. Specifications dense enough
to implement mechanically.

### Failures in Existing Tests

One block per failure, or omit section if none.

```
[FAIL] `<file>` (`<test name>`)
Location: `<path>:<line>`
Expected: <...>
Got: <...>
Likely cause: bug in source | bug in test | flaky
```

### Characterization Tests Needed

For legacy code under modification without existing tests.

```
**Target:** <function or module>
**Rationale:** <why characterization is needed>
**Observed behavior:** <input-output pairs documented from source
inspection or live probing at HEAD>
**Marking:** Developer groups these under
`describe("characterization: current behavior, not verified as correct")`
and suffixes each test name with `(characterization)`.
```

### Trade-offs and Design Concerns

Free-form. Concerns that suggest the code itself, not the tests, is
the problem. These are forwarded to reviewer and developer; never
swallowed.

### Summary for Developer

One short paragraph. Priority order of what to implement first.

## Severity Tagging

Every finding carries exactly one severity:

- **Blocking.** Must be addressed before the change merges. Either
  directly harmful (flaky test, green test that does not actually
  verify the claim, anti-pattern that will mislead future readers) or
  structurally load-bearing (coupling problem that will force future
  tests to break the principles).

- **Advisory.** Should be addressed, does not block. Improvements that
  raise quality but whose absence does not make the change unsafe.

Findings without severity are invalid output.

## Synthesis (for the Lead)

When multiple specialists produce advisories for the same change, the
Lead synthesizes into a single master advisory using the same
top-level template, with one header addition:

```
## Master Test Advisory: <target>

**Execution:** PASS | FAIL | N/A
**Quality:** CLEAN | CONCERNS | BLOCKING

**Synthesized from:**
- tester-coverage (<quality verdict>)
- tester-artisan (<quality verdict>)
- tester-architect (<quality verdict>)
```

Rules:

- **Execution verdict:** identical across all specialists (same test
  run); take any. Disagreement signals an execution error; re-dispatch.
- **Quality verdict:** worst-of-all wins. One BLOCKING makes the
  master BLOCKING.
- **Test Suite Status:** identical; take any.
- **Existing Test Audit:** primarily from tester-artisan. Augment with
  coupling-rooted findings from tester-architect (cite architectural
  cause) and coverage-rooted findings from tester-coverage (tests claiming
  to verify a behavior they do not actually verify). Deduplicate by
  `file:line`; when multiple specialists find the same test, merge
  into one entry with the combined principle list.
- **Test Specifications:** primarily from tester-coverage. Union with any
  specs from the others that introduce a distinct behavior.
  Deduplicate by behavior; when two specialists specify the same
  behavior with different setup, prefer the specification that uses a
  fake over one that uses a mock; among fakes, prefer the simpler
  setup.
- **Failures in Existing Tests:** identical; take any.
- **Characterization Tests Needed:** union, deduplicated by target.
- **Trade-offs and Design Concerns:** primarily from tester-architect.
  Include design-level findings from tester-coverage (gaps that exist because
  code is untestable) and artisan (unreadability whose root is
  architectural). Each concern names its author specialist inline.
- **Summary for Developer:** the Lead writes this fresh, integrating
  priorities across all three advisories in this order:
  1. Regression tests (always first).
  2. Design refactors if Quality is BLOCKING.
  3. High-severity existing test rewrites.
  4. New behavioral specifications in priority order.
  5. Craft polish and minor refactors.

When Quality is BLOCKING, the master advisory is primarily a referral
back to design; test specifications from tester-coverage may be deferred until
the design is resolved. The Lead states this explicitly in the
Summary for Developer.
