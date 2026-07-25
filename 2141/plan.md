---
plan_schema_version: "1.0"
issue: 2141
title: "Authorization Workflow Fix — Record Session Authorization Before Verifying"
dispatch:
  - phase: phase-5
    skill: test-driven-development
    task: red
  - phase: phase-1
    skill: test-driven-development
    task: green
  - phase: phase-2
    skill: test-driven-development
    task: green
  - phase: phase-3
    skill: test-driven-development
    task: green
  - phase: phase-4
    skill: test-driven-development
    task: green
---

# Plan: Authorization Workflow Fix — Record Session Authorization Before Verifying

## Pre-Implementation Steps

- [ ] **Coherence gate** — dispatch `audit --task coherence-extraction` to verify spec/plan coherence before any implementation. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **Baseline check** — dispatch `pre-red-baseline` from implementation-pipeline to verify trunk tip, clean working tree, and submodule state. (**sub-agent**) Context: {issue_number: 2141}

## Pre-Completed Items

The following SCs are already implemented and verified. No implementation work is needed — they are documented here for completeness and to prevent re-work.

| SC | Description | Status | Evidence |
|----|-------------|--------|----------|
| SC-1 | Create `record-authorization.md` task file | ✅ Already implemented | File exists at `.opencode/skills/approval-gate-scope/tasks/verify-authorization/record-authorization.md` |
| SC-8 | Remove `verify-explicit-authorization.md`, create `verify-recording.md` | ✅ Already implemented | `verify-explicit-authorization.md` is removed; `verify-recording.md` exists at `.opencode/skills/approval-gate-scope/tasks/verify-authorization/verify-recording.md` |

**Note:** These items are excluded from all implementation phases below. The RED/GREEN cycles in Phase-5 through Phase-4 do not cover SC-1 or SC-8.

---

## Phase-5: Behavioral Enforcement Tests (RED Phase)

**Concern:** Write RED-phase behavioral enforcement tests for all behavioral SCs before any GREEN implementation. These tests must FAIL initially (the implementation doesn't exist yet).

**SCs covered:** SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-9, SC-10, SC-11, SC-12, SC-13

**Dependencies:** None (runs first)

### Item: SC-2 — RED test for record-authorization scope gating

- [ ] **red-phase** — dispatch `test-driven-development --task red` to write a behavioral test that verifies `record-authorization` sets `status: approved` in spec.md frontmatter when scope is `for_implementation` or higher, and does NOT set it for scopes below `for_implementation`. (**sub-agent**) Context: {issue_number: 2141, sc_id: SC-2}
- [ ] **z3-check-red** — dispatch `solve --task check` to validate RED test state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}
- [ ] **red-doublecheck** — dispatch `verification-before-completion --task verify` to verify the RED test is correct and fails as expected. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-red-doublecheck** — dispatch `solve --task check` to validate RED doublecheck state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}
- [ ] **post-red-enforcement** — dispatch `post-red-enforcement` from implementation-pipeline to enforce RED gate. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-post-red** — dispatch `solve --task check` to validate post-RED state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}

### Item: SC-3 — RED test for comments.yaml authorization record

- [ ] **red-phase** — dispatch `test-driven-development --task red` to write a behavioral test that verifies `record-authorization` appends an authorization record to `comments.yaml` with authorization text, scope, timestamp, and human attribution. (**sub-agent**) Context: {issue_number: 2141, sc_id: SC-3}
- [ ] **z3-check-red** — dispatch `solve --task check` to validate RED test state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}
- [ ] **red-doublecheck** — dispatch `verification-before-completion --task verify` to verify the RED test is correct and fails as expected. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-red-doublecheck** — dispatch `solve --task check` to validate RED doublecheck state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}
- [ ] **post-red-enforcement** — dispatch `post-red-enforcement` from implementation-pipeline to enforce RED gate. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-post-red** — dispatch `solve --task check` to validate post-RED state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}

### Item: SC-4 — RED test for issue.yaml label

- [ ] **red-phase** — dispatch `test-driven-development --task red` to write a behavioral test that verifies `record-authorization` updates `issue.yaml` with the `approved-for-{scope}` label. (**sub-agent**) Context: {issue_number: 2141, sc_id: SC-4}
- [ ] **z3-check-red** — dispatch `solve --task check` to validate RED test state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}
- [ ] **red-doublecheck** — dispatch `verification-before-completion --task verify` to verify the RED test is correct and fails as expected. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-red-doublecheck** — dispatch `solve --task check` to validate RED doublecheck state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}
- [ ] **post-red-enforcement** — dispatch `post-red-enforcement` from implementation-pipeline to enforce RED gate. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-post-red** — dispatch `solve --task check` to validate post-RED state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}

