---
description: Create or update a Pull Request with a well-crafted title and description.
allowed-tools: Bash(git *), Bash(gh *), Read, Grep, Glob
argument-hint: "[--base <branch>] [--draft] [--update]"
---

# Pull Request

Create a new Pull Request or update an existing one. Analyzes all commits and
the full diff to generate a Conventional Commits title and a structured
description that tells reviewers exactly what changed and why.

**Usage:**

- `/agentic:pr` — create or update a PR for the current branch
- `/agentic:pr --base develop` — target a specific base branch
- `/agentic:pr --draft` — create as Draft PR (work in progress, not yet review-ready)
- `/agentic:pr --update` — force-update an existing PR's title and description

## Rules

- **Follow Conventional Commits** for the PR title — consistent with `/agentic:commit`.
- **Never merge.** This command creates or updates PRs. It never merges them.
- **Never force-push.** If the branch needs pushing, use a normal push.
- **Respect existing reviews.** When updating a PR that has reviews or comments,
  warn the user before overwriting the description.

## Workflow

### Step 1: Detect State

Run these in parallel:

```bash
git branch --show-current
```

```bash
git rev-parse --abbrev-ref --symbolic-full-name @{upstream} 2>/dev/null
```

```bash
gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'
```

```bash
gh pr view --json number,title,body,url,state,reviews,isDraft 2>/dev/null
```

Determine:

- **Current branch** — if on the default branch, stop: "You're on the default
  branch. Create a feature branch first."
- **Remote tracking** — is the branch pushed?
- **Existing PR** — does a PR already exist for this branch?
- **Default branch** — what is the repo's default branch?

### Step 2: Determine Base Branch

Use this priority:

1. If `$ARGUMENTS` contains `--base <branch>` — use that branch.
2. If an existing PR exists — use that PR's base branch.
3. Otherwise — use the repo's default branch.

Present the base branch to the user:

> "PR gegen `main` — passt das?"

Only wait for confirmation if the base branch seems unusual (e.g., not `main`
or `develop`). For the default branch, proceed unless the user intervenes.

### Step 3: Push if Needed

If the branch has no upstream tracking:

> "Branch `feature/token-refresh` has no upstream. Pushing to origin now."

Then push:

```bash
git push -u origin <current-branch>
```

If the branch is behind the remote (diverged), stop and inform the user.
Do not force-push.

### Step 4: Analyze Changes

Run in parallel:

```bash
git log <base>..HEAD --oneline
```

```bash
git log <base>..HEAD --format="%s%n%n%b" --no-merges
```

```bash
git diff <base>...HEAD --stat
```

```bash
git diff <base>...HEAD
```

Read the full diff carefully. Understand:

- **What changed** — files created, modified, deleted
- **Why it changed** — derive intent from commit messages and code context
- **Scope** — is this a single feature, a bugfix, a refactor, or multiple things?
- **Breaking changes** — any API changes, removed exports, schema migrations?
- **Related issues** — any `#123` references in commits or code comments?

For large diffs (50+ files), focus on the commit messages and diff stat first,
then read the most significant file changes.

### Step 5: Generate Title and Description

**Title** — Conventional Commits format, max 100 characters:

```
<type>[optional scope][optional !]: <description>
```

- Derive the type from the changes (feat, fix, refactor, docs, chore, etc.)
- Scope is optional — use it when the changes are focused on one module
- Imperative mood, lowercase, no period

**Description** — structured, scannable, reviewer-friendly:

```markdown
## Summary

<1-3 sentences: what this PR does and why. Not how — the diff shows how.>

## Changes

- <grouped by concern, each bullet is a concrete change>
- <reference specific files when helpful>
- <note any non-obvious design decisions>

## Breaking Changes

<only include this section if there are breaking changes>
- <what breaks and how to migrate>

## Test Plan

- <how to verify this works>
- <what tests were added or should be run>
- <edge cases covered>
```

**Rules for the description:**

- Write for the reviewer, not for yourself. They haven't seen this code before.
- Lead with the WHY, not the WHAT. The diff shows what changed.
- Be specific. "Updated auth logic" is useless. "Added token expiry check
  to prevent stale sessions from bypassing rate limits" is useful.
- If commits reference issues, add them naturally in the Summary
  (e.g., "Fixes #234").
- Don't pad with filler. If the change is small, the description should be small.

### Step 6: Present and Confirm

**For a new PR:**

Show:

1. The full title
2. The full description
3. Whether it will be created as a draft
4. The base branch

Wait for approval. The user may edit the title, description, or both.

**For an existing PR update:**

Show:

1. Current title → proposed title
2. Current description → proposed description (or a summary of what changed)
3. Whether the PR has existing reviews (warn if so)

Wait for approval.

### Step 7: Execute

**Create new PR:**

```bash
gh pr create --title "<title>" --body "$(cat <<'EOF'
<description>
EOF
)" [--draft]
```

**Update existing PR:**

```bash
gh pr edit <number> --title "<title>" --body "$(cat <<'EOF'
<description>
EOF
)"
```

Report the result with the PR URL.

### Step 8: Follow-up

After creating or updating, suggest next steps if relevant:

- "PR created: <url>"
- If draft: "Draft PR created. When ready for review: `gh pr ready`"
- If the reviewer/tester pipeline hasn't run: suggest `/agentic:review`
