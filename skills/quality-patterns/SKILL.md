---
name: quality-patterns
description: Identifies code quality anti-patterns and provides best practices. Applied when analyzing code smells, architecture decisions, complexity, or technical debt.
user-invokable: false
---

# Quality Patterns & Anti-Patterns

Code quality isn't subjective. These patterns are proven signals — each backed
by decades of engineering wisdom. When this skill is active, evaluate code
against these patterns. Flag violations with evidence and specific remediation.

## Anti-Patterns to Flag

### Complexity

- **God objects**: Classes with many unrelated public methods or excessive dependencies
  (typically 8+ public methods across multiple concerns, or 10+ dependencies).
  Fix: Extract focused collaborators.
- **Feature envy**: A function that accesses another object's data more than its own.
  Fix: Move the behavior to where the data lives.
- **Primitive obsession**: Using strings or numbers where a domain type would add clarity.
  Fix: Introduce a value object (`EmailAddress`, `Money`, `UserId`).
- **Deep nesting**: More than 3 levels of indentation.
  Fix: Extract to functions, use early returns, invert conditions.

### Coupling

- **Temporal coupling**: Functions that must be called in a specific order.
  Fix: Make the dependency explicit through function composition or a builder pattern.
- **Stamp coupling**: Passing a large object when only one field is needed.
  Fix: Pass only what's needed. Narrow the interface.
- **Leaky abstractions**: Implementation details surfacing through a public API.
  Fix: Introduce an interface boundary.

### Duplication

- **Shotgun surgery**: A single change requires edits in many places.
  Fix: Centralize the varying behavior behind an abstraction.
- **Copy-paste code**: Identical or near-identical blocks in multiple locations.
  Fix: Extract a shared function. If the duplication is structural, extract a pattern.
- **Long parameter lists**: Functions taking 4+ parameters that travel together.
  Fix: Introduce a parameter object or config type.
- **Data clumps**: Groups of values that always appear together across multiple functions.
  Fix: Extract a cohesive type that represents the concept.

### Error Handling

- **Silent failures**: Catching errors without logging or rethrowing.
  Fix: At minimum, log. Better: rethrow or return a Result type.
- **Overly broad catches**: `catch (e: any)` or `catch (Exception e)`.
  Fix: Catch the narrowest type possible.
- **Error codes as control flow**: Using return values instead of exceptions (or vice versa) inconsistently.
  Fix: Pick one pattern and use it consistently within a boundary.

## Positive Patterns to Encourage

- **Single Responsibility**: Each module has one reason to change.
- **Dependency Inversion**: Depend on abstractions, not concretions.
- **Fail Fast**: Validate inputs at the boundary, trust internals.
- **Composition over Inheritance**: Combine behaviors through composition.
- **Immutability by Default**: Mutable state is opt-in, not opt-out.
- **Explicit over Implicit**: Make side effects, dependencies, and state transitions visible.

## Severity Classification

When reporting issues, classify by impact:

- **Critical**: Will cause bugs, data loss, or security vulnerabilities. Must fix.
- **Warning**: Increases maintenance cost or risk. Should fix.
- **Suggestion**: Improves clarity or follows best practices. Consider fixing.

Only flag issues you are confident about. False positives erode trust.
