---
plan_schema_version: "1.0"
issue: 2167
title: "Fix stale analytical artifacts after spec revision"
dispatch:
  - phase: 1
    skill: test-driven-development
    task: red
  - phase: 1
    skill: test-driven-development
    task: green
  - phase: 2
    skill: test-driven-development
    task: red
  - phase: 2
    skill: test-driven-development
    task: green
  - phase: 3
    skill: test-driven-development
    task: red
  - phase: 3
    skill: test-driven-development
    task: green
---

# Plan: Fix stale analytical artifacts after spec revision

## Pre-Implementation

- [ ] **Coherence gate** — dispatch `audit --task coherence-extraction` to verify spec/plan coherence before RED routing. (**sub-agent**)
  - Context: `{issue_number: 2167}`
- [ ] **Baseline check** — dispatch `implementation-pipeline --task pre-red-baseline` to verify baseline state before any RED phase. (**sub-agent**)
  - Context: `{issue_number: 2167}`

## Phase Table

| Phase | SCs | Description | Dispatch |
|-------|-----|-------------|----------|
| 1 | SC-1, SC-2 | Fix audit SKILL.md scenario (c): change from HALT to auto-delete + backfill with explicit delete instruction | test-driven-development (red/green) |
| 2 | SC-3 | Add artifact cleanup step to spec-creation/tasks/revise.md | test-driven-development (red/green) |
| 3 | SC-4, SC-5 | Verify no orphaned cross-references to old language and all 3 scenarios route to backfill uniformly | test-driven-development (red/green) |

---

## Phase 1: Fix audit SKILL.md scenario (c) [SC-1, SC-2]

### Item 1: Change audit SKILL.md scenario (c) from HALT to auto-delete + backfill [SC-1]

- [ ] **red-phase** — dispatch `test-driven-development --task red` to write a failing grep test for absence of "developer intervention is required" in scenario (c). (**sub-agent**)
  - Context: `{issue_number: 2167}`
  - SC-ID: SC-1
- [ ] **z3-check-red** — dispatch `solve --task check` to validate RED state transition. (**inline**)
  - Context: `{issue_number: 2167, contract_path: from structure artifact}`
- [ ] **red-doublecheck** — dispatch `verification-before-completion --task verify` to verify RED test correctness. (**sub-agent**)
  - Context: `{issue_number: 2167}`
- [ ] **z3-check-red-doublecheck** — dispatch `solve --task check` to validate RED-doublecheck state transition. (**inline**)
  - Context: `{issue_number: 2167, contract_path: from structure artifact}`
- [ ] **post-red-enforcement** — dispatch `implementation-pipeline --task post-red-enforcement` to enforce RED gate. (**sub-agent**)
  - Context: `{issue_number: 2167}`
- [ ] **z3-check-post-red** — dispatch `solve --task check` to validate post-RED state transition. (**inline**)
  - Context: `{issue_number: 2167, contract_path: from structure artifact}`
- [ ] **green-phase** — dispatch `test-driven-development --task green` to change audit SKILL.md scenario (c) from HALT to auto-delete + backfill. (**sub-agent**)
  - Context: `{issue_number: 2167}`
  - SC-ID: SC-1
- [ ] **z3-check-green** — dispatch `solve --task check` to validate GREEN state transition. (**inline**)
  - Context: `{issue_number: 2167, contract_path: from structure artifact}`
- [ ] **post-green-enforcement** — dispatch `implementation-pipeline --task post-green-enforcement` to enforce GREEN gate. (**sub-agent**)
  - Context: `{issue_number: 2167}`
- [ ] **z3-check-post-green** — dispatch `solve --task check` to validate post-GREEN state transition. (**inline**)
  - Context: `{issue_number: 2167, contract_path: from structure artifact}`
- [ ] **green-doublecheck** — dispatch `verification-before-completion --task verify` to verify GREEN implementation. (**sub-agent**)
  - Context: `{issue_number: 2167}`
- [ ] **checkpoint-tag-create** — dispatch `implementation-pipeline --task checkpoint-tag-create` to create checkpoint tag. (**sub-agent**)
  - Context: `{issue_number: 2167}`
- [ ] **checkpoint-commit** — dispatch `git-workflow --task commit-prep` to commit test + change together. (**sub-agent**)
  - Context: `{issue_number: 2167}`

### Item 2: Add explicit delete instruction to scenario (c) [SC-2]

