# @rexeus/agentic

Multi-agent development toolkit for Claude Code. Specialized agents, conventions,
review workflows, and quality guardrails for TypeScript and JavaScript projects.

## Installation

```bash
# From marketplace
claude plugin install agentic

# For development
claude --plugin-dir /path/to/agentic
```

## Architecture

The plugin separates **knowledge** from **action** from **orchestration**:

- **Skills** hold knowledge (conventions, patterns, security)
- **Commands** trigger actions (`/agentic:review`, `/agentic:develop`)
- **Agents** provide specialized cognitive modes (scout, architect, developer...)
- **Hooks** enforce guardrails automatically

A **Lead** agent orchestrates everything. It runs as the main thread
(`settings.json → "agent": "lead"`), analyzes tasks, delegates to specialists,
and keeps the human in the loop.

### Cognitive Modes

Each agent answers a distinct question. No two overlap:

```
Scout       → "What is here?"              (explore)
Analyst     → "How does this work?"         (understand)
Architect   → "How should it be?"           (design)
Developer   → "Here's the implementation."  (build)
Reviewer    → "Is this correct?"            (verify)
Tester      → "Does it actually work?"      (prove)
Refiner     → "How can this be simpler?"    (simplify)
Lead        → orchestrates all of the above (coordinate)
```

## Agents

| Agent         | Model   | Mode       | Purpose                                                                                               |
| ------------- | ------- | ---------- | ----------------------------------------------------------------------------------------------------- |
| **lead**      | inherit | Coordinate | Analyzes tasks, delegates to specialists, synthesizes results                                         |
| **scout**     | haiku   | Explore    | Fast codebase reconnaissance. Maps structure, finds patterns. Read-only                               |
| **analyst**   | sonnet  | Understand | Traces logic, follows data flows, explains mechanics. Read-only                                       |
| **architect** | inherit | Design     | Designs solutions, evaluates trade-offs, produces implementation plans. Read-only                     |
| **developer** | inherit | Build      | Implements features and refactors code. The only agent that writes source code                        |
| **reviewer**  | inherit | Verify     | Reviews for correctness, security, conventions, quality. Confidence scoring (threshold 80). Read-only |
| **tester**    | inherit | Prove      | Writes and runs tests. Arrange-Act-Assert. Writes test code only, never source code                   |
| **refiner**   | inherit | Simplify   | Distills working code to its essence. Reduces complexity without changing behavior. Source code only  |

Every agent has a **Stop hook** — an LLM-based guardrail that verifies the agent
stayed in its role before returning results.

## Skills

Skills are background knowledge, automatically loaded by Claude when relevant.
Agents preload specific skills via frontmatter.

| Skill              | Loaded by                                             | Purpose                                                 |
| ------------------ | ----------------------------------------------------- | ------------------------------------------------------- |
| `conventions`      | lead, architect, developer, reviewer, tester, refiner | Code style, naming, structure, types, error handling    |
| `quality-patterns` | lead, architect, developer, reviewer, refiner         | Anti-patterns, coupling, duplication, positive patterns |
| `security`         | architect, reviewer                                   | Injection, auth, data exposure, input validation        |
| `testing`          | reviewer, tester                                      | Test philosophy, layers, doubles, anti-patterns         |
| `git-conventions`  | lead                                                  | Conventional Commits, branch naming, commit discipline  |

## Commands

| Command                      | Purpose                                                                              |
| ---------------------------- | ------------------------------------------------------------------------------------ |
| `/agentic:commit`            | Create a commit from staged changes using Conventional Commits. Never runs `git add` |
| `/agentic:plan <task>`       | Critically question requirements, present options, produce an implementation plan    |
| `/agentic:develop <task>`    | Full pipeline: scout → analyst → architect → developer → reviewer + tester           |
| `/agentic:review [target]`   | Multi-agent parallel review. Asks what to review if scope is unclear                 |
| `/agentic:simplify [target]` | Distill code to its essence. Analyst → Refiner → Tester pipeline                     |

All commands are user-triggered only (`disable-model-invocation: true`).

## Hooks

### Plugin-level (hooks/hooks.json)

**PreToolUse** on `Bash` — runs `validate-commit-msg.sh` before every `git commit`:

- Validates Conventional Commits format (type, scope, description)
- Checks lowercase description, no trailing period, max 72 characters
- Feeds validation errors back to Claude for self-correction (exit 2)

**PostToolUse** on `Write|Edit` — runs `check-conventions.sh` after every file change:

- Merge conflict markers (blocks)
- Hardcoded secrets patterns (blocks)
- Debug statements in JS/TS (warns)
- TODOs without owner or issue link (warns)

### Agent-level (frontmatter)

Every agent carries a **prompt-based Stop hook** that evaluates whether
the agent's output matches its role constraints. If violated, the agent
is instructed to correct itself.

Stop hooks include a `stop_hook_active` flag for infinite-loop protection:
when a stop hook triggers a correction, `stop_hook_active` is set to `true`
on the subsequent evaluation to prevent the hook from recursively evaluating
its own correction. This ensures the agent can self-correct exactly once
without entering an infinite evaluation loop.

## Philosophy

- **Separation of concerns.** Each agent has one cognitive mode. No overlap.
- **Signal over noise.** Never flag uncertain issues. False positives erode trust.
- **Knowledge informs action.** Skills hold the standards. Agents apply them.
- **Plan before building.** The Lead always presents a plan before delegating.
- **Adapt, don't impose.** Project conventions take precedence over defaults.

## Project Structure

```
agentic/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest
├── agents/
│   ├── lead.md              # Orchestrator (main thread)
│   ├── scout.md             # Codebase reconnaissance
│   ├── analyst.md           # Deep code analysis
│   ├── architect.md         # System design
│   ├── developer.md         # Implementation
│   ├── reviewer.md          # Code review
│   ├── tester.md            # Test engineering
│   └── refiner.md           # Code simplification
├── commands/
│   ├── commit.md            # Conventional Commits
│   ├── plan.md              # Feature planning
│   ├── develop.md           # Full dev pipeline
│   ├── review.md            # Multi-agent review
│   └── simplify.md          # Code simplification
├── skills/
│   ├── conventions/         # Code style and naming
│   ├── quality-patterns/    # Anti-patterns and best practices
│   ├── security/            # Security patterns
│   ├── testing/             # Testing patterns
│   └── git-conventions/     # Git and commit conventions
├── hooks/
│   └── hooks.json           # PreToolUse + PostToolUse hooks
├── scripts/
│   ├── check-conventions.sh # Convention check (PostToolUse)
│   └── validate-commit-msg.sh # Commit message validation (PreToolUse)
├── settings.json            # Lead as main thread agent
└── package.json
```

## License

Apache-2.0