### Item: SC-5 — RED test for worktree commit

- [ ] **red-phase** — dispatch `test-driven-development --task red` to write a behavioral test that verifies `record-authorization` commits the `.issues/` worktree changes after writing. (**sub-agent**) Context: {issue_number: 2141, sc_id: SC-5}
- [ ] **z3-check-red** — dispatch `solve --task check` to validate RED test state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}
- [ ] **red-doublecheck** — dispatch `verification-before-completion --task verify` to verify the RED test is correct and fails as expected. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-red-doublecheck** — dispatch `solve --task check` to validate RED doublecheck state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}
- [ ] **post-red-enforcement** — dispatch `post-red-enforcement` from implementation-pipeline to enforce RED gate. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-post-red** — dispatch `solve --task check` to validate post-RED state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}

### Item: SC-6 — RED test for fast-path workflow order

- [ ] **red-phase** — dispatch `test-driven-development --task red` to write a behavioral test that verifies the fast-path workflow shows `record-authorization` before `verify-recording` in stderr. (**sub-agent**) Context: {issue_number: 2141, sc_id: SC-6}
- [ ] **z3-check-red** — dispatch `solve --task check` to validate RED test state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}
- [ ] **red-doublecheck** — dispatch `verification-before-completion --task verify` to verify the RED test is correct and fails as expected. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-red-doublecheck** — dispatch `solve --task check` to validate RED doublecheck state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}
- [ ] **post-red-enforcement** — dispatch `post-red-enforcement` from implementation-pipeline to enforce RED gate. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-post-red** — dispatch `solve --task check` to validate post-RED state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}

### Item: SC-7 — RED test for full-path workflow order

- [ ] **red-phase** — dispatch `test-driven-development --task red` to write a behavioral test that verifies the full-path workflow shows `record-authorization` at position 2 and `verify-recording` at position 3 in stderr. (**sub-agent**) Context: {issue_number: 2141, sc_id: SC-7}
- [ ] **z3-check-red** — dispatch `solve --task check` to validate RED test state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}
- [ ] **red-doublecheck** — dispatch `verification-before-completion --task verify` to verify the RED test is correct and fails as expected. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-red-doublecheck** — dispatch `solve --task check` to validate RED doublecheck state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}
- [ ] **post-red-enforcement** — dispatch `post-red-enforcement` from implementation-pipeline to enforce RED gate. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-post-red** — dispatch `solve --task check` to validate post-RED state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}

### Item: SC-9 — RED test for verify-recording BLOCK on missing state

- [ ] **red-phase** — dispatch `test-driven-development --task red` to write a behavioral test that verifies `verify-recording` returns BLOCKED when spec.md, comments.yaml, or issue.yaml is missing or corrupted. (**sub-agent**) Context: {issue_number: 2141, sc_id: SC-9}
- [ ] **z3-check-red** — dispatch `solve --task check` to validate RED test state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}
- [ ] **red-doublecheck** — dispatch `verification-before-completion --task verify` to verify the RED test is correct and fails as expected. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-red-doublecheck** — dispatch `solve --task check` to validate RED doublecheck state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}
- [ ] **post-red-enforcement** — dispatch `post-red-enforcement` from implementation-pipeline to enforce RED gate. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-post-red** — dispatch `solve --task check` to validate post-RED state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}

### Item: SC-10 — RED test for apply-label position

- [ ] **red-phase** — dispatch `test-driven-development --task red` to write a behavioral test that verifies `apply-label` is dispatched after `verify-recording` in stderr. (**sub-agent**) Context: {issue_number: 2141, sc_id: SC-10}
- [ ] **z3-check-red** — dispatch `solve --task check` to validate RED test state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}
- [ ] **red-doublecheck** — dispatch `verification-before-completion --task verify` to verify the RED test is correct and fails as expected. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-red-doublecheck** — dispatch `solve --task check` to validate RED doublecheck state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}
- [ ] **post-red-enforcement** — dispatch `post-red-enforcement` from implementation-pipeline to enforce RED gate. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-post-red** — dispatch `solve --task check` to validate post-RED state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}

