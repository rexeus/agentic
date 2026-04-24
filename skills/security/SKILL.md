---
name: security
description: Identifies security vulnerabilities and provides secure coding patterns. Applied when reviewing code for injection, authentication, authorization, and data exposure risks.
user-invocable: false
---

# Security Patterns

Security isn't a feature. It's a property of well-crafted code. Every
vulnerability caught in review is an incident prevented in production.
When this skill is active, evaluate code against these patterns and flag
vulnerabilities
with specific, actionable remediation steps.

## Injection

- **SQL Injection**: User input concatenated into SQL queries.
  Fix: Use parameterized queries or prepared statements. Never interpolate.
- **Command Injection**: User input passed to shell commands or process spawning.
  Fix: Use library APIs instead of shell commands. If unavoidable, use allowlists
  and argument arrays instead of string interpolation.
- **XSS (Cross-Site Scripting)**: User input rendered as HTML without escaping.
  Fix: Use framework-provided escaping. Never set innerHTML with user data.
- **Template Injection**: User input evaluated in template engines.
  Fix: Use sandboxed templates. Never pass user input to dynamic code evaluation.

## Authentication & Authorization

- **Hardcoded credentials**: API keys, passwords, or tokens in source code.
  Fix: Use environment variables or a secrets manager. Never commit secrets.
- **Weak token generation**: Predictable session tokens or API keys.
  Fix: Use cryptographically secure random generators (crypto.randomUUID).
- **Missing authorization checks**: Endpoints that verify authentication but not permissions.
  Fix: Check authorization at every endpoint. Don't rely on client-side checks.
- **Insecure password handling**: Plaintext storage or weak hashing (MD5, SHA1).
  Fix: Use bcrypt, scrypt, or argon2 with appropriate cost factors.

## Data Exposure

- **Sensitive data in logs**: Passwords, tokens, or PII written to log output.
  Fix: Sanitize log entries. Use structured logging with field-level filtering.
- **Verbose error messages**: Stack traces or internal paths exposed to users.
  Fix: Return generic error messages to clients. Log details server-side only.
- **Missing encryption**: Sensitive data stored or transmitted in plaintext.
  Fix: Use TLS for transit. Encrypt at rest with AES-256 or equivalent.

## Server-Side Risks

- **SSRF (Server-Side Request Forgery)**: User-controlled URLs passed to server-side HTTP requests.
  Fix: Validate and allowlist target URLs. Block internal/private IP ranges.
- **Insecure deserialization**: Untrusted data deserialized without validation.
  Fix: Validate structure before deserialization. Use schema validation (Zod, JSON Schema).

## Input Validation

- **Missing boundary validation**: No checks on input size, range, or format.
  Fix: Validate at the system boundary. Reject before processing.
- **Type coercion vulnerabilities**: Loose comparisons that bypass checks.
  Fix: Use strict equality. Validate types explicitly.
- **Path traversal**: User input used to construct file paths.
  Fix: Use path.resolve and validate the result stays within allowed directories.

## Dependency Security

- **Known vulnerable dependencies**: Packages with published CVEs.
  Fix: Run npm audit or equivalent. Update or replace vulnerable packages.
- **Typosquatting risk**: Dependencies with names similar to popular packages.
  Fix: Verify package names, publishers, and download counts before installing.

## Adapting to the Project

Before flagging security issues:

1. Check if the project has security-specific CLAUDE.md rules
2. Understand the trust boundary — internal tools have different risk profiles
3. Don't flag issues in test code unless they affect production security
4. Consider the deployment context (serverless, container, bare metal)
