#!/usr/bin/env bash
# check-conventions.sh
# PostToolUse hook for Write|Edit — informational convention feedback.
# Secrets are blocked by block-secrets.sh (PreToolUse) before the write happens.
# This script runs AFTER the write and provides soft warnings via stdout + exit 0.

set -euo pipefail

if ! command -v jq &>/dev/null; then
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

# Merge conflict markers — should not be in any written file
if grep -qE '^(<<<<<<<|=======|>>>>>>>)' "$FILE_PATH" 2>/dev/null; then
  echo "Merge conflict markers found in ${FILE_PATH} — resolve before committing"
fi

WARNINGS=""

# Debug statements in JS/TS files
case "$FILE_PATH" in
  *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs)
    if grep -qn 'console\.log\|console\.debug\|debugger' "$FILE_PATH" 2>/dev/null; then
      WARNINGS="${WARNINGS}Debug statement found in ${FILE_PATH} — remove before committing\n"
    fi
    ;;
esac

# TODOs without owner or issue link (source files only)
case "$FILE_PATH" in
  *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs)
    if grep -qnE '(^|[^A-Za-z])TODO([^(A-Za-z]|$)' "$FILE_PATH" 2>/dev/null; then
      WARNINGS="${WARNINGS}Unowned TODO in ${FILE_PATH} — use TODO(name) or TODO(#123)\n"
    fi
    ;;
esac

if [ -n "$WARNINGS" ]; then
  printf "%b" "$WARNINGS"
  exit 0
fi

exit 0
