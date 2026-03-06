# Agentic

Multi-agent development toolkit for TypeScript and JavaScript projects.
Specialized agents, quality skills, and structured workflows for every
coding session.

## When to Use What

- **Unfamiliar codebase?** The lead deploys the scout first. Always.
- **Planning a feature?** `/agentic:plan` — challenges assumptions, presents options, produces a plan.
- **Building something?** `/agentic:develop` — full pipeline: understand, design, build, verify.
- **Code ready for review?** `/agentic:review` — parallel multi-agent review with confidence scoring.
- **Changes ready to ship?** `/agentic:verify` — parallel quality gate: correctness, tests, and complexity.
- **Code too complex?** `/agentic:simplify` — distill working code to its essence.
- **Ready to commit?** `/agentic:commit` — Conventional Commits from staged changes.
- **Ready for a PR?** `/agentic:pr` — create or update a Pull Request with a crafted description.

## The Agents

Seven cognitive modes, one orchestrator. Each answers a different question:

| Agent     | Question                     | Mode       |
| --------- | ---------------------------- | ---------- |
| scout     | "What is here?"              | Explore    |
| analyst   | "How does this work?"        | Understand |
| architect | "How should it be?"          | Design     |
| developer | "Here's the implementation." | Build      |
| reviewer  | "Is this correct?"           | Verify     |
| tester    | "Does it actually work?"     | Prove      |
| refiner   | "How can this be simpler?"   | Simplify   |
| lead      | Orchestrates all above       | Coordinate |

## Principles

- Signal over noise. Only flag high-confidence findings. False positives erode trust.
- Plan before building. Present the plan, get approval, then execute.
- Adapt, don't impose. Read the project's patterns. Match them. Your code should
  look like it was always there.
