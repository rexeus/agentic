---
"@rexeus/agentic": patch
---

Unify read-only bash permissions across all inspection agents (scout, analyst, architect, reviewer) for both Claude Code and OpenCode runtimes. Each agent now shares the complete set of safe, read-only commands instead of an arbitrary subset. Drops `find` from the allowlist since it supports mutating flags (`-delete`, `-exec`) — use `Glob`, `ls`, or `git ls-files` for discovery instead.
