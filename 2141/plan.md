---
plan_schema_version: "1.0"
issue: 2141
title: "Authorization Workflow Fix — Record Session Authorization Before Verifying"
dispatch:
  - phase: phase-1a
    skill: implementation-pipeline
    task: assemble-work
  - phase: phase-1b
    skill: test-driven-development
    task: red
  - phase: phase-1b
    skill: test-driven-development
    task: green
  - phase: phase-2
    skill: test-driven-development
    task: red
  - phase: phase-2
    skill: test-driven-development
    task: green
  - phase: phase-3
    skill: test-driven-development
    task: red
  - phase: phase-3
    skill: test-driven-development
    task: green
  - phase: phase-4
    skill: test-driven-development
    task: red
  - phase: phase-4
    skill: test-driven-development
    task: green
  - phase: phase-5
    skill: finishing-a-development-branch
    task: checklist
  - phase: phase-5
    skill: audit
    task: verification-audit
  - phase: phase-5
    skill: git-workflow
    task: review-prep
  - phase: phase-5
    skill: pr-creation-workflow
    task: create
---

# Plan: Authorization Workflow Fix — Record Session Authorization Before Verifying

## Pre-Implementation Steps

- [ ] **Coherence gate** — dispatch `audit --task coherence-extraction` to verify spec/plan coherence before any implementation. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **Baseline check** — dispatch `pre-red-baseline` from implementation-pipeline to verify trunk tip, clean working tree, and submodule state. (**sub-agent**) Context: {issue_number: 2141}

---

## Phase 1a: Task File Scaffolding

**Concern:** Create structural task files (`record-authorization.md`, `verify-recording.md`), remove `verify-explicit-authorization.md`.

**SCs covered:** SC-1, SC-8

**Dependencies:** None (first phase)

### Item 1: SC-1 — Create `record-authorization.md` task file

- [ ] **assemble-work** — dispatch `implementation-pipeline --task assemble-work` to create the `record-authorization.md` task file at `approval-gate-scope/tasks/record-authorization.md`. The file must contain the task procedure for writing session authorization into persistent issue state (spec.md frontmatter, comments.yaml, issue.yaml) and committing the worktree. (**sub-agent**) Context: {issue_number: 2141, sc_id: SC-1}
- [ ] **checkpoint-tag-create** — dispatch `checkpoint-tag-create` from implementation-pipeline to create a checkpoint tag for this item. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **checkpoint-commit** — dispatch `git-workflow --task commit-prep` to commit the changes with checkpoint tag. (**sub-agent**) Context: {issue_number: 2141}

### Item 2: SC-8 — Remove `verify-explicit-authorization.md`, create `verify-recording.md`

- [ ] **assemble-work** — dispatch `implementation-pipeline --task assemble-work` to remove `verify-explicit-authorization.md` from `approval-gate-scope/tasks/verify-authorization/` and create `verify-recording.md` at `approval-gate-scope/tasks/verify-authorization/verify-recording.md`. The `verify-recording.md` task file must contain the procedure for reading back recorded state (spec.md frontmatter, comments.yaml, issue.yaml) and confirming it matches what was written. (**sub-agent**) Context: {issue_number: 2141, sc_id: SC-8}
- [ ] **checkpoint-tag-create** — dispatch `checkpoint-tag-create` from implementation-pipeline to create a checkpoint tag for this item. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **checkpoint-commit** — dispatch `git-workflow --task commit-prep` to commit the changes with checkpoint tag. (**sub-agent**) Context: {issue_number: 2141}

---

## Phase 1b: SC-2 RED/GREEN — record-authorization scope gating

**Concern:** Implement SC-2 RED/GREEN for `record-authorization` spec.md frontmatter scope gating.

**SCs covered:** SC-2

**Dependencies:** Phase 1a (task files must exist)

### Item 3: SC-2 — RED/GREEN for record-authorization scope gating

