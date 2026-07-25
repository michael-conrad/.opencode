---
plan_schema_version: "1.0"
issue: 2104
title: "Per-SC RED/GREEN Decomposition"
dispatch:
  - phase: 1
    skill: implementation-pipeline
    task: assemble-work
  - phase: 2
    skill: implementation-pipeline
    task: assemble-work
  - phase: 3
    skill: implementation-pipeline
    task: assemble-work
  - phase: 4
    skill: implementation-pipeline
    task: assemble-work
  - phase: 5
    skill: implementation-pipeline
    task: assemble-work
---

# Implementation Plan: Per-SC RED/GREEN Decomposition

## Pre-Implementation Steps

### Coherence Gate
- [ ] Dispatch `sc-coherence-gate` from implementation-pipeline (**sub-agent**)
  - Context: `{issue_number: 2104}`
  - Verifies spec/plan coherence before any RED routing

### Baseline Check
- [ ] Dispatch `pre-red-baseline` from implementation-pipeline (**sub-agent**)
  - Context: `{issue_number: 2104}`
  - Captures pre-implementation state for diff comparison

---

## Phase 1 — Spec Writer Changes

**Concern:** spec-writer
**SCs:** SC-1, SC-2
**Files:** `.opencode/skills/spec-creation/tasks/create.md`

### Task: Replace three-tier per-file phase structure with per-SC item list (SC-1)

- [ ] **red-phase** — Write a failing test that verifies the new per-SC item enumeration pattern (**sub-agent**)
  - Context: `{issue_number: 2104}`
  - Targets SC-1: decompose.md Step 5 replacement
- [ ] **z3-check-red** — Solve check RED phase (**inline**)
  - Context: `{issue_number: 2104, contract_path: ...}`
- [ ] **red-doublecheck** — Verify RED phase output (**sub-agent**)
  - Context: `{issue_number: 2104}`
- [ ] **z3-check-red-doublecheck** — Solve check RED doublecheck (**inline**)
  - Context: `{issue_number: 2104, contract_path: ...}`
- [ ] **post-red-enforcement** — Post-RED enforcement gate (**sub-agent**)
  - Context: `{issue_number: 2104}`
- [ ] **z3-check-post-red** — Solve check post-RED (**inline**)
  - Context: `{issue_number: 2104, contract_path: ...}`
- [ ] **green-phase** — Implement the change: replace Step 5 three-tier per-file phase structure with per-SC item enumeration (**sub-agent**)
  - Context: `{issue_number: 2104}`
  - Targets SC-1: modify `spec-creation/tasks/create.md` Step 5
- [ ] **z3-check-green** — Solve check GREEN phase (**inline**)
  - Context: `{issue_number: 2104, contract_path: ...}`
- [ ] **post-green-enforcement** — Post-GREEN enforcement gate (**sub-agent**)
  - Context: `{issue_number: 2104}`
- [ ] **z3-check-post-green** — Solve check post-GREEN (**inline**)
  - Context: `{issue_number: 2104, contract_path: ...}`
- [ ] **checkpoint-tag-create** — Create checkpoint tag (**sub-agent**)
  - Context: `{issue_number: 2104}`
- [ ] **checkpoint-commit** — Save checkpoint commit (**sub-agent**)
  - Context: `{issue_number: 2104}`
- [ ] **structural-checks** — Run lint/typecheck (**sub-agent**)
  - Context: `{issue_number: 2104}`
- [ ] **green-doublecheck** — Verify GREEN phase output (**sub-agent**)
  - Context: `{issue_number: 2104}`
- [ ] **green-vbc** — Verification before completion (**sub-agent**)
  - Context: `{issue_number: 2104}`
- [ ] **sc-count-gate** — SC count gate: verify SC-1 has a verdict (**sub-agent**)
  - Context: `{issue_number: 2104}`
- [ ] **pre-pr-gate** — Pre-PR gate: verify all SCs PASS (**sub-agent**)
  - Context: `{issue_number: 2104}`
- [ ] **audit** — Dispatch audit task (**sub-agent**)
  - Context: `{issue_number: 2104}`
