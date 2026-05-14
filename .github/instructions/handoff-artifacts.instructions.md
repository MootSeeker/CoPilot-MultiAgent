---
description: "Use when reading or writing task handoff artifacts in tasks/**/*.md. Covers append-only rules, required section headings, ownership discipline, and artifact formatting for plan, exploration, changes, validation, and review files."
applyTo: "tasks/**/*.md"
---

# Handoff Artifact Rules

These rules apply to all Markdown files under `tasks/`. They are enforced by all agents in the pipeline.

## Append-Only Discipline

- **Never delete** existing content from an artifact file.
- **Never overwrite** a prior section. If you need to update information, add a new dated section:
  ```markdown
  ## Update — 2026-05-14
  ...
  ```
- Each agent appends its own section; it does not edit content written by earlier agents.

## Ownership

| File | Primary owner | May append |
|------|--------------|-----------|
| `plan.md` | Orchestrator | Reviewer (deferred items) |
| `exploration.md` | Explore Agent | Implementer (discovery during impl.) |
| `changes.md` | Implementer Agent | Validator (notes on build scope) |
| `validation.md` | Validator Agent | — |
| `review.md` | Reviewer Agent | — |

Only the primary owner writes the main body. Other agents may append a `## Notes from <Phase>` section at the bottom.

## Required Section Headings

Every artifact must contain at minimum:

- A **Task ID** line (copy from `plan.md`)
- A **Phase** line
- A **Next Phase** line (or `DONE` for review.md)

## Self-Containment

Each artifact must be fully understandable without opening the source code. Include:
- File paths (relative to repo root)
- Line references where relevant
- Command strings with actual output excerpts (not just "it worked")

## No Secrets

Never write API keys, tokens, passwords, connection strings, or credentials into any artifact file. Reference environment variable names instead (e.g. `$GITHUB_TOKEN`).

## Gating

- The Implementer must not start until `exploration.md` is present and non-empty.
- The Validator must not start until `changes.md` is present and non-empty.
- The Reviewer must not start until `validation.md` shows an overall **PASS** verdict.
