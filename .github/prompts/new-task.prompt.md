---
description: "Bootstrap a new task folder from the template. Use when starting a new multi-agent task, creating the tasks/<task-id>/ structure, or seeding a plan.md from a goal description."
argument-hint: "Describe the goal in one sentence, e.g. 'Add JWT authentication to the /api/users endpoint'"
agent: agent
tools: [read, edit, search, todo]
---

Create a new task folder and seed it with a plan.

## Instructions

You will receive a goal description as input. Follow these steps exactly:

### 1. Generate a task ID

Format: `YYYYMMDD-slug`
- Use today's date (UTC) for `YYYYMMDD`.
- Derive `slug` from the goal: lowercase, hyphens instead of spaces, max 5 words.
- Example: goal "Add JWT authentication to /api/users" → `20260514-add-jwt-auth`

### 2. Create the task folder

Copy the contents of `tasks/_template/` into `tasks/<task-id>/`:
- `tasks/<task-id>/plan.md`
- `tasks/<task-id>/exploration.md`
- `tasks/<task-id>/changes.md`
- `tasks/<task-id>/validation.md`
- `tasks/<task-id>/review.md`

### 3. Fill in plan.md

Open `tasks/<task-id>/plan.md` and replace all placeholder content:

- **Task ID** line: the generated task ID
- **Created** line: today's date (YYYY-MM-DD)
- **Status**: `PLANNING`
- **Goal**: restate the input goal in one or two clear sentences
- **Work Packages**: break the goal into discrete slices (one module / one concern each). Use `[ ]` checkboxes.
- **Constraints**: ask if unclear, or write "None identified" if truly none
- **Out of Scope**: write at least one explicit exclusion
- **Open Questions**: list any ambiguities in the goal

### 4. Report to the user

Reply with:
- The task ID
- A markdown link to the plan file: `tasks/<task-id>/plan.md`
- A one-line summary of each work package
- Prompt the user: "Switch to the **Orchestrator** agent and say `run task <task-id>` to start the pipeline."

## Example

Input: "Add rate limiting to all public API endpoints"

Output:
- Task ID: `20260514-add-rate-limiting`
- Created: `tasks/20260514-add-rate-limiting/plan.md`
- Work Packages:
  - WP-1: Add rate-limit middleware to the Express router
  - WP-2: Add Redis-backed counter store
  - WP-3: Add tests for limit enforcement and reset behaviour
