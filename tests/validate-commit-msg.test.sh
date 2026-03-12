# validate-commit-msg.test.sh — Tests for commit message validation hook

SCRIPT="$REPO_ROOT/scripts/validate-commit-msg.sh"

# Helper: create Bash tool JSON input with a command
cmd() {
  local command="$1"
  printf '{"tool_input":{"command":"%s"}}' "$command"
}

# ─── Valid messages: should ALLOW (exit 0) ───

assert_exit "allows valid feat message" 0 \
  pipe_to "$SCRIPT" "$(cmd 'git commit -m \"feat: add user auth\"')"

assert_exit "allows valid fix message" 0 \
  pipe_to "$SCRIPT" "$(cmd 'git commit -m \"fix: resolve null ref\"')"

assert_exit "allows valid docs message" 0 \
  pipe_to "$SCRIPT" "$(cmd 'git commit -m \"docs: update readme\"')"

assert_exit "allows scoped message" 0 \
  pipe_to "$SCRIPT" "$(cmd 'git commit -m \"feat(auth): add login flow\"')"

assert_exit "allows breaking change with !" 0 \
  pipe_to "$SCRIPT" "$(cmd 'git commit -m \"feat!: remove legacy api\"')"

assert_exit "allows scoped breaking change" 0 \
  pipe_to "$SCRIPT" "$(cmd 'git commit -m \"feat(api)!: change response format\"')"

assert_exit "allows refactor type" 0 \
  pipe_to "$SCRIPT" "$(cmd 'git commit -m \"refactor: extract helper\"')"

assert_exit "allows chore type" 0 \
  pipe_to "$SCRIPT" "$(cmd 'git commit -m \"chore: update deps\"')"

assert_exit "allows perf type" 0 \
  pipe_to "$SCRIPT" "$(cmd 'git commit -m \"perf: optimize query\"')"

# ─── Invalid messages: should BLOCK (exit 2) ───

assert_exit "blocks non-conventional message" 2 \
  pipe_to "$SCRIPT" "$(cmd 'git commit -m \"Updated the login page\"')"

assert_exit "blocks missing colon-space" 2 \
  pipe_to "$SCRIPT" "$(cmd 'git commit -m \"feat add feature\"')"

assert_exit "blocks uppercase description" 2 \
  pipe_to "$SCRIPT" "$(cmd 'git commit -m \"feat: Add user auth\"')"

assert_exit "blocks trailing period" 2 \
  pipe_to "$SCRIPT" "$(cmd 'git commit -m \"feat: add user auth.\"')"

assert_exit "blocks unknown type" 2 \
  pipe_to "$SCRIPT" "$(cmd 'git commit -m \"feature: add user auth\"')"

# ─── Flag variants: should validate ───

assert_exit "validates -am flag (combined)" 2 \
  pipe_to "$SCRIPT" "$(cmd 'git commit -am \"bad message\"')"

assert_exit "allows valid -am message" 0 \
  pipe_to "$SCRIPT" "$(cmd 'git commit -am \"fix: resolve null ref\"')"

# ─── Command chains: should validate ───

assert_exit "validates after && chain" 2 \
  pipe_to "$SCRIPT" "$(cmd 'cd /project && git commit -m \"bad message\"')"

assert_exit "allows valid message in chain" 0 \
  pipe_to "$SCRIPT" "$(cmd 'cd /project && git commit -m \"feat: add feature\"')"

assert_exit "validates after semicolon chain" 2 \
  pipe_to "$SCRIPT" "$(cmd 'echo done; git commit -m \"bad message\"')"

# ─── Non-commit commands: should SKIP (exit 0) ───

assert_exit "skips git status" 0 \
  pipe_to "$SCRIPT" "$(cmd 'git status')"

assert_exit "skips git diff" 0 \
  pipe_to "$SCRIPT" "$(cmd 'git diff --cached')"

assert_exit "skips non-git command" 0 \
  pipe_to "$SCRIPT" "$(cmd 'echo hello')"

assert_exit "skips git log" 0 \
  pipe_to "$SCRIPT" "$(cmd 'git log --oneline -10')"

# ─── Edge cases ───

assert_exit "skips --amend without -m (no message to validate)" 0 \
  pipe_to "$SCRIPT" "$(cmd 'git commit --amend')"

assert_exit "skips empty command" 0 \
  pipe_to "$SCRIPT" '{"tool_input":{"command":""}}'

# ─── Error message quality ───

assert_stderr_contains "reports invalid type" "valid type" \
  pipe_to "$SCRIPT" "$(cmd 'git commit -m \"bad: message\"')"

assert_stderr_contains "reports missing colon-space" "colon and space" \
  pipe_to "$SCRIPT" "$(cmd 'git commit -m \"feat add stuff\"')"