- [ ] **cross-validate** — Cross-validate findings (**sub-agent**)
  - Context: `{issue_number: 2104}`
- [ ] **regression-check** — Run regression tests (**sub-agent**)
  - Context: `{issue_number: 2104}`
- [ ] **review-prep** — Prepare for review (**sub-agent**)
  - Context: `{issue_number: 2104}`
- [ ] **create-pr** — Create pull request (**sub-agent**)
  - Context: `{issue_number: 2104, authorization_scope: for_pr, halt_at: pr_created}`
- [ ] **exec-summary** — Completion summary (**sub-agent**)
  - Context: `{issue_number: 2104}`

### Task: Change plan_phase to plan_item in sc-summary.yaml (SC-2)

- [ ] **red-phase** — Write a failing test that verifies the plan_item field (**sub-agent**)
  - Context: `{issue_number: 2104}`
  - Targets SC-2: create.md Step 1.1 field rename
- [ ] **z3-check-red** — Solve check RED phase (**inline**)
  - Context: `{issue_number: 2104, contract_path: ...}`
- [ ] **red-doublecheck** — Verify RED phase output (**sub-agent**)
  - Context: `{issue_number: 2104}`
- [ ] **z3-check-red-doublecheck** — Solve check RED doublecheck (**inline**)
  - Context: `{issue_number: 2104, contract_path: ...}`
- [ ] **post-red-enforcement** — Post-RED enforcement gate (**sub-agent**)
  - Context: `{issue_number: 2104}`
- [ ] **z3-check-post-red** — Solve check post-RED (**inline**)
  - Context: `{issue_number: 2104, contract_path: ...}`
- [ ] **green-phase** — Implement the change: rename plan_phase to plan_item in sc-summary.yaml template (**sub-agent**)
  - Context: `{issue_number: 2104}`
  - Targets SC-2: modify `spec-creation/tasks/create.md` Step 1.1
- [ ] **z3-check-green** — Solve check GREEN phase (**inline**)
  - Context: `{issue_number: 2104, contract_path: ...}`
- [ ] **post-green-enforcement** — Post-GREEN enforcement gate (**sub-agent**)
  - Context: `{issue_number: 2104}`
- [ ] **z3-check-post-green** — Solve check post-GREEN (**inline**)
  - Context: `{issue_number: 2104, contract_path: ...}`
- [ ] **checkpoint-tag-create** — Create checkpoint tag (**sub-agent**)
  - Context: `{issue_number: 2104}`
- [ ] **checkpoint-commit** — Save checkpoint commit (**sub-agent**)
  - Context: `{issue_number: 2104}`
- [ ] **structural-checks** — Run lint/typecheck (**sub-agent**)
  - Context: `{issue_number: 2104}`
- [ ] **green-doublecheck** — Verify GREEN phase output (**sub-agent**)
  - Context: `{issue_number: 2104}`
- [ ] **green-vbc** — Verification before completion (**sub-agent**)
  - Context: `{issue_number: 2104}`
- [ ] **sc-count-gate** — SC count gate: verify SC-2 has a verdict (**sub-agent**)
  - Context: `{issue_number: 2104}`
- [ ] **pre-pr-gate** — Pre-PR gate: verify all SCs PASS (**sub-agent**)
  - Context: `{issue_number: 2104}`
- [ ] **audit** — Dispatch audit task (**sub-agent**)
  - Context: `{issue_number: 2104}`
- [ ] **cross-validate** — Cross-validate findings (**sub-agent**)
  - Context: `{issue_number: 2104}`
- [ ] **regression-check** — Run regression tests (**sub-agent**)
  - Context: `{issue_number: 2104}`
- [ ] **review-prep** — Prepare for review (**sub-agent**)
  - Context: `{issue_number: 2104}`
- [ ] **create-pr** — Create pull request (**sub-agent**)
  - Context: `{issue_number: 2104, authorization_scope: for_pr, halt_at: pr_created}`
- [ ] **exec-summary** — Completion summary (**sub-agent**)
  - Context: `{issue_number: 2104}`

---

## Phase 2 — Documentation Standards

