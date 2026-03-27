# opencode-cli.test.sh - Tests for OpenCode installer CLI flow

SCRIPT="$REPO_ROOT/bin/agentic.js"

run_cli() {
  local config_dir="$1"
  shift
  OPENCODE_CONFIG_DIR="$config_dir" node "$SCRIPT" "$@"
}

assert_exit "doctor on clean machine does not create config state" 0 \
  bash -lc 'config_dir="$TEST_TMPDIR/opencode-clean-doctor"; rm -rf "$config_dir"; OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" doctor >/dev/null; test ! -e "$config_dir"'

assert_exit "uninstall on clean machine does not create config state" 0 \
  bash -lc 'config_dir="$TEST_TMPDIR/opencode-clean-uninstall"; rm -rf "$config_dir"; OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" uninstall opencode >/dev/null; test ! -e "$config_dir"'

assert_exit "install opencode succeeds" 0 \
  bash -lc 'config_dir="$TEST_TMPDIR/opencode-config"; mkdir -p "$config_dir"; OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" install opencode >/dev/null'

assert_exit "install fails on malformed config without overwriting it" 1 \
  bash -lc 'config_dir="$TEST_TMPDIR/opencode-invalid-install"; mkdir -p "$config_dir"; printf "{\n  \"plugin\": [\n" > "$config_dir/opencode.json"; OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" install opencode >/dev/null 2>&1; status="$?"; test "$status" -eq 1; grep -q "\"plugin\"" "$config_dir/opencode.json"; test ! -e "$config_dir/commands"; ! ls "$config_dir"/opencode.json.bak.* >/dev/null 2>&1; exit "$status"'

assert_stderr_contains "install reports malformed config and no changes made" "No changes were made." \
  bash -lc 'config_dir="$TEST_TMPDIR/opencode-invalid-install"; OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" install opencode'

assert_exit "install fails when plugin key is not an array without overwriting it" 1 \
  bash -lc 'config_dir="$TEST_TMPDIR/opencode-invalid-plugin-install"; mkdir -p "$config_dir"; cat <<"EOF" > "$config_dir/opencode.json"
{
  "plugin": "@rexeus/agentic",
  "theme": "dark"
}
EOF
original_contents="$(cat "$config_dir/opencode.json")"; OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" install opencode >/dev/null 2>&1; status="$?"; test "$status" -eq 1; test "$(cat "$config_dir/opencode.json")" = "$original_contents"; test ! -e "$config_dir/commands"; ! ls "$config_dir"/opencode.json.bak.* >/dev/null 2>&1; exit "$status"'

assert_stderr_contains "install reports non-array plugin config explicitly" "expected 'plugin' to be an array when present. No changes were made." \
  bash -lc 'config_dir="$TEST_TMPDIR/opencode-invalid-plugin-install"; OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" install opencode'

assert_exit "uninstall fails on malformed config without overwriting it" 1 \
  bash -lc 'config_dir="$TEST_TMPDIR/opencode-invalid-uninstall"; mkdir -p "$config_dir/commands"; printf "{\n  // broken\n  \"plugin\": [\n" > "$config_dir/opencode.jsonc"; printf "<!-- Installed by @rexeus/agentic command -->\n" > "$config_dir/commands/agentic-test.md"; OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" uninstall opencode >/dev/null 2>&1; status="$?"; test "$status" -eq 1; grep -q "\"plugin\"" "$config_dir/opencode.jsonc"; test -f "$config_dir/commands/agentic-test.md"; ! ls "$config_dir"/opencode.jsonc.bak.* >/dev/null 2>&1; exit "$status"'

assert_stderr_contains "uninstall reports malformed config and no changes made" "No changes were made." \
  bash -lc 'config_dir="$TEST_TMPDIR/opencode-invalid-uninstall"; OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" uninstall opencode'

