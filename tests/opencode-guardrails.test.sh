# opencode-guardrails.test.sh - Tests for OpenCode guardrail helpers

assert_exit "secret detector flags hardcoded secret" 0 \
  node --input-type=module -e 'import { findSecretViolations } from "./opencode/guardrails.mjs"; const violations = findSecretViolations({ filePath: "src/config.ts", content: "const password = \"hunter2\"" }); if (violations.length === 0) process.exit(1);'

assert_exit "secret detector allows safe content" 0 \
  node --input-type=module -e 'import { findSecretViolations } from "./opencode/guardrails.mjs"; const violations = findSecretViolations({ filePath: "src/app.ts", content: "const greeting = \"hello\"" }); if (violations.length !== 0) process.exit(1);'

assert_exit "commit validator flags non-conventional message" 0 \
  node --input-type=module -e 'import { validateConventionalCommitCommand } from "./opencode/guardrails.mjs"; const issues = validateConventionalCommitCommand("git commit -m \"bad message\""); if (issues.length === 0) process.exit(1);'

assert_exit "commit validator accepts valid conventional message" 0 \
  node --input-type=module -e 'import { validateConventionalCommitCommand } from "./opencode/guardrails.mjs"; const issues = validateConventionalCommitCommand("git commit -m \"feat: add login flow\""); if (issues.length !== 0) process.exit(1);'

assert_exit "convention checker finds debug warning" 0 \
  bash -lc 'file="$TEST_TMPDIR/debug.ts"; printf "console.log(\"debug\")\n" > "$file"; node --input-type=module -e "import { getConventionWarningsForFile } from \"./opencode/guardrails.mjs\"; const warnings = getConventionWarningsForFile(\"$file\"); if (warnings.length === 0) process.exit(1);"'

assert_exit "plugin exports executable hooks" 0 \
  node --input-type=module -e 'import AgenticPlugin from "./opencode/plugin.mjs"; const plugin = await AgenticPlugin({}); if (typeof plugin["tool.execute.before"] !== "function" || typeof plugin["tool.execute.after"] !== "function") process.exit(1);'

# ─── findSecretViolations: token patterns ───

