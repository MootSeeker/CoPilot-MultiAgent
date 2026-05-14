---
name: implement-slice
description: "Implement exactly one logical slice of a planned change — one module, one concern, one work package. Use when acting as the Implementer agent, applying a focused code edit, or making a single-responsibility change without scope creep. Reads plan.md and exploration.md, edits source files, runs formatter, writes changes.md."
argument-hint: "Work package identifier, e.g. WP-1 from tasks/20260514-add-auth/plan.md"
---

# Implement Slice

Disciplined single-slice implementation with mandatory change documentation.

## When to Use

- Implementing one work package from `plan.md`.
- Applying a focused fix or feature addition.
- Any time a code change must be fully documented for the Validate phase.

## Procedure

### Step 1 — Read inputs

1. Open `tasks/<task-id>/plan.md` → identify the specific work package to implement.
2. Open `tasks/<task-id>/exploration.md` → read the affected files list, control flow, and risk notes.
3. Confirm you are implementing exactly one work package. If multiple are needed, complete this procedure once per package.

### Step 2 — Plan the edit

Before touching files:
- List the files you will change (must match `exploration.md` scope).
- Write a one-sentence description of the change to each file.
- Identify the test file(s) you will add to or update.

### Step 3 — Implement

Edit files in this order:
1. Core logic first (the change target identified in `exploration.md`)
2. Supporting types / interfaces (if any)
3. Tests (add or update to cover the changed logic)
4. Update inline comments / JSDoc if the function signature or behaviour changed

Rules during editing:
- Follow `.github/instructions/code-style.instructions.md`
- Follow `.github/instructions/testing.instructions.md`
- Follow `.github/instructions/security-boundaries.instructions.md`
- Do not touch files outside the scope from `exploration.md`
- Do not hardcode secrets or environment-specific values

### Step 4 — Run formatter

Run the project formatter on every modified file. Record the command in `changes.md`.

> Formatter command placeholder — replace with your project's actual command:
> - JS/TS: `npx prettier --write <files>`
> - Python: `black <files>`
> - C/C++: `clang-format -i <files>`

### Step 5 — Write changes.md

Fill in `tasks/<task-id>/changes.md` using the schema from `tasks/_template/changes.md`:
- Summary paragraph
- Files Modified table
- Key Decisions
- Diff Highlights (most important code sections)
- Confirm formatter was run
- Any deferred items

## Output

- Modified source files (scoped to the work package)
- Updated or new test files
- A complete `tasks/<task-id>/changes.md`

## Anti-Patterns

- Touching files not listed in `exploration.md` without adding them to `changes.md`
- Skipping tests because "it's a small change"
- Implementing multiple work packages in one invocation
- Leaving debug output (`console.log`, `print`, verbose temporary logging) in production paths