assert_exit "uninstall fails when plugin key is not an array without overwriting it" 1 \
  bash -lc 'config_dir="$TEST_TMPDIR/opencode-invalid-plugin-uninstall"; mkdir -p "$config_dir/commands"; cat <<"EOF" > "$config_dir/opencode.json"
{
  "plugin": {
    "name": "@rexeus/agentic"
  },
  "theme": "dark"
}
EOF
printf "<!-- Installed by @rexeus/agentic command -->\n" > "$config_dir/commands/agentic-test.md"; original_contents="$(cat "$config_dir/opencode.json")"; OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" uninstall opencode >/dev/null 2>&1; status="$?"; test "$status" -eq 1; test "$(cat "$config_dir/opencode.json")" = "$original_contents"; test -f "$config_dir/commands/agentic-test.md"; ! ls "$config_dir"/opencode.json.bak.* >/dev/null 2>&1; exit "$status"'

assert_stderr_contains "uninstall reports non-array plugin config explicitly" "expected 'plugin' to be an array when present. No changes were made." \
  bash -lc 'config_dir="$TEST_TMPDIR/opencode-invalid-plugin-uninstall"; OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" uninstall opencode'

assert_stdout_contains "doctor reports invalid config read-only" "Config valid: no" \
  bash -lc 'config_dir="$TEST_TMPDIR/opencode-invalid-install"; OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" doctor'

assert_stdout_contains "doctor reports plugin installed" "Plugin installed: yes" \
  bash -lc 'config_dir="$TEST_TMPDIR/opencode-config"; OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" doctor'

assert_stdout_contains "doctor reports commands installed" "Commands installed: yes" \
  bash -lc 'config_dir="$TEST_TMPDIR/opencode-config"; OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" doctor'

assert_stdout_contains "doctor reports agents installed" "Agents installed: yes" \
  bash -lc 'config_dir="$TEST_TMPDIR/opencode-config"; OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" doctor'

assert_stdout_contains "doctor reports skills installed" "Skills installed: yes" \
  bash -lc 'config_dir="$TEST_TMPDIR/opencode-config"; OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" doctor'

assert_stdout_contains "config contains plugin entry" "@rexeus/agentic" \
  bash -lc 'config_dir="$TEST_TMPDIR/opencode-config"; cat "$config_dir/opencode.json"'

assert_stdout_contains "lead agent installed globally" "mode: \"primary\"" \
  bash -lc 'config_dir="$TEST_TMPDIR/opencode-config"; cat "$config_dir/agents/lead.md"'

assert_stdout_contains "setup skill installed globally" "name: setup" \
  bash -lc 'config_dir="$TEST_TMPDIR/opencode-config"; cat "$config_dir/skills/setup/SKILL.md"'

assert_exit "uninstall preserves unmarked user command" 0 \
  bash -lc 'config_dir="$TEST_TMPDIR/opencode-config"; mkdir -p "$config_dir/commands"; printf "# user command\n" > "$config_dir/commands/agentic-custom.md"; OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" uninstall opencode >/dev/null; test -f "$config_dir/commands/agentic-custom.md"'

assert_exit "install and uninstall preserve unmarked user agent" 0 \
  bash -lc 'config_dir="$TEST_TMPDIR/opencode-owned-agent"; mkdir -p "$config_dir/agents"; cat <<"EOF" > "$config_dir/agents/lead.md"
---
description: "user lead"
mode: "primary"
---
EOF
OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" install opencode >/dev/null; grep -q "user lead" "$config_dir/agents/lead.md"; OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" uninstall opencode >/dev/null; grep -q "user lead" "$config_dir/agents/lead.md"'

assert_exit "install and uninstall preserve unmarked user skill" 0 \
  bash -lc 'config_dir="$TEST_TMPDIR/opencode-owned-skill"; mkdir -p "$config_dir/skills/setup"; cat <<"EOF" > "$config_dir/skills/setup/SKILL.md"
---
name: setup
---

# User setup skill
EOF
OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" install opencode >/dev/null; grep -q "User setup skill" "$config_dir/skills/setup/SKILL.md"; OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" uninstall opencode >/dev/null; grep -q "User setup skill" "$config_dir/skills/setup/SKILL.md"'

