---
description: "Use when writing tests, adding new logic, or reviewing test coverage. Covers test scope policy, naming, structure, and the rule that new logic requires accompanying tests. Referenced by the Validator agent."
applyTo: ["tests/**", "test/**", "**/*.test.*", "**/*.spec.*", "**/*_test.*"]
---

# Testing

## Core Policy

- **New logic requires a test.** Any function, method, or module added or modified must have at least one test.
- **Test only the changed area.** Do not refactor or add tests for unrelated code in the same PR/task.
- **Tests must pass before review.** The Validator agent gates on a clean test run.

## Test Scope

| Change type | Minimum test required |
|-------------|----------------------|
| New function | Unit test for happy path + at least one error/edge case |
| Modified function | Regression test proving old behaviour still holds |
| New API endpoint | Integration test covering auth, input validation, and response shape |
| New UI component | Render test + at least one interaction test |
| Protocol change | Backwards-compatibility test with the previous wire format |

## Naming

- Test files: `<module-under-test>.test.ts` / `test_<module>.py` / `<module>_test.go`
- Test functions: `should_<behaviour>_when_<condition>` or `<method>_<scenario>_<expected>`
- Describe blocks: match the module/class name

## Structure (AAA)

```
Arrange  — set up inputs, mocks, and expected values
Act      — call the code under test
Assert   — verify the output / side effects
```

Each test must be independent: no shared mutable state between tests.

## Mocking

- Mock at the boundary (I/O, network, filesystem, clock). Do not mock your own logic.
- Use dependency injection to make units testable without real external services.
- Remove `console.log` / print statements from test files before committing.

## Coverage

- Aim for ≥ 80 % line coverage on new code. Do not regress total coverage.
- Coverage is a signal, not a goal. 100 % coverage with trivial assertions is worthless.

## Running Tests

> Fill in your project's actual test command in `.github/skills/build-and-test/SKILL.md`.
> The Validator agent reads that skill to know which command to run.

## Anti-Patterns

- Testing implementation details (private methods, internal state) instead of behaviour.
- Tests that only pass by chance (time-dependent, order-dependent, network-dependent).
- Giant test helpers that obscure what is actually being tested.
- Disabling or skipping tests to make CI pass.
