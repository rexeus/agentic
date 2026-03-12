# block-secrets.test.sh — Tests for secret detection hook
# All sensitive patterns are constructed at runtime to avoid triggering
# the hook on this test file itself.

SCRIPT="$REPO_ROOT/scripts/block-secrets.sh"

# Build test values at runtime
PW="hunter2"
PW_KEY="password"
SEC_KEY="secret"
AK_KEY="api_key"
LONG_VAL="mySecretValue123"
ENV_VAL="hunter2longvalue"

# Token patterns constructed at runtime
OPENAI_TOKEN="sk-$(printf 'a%.0s' {1..26})"
GHP_TOKEN="ghp_$(printf 'A%.0s' {1..36})"
GHO_TOKEN="gho_$(printf 'A%.0s' {1..36})"
GHPAT_TOKEN="github""_pat_11ABCDEFGH0123456789_abc"
AWS_KEY_ID="AKIA$(printf 'A%.0s' {1..16})"
AWS_SEC="aws_$(printf 'a%.0s' {1..24})"
STRIPE_L="sk_live""_$(printf 'a%.0s' {1..24})"
STRIPE_T="sk_test""_$(printf 'a%.0s' {1..24})"
SLACK_B="xoxb""-1234567890-1234567890123-$(printf 'a%.0s' {1..16})"
SLACK_U="xoxp""-1234567890-1234567890123-$(printf 'a%.0s' {1..16})"

# Helper: create Write tool JSON with content
mk() {
  local content="$1"
  local file="${2:-src/config.ts}"
  printf '{"tool_input":{"file_path":"%s","content":"%s"}}' "$file" "$content"
}

# ─── Hardcoded secrets: should BLOCK (exit 2) ───

assert_exit "blocks YAML format" 2 \
  pipe_to "$SCRIPT" "$(mk "${PW_KEY}: \\\"${PW}\\\"")"

assert_exit "blocks JSON format" 2 \
  pipe_to "$SCRIPT" "$(mk "\\\"${PW_KEY}\\\": \\\"${PW}\\\"")"

assert_exit "blocks JS assignment" 2 \
  pipe_to "$SCRIPT" "$(mk "const ${PW_KEY} = \\\"${PW}\\\"")"

assert_exit "blocks .env with quotes" 2 \
  pipe_to "$SCRIPT" "$(mk "PASSWORD=\\\"${PW}\\\"")"

assert_exit "blocks .env without quotes" 2 \
  pipe_to "$SCRIPT" "$(mk "PASSWORD=${ENV_VAL}")"

assert_exit "blocks secret assignment" 2 \
  pipe_to "$SCRIPT" "$(mk "const ${SEC_KEY} = \\\"${LONG_VAL}\\\"")"

assert_exit "blocks access_key" 2 \
  pipe_to "$SCRIPT" "$(mk "access_key: \\\"longAccessKeyValue12\\\"")"

assert_exit "blocks private_key" 2 \
  pipe_to "$SCRIPT" "$(mk "private_key = \\\"longprivatekeyvalue\\\"")"

# ─── Hardcoded secrets: should ALLOW (exit 0) ───

assert_exit "allows Validator variable name" 0 \
  pipe_to "$SCRIPT" "$(mk "const ${PW_KEY}Validator = new Validator()")"

assert_exit "allows empty value" 0 \
  pipe_to "$SCRIPT" "$(mk "${PW_KEY} = \\\"\\\"")"

assert_exit "allows short value (< 4 chars)" 0 \
  pipe_to "$SCRIPT" "$(mk "${PW_KEY} = \\\"ab\\\"")"

assert_exit "allows type annotation" 0 \
  pipe_to "$SCRIPT" "$(mk "${PW_KEY}: string")"

assert_exit "allows empty content" 0 \
  pipe_to "$SCRIPT" '{"tool_input":{"file_path":"test.ts","content":""}}'

assert_exit "allows normal code" 0 \
  pipe_to "$SCRIPT" "$(mk "const greeting = \\\"hello world\\\"")"

# ─── API token patterns: should BLOCK (exit 2) ───

assert_exit "blocks OpenAI token (sk-)" 2 \
  pipe_to "$SCRIPT" "$(mk "$OPENAI_TOKEN")"

assert_exit "blocks GitHub classic PAT (ghp_)" 2 \
  pipe_to "$SCRIPT" "$(mk "$GHP_TOKEN")"

assert_exit "blocks GitHub OAuth (gho_)" 2 \
  pipe_to "$SCRIPT" "$(mk "$GHO_TOKEN")"

assert_exit "blocks GitHub fine-grained PAT" 2 \
  pipe_to "$SCRIPT" "$(mk "$GHPAT_TOKEN")"

assert_exit "blocks AWS access key ID (AKIA)" 2 \
  pipe_to "$SCRIPT" "$(mk "$AWS_KEY_ID")"

assert_exit "blocks AWS secret key (aws_)" 2 \
  pipe_to "$SCRIPT" "$(mk "$AWS_SEC")"

assert_exit "blocks Stripe live key" 2 \
  pipe_to "$SCRIPT" "$(mk "$STRIPE_L")"

assert_exit "blocks Stripe test key" 2 \
  pipe_to "$SCRIPT" "$(mk "$STRIPE_T")"

assert_exit "blocks Slack bot token (xoxb-)" 2 \
  pipe_to "$SCRIPT" "$(mk "$SLACK_B")"

assert_exit "blocks Slack user token (xoxp-)" 2 \
  pipe_to "$SCRIPT" "$(mk "$SLACK_U")"

# ─── API tokens: should ALLOW (exit 0) ───

assert_exit "allows short sk- prefix (not a token)" 0 \
  pipe_to "$SCRIPT" "$(mk "sk-short")"

# ─── Error messages ───

assert_stderr_contains "secret error mentions file path" "config.ts" \
  pipe_to "$SCRIPT" "$(mk "${PW_KEY}: \\\"${PW}\\\"" "src/config.ts")"

assert_stderr_contains "token error mentions file path" "config.ts" \
  pipe_to "$SCRIPT" "$(mk "$OPENAI_TOKEN" "src/config.ts")"