**Concern:** documentation-standards
**SCs:** SC-3, SC-4, SC-5, SC-6
**Files:** `.opencode/AGENTS.md`, `.opencode/guidelines/091-incremental-build.md`, `.opencode/skills/test-driven-development/tasks/red.md`, `.opencode/skills/test-driven-development/tasks/green.md`

### Task: Add Per-SC Decomposition section to AGENTS.md (SC-3)

- [ ] **red-phase** — Write a failing test that verifies the Per-SC Decomposition section exists (**sub-agent**)
  - Context: `{issue_number: 2104}`
  - Targets SC-3
- [ ] **z3-check-red** — Solve check RED phase (**inline**)
- [ ] **red-doublecheck** — Verify RED phase output (**sub-agent**)
- [ ] **z3-check-red-doublecheck** — Solve check RED doublecheck (**inline**)
- [ ] **post-red-enforcement** — Post-RED enforcement gate (**sub-agent**)
- [ ] **z3-check-post-red** — Solve check post-RED (**inline**)
- [ ] **green-phase** — Add Per-SC Decomposition section to AGENTS.md (**sub-agent**)
  - Context: `{issue_number: 2104}`
  - Targets SC-3
- [ ] **z3-check-green** — Solve check GREEN phase (**inline**)
- [ ] **post-green-enforcement** — Post-GREEN enforcement gate (**sub-agent**)
- [ ] **z3-check-post-green** — Solve check post-GREEN (**inline**)
- [ ] **checkpoint-tag-create** — Create checkpoint tag (**sub-agent**)
- [ ] **checkpoint-commit** — Save checkpoint commit (**sub-agent**)
- [ ] **structural-checks** — Run lint/typecheck (**sub-agent**)
- [ ] **green-doublecheck** — Verify GREEN phase output (**sub-agent**)
- [ ] **green-vbc** — Verification before completion (**sub-agent**)
- [ ] **sc-count-gate** — SC count gate (**sub-agent**)
- [ ] **pre-pr-gate** — Pre-PR gate (**sub-agent**)
- [ ] **audit** — Dispatch audit task (**sub-agent**)
- [ ] **cross-validate** — Cross-validate findings (**sub-agent**)
- [ ] **regression-check** — Run regression tests (**sub-agent**)
- [ ] **review-prep** — Prepare for review (**sub-agent**)
- [ ] **create-pr** — Create pull request (**sub-agent**)
- [ ] **exec-summary** — Completion summary (**sub-agent**)

### Task: Clarify item = one SC per item in 091-incremental-build.md (SC-4)

- [ ] **red-phase** — Write a failing test for the item clarification (**sub-agent**)
- [ ] **z3-check-red** — Solve check RED phase (**inline**)
- [ ] **red-doublecheck** — Verify RED phase output (**sub-agent**)
- [ ] **z3-check-red-doublecheck** — Solve check RED doublecheck (**inline**)
- [ ] **post-red-enforcement** — Post-RED enforcement gate (**sub-agent**)
- [ ] **z3-check-post-red** — Solve check post-RED (**inline**)
- [ ] **green-phase** — Clarify item = one SC per item in 091-incremental-build.md (**sub-agent**)
- [ ] **z3-check-green** — Solve check GREEN phase (**inline**)
- [ ] **post-green-enforcement** — Post-GREEN enforcement gate (**sub-agent**)
- [ ] **z3-check-post-green** — Solve check post-GREEN (**inline**)
- [ ] **checkpoint-tag-create** — Create checkpoint tag (**sub-agent**)
- [ ] **checkpoint-commit** — Save checkpoint commit (**sub-agent**)
- [ ] **structural-checks** — Run lint/typecheck (**sub-agent**)
- [ ] **green-doublecheck** — Verify GREEN phase output (**sub-agent**)
- [ ] **green-vbc** — Verification before completion (**sub-agent**)
- [ ] **sc-count-gate** — SC count gate (**sub-agent**)
- [ ] **pre-pr-gate** — Pre-PR gate (**sub-agent**)
- [ ] **audit** — Dispatch audit task (**sub-agent**)
- [ ] **cross-validate** — Cross-validate findings (**sub-agent**)
- [ ] **regression-check** — Run regression tests (**sub-agent**)
- [ ] **review-prep** — Prepare for review (**sub-agent**)
- [ ] **create-pr** — Create pull request (**sub-agent**)
- [ ] **exec-summary** — Completion summary (**sub-agent**)