- [ ] **red-phase** — dispatch `test-driven-development --task red` to write a behavioral test that verifies `record-authorization` sets `status: approved` in spec.md frontmatter when scope is `for_implementation` or higher, and does NOT set it for scopes below `for_implementation` (`for_analysis`, `for_spec`, `for_plan`). (**sub-agent**) Context: {issue_number: 2141, sc_id: SC-2}
- [ ] **z3-check-red** — dispatch `solve --task check` to validate RED test state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **red-doublecheck** — dispatch `verification-before-completion --task verify` to verify the RED test is correct and fails as expected. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-red-doublecheck** — dispatch `solve --task check` to validate RED doublecheck state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **post-red-enforcement** — dispatch `post-red-enforcement` from implementation-pipeline to enforce RED gate. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-post-red** — dispatch `solve --task check` to validate post-RED state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **green-phase** — dispatch `test-driven-development --task green` to implement the `record-authorization` task's spec.md frontmatter update logic: set `status: approved` when scope is `for_implementation` or higher; do NOT set it for `for_analysis`, `for_spec`, or `for_plan`. (**sub-agent**) Context: {issue_number: 2141, sc_id: SC-2}
- [ ] **z3-check-green** — dispatch `solve --task check` to validate GREEN state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **post-green-enforcement** — dispatch `post-green-enforcement` from implementation-pipeline to enforce GREEN gate. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-post-green** — dispatch `solve --task check` to validate post-GREEN state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **checkpoint-tag-create** — dispatch `checkpoint-tag-create` from implementation-pipeline to create a checkpoint tag for this item. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **checkpoint-commit** — dispatch `git-workflow --task commit-prep` to commit the changes with checkpoint tag. (**sub-agent**) Context: {issue_number: 2141}

---

## Phase 2: SC-3, SC-4, SC-5, SC-9 RED/GREEN

**Concern:** Implement RED/GREEN cycles for `record-authorization` comments.yaml append, issue.yaml label update, worktree commit, and `verify-recording` read-back confirmation.

**SCs covered:** SC-3, SC-4, SC-5, SC-9

**Dependencies:** Phase 1 (task files must exist)

### Item 4: SC-3 — RED/GREEN for comments.yaml authorization record

- [ ] **red-phase** — dispatch `test-driven-development --task red` to write a behavioral test that verifies `record-authorization` appends an authorization record to `comments.yaml` with authorization text, scope, timestamp, and human attribution. (**sub-agent**) Context: {issue_number: 2141, sc_id: SC-3}
- [ ] **z3-check-red** — dispatch `solve --task check` to validate RED test state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **red-doublecheck** — dispatch `verification-before-completion --task verify` to verify the RED test is correct and fails as expected. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-red-doublecheck** — dispatch `solve --task check` to validate RED doublecheck state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **post-red-enforcement** — dispatch `post-red-enforcement` from implementation-pipeline to enforce RED gate. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-post-red** — dispatch `solve --task check` to validate post-RED state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **green-phase** — dispatch `test-driven-development --task green` to implement the `record-authorization` task's `comments.yaml` append logic: write authorization text, scope, timestamp, and human attribution as a new YAML entry. Handle missing `comments.yaml` by creating it. (**sub-agent**) Context: {issue_number: 2141, sc_id: SC-3}
- [ ] **z3-check-green** — dispatch `solve --task check` to validate GREEN state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **post-green-enforcement** — dispatch `post-green-enforcement` from implementation-pipeline to enforce GREEN gate. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-post-green** — dispatch `solve --task check` to validate post-GREEN state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **checkpoint-tag-create** — dispatch `checkpoint-tag-create` from implementation-pipeline to create a checkpoint tag for this item. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **checkpoint-commit** — dispatch `git-workflow --task commit-prep` to commit the changes with checkpoint tag. (**sub-agent**) Context: {issue_number: 2141}

### Item 5: SC-4 — RED/GREEN for issue.yaml label update