### Item: SC-11 — RED test for gap-fill-path workflow order

- [ ] **red-phase** — dispatch `test-driven-development --task red` to write a behavioral test that verifies the gap-fill-path workflow shows `record-authorization` at position 2 and `verify-recording` at position 3 in stderr. (**sub-agent**) Context: {issue_number: 2141, sc_id: SC-11}
- [ ] **z3-check-red** — dispatch `solve --task check` to validate RED test state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}
- [ ] **red-doublecheck** — dispatch `verification-before-completion --task verify` to verify the RED test is correct and fails as expected. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-red-doublecheck** — dispatch `solve --task check` to validate RED doublecheck state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}
- [ ] **post-red-enforcement** — dispatch `post-red-enforcement` from implementation-pipeline to enforce RED gate. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-post-red** — dispatch `solve --task check` to validate post-RED state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}

### Item: SC-12 — RED test for record-authorization as step 2 in all workflows

- [ ] **red-phase** — dispatch `test-driven-development --task red` to write a behavioral test that verifies `record-authorization` is step 2 in all three workflows (fast-path, gap-fill-path, full-path) in stderr. (**sub-agent**) Context: {issue_number: 2141, sc_id: SC-12}
- [ ] **z3-check-red** — dispatch `solve --task check` to validate RED test state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}
- [ ] **red-doublecheck** — dispatch `verification-before-completion --task verify` to verify the RED test is correct and fails as expected. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-red-doublecheck** — dispatch `solve --task check` to validate RED doublecheck state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}
- [ ] **post-red-enforcement** — dispatch `post-red-enforcement` from implementation-pipeline to enforce RED gate. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-post-red** — dispatch `solve --task check` to validate post-RED state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}

### Item: SC-13 — RED test for source_db: MISSING

- [ ] **red-phase** — dispatch `test-driven-development --task red` to write a behavioral test that verifies `__export_sqlite_to_yaml` writes `source_db: MISSING` when the SQLite DB is not found in the test home, and does NOT fall back to production paths. (**sub-agent**) Context: {issue_number: 2141, sc_id: SC-13}
- [ ] **z3-check-red** — dispatch `solve --task check` to validate RED test state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}
- [ ] **red-doublecheck** — dispatch `verification-before-completion --task verify` to verify the RED test is correct and fails as expected. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-red-doublecheck** — dispatch `solve --task check` to validate RED doublecheck state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}
- [ ] **post-red-enforcement** — dispatch `post-red-enforcement` from implementation-pipeline to enforce RED gate. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-post-red** — dispatch `solve --task check` to validate post-RED state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}

---

## Phase-1: Record-Authorization Task Implementation

**Concern:** Implement the `record-authorization` task procedure — write session authorization into persistent issue state (spec.md frontmatter, comments.yaml, issue.yaml) and commit the worktree.

**SCs covered:** SC-2, SC-3, SC-4, SC-5

**Dependencies:** Phase-5 (RED tests must exist first)

### Item: SC-2 — record-authorization sets status: approved per scope

- [ ] **green-phase** — dispatch `test-driven-development --task green` to implement the `record-authorization` task's spec.md frontmatter update logic: set `status: approved` when scope is `for_implementation` or higher; do NOT set it for `for_analysis`, `for_spec`, or `for_plan`. (**sub-agent**) Context: {issue_number: 2141, sc_id: SC-2}
- [ ] **z3-check-green** — dispatch `solve --task check` to validate GREEN state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}
- [ ] **post-green-enforcement** — dispatch `post-green-enforcement` from implementation-pipeline to enforce GREEN gate. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-post-green** — dispatch `solve --task check` to validate post-GREEN state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}
- [ ] **checkpoint-tag-create** — dispatch `checkpoint-tag-create` from implementation-pipeline to create a checkpoint tag for this item. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **checkpoint-commit** — dispatch `git-workflow --task commit-prep` to commit the changes with checkpoint tag. (**sub-agent**) Context: {issue_number: 2141}

### Item: SC-3 — record-authorization appends to comments.yaml

