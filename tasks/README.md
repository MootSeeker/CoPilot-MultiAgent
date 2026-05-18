# Tasks

This folder holds all task artifacts for the multi-agent pipeline.

## Folder Structure

```
tasks/
  README.md             ← this file
  _template/            ← copy this to create a new task
  <task-id>/            ← one folder per task
    plan.md
    exploration.md
    changes.md
    validation.md
    review.md
```

## Task ID Convention

Format: **`YYYYMMDD-slug`**

- `YYYYMMDD` — creation date (UTC)
- `slug` — short hyphenated description (e.g. `add-auth`, `fix-overflow`, `refactor-parser`)

Examples: `20260514-add-jwt-auth`, `20260515-fix-memory-leak`

## Creating a New Task

**Option A** — use the `/new-task` prompt in VS Code chat:
```
/new-task Add JWT authentication to the /api/users endpoint
```
This creates the folder and seeds `plan.md` automatically.

**Option B** — copy the template manually:
```bash
cp -r tasks/_template tasks/20260514-your-slug
```
Then open `tasks/20260514-your-slug/plan.md` and fill in the goal.

## Artifact Ownership

| File | Written by | Content |
|------|-----------|---------|
| `plan.md` | Orchestrator | Goal, work packages, constraints, out-of-scope |
| `exploration.md` | Explore Agent | Affected files, dependencies, control flow, risks |
| `changes.md` | Implementer Agent | What changed, why, decisions made |
| `validation.md` | Validator Agent | Build/test/lint results, pass/fail |
| `review.md` | Reviewer Agent | Verdict (APPROVE / CHANGES REQUESTED), evidence |

## Artifact Rules

1. **Template seed, then append-only**: replace copied placeholder text when writing the first real phase output. After that, never delete existing content; add dated section headers when updating.
2. **Self-contained**: Each file must be readable without opening the source code.
3. **No secrets**: Never write tokens, passwords, or credentials into artifact files.

## Lifecycle

See [docs/task-lifecycle.md](../docs/task-lifecycle.md) for the full phase diagram, gating rules, and done criteria.
