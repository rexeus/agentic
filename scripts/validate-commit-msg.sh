#!/usr/bin/env bash
# validate-commit-msg.sh
# PreToolUse hook for Bash — validates commit messages against Conventional Commits 1.0.0.
# Only activates for git commit commands. Exit 0 allows, exit 2 feeds feedback to Claude.

set -euo pipefail

# Require jq for JSON parsing
if ! command -v jq &>/dev/null; then
  echo "Warning: jq not found — commit message validation skipped" >&2
  exit 0
fi

INPUT=$(cat)
COMMAND=$(printf '%s\n' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null || echo "")

# Only validate git commit commands
if ! printf '%s\n' "$COMMAND" | grep -qE '^[[:space:]]*git[[:space:]]+commit'; then
  exit 0
fi

# Extract the commit message from -m flag
# Handles: git commit -m "msg", git commit -m 'msg', git commit -m "$(cat <<'EOF'\n...\nEOF\n)"
MSG=""
if printf '%s\n' "$COMMAND" | grep -qE '\-m[[:space:]]'; then
  # Try to extract message between quotes after -m
  MSG=$(printf '%s\n' "$COMMAND" | sed -n 's/.*-m[[:space:]]*["'"'"']\(.*\)["'"'"'].*/\1/p' | head -1)

  # Handle HEREDOC format: extract first line of the message
  if [ -z "$MSG" ] && printf '%s\n' "$COMMAND" | grep -q 'cat <<'; then
    MSG=$(printf '%s\n' "$COMMAND" | sed -n "/cat <<.*EOF/,/EOF/p" | sed '1d;$d' | head -1)
  fi
fi

# No message found — skip (might be interactive commit or --amend)
if [ -z "$MSG" ]; then
  exit 0
fi

# Extract just the first line for header validation
FIRST_LINE=$(printf '%s\n' "$MSG" | head -1)
ISSUES=""

# Valid types per Conventional Commits
TYPES="feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert"

# 1. Must start with a valid type
if ! printf '%s\n' "$FIRST_LINE" | grep -qE "^($TYPES)"; then
  ISSUES="${ISSUES}First line must start with a valid type ($TYPES)\n"
fi

# 2. Format: type(scope)?: description or type(scope)?!: description
if ! printf '%s\n' "$FIRST_LINE" | grep -qE "^($TYPES)(\([a-zA-Z0-9_./-]+\))?!?:[[:space:]].+"; then
  ISSUES="${ISSUES}Format must be: type(scope): description — colon and space required\n"
fi

# 3. Description must be lowercase after ': '
DESC=$(printf '%s\n' "$FIRST_LINE" | sed -n 's/^[^:]*:[[:space:]]*//p')
if [ -n "$DESC" ]; then
  FIRST_CHAR=$(printf '%s\n' "$DESC" | cut -c1)
  if printf '%s\n' "$FIRST_CHAR" | grep -qE '^[A-Z]$'; then
    ISSUES="${ISSUES}Description should start lowercase after ': '\n"
  fi

  # 4. No period at end of description
  if printf '%s\n' "$DESC" | grep -qE '\.$'; then
    ISSUES="${ISSUES}Description should not end with a period\n"
  fi
fi

# 5. First line max 72 characters
LINE_LEN=${#FIRST_LINE}
if [ "$LINE_LEN" -gt 72 ]; then
  ISSUES="${ISSUES}First line exceeds 72 characters (found ${LINE_LEN})\n"
fi

if [ -n "$ISSUES" ]; then
  printf "Commit message validation failed:\n%b" "$ISSUES" >&2
  exit 2
fi

exit 0