- [ ] **green-phase** — dispatch `test-driven-development --task green` to implement the `record-authorization` task's `comments.yaml` append logic: write authorization text, scope, timestamp, and human attribution as a new YAML entry. (**sub-agent**) Context: {issue_number: 2141, sc_id: SC-3}
- [ ] **z3-check-green** — dispatch `solve --task check` to validate GREEN state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}
- [ ] **post-green-enforcement** — dispatch `post-green-enforcement` from implementation-pipeline to enforce GREEN gate. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-post-green** — dispatch `solve --task check` to validate post-GREEN state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}
- [ ] **checkpoint-tag-create** — dispatch `checkpoint-tag-create` from implementation-pipeline to create a checkpoint tag for this item. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **checkpoint-commit** — dispatch `git-workflow --task commit-prep` to commit the changes with checkpoint tag. (**sub-agent**) Context: {issue_number: 2141}

### Item: SC-4 — record-authorization updates issue.yaml label

- [ ] **green-phase** — dispatch `test-driven-development --task green` to implement the `record-authorization` task's `issue.yaml` label update logic: add `approved-for-{scope}` to the labels array. (**sub-agent**) Context: {issue_number: 2141, sc_id: SC-4}
- [ ] **z3-check-green** — dispatch `solve --task check` to validate GREEN state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}
- [ ] **post-green-enforcement** — dispatch `post-green-enforcement` from implementation-pipeline to enforce GREEN gate. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-post-green** — dispatch `solve --task check` to validate post-GREEN state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}
- [ ] **checkpoint-tag-create** — dispatch `checkpoint-tag-create` from implementation-pipeline to create a checkpoint tag for this item. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **checkpoint-commit** — dispatch `git-workflow --task commit-prep` to commit the changes with checkpoint tag. (**sub-agent**) Context: {issue_number: 2141}

### Item: SC-5 — record-authorization commits worktree

- [ ] **green-phase** — dispatch `test-driven-development --task green` to implement the `record-authorization` task's worktree commit logic: run `git -C .issues/ add -A && git -C .issues/ commit -m` after writing all three files. Handle commit failure with BLOCKED + COMMIT_FAILED reason. (**sub-agent**) Context: {issue_number: 2141, sc_id: SC-5}
- [ ] **z3-check-green** — dispatch `solve --task check` to validate GREEN state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}
- [ ] **post-green-enforcement** — dispatch `post-green-enforcement` from implementation-pipeline to enforce GREEN gate. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-post-green** — dispatch `solve --task check` to validate post-GREEN state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}
- [ ] **checkpoint-tag-create** — dispatch `checkpoint-tag-create` from implementation-pipeline to create a checkpoint tag for this item. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **checkpoint-commit** — dispatch `git-workflow --task commit-prep` to commit the changes with checkpoint tag. (**sub-agent**) Context: {issue_number: 2141}

---

## Phase-2: Verify-Recording Task Implementation

**Concern:** Implement the `verify-recording` task procedure — read back spec.md, comments.yaml, and issue.yaml, confirm all three match what was written, and return BLOCKED if any are missing.

**SCs covered:** SC-9

**Dependencies:** Phase-1 (verify-recording reads state written by record-authorization)

### Item: SC-9 — verify-recording checks all three files

- [ ] **green-phase** — dispatch `test-driven-development --task green` to implement the `verify-recording` task: read spec.md frontmatter for `status: approved`, read comments.yaml for the authorization record, read issue.yaml for the label. Return PASS if all three match. Return BLOCKED with specific reason if any are missing or corrupted. Handle edge cases: malformed frontmatter, missing comments.yaml, missing issue.yaml. (**sub-agent**) Context: {issue_number: 2141, sc_id: SC-9}
- [ ] **z3-check-green** — dispatch `solve --task check` to validate GREEN state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}
- [ ] **post-green-enforcement** — dispatch `post-green-enforcement` from implementation-pipeline to enforce GREEN gate. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-post-green** — dispatch `solve --task check` to validate post-GREEN state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}
- [ ] **checkpoint-tag-create** — dispatch `checkpoint-tag-create` from implementation-pipeline to create a checkpoint tag for this item. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **checkpoint-commit** — dispatch `git-workflow --task commit-prep` to commit the changes with checkpoint tag. (**sub-agent**) Context: {issue_number: 2141}

---

## Phase-3: Workflow Reordering in SKILL.md

**Concern:** Reorder all three workflows (fast-path, full-path, gap-fill-path) in `approval-gate-scope/SKILL.md` to the record-then-verify pattern. Insert `record-authorization` at position 2 (after `scope-auto-resolve`), replace `verify-explicit-authorization` with `verify-recording` at position 3, move `apply-label` to position 4.