### Task: Add per-SC targeting note to red.md (SC-5)

- [ ] **red-phase** — Write a failing test for per-SC targeting in red.md (**sub-agent**)
- [ ] **z3-check-red** — Solve check RED phase (**inline**)
- [ ] **red-doublecheck** — Verify RED phase output (**sub-agent**)
- [ ] **z3-check-red-doublecheck** — Solve check RED doublecheck (**inline**)
- [ ] **post-red-enforcement** — Post-RED enforcement gate (**sub-agent**)
- [ ] **z3-check-post-red** — Solve check post-RED (**inline**)
- [ ] **green-phase** — Add per-SC targeting note to red.md Required RED Structure section (**sub-agent**)
- [ ] **z3-check-green** — Solve check GREEN phase (**inline**)
- [ ] **post-green-enforcement** — Post-GREEN enforcement gate (**sub-agent**)
- [ ] **z3-check-post-green** — Solve check post-GREEN (**inline**)
- [ ] **checkpoint-tag-create** — Create checkpoint tag (**sub-agent**)
- [ ] **checkpoint-commit** — Save checkpoint commit (**sub-agent**)
- [ ] **structural-checks** — Run lint/typecheck (**sub-agent**)
- [ ] **green-doublecheck** — Verify GREEN phase output (**sub-agent**)
- [ ] **green-vbc** — Verification before completion (**sub-agent**)
- [ ] **sc-count-gate** — SC count gate (**sub-agent**)
- [ ] **pre-pr-gate** — Pre-PR gate (**sub-agent**)
- [ ] **audit** — Dispatch audit task (**sub-agent**)
- [ ] **cross-validate** — Cross-validate findings (**sub-agent**)
- [ ] **regression-check** — Run regression tests (**sub-agent**)
- [ ] **review-prep** — Prepare for review (**sub-agent**)
- [ ] **create-pr** — Create pull request (**sub-agent**)
- [ ] **exec-summary** — Completion summary (**sub-agent**)

### Task: Add per-SC implementation note to green.md (SC-6)

- [ ] **red-phase** — Write a failing test for per-SC implementation in green.md (**sub-agent**)
- [ ] **z3-check-red** — Solve check RED phase (**inline**)
- [ ] **red-doublecheck** — Verify RED phase output (**sub-agent**)
- [ ] **z3-check-red-doublecheck** — Solve check RED doublecheck (**inline**)
- [ ] **post-red-enforcement** — Post-RED enforcement gate (**sub-agent**)
- [ ] **z3-check-post-red** — Solve check post-RED (**inline**)
- [ ] **green-phase** — Add per-SC implementation note to green.md Exit Criteria section (**sub-agent**)
- [ ] **z3-check-green** — Solve check GREEN phase (**inline**)
- [ ] **post-green-enforcement** — Post-GREEN enforcement gate (**sub-agent**)
- [ ] **z3-check-post-green** — Solve check post-GREEN (**inline**)
- [ ] **checkpoint-tag-create** — Create checkpoint tag (**sub-agent**)
- [ ] **checkpoint-commit** — Save checkpoint commit (**sub-agent**)
- [ ] **structural-checks** — Run lint/typecheck (**sub-agent**)
- [ ] **green-doublecheck** — Verify GREEN phase output (**sub-agent**)
- [ ] **green-vbc** — Verification before completion (**sub-agent**)
- [ ] **sc-count-gate** — SC count gate (**sub-agent**)
- [ ] **pre-pr-gate** — Pre-PR gate (**sub-agent**)
- [ ] **audit** — Dispatch audit task (**sub-agent**)
- [ ] **cross-validate** — Cross-validate findings (**sub-agent**)
- [ ] **regression-check** — Run regression tests (**sub-agent**)
- [ ] **review-prep** — Prepare for review (**sub-agent**)
- [ ] **create-pr** — Create pull request (**sub-agent**)
- [ ] **exec-summary** — Completion summary (**sub-agent**)

