---
description: "Transition the pipeline from the current phase to the next. Use when a phase artifact has been written and you want to verify completeness and invoke the next agent. Checks the current artifact for required sections before handing off."
argument-hint: "Current phase: plan | explore | implement | validate | review"
agent: agent
tools: [read, agent]
---

Verify the current phase artifact is complete and transition to the next phase.

## Instructions

You will receive the **current phase name** and the **task ID** as input.

### Step 1 — Locate the artifact

| Current phase | Artifact to check | Next agent |
|--------------|------------------|-----------|
| `plan` | `tasks/<id>/plan.md` | Explore |
| `explore` | `tasks/<id>/exploration.md` | Implementer |
| `implement` | `tasks/<id>/changes.md` | Validator |
| `validate` | `tasks/<id>/validation.md` | Reviewer |
| `review` | `tasks/<id>/review.md` | (done) |

### Step 2 — Verify completeness

Open the current artifact. Check:
- [ ] No template placeholder text remains (no `<!-- ... -->` comments with "fill in" instructions)
- [ ] All required section headings are present (see `write-task-artifact` skill for the schema)
- [ ] `## Next Phase` line is present and points to the correct next phase
- [ ] For `validation.md`: Overall Verdict is **PASS** (not FAIL) before proceeding to review

If any check fails:
- Report the missing sections to the user.
- Do not invoke the next agent.
- Ask the user to fix the artifact or re-run the current agent.

### Step 3 — Invoke the next agent

If all checks pass, invoke the appropriate next agent as a subagent:

**Explore phase**:
> "The plan is ready. Explore the codebase for task `<id>`. Read `tasks/<id>/plan.md` and write `tasks/<id>/exploration.md`."

**Implement phase**:
> "Exploration is complete. Implement WP-1 from `tasks/<id>/plan.md` using `tasks/<id>/exploration.md`. Write `tasks/<id>/changes.md`."

**Validate phase**:
> "Implementation is complete. Validate the changes in `tasks/<id>/changes.md`. Run build, tests, and lint. Write `tasks/<id>/validation.md`."

**Review phase**:
> "Validation passed. Review the full task `<id>`. Read all artifacts in `tasks/<id>/`. Write `tasks/<id>/review.md`."

### Step 4 — Report

After invoking the next agent:
- State which agent was invoked.
- Link to the artifact it will produce.
- Remind the user they can `/handoff` again once that artifact is written.
