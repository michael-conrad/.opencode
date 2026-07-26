---
plan_schema_version: "1.0"
issue: 2144
title: "Add per-SC triplet integrity checks to writing-plans pipeline"
dispatch:
  - phase: 1
    skill: test-driven-development
    task: red
  - phase: 2
    skill: test-driven-development
    task: red
  - phase: 3
    skill: test-driven-development
    task: patterns
---

# Plan: Add per-SC triplet integrity checks to writing-plans pipeline

## Pre-Implementation

- [ ] **Coherence gate.** Dispatch `sc-coherence-gate` from implementation-pipeline. Verify spec/plan coherence before RED routing. (**sub-agent**)
  - Context: `{issue_number: 2144}`
- [ ] **Baseline check.** Dispatch `pre-red-baseline` from implementation-pipeline. Verify clean working tree, trunk tip currency, and submodule state. (**sub-agent**)
  - Context: `{issue_number: 2144}`

## Phase 1 — Add triplet co-location + cross-phase dependency checks to structure.md

**Concerns:** triplet-co-location, cross-phase-dependency
**SC coverage:** SC-1, SC-2, SC-5
**Files:** `.opencode/skills/writing-plans/tasks/structure.md`

### Item 1 — SC-1: structure.md rejects phase decomposition where any SC's RED and GREEN are in different phases

- [ ] **RED phase.** Dispatch `red-phase` from implementation-pipeline. Write a behavioral enforcement test that sends a prompt triggering the structure task on a spec with split SCs and asserts stderr shows BLOCKED. (**clean-room**)
  - Context: `{issue_number: 2144, sc: SC-1, evidence_type: behavioral}`