- [ ] **red-phase** — dispatch `test-driven-development --task red` to write a failing grep test for "delete stale artifact" or "rm" in scenario (c). (**sub-agent**)
  - Context: `{issue_number: 2167}`
  - SC-ID: SC-2
- [ ] **z3-check-red** — dispatch `solve --task check` to validate RED state transition. (**inline**)
  - Context: `{issue_number: 2167, contract_path: from structure artifact}`
- [ ] **red-doublecheck** — dispatch `verification-before-completion --task verify` to verify RED test correctness. (**sub-agent**)
  - Context: `{issue_number: 2167}`
- [ ] **z3-check-red-doublecheck** — dispatch `solve --task check` to validate RED-doublecheck state transition. (**inline**)
  - Context: `{issue_number: 2167, contract_path: from structure artifact}`
- [ ] **post-red-enforcement** — dispatch `implementation-pipeline --task post-red-enforcement` to enforce RED gate. (**sub-agent**)
  - Context: `{issue_number: 2167}`
- [ ] **z3-check-post-red** — dispatch `solve --task check` to validate post-RED state transition. (**inline**)
  - Context: `{issue_number: 2167, contract_path: from structure artifact}`
- [ ] **green-phase** — dispatch `test-driven-development --task green` to add explicit delete instruction to scenario (c). (**sub-agent**)
  - Context: `{issue_number: 2167}`
  - SC-ID: SC-2
- [ ] **z3-check-green** — dispatch `solve --task check` to validate GREEN state transition. (**inline**)
  - Context: `{issue_number: 2167, contract_path: from structure artifact}`
- [ ] **post-green-enforcement** — dispatch `implementation-pipeline --task post-green-enforcement` to enforce GREEN gate. (**sub-agent**)
  - Context: `{issue_number: 2167}`
- [ ] **z3-check-post-green** — dispatch `solve --task check` to validate post-GREEN state transition. (**inline**)
  - Context: `{issue_number: 2167, contract_path: from structure artifact}`
- [ ] **green-doublecheck** — dispatch `verification-before-completion --task verify` to verify GREEN implementation. (**sub-agent**)
  - Context: `{issue_number: 2167}`
- [ ] **checkpoint-tag-create** — dispatch `implementation-pipeline --task checkpoint-tag-create` to create checkpoint tag. (**sub-agent**)
  - Context: `{issue_number: 2167}`
- [ ] **checkpoint-commit** — dispatch `git-workflow --task commit-prep` to commit test + change together. (**sub-agent**)
  - Context: `{issue_number: 2167}`

---

## Phase 2: Add artifact cleanup step to revise.md [SC-3]

### Item 3: Add artifact cleanup step to spec-creation/tasks/revise.md [SC-3]

- [ ] **red-phase** — dispatch `test-driven-development --task red` to write a failing grep test for "artifact" and "delete" or "clean" in revise.md. (**sub-agent**)
  - Context: `{issue_number: 2167}`
  - SC-ID: SC-3
- [ ] **z3-check-red** — dispatch `solve --task check` to validate RED state transition. (**inline**)
  - Context: `{issue_number: 2167, contract_path: from structure artifact}`
- [ ] **red-doublecheck** — dispatch `verification-before-completion --task verify` to verify RED test correctness. (**sub-agent**)
  - Context: `{issue_number: 2167}`
- [ ] **z3-check-red-doublecheck** — dispatch `solve --task check` to validate RED-doublecheck state transition. (**inline**)
  - Context: `{issue_number: 2167, contract_path: from structure artifact}`
- [ ] **post-red-enforcement** — dispatch `implementation-pipeline --task post-red-enforcement` to enforce RED gate. (**sub-agent**)
  - Context: `{issue_number: 2167}`
- [ ] **z3-check-post-red** — dispatch `solve --task check` to validate post-RED state transition. (**inline**)
  - Context: `{issue_number: 2167, contract_path: from structure artifact}`
- [ ] **green-phase** — dispatch `test-driven-development --task green` to add artifact cleanup step to spec-creation/tasks/revise.md. (**sub-agent**)
  - Context: `{issue_number: 2167}`
  - SC-ID: SC-3
- [ ] **z3-check-green** — dispatch `solve --task check` to validate GREEN state transition. (**inline**)
  - Context: `{issue_number: 2167, contract_path: from structure artifact}`
- [ ] **post-green-enforcement** — dispatch `implementation-pipeline --task post-green-enforcement` to enforce GREEN gate. (**sub-agent**)
  - Context: `{issue_number: 2167}`