- [ ] **red-phase** — dispatch `test-driven-development --task red` to write a behavioral test that verifies `record-authorization` updates `issue.yaml` with the `approved-for-{scope}` label. (**sub-agent**) Context: {issue_number: 2141, sc_id: SC-4}
- [ ] **z3-check-red** — dispatch `solve --task check` to validate RED test state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **red-doublecheck** — dispatch `verification-before-completion --task verify` to verify the RED test is correct and fails as expected. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-red-doublecheck** — dispatch `solve --task check` to validate RED doublecheck state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **post-red-enforcement** — dispatch `post-red-enforcement` from implementation-pipeline to enforce RED gate. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-post-red** — dispatch `solve --task check` to validate post-RED state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **green-phase** — dispatch `test-driven-development --task green` to implement the `record-authorization` task's `issue.yaml` label update logic: add `approved-for-{scope}` to the labels array. (**sub-agent**) Context: {issue_number: 2141, sc_id: SC-4}
- [ ] **z3-check-green** — dispatch `solve --task check` to validate GREEN state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **post-green-enforcement** — dispatch `post-green-enforcement` from implementation-pipeline to enforce GREEN gate. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-post-green** — dispatch `solve --task check` to validate post-GREEN state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **checkpoint-tag-create** — dispatch `checkpoint-tag-create` from implementation-pipeline to create a checkpoint tag for this item. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **checkpoint-commit** — dispatch `git-workflow --task commit-prep` to commit the changes with checkpoint tag. (**sub-agent**) Context: {issue_number: 2141}

### Item 6: SC-5 — RED/GREEN for worktree commit

- [ ] **red-phase** — dispatch `test-driven-development --task red` to write a behavioral test that verifies `record-authorization` commits the `.issues/` worktree changes after writing all three files. (**sub-agent**) Context: {issue_number: 2141, sc_id: SC-5}
- [ ] **z3-check-red** — dispatch `solve --task check` to validate RED test state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **red-doublecheck** — dispatch `verification-before-completion --task verify` to verify the RED test is correct and fails as expected. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-red-doublecheck** — dispatch `solve --task check` to validate RED doublecheck state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **post-red-enforcement** — dispatch `post-red-enforcement` from implementation-pipeline to enforce RED gate. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-post-red** — dispatch `solve --task check` to validate post-RED state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **green-phase** — dispatch `test-driven-development --task green` to implement the `record-authorization` task's worktree commit logic: run `git -C .issues/ add -A && git -C .issues/ commit -m` after writing all three files. Handle commit failure with BLOCKED + COMMIT_FAILED reason. Handle concurrent authorization attempts by re-reading state and checking compatibility. (**sub-agent**) Context: {issue_number: 2141, sc_id: SC-5}
- [ ] **z3-check-green** — dispatch `solve --task check` to validate GREEN state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **post-green-enforcement** — dispatch `post-green-enforcement` from implementation-pipeline to enforce GREEN gate. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-post-green** — dispatch `solve --task check` to validate post-GREEN state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **checkpoint-tag-create** — dispatch `checkpoint-tag-create` from implementation-pipeline to create a checkpoint tag for this item. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **checkpoint-commit** — dispatch `git-workflow --task commit-prep` to commit the changes with checkpoint tag. (**sub-agent**) Context: {issue_number: 2141}

### Item 7: SC-9 — RED/GREEN for verify-recording read-back