- [ ] **Z3 check RED.** Dispatch `z3-check-red` from implementation-pipeline. Validate RED step state transition. (**inline**)
  - Context: `{issue_number: 2144, contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **RED doublecheck.** Dispatch `red-doublecheck` from implementation-pipeline. Verify RED test is correct and fails as expected. (**clean-room**)
  - Context: `{issue_number: 2144}`
- [ ] **Z3 check RED doublecheck.** Dispatch `z3-check-red-doublecheck` from implementation-pipeline. Validate RED doublecheck state transition. (**inline**)
  - Context: `{issue_number: 2144, contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Post-RED enforcement.** Dispatch `post-red-enforcement` from implementation-pipeline. Verify RED gate passes. (**clean-room**)
  - Context: `{issue_number: 2144}`
- [ ] **Z3 check post-RED.** Dispatch `z3-check-post-red` from implementation-pipeline. Validate post-RED state transition. (**inline**)
  - Context: `{issue_number: 2144, contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **GREEN phase.** Dispatch `green-phase` from implementation-pipeline. Add the triplet co-location check to `structure.md` procedure: reject any phase decomposition where a single SC's RED, GREEN, and COMMIT steps are not all in the same phase. (**clean-room**)
  - Context: `{issue_number: 2144, sc: SC-1, evidence_type: behavioral, files: [".opencode/skills/writing-plans/tasks/structure.md"]}`
- [ ] **Z3 check GREEN.** Dispatch `z3-check-green` from implementation-pipeline. Validate GREEN step state transition. (**inline**)
  - Context: `{issue_number: 2144, contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Post-GREEN enforcement.** Dispatch `post-green-enforcement` from implementation-pipeline. Verify GREEN gate passes. (**clean-room**)
  - Context: `{issue_number: 2144}`
- [ ] **Z3 check post-GREEN.** Dispatch `z3-check-post-green` from implementation-pipeline. Validate post-GREEN state transition. (**inline**)
  - Context: `{issue_number: 2144, contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Create checkpoint tag.** Dispatch `checkpoint-tag-create` from implementation-pipeline. Create checkpoint tag for this item's PASS state. (**clean-room**)
  - Context: `{issue_number: 2144, phase: 1, item: 1}`
- [ ] **Checkpoint commit.** Dispatch `checkpoint-commit` from implementation-pipeline. Commit RED test + GREEN implementation together. (**clean-room**)
  - Context: `{issue_number: 2144}`

### Item 2 — SC-2: structure.md rejects phase decomposition where a RED test depends on uncommitted SC output

- [ ] **RED phase.** Dispatch `red-phase` from implementation-pipeline. Write a behavioral enforcement test that sends a prompt triggering the structure task on a spec with cross-phase RED dependency and asserts stderr shows BLOCKED. (**clean-room**)
  - Context: `{issue_number: 2144, sc: SC-2, evidence_type: behavioral}`
- [ ] **Z3 check RED.** Dispatch `z3-check-red` from implementation-pipeline. Validate RED step state transition. (**inline**)
  - Context: `{issue_number: 2144, contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **RED doublecheck.** Dispatch `red-doublecheck` from implementation-pipeline. Verify RED test is correct and fails as expected. (**clean-room**)
  - Context: `{issue_number: 2144}`
- [ ] **Z3 check RED doublecheck.** Dispatch `z3-check-red-doublecheck` from implementation-pipeline. Validate RED doublecheck state transition. (**inline**)
  - Context: `{issue_number: 2144, contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Post-RED enforcement.** Dispatch `post-red-enforcement` from implementation-pipeline. Verify RED gate passes. (**clean-room**)
  - Context: `{issue_number: 2144}`
- [ ] **Z3 check post-RED.** Dispatch `z3-check-post-red` from implementation-pipeline. Validate post-RED state transition. (**inline**)
  - Context: `{issue_number: 2144, contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **GREEN phase.** Dispatch `green-phase` from implementation-pipeline. Add the cross-phase dependency check to `structure.md` procedure: reject any phase decomposition where a RED test depends on SC output not yet committed in the same phase. (**clean-room**)
  - Context: `{issue_number: 2144, sc: SC-2, evidence_type: behavioral, files: [".opencode/skills/writing-plans/tasks/structure.md"]}`
- [ ] **Z3 check GREEN.** Dispatch `z3-check-green` from implementation-pipeline. Validate GREEN step state transition. (**inline**)
  - Context: `{issue_number: 2144, contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Post-GREEN enforcement.** Dispatch `post-green-enforcement` from implementation-pipeline. Verify GREEN gate passes. (**clean-room**)
  - Context: `{issue_number: 2144}`
- [ ] **Z3 check post-GREEN.** Dispatch `z3-check-post-green` from implementation-pipeline. Validate post-GREEN state transition. (**inline**)
  - Context: `{issue_number: 2144, contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Create checkpoint tag.** Dispatch `checkpoint-tag-create` from implementation-pipeline. Create checkpoint tag for this item's PASS state. (**clean-room**)
  - Context: `{issue_number: 2144, phase: 1, item: 2}`
- [ ] **Checkpoint commit.** Dispatch `checkpoint-commit` from implementation-pipeline. Commit RED test + GREEN implementation together. (**clean-room**)
  - Context: `{issue_number: 2144}`

### Item 5 — SC-5: structure.md documents the triplet integrity rule in its procedure

- [ ] **GREEN phase.** Dispatch `green-phase` from implementation-pipeline. Add the triplet integrity rule text to `structure.md` procedure: "Each SC's RED, GREEN, and COMMIT steps MUST be in the same phase. No SC may have its test in one phase and its implementation in another." (**clean-room**)
  - Context: `{issue_number: 2144, sc: SC-5, evidence_type: string, files: [".opencode/skills/writing-plans/tasks/structure.md"]}`
- [ ] **Z3 check GREEN.** Dispatch `z3-check-green` from implementation-pipeline. Validate GREEN step state transition. (**inline**)
  - Context: `{issue_number: 2144, contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Post-GREEN enforcement.** Dispatch `post-green-enforcement` from implementation-pipeline. Verify GREEN gate passes. (**clean-room**)
  - Context: `{issue_number: 2144}`
- [ ] **Z3 check post-GREEN.** Dispatch `z3-check-post-green` from implementation-pipeline. Validate post-GREEN state transition. (**inline**)
  - Context: `{issue_number: 2144, contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Create checkpoint tag.** Dispatch `checkpoint-tag-create` from implementation-pipeline. Create checkpoint tag for this item's PASS state. (**clean-room**)
  - Context: `{issue_number: 2144, phase: 1, item: 5}`
- [ ] **Checkpoint commit.** Dispatch `checkpoint-commit` from implementation-pipeline. Commit GREEN implementation. (**clean-room**)
  - Context: `{issue_number: 2144}`

## Phase 2 — Add triplet split detection to self-review.md and validate.md

**Concerns:** self-review-detection, validate-detection
**SC coverage:** SC-3, SC-4, SC-6, SC-7
**Files:** `.opencode/skills/writing-plans/tasks/self-review.md`, `.opencode/skills/writing-plans/tasks/validate.md`

### Item 3 — SC-3: self-review.md detects and BLOCKs on any SC whose RED/GREEN/COMMIT steps are split across phases

- [ ] **RED phase.** Dispatch `red-phase` from implementation-pipeline. Write a behavioral enforcement test that sends a prompt triggering self-review on a plan with split SCs and asserts stderr shows SELF_REVIEW_FAILED. (**clean-room**)
  - Context: `{issue_number: 2144, sc: SC-3, evidence_type: behavioral}`
- [ ] **Z3 check RED.** Dispatch `z3-check-red` from implementation-pipeline. Validate RED step state transition. (**inline**)
  - Context: `{issue_number: 2144, contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **RED doublecheck.** Dispatch `red-doublecheck` from implementation-pipeline. Verify RED test is correct and fails as expected. (**clean-room**)
  - Context: `{issue_number: 2144}`
- [ ] **Z3 check RED doublecheck.** Dispatch `z3-check-red-doublecheck` from implementation-pipeline. Validate RED doublecheck state transition. (**inline**)
  - Context: `{issue_number: 2144, contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Post-RED enforcement.** Dispatch `post-red-enforcement` from implementation-pipeline. Verify RED gate passes. (**clean-room**)
  - Context: `{issue_number: 2144}`
- [ ] **Z3 check post-RED.** Dispatch `z3-check-post-red` from implementation-pipeline. Validate post-RED state transition. (**inline**)
  - Context: `{issue_number: 2144, contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **GREEN phase.** Dispatch `green-phase` from implementation-pipeline. Add triplet split detection to `self-review.md` procedure: detect and BLOCK on any SC whose RED/GREEN/COMMIT steps are split across phases. (**clean-room**)
  - Context: `{issue_number: 2144, sc: SC-3, evidence_type: behavioral, files: [".opencode/skills/writing-plans/tasks/self-review.md"]}`
- [ ] **Z3 check GREEN.** Dispatch `z3-check-green` from implementation-pipeline. Validate GREEN step state transition. (**inline**)
  - Context: `{issue_number: 2144, contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Post-GREEN enforcement.** Dispatch `post-green-enforcement` from implementation-pipeline. Verify GREEN gate passes. (**clean-room**)
  - Context: `{issue_number: 2144}`
- [ ] **Z3 check post-GREEN.** Dispatch `z3-check-post-green` from implementation-pipeline. Validate post-GREEN state transition. (**inline**)
  - Context: `{issue_number: 2144, contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Create checkpoint tag.** Dispatch `checkpoint-tag-create` from implementation-pipeline. Create checkpoint tag for this item's PASS state. (**clean-room**)
  - Context: `{issue_number: 2144, phase: 2, item: 3}`
- [ ] **Checkpoint commit.** Dispatch `checkpoint-commit` from implementation-pipeline. Commit RED test + GREEN implementation together. (**clean-room**)
  - Context: `{issue_number: 2144}`

### Item 4 — SC-4: validate.md detects and FAILs on any SC whose RED/GREEN/COMMIT steps are split across phases

- [ ] **RED phase.** Dispatch `red-phase` from implementation-pipeline. Write a behavioral enforcement test that sends a prompt triggering validate on a plan with split SCs and asserts stderr shows FAIL. (**clean-room**)
  - Context: `{issue_number: 2144, sc: SC-4, evidence_type: behavioral}`
- [ ] **Z3 check RED.** Dispatch `z3-check-red` from implementation-pipeline. Validate RED step state transition. (**inline**)
  - Context: `{issue_number: 2144, contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **RED doublecheck.** Dispatch `red-doublecheck` from implementation-pipeline. Verify RED test is correct and fails as expected. (**clean-room**)
  - Context: `{issue_number: 2144}`
- [ ] **Z3 check RED doublecheck.** Dispatch `z3-check-red-doublecheck` from implementation-pipeline. Validate RED doublecheck state transition. (**inline**)
  - Context: `{issue_number: 2144, contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Post-RED enforcement.** Dispatch `post-red-enforcement` from implementation-pipeline. Verify RED gate passes. (**clean-room**)
  - Context: `{issue_number: 2144}`
- [ ] **Z3 check post-RED.** Dispatch `z3-check-post-red` from implementation-pipeline. Validate post-RED state transition. (**inline**)
  - Context: `{issue_number: 2144, contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **GREEN phase.** Dispatch `green-phase` from implementation-pipeline. Add triplet split detection to `validate.md` procedure: detect and FAIL on any SC whose RED/GREEN/COMMIT steps are split across phases. (**clean-room**)
  - Context: `{issue_number: 2144, sc: SC-4, evidence_type: behavioral, files: [".opencode/skills/writing-plans/tasks/validate.md"]}`
- [ ] **Z3 check GREEN.** Dispatch `z3-check-green` from implementation-pipeline. Validate GREEN step state transition. (**inline**)
  - Context: `{issue_number: 2144, contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Post-GREEN enforcement.** Dispatch `post-green-enforcement` from implementation-pipeline. Verify GREEN gate passes. (**clean-room**)
  - Context: `{issue_number: 2144}`
- [ ] **Z3 check post-GREEN.** Dispatch `z3-check-post-green` from implementation-pipeline. Validate post-GREEN state transition. (**inline**)
  - Context: `{issue_number: 2144, contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Create checkpoint tag.** Dispatch `checkpoint-tag-create` from implementation-pipeline. Create checkpoint tag for this item's PASS state. (**clean-room**)
  - Context: `{issue_number: 2144, phase: 2, item: 4}`
- [ ] **Checkpoint commit.** Dispatch `checkpoint-commit` from implementation-pipeline. Commit RED test + GREEN implementation together. (**clean-room**)
  - Context: `{issue_number: 2144}`

### Item 6 — SC-6: self-review.md documents the triplet integrity check in its procedure

- [ ] **GREEN phase.** Dispatch `green-phase` from implementation-pipeline. Add the triplet integrity check documentation to `self-review.md` procedure. (**clean-room**)
  - Context: `{issue_number: 2144, sc: SC-6, evidence_type: string, files: [".opencode/skills/writing-plans/tasks/self-review.md"]}`
- [ ] **Z3 check GREEN.** Dispatch `z3-check-green` from implementation-pipeline. Validate GREEN step state transition. (**inline**)
  - Context: `{issue_number: 2144, contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Post-GREEN enforcement.** Dispatch `post-green-enforcement` from implementation-pipeline. Verify GREEN gate passes. (**clean-room**)
  - Context: `{issue_number: 2144}`
- [ ] **Z3 check post-GREEN.** Dispatch `z3-check-post-green` from implementation-pipeline. Validate post-GREEN state transition. (**inline**)
  - Context: `{issue_number: 2144, contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Create checkpoint tag.** Dispatch `checkpoint-tag-create` from implementation-pipeline. Create checkpoint tag for this item's PASS state. (**clean-room**)
  - Context: `{issue_number: 2144, phase: 2, item: 6}`
- [ ] **Checkpoint commit.** Dispatch `checkpoint-commit` from implementation-pipeline. Commit GREEN implementation. (**clean-room**)
  - Context: `{issue_number: 2144}`

### Item 7 — SC-7: validate.md documents the triplet integrity check in its procedure

- [ ] **GREEN phase.** Dispatch `green-phase` from implementation-pipeline. Add the triplet integrity check documentation to `validate.md` procedure. (**clean-room**)
  - Context: `{issue_number: 2144, sc: SC-7, evidence_type: string, files: [".opencode/skills/writing-plans/tasks/validate.md"]}`
- [ ] **Z3 check GREEN.** Dispatch `z3-check-green` from implementation-pipeline. Validate GREEN step state transition. (**inline**)
  - Context: `{issue_number: 2144, contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Post-GREEN enforcement.** Dispatch `post-green-enforcement` from implementation-pipeline. Verify GREEN gate passes. (**clean-room**)
  - Context: `{issue_number: 2144}`
- [ ] **Z3 check post-GREEN.** Dispatch `z3-check-post-green` from implementation-pipeline. Validate post-GREEN state transition. (**inline**)
  - Context: `{issue_number: 2144, contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Create checkpoint tag.** Dispatch `checkpoint-tag-create` from implementation-pipeline. Create checkpoint tag for this item's PASS state. (**clean-room**)
  - Context: `{issue_number: 2144, phase: 2, item: 7}`
- [ ] **Checkpoint commit.** Dispatch `checkpoint-commit` from implementation-pipeline. Commit GREEN implementation. (**clean-room**)
  - Context: `{issue_number: 2144}`

## Phase 3 — Create behavioral enforcement test

**Concerns:** behavioral-test
**SC coverage:** SC-8
**Files:** `.opencode/tests-v2/behaviors/`

### Item 8 — SC-8: Behavioral enforcement test verifies triplet integrity check fires on a defective plan

- [ ] **Patterns phase.** Dispatch `regression-check` from implementation-pipeline. Write a behavioral enforcement test that sends a prompt producing a plan with split SCs and asserts stderr shows BLOCKED/FAIL. (**clean-room**)
  - Context: `{issue_number: 2144, sc: SC-8, evidence_type: behavioral, files: [".opencode/tests-v2/behaviors/"]}`
- [ ] **Z3 check patterns.** Dispatch `z3-check-green` from implementation-pipeline. Validate patterns step state transition. (**inline**)
  - Context: `{issue_number: 2144, contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Post-patterns enforcement.** Dispatch `post-green-enforcement` from implementation-pipeline. Verify patterns gate passes. (**clean-room**)
  - Context: `{issue_number: 2144}`
- [ ] **Z3 check post-patterns.** Dispatch `z3-check-post-green` from implementation-pipeline. Validate post-patterns state transition. (**inline**)
  - Context: `{issue_number: 2144, contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Create checkpoint tag.** Dispatch `checkpoint-tag-create` from implementation-pipeline. Create checkpoint tag for this item's PASS state. (**clean-room**)
  - Context: `{issue_number: 2144, phase: 3, item: 8}`
- [ ] **Checkpoint commit.** Dispatch `checkpoint-commit` from implementation-pipeline. Commit behavioral enforcement test. (**clean-room**)
  - Context: `{issue_number: 2144}`

## Post-Implementation

- [ ] **Structural checks.** Dispatch `structural-checks` from implementation-pipeline. Run lint, typecheck, and format checks on all modified files. (**clean-room**)
  - Context: `{issue_number: 2144}`
- [ ] **GREEN doublecheck.** Dispatch `green-doublecheck` from implementation-pipeline. Verify all GREEN implementations are correct. (**clean-room**)
  - Context: `{issue_number: 2144}`
- [ ] **Verification before completion.** Dispatch `green-vbc` from implementation-pipeline. Run full verification against all success criteria. (**clean-room**)
  - Context: `{issue_number: 2144}`
- [ ] **SC count gate.** Dispatch `sc-count-gate` from implementation-pipeline. Verify all 8 SCs have verdicts. (**clean-room**)
  - Context: `{issue_number: 2144}`
- [ ] **Pre-PR gate.** Dispatch `pre-pr-gate` from implementation-pipeline. Verify no SC has a FAIL verdict. (**clean-room**)
  - Context: `{issue_number: 2144}`
- [ ] **Audit.** Dispatch audit task from audit skill. Perform adversarial audit of all changes. (**clean-room**)
  - Context: `{issue_number: 2144}`
- [ ] **Cross-validate.** Dispatch `cross-validate` from audit. Produce cross-validate findings. (**clean-room**)
  - Context: `{issue_number: 2144}`
- [ ] **Regression check.** Dispatch `regression-check` from implementation-pipeline. Run existing enforcement tests to verify no regressions. (**clean-room**)
  - Context: `{issue_number: 2144}`
- [ ] **Review prep.** Dispatch `review-prep` from git-workflow. Prepare PR for review. (**clean-room**)
  - Context: `{issue_number: 2144}`
- [ ] **Create PR.** Dispatch `create-pr` from pr-creation-workflow. Create pull request with all changes. (**clean-room**)
  - Context: `{issue_number: 2144, authorization_scope: for_pr, halt_at: pr_created}`
- [ ] **Executive summary.** Dispatch `exec-summary` from completion-core. Report completion summary. (**clean-room**)
  - Context: `{issue_number: 2144}`

## Lifecycle Events

- **2026-07-25T12:00:00Z** — `plan_created` — Plan file at `.opencode/.issues/2144/plan.md` with 3 phases, 8 items. Dispatch mode: clean-room (primary) with inline Z3 checks. Pipeline signal: route to `implementation-pipeline` for RED/GREEN execution.
