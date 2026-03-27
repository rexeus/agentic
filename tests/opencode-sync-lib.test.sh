# opencode-sync-lib.test.sh — Tests for opencode-sync-lib pure functions

# ─── splitFrontmatter ───

assert_exit "splitFrontmatter separates frontmatter from body" 0 \
  node --input-type=module -e '
    import { splitFrontmatter } from "./scripts/opencode-sync-lib.mjs";
    const input = "---\nkey: value\n---\n\nBody content";
    const result = splitFrontmatter(input);
    if (result.rawFrontmatter !== "key: value") process.exit(1);
    if (result.body !== "Body content") process.exit(1);'

assert_exit "splitFrontmatter returns empty rawFrontmatter without frontmatter" 0 \
  node --input-type=module -e '
    import { splitFrontmatter } from "./scripts/opencode-sync-lib.mjs";
    const input = "Just plain content";
    const result = splitFrontmatter(input);
    if (result.rawFrontmatter !== "") process.exit(1);
    if (result.body !== "Just plain content") process.exit(1);'

assert_exit "splitFrontmatter strips trailing blank line after closing ---" 0 \
  node --input-type=module -e '
    import { splitFrontmatter } from "./scripts/opencode-sync-lib.mjs";
    const input = "---\ntitle: test\n---\n\nFirst paragraph";
    const result = splitFrontmatter(input);
    if (result.body !== "First paragraph") process.exit(1);'

# ─── parseFrontmatter ───

assert_exit "parseFrontmatter parses simple key-value" 0 \
  node --input-type=module -e '
    import { parseFrontmatter } from "./scripts/opencode-sync-lib.mjs";
    const result = parseFrontmatter("key: value");
    if (result.key !== "value") process.exit(1);'

assert_exit "parseFrontmatter parses multiple key-value pairs" 0 \
  node --input-type=module -e '
    import { parseFrontmatter } from "./scripts/opencode-sync-lib.mjs";
    const result = parseFrontmatter("name: alice\nage: 30");
    if (result.name !== "alice") process.exit(1);
    if (result.age !== "30") process.exit(1);'

assert_exit "parseFrontmatter parses folded scalar with >" 0 \
  node --input-type=module -e '
    import { parseFrontmatter } from "./scripts/opencode-sync-lib.mjs";
    const result = parseFrontmatter("description: >\n  line one\n  line two");
    if (!result.description.includes("line one")) process.exit(1);
    if (!result.description.includes("line two")) process.exit(1);'

assert_exit "parseFrontmatter parses list values" 0 \
  node --input-type=module -e '
    import { parseFrontmatter } from "./scripts/opencode-sync-lib.mjs";
    const result = parseFrontmatter("items:\n  - alpha\n  - beta");
    if (!Array.isArray(result.items)) process.exit(1);
    if (result.items.length !== 2) process.exit(1);
    if (result.items[0] !== "alpha") process.exit(1);
    if (result.items[1] !== "beta") process.exit(1);'

assert_exit "parseFrontmatter skips blank lines" 0 \
  node --input-type=module -e '
    import { parseFrontmatter } from "./scripts/opencode-sync-lib.mjs";
    const result = parseFrontmatter("name: alice\n\nage: 30");
    if (result.name !== "alice") process.exit(1);
    if (result.age !== "30") process.exit(1);'

assert_exit "parseFrontmatter trims whitespace from values" 0 \
  node --input-type=module -e '
    import { parseFrontmatter } from "./scripts/opencode-sync-lib.mjs";
    const result = parseFrontmatter("key:   padded value  ");
    if (result.key !== "padded value") process.exit(1);'

# ─── normalizeGeneratedContent ───

assert_exit "normalizeGeneratedContent converts CRLF to LF" 0 \
  node --input-type=module -e '
    import { normalizeGeneratedContent } from "./scripts/opencode-sync-lib.mjs";
    const result = normalizeGeneratedContent("line1\r\nline2\r\n");
    if (result !== "line1\nline2") process.exit(1);'

assert_exit "normalizeGeneratedContent trims whitespace" 0 \
  node --input-type=module -e '
    import { normalizeGeneratedContent } from "./scripts/opencode-sync-lib.mjs";
    const result = normalizeGeneratedContent("  hello world  ");
    if (result !== "hello world") process.exit(1);'

assert_exit "normalizeGeneratedContent leaves clean content unchanged" 0 \
  node --input-type=module -e '
    import { normalizeGeneratedContent } from "./scripts/opencode-sync-lib.mjs";
    const result = normalizeGeneratedContent("clean content");
    if (result !== "clean content") process.exit(1);'