- [ ] **red-phase** — dispatch `test-driven-development --task red` to write a behavioral test that verifies `verify-recording` returns PASS when spec.md has `status: approved`, comments.yaml has the authorization record, and issue.yaml has the label. Verify it returns BLOCKED with specific reason when any of the three is missing or corrupted. (**sub-agent**) Context: {issue_number: 2141, sc_id: SC-9}
- [ ] **z3-check-red** — dispatch `solve --task check` to validate RED test state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **red-doublecheck** — dispatch `verification-before-completion --task verify` to verify the RED test is correct and fails as expected. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-red-doublecheck** — dispatch `solve --task check` to validate RED doublecheck state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **post-red-enforcement** — dispatch `post-red-enforcement` from implementation-pipeline to enforce RED gate. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-post-red** — dispatch `solve --task check` to validate post-RED state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **green-phase** — dispatch `test-driven-development --task green` to implement the `verify-recording` task: read spec.md frontmatter for `status: approved`, read comments.yaml for the authorization record, read issue.yaml for the label. Return PASS if all three match. Return BLOCKED with specific reason if any are missing or corrupted. Handle edge cases: malformed frontmatter (BLOCKED + MALFORMED_FRONTMATTER), missing comments.yaml (BLOCKED + MISSING_COMMENTS), missing issue.yaml (BLOCKED + MISSING_ISSUE_YAML), missing worktree (BLOCKED + ISSUES_WORKTREE_NOT_INITIALIZED). (**sub-agent**) Context: {issue_number: 2141, sc_id: SC-9}
- [ ] **z3-check-green** — dispatch `solve --task check` to validate GREEN state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **post-green-enforcement** — dispatch `post-green-enforcement` from implementation-pipeline to enforce GREEN gate. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-post-green** — dispatch `solve --task check` to validate post-GREEN state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **checkpoint-tag-create** — dispatch `checkpoint-tag-create` from implementation-pipeline to create a checkpoint tag for this item. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **checkpoint-commit** — dispatch `git-workflow --task commit-prep` to commit the changes with checkpoint tag. (**sub-agent**) Context: {issue_number: 2141}

---

## Phase 3: Workflow Reordering in SKILL.md

**Concern:** Reorder all three workflows (fast-path, full-path, gap-fill-path) in `approval-gate-scope/SKILL.md` to the record-then-verify pattern. Insert `record-authorization` at position 2 (after `scope-auto-resolve`), replace `verify-explicit-authorization` with `verify-recording` at position 3, move `apply-label` to position 4.

**SCs covered:** SC-6, SC-7, SC-10, SC-11, SC-12

**Dependencies:** Phase 1 (record-authorization.md and verify-recording.md task files must exist), Phase 2 (task implementations must exist)

### Item 8: SC-6 — RED/GREEN for fast-path workflow reordering

- [ ] **red-phase** — dispatch `test-driven-development --task red` to write a behavioral test that verifies the fast-path workflow in `approval-gate-scope/SKILL.md` shows the step order: scope-auto-resolve → record-authorization → verify-recording → apply-label → auto-dispatch. (**sub-agent**) Context: {issue_number: 2141, sc_id: SC-6}
- [ ] **z3-check-red** — dispatch `solve --task check` to validate RED test state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **red-doublecheck** — dispatch `verification-before-completion --task verify` to verify the RED test is correct and fails as expected. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-red-doublecheck** — dispatch `solve --task check` to validate RED doublecheck state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **post-red-enforcement** — dispatch `post-red-enforcement` from implementation-pipeline to enforce RED gate. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-post-red** — dispatch `solve --task check` to validate post-RED state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **green-phase** — dispatch `test-driven-development --task green` to reorder the fast-path workflow in `approval-gate-scope/SKILL.md` to: scope-auto-resolve → record-authorization → verify-recording → apply-label → auto-dispatch. (**sub-agent**) Context: {issue_number: 2141, sc_id: SC-6}
- [ ] **z3-check-green** — dispatch `solve --task check` to validate GREEN state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **post-green-enforcement** — dispatch `post-green-enforcement` from implementation-pipeline to enforce GREEN gate. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-post-green** — dispatch `solve --task check` to validate post-GREEN state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **checkpoint-tag-create** — dispatch `checkpoint-tag-create` from implementation-pipeline to create a checkpoint tag for this item. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **checkpoint-commit** — dispatch `git-workflow --task commit-prep` to commit the changes with checkpoint tag. (**sub-agent**) Context: {issue_number: 2141}

### Item 9: SC-7 — RED/GREEN for full-path workflow reordering

