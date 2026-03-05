#!/usr/bin/env bash
# check-conventions.sh
# PostToolUse hook for Write|Edit — checks written files for convention issues.
# Exit 1 blocks the action (hard violations). Exit 2 feeds back to Claude (soft violations).

set -euo pipefail

# Require jq for JSON parsing
if ! command -v jq &>/dev/null; then
  echo "Warning: jq not found — convention checks skipped" >&2
  exit 0
fi

INPUT=$(cat)
FILE_PATH=$(printf '%s\n' "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null || echo "")

# Skip if no file or file doesn't exist
if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

# Skip binary and generated files
case "$FILE_PATH" in
  *.png|*.jpg|*.jpeg|*.gif|*.ico|*.svg|*.woff|*.woff2|*.ttf|*.eot|*.lock|*.min.js|*.min.css|*.map)
    exit 0
    ;;
esac

BLOCKERS=""

# --- BLOCKERS (exit 1) — never acceptable, hard stop ---

# Merge conflict markers
if grep -qE '^(<<<<<<<|=======|>>>>>>>)' "$FILE_PATH" 2>/dev/null; then
  BLOCKERS="${BLOCKERS}Merge conflict markers in ${FILE_PATH}\n"
fi

# Hardcoded secrets patterns (POSIX-portable regex — no \s or \x27)
if grep -qEi '(password|passwd|secret|api_?key|access_?key|private_?key)[[:space:]]*[:=][[:space:]]*["'"'"'][^[:space:]"'"'"']{4,}' "$FILE_PATH" 2>/dev/null; then
  BLOCKERS="${BLOCKERS}Possible hardcoded secret in ${FILE_PATH}\n"
fi
if grep -qE '(sk-[a-zA-Z0-9]{20,}|ghp_[a-zA-Z0-9]{36,}|gho_[a-zA-Z0-9]{36,}|aws_[a-zA-Z0-9/+=]{20,})' "$FILE_PATH" 2>/dev/null; then
  BLOCKERS="${BLOCKERS}Possible API token (OpenAI/GitHub/AWS pattern) in ${FILE_PATH}\n"
fi

if [ -n "$BLOCKERS" ]; then
  printf "%b" "$BLOCKERS" >&2
  exit 1
fi

exit 0
