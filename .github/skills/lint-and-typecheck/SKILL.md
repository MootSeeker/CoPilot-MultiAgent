---
name: lint-and-typecheck
description: "Run the linter and type checker on changed source files. Use when verifying code style and type correctness after a change, as part of the Validator agent's validation phase. Results are recorded in validation.md. Customize the command placeholders for your project."
argument-hint: "Optional: space-separated list of files to lint"
---

# Lint and Type Check

Run linters and type checkers scoped to the changed files, capture results, and write them to `validation.md`.

## When to Use

- After every implementation, alongside the `build-and-test` skill.
- When a reviewer requests a fresh lint run.
- As part of the Validator agent's validation phase.

## Customize for Your Project

> **Required setup**: Replace the placeholder commands below with your project's actual linter/type-checker.
> Edit this SKILL.md file directly once you have bootstrapped the scaffold into your project.

## Procedure

### Step 1 — Run linter

Scope to modified files where possible:

```bash
# JS/TS — ESLint
npx eslint <file1> <file2> ...
# Or full project:
npm run lint

# Python — Ruff (fast, recommended) or Flake8
ruff check <file1> <file2>
# Or full project:
ruff check .

# C/C++ — clang-tidy
clang-tidy <file1> -- -I include/

# Rust — Clippy
cargo clippy -- -D warnings
```

Record: command, number of warnings/errors, exit code.

### Step 2 — Run type checker

```bash
# TypeScript
npx tsc --noEmit

# Python — mypy or pyright
mypy <file1> <file2>
pyright <file1> <file2>

# Go (built-in)
go vet ./...

# Rust (type errors surface during build — no separate step needed)
```

Record: command, error count, exit code.

### Step 3 — Auto-fix (optional)

If the linter supports safe auto-fixes and the team allows them:

```bash
# ESLint
npx eslint --fix <files>

# Ruff
ruff check --fix <files>
```

If auto-fixes were applied, re-run the linter to confirm zero issues remain.

### Step 4 — Record in validation.md

Append to the Lint/Type Check section of `tasks/<task-id>/validation.md`:
- Command used
- Output excerpt (errors only, or "no issues found")
- Result: PASS (zero errors) or FAIL (with error count)

## Output

Updated `validation.md` Lint/Type Check section with documented results.

## Notes

- Warnings are acceptable; **errors are not**. PASS requires zero linter errors.
- If the linter reports issues in files you did not change, note this in `validation.md` but do not mark it as FAIL unless it is a pre-existing agreed-upon rule.