---

## Phase 3 — Plan Writer Changes

**Concern:** plan-writer
**SCs:** SC-7, SC-8, SC-9
**Files:** `.opencode/skills/writing-plans/tasks/structure.md`, `.opencode/skills/writing-plans/tasks/create.md`

### Task: Change structure.md Step 5 from code-path-to-item to SC-to-item (SC-7)

- [ ] **red-phase** — Write a failing test for SC-to-item mapping in structure.md (**sub-agent**)
- [ ] **z3-check-red** — Solve check RED phase (**inline**)
- [ ] **red-doublecheck** — Verify RED phase output (**sub-agent**)
- [ ] **z3-check-red-doublecheck** — Solve check RED doublecheck (**inline**)
- [ ] **post-red-enforcement** — Post-RED enforcement gate (**sub-agent**)
- [ ] **z3-check-post-red** — Solve check post-RED (**inline**)
- [ ] **green-phase** — Change structure.md Step 5 mapping directive from code-path-to-item to SC-to-item (**sub-agent**)
- [ ] **z3-check-green** — Solve check GREEN phase (**inline**)
- [ ] **post-green-enforcement** — Post-GREEN enforcement gate (**sub-agent**)
- [ ] **z3-check-post-green** — Solve check post-GREEN (**inline**)
- [ ] **checkpoint-tag-create** — Create checkpoint tag (**sub-agent**)
- [ ] **checkpoint-commit** — Save checkpoint commit (**sub-agent**)
- [ ] **structural-checks** — Run lint/typecheck (**sub-agent**)
- [ ] **green-doublecheck** — Verify GREEN phase output (**sub-agent**)
- [ ] **green-vbc** — Verification before completion (**sub-agent**)
- [ ] **sc-count-gate** — SC count gate (**sub-agent**)
- [ ] **pre-pr-gate** — Pre-PR gate (**sub-agent**)
- [ ] **audit** — Dispatch audit task (**sub-agent**)
- [ ] **cross-validate** — Cross-validate findings (**sub-agent**)
- [ ] **regression-check** — Run regression tests (**sub-agent**)
- [ ] **review-prep** — Prepare for review (**sub-agent**)
- [ ] **create-pr** — Create pull request (**sub-agent**)
- [ ] **exec-summary** — Completion summary (**sub-agent**)

### Task: Change create.md Tier 3 to per-SC with SC-ID binding (SC-8)

- [ ] **red-phase** — Write a failing test for per-SC SC-ID binding in create.md (**sub-agent**)
- [ ] **z3-check-red** — Solve check RED phase (**inline**)
- [ ] **red-doublecheck** — Verify RED phase output (**sub-agent**)
- [ ] **z3-check-red-doublecheck** — Solve check RED doublecheck (**inline**)
- [ ] **post-red-enforcement** — Post-RED enforcement gate (**sub-agent**)
- [ ] **z3-check-post-red** — Solve check post-RED (**inline**)
- [ ] **green-phase** — Change create.md Tier 3 from per-item to per-SC with explicit SC-ID binding (**sub-agent**)
- [ ] **z3-check-green** — Solve check GREEN phase (**inline**)
- [ ] **post-green-enforcement** — Post-GREEN enforcement gate (**sub-agent**)
- [ ] **z3-check-post-green** — Solve check post-GREEN (**inline**)
- [ ] **checkpoint-tag-create** — Create checkpoint tag (**sub-agent**)
- [ ] **checkpoint-commit** — Save checkpoint commit (**sub-agent**)
- [ ] **structural-checks** — Run lint/typecheck (**sub-agent**)
- [ ] **green-doublecheck** — Verify GREEN phase output (**sub-agent**)
- [ ] **green-vbc** — Verification before completion (**sub-agent**)
- [ ] **sc-count-gate** — SC count gate (**sub-agent**)
- [ ] **pre-pr-gate** — Pre-PR gate (**sub-agent**)
- [ ] **audit** — Dispatch audit task (**sub-agent**)
- [ ] **cross-validate** — Cross-validate findings (**sub-agent**)
- [ ] **regression-check** — Run regression tests (**sub-agent**)
- [ ] **review-prep** — Prepare for review (**sub-agent**)
- [ ] **create-pr** — Create pull request (**sub-agent**)
- [ ] **exec-summary** — Completion summary (**sub-agent**)