- [ ] **red-phase** — dispatch `test-driven-development --task red` to write a behavioral test that verifies the full-path workflow in `approval-gate-scope/SKILL.md` shows `record-authorization` at position 2 and `verify-recording` at position 3. (**sub-agent**) Context: {issue_number: 2141, sc_id: SC-7}
- [ ] **z3-check-red** — dispatch `solve --task check` to validate RED test state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **red-doublecheck** — dispatch `verification-before-completion --task verify` to verify the RED test is correct and fails as expected. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-red-doublecheck** — dispatch `solve --task check` to validate RED doublecheck state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **post-red-enforcement** — dispatch `post-red-enforcement` from implementation-pipeline to enforce RED gate. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-post-red** — dispatch `solve --task check` to validate post-RED state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **green-phase** — dispatch `test-driven-development --task green` to reorder the full-path workflow in `approval-gate-scope/SKILL.md` to: scope-auto-resolve → record-authorization → verify-recording → apply-label → item-decomposition → SC-traceability → sub-issues → spec-to-plan-cascade → gap-fill-cascade → verify-codebase → verify-blockers → verify-closed-issue → verify-already-implemented → auto-dispatch. (**sub-agent**) Context: {issue_number: 2141, sc_id: SC-7}
- [ ] **z3-check-green** — dispatch `solve --task check` to validate GREEN state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **post-green-enforcement** — dispatch `post-green-enforcement` from implementation-pipeline to enforce GREEN gate. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-post-green** — dispatch `solve --task check` to validate post-GREEN state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **checkpoint-tag-create** — dispatch `checkpoint-tag-create` from implementation-pipeline to create a checkpoint tag for this item. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **checkpoint-commit** — dispatch `git-workflow --task commit-prep` to commit the changes with checkpoint tag. (**sub-agent**) Context: {issue_number: 2141}

### Item 10: SC-10 — RED/GREEN for apply-label position

- [ ] **red-phase** — dispatch `test-driven-development --task red` to write a behavioral test that verifies `apply-label` is dispatched after `verify-recording` (step 4, not step 3) in both fast-path and full-path workflows in `approval-gate-scope/SKILL.md`. (**sub-agent**) Context: {issue_number: 2141, sc_id: SC-10}
- [ ] **z3-check-red** — dispatch `solve --task check` to validate RED test state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **red-doublecheck** — dispatch `verification-before-completion --task verify` to verify the RED test is correct and fails as expected. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-red-doublecheck** — dispatch `solve --task check` to validate RED doublecheck state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **post-red-enforcement** — dispatch `post-red-enforcement` from implementation-pipeline to enforce RED gate. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-post-red** — dispatch `solve --task check` to validate post-RED state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **green-phase** — dispatch `test-driven-development --task green` to move the `apply-label` step to position 4 (after `record-authorization` and `verify-recording`) in all three workflows in `approval-gate-scope/SKILL.md`. (**sub-agent**) Context: {issue_number: 2141, sc_id: SC-10}
- [ ] **z3-check-green** — dispatch `solve --task check` to validate GREEN state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **post-green-enforcement** — dispatch `post-green-enforcement` from implementation-pipeline to enforce GREEN gate. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-post-green** — dispatch `solve --task check` to validate post-GREEN state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **checkpoint-tag-create** — dispatch `checkpoint-tag-create` from implementation-pipeline to create a checkpoint tag for this item. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **checkpoint-commit** — dispatch `git-workflow --task commit-prep` to commit the changes with checkpoint tag. (**sub-agent**) Context: {issue_number: 2141}

### Item 11: SC-11 — RED/GREEN for gap-fill-path workflow reordering

- [ ] **red-phase** — dispatch `test-driven-development --task red` to write a behavioral test that verifies the gap-fill-path workflow in `approval-gate-scope/SKILL.md` shows `record-authorization` at position 2 and `verify-recording` at position 3. (**sub-agent**) Context: {issue_number: 2141, sc_id: SC-11}
- [ ] **z3-check-red** — dispatch `solve --task check` to validate RED test state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **red-doublecheck** — dispatch `verification-before-completion --task verify` to verify the RED test is correct and fails as expected. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-red-doublecheck** — dispatch `solve --task check` to validate RED doublecheck state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **post-red-enforcement** — dispatch `post-red-enforcement` from implementation-pipeline to enforce RED gate. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-post-red** — dispatch `solve --task check` to validate post-RED state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **green-phase** — dispatch `test-driven-development --task green` to reorder the gap-fill-path workflow in `approval-gate-scope/SKILL.md` to: scope-auto-resolve → record-authorization → verify-recording → gap-fill-cascade → auto-dispatch. (**sub-agent**) Context: {issue_number: 2141, sc_id: SC-11}
- [ ] **z3-check-green** — dispatch `solve --task check` to validate GREEN state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **post-green-enforcement** — dispatch `post-green-enforcement` from implementation-pipeline to enforce GREEN gate. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-post-green** — dispatch `solve --task check` to validate post-GREEN state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **checkpoint-tag-create** — dispatch `checkpoint-tag-create` from implementation-pipeline to create a checkpoint tag for this item. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **checkpoint-commit** — dispatch `git-workflow --task commit-prep` to commit the changes with checkpoint tag. (**sub-agent**) Context: {issue_number: 2141}

