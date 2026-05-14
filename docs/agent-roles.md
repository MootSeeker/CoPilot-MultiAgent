# Agent Roles Reference

Quick reference card for every agent in the system. For full definitions see the agent files in `.github/agents/`.

---

## Orchestrator

**File**: [`.github/agents/orchestrator.agent.md`](../.github/agents/orchestrator.agent.md)  
**Tools**: `read`, `edit`, `search`, `agent`, `todo`, `memory`

| | |
|-|-|
| **Inputs** | User goal (free text) |
| **Outputs** | `tasks/<id>/plan.md`; dispatches subagents |
| **Never does** | Edits source code; runs build/test commands |

**When to invoke**: For any non-trivial multi-file change. Use this agent as the primary entry point for the pipeline.

**Exit criteria**: `tasks/<id>/review.md` verdict is APPROVE and all artifacts are present.

---

## Explore

**File**: [`.github/agents/explore.agent.md`](../.github/agents/explore.agent.md)  
**Tools**: `read`, `search` (read-only)

| | |
|-|-|
| **Inputs** | `tasks/<id>/plan.md` |
| **Outputs** | `tasks/<id>/exploration.md` |
| **Never does** | Edits files; runs commands; guesses without evidence |

**When to invoke**: Before any implementation — to map affected files, dependencies, and risks.

**Exit criteria**: All sections of `exploration.md` are complete; at least one affected file listed; risks section non-empty.

---

## Implementer

**File**: [`.github/agents/implementer.agent.md`](../.github/agents/implementer.agent.md)  
**Tools**: `read`, `edit`, `search`, `execute` (formatter only)

| | |
|-|-|
| **Inputs** | `tasks/<id>/plan.md` + `tasks/<id>/exploration.md` |
| **Outputs** | Modified source files; `tasks/<id>/changes.md` |
| **Never does** | Runs build or test commands; touches out-of-scope files; hard-codes secrets |

**When to invoke**: After `exploration.md` is complete; once per work package.

**Exit criteria**: Work package goal met; new logic has tests; formatter run; `changes.md` written.

---

## Validator

**File**: [`.github/agents/validator.agent.md`](../.github/agents/validator.agent.md)  
**Tools**: `read`, `execute`

| | |
|-|-|
| **Inputs** | `tasks/<id>/changes.md` + codebase |
| **Outputs** | `tasks/<id>/validation.md` |
| **Never does** | Edits source code; skips a failing check; runs deployment commands |

**When to invoke**: After `changes.md` is written; before the Reviewer sees the change.

**Exit criteria**: All three checks (build, test, lint) recorded with PASS verdict; FAIL details complete enough for Implementer to diagnose.

---

## Reviewer

**File**: [`.github/agents/reviewer.agent.md`](../.github/agents/reviewer.agent.md)  
**Tools**: `read`, `search` (read-only)

| | |
|-|-|
| **Inputs** | All task artifacts + codebase |
| **Outputs** | `tasks/<id>/review.md` with APPROVE or CHANGES REQUESTED |
| **Never does** | Edits source code; approves with failing checks; leaves placeholder text |

**When to invoke**: After `validation.md` shows PASS.

**Exit criteria**: Every required check documented with evidence; verdict is clear; CHANGES REQUESTED items are specific and actionable.

---

## Docs Writer

**File**: [`.github/agents/docs-writer.agent.md`](../.github/agents/docs-writer.agent.md)  
**Tools**: `read`, `edit`, `search`

| | |
|-|-|
| **Inputs** | `review.md` + `changes.md` + existing docs |
| **Outputs** | Updated README, `docs/`, inline comments |
| **Never does** | Changes source logic; creates docs for unchanged code |

**When to invoke**: After APPROVE, when `review.md` notes that documentation needs updating.

**Exit criteria**: All public interfaces changed in `changes.md` have accurate documentation; no stale references remain.

---

## Firmware Engineer *(example specialist)*

**File**: [`.github/agents/firmware-engineer.agent.md`](../.github/agents/firmware-engineer.agent.md)  
**Tools**: `read`, `edit`, `search`, `execute`  
**Status**: disabled by default (`user-invocable: false`)

Domain: ESP-IDF, HAL, FreeRTOS, peripheral drivers, IRAM placement, interrupt safety.

To enable: set `user-invocable: true` in the agent frontmatter and customise the project-specific sections.

---

## Protocol Specialist *(example specialist)*

**File**: [`.github/agents/protocol-specialist.agent.md`](../.github/agents/protocol-specialist.agent.md)  
**Tools**: `read`, `edit`, `search`  
**Status**: disabled by default (`user-invocable: false`)

Domain: wire protocols, message schemas, codec changes, backwards-compatibility analysis, golden fixtures.

To enable: set `user-invocable: true` in the agent frontmatter and customise the project-specific sections.
