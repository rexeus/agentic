---
name: testing
description: Provides testing philosophy, patterns, and strategies. Applied when writing tests, assessing coverage, or designing test architectures.
user-invocable: false
---

# Testing Patterns

Examples use **TypeScript/JavaScript** conventions (Vitest, Jest, Mocha).
For other languages, adapt patterns to the project's test framework.

Tests aren't bureaucracy. They're a commitment to excellence — proof that
the code does what it claims. When this skill is active, apply these
principles to every test you write or assess.

## Philosophy

- **Test behavior, not implementation.** Tests verify what the code does,
  not how it does it. A refactoring that preserves behavior should never
  break a test.
- **One assertion per concept.** Each test verifies one specific behavior.
  If a test name needs "and", split it.
- **Tests are documentation.** A well-named test suite is a specification.
  `it('returns 401 when token is expired')` is both test and documentation.
- **Fast tests run often.** The faster the feedback loop, the more value
  tests provide. Prefer unit tests over integration tests over E2E tests.

## Test Structure

Follow the **Arrange-Act-Assert** pattern:

```
// Arrange: set up the preconditions
const user = createTestUser({ role: 'admin' })
const request = buildRequest({ userId: user.id })

// Act: execute the behavior under test
const result = await handleRequest(request)

// Assert: verify the outcome
expect(result.status).toBe(200)
```

Each section should be clearly separated. If Arrange is more than 5 lines,
extract a factory or fixture.

## Naming Conventions

Test names should read as specifications:

- `describe('TokenService')` — the unit under test
- `describe('validate()')` — the method or behavior
- `it('returns invalid when token is expired')` — the specific case

Pattern: `it('<expected outcome> when <condition>')`

## What to Test

### Layer 1: Unit Tests (always)

- Individual functions and methods in isolation
- Pure logic, calculations, transformations
- Error handling paths
- Boundary conditions

### Layer 2: Integration Tests (at boundaries)

- Component interactions
- Database queries (with test database)
- API endpoint request/response cycles
- Middleware chains

### Layer 3: Edge Cases (where bugs hide)

- Empty, null, undefined inputs
- Boundary values: 0, -1, MAX_INT, empty string, single character
- Concurrent operations and race conditions
- Large inputs, deeply nested structures
- Invalid types and malformed data
- Unicode, special characters, emoji

## Test Doubles

Use the right double for the job:

- **Stub**: Returns predetermined data. Use when you need controlled input.
- **Mock**: Verifies interactions. Use sparingly — only when the interaction IS the behavior.
- **Fake**: Working implementation with shortcuts. Use for external services.
- **Spy**: Records calls without changing behavior. Use to observe side effects.

**Rule:** Prefer stubs over mocks. Mocking implementation details creates brittle tests.

## Anti-Patterns to Avoid

- **Test interdependence**: Tests that must run in a specific order.
  Fix: Each test sets up and tears down its own state.
- **Testing implementation**: Asserting on internal method calls or private state.
  Fix: Test the public interface and observable outcomes only.
- **Flaky tests**: Tests that sometimes pass and sometimes fail.
  Fix: Eliminate time-dependence, randomness, and shared state.
- **Giant test files**: Hundreds of tests in a single file.
  Fix: Group by behavior. One describe block per method or feature.
- **Commented-out tests**: Tests disabled instead of fixed or removed.
  Fix: Fix or delete. Commented tests rot and mislead.

## Adapting to the Project

Before writing tests:

1. Identify the test framework in use (Jest, Vitest, Mocha, pytest, etc.)
2. Find existing test utilities, factories, and fixtures
3. Match the naming convention and file structure
4. Check for CI/CD test configuration and coverage thresholds
