---
name: git-conventions
description: Provides git workflow conventions including Conventional Commits, branch naming, and PR descriptions. Applied when committing, branching, or creating pull requests.
user-invokable: false
---

# Git Conventions

Commits tell a story. Reading `git log --oneline` should explain the
evolution of a project — every change purposeful, every message clear.
When this skill is active, apply these conventions to all git operations.

## Conventional Commits

Follow the Conventional Commits 1.0.0 specification (conventionalcommits.org):

```
<type>[optional scope][optional !]: <description>

[optional body]

[optional footer(s)]
```

### Types

| Type       | When to use                     | Semver impact |
| ---------- | ------------------------------- | ------------- |
| `feat`     | New feature for the user        | MINOR         |
| `fix`      | Bug fix                         | PATCH         |
| `docs`     | Documentation only              | —             |
| `style`    | Formatting, no logic change     | —             |
| `refactor` | Code change, no feature or fix  | —             |
| `perf`     | Performance improvement         | PATCH         |
| `test`     | Adding or correcting tests      | —             |
| `build`    | Build system or dependencies    | —             |
| `ci`       | CI/CD configuration             | —             |
| `chore`    | Maintenance, no production code | —             |
| `revert`   | Reverts a previous commit       | —             |

### Rules

- **Description**: imperative mood, lowercase, no period. Max 100 characters.
  Good: `feat(auth): add token refresh endpoint`
  Bad: `feat(auth): Added Token Refresh Endpoint.`
- **Scope**: optional. Use the module or component name.
  `feat(auth)`, `fix(api)`, `refactor(db)`
- **Body**: explain WHAT changed and WHY. The diff shows HOW.
  Wrap at 72 characters. Separate from description with a blank line.
  Multiple paragraphs are allowed — separate them with blank lines.
- **Breaking changes**: add `!` after type/scope OR `BREAKING CHANGE:` in footer.
  `BREAKING-CHANGE` (hyphen) is a valid synonym.
  `feat(api)!: change authentication to OAuth2`

### Choosing the Right Type

- Changed behavior for the user? → `feat` or `fix`
- Changed internals without affecting behavior? → `refactor`
- Only moved or renamed things? → `refactor`
- Only changed comments or docs? → `docs`
- Only changed tests? → `test`
- Undoing a previous commit? → `revert`
- Multiple types in one commit? → The commit is too large. Split it.

### Footers

Footers follow `git-trailer` format: `Token: value` or `Token #value`.
They appear after the body, separated by a blank line. One footer per line.
Multi-word tokens use `-` (exception: `BREAKING CHANGE` with space).

| Footer            | Purpose           | Example                                 |
| ----------------- | ----------------- | --------------------------------------- |
| `BREAKING CHANGE` | Describe breakage | `BREAKING CHANGE: removed v1 endpoints` |
| `Fixes`           | Close an issue    | `Fixes #42`                             |
| `Refs`            | Reference issues  | `Refs #123, #456`                       |
| `Co-authored-by`  | Credit co-author  | `Co-authored-by: Name <email>`          |
| `Reviewed-by`     | Credit reviewer   | `Reviewed-by: Name <email>`             |

### Examples

Minimal — title only:

```
fix(auth): prevent token expiry race condition
```

With body and issue reference:

```
feat(api): add batch processing endpoint

Process up to 100 items in a single request. Uses chunked
transfer encoding for large payloads.

Fixes #234
```

Breaking change with footer:

```
refactor(db)!: migrate from MySQL to PostgreSQL

Replace all MySQL-specific queries with PostgreSQL equivalents.
Connection pooling now uses pgBouncer.

BREAKING CHANGE: database connection string format changed,
requires migration script before deployment
Refs #89
```

## Branch Naming

Pattern: `<type>/<short-description>`

```
feat/token-refresh
fix/null-reference-login
refactor/extract-auth-service
```

- Use lowercase and hyphens
- Keep it short but descriptive
- Match the type to Conventional Commits types

## Commit Discipline

- **One logical change per commit.** If you need "and" to describe it, split it.
- **Never commit generated files** (dist/, build/, node_modules/).
- **Never commit secrets** (.env, credentials, API keys).
- **Never commit debug code** (console.log, debugger, TODO: remove).
- **Commit messages tell a story.** Reading `git log --oneline` should
  explain the evolution of the project.

## Adapting to the Project

Before applying these conventions:

1. Read the last 20 commit messages: `git log --oneline -20`
2. Check for a CONTRIBUTING.md or commit message guidelines
3. If the project uses a different convention, follow theirs
4. Match the language of existing commits (English, German, etc.)
