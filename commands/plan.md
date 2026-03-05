---
description: Plan a new feature or task. Critically evaluates requirements, presents options, and produces an implementation plan.
allowed-tools: Read, Grep, Glob, Bash(git log *), Bash(git diff *), Agent
argument-hint: "<feature or task description>"
---

# Plan

Plan a new feature or task. This command challenges assumptions, explores
options, and produces a concrete plan — before any code is written.

**Usage:**

- `/agentic:plan Add user authentication with OAuth`
- `/agentic:plan Refactor the payment module for multi-currency support`

## Philosophy

The most expensive bugs are wrong assumptions made before the first line of code.
This command exists to catch them. Your job is to be the critical thinker who
asks the hard questions BEFORE the team starts building.

## Workflow

### Step 1: Understand the Request

Read `$ARGUMENTS` carefully. If no arguments were provided, ask the user
what they want to build.

Before doing anything else, **challenge the request**:

- Is the problem clearly defined? If not, ask clarifying questions.
- Are there hidden assumptions? Surface them explicitly.
- Is the scope reasonable? If it's too broad, suggest breaking it down.
- Does it conflict with existing functionality? Check the codebase.

Do NOT proceed until the problem is well-defined. Ask questions.
Present your understanding back to the user for confirmation.

### Step 2: Reconnaissance

Deploy the **scout** to map relevant areas of the codebase:

- What exists today that relates to this feature?
- What patterns does the codebase use?
- What constraints exist (framework, language, architecture)?

If the scout reveals complexity, deploy the **analyst** to trace
the relevant code paths in depth.

### Step 3: Present Options

Deploy the **architect** to design 2-3 approaches. For each option, present:

```
## Option A: <name>

**Approach:** What this option does and how it works.

**Pros:**
- ...

**Cons:**
- ...

**Effort:** Low / Medium / High

**Risk:** Low / Medium / High

**Fits existing patterns:** Yes / No — explanation.
```

**Always present at least 2 options.** If there seems to be only one way,
think harder — there's always a trade-off worth exploring.

Include a recommendation, but make it clear this is YOUR recommendation
and the user decides.

### Step 4: User Decision

Wait for the user to choose an option or provide feedback.
Do NOT proceed to implementation planning without explicit user choice.

If the user has questions or wants to modify an option, iterate.
This step can take multiple rounds — that's the point.

### Step 5: Implementation Plan

Once the user approves an approach, produce a concrete plan:

```
## Implementation Plan: <feature>

### Overview
<1-2 sentences describing the chosen approach>

### Files to Create
- `path/file.ts` — purpose

### Files to Modify
- `path/file.ts` — what changes and why

### Implementation Steps
1. <step> — <why this order>
2. <step>
3. <step>

### Edge Cases
- <case> — how to handle

### Testing Strategy
- Unit tests for: ...
- Integration tests for: ...

### Open Questions
- <anything still unresolved>
```

Present the plan for final approval. Once approved, the user can
start implementation with `/agentic:develop`.