### Task: Add validation rule 16 to create.md (SC-9)

- [ ] **red-phase** — Write a failing test for validation rule 16 in create.md (**sub-agent**)
- [ ] **z3-check-red** — Solve check RED phase (**inline**)
- [ ] **red-doublecheck** — Verify RED phase output (**sub-agent**)
- [ ] **z3-check-red-doublecheck** — Solve check RED doublecheck (**inline**)
- [ ] **post-red-enforcement** — Post-RED enforcement gate (**sub-agent**)
- [ ] **z3-check-post-red** — Solve check post-RED (**inline**)
- [ ] **green-phase** — Add validation rule 16: each item references exactly one SC-ID to create.md (**sub-agent**)
- [ ] **z3-check-green** — Solve check GREEN phase (**inline**)
- [ ] **post-green-enforcement** — Post-GREEN enforcement gate (**sub-agent**)
- [ ] **z3-check-post-green** — Solve check post-GREEN (**inline**)
- [ ] **checkpoint-tag-create** — Create checkpoint tag (**sub-agent**)
- [ ] **checkpoint-commit** — Save checkpoint commit (**sub-agent**)
- [ ] **structural-checks** — Run lint/typecheck (**sub-agent**)
- [ ] **green-doublecheck** — Verify GREEN phase output (**sub-agent**)
- [ ] **green-vbc** — Verification before completion (**sub-agent**)
- [ ] **sc-count-gate** — SC count gate (**sub-agent**)
- [ ] **pre-pr-gate** — Pre-PR gate (**sub-agent**)
- [ ] **audit** — Dispatch audit task (**sub-agent**)
- [ ] **cross-validate** — Cross-validate findings (**sub-agent**)
- [ ] **regression-check** — Run regression tests (**sub-agent**)
- [ ] **review-prep** — Prepare for review (**sub-agent**)
- [ ] **create-pr** — Create pull request (**sub-agent**)
- [ ] **exec-summary** — Completion summary (**sub-agent**)

---

## Phase 4 — Pipeline Changes

**Concern:** pipeline
**SCs:** SC-10, SC-11
**Files:** `.opencode/skills/implementation-pipeline/tasks/pipeline-executor.md`, `.opencode/skills/implementation-pipeline/tasks/tdd-chaining-gate.md`

### Task: Add per-SC checkpoint verification to pipeline-executor.md (SC-10)

- [ ] **red-phase** — Write a failing test for per-SC checkpoint in pipeline-executor.md (**sub-agent**)
- [ ] **z3-check-red** — Solve check RED phase (**inline**)
- [ ] **red-doublecheck** — Verify RED phase output (**sub-agent**)
- [ ] **z3-check-red-doublecheck** — Solve check RED doublecheck (**inline**)
- [ ] **post-red-enforcement** — Post-RED enforcement gate (**sub-agent**)
- [ ] **z3-check-post-red** — Solve check post-RED (**inline**)
- [ ] **green-phase** — Add per-SC checkpoint verification after each RED/GREEN cycle with SC-ID in tag naming (**sub-agent**)
- [ ] **z3-check-green** — Solve check GREEN phase (**inline**)
- [ ] **post-green-enforcement** — Post-GREEN enforcement gate (**sub-agent**)
- [ ] **z3-check-post-green** — Solve check post-GREEN (**inline**)
- [ ] **checkpoint-tag-create** — Create checkpoint tag (**sub-agent**)
- [ ] **checkpoint-commit** — Save checkpoint commit (**sub-agent**)
- [ ] **structural-checks** — Run lint/typecheck (**sub-agent**)
- [ ] **green-doublecheck** — Verify GREEN phase output (**sub-agent**)
- [ ] **green-vbc** — Verification before completion (**sub-agent**)
- [ ] **sc-count-gate** — SC count gate (**sub-agent**)
- [ ] **pre-pr-gate** — Pre-PR gate (**sub-agent**)
- [ ] **audit** — Dispatch audit task (**sub-agent**)
- [ ] **cross-validate** — Cross-validate findings (**sub-agent**)
- [ ] **regression-check** — Run regression tests (**sub-agent**)
- [ ] **review-prep** — Prepare for review (**sub-agent**)
- [ ] **create-pr** — Create pull request (**sub-agent**)
- [ ] **exec-summary** — Completion summary (**sub-agent**)

