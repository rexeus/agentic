---
name: conventions
description: Code conventions and style convictions. Applied when writing, reviewing, or analyzing code. These are non-negotiable standards, not preferences.
user-invocable: false
---

# Code Conventions

These conventions target **TypeScript and JavaScript** projects. For other
languages, adapt the principles to idiomatic equivalents.

These are convictions, not suggestions. Apply them to all code you write or review.

## Certainty Over Ambiguity

- Use `??` over `||`. Nullish is not falsy. Mean what you say.
- Use strict equality (`===`). Loose comparisons hide bugs.
- Discriminated unions over optional fields when states are mutually exclusive.

## Immutability Is Clarity

- `const` by default. `let` only when mutation is required and justified.
- Mark properties `readonly` unless mutation is the explicit intent.
- Mutable state is opt-in, never opt-out.

## Types, Not Interfaces

- Use `type` for composition, algebraic types, and everything internal.
- Use `interface` only for contracts with external consumers.
- If in doubt, use `type`.

## Say It With Access Modifiers

- `public`, `private`, `protected` on every method and constructor parameter.
- No ambiguity. No guessing. Declare intent explicitly.

## Naming Is Design

- Variables and functions: camelCase. Descriptive. `getUserById` not `getUser`.
- Types and classes: PascalCase. Nouns for data, adjectives for capabilities.
- Constants: SCREAMING_SNAKE_CASE only for true compile-time constants.
- Booleans: prefix with `is`, `has`, `can`, `should`. Never ambiguous.
- Files: match the primary export. `UserService.ts` exports `UserService`.
- If you can't name it clearly, you don't understand it yet.

## Small Functions, Clear Purpose

- Every function does one thing. If you need "and" to describe it, split it.
- Aim for 20 lines or fewer. If significantly longer, consider extracting.
- Aim for 300 lines or fewer per file. If significantly longer, consider decomposing.
- Maximum nesting: 3 levels. Early returns over deep nesting.

## Errors Are First-Class Citizens

- Never swallow errors. Every `catch` must log, rethrow, or transform.
- Typed errors with meaningful messages. `new AuthError("Token expired")` not `new Error("error")`.
- Handle errors at the appropriate boundary. Don't catch what you can't handle.
- Prefer `Result<T, E>` patterns where the language supports it.
- The unhappy path deserves as much care as the happy path.

## Imports & Dependencies

- Named exports only. Default exports create ambiguity.
- Import order: stdlib, external packages, internal packages, relative imports.
- Every dependency is a decision. Lightweight, well-maintained, truly needed — or don't add it.

## Comments Are a Last Resort

- If the code needs a comment to be understood, the code isn't done yet.
- Comments explain _why_, never _what_. Only when the reasoning is non-obvious.
- TODO comments include an owner or issue link. Orphan TODOs are technical debt.
- JSDoc only for public API surfaces.

## Adapting to the Project

These conventions are the baseline. The project's voice takes precedence:

1. Check for CLAUDE.md files in the repository
2. Examine recent commits for naming and style patterns
3. Look at existing tests for testing conventions
4. If the project has its own standards, those override these defaults

Your code should look like it was always there.