assert_exit "uninstall preserves user files in agentic-owned skill directory" 0 \
  bash -lc 'config_dir="$TEST_TMPDIR/opencode-skill-extra-files"; mkdir -p "$config_dir"; OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" install opencode >/dev/null; printf "user note\n" > "$config_dir/skills/setup/notes.txt"; OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" uninstall opencode >/dev/null; test ! -f "$config_dir/skills/setup/SKILL.md" && test -f "$config_dir/skills/setup/notes.txt"'

assert_exit "install restores missing agentic skill file without deleting user files" 0 \
  bash -lc 'config_dir="$TEST_TMPDIR/opencode-skill-reinstall"; mkdir -p "$config_dir"; OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" install opencode >/dev/null; printf "user note\n" > "$config_dir/skills/setup/notes.txt"; rm "$config_dir/skills/setup/SKILL.md"; OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" install opencode >/dev/null; grep -q "Installed by @rexeus/agentic" "$config_dir/skills/setup/SKILL.md" && grep -q "name: setup" "$config_dir/skills/setup/SKILL.md" && test -f "$config_dir/skills/setup/notes.txt"'

assert_exit "install preserves conflicting user command" 0 \
  bash -lc 'config_dir="$TEST_TMPDIR/opencode-command-conflict"; mkdir -p "$config_dir/commands"; printf "# user plan command\n" > "$config_dir/commands/agentic-plan.md"; OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" install opencode >/dev/null; grep -q "user plan command" "$config_dir/commands/agentic-plan.md"'

assert_stdout_contains "install reports conflicting user command" "command conflict: agentic-plan.md" \
  bash -lc 'config_dir="$TEST_TMPDIR/opencode-command-conflict"; OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" install opencode'

assert_stdout_contains "doctor reports conflicting user command" "command conflict: agentic-plan.md" \
  bash -lc 'config_dir="$TEST_TMPDIR/opencode-command-conflict"; OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" doctor'

assert_stdout_contains "doctor does not treat conflicting commands as fully installed" "Commands installed: no (1 conflicting, 0 missing)" \
  bash -lc 'config_dir="$TEST_TMPDIR/opencode-command-conflict"; OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" doctor'

assert_exit "uninstall preserves conflicting user command" 0 \
  bash -lc 'config_dir="$TEST_TMPDIR/opencode-command-conflict"; OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" uninstall opencode >/dev/null; grep -q "user plan command" "$config_dir/commands/agentic-plan.md"'

assert_exit "install preserves conflicting user agent and skill" 0 \
  bash -lc 'config_dir="$TEST_TMPDIR/opencode-asset-conflicts"; mkdir -p "$config_dir/agents" "$config_dir/skills/setup"; cat <<"EOF" > "$config_dir/agents/lead.md"
---
description: "user lead"
mode: "primary"
---
EOF
cat <<"EOF" > "$config_dir/skills/setup/SKILL.md"
---
name: setup
---

# User setup skill
EOF
OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" install opencode >/dev/null; grep -q "user lead" "$config_dir/agents/lead.md" && grep -q "User setup skill" "$config_dir/skills/setup/SKILL.md"'

assert_stdout_contains "install reports conflicting user agent" "agent conflict: lead.md" \
  bash -lc 'config_dir="$TEST_TMPDIR/opencode-asset-conflicts"; OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" install opencode'

assert_stdout_contains "install reports conflicting user skill" "skill conflict: setup" \
  bash -lc 'config_dir="$TEST_TMPDIR/opencode-asset-conflicts"; OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" install opencode'

assert_stdout_contains "doctor reports conflicting user agent" "agent conflict: lead.md" \
  bash -lc 'config_dir="$TEST_TMPDIR/opencode-asset-conflicts"; OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" doctor'

assert_stdout_contains "doctor reports conflicting user skill" "skill conflict: setup" \
  bash -lc 'config_dir="$TEST_TMPDIR/opencode-asset-conflicts"; OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" doctor'

assert_stdout_contains "doctor does not treat conflicting agents as fully installed" "Agents installed: no (1 conflicting, 0 missing)" \
  bash -lc 'config_dir="$TEST_TMPDIR/opencode-asset-conflicts"; OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" doctor'

