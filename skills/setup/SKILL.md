---
name: setup
description: Getting started with Agentic — workflow, commands, and how the agent team works together.
---

# Getting Started with Agentic

Agentic is a multi-agent development toolkit. Seven specialists, one
orchestrator (the Lead), zero configuration.

## Your First Session

The Lead agent is your main thread. It runs automatically. Just describe what
you want to build, fix, or improve — the Lead figures out the rest.

For structured workflows, use the commands:

```
/agentic:plan      Plan a feature — challenges assumptions, presents options
/agentic:develop   Build it — full pipeline from understanding to testing
/agentic:review    Review the code — parallel reviewers, different focus areas
/agentic:simplify  Simplify — distill working code to its essence
/agentic:verify    Quality gate — correctness, complexity, tests in parallel
/agentic:commit    Commit — Conventional Commits from staged changes
/agentic:pr        Pull Request — crafted title and description
```

## The Typical Flow

```
Plan → Develop → Review → Simplify → Verify → Commit → PR
```

1. `/agentic:plan` — describe what you want. The Lead asks questions, challenges
   scope, and produces a plan. You approve before anything is built.
2. `/agentic:develop` — the Lead scouts the codebase, designs the approach,
   briefs the developer, and runs review + tests.
3. `/agentic:review` — independent parallel reviewers check correctness,
   security, and conventions.
4. `/agentic:simplify` — the Refiner removes unnecessary complexity while
   preserving behavior.
5. Review the changes yourself. Stage what looks good with `git add`.
6. `/agentic:commit` — creates the commit message from staged changes.
7. `/agentic:pr` — creates or updates a Pull Request.

Skip steps you don't need. Every command works independently.

## Important: You Control Staging

No agent will ever run `git add`, `git stash`, or modify your staged files.
Staging is your responsibility. The agents write code — you decide what ships.

## The Agents

You don't deploy agents directly. The Lead does that based on your task:

- **Scout** — fast reconnaissance, maps the codebase
- **Analyst** — traces logic, follows data flows, explains mechanics
- **Architect** — designs solutions, evaluates trade-offs
- **Developer** — the only agent that writes source code
- **Reviewer** — reviews for correctness and security (read-only)
- **Tester** — writes and runs tests (test code only)
- **Refiner** — simplifies working code without changing behavior

## Guardrails

The plugin enforces quality automatically:

- **Secrets blocked** before writing (hardcoded passwords, API tokens)
- **Commit messages validated** against Conventional Commits format
- **Debug statements flagged** after writing (console.log, debugger)
- **Unowned TODOs flagged** — use `TODO(name)` or `TODO(#123)`
- **Agent role enforcement** via Stop hooks on every agent
