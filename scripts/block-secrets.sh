#!/usr/bin/env bash
# block-secrets.sh
# PreToolUse hook for Write|Edit — blocks writes that contain secrets.
# Checks the CONTENT about to be written, not the file on disk.
# Exit 2 blocks the tool call and feeds the reason back to Claude.

set -euo pipefail

if ! command -v jq &>/dev/null; then
  echo "Warning: jq not found — secret detection skipped" >&2
  exit 0
fi

INPUT=$(cat)

# Extract the content that's about to be written:
# - Write tool: tool_input.content
# - Edit tool: tool_input.new_string
CONTENT=$(printf '%s\n' "$INPUT" | jq -r '.tool_input.content // .tool_input.new_string // empty' 2>/dev/null || echo "")
FILE_PATH=$(printf '%s\n' "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null || echo "")

if [ -z "$CONTENT" ]; then
  exit 0
fi

BLOCKERS=""

# Hardcoded secrets — two patterns:
# 1. Quoted values after : or = (catches JSON, YAML, JS with quotes)
# 2. Unquoted values after = only (catches .env without quotes)
# This avoids false positives on type annotations like "password: string"
if printf '%s\n' "$CONTENT" | grep -qEi '(password|passwd|secret|api_?key|access_?key|private_?key)"?[[:space:]]*[:=][[:space:]]*["'"'"'][^[:space:]"'"'"']{4,}'; then
  BLOCKERS="${BLOCKERS}Possible hardcoded secret detected — do not write credentials to ${FILE_PATH:-file}\n"
elif printf '%s\n' "$CONTENT" | grep -qEi '(password|passwd|secret|api_?key|access_?key|private_?key)[[:space:]]*=[[:space:]]*[^[:space:]"'"'"'=,;}{]{4,}'; then
  BLOCKERS="${BLOCKERS}Possible hardcoded secret detected — do not write credentials to ${FILE_PATH:-file}\n"
fi

# Known API token patterns
if printf '%s\n' "$CONTENT" | grep -qE '(sk-[a-zA-Z0-9]{20,}|ghp_[a-zA-Z0-9]{36,}|gho_[a-zA-Z0-9]{36,}|github_pat_[a-zA-Z0-9_]{20,}|aws_[a-zA-Z0-9/+=]{20,}|AKIA[A-Z0-9]{16}|sk_live_[a-zA-Z0-9]{20,}|sk_test_[a-zA-Z0-9]{20,}|xoxb-[a-zA-Z0-9-]{20,}|xoxp-[a-zA-Z0-9-]{20,})'; then
  BLOCKERS="${BLOCKERS}Possible API token detected — do not write tokens to ${FILE_PATH:-file}\n"
fi

if [ -n "$BLOCKERS" ]; then
  printf "%b" "$BLOCKERS" >&2
  exit 2
fi

exit 0