assert_stdout_contains "doctor does not treat conflicting skills as fully installed" "Skills installed: no (1 conflicting, 0 missing)" \
  bash -lc 'config_dir="$TEST_TMPDIR/opencode-asset-conflicts"; OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" doctor'

assert_exit "uninstall preserves conflicting user agent and skill" 0 \
  bash -lc 'config_dir="$TEST_TMPDIR/opencode-asset-conflicts"; OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" uninstall opencode >/dev/null; grep -q "user lead" "$config_dir/agents/lead.md" && grep -q "User setup skill" "$config_dir/skills/setup/SKILL.md"'

assert_exit "plugin key is removed when originally absent" 0 \
  bash -lc 'config_dir="$TEST_TMPDIR/opencode-no-plugin"; mkdir -p "$config_dir"; cat <<"EOF" > "$config_dir/opencode.json"
{
  "theme": "dark"
}
EOF
OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" install opencode >/dev/null; OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" uninstall opencode >/dev/null; node -e "const fs=require(\"node:fs\"); const config=JSON.parse(fs.readFileSync(process.argv[1], \"utf8\")); if (Object.hasOwn(config, \"plugin\")) process.exit(1); if (config.theme !== \"dark\") process.exit(1);" "$config_dir/opencode.json"'

assert_exit "install preserves jsonc comments" 0 \
  bash -lc 'config_dir="$TEST_TMPDIR/opencode-jsonc"; mkdir -p "$config_dir"; cat <<"EOF" > "$config_dir/opencode.jsonc"
{
  // keep this comment
  "plugin": [
    "example/plugin"
  ]
}
EOF
OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" install opencode >/dev/null; grep -q "// keep this comment" "$config_dir/opencode.jsonc"'

assert_exit "uninstall preserves jsonc comments" 0 \
  bash -lc 'config_dir="$TEST_TMPDIR/opencode-jsonc"; OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" uninstall opencode >/dev/null; grep -q "// keep this comment" "$config_dir/opencode.jsonc"'

assert_exit "plugin roundtrip preserves other plugins and removes versioned agentic entries" 0 \
  bash -lc 'config_dir="$TEST_TMPDIR/opencode-plugin-roundtrip"; mkdir -p "$config_dir"; cat <<"EOF" > "$config_dir/opencode.json"
{
  "plugin": [
    "example/plugin-a",
    "@rexeus/agentic@0.0.1",
    "example/plugin-b",
    "@rexeus/agentic@0.0.2"
  ]
}
EOF
OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" install opencode >/dev/null
node -e "const fs=require(\"node:fs\"); const config=JSON.parse(fs.readFileSync(process.argv[1], \"utf8\")); const plugins=config.plugin; if (!Array.isArray(plugins)) process.exit(1); if (plugins.length !== 3) process.exit(1); if (plugins[0] !== \"example/plugin-a\") process.exit(1); if (plugins[1] !== \"example/plugin-b\") process.exit(1); if (plugins[2] !== \"@rexeus/agentic\") process.exit(1);" "$config_dir/opencode.json"
OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" uninstall opencode >/dev/null
node -e "const fs=require(\"node:fs\"); const config=JSON.parse(fs.readFileSync(process.argv[1], \"utf8\")); const plugins=config.plugin; if (!Array.isArray(plugins)) process.exit(1); if (plugins.length !== 2) process.exit(1); if (plugins[0] !== \"example/plugin-a\") process.exit(1); if (plugins[1] !== \"example/plugin-b\") process.exit(1); if (plugins.some((entry) => typeof entry === \"string\" && entry.startsWith(\"@rexeus/agentic\"))) process.exit(1);" "$config_dir/opencode.json"'

