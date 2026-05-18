# Task Lifecycle

## Task ID Convention

Format: `YYYYMMDD-slug`

- `YYYYMMDD` — date the task was created (UTC)
- `slug` — short hyphenated description of the goal (e.g. `add-auth`, `fix-parser-overflow`)

Example: `20260514-add-oauth2-login`

This convention is human-readable, chronologically sortable, and requires no central counter or state file.

## Lifecycle Phases

```
 New Task
    │
    ▼
┌─────────┐    plan.md written
│  PLAN   │◄── Orchestrator decomposes goal into work packages
└────┬────┘
     │
     ▼
┌─────────┐    exploration.md written
│ EXPLORE │◄── Explore Agent maps affected files, deps, risks
└────┬────┘
     │ gate: exploration.md present & non-empty
     ▼
┌──────────────┐    changes.md written
│  IMPLEMENT   │◄── Implementer Agent edits exactly one slice
└──────┬───────┘
       │ gate: changes.md present & non-empty
       ▼
┌──────────┐    validation.md written
│ VALIDATE │◄── Validator Agent runs build/test/lint on changed area
└─────┬────┘
      │ gate: validation.md shows PASS
      ▼
┌────────┐    review.md written
│ REVIEW │◄── Reviewer Agent checks for regressions, missing tests,
└───┬────┘    architecture drift, requirement traceability
    │
    ├── verdict: APPROVE ──► task DONE
    │
    └── verdict: CHANGES REQUESTED ──► back to IMPLEMENT
                                        (with review.md as additional input)
```

## Phase Definitions

### PLAN

**Owner**: Orchestrator  
**Input**: User goal (free text)  
**Output**: `tasks/<id>/plan.md`  
**Exit criteria**:
- Goal is restated unambiguously.
- Work packages are listed (each ≤ 1 logical slice).
- Constraints and out-of-scope items are explicit.
- No code has been touched.

### EXPLORE

**Owner**: Explore Agent  
**Input**: `plan.md`  
**Output**: `tasks/<id>/exploration.md`  
**Exit criteria**:
- Affected files listed with line references where relevant.
- Dependency graph of changed module documented.
- Control-flow path from entry point to change site described.
- Risk items (breakage surface, test coverage gaps) noted.

### IMPLEMENT

**Owner**: Implementer Agent  
**Input**: `plan.md` + `exploration.md`  
**Output**: `tasks/<id>/changes.md` + actual code edits  
**Exit criteria**:
- Exactly one work package from `plan.md` has been implemented.
- `changes.md` summarises what changed, why, and any decisions made.
- No unrelated files touched.
- Formatter has been run on changed files.

### VALIDATE

**Owner**: Validator Agent  
**Input**: `changes.md` + codebase  
**Output**: `tasks/<id>/validation.md`  
**Exit criteria**:
- Build command executed and result recorded.
- Relevant test suite executed and result recorded.
- Linter/type-checker executed on changed files and result recorded.
- All checks PASS. (If any FAIL, validation.md documents failures; Orchestrator returns to IMPLEMENT.)

### REVIEW

**Owner**: Reviewer Agent  
**Input**: All prior artifacts + codebase diff  
**Output**: `tasks/<id>/review.md`  
**Exit criteria**:
- Requirements traceability: every item in `plan.md` either implemented or explicitly deferred.
- Regression check: no previously passing tests broken.
- Test adequacy: new logic covered by at least one test.
- Architecture check: no unintended coupling or boundary violations.
- Security check: no new OWASP Top-10 issues introduced.
- Verdict is `APPROVE` or `CHANGES REQUESTED` (with specific action items).

## Artifact Rules

1. **Template seed, then append-only**: the owning agent may replace the copied template placeholders once when writing the first real phase output. After that, never delete or overwrite existing content; add a dated section header when updating.
2. **Owner discipline**: Only the owning agent writes the primary content; later agents may append notes in a clearly marked `## Notes from <phase>` section.
3. **Self-contained**: Each artifact must be readable standalone — include enough context that a human can understand it without opening the code.

## Done Criteria

A task is **DONE** when:
- `review.md` verdict is `APPROVE`
- All artifact files are present and non-empty
- No open action items remain in `review.md`

Completed task folders are **not deleted** — they serve as a searchable history of decisions.
