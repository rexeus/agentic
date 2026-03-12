# @rexeus/agentic

A multi-agent development toolkit for Claude Code. Seven specialized agents,
one orchestrator, zero complexity.

## Why

Most Claude Code plugins are overwhelming. Dozens of commands, complex
configuration, steep learning curves.

Agentic is different. Install it, type a command, and let the agents do their
work. The Lead orchestrator figures out which specialists to deploy, briefs them
precisely, and synthesizes their results. You stay in control — the agents stay
in their lane.

Built for TypeScript projects. Should work with other languages too.

## Quick Start

```
/plugin marketplace add rexeus/agentic
/plugin install agentic@rexeus
```

That's it. The Lead agent activates automatically as your main thread. Start
with any command:

```
/agentic:plan      Plan a feature
/agentic:develop   Build it
/agentic:review    Review the code
/agentic:simplify  Make it simpler
/agentic:polish    Harmonize the codebase
/agentic:verify    Run the quality gate
/agentic:commit    Commit with Conventional Commits
/agentic:pr        Create a Pull Request
```

## The Workflow

A typical development cycle with Agentic:

```
Plan → Develop → Review → Simplify → Verify → Commit → PR
                                ↑
                              Polish (iterative loop)
```

**1. Plan.** Start with `/agentic:plan`. The Lead doesn't just accept your
requirements — it challenges them. It asks hard questions, surfaces assumptions,
and presents options before producing an implementation plan. You approve the
plan before any code is written.

**2. Develop.** `/agentic:develop` runs the full pipeline. The Lead scouts the
codebase, designs the approach, hands a precise briefing to the developer agent,
and follows up with review and tests. You get working, tested code — not a plan
about a plan.

**3. Review.** `/agentic:review` deploys parallel reviewers with different
focus areas — correctness, security, conventions. Each reviewer works
independently for unbiased analysis. High-confidence findings only.

**4. Simplify.** `/agentic:simplify` is where the craft happens. The Refiner
distills working code to its essence — fewer abstractions, clearer names, less
indirection. Behavior stays the same. Complexity goes down. This step is what
separates code that works from code that sings.

**Polish.** `/agentic:polish` is the consistency loop. It discovers the patterns
your project already uses, finds where peer files diverge, and unifies them.
Use it after a feature is built, after a large refactor, or whenever files have
drifted apart. Polish is designed for iterative runs: execute, review the
changes, then `/clear` and run `/agentic:polish` again. Each pass finds fewer
issues until the codebase converges.

**5. Verify.** `/agentic:verify` is the pre-ship quality gate. It runs
correctness review, complexity analysis, and tests in parallel. One command,
three perspectives, a clear verdict: PASS, FAIL, or CONDITIONAL.

**6. Commit & PR.** `/agentic:commit` creates Conventional Commits from your
staged changes. `/agentic:pr` crafts a Pull Request with a structured
description. You stage the files — the agents handle the message.

You don't have to use every step. Skip what you don't need. The commands work
independently.

## The Agents

Seven cognitive modes, one orchestrator. Each answers a different question:

```
Scout       → "What is here?"              Fast codebase reconnaissance
Analyst     → "How does this work?"        Traces logic and data flows
Architect   → "How should it be?"          Designs solutions, evaluates trade-offs
Developer   → "Here's the implementation." The only agent that writes source code
Reviewer    → "Is this correct?"           Reviews for quality, correctness, and conventions
Tester      → "Does it actually work?"     Writes and runs tests
Refiner     → "How can this be simpler?"   Distills code to its essence
Lead        → Orchestrates all above       Delegates, synthesizes, keeps you in the loop
```

The Lead runs as your main thread (configured in `settings.json`). When you
describe a task, the Lead decides which specialists to deploy, in what order,
and with what briefing. You see the plan before it executes.

Every agent has a **Stop hook** — an LLM-based guardrail that verifies the agent
stayed in its role before returning results. The Developer can't plan. The
Reviewer can't implement. The Architect can't write tests. Each agent does one
thing well.

## Skills

Skills are background knowledge that agents load automatically. They inform
decisions without cluttering your workflow.

| Skill              | Purpose                                                    |
| ------------------ | ---------------------------------------------------------- |
| `conventions`      | Code style, naming, structure, types, error handling       |
| `quality-patterns` | Anti-patterns, coupling, duplication, positive patterns    |
| `security`         | Injection, auth, data exposure, input validation           |
| `testing`          | Test philosophy, layers, doubles, anti-patterns            |
| `git-conventions`  | Conventional Commits, branch naming, PR descriptions       |
| `setup`            | Getting started with Agentic, workflow, and agent overview |

## Hooks & Guardrails

The plugin enforces quality through automated hooks at two levels:

**Before writing** (PreToolUse) — blocks the action if violated:

- Secret detection — hardcoded passwords, secrets, API keys, access keys (OpenAI, GitHub, AWS patterns)
- Commit message validation — Conventional Commits format, lowercase, no trailing period, max 100 chars
- Plan mode blocking — agents manage planning through conversation, not native plan mode

**After writing** (PostToolUse) — informational warnings, never blocking:

- Debug statements in JS/TS (console.log, console.debug, console.warn, debugger)
- Unowned TODOs — use `TODO(name)` or `TODO(#123)`
- Merge conflict markers

**Agent-level** — every agent carries a prompt-based Stop hook that evaluates
role compliance before returning results.

## License

Apache-2.0