assert_exit "secret detector flags OpenAI token pattern" 0 \
  bash -lc '
    token="sk-'"$(printf 'a%.0s' {1..26})"'"
    node --input-type=module -e "
      import { findSecretViolations } from \"./opencode/guardrails.mjs\";
      const v = findSecretViolations({ filePath: \"f.ts\", content: \"$token\" });
      if (v.length === 0) process.exit(1);
    "'

assert_exit "secret detector flags GitHub PAT pattern" 0 \
  bash -lc '
    token="ghp_'"$(printf 'A%.0s' {1..36})"'"
    node --input-type=module -e "
      import { findSecretViolations } from \"./opencode/guardrails.mjs\";
      const v = findSecretViolations({ filePath: \"f.ts\", content: \"$token\" });
      if (v.length === 0) process.exit(1);
    "'

assert_exit "secret detector flags AWS access key pattern" 0 \
  bash -lc '
    token="AKIA'"$(printf 'A%.0s' {1..16})"'"
    node --input-type=module -e "
      import { findSecretViolations } from \"./opencode/guardrails.mjs\";
      const v = findSecretViolations({ filePath: \"f.ts\", content: \"$token\" });
      if (v.length === 0) process.exit(1);
    "'

assert_exit "secret detector flags Stripe live key pattern" 0 \
  bash -lc '
    token="sk_live_'"$(printf 'a%.0s' {1..24})"'"
    node --input-type=module -e "
      import { findSecretViolations } from \"./opencode/guardrails.mjs\";
      const v = findSecretViolations({ filePath: \"f.ts\", content: \"$token\" });
      if (v.length === 0) process.exit(1);
    "'

assert_exit "secret detector returns two violations for secret + token" 0 \
  bash -lc '
    token="sk-'"$(printf 'a%.0s' {1..26})"'"
    node --input-type=module -e "
      import { findSecretViolations } from \"./opencode/guardrails.mjs\";
      const v = findSecretViolations({ filePath: \"f.ts\", content: \"const password = \\\"hunter2\\\" $token\" });
      if (v.length !== 2) process.exit(1);
    "'

assert_exit "secret detector returns empty for null content" 0 \
  node --input-type=module -e '
    import { findSecretViolations } from "./opencode/guardrails.mjs";
    const v = findSecretViolations({ filePath: "f.ts", content: null });
    if (v.length !== 0) process.exit(1);'

assert_exit "secret detector returns empty for undefined content" 0 \
  node --input-type=module -e '
    import { findSecretViolations } from "./opencode/guardrails.mjs";
    const v = findSecretViolations({ filePath: "f.ts", content: undefined });
    if (v.length !== 0) process.exit(1);'

assert_exit "secret detector uses file as label when filePath is missing" 0 \
  node --input-type=module -e '
    import { findSecretViolations } from "./opencode/guardrails.mjs";
    const v = findSecretViolations({ content: "const password = \"hunter2\"" });
    if (v.length === 0) process.exit(1);
    if (!v[0].includes("file")) process.exit(1);'

assert_exit "secret detector flags unquoted assignment" 0 \
  node --input-type=module -e '
    import { findSecretViolations } from "./opencode/guardrails.mjs";
    const v = findSecretViolations({ filePath: "f.ts", content: "API_KEY=somevalue1234" });
    if (v.length === 0) process.exit(1);'

# ─── validateConventionalCommitCommand: additional cases ───

assert_exit "commit validator flags uppercase description" 0 \
  node --input-type=module -e '
    import { validateConventionalCommitCommand } from "./opencode/guardrails.mjs";
    const issues = validateConventionalCommitCommand("git commit -m \"feat: Add login\"");
    if (!issues.some(i => i.includes("lowercase"))) process.exit(1);'

assert_exit "commit validator flags trailing period" 0 \
  node --input-type=module -e '
    import { validateConventionalCommitCommand } from "./opencode/guardrails.mjs";
    const issues = validateConventionalCommitCommand("git commit -m \"feat: add login.\"");
    if (!issues.some(i => i.includes("period"))) process.exit(1);'

assert_exit "commit validator flags header over 100 chars" 0 \
  node --input-type=module -e '
    import { validateConventionalCommitCommand } from "./opencode/guardrails.mjs";
    const long = "feat: " + "a".repeat(96);
    const issues = validateConventionalCommitCommand("git commit -m \"" + long + "\"");
    if (!issues.some(i => i.includes("100 characters"))) process.exit(1);'

assert_exit "commit validator accepts scoped commit" 0 \
  node --input-type=module -e '
    import { validateConventionalCommitCommand } from "./opencode/guardrails.mjs";
    const issues = validateConventionalCommitCommand("git commit -m \"feat(auth): add login\"");
    if (issues.length !== 0) process.exit(1);'

assert_exit "commit validator accepts breaking change" 0 \
  node --input-type=module -e '
    import { validateConventionalCommitCommand } from "./opencode/guardrails.mjs";
    const issues = validateConventionalCommitCommand("git commit -m \"feat!: breaking change\"");
    if (issues.length !== 0) process.exit(1);'

assert_exit "commit validator ignores non-commit command" 0 \
  node --input-type=module -e '
    import { validateConventionalCommitCommand } from "./opencode/guardrails.mjs";
    const issues = validateConventionalCommitCommand("echo hello");
    if (issues.length !== 0) process.exit(1);'

assert_exit "commit validator extracts and validates heredoc message" 0 \
  node --input-type=module -e '
    import { validateConventionalCommitCommand } from "./opencode/guardrails.mjs";
    const cmd = "git commit -m \"$(cat <<EOF\nbad message\nEOF\n)\"";
    const issues = validateConventionalCommitCommand(cmd);
    if (issues.length === 0) process.exit(1);'

assert_exit "commit validator accepts valid heredoc message" 0 \
  node --input-type=module -e '
    import { validateConventionalCommitCommand } from "./opencode/guardrails.mjs";
    const cmd = "git commit -m \"$(cat <<EOF\nfeat: add login\nEOF\n)\"";
    const issues = validateConventionalCommitCommand(cmd);
    if (issues.length !== 0) process.exit(1);'

assert_exit "commit validator allows amend without message" 0 \
  node --input-type=module -e '
    import { validateConventionalCommitCommand } from "./opencode/guardrails.mjs";
    const issues = validateConventionalCommitCommand("git commit --amend");
    if (issues.length !== 0) process.exit(1);'

# ─── getConventionWarningsForFile: additional cases ───

assert_exit "convention checker finds merge conflict markers" 0 \
  bash -lc '
    file="$TEST_TMPDIR/guardrails-conflict.ts"
    printf "<<<<<<< HEAD\nours\n=======\ntheirs\n>>>>>>> branch\n" > "$file"
    node --input-type=module -e "
      import { getConventionWarningsForFile } from \"./opencode/guardrails.mjs\";
      const w = getConventionWarningsForFile(\"$file\");
      if (!w.some(m => m.includes(\"Merge conflict\"))) process.exit(1);
    "'

assert_exit "convention checker finds unowned TODO" 0 \
  bash -lc '
    file="$TEST_TMPDIR/guardrails-todo.ts"
    printf "// TODO fix this later\n" > "$file"
    node --input-type=module -e "
      import { getConventionWarningsForFile } from \"./opencode/guardrails.mjs\";
      const w = getConventionWarningsForFile(\"$file\");
      if (!w.some(m => m.includes(\"TODO\"))) process.exit(1);
    "'

assert_exit "convention checker does not flag owned TODO" 0 \
  bash -lc '
    file="$TEST_TMPDIR/guardrails-todo-owned.ts"
    printf "// TODO(dennis) fix this later\n" > "$file"
    node --input-type=module -e "
      import { getConventionWarningsForFile } from \"./opencode/guardrails.mjs\";
      const w = getConventionWarningsForFile(\"$file\");
      if (w.some(m => m.includes(\"TODO\"))) process.exit(1);
    "'

assert_exit "convention checker skips binary file paths" 0 \
  node --input-type=module -e '
    import { getConventionWarningsForFile } from "./opencode/guardrails.mjs";
    const w = getConventionWarningsForFile("image.png");
    if (w.length !== 0) process.exit(1);'

assert_exit "convention checker finds console.debug" 0 \
  bash -lc '
    file="$TEST_TMPDIR/guardrails-console-debug.ts"
    printf "console.debug(\"test\")\n" > "$file"
    node --input-type=module -e "
      import { getConventionWarningsForFile } from \"./opencode/guardrails.mjs\";
      const w = getConventionWarningsForFile(\"$file\");
      if (!w.some(m => m.includes(\"Debug statement\"))) process.exit(1);
    "'

assert_exit "convention checker finds debugger keyword" 0 \
  bash -lc '
    file="$TEST_TMPDIR/guardrails-debugger.ts"
    printf "function test() {\n  debugger;\n}\n" > "$file"
    node --input-type=module -e "
      import { getConventionWarningsForFile } from \"./opencode/guardrails.mjs\";
      const w = getConventionWarningsForFile(\"$file\");
      if (!w.some(m => m.includes(\"Debug statement\"))) process.exit(1);
    "'

assert_exit "convention checker skips debug checks for non-JS files" 0 \
  bash -lc '
    file="$TEST_TMPDIR/guardrails-readme.md"
    printf "console.log(\"example\")\n" > "$file"
    node --input-type=module -e "
      import { getConventionWarningsForFile } from \"./opencode/guardrails.mjs\";
      const w = getConventionWarningsForFile(\"$file\");
      if (w.some(m => m.includes(\"Debug statement\"))) process.exit(1);
    "'

assert_exit "convention checker returns empty for nonexistent file" 0 \
  node --input-type=module -e '
    import { getConventionWarningsForFile } from "./opencode/guardrails.mjs";
    const w = getConventionWarningsForFile("/tmp/does-not-exist-guardrails-test.ts");
    if (w.length !== 0) process.exit(1);'

# ─── extractFilePath / extractWriteContent ───

assert_exit "extractFilePath prefers filePath over file_path over path" 0 \
  node --input-type=module -e '
    import { extractFilePath } from "./opencode/guardrails.mjs";
    if (extractFilePath({ filePath: "a.ts", file_path: "b.ts", path: "c.ts" }) !== "a.ts") process.exit(1);
    if (extractFilePath({ file_path: "b.ts", path: "c.ts" }) !== "b.ts") process.exit(1);
    if (extractFilePath({ path: "c.ts" }) !== "c.ts") process.exit(1);'

assert_exit "extractFilePath returns empty string for null args" 0 \
  node --input-type=module -e '
    import { extractFilePath } from "./opencode/guardrails.mjs";
    if (extractFilePath(null) !== "") process.exit(1);
    if (extractFilePath(undefined) !== "") process.exit(1);'

assert_exit "extractWriteContent prefers content over newString over new_string" 0 \
  node --input-type=module -e '
    import { extractWriteContent } from "./opencode/guardrails.mjs";
    if (extractWriteContent({ content: "a", newString: "b", new_string: "c" }) !== "a") process.exit(1);
    if (extractWriteContent({ newString: "b", new_string: "c" }) !== "b") process.exit(1);
    if (extractWriteContent({ new_string: "c" }) !== "c") process.exit(1);'

assert_exit "extractWriteContent returns empty string for null args" 0 \
  node --input-type=module -e '
    import { extractWriteContent } from "./opencode/guardrails.mjs";
    if (extractWriteContent(null) !== "") process.exit(1);
    if (extractWriteContent(undefined) !== "") process.exit(1);'