### Task: Add SC-level check to tdd-chaining-gate.md (SC-11)

- [ ] **red-phase** — Write a failing test for MULTI_SC_ITEM BLOCK in tdd-chaining-gate.md (**sub-agent**)
- [ ] **z3-check-red** — Solve check RED phase (**inline**)
- [ ] **red-doublecheck** — Verify RED phase output (**sub-agent**)
- [ ] **z3-check-red-doublecheck** — Solve check RED doublecheck (**inline**)
- [ ] **post-red-enforcement** — Post-RED enforcement gate (**sub-agent**)
- [ ] **z3-check-post-red** — Solve check post-RED (**inline**)
- [ ] **green-phase** — Add SC-level check to tdd-chaining-gate.md: verify each item covers exactly one SC, BLOCK with MULTI_SC_ITEM (**sub-agent**)
- [ ] **z3-check-green** — Solve check GREEN phase (**inline**)
- [ ] **post-green-enforcement** — Post-GREEN enforcement gate (**sub-agent**)
- [ ] **z3-check-post-green** — Solve check post-GREEN (**inline**)
- [ ] **checkpoint-tag-create** — Create checkpoint tag (**sub-agent**)
- [ ] **checkpoint-commit** — Save checkpoint commit (**sub-agent**)
- [ ] **structural-checks** — Run lint/typecheck (**sub-agent**)
- [ ] **green-doublecheck** — Verify GREEN phase output (**sub-agent**)
- [ ] **green-vbc** — Verification before completion (**sub-agent**)
- [ ] **sc-count-gate** — SC count gate (**sub-agent**)
- [ ] **pre-pr-gate** — Pre-PR gate (**sub-agent**)
- [ ] **audit** — Dispatch audit task (**sub-agent**)
- [ ] **cross-validate** — Cross-validate findings (**sub-agent**)
- [ ] **regression-check** — Run regression tests (**sub-agent**)
- [ ] **review-prep** — Prepare for review (**sub-agent**)
- [ ] **create-pr** — Create pull request (**sub-agent**)
- [ ] **exec-summary** — Completion summary (**sub-agent**)

---

## Phase 5 — Behavioral Tests

**Concern:** behavioral-tests
**SCs:** SC-12, SC-13
**Files:** `.opencode/tests-v2/behaviors/per-sc-decomposition.sh`, `.opencode/tests-v2/behaviors/tdd-chaining-multi-sc-block.sh`

### Task: Create per-sc-decomposition.sh behavioral test (SC-12)

