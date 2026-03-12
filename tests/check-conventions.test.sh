# check-conventions.test.sh — Tests for convention check hook
# This hook is PostToolUse (informational, always exit 0).
# We test that warnings appear in stdout when expected.

SCRIPT="$REPO_ROOT/scripts/check-conventions.sh"

# Helper: create a temp file with content and build the hook JSON input
check_file() {
  local filename="$1"
  local content="$2"
  local filepath="$TEST_TMPDIR/$filename"
  printf '%s\n' "$content" > "$filepath"
  printf '{"tool_input":{"file_path":"%s"}}' "$filepath"
}

# ─── Debug statements: should WARN ───

assert_stdout_contains "warns on console.log" "Debug statement" \
  pipe_to "$SCRIPT" "$(check_file "app.ts" "console.log('debug')")"

assert_stdout_contains "warns on console.debug" "Debug statement" \
  pipe_to "$SCRIPT" "$(check_file "app.ts" "console.debug('test')")"

assert_stdout_contains "warns on debugger keyword" "Debug statement" \
  pipe_to "$SCRIPT" "$(check_file "app.ts" "debugger")"

assert_stdout_contains "warns in .tsx files" "Debug statement" \
  pipe_to "$SCRIPT" "$(check_file "App.tsx" "console.log('render')")"

assert_stdout_contains "warns in .mjs files" "Debug statement" \
  pipe_to "$SCRIPT" "$(check_file "utils.mjs" "console.log('test')")"

# ─── console.warn: should NOT warn (legitimate production use) ───

assert_stdout_empty "does NOT warn on console.warn alone" \
  pipe_to "$SCRIPT" "$(check_file "warn-only.ts" 'console.warn("deprecation notice")')"

# ─── TODOs: should WARN ───

assert_stdout_contains "warns on bare TODO" "Unowned TODO" \
  pipe_to "$SCRIPT" "$(check_file "app.ts" "// TODO fix this")"

assert_stdout_contains "warns on TODO with colon" "Unowned TODO" \
  pipe_to "$SCRIPT" "$(check_file "app.ts" "// TODO: refactor")"

assert_stdout_contains "warns on standalone TODO" "Unowned TODO" \
  pipe_to "$SCRIPT" "$(check_file "app.ts" "// TODO")"

# ─── TODOs: should NOT warn (owned) ───

assert_stdout_empty "does NOT warn on TODO(owner)" \
  pipe_to "$SCRIPT" "$(check_file "owned.ts" '// TODO(dennis) fix this')"

assert_stdout_empty "does NOT warn on TODO(#issue)" \
  pipe_to "$SCRIPT" "$(check_file "issue.ts" '// TODO(#123) track this')"

# ─── TODOLIST false positive: should NOT warn ───

assert_stdout_empty "does NOT warn on TODOLIST identifier" \
  pipe_to "$SCRIPT" "$(check_file "todolist.ts" 'const TODOLIST = []')"

# ─── Merge conflict markers: should WARN ───

assert_stdout_contains "warns on merge conflict markers" "Merge conflict" \
  pipe_to "$SCRIPT" "$(check_file "app.ts" "<<<<<<< HEAD")"

# ─── Binary files: should skip (no output) ───

assert_stdout_empty "skips binary files (.png)" \
  pipe_to "$SCRIPT" "$(check_file "image.png" 'console.log("in a png")')"

# ─── Non-JS files: should skip debug/TODO checks ───

assert_stdout_empty "skips debug check for non-JS files" \
  pipe_to "$SCRIPT" "$(check_file "app.py" 'console.log("not real python")')"

# ─── All convention checks always exit 0 ───

assert_exit "always exits 0 even with warnings" 0 \
  pipe_to "$SCRIPT" "$(check_file "app.ts" "console.log('test')")"