### Item 12: SC-12 — RED/GREEN for record-authorization as step 2 in all workflows

- [ ] **red-phase** — dispatch `test-driven-development --task red` to write a behavioral test that verifies `record-authorization` is step 2 (immediately after `scope-auto-resolve`) in all three workflows (fast-path, gap-fill-path, full-path) in `approval-gate-scope/SKILL.md`. (**sub-agent**) Context: {issue_number: 2141, sc_id: SC-12}
- [ ] **z3-check-red** — dispatch `solve --task check` to validate RED test state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **red-doublecheck** — dispatch `verification-before-completion --task verify` to verify the RED test is correct and fails as expected. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-red-doublecheck** — dispatch `solve --task check` to validate RED doublecheck state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **post-red-enforcement** — dispatch `post-red-enforcement` from implementation-pipeline to enforce RED gate. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-post-red** — dispatch `solve --task check` to validate post-RED state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **green-phase** — dispatch `test-driven-development --task green` to verify and ensure `record-authorization` is step 2 (immediately after `scope-auto-resolve`) in all three workflows in `approval-gate-scope/SKILL.md`. Fix any workflow where it is not at position 2. (**sub-agent**) Context: {issue_number: 2141, sc_id: SC-12}
- [ ] **z3-check-green** — dispatch `solve --task check` to validate GREEN state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **post-green-enforcement** — dispatch `post-green-enforcement` from implementation-pipeline to enforce GREEN gate. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-post-green** — dispatch `solve --task check` to validate post-GREEN state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **checkpoint-tag-create** — dispatch `checkpoint-tag-create` from implementation-pipeline to create a checkpoint tag for this item. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **checkpoint-commit** — dispatch `git-workflow --task commit-prep` to commit the changes with checkpoint tag. (**sub-agent**) Context: {issue_number: 2141}

---

## Phase 4: Behavioral Test Harness — source_db: MISSING

**Concern:** Implement `source_db: MISSING` in `__export_sqlite_to_yaml` when the SQLite DB is not found in the test home. Remove all production fallback paths. The evaluation pipeline must treat `source_db: MISSING` as a hard FAIL.

**SCs covered:** SC-13

**Dependencies:** Phase 1 (task files must exist for harness integration)

### Item 13: SC-13 — RED/GREEN for source_db: MISSING

- [ ] **red-phase** — dispatch `test-driven-development --task red` to write a behavioral test that verifies `__export_sqlite_to_yaml` writes `source_db: MISSING` (not `null`, not a fallback path) when the SQLite DB is not found in the test home, and does NOT fall back to production XDG paths, environment variables, or any other location. (**sub-agent**) Context: {issue_number: 2141, sc_id: SC-13}
- [ ] **z3-check-red** — dispatch `solve --task check` to validate RED test state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **red-doublecheck** — dispatch `verification-before-completion --task verify` to verify the RED test is correct and fails as expected. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-red-doublecheck** — dispatch `solve --task check` to validate RED doublecheck state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **post-red-enforcement** — dispatch `post-red-enforcement` from implementation-pipeline to enforce RED gate. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-post-red** — dispatch `solve --task check` to validate post-RED state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **green-phase** — dispatch `test-driven-development --task green` to modify `__export_sqlite_to_yaml` to write `source_db: MISSING` (not `null`, not a fallback path) when the SQLite DB is not found in the test home. Remove all production fallback paths (XDG paths, environment variables, hardcoded paths). The evaluation pipeline must treat `source_db: MISSING` as a hard FAIL — no substitution, no synthesis, no fabrication. (**sub-agent**) Context: {issue_number: 2141, sc_id: SC-13}
- [ ] **z3-check-green** — dispatch `solve --task check` to validate GREEN state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **post-green-enforcement** — dispatch `post-green-enforcement` from implementation-pipeline to enforce GREEN gate. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **z3-check-post-green** — dispatch `solve --task check` to validate post-GREEN state transition. (**inline**) Context: {issue_number: 2141, contract_path: .opencode/.issues/2141/contracts/}
- [ ] **checkpoint-tag-create** — dispatch `checkpoint-tag-create` from implementation-pipeline to create a checkpoint tag for this item. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **checkpoint-commit** — dispatch `git-workflow --task commit-prep` to commit the changes with checkpoint tag. (**sub-agent**) Context: {issue_number: 2141}

