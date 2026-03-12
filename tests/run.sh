#!/usr/bin/env bash
# run.sh — Minimal test runner for hook scripts.
# No dependencies. Pure bash.
#
# Usage:
#   ./tests/run.sh              Run all tests
#   ./tests/run.sh secrets      Run only block-secrets tests
#   ./tests/run.sh commit       Run only commit validation tests
#   ./tests/run.sh conventions  Run only convention check tests

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

PASSED=0
FAILED=0

# Runner-managed temp directory — available to all test files as $TEST_TMPDIR
TEST_TMPDIR=$(mktemp -d)
trap "rm -rf $TEST_TMPDIR" EXIT

# Colors (disabled if not a terminal)
if [ -t 1 ]; then
  GREEN='\033[0;32m'
  RED='\033[0;31m'
  DIM='\033[0;90m'
  BOLD='\033[1m'
  RESET='\033[0m'
else
  GREEN="" RED="" DIM="" BOLD="" RESET=""
fi

# Assert that a command exits with the expected code
assert_exit() {
  local description="$1"
  local expected_exit="$2"
  shift 2

  local actual_exit=0
  "$@" >/dev/null 2>&1 || actual_exit=$?

  if [ "$actual_exit" -eq "$expected_exit" ]; then
    PASSED=$((PASSED + 1))
    printf "${GREEN}  ✓${RESET} %s\n" "$description"
  else
    FAILED=$((FAILED + 1))
    printf "${RED}  ✗${RESET} %s ${DIM}(expected exit %d, got %d)${RESET}\n" "$description" "$expected_exit" "$actual_exit"
  fi
}

# Assert that a command's stderr contains a literal string
assert_stderr_contains() {
  local description="$1"
  local pattern="$2"
  shift 2

  local output
  output=$("$@" 2>&1 >/dev/null || true)

  if printf '%s\n' "$output" | grep -qF "$pattern"; then
    PASSED=$((PASSED + 1))
    printf "${GREEN}  ✓${RESET} %s\n" "$description"
  else
    FAILED=$((FAILED + 1))
    printf "${RED}  ✗${RESET} %s ${DIM}(stderr did not contain '%s')${RESET}\n" "$description" "$pattern"
  fi
}

# Assert that a command's stdout contains a literal string
assert_stdout_contains() {
  local description="$1"
  local pattern="$2"
  shift 2

  local output
  output=$("$@" 2>/dev/null || true)

  if printf '%s\n' "$output" | grep -qF "$pattern"; then
    PASSED=$((PASSED + 1))
    printf "${GREEN}  ✓${RESET} %s\n" "$description"
  else
    FAILED=$((FAILED + 1))
    printf "${RED}  ✗${RESET} %s ${DIM}(stdout did not contain '%s')${RESET}\n" "$description" "$pattern"
  fi
}

# Assert that a command produces no stdout
assert_stdout_empty() {
  local description="$1"
  shift

  local output
  output=$("$@" 2>/dev/null || true)

  if [ -z "$output" ]; then
    PASSED=$((PASSED + 1))
    printf "${GREEN}  ✓${RESET} %s\n" "$description"
  else
    FAILED=$((FAILED + 1))
    printf "${RED}  ✗${RESET} %s ${DIM}(expected no output, got '%s')${RESET}\n" "$description" "$output"
  fi
}

# Helper: pipe JSON input to a script
pipe_to() {
  local script="$1"
  local input="$2"
  printf '%s\n' "$input" | bash "$script"
}

# Export helpers for test files
export REPO_ROOT TEST_TMPDIR
export -f assert_exit assert_stderr_contains assert_stdout_contains assert_stdout_empty pipe_to

# Run test files
run_suite() {
  local file="$1"
  local name
  name="$(basename "$file" .test.sh)"
  printf "\n${BOLD}%s${RESET}\n" "$name"
  source "$file"
}

# Determine which suites to run
FILTER="${1:-all}"
TEST_FILES=()

case "$FILTER" in
  secrets)     TEST_FILES=("$SCRIPT_DIR/block-secrets.test.sh") ;;
  commit)      TEST_FILES=("$SCRIPT_DIR/validate-commit-msg.test.sh") ;;
  conventions) TEST_FILES=("$SCRIPT_DIR/check-conventions.test.sh") ;;
  all)         TEST_FILES=("$SCRIPT_DIR"/*.test.sh) ;;
  *)
    echo "Unknown suite: $FILTER"
    echo "Usage: $0 [secrets|commit|conventions|all]"
    exit 1
    ;;
esac

printf "${BOLD}Agentic Hook Tests${RESET}\n"

for file in "${TEST_FILES[@]}"; do
  if [ -f "$file" ]; then
    run_suite "$file"
  fi
done

# Summary
printf "\n${BOLD}─────────────────────────${RESET}\n"
printf "${GREEN}%d passed${RESET}" "$PASSED"
if [ "$FAILED" -gt 0 ]; then
  printf ", ${RED}%d failed${RESET}" "$FAILED"
fi
printf "\n"

if [ "$FAILED" -gt 0 ]; then
  exit 1
fi
