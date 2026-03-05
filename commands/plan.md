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

This is the most critical step. A brilliant plan for the wrong problem is
worthless. Your job is to be a **critical thinking partner** — not a
yes-machine that immediately starts planning.

#### 1a: Clarify

Ask questions until the problem is crystal clear:

- **What exactly should change?** Get specific. "Improve performance" is not
  a requirement — "Reduce API response time from 2s to 200ms" is.
- **What's the success criteria?** How will we know it's done? What does
  "done" look like?
- **Who is this for?** End users? Other developers? An internal system?
- **What's the context?** Why now? What triggered this? Is there urgency?
- **What are the constraints?** Budget, time, tech stack, backwards compatibility?

#### 1b: Challenge

Play devil's advocate. Respectfully but firmly question the idea:

- **Is this the right problem?** Or is it a symptom of a deeper issue?
- **Do we actually need this?** What's the cost of NOT doing it?
- **What could go wrong?** What are the risks, failure modes, unintended consequences?
- **Is there a simpler way?** Could we achieve 80% of the value with 20% of the effort?
- **What are we giving up?** Every feature has opportunity cost. What won't we build?
- **Have we seen this pattern before?** Does the codebase already solve a similar
  problem we can learn from?

#### 1c: Confirm Understanding

Restate the problem in your own words. Include:

- The core problem being solved
- The key constraints
- What success looks like
- Anything explicitly out of scope

**Do NOT proceed until the user confirms your understanding.** If they
correct you, update and confirm again. This loop can take multiple rounds.

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

Present the plan for final approval.

### Step 6: Transition to Development

Once the plan is approved, ask the user directly:

> "Der Plan steht. Gibt es noch Rückfragen oder sollen wir direkt loslegen?"

- If the user has questions — answer them, iterate on the plan.
- If the user says go — **transition seamlessly into the develop pipeline.**
  Do NOT wait for them to manually invoke `/agentic:develop`. You have the
  plan, the context, and the scout findings. Proceed directly:
  1. Create a progress tracking task list based on the implementation steps
  2. Start with Step 4 of the develop workflow (Implement), since planning
     and reconnaissance are already done
  3. Continue through verification, iteration, and summary as normal