- [ ] **red-phase** — Write a failing test that verifies the behavioral test file exists (**sub-agent**)
- [ ] **z3-check-red** — Solve check RED phase (**inline**)
- [ ] **red-doublecheck** — Verify RED phase output (**sub-agent**)
- [ ] **z3-check-red-doublecheck** — Solve check RED doublecheck (**inline**)
- [ ] **post-red-enforcement** — Post-RED enforcement gate (**sub-agent**)
- [ ] **z3-check-post-red** — Solve check post-RED (**inline**)
- [ ] **green-phase** — Create per-sc-decomposition.sh behavioral test verifying plan writer produces per-SC items (**sub-agent**)
- [ ] **z3-check-green** — Solve check GREEN phase (**inline**)
- [ ] **post-green-enforcement** — Post-GREEN enforcement gate (**sub-agent**)
- [ ] **z3-check-post-green** — Solve check post-GREEN (**inline**)
- [ ] **checkpoint-tag-create** — Create checkpoint tag (**sub-agent**)
- [ ] **checkpoint-commit** — Save checkpoint commit (**sub-agent**)
- [ ] **structural-checks** — Run lint/typecheck (**sub-agent**)
- [ ] **green-doublecheck** — Verify GREEN phase output (**sub-agent**)
- [ ] **green-vbc** — Verification before completion (**sub-agent**)
- [ ] **sc-count-gate** — SC count gate (**sub-agent**)
- [ ] **pre-pr-gate** — Pre-PR gate (**sub-agent**)
- [ ] **audit** — Dispatch audit task (**sub-agent**)
- [ ] **cross-validate** — Cross-validate findings (**sub-agent**)
- [ ] **regression-check** — Run regression tests (**sub-agent**)
- [ ] **review-prep** — Prepare for review (**sub-agent**)
- [ ] **create-pr** — Create pull request (**sub-agent**)
- [ ] **exec-summary** — Completion summary (**sub-agent**)

### Task: Create tdd-chaining-multi-sc-block.sh behavioral test (SC-13)

- [ ] **red-phase** — Write a failing test for the TDD chaining gate BLOCK behavioral test (**sub-agent**)
- [ ] **z3-check-red** — Solve check RED phase (**inline**)
- [ ] **red-doublecheck** — Verify RED phase output (**sub-agent**)
- [ ] **z3-check-red-doublecheck** — Solve check RED doublecheck (**inline**)
- [ ] **post-red-enforcement** — Post-RED enforcement gate (**sub-agent**)
- [ ] **z3-check-post-red** — Solve check post-RED (**inline**)
- [ ] **green-phase** — Create tdd-chaining-multi-sc-block.sh behavioral test verifying TDD chaining gate BLOCKs on multi-SC items (**sub-agent**)
- [ ] **z3-check-green** — Solve check GREEN phase (**inline**)
- [ ] **post-green-enforcement** — Post-GREEN enforcement gate (**sub-agent**)
- [ ] **z3-check-post-green** — Solve check post-GREEN (**inline**)
- [ ] **checkpoint-tag-create** — Create checkpoint tag (**sub-agent**)
- [ ] **checkpoint-commit** — Save checkpoint commit (**sub-agent**)
- [ ] **structural-checks** — Run lint/typecheck (**sub-agent**)
- [ ] **green-doublecheck** — Verify GREEN phase output (**sub-agent**)
- [ ] **green-vbc** — Verification before completion (**sub-agent**)
- [ ] **sc-count-gate** — SC count gate (**sub-agent**)
- [ ] **pre-pr-gate** — Pre-PR gate (**sub-agent**)
- [ ] **audit** — Dispatch audit task (**sub-agent**)
- [ ] **cross-validate** — Cross-validate findings (**sub-agent**)
- [ ] **regression-check** — Run regression tests (**sub-agent**)
- [ ] **review-prep** — Prepare for review (**sub-agent**)
- [ ] **create-pr** — Create pull request (**sub-agent**)
- [ ] **exec-summary** — Completion summary (**sub-agent**)

---

## Post-Implementation Steps

- [ ] **Structural checks** — Run lint/typecheck across all modified files (**sub-agent**)
- [ ] **Verification** — Verify all 13 SCs have PASS verdicts (**sub-agent**)
- [ ] **Audit** — Dispatch adversarial audit of all changes (**sub-agent**)
- [ ] **Cross-validate** — Cross-validate audit findings (**sub-agent**)
- [ ] **Review prep** — Prepare PR for review (**sub-agent**)
- [ ] **Create PR** — Create pull request with authorization_scope: for_pr (**sub-agent**)
- [ ] **Completion** — Generate completion summary (**sub-agent**)

---

## Lifecycle Events

- **event:** plan_created
  **timestamp:** 2026-07-24T00:00:00Z
  **issuer:** OpenCode (deepseek-v4-flash)
  **plan_path:** `.opencode/.issues/2104/plan.md`
  **phase_count:** 5
  **sc_count:** 13
  **status:** PASS
