---
name: write-task-artifact
description: "Create or update a task handoff artifact (plan.md, exploration.md, changes.md, validation.md, or review.md) using the correct schema and append-only discipline. Use when an agent needs to write its phase output, when bootstrapping a new task, or when adding an update section to an existing artifact."
argument-hint: "Artifact type: plan | exploration | changes | validation | review"
---

# Write Task Artifact

Correctly create or update a task handoff artifact, following the append-only rules and required section schema.

## When to Use

- Creating a new task folder from `tasks/_template/`.
- Writing the output artifact after completing a pipeline phase.
- Appending an update to an existing artifact without overwriting prior content.

## Artifact Schemas

### plan.md (written by Orchestrator)

Required sections:
- `# Plan` heading with Task ID, created date, and status
- `## Goal` — one or two sentences, specific and unambiguous
- `## Work Packages` — checklist of discrete slices (one logical concern each)
- `## Constraints` — hard limits (do not break X, Y is out of scope)
- `## Out of Scope` — explicit exclusions
- `## Open Questions` — unresolved ambiguities
- `## Next Phase` — always `Explore → write exploration.md`

### exploration.md (written by Explore Agent)

Required sections:
- `# Exploration` heading with Task ID, phase, and timestamp
- `## Affected Files` — table: file path, role, notes
- `## Dependencies` — list of direct + transitive deps of changed modules
- `## Control Flow` — trace from entry point to change site
- `## Test Coverage` — existing tests + gaps
- `## Risks` — at least one item (even "low risk — isolated module")
- `## Open Questions` — anything that blocked exploration
- `## Next Phase` — always `Implement → write changes.md`

### changes.md (written by Implementer)

Required sections:
- `# Changes` heading with Task ID, phase, timestamp, and work package
- `## Summary` — one paragraph: what changed and why
- `## Files Modified` — table: file, change type, summary
- `## Key Decisions` — deviations from plan, alternatives considered
- `## Diff Highlights` — most important code sections
- `## Formatter Run` — checkbox confirming formatter was run
- `## Open Questions / Deferred Items`
- `## Next Phase` — always `Validate → write validation.md`

### validation.md (written by Validator)

Required sections:
- `# Validation` heading with Task ID, phase, and timestamp
- `## Build` — command, result (PASS/FAIL), output excerpt
- `## Tests` — command, scope, result, output excerpt
- `## Lint / Type Check` — command, result, output excerpt
- `## Overall Verdict` — **PASS** or **FAIL**
- `## Failure Details` — if FAIL, root cause for Implementer
- `## Next Phase` — `Review → write review.md` (only if PASS)

### review.md (written by Reviewer)

Required sections:
- `# Review` heading with Task ID, phase, and timestamp
- `## Verdict` — **APPROVE** or **CHANGES REQUESTED**
- `## Requirements Traceability` — table: work package, status, evidence
- `## Regression Check` — checkbox + issues list
- `## Test Adequacy` — checkbox + gaps list
- `## Architecture` — checkboxes + notes
- `## Security` — checkboxes + notes
- `## Required Changes` — numbered action items (if CHANGES REQUESTED)
- `## Approval Notes` — optional suggestions for follow-up

## Append-Only Rule

When adding an update to an **existing** artifact, always append a new section:

```markdown
## Update — YYYY-MM-DD

<!-- New content here — do not edit any section above this line -->
```

Never edit, delete, or overwrite prior sections.

## Procedure

1. Determine which artifact to write and the task ID.
2. Copy the template from `tasks/_template/<artifact>.md` if creating fresh.
3. Fill in all required sections completely — no placeholder text in the output.
4. Append, do not overwrite, if the file already exists.
5. Confirm the `## Next Phase` line points to the correct next agent.
