# @rexeus/agentic

A multi-agent development toolkit for Claude Code and OpenCode. Ten specialized
agents, one orchestrator, zero complexity.

## Why

Most Claude Code plugins are overwhelming. Dozens of commands, complex
configuration, steep learning curves.

Agentic is different. Install it, type a command, and let the agents do their
work. The Lead orchestrator figures out which specialists to deploy, briefs them
precisely, and synthesizes their results. You stay in control — the agents stay
in their lane.

Built for TypeScript projects. Should work with other languages too.

## Quick Start

### OpenCode (recommended)

```bash
npx @rexeus/agentic install opencode
```

One command. This installs the Agentic plugin, agents, commands, and skills
globally. Restart OpenCode, switch to the visible `lead` agent, then run:

```
/agentic-plan      Plan a feature
/agentic-develop   Build it
/agentic-review    Review the code
/agentic-simplify  Make it simpler
/agentic-polish    Harmonize the codebase
/agentic-verify    Run the quality gate
/agentic-commit    Commit with Conventional Commits
/agentic-pr        Create a Pull Request
```

### Claude Code

```
/plugin marketplace add rexeus/agentic
/plugin install agentic@rexeus
```

## The Workflow

A typical development cycle with Agentic:

```
Plan → Develop → Review → Simplify → Verify → Commit → PR
                                ↑
                              Polish (iterative loop)
```

**1. Plan.** Start with `/agentic-plan` (OpenCode) or `/agentic:plan` (Claude Code).
The Lead doesn't just accept your
requirements — it challenges them. It asks hard questions, surfaces assumptions,
and presents options before producing an implementation plan. You approve the
plan before any code is written.

**2. Develop.** `/agentic-develop` (OpenCode) or `/agentic:develop` (Claude Code)
runs the full pipeline. The Lead scouts the
codebase, designs the approach, hands a precise briefing to the developer agent,
and follows up with review and tests. You get working, tested code — not a plan
about a plan.

**3. Review.** `/agentic-review` (OpenCode) or `/agentic:review` (Claude Code)
deploys **six specialists in parallel**: three reviewers (correctness,
security, maintainability) and three testers (coverage, craft,
testability). Each has its own identity and its own loaded skills.
All six are advisory — none of them modifies files. High-confidence
findings only, lens labels preserved. Composite verdict is the worst
of the six.

**4. Simplify.** `/agentic-simplify` (OpenCode) or `/agentic:simplify` (Claude Code)
is where the craft happens. The Refiner
distills working code to its essence — fewer abstractions, clearer names, less
indirection. Behavior stays the same. Complexity goes down. This step is what
separates code that works from code that sings.

**Polish.** `/agentic-polish` (OpenCode) or `/agentic:polish` (Claude Code)
is the consistency loop. It discovers the patterns
your project already uses, finds where peer files diverge, and unifies them.
Use it after a feature is built, after a large refactor, or whenever files have
drifted apart. Polish is designed for iterative runs: execute, review the
changes, then `/clear` and run it again. Each pass finds fewer
issues until the codebase converges.

**5. Verify.** `/agentic-verify` (OpenCode) or `/agentic:verify` (Claude Code)
is the pre-ship quality gate. It runs the reviewer trio and the
tester trio — six specialists in parallel — plus a full test-suite
execution. One command, six perspectives, a clear verdict: PASS,
FAIL, or CONDITIONAL.

**6. Commit & PR.** `/agentic-commit` + `/agentic-pr` (OpenCode) or
`/agentic:commit` + `/agentic:pr` (Claude Code) handle commit and PR flow.
`commit` creates Conventional Commits from your
staged changes. `pr` crafts a Pull Request with a structured
description. You stage the files — the agents handle the message.

### OpenCode CLI

```bash
agentic install opencode
agentic doctor
agentic uninstall opencode
```

You don't have to use every step. Skip what you don't need. The commands work
independently.

## The Agents

Ten cognitive modes, one orchestrator. Each answers a different question:

```
Scout                     → "What is here?"              Fast codebase reconnaissance
Analyst                   → "How does this work?"        Traces logic and data flows
Architect                 → "How should it be?"          Designs solutions, evaluates trade-offs
Developer                 → "Here's the code + tests."   The only agent that writes source code or tests
Reviewer (correctness)    → "Does it work?"              Runtime behavior, edge cases, the crash path
Reviewer (security)       → "Can it be broken?"          Attacker model, trust boundaries, OWASP
Reviewer (maintainability)→ "Will it age well?"          Complexity, coupling, readability
Tester (scout)            → "What is not yet tested?"    Coverage gaps, missing scenarios
Tester (artisan)          → "Do the tests read well?"    Test craft, AAA, clarity
Tester (architect)        → "Is the code testable?"      Design-for-test, seams, dependencies
Refiner                   → "How can this be simpler?"   Distills code to its essence
Lead                      → Orchestrates all above       Delegates, synthesizes, keeps you in the loop
```

After the developer ships code **and the tests they write alongside it**, the
reviewer trio and the tester trio fan out in parallel: six disjoint advisory
lenses on the same change. Only the developer writes code and tests; the six
specialists never modify files. One FAIL anywhere fails the gate.

The Lead runs as your main thread. In Claude Code, that is configured through
`settings.json`. When you describe a task, the Lead decides which specialists
to deploy, in what order, and with what briefing. You see the plan before it
executes.

In OpenCode, `lead` is installed as a first-class primary agent. The rest of
the team is installed as hidden subagents so the experience still flows through
one visible orchestrator instead of competing entry points.

Claude Code agents also have **Stop hooks** — LLM-based guardrails that check
whether the agent stayed in its role before returning results. The Developer is
checked against planning. The reviewer trio against implementing. The Architect
against writing tests. These are probabilistic guardrails, not hard walls — but
they catch most role drift.

## Skills

Skills are background knowledge that agents load automatically. They inform
decisions without cluttering your workflow.

| Skill                   | Purpose                                                    |
| ----------------------- | ---------------------------------------------------------- |
| `conventions`           | Code style, naming, structure, types, error handling       |
| `quality-patterns`      | Anti-patterns, coupling, duplication, positive patterns    |
| `security`              | Injection, auth, data exposure, input validation           |
| `testing-core`          | Test philosophy, F.I.R.S.T, doubles, anti-patterns         |
| `test-advisory-format`  | Master Test Advisory template used by the tester trio      |
| `review-foundations`    | Confidence, severity, verdict, output shape for reviewers  |
| `git-conventions`       | Conventional Commits, branch naming, PR descriptions       |
| `setup`                 | Getting started with Agentic, workflow, and agent overview |

Agentic is compatible with the [`skills` CLI](https://github.com/vercel-labs/skills).
You can use it to update skills via `npx skills update` or install additional
third-party skills alongside Agentic. To add Agentic skills through the skills
CLI instead of the built-in installer:

```bash
npx skills add rexeus/agentic -g --all -y
```

## Configuration

Agentic works out of the box with zero configuration. But you can customize
models per agent in your `opencode.json`:

```json
{
  "agent": {
    "lead": { "model": "openai/gpt-5.4" },
    "scout": { "model": "anthropic/claude-haiku-4-5" },
    "developer": { "model": "openai/gpt-5.4" }
  }
}
```

Model IDs use the `provider/model` format — the same format as your top-level
`model` setting. Agents without an explicit override use your default. This
lets you balance cost and capability — a fast model for the scout, a capable
model for the lead and developer, and your default for everything else.

In Claude Code, model overrides are configured in `settings.json` via the
`agentSettings` key.

## Hooks & Guardrails

Both integrations enforce the same core guardrails:

- Secret detection before write/edit (hardcoded passwords, secrets, API tokens)
- Conventional Commit validation on `git commit` messages
- Convention warnings after edits (debug statements, unowned TODOs, conflict markers)

**Claude Code integration** (`hooks/hooks.json`, shell scripts, and `settings.json`) also includes:

- Native plan mode blocking to keep planning inside Agentic workflows
- Agent-level Stop hooks for role compliance checks

**OpenCode integration** (`opencode/plugin.mjs`) applies the same write/commit
guardrails through `tool.execute.before` and post-edit warnings through
`tool.execute.after`.

All guardrails are pattern-based and intentionally conservative. They catch high-signal
issues, but they are not a substitute for human review.

## License

Apache-2.0