**SCs covered:** SC-6, SC-7, SC-10, SC-11, SC-12

**Dependencies:** Phase-1 (record-authorization task must exist), Phase-2 (verify-recording task must exist)

### Item: SC-6 — Fast-path workflow reordering

- [ ] **green-phase** — dispatch `test-driven-development --task green` to reorder the fast-path workflow in `approval-gate-scope/SKILL.md` to: scope-auto-resolve → record-authorization → verify-recording → apply-label → auto-dispatch. (**sub-agent**) Context: {issue_number: 2141, sc_id: SC-6}
- [ ] **z3-check-green** — dispatch `solve --task check` to validate GREEN state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}
- [ ] **post-green-enforcement** — dispatch `post-green-enforcement` from implementation-pipeline to enforce GREEN gate. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-post-green** — dispatch `solve --task check` to validate post-GREEN state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}
- [ ] **checkpoint-tag-create** — dispatch `checkpoint-tag-create` from implementation-pipeline to create a checkpoint tag for this item. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **checkpoint-commit** — dispatch `git-workflow --task commit-prep` to commit the changes with checkpoint tag. (**sub-agent**) Context: {issue_number: 2141}

### Item: SC-7 — Full-path workflow reordering

- [ ] **green-phase** — dispatch `test-driven-development --task green` to reorder the full-path workflow in `approval-gate-scope/SKILL.md` to: scope-auto-resolve → record-authorization → verify-recording → apply-label → item-decomposition → SC-traceability → sub-issues → spec-to-plan-cascade → gap-fill-cascade → verify-codebase → verify-blockers → verify-closed-issue → verify-already-implemented → auto-dispatch. (**sub-agent**) Context: {issue_number: 2141, sc_id: SC-7}
- [ ] **z3-check-green** — dispatch `solve --task check` to validate GREEN state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}
- [ ] **post-green-enforcement** — dispatch `post-green-enforcement` from implementation-pipeline to enforce GREEN gate. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-post-green** — dispatch `solve --task check` to validate post-GREEN state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}
- [ ] **checkpoint-tag-create** — dispatch `checkpoint-tag-create` from implementation-pipeline to create a checkpoint tag for this item. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **checkpoint-commit** — dispatch `git-workflow --task commit-prep` to commit the changes with checkpoint tag. (**sub-agent**) Context: {issue_number: 2141}

### Item: SC-10 — apply-label moved to step 4

- [ ] **green-phase** — dispatch `test-driven-development --task green` to move the `apply-label` step to position 4 (after `record-authorization` and `verify-recording`) in all three workflows in `approval-gate-scope/SKILL.md`. (**sub-agent**) Context: {issue_number: 2141, sc_id: SC-10}
- [ ] **z3-check-green** — dispatch `solve --task check` to validate GREEN state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}
- [ ] **post-green-enforcement** — dispatch `post-green-enforcement` from implementation-pipeline to enforce GREEN gate. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-post-green** — dispatch `solve --task check` to validate post-GREEN state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}
- [ ] **checkpoint-tag-create** — dispatch `checkpoint-tag-create` from implementation-pipeline to create a checkpoint tag for this item. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **checkpoint-commit** — dispatch `git-workflow --task commit-prep` to commit the changes with checkpoint tag. (**sub-agent**) Context: {issue_number: 2141}

### Item: SC-11 — Gap-fill-path workflow reordering

- [ ] **green-phase** — dispatch `test-driven-development --task green` to reorder the gap-fill-path workflow in `approval-gate-scope/SKILL.md` to: scope-auto-resolve → record-authorization → verify-recording → gap-fill-cascade → auto-dispatch. (**sub-agent**) Context: {issue_number: 2141, sc_id: SC-11}
- [ ] **z3-check-green** — dispatch `solve --task check` to validate GREEN state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}
- [ ] **post-green-enforcement** — dispatch `post-green-enforcement` from implementation-pipeline to enforce GREEN gate. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-post-green** — dispatch `solve --task check` to validate post-GREEN state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}
- [ ] **checkpoint-tag-create** — dispatch `checkpoint-tag-create` from implementation-pipeline to create a checkpoint tag for this item. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **checkpoint-commit** — dispatch `git-workflow --task commit-prep` to commit the changes with checkpoint tag. (**sub-agent**) Context: {issue_number: 2141}

### Item: SC-12 — record-authorization is step 2 in all workflows

