---
name: review-diff
description: "Systematically review a code diff for regressions, missing tests, architecture violations, security issues, and requirement traceability. Use when acting as the Reviewer agent, auditing a pull request, or evaluating whether an implementation matches its plan. Produces review.md."
argument-hint: "Path to the task folder, e.g. tasks/20260514-add-auth"
---

# Review Diff

Structured code review checklist that produces `review.md` with a clear APPROVE / CHANGES REQUESTED verdict.

## When to Use

- After validation passes, to complete the Review phase.
- When auditing any significant code change.
- When comparing an implementation against its original requirements.

## Procedure

### Step 1 — Read all artifacts

In order:
1. `tasks/<id>/plan.md` — what was supposed to be done
2. `tasks/<id>/exploration.md` — what was expected to change
3. `tasks/<id>/changes.md` — what actually changed
4. `tasks/<id>/validation.md` — confirm it says PASS

### Step 2 — Requirements traceability

For every work package in `plan.md`:
- [ ] Locate the implementation in `changes.md` (file + function)
- [ ] Confirm the work package goal is met
- [ ] If deferred: confirm there is a reason and it is noted in `changes.md`

### Step 3 — Regression check

- [ ] Search test files for tests covering affected modules
- [ ] Cross-reference with `validation.md` — all tests passed
- [ ] Check if any tests were deleted or disabled — if so, flag this

### Step 4 — Test adequacy

- [ ] New or modified logic has at least one test
- [ ] Error paths / edge cases have tests (not just happy path)
- [ ] Tests use realistic inputs (not only trivial stubs)

### Step 5 — Architecture

- [ ] Changed files stay within their module's responsibility boundary
- [ ] No new circular dependencies introduced
- [ ] Public interfaces changed only if explicitly planned — with a migration path
- [ ] No new global state or hidden singletons

### Step 6 — Security

Apply the checklist from `.github/instructions/security-boundaries.instructions.md`:
- [ ] No hardcoded secrets or credentials
- [ ] All external input validated at system boundaries
- [ ] No new injection risks (SQL, shell, LDAP, path traversal)
- [ ] Auth/authz checks present on any new endpoint or action
- [ ] No SSRF — URLs from input are validated
- [ ] Dependencies checked for known CVEs

### Step 7 — Code quality (non-blocking observations)

Note (but do not block on) style issues, missing comments, or improvement opportunities. Log these as suggestions for a follow-up task.

### Step 8 — Write review.md

Fill in `tasks/<task-id>/review.md` using the schema from `tasks/_template/review.md`:
- Verdict: **APPROVE** or **CHANGES REQUESTED**
- Status + evidence for each check
- If CHANGES REQUESTED: numbered, specific, actionable items

## Verdict Criteria

| Verdict | Condition |
|---------|-----------|
| **APPROVE** | All required checks pass; no blocking issues |
| **CHANGES REQUESTED** | Any required check fails; issues are blocking |

## Output

A complete `tasks/<task-id>/review.md`.