- [ ] **z3-check-post-green** — dispatch `solve --task check` to validate post-GREEN state transition. (**inline**)
  - Context: `{issue_number: 2167, contract_path: from structure artifact}`
- [ ] **green-doublecheck** — dispatch `verification-before-completion --task verify` to verify GREEN implementation. (**sub-agent**)
  - Context: `{issue_number: 2167}`
- [ ] **checkpoint-tag-create** — dispatch `implementation-pipeline --task checkpoint-tag-create` to create checkpoint tag. (**sub-agent**)
  - Context: `{issue_number: 2167}`
- [ ] **checkpoint-commit** — dispatch `git-workflow --task commit-prep` to commit test + change together. (**sub-agent**)
  - Context: `{issue_number: 2167}`

---

## Phase 3: Verify no orphaned references and uniform routing [SC-4, SC-5]

### Item 4: Remove orphaned references to old "developer intervention required" language [SC-4]

- [ ] **red-phase** — dispatch `test-driven-development --task red` to write a failing grep test — grep for "developer intervention is required" across .opencode/ — expect 0 matches after changes. (**sub-agent**)
  - Context: `{issue_number: 2167}`
  - SC-ID: SC-4
- [ ] **z3-check-red** — dispatch `solve --task check` to validate RED state transition. (**inline**)
  - Context: `{issue_number: 2167, contract_path: from structure artifact}`
- [ ] **red-doublecheck** — dispatch `verification-before-completion --task verify` to verify RED test correctness. (**sub-agent**)
  - Context: `{issue_number: 2167}`
- [ ] **z3-check-red-doublecheck** — dispatch `solve --task check` to validate RED-doublecheck state transition. (**inline**)
  - Context: `{issue_number: 2167, contract_path: from structure artifact}`
- [ ] **post-red-enforcement** — dispatch `implementation-pipeline --task post-red-enforcement` to enforce RED gate. (**sub-agent**)
  - Context: `{issue_number: 2167}`
- [ ] **z3-check-post-red** — dispatch `solve --task check` to validate post-RED state transition. (**inline**)
  - Context: `{issue_number: 2167, contract_path: from structure artifact}`
- [ ] **green-phase** — dispatch `test-driven-development --task green` to remove any remaining orphaned references found. (**sub-agent**)
  - Context: `{issue_number: 2167}`
  - SC-ID: SC-4
- [ ] **z3-check-green** — dispatch `solve --task check` to validate GREEN state transition. (**inline**)
  - Context: `{issue_number: 2167, contract_path: from structure artifact}`
- [ ] **post-green-enforcement** — dispatch `implementation-pipeline --task post-green-enforcement` to enforce GREEN gate. (**sub-agent**)
  - Context: `{issue_number: 2167}`
- [ ] **z3-check-post-green** — dispatch `solve --task check` to validate post-GREEN state transition. (**inline**)
  - Context: `{issue_number: 2167, contract_path: from structure artifact}`
- [ ] **green-doublecheck** — dispatch `verification-before-completion --task verify` to verify GREEN implementation. (**sub-agent**)
  - Context: `{issue_number: 2167}`
- [ ] **checkpoint-tag-create** — dispatch `implementation-pipeline --task checkpoint-tag-create` to create checkpoint tag. (**sub-agent**)
  - Context: `{issue_number: 2167}`
- [ ] **checkpoint-commit** — dispatch `git-workflow --task commit-prep` to commit test + change together. (**sub-agent**)
  - Context: `{issue_number: 2167}`

### Item 5: Verify all 3 scenarios route to backfill uniformly [SC-5]

- [ ] **red-phase** — dispatch `test-driven-development --task red` to write a failing semantic test — clean-room sub-agent reads all 3 scenarios, verifies they do NOT all route to backfill. (**sub-agent**)
  - Context: `{issue_number: 2167}`
  - SC-ID: SC-5
- [ ] **z3-check-red** — dispatch `solve --task check` to validate RED state transition. (**inline**)
  - Context: `{issue_number: 2167, contract_path: from structure artifact}`
- [ ] **red-doublecheck** — dispatch `verification-before-completion --task verify` to verify RED test correctness. (**sub-agent**)
  - Context: `{issue_number: 2167}`
- [ ] **z3-check-red-doublecheck** — dispatch `solve --task check` to validate RED-doublecheck state transition. (**inline**)
  - Context: `{issue_number: 2167, contract_path: from structure artifact}`
- [ ] **post-red-enforcement** — dispatch `implementation-pipeline --task post-red-enforcement` to enforce RED gate. (**sub-agent**)
  - Context: `{issue_number: 2167}`