assert_exit "tuple plugin entries are preserved and deduped on install" 0 \
  bash -lc 'config_dir="$TEST_TMPDIR/opencode-plugin-tuple"; mkdir -p "$config_dir"; cat <<"EOF" > "$config_dir/opencode.json"
{
  "plugin": [
    "example/plugin-a",
    ["@rexeus/agentic", { "mode": "config" }],
    "example/plugin-b"
  ]
}
EOF
OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" install opencode >/dev/null
node -e "const fs=require(\"node:fs\"); const config=JSON.parse(fs.readFileSync(process.argv[1], \"utf8\")); const plugins=config.plugin; if (!Array.isArray(plugins)) process.exit(1); if (plugins.length !== 3) process.exit(1); if (plugins[0] !== \"example/plugin-a\") process.exit(1); if (plugins[1] !== \"example/plugin-b\") process.exit(1); if (!Array.isArray(plugins[2])) process.exit(1); if (plugins[2][0] !== \"@rexeus/agentic\") process.exit(1); if (plugins[2][1]?.mode !== \"config\") process.exit(1); if (plugins.filter((entry) => (typeof entry === \"string\" && entry === \"@rexeus/agentic\") || (Array.isArray(entry) && entry[0] === \"@rexeus/agentic\")).length !== 1) process.exit(1);" "$config_dir/opencode.json"'

assert_stdout_contains "doctor reports tuple plugin via config" "Plugin via config: yes" \
  bash -lc 'config_dir="$TEST_TMPDIR/opencode-plugin-tuple"; OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" doctor'

assert_exit "tuple plugin entries are removed on uninstall" 0 \
  bash -lc 'config_dir="$TEST_TMPDIR/opencode-plugin-tuple"; OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" uninstall opencode >/dev/null
node -e "const fs=require(\"node:fs\"); const config=JSON.parse(fs.readFileSync(process.argv[1], \"utf8\")); const plugins=config.plugin; if (!Array.isArray(plugins)) process.exit(1); if (plugins.length !== 2) process.exit(1); if (plugins[0] !== \"example/plugin-a\") process.exit(1); if (plugins[1] !== \"example/plugin-b\") process.exit(1); if (plugins.some((entry) => (typeof entry === \"string\" && entry.startsWith(\"@rexeus/agentic\")) || (Array.isArray(entry) && typeof entry[0] === \"string\" && entry[0].startsWith(\"@rexeus/agentic\")))) process.exit(1);" "$config_dir/opencode.json"'

assert_exit "uninstall is a no-op when config has other plugins only" 0 \
  bash -lc 'config_dir="$TEST_TMPDIR/opencode-uninstall-noop"; mkdir -p "$config_dir"; cat <<"EOF" > "$config_dir/opencode.json"
{
  "plugin": [
    "example/plugin-a",
    "example/plugin-b"
  ],
  "theme": "dark"
}
EOF
original_contents="$(cat "$config_dir/opencode.json")"
OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" uninstall opencode >/dev/null
test "$(cat "$config_dir/opencode.json")" = "$original_contents"
! ls "$config_dir"/opencode.json.bak.* >/dev/null 2>&1'

assert_exit "uninstall opencode succeeds" 0 \
  bash -lc 'config_dir="$TEST_TMPDIR/opencode-config"; OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" uninstall opencode >/dev/null'

assert_stdout_contains "doctor reports plugin removed after uninstall" "Plugin installed: no" \
  bash -lc 'config_dir="$TEST_TMPDIR/opencode-config"; OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" doctor'

assert_stdout_contains "doctor reports missing commands after uninstall" "Commands installed: no" \
  bash -lc 'config_dir="$TEST_TMPDIR/opencode-config"; OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" doctor'

assert_stdout_contains "doctor reports missing agents after uninstall" "Agents installed: no" \
  bash -lc 'config_dir="$TEST_TMPDIR/opencode-config"; OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" doctor'

assert_stdout_contains "doctor reports missing skills after uninstall" "Skills installed: no" \
  bash -lc 'config_dir="$TEST_TMPDIR/opencode-config"; OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" doctor'

assert_stdout_contains "doctor detects local plugin file" "Plugin installed: yes" \
  bash -lc 'config_dir="$TEST_TMPDIR/opencode-local-plugin"; mkdir -p "$config_dir/plugins"; printf "import AgenticPlugin from \"%s/opencode/plugin.mjs\";\nexport default AgenticPlugin;\n" "$REPO_ROOT" > "$config_dir/plugins/agentic-local.mjs"; OPENCODE_CONFIG_DIR="$config_dir" node "$REPO_ROOT/bin/agentic.js" doctor'
