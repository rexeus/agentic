# opencode-plugin.test.sh — Tests for OpenCode plugin hooks

# ─── tool.execute.before: secret detection ───

assert_exit "before hook blocks write with hardcoded secret" 0 \
  node --input-type=module -e '
    import AgenticPlugin from "./opencode/plugin.mjs";
    const plugin = await AgenticPlugin();
    try {
      await plugin["tool.execute.before"]({ tool: "write" }, { args: { filePath: "config.ts", content: "const password = \"hunter2\"" } });
      process.exit(1);
    } catch (e) {
      if (!e.message.includes("Possible hardcoded secret")) process.exit(1);
    }'

assert_exit "before hook blocks edit with hardcoded secret" 0 \
  node --input-type=module -e '
    import AgenticPlugin from "./opencode/plugin.mjs";
    const plugin = await AgenticPlugin();
    try {
      await plugin["tool.execute.before"]({ tool: "edit" }, { args: { filePath: "config.ts", content: "const password = \"hunter2\"" } });
      process.exit(1);
    } catch (e) {
      if (!e.message.includes("Possible hardcoded secret")) process.exit(1);
    }'

assert_exit "before hook allows write with clean content" 0 \
  node --input-type=module -e '
    import AgenticPlugin from "./opencode/plugin.mjs";
    const plugin = await AgenticPlugin();
    await plugin["tool.execute.before"]({ tool: "write" }, { args: { filePath: "app.ts", content: "const x = 42" } });'

# ─── tool.execute.before: commit validation ───

assert_exit "before hook blocks non-conventional commit" 0 \
  node --input-type=module -e '
    import AgenticPlugin from "./opencode/plugin.mjs";
    const plugin = await AgenticPlugin();
    try {
      await plugin["tool.execute.before"]({ tool: "bash" }, { args: { command: "git commit -m \"bad message\"" } });
      process.exit(1);
    } catch (e) {
      if (!e.message.includes("Commit message validation failed")) process.exit(1);
    }'

assert_exit "before hook allows valid conventional commit" 0 \
  node --input-type=module -e '
    import AgenticPlugin from "./opencode/plugin.mjs";
    const plugin = await AgenticPlugin();
    await plugin["tool.execute.before"]({ tool: "bash" }, { args: { command: "git commit -m \"feat: add login flow\"" } });'

assert_exit "before hook allows non-commit bash command" 0 \
  node --input-type=module -e '
    import AgenticPlugin from "./opencode/plugin.mjs";
    const plugin = await AgenticPlugin();
    await plugin["tool.execute.before"]({ tool: "bash" }, { args: { command: "ls -la" } });'

assert_exit "before hook allows bash with empty command" 0 \
  node --input-type=module -e '
    import AgenticPlugin from "./opencode/plugin.mjs";
    const plugin = await AgenticPlugin();
    await plugin["tool.execute.before"]({ tool: "bash" }, { args: { command: "" } });'

assert_exit "before hook allows bash with null command" 0 \
  node --input-type=module -e '
    import AgenticPlugin from "./opencode/plugin.mjs";
    const plugin = await AgenticPlugin();
    await plugin["tool.execute.before"]({ tool: "bash" }, { args: { command: null } });'

assert_exit "before hook allows bash with undefined command" 0 \
  node --input-type=module -e '
    import AgenticPlugin from "./opencode/plugin.mjs";
    const plugin = await AgenticPlugin();
    await plugin["tool.execute.before"]({ tool: "bash" }, { args: {} });'

# ─── tool.execute.before: non-matching tools ───

assert_exit "before hook ignores non-write/edit/bash tool" 0 \
  node --input-type=module -e '
    import AgenticPlugin from "./opencode/plugin.mjs";
    const plugin = await AgenticPlugin();
    await plugin["tool.execute.before"]({ tool: "read" }, { args: { filePath: "src/app.ts" } });'

# ─── tool.execute.after: convention warnings ───

assert_exit "after hook appends warnings for console.log in JS file" 0 \
  bash -lc '
    file="$TEST_TMPDIR/plugin-debug.ts"
    printf "console.log(\"debug\")\n" > "$file"
    node --input-type=module -e "
      import AgenticPlugin from \"./opencode/plugin.mjs\";
      const plugin = await AgenticPlugin();
      const output = { output: \"\" };
      await plugin[\"tool.execute.after\"]({ tool: \"write\", args: { filePath: \"$file\" } }, output);
      if (!output.output.includes(\"agentic warnings\")) process.exit(1);
    "'

assert_exit "after hook appends warnings for merge conflict markers" 0 \
  bash -lc '
    file="$TEST_TMPDIR/plugin-conflict.ts"
    printf "<<<<<<< HEAD\nours\n=======\ntheirs\n>>>>>>> branch\n" > "$file"
    node --input-type=module -e "
      import AgenticPlugin from \"./opencode/plugin.mjs\";
      const plugin = await AgenticPlugin();
      const output = { output: \"\" };
      await plugin[\"tool.execute.after\"]({ tool: \"edit\", args: { filePath: \"$file\" } }, output);
      if (!output.output.includes(\"agentic warnings\")) process.exit(1);
    "'

assert_exit "after hook ignores non-write/edit tool" 0 \
  node --input-type=module -e '
    import AgenticPlugin from "./opencode/plugin.mjs";
    const plugin = await AgenticPlugin();
    const output = { output: "original" };
    await plugin["tool.execute.after"]({ tool: "bash", args: {} }, output);
    if (output.output !== "original") process.exit(1);'

assert_exit "after hook does not warn on clean JS file" 0 \
  bash -lc '
    file="$TEST_TMPDIR/plugin-clean.ts"
    printf "const x = 42;\n" > "$file"
    node --input-type=module -e "
      import AgenticPlugin from \"./opencode/plugin.mjs\";
      const plugin = await AgenticPlugin();
      const output = { output: \"done\" };
      await plugin[\"tool.execute.after\"]({ tool: \"write\", args: { filePath: \"$file\" } }, output);
      if (output.output !== \"done\") process.exit(1);
    "'

assert_exit "after hook appends warnings after existing output" 0 \
  bash -lc '
    file="$TEST_TMPDIR/plugin-existing.ts"
    printf "console.log(\"debug\")\n" > "$file"
    node --input-type=module -e "
      import AgenticPlugin from \"./opencode/plugin.mjs\";
      const plugin = await AgenticPlugin();
      const output = { output: \"existing content\" };
      await plugin[\"tool.execute.after\"]({ tool: \"write\", args: { filePath: \"$file\" } }, output);
      if (!output.output.startsWith(\"existing content\")) process.exit(1);
      if (!output.output.includes(\"\\n\\n[agentic warnings]\")) process.exit(1);
    "'

assert_exit "after hook sets warnings as output when output is empty" 0 \
  bash -lc '
    file="$TEST_TMPDIR/plugin-empty-output.ts"
    printf "console.log(\"debug\")\n" > "$file"
    node --input-type=module -e "
      import AgenticPlugin from \"./opencode/plugin.mjs\";
      const plugin = await AgenticPlugin();
      const output = { output: \"\" };
      await plugin[\"tool.execute.after\"]({ tool: \"write\", args: { filePath: \"$file\" } }, output);
      if (!output.output.startsWith(\"[agentic warnings]\")) process.exit(1);
    "'
