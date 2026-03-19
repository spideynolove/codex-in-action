---
name: quality-tests
description: Use when writing tests for any function, component, or module - enforces behavior contracts over coverage padding, boundaries over happy paths, and prevents testing what the type system already guarantees.
---

# Writing Quality Tests

## Core Philosophy

Tests are **behavior contracts**, not coverage padding. Goal is real runtime confidence, not 100% line coverage. Let the type system handle static guarantees.

## Golden Rules

**1. Don't test what types already guarantee**

Never test: required fields being present, types of returned values, non-null assertions, basic property existence.

**2. Test behavior, not implementation**

Only use the public interface to set up and verify. Never reference private methods, internal variables, or current code shape.

**3. Focus on boundaries and unhappy paths first**

Priority order:
1. Invalid/malformed inputs → error cases
2. Edge values (empty, max/min, nullish where allowed)
3. Permission/state transitions that should fail
4. Happy-path only when behavior has non-obvious domain logic

**4. Quantity guardrail: 1-4 tests per behavior**

Work in vertical slices: one failing test → minimal implementation → refactor → next test.

## Test Quality Check

**Good output:**
- 2-6 focused test blocks
- Assertions about outcomes, errors, side effects
- Realistic edge cases first
- No `toBeDefined()`, `toBeString()`, `expect(x).not.toBeNull()` noise

**Bad output (rewrite):**
- 30-50 tests
- Every property individually asserted
- Happy path repeated with minor variations
- Tests peeking into private state

## Prompt Template (Copy-Ready)

```
You are an expert TDD practitioner using red-green-refactor.

Rules:
- Don't test what the type system already guarantees
- Test behavior, not implementation
- Only use public interface methods to verify
- Focus first on boundaries, invalid inputs, error paths
- Write only 1-3 high-signal tests per behavior
- Never test simple getters/setters/passthroughs

Task: Write the initial failing test suite for [describe here].
All tests must fail right now (no implementation exists).
Start with the most important boundary/error case first.
```

## TDD Workflow

1. Describe feature/function signature clearly
2. Write **failing tests** only (using rules above)
3. Review → adjust naming, add missing edges, remove noise
4. Implement minimal code to make tests pass
5. Refactor
6. Repeat for next slice

## Anti-Patterns

| Pattern | Why Bad |
|---------|---------|
| `expect(result).toBeDefined()` | Type system guarantees this |
| Testing return type is string | Same - types cover this |
| 50 assertions for one function | Noise, not signal |
| `user.privateField` in test | Breaks encapsulation |
| Trivial happy path with no logic | Adds no confidence |
