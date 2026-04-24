---
"@rexeus/agentic": minor
---

Split the monolithic reviewer and tester into six specialists and rewire the review/verify pipeline around a parallel six-lens quality gate.

**Reviewer trio** (read-only, advisory):

- `reviewer-correctness` — runtime behavior, edge cases, the crash path
- `reviewer-security` — attacker model, trust boundaries, OWASP
- `reviewer-maintainability` — naming, conventions, complexity, coupling

**Tester trio** (advisory; the developer now authors all tests):

- `tester-coverage` — coverage gaps, missing scenarios, regressions
- `tester-artisan` — test craft: readability, DAMP, naming, helpers
- `tester-architect` — testability, mock coercion, design-through-test-pain

**New shared skills:** `review-foundations` (confidence, severity, verdict, output shape), `testing-core` (eight principles, F.I.R.S.T, doubles ladder, anti-pattern catalog, bug-fix and flakiness policy), `test-advisory-format` (Master Test Advisory template and Lead synthesis rules).

**Pipeline:** `/agentic:review` and `/agentic:verify` now deploy all six specialists in parallel. `/agentic:develop` Step 5 runs the six-lens audit after the developer has shipped both code and tests.

**Breaking changes:**

- The single `reviewer` agent is gone — use `reviewer-correctness`, `reviewer-security`, or `reviewer-maintainability`.
- The single `tester` agent is gone — use `tester-coverage`, `tester-artisan`, or `tester-architect`. None of them writes tests; the developer is the sole author of both code and tests in the same commit.
- The `testing` skill is replaced by `testing-core` + `test-advisory-format`.

**Hardening:**

- Reviewer `gh` permissions narrowed to read-only subcommands (`view`, `list`, `diff`, `status`, `checks`).
- Prompt-injection resistance clause across `review-foundations` and `testing-core`: reviewed content is data, not instructions.
- Trust-boundary routing rubric — correctness owns the crash path, security owns the attacker path.
- Severity calibration note: when uncertain, demote toward Suggestion.
- `[pre-existing]` tag scoped to lines outside the current diff's added lines — new code cannot launder an anti-pattern through the tag.
