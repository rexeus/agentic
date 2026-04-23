# Agentic

Multi-agent development toolkit for TypeScript and JavaScript projects.
Specialized agents, quality skills, and structured workflows for every
coding session.

## When to Use What

- **Unfamiliar codebase?** The lead deploys the scout first. Always.
- **Planning a feature?** `/agentic:plan` — challenges assumptions, presents options, produces a plan.
- **Building something?** `/agentic:develop` — full pipeline: understand, design, build, verify.
- **Code ready for review?** `/agentic:review` — focused code review on a PR, branch, or staged changes. Finds bugs, security issues, convention violations.
- **Changes ready to ship?** `/agentic:verify` — pre-ship quality gate. Runs correctness review, complexity analysis, AND tests in parallel. Broader than review.
- **Code too complex?** `/agentic:simplify` — distill working code to its essence.
- **Codebase inconsistent?** `/agentic:polish` — discover patterns, find divergence, unify. Designed for iterative runs.
- **Ready to commit?** `/agentic:commit` — Conventional Commits from staged changes.
- **Ready for a PR?** `/agentic:pr` — create or update a Pull Request with a crafted description.

## The Agents

Ten cognitive modes, one orchestrator. Each answers a different question:

| Agent                    | Question                              | Mode       |
| ------------------------ | ------------------------------------- | ---------- |
| scout                    | "What is here?"                       | Explore    |
| analyst                  | "How does this work?"                 | Understand |
| architect                | "How should it be?"                   | Design     |
| developer                | "Here's the code and the tests."      | Build      |
| reviewer-correctness     | "Does it work?"                       | Verify     |
| reviewer-security        | "Can it be broken?"                   | Verify     |
| reviewer-maintainability | "Will it age well?"                   | Verify     |
| tester-scout             | "What is not yet tested?"             | Prove      |
| tester-artisan           | "Do the tests read well?"             | Prove      |
| tester-architect         | "Is the code testable?"               | Prove      |
| refiner                  | "How can this be simpler?"            | Simplify   |
| lead                     | Orchestrates all above                | Coordinate |

After the developer finishes implementation — **including the tests
they write alongside the code** — the reviewer trio (correctness /
security / maintainability) and the tester trio (coverage / craft /
testability) run in parallel: six disjoint lenses on the same change.
All six are advisory; only the developer writes code and tests. One
FAIL anywhere fails the review.

## Principles

- Signal over noise. Only flag high-confidence findings. False positives erode trust.
- Plan before building. Present the plan, get approval, then execute.
- Adapt, don't impose. Read the project's patterns. Match them. Your code should
  look like it was always there.
