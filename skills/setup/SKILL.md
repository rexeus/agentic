---
name: setup
description: Getting started with Agentic — workflow, commands, and how the agent team works together.
---

# Getting Started with Agentic

Agentic is a multi-agent development toolkit. Seven specialists, one
orchestrator (the Lead), zero configuration.

In OpenCode, `lead` is installed as a visible primary agent. The specialists
are installed as hidden subagents. Talk to the Lead; the Lead deploys the team.

## Your First Session

The Lead agent is your main thread. Start with the Lead when you want to build,
fix, or improve something — it deploys the right specialists for the job.

For structured workflows, use the commands:

```
OpenCode:    /agentic-plan      Claude Code: /agentic:plan
OpenCode:    /agentic-develop   Claude Code: /agentic:develop
OpenCode:    /agentic-review    Claude Code: /agentic:review
OpenCode:    /agentic-simplify  Claude Code: /agentic:simplify
OpenCode:    /agentic-polish    Claude Code: /agentic:polish
OpenCode:    /agentic-verify    Claude Code: /agentic:verify
OpenCode:    /agentic-commit    Claude Code: /agentic:commit
OpenCode:    /agentic-pr        Claude Code: /agentic:pr
```

## The Typical Flow

```
Plan → Develop → Review → Simplify → Verify → Commit → PR
                                ↑
                              Polish (iterative loop)
```

1. `/agentic-plan` (OpenCode) or `/agentic:plan` (Claude Code) — describe what you want. The Lead asks questions, challenges
   scope, and produces a plan. You approve before anything is built.
2. `/agentic-develop` (OpenCode) or `/agentic:develop` (Claude Code) — the Lead scouts the codebase, designs the approach,
   briefs the developer, and runs review + tests.
3. `/agentic-review` (OpenCode) or `/agentic:review` (Claude Code) — independent parallel reviewers check correctness,
   security, and conventions.
4. `/agentic-simplify` (OpenCode) or `/agentic:simplify` (Claude Code) — the Refiner removes unnecessary complexity while
   preserving behavior.

   **Polish.** `/agentic-polish` (OpenCode) or `/agentic:polish` (Claude Code) is the consistency loop. It aligns the code
   with established patterns, smooths out inconsistencies, and is designed for iterative runs until the codebase converges.

5. Review the changes yourself. Stage what looks good with `git add`.
6. `/agentic-commit` (OpenCode) or `/agentic:commit` (Claude Code) — creates the commit message from staged changes.
7. `/agentic-pr` (OpenCode) or `/agentic:pr` (Claude Code) — creates or updates a Pull Request.

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

## Customizing Models

Agents use your default model unless overridden. In OpenCode, configure
per-agent models in `opencode.json`:

```json
{
  "agent": {
    "lead": { "model": "openai/gpt-5.4" },
    "scout": { "model": "anthropic/claude-haiku-4-5" },
    "developer": { "model": "openai/gpt-5.4" }
  }
}
```

Model IDs use the `provider/model` format. A practical setup: fast model for
the scout (reconnaissance), capable model for the lead and developer
(orchestration and implementation), default for the rest.

In Claude Code, model overrides are configured in `settings.json` via the
`agentSettings` key.

## Guardrails

The plugin enforces quality automatically:

- **Secrets blocked** before writing (hardcoded passwords, API tokens)
- **Commit messages validated** against Conventional Commits format
- **Debug statements flagged** after writing (console.log, debugger)
- **Unowned TODOs flagged** — use `TODO(name)` or `TODO(#123)`
- **Agent role enforcement** via Stop hooks (Claude Code integration)