- [ ] **green-phase** — dispatch `test-driven-development --task green` to verify and ensure `record-authorization` is step 2 (immediately after `scope-auto-resolve`) in all three workflows in `approval-gate-scope/SKILL.md`. Fix any workflow where it is not at position 2. (**sub-agent**) Context: {issue_number: 2141, sc_id: SC-12}
- [ ] **z3-check-green** — dispatch `solve --task check` to validate GREEN state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}
- [ ] **post-green-enforcement** — dispatch `post-green-enforcement` from implementation-pipeline to enforce GREEN gate. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-post-green** — dispatch `solve --task check` to validate post-GREEN state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}
- [ ] **checkpoint-tag-create** — dispatch `checkpoint-tag-create` from implementation-pipeline to create a checkpoint tag for this item. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **checkpoint-commit** — dispatch `git-workflow --task commit-prep` to commit the changes with checkpoint tag. (**sub-agent**) Context: {issue_number: 2141}

---

## Phase-4: Behavioral Test Harness — source_db: MISSING

**Concern:** Implement `source_db: MISSING` in `__export_sqlite_to_yaml` when the SQLite DB is not found in the test home. Remove all production fallback paths. The evaluation pipeline must treat `source_db: MISSING` as a hard FAIL.

**SCs covered:** SC-13

**Dependencies:** Phase-5 (RED tests must exist first)

### Item: SC-13 — source_db: MISSING in harness

- [ ] **green-phase** — dispatch `test-driven-development --task green` to modify `__export_sqlite_to_yaml` to write `source_db: MISSING` (not `null`, not a fallback path) when the SQLite DB is not found in the test home. Remove all production fallback paths (XDG paths, environment variables, hardcoded paths). The evaluation pipeline must treat `source_db: MISSING` as a hard FAIL. (**sub-agent**) Context: {issue_number: 2141, sc_id: SC-13}
- [ ] **z3-check-green** — dispatch `solve --task check` to validate GREEN state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}
- [ ] **post-green-enforcement** — dispatch `post-green-enforcement` from implementation-pipeline to enforce GREEN gate. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-post-green** — dispatch `solve --task check` to validate post-GREEN state transition. (**inline**) Context: {issue_number: 2141, contract_path: ...}
- [ ] **checkpoint-tag-create** — dispatch `checkpoint-tag-create` from implementation-pipeline to create a checkpoint tag for this item. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **checkpoint-commit** — dispatch `git-workflow --task commit-prep` to commit the changes with checkpoint tag. (**sub-agent**) Context: {issue_number: 2141}

---

## Post-Implementation Steps

- [ ] **Structural checks** — dispatch `finishing-a-development-branch --task checklist` to run lint, typecheck, and structural verification across all modified files. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **Green doublecheck** — dispatch `verification-before-completion --task verify` to verify all GREEN implementations are correct. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **Verification before completion** — dispatch `verification-before-completion --task completion` to run the full VbC gate against all SCs. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **SC count gate** — dispatch `sc-count-gate` from implementation-pipeline to verify all SCs have a verdict. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **Pre-PR gate** — dispatch `verification-before-completion --task verify` to check all SC verdicts — BLOCK if any FAIL. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **Rationalization check** — dispatch `verification-before-completion --task verify` to check for rationalization in any proposed action. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **Audit** — dispatch the appropriate audit task from `audit` skill with `{spec_local_dir, artifact_evidence_dir}`. If non-clean-pass, remediate and restart. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **Cross-validate** — dispatch `audit --task cross-validate` to produce consensus findings. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **Regression check** — dispatch `test-driven-development --task patterns` to generate regression test patterns. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **Behavioral test remediation** — dispatch `behavioral-test-remediation` from implementation-pipeline if any behavioral test needs remediation. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **Review prep** — dispatch `git-workflow --task review-prep` to prepare the branch for review. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **Create PR** — dispatch `pr-creation-workflow --task create` to create the pull request with evidence artifacts. (**sub-agent**) Context: {issue_number: 2141, authorization_scope, halt_at}
- [ ] **Completion** — dispatch `completion-core --task completion` to produce the executive summary. (**sub-agent**) Context: {issue_number: 2141}

---

## Lifecycle Events

| Timestamp | Event | Details |
|-----------|-------|---------|
| 2026-07-25T12:00:00Z | `plan_created` | Plan file at `.opencode/.issues/2141/plan.md`, 5 phases, 22 items total |