- [ ] **z3-check-post-red** — dispatch `solve --task check` to validate post-RED state transition. (**inline**)
  - Context: `{issue_number: 2167, contract_path: from structure artifact}`
- [ ] **green-phase** — dispatch `test-driven-development --task green` to ensure scenario (a) and (b) already route to backfill; scenario (c) changed in Phase 1 to also route to backfill. (**sub-agent**)
  - Context: `{issue_number: 2167}`
  - SC-ID: SC-5
- [ ] **z3-check-green** — dispatch `solve --task check` to validate GREEN state transition. (**inline**)
  - Context: `{issue_number: 2167, contract_path: from structure artifact}`
- [ ] **post-green-enforcement** — dispatch `implementation-pipeline --task post-green-enforcement` to enforce GREEN gate. (**sub-agent**)
  - Context: `{issue_number: 2167}`
- [ ] **z3-check-post-green** — dispatch `solve --task check` to validate post-GREEN state transition. (**inline**)
  - Context: `{issue_number: 2167, contract_path: from structure artifact}`
- [ ] **green-doublecheck** — dispatch `verification-before-completion --task verify` to verify GREEN implementation — clean-room sub-agent reads all 3 scenarios, confirms all route to backfill. (**sub-agent**)
  - Context: `{issue_number: 2167}`
- [ ] **checkpoint-tag-create** — dispatch `implementation-pipeline --task checkpoint-tag-create` to create checkpoint tag. (**sub-agent**)
  - Context: `{issue_number: 2167}`
- [ ] **checkpoint-commit** — dispatch `git-workflow --task commit-prep` to commit test + change together. (**sub-agent**)
  - Context: `{issue_number: 2167}`

---

## Post-Implementation

- [ ] **Structural checks** — dispatch `finishing-a-development-branch --task checklist` to run lint/typecheck. (**sub-agent**)
  - Context: `{issue_number: 2167}`
- [ ] **Verification before completion** — dispatch `verification-before-completion --task completion` to verify all SCs. (**sub-agent**)
  - Context: `{issue_number: 2167}`
- [ ] **SC count gate** — dispatch `implementation-pipeline --task sc-count-gate` to verify all 5 SCs have verdicts. (**sub-agent**)
  - Context: `{issue_number: 2167}`
- [ ] **Pre-PR gate** — dispatch `verification-before-completion --task verify` to check all SC verdicts — BLOCK if any FAIL. (**sub-agent**)
  - Context: `{issue_number: 2167}`
- [ ] **Audit** — dispatch appropriate audit task from audit skill. (**sub-agent**)
  - Context: `{issue_number: 2167, spec_local_dir: .opencode/.issues/2167, artifact_evidence_dir: .opencode/.issues/2167/artifacts}`
- [ ] **Cross-validate** — dispatch `audit --task cross-validate` for consensus check. (**sub-agent**)
  - Context: `{issue_number: 2167}`
- [ ] **Regression check** — dispatch `test-driven-development --task patterns` for regression test patterns. (**sub-agent**)
  - Context: `{issue_number: 2167}`
- [ ] **Review prep** — dispatch `git-workflow --task review-prep` to prepare PR review. (**sub-agent**)
  - Context: `{issue_number: 2167}`
- [ ] **Create PR** — dispatch `pr-creation-workflow --task create` to create pull request. (**sub-agent**)
  - Context: `{issue_number: 2167, authorization_scope: for_pr, halt_at: pr_created}`
- [ ] **Completion** — dispatch `completion-core --task completion` for executive summary. (**sub-agent**)
  - Context: `{issue_number: 2167}`

---

## Exit Criteria

| SC | Phase | Verification Method |
|----|-------|-------------------|
| SC-1 | 1 | grep for absence of 'developer intervention is required' in audit SKILL.md scenario (c) |
| SC-2 | 1 | grep for 'delete stale artifact' or 'rm' in audit SKILL.md scenario (c) |
| SC-3 | 2 | grep for 'artifact' and 'delete' or 'clean' in spec-creation/tasks/revise.md |
| SC-4 | 3 | grep for 'developer intervention is required' across .opencode/ — only expected matches remain |
| SC-5 | 3 | Read all 3 scenarios, verify they all route to backfill |

---

## Lifecycle Events

| Timestamp | Event | Details |
|-----------|-------|---------|
| 2026-07-27T20:20:00Z | plan_created | Plan file at `.opencode/.issues/2167/plan.md`, 3 phases, 5 SCs |
