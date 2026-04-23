---
"@rexeus/agentic": patch
---

Unify read-only bash permissions across all inspection agents (scout, analyst, architect, reviewer) for both Claude Code and OpenCode runtimes. Each agent now shares the same pragmatic allowlist instead of an arbitrary subset. Drops `find` in favor of narrower alternatives (`Glob`, `git ls-files`, `Grep`) that make intent explicit.
