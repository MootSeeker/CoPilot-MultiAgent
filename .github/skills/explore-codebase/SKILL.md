---
name: explore-codebase
description: "Explore and map a codebase to understand affected files, dependencies, and control flow before implementing a change. Use when producing an exploration.md artifact for a task, researching blast radius of a change, or doing codebase archaeology. Outputs a structured exploration.md."
argument-hint: "Path to the task plan.md, e.g. tasks/20260514-add-auth/plan.md"
---

# Explore Codebase

Systematic read-only codebase exploration that produces `exploration.md` for the Implement phase.

## When to Use

- Before any implementation — to understand what will be affected.
- When assessing the risk of a proposed change.
- When a reviewer needs a dependency map.

## Procedure

### Step 1 — Read the plan

Open `tasks/<task-id>/plan.md`. Identify:
- The goal
- Each work package
- Any constraints on scope

### Step 2 — Find entry points

Search for where the system receives input related to the planned change:

```
search: function/class names mentioned in the plan
search: route handlers, CLI commands, message consumers, ISRs related to the domain
```

### Step 3 — Trace control flow

From each entry point, follow the call chain to the likely change site:

```
read: each function body in the chain
note: file paths and line numbers at each step
stop: when you reach the leaf function that will be modified
```

Document the trace as: `entryPoint → moduleA → moduleB → changeTarget`

### Step 4 — Map dependencies

For each file that will be changed:

```
search: import/require/include statements in that file
search: which other files import/require that file (reverse dependency)
note: transitive dependencies that could be affected
```

### Step 5 — Check test coverage

```
search: test files that import or reference the affected modules
note: test file paths and what they test
note: any obvious gaps (untested public functions, edge cases)
```

### Step 6 — Identify risks

Consider:
- Shared mutable state (global variables, singletons, caches)
- Public API surfaces that external code depends on
- Concurrent access (threads, async, interrupts)
- Performance-sensitive paths
- Security boundaries (auth checks, input validation)

### Step 7 — Write exploration.md

Fill in `tasks/<task-id>/exploration.md` using the schema from `tasks/_template/exploration.md`.
All sections must be complete. Do not leave placeholder text.

## Output

A complete `tasks/<task-id>/exploration.md` with:
- Affected Files table
- Dependencies list
- Control Flow trace
- Test Coverage notes
- Risks list
- Open Questions