---

## Phase 5: Completion Gates

**Concern:** Run completeness gate, adversarial audit, finishing checklist, and PR creation. All 13 SCs must be verified before PR.

**SCs covered:** All (SC-1 through SC-13)

**Dependencies:** Phase 1, Phase 2, Phase 3, Phase 4 (all implementation complete)

### Item 14: Completeness gate — verify all 13 SCs covered

- [ ] **Structural checks** — dispatch `finishing-a-development-branch --task checklist` to run lint, typecheck, and structural verification across all modified files. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **Green doublecheck** — dispatch `verification-before-completion --task verify` to verify all GREEN implementations are correct. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **Verification before completion** — dispatch `verification-before-completion --task completion` to run the full VbC gate against all SCs. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **SC count gate** — dispatch `sc-count-gate` from implementation-pipeline to verify all 13 SCs have a verdict. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **Pre-PR gate** — dispatch `verification-before-completion --task verify` to check all SC verdicts — BLOCK if any FAIL. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **Rationalization check** — dispatch `verification-before-completion --task verify` to check for rationalization in any proposed action. (**sub-agent**) Context: {issue_number: 2141}

### Item 15: Audit — adversarial verification of all deliverables

- [ ] **Audit** — dispatch the appropriate audit task from `audit` skill with `{spec_local_dir: .opencode/.issues/2141/, artifact_evidence_dir: .opencode/.issues/2141/evidence/}`. If non-clean-pass, remediate and restart from audit step. `DONE_WITH_CONCERNS` is coerced to FAIL. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **Cross-validate** — dispatch `audit --task cross-validate` to produce consensus findings. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **Regression check** — dispatch `test-driven-development --task patterns` to generate regression test patterns. (**sub-agent**) Context: {issue_number: 2141}
- [ ] **Behavioral test remediation** — dispatch `behavioral-test-remediation` from implementation-pipeline if any behavioral test needs remediation. (**sub-agent**) Context: {issue_number: 2141}

### Item 16: Finishing checklist — branch readiness, pre-PR checks

- [ ] **Review prep** — dispatch `git-workflow --task review-prep` to prepare the branch for review. (**sub-agent**) Context: {issue_number: 2141}

### Item 17: PR creation

- [ ] **Create PR** — dispatch `pr-creation-workflow --task create` to create the pull request with evidence artifacts. (**sub-agent**) Context: {issue_number: 2141, authorization_scope, halt_at}
- [ ] **Completion** — dispatch `completion-core --task completion` to produce the executive summary. (**sub-agent**) Context: {issue_number: 2141}

---

## Lifecycle Events

| Timestamp | Event | Details |
|-----------|-------|---------|
| 2026-07-25T22:00:00Z | `plan_created` | Plan file at `.opencode/.issues/2141/plan.md`, 6 phases (1a, 1b, 2, 3, 4, 5), 17 items, 13 SCs |
| 2026-07-25T22:01:00Z | `plan_completed` | Plan verified, lifecycle event appended, execution strategy: 6 phases, clean-room dispatch with inline z3-check gates, pipeline signal: implementation-pipeline → TDD → finishing → audit → PR |
