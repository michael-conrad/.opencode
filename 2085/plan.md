---
plan_schema_version: "1.0"
issue: 2085
title: "Restructure writing-plans skill with atomic task cards and self-contained plan output"
dispatch:
  - phase: 1
    skill: implementation-pipeline
    task: step-dispatch
  - phase: 2
    skill: implementation-pipeline
    task: step-dispatch
---

# Implementation Plan — #2085 — Restructure writing-plans skill

**Goal:** Restructure the writing-plans skill into 9 atomic task cards (one concern per card) with 3 self-contained workflows and plans that follow the implementation-pipeline workflow exactly.

**Architecture:** The writing-plans skill is restructured from 7 task files to 9 atomic task cards. The explore task is extracted to a separate skill (spec #2084, not part of this plan). The create.md task card is rewritten to produce plans that load the implementation-pipeline TDT at runtime and enumerate every step of the per-task cycle. The SKILL.md gets 3 self-contained workflow tables (Create, Revise, Retroactive) with no cross-references between them.

**Tech Stack:** opencode skills, YAML frontmatter, markdown task cards, behavioral enforcement tests via `opencode run`

---

## Pre-Implementation

- [ ] 1. **Coherence gate.** Verify spec/plan coherence.
  - Dispatch: `audit --task coherence-extraction` (**sub-agent**)
  - Context: `{issue_number: 2085}`
- [ ] 2. **Baseline check.** Verify clean starting state.
  - Dispatch: `implementation-pipeline --task pre-red-baseline` (**sub-agent**)
  - Context: `{issue_number: 2085}`

---

## Phase 1: Writing-plans restructure

**Concern:** Restructure writing-plans skill with 9 atomic task cards and 3 self-contained workflows.
**SCs:** SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8, SC-9, SC-10, SC-11, SC-12, SC-13, SC-14, SC-15
**Depends On:** (none)

### Task 1: Update SKILL.md with 3 self-contained workflows

- [ ] 1. **RED.** Write failing test asserting SKILL.md has 3 workflow tables.
  - Test file: `tests/behaviors/writing-plans-workflows.sh`
  - Expected failure: SKILL.md missing workflow tables
  - Dispatch: `test-driven-development --task red` (**clean-room**)
  - Context: `{issue_number: 2085, plan_path: ".opencode/.issues/2085/plan.md", test_file: "tests/behaviors/writing-plans-workflows.sh", expected_failure: "SKILL.md missing workflow tables"}`
- [ ] 2. **Z3 check RED.** Validate RED state.
  - Dispatch: `solve --task check` (**inline**)
- [ ] 3. **RED doublecheck.** Verify RED test fails correctly.
  - Dispatch: `verification-before-completion --task verify` (**clean-room**)
  - Context: `{issue_number: 2085, plan_path: ".opencode/.issues/2085/plan.md"}`
- [ ] 4. **Z3 check RED doublecheck.** Validate RED doublecheck state.
  - Dispatch: `solve --task check` (**inline**)
- [ ] 5. **Post-RED enforcement.** Enforce RED gate.
  - Dispatch: `implementation-pipeline --task post-red-enforcement` (**clean-room**)
  - Context: `{issue_number: 2085}`
- [ ] 6. **Z3 check post-RED.** Validate post-RED state.
  - Dispatch: `solve --task check` (**inline**)
- [ ] 7. **GREEN.** Write `skills/writing-plans/SKILL.md` per spec §SKILL.md and §Workflows at `.opencode/.issues/2085/issue.yaml`.
  - File: `skills/writing-plans/SKILL.md`
  - Dispatch: `test-driven-development --task green` (**clean-room**)
  - Context: `{issue_number: 2085, plan_path: ".opencode/.issues/2085/plan.md", spec_path: ".opencode/.issues/2085/issue.yaml", target_file: "skills/writing-plans/SKILL.md"}`
- [ ] 8. **Z3 check GREEN.** Validate GREEN state.
  - Dispatch: `solve --task check` (**inline**)
- [ ] 9. **Post-GREEN enforcement.** Enforce GREEN gate.
  - Dispatch: `implementation-pipeline --task post-green-enforcement` (**clean-room**)
  - Context: `{issue_number: 2085}`
- [ ] 10. **Z3 check post-GREEN.** Validate post-GREEN state.
  - Dispatch: `solve --task check` (**inline**)
- [ ] 11. **Checkpoint tag.** Create checkpoint tag.
  - Dispatch: `implementation-pipeline --task checkpoint-tag-create` (**clean-room**)
  - Context: `{issue_number: 2085}`
- [ ] 12. **Checkpoint commit.** Commit with checkpoint.
  - Files: `skills/writing-plans/SKILL.md`
  - Dispatch: `git-workflow --task commit-prep` (**clean-room**)
  - Context: `{issue_number: 2085, files: ["skills/writing-plans/SKILL.md"]}`

### Task 2: Create backfill.md task card

- [ ] 1. **RED.** Write failing test asserting backfill.md exists and blocks on missing spec.
  - Test file: `tests/behaviors/writing-plans-backfill.sh`
  - Expected failure: file not found
  - Dispatch: `test-driven-development --task red` (**clean-room**)
  - Context: `{issue_number: 2085, plan_path: ".opencode/.issues/2085/plan.md", test_file: "tests/behaviors/writing-plans-backfill.sh", expected_failure: "file not found"}`
- [ ] 2. **Z3 check RED.** Validate RED state.
  - Dispatch: `solve --task check` (**inline**)
- [ ] 3. **RED doublecheck.** Verify RED test fails correctly.
  - Dispatch: `verification-before-completion --task verify` (**clean-room**)
  - Context: `{issue_number: 2085, plan_path: ".opencode/.issues/2085/plan.md"}`
- [ ] 4. **Z3 check RED doublecheck.** Validate RED doublecheck state.
  - Dispatch: `solve --task check` (**inline**)
- [ ] 5. **Post-RED enforcement.** Enforce RED gate.
  - Dispatch: `implementation-pipeline --task post-red-enforcement` (**clean-room**)
  - Context: `{issue_number: 2085}`
- [ ] 6. **Z3 check post-RED.** Validate post-RED state.
  - Dispatch: `solve --task check` (**inline**)
- [ ] 7. **GREEN.** Write `skills/writing-plans/tasks/backfill.md` per spec §Task Cards → backfill.md at `.opencode/.issues/2085/issue.yaml`.
  - File: `skills/writing-plans/tasks/backfill.md`
  - Dispatch: `test-driven-development --task green` (**clean-room**)
  - Context: `{issue_number: 2085, plan_path: ".opencode/.issues/2085/plan.md", spec_path: ".opencode/.issues/2085/issue.yaml", target_file: "skills/writing-plans/tasks/backfill.md"}`
- [ ] 8. **Z3 check GREEN.** Validate GREEN state.
  - Dispatch: `solve --task check` (**inline**)
- [ ] 9. **Post-GREEN enforcement.** Enforce GREEN gate.
  - Dispatch: `implementation-pipeline --task post-green-enforcement` (**clean-room**)
  - Context: `{issue_number: 2085}`
- [ ] 10. **Z3 check post-GREEN.** Validate post-GREEN state.
  - Dispatch: `solve --task check` (**inline**)
- [ ] 11. **Checkpoint tag.** Create checkpoint tag.
  - Dispatch: `implementation-pipeline --task checkpoint-tag-create` (**clean-room**)
  - Context: `{issue_number: 2085}`
- [ ] 12. **Checkpoint commit.** Commit with checkpoint.
  - Files: `skills/writing-plans/tasks/backfill.md`
  - Dispatch: `git-workflow --task commit-prep` (**clean-room**)
  - Context: `{issue_number: 2085, files: ["skills/writing-plans/tasks/backfill.md"]}`

### Task 3: Rewrite analyze.md task card

- [ ] 1. **RED.** Write failing test asserting analyze.md blocks on missing spec.
  - Test file: `tests/behaviors/writing-plans-analyze.sh`
  - Expected failure: old behavior
  - Dispatch: `test-driven-development --task red` (**clean-room**)
  - Context: `{issue_number: 2085, plan_path: ".opencode/.issues/2085/plan.md", test_file: "tests/behaviors/writing-plans-analyze.sh", expected_failure: "old behavior"}`
- [ ] 2. **Z3 check RED.** Validate RED state.
  - Dispatch: `solve --task check` (**inline**)
- [ ] 3. **RED doublecheck.** Verify RED test fails correctly.
  - Dispatch: `verification-before-completion --task verify` (**clean-room**)
  - Context: `{issue_number: 2085, plan_path: ".opencode/.issues/2085/plan.md"}`
- [ ] 4. **Z3 check RED doublecheck.** Validate RED doublecheck state.
  - Dispatch: `solve --task check` (**inline**)
- [ ] 5. **Post-RED enforcement.** Enforce RED gate.
  - Dispatch: `implementation-pipeline --task post-red-enforcement` (**clean-room**)
  - Context: `{issue_number: 2085}`
- [ ] 6. **Z3 check post-RED.** Validate post-RED state.
  - Dispatch: `solve --task check` (**inline**)
- [ ] 7. **GREEN.** Write `skills/writing-plans/tasks/analyze.md` per spec §Task Cards → analyze.md at `.opencode/.issues/2085/issue.yaml`.
  - File: `skills/writing-plans/tasks/analyze.md`
  - Dispatch: `test-driven-development --task green` (**clean-room**)
  - Context: `{issue_number: 2085, plan_path: ".opencode/.issues/2085/plan.md", spec_path: ".opencode/.issues/2085/issue.yaml", target_file: "skills/writing-plans/tasks/analyze.md"}`
- [ ] 8. **Z3 check GREEN.** Validate GREEN state.
  - Dispatch: `solve --task check` (**inline**)
- [ ] 9. **Post-GREEN enforcement.** Enforce GREEN gate.
  - Dispatch: `implementation-pipeline --task post-green-enforcement` (**clean-room**)
  - Context: `{issue_number: 2085}`
- [ ] 10. **Z3 check post-GREEN.** Validate post-GREEN state.
  - Dispatch: `solve --task check` (**inline**)
- [ ] 11. **Checkpoint tag.** Create checkpoint tag.
  - Dispatch: `implementation-pipeline --task checkpoint-tag-create` (**clean-room**)
  - Context: `{issue_number: 2085}`
- [ ] 12. **Checkpoint commit.** Commit with checkpoint.
  - Files: `skills/writing-plans/tasks/analyze.md`
  - Dispatch: `git-workflow --task commit-prep` (**clean-room**)
  - Context: `{issue_number: 2085, files: ["skills/writing-plans/tasks/analyze.md"]}`

### Task 4: Rewrite structure.md task card

- [ ] 1. **RED.** Write failing test asserting structure.md produces phase decomposition.
  - Test file: `tests/behaviors/writing-plans-structure.sh`
  - Expected failure: old behavior
  - Dispatch: `test-driven-development --task red` (**clean-room**)
  - Context: `{issue_number: 2085, plan_path: ".opencode/.issues/2085/plan.md", test_file: "tests/behaviors/writing-plans-structure.sh", expected_failure: "old behavior"}`
- [ ] 2. **Z3 check RED.** Validate RED state.
  - Dispatch: `solve --task check` (**inline**)
- [ ] 3. **RED doublecheck.** Verify RED test fails correctly.
  - Dispatch: `verification-before-completion --task verify` (**clean-room**)
  - Context: `{issue_number: 2085, plan_path: ".opencode/.issues/2085/plan.md"}`
- [ ] 4. **Z3 check RED doublecheck.** Validate RED doublecheck state.
  - Dispatch: `solve --task check` (**inline**)
- [ ] 5. **Post-RED enforcement.** Enforce RED gate.
  - Dispatch: `implementation-pipeline --task post-red-enforcement` (**clean-room**)
  - Context: `{issue_number: 2085}`
- [ ] 6. **Z3 check post-RED.** Validate post-RED state.
  - Dispatch: `solve --task check` (**inline**)
- [ ] 7. **GREEN.** Write `skills/writing-plans/tasks/structure.md` per spec §Task Cards → structure.md at `.opencode/.issues/2085/issue.yaml`.
  - File: `skills/writing-plans/tasks/structure.md`
  - Dispatch: `test-driven-development --task green` (**clean-room**)
  - Context: `{issue_number: 2085, plan_path: ".opencode/.issues/2085/plan.md", spec_path: ".opencode/.issues/2085/issue.yaml", target_file: "skills/writing-plans/tasks/structure.md"}`
- [ ] 8. **Z3 check GREEN.** Validate GREEN state.
  - Dispatch: `solve --task check` (**inline**)
- [ ] 9. **Post-GREEN enforcement.** Enforce GREEN gate.
  - Dispatch: `implementation-pipeline --task post-green-enforcement` (**clean-room**)
  - Context: `{issue_number: 2085}`
- [ ] 10. **Z3 check post-GREEN.** Validate post-GREEN state.
  - Dispatch: `solve --task check` (**inline**)
- [ ] 11. **Checkpoint tag.** Create checkpoint tag.
  - Dispatch: `implementation-pipeline --task checkpoint-tag-create` (**clean-room**)
  - Context: `{issue_number: 2085}`
- [ ] 12. **Checkpoint commit.** Commit with checkpoint.
  - Files: `skills/writing-plans/tasks/structure.md`
  - Dispatch: `git-workflow --task commit-prep` (**clean-room**)
  - Context: `{issue_number: 2085, files: ["skills/writing-plans/tasks/structure.md"]}`

### Task 5: Rewrite create.md task card

- [ ] 1. **RED.** Write failing test asserting create.md produces plans with full per-task cycle.
  - Test file: `tests/behaviors/writing-plans-create.sh`
  - Expected failure: old behavior produces incomplete plans
  - Dispatch: `test-driven-development --task red` (**clean-room**)
  - Context: `{issue_number: 2085, plan_path: ".opencode/.issues/2085/plan.md", test_file: "tests/behaviors/writing-plans-create.sh", expected_failure: "old behavior produces incomplete plans"}`
- [ ] 2. **Z3 check RED.** Validate RED state.
  - Dispatch: `solve --task check` (**inline**)
- [ ] 3. **RED doublecheck.** Verify RED test fails correctly.
  - Dispatch: `verification-before-completion --task verify` (**clean-room**)
  - Context: `{issue_number: 2085, plan_path: ".opencode/.issues/2085/plan.md"}`
- [ ] 4. **Z3 check RED doublecheck.** Validate RED doublecheck state.
  - Dispatch: `solve --task check` (**inline**)
- [ ] 5. **Post-RED enforcement.** Enforce RED gate.
  - Dispatch: `implementation-pipeline --task post-red-enforcement` (**clean-room**)
  - Context: `{issue_number: 2085}`
- [ ] 6. **Z3 check post-RED.** Validate post-RED state.
  - Dispatch: `solve --task check` (**inline**)
- [ ] 7. **GREEN.** Write `skills/writing-plans/tasks/create.md` per spec §Task Cards → create.md at `.opencode/.issues/2085/issue.yaml`.
  - File: `skills/writing-plans/tasks/create.md`
  - Dispatch: `test-driven-development --task green` (**clean-room**)
  - Context: `{issue_number: 2085, plan_path: ".opencode/.issues/2085/plan.md", spec_path: ".opencode/.issues/2085/issue.yaml", target_file: "skills/writing-plans/tasks/create.md"}`
- [ ] 8. **Z3 check GREEN.** Validate GREEN state.
  - Dispatch: `solve --task check` (**inline**)
- [ ] 9. **Post-GREEN enforcement.** Enforce GREEN gate.
  - Dispatch: `implementation-pipeline --task post-green-enforcement` (**clean-room**)
  - Context: `{issue_number: 2085}`
- [ ] 10. **Z3 check post-GREEN.** Validate post-GREEN state.
  - Dispatch: `solve --task check` (**inline**)
- [ ] 11. **Checkpoint tag.** Create checkpoint tag.
  - Dispatch: `implementation-pipeline --task checkpoint-tag-create` (**clean-room**)
  - Context: `{issue_number: 2085}`
- [ ] 12. **Checkpoint commit.** Commit with checkpoint.
  - Files: `skills/writing-plans/tasks/create.md`
  - Dispatch: `git-workflow --task commit-prep` (**clean-room**)
  - Context: `{issue_number: 2085, files: ["skills/writing-plans/tasks/create.md"]}`

### Task 6: Rewrite self-review.md task card

- [ ] 1. **RED.** Write failing test asserting self-review.md detects missing steps.
  - Test file: `tests/behaviors/writing-plans-self-review.sh`
  - Expected failure: old behavior
  - Dispatch: `test-driven-development --task red` (**clean-room**)
  - Context: `{issue_number: 2085, plan_path: ".opencode/.issues/2085/plan.md", test_file: "tests/behaviors/writing-plans-self-review.sh", expected_failure: "old behavior"}`
- [ ] 2. **Z3 check RED.** Validate RED state.
  - Dispatch: `solve --task check` (**inline**)
- [ ] 3. **RED doublecheck.** Verify RED test fails correctly.
  - Dispatch: `verification-before-completion --task verify` (**clean-room**)
  - Context: `{issue_number: 2085, plan_path: ".opencode/.issues/2085/plan.md"}`
- [ ] 4. **Z3 check RED doublecheck.** Validate RED doublecheck state.
  - Dispatch: `solve --task check` (**inline**)
- [ ] 5. **Post-RED enforcement.** Enforce RED gate.
  - Dispatch: `implementation-pipeline --task post-red-enforcement` (**clean-room**)
  - Context: `{issue_number: 2085}`
- [ ] 6. **Z3 check post-RED.** Validate post-RED state.
  - Dispatch: `solve --task check` (**inline**)
- [ ] 7. **GREEN.** Write `skills/writing-plans/tasks/self-review.md` per spec §Task Cards → self-review.md at `.opencode/.issues/2085/issue.yaml`.
  - File: `skills/writing-plans/tasks/self-review.md`
  - Dispatch: `test-driven-development --task green` (**clean-room**)
  - Context: `{issue_number: 2085, plan_path: ".opencode/.issues/2085/plan.md", spec_path: ".opencode/.issues/2085/issue.yaml", target_file: "skills/writing-plans/tasks/self-review.md"}`
- [ ] 8. **Z3 check GREEN.** Validate GREEN state.
  - Dispatch: `solve --task check` (**inline**)
- [ ] 9. **Post-GREEN enforcement.** Enforce GREEN gate.
  - Dispatch: `implementation-pipeline --task post-green-enforcement` (**clean-room**)
  - Context: `{issue_number: 2085}`
- [ ] 10. **Z3 check post-GREEN.** Validate post-GREEN state.
  - Dispatch: `solve --task check` (**inline**)
- [ ] 11. **Checkpoint tag.** Create checkpoint tag.
  - Dispatch: `implementation-pipeline --task checkpoint-tag-create` (**clean-room**)
  - Context: `{issue_number: 2085}`
- [ ] 12. **Checkpoint commit.** Commit with checkpoint.
  - Files: `skills/writing-plans/tasks/self-review.md`
  - Dispatch: `git-workflow --task commit-prep` (**clean-room**)
  - Context: `{issue_number: 2085, files: ["skills/writing-plans/tasks/self-review.md"]}`

### Task 7: Remove old task files and create contract templates

- [ ] 1. **RED.** Write failing test asserting old files are removed and contracts exist.
  - Test file: `tests/behaviors/writing-plans-cleanup.sh`
  - Expected failure: old files still exist
  - Dispatch: `test-driven-development --task red` (**clean-room**)
  - Context: `{issue_number: 2085, plan_path: ".opencode/.issues/2085/plan.md", test_file: "tests/behaviors/writing-plans-cleanup.sh", expected_failure: "old files still exist"}`
- [ ] 2. **Z3 check RED.** Validate RED state.
  - Dispatch: `solve --task check` (**inline**)
- [ ] 3. **RED doublecheck.** Verify RED test fails correctly.
  - Dispatch: `verification-before-completion --task verify` (**clean-room**)
  - Context: `{issue_number: 2085, plan_path: ".opencode/.issues/2085/plan.md"}`
- [ ] 4. **Z3 check RED doublecheck.** Validate RED doublecheck state.
  - Dispatch: `solve --task check` (**inline**)
- [ ] 5. **Post-RED enforcement.** Enforce RED gate.
  - Dispatch: `implementation-pipeline --task post-red-enforcement` (**clean-room**)
  - Context: `{issue_number: 2085}`
- [ ] 6. **Z3 check post-RED.** Validate post-RED state.
  - Dispatch: `solve --task check` (**inline**)
- [ ] 7. **GREEN.** Remove `skills/writing-plans/tasks/retroactive.md` and `skills/writing-plans/tasks/explore.md`. Create 18 contract templates at `skills/writing-plans/contracts/`. Simplify `skills/writing-plans/reference/plan-artifact-format.md` per spec §File Structure and SC-14, SC-15 at `.opencode/.issues/2085/issue.yaml`.
  - Files: remove `tasks/retroactive.md`, remove `tasks/explore.md`, create `contracts/` templates, modify `reference/plan-artifact-format.md`
  - Dispatch: `test-driven-development --task green` (**clean-room**)
  - Context: `{issue_number: 2085, plan_path: ".opencode/.issues/2085/plan.md", spec_path: ".opencode/.issues/2085/issue.yaml", target_files: ["skills/writing-plans/tasks/retroactive.md", "skills/writing-plans/tasks/explore.md", "skills/writing-plans/contracts/", "skills/writing-plans/reference/plan-artifact-format.md"]}`
- [ ] 8. **Z3 check GREEN.** Validate GREEN state.
  - Dispatch: `solve --task check` (**inline**)
- [ ] 9. **Post-GREEN enforcement.** Enforce GREEN gate.
  - Dispatch: `implementation-pipeline --task post-green-enforcement` (**clean-room**)
  - Context: `{issue_number: 2085}`
- [ ] 10. **Z3 check post-GREEN.** Validate post-GREEN state.
  - Dispatch: `solve --task check` (**inline**)
- [ ] 11. **Checkpoint tag.** Create checkpoint tag.
  - Dispatch: `implementation-pipeline --task checkpoint-tag-create` (**clean-room**)
  - Context: `{issue_number: 2085}`
- [ ] 12. **Checkpoint commit.** Commit with checkpoint.
  - Files: removed files, new contracts, modified reference
  - Dispatch: `git-workflow --task commit-prep` (**clean-room**)
  - Context: `{issue_number: 2085, files: ["skills/writing-plans/tasks/retroactive.md", "skills/writing-plans/tasks/explore.md", "skills/writing-plans/contracts/", "skills/writing-plans/reference/plan-artifact-format.md"]}`

---

## Phase 2: Behavioral tests

**Concern:** Update existing writing-plans behavioral test and add explore skill behavioral test.
**Files:**
- Modify: `tests/behaviors/writing-plans.sh`
- Create: `tests/behaviors/explore-skill.sh`
**SCs:** SC-16
**Depends On:** Phase 1

### Task 1: Update writing-plans behavioral test

- [ ] 1. **RED.** Write failing test asserting new writing-plans behavior.
  - Test file: `tests/behaviors/writing-plans.sh`
  - Expected failure: old behavior
  - Dispatch: `test-driven-development --task red` (**clean-room**)
  - Context: `{issue_number: 2085, plan_path: ".opencode/.issues/2085/plan.md", test_file: "tests/behaviors/writing-plans.sh", expected_failure: "old behavior"}`
- [ ] 2. **Z3 check RED.** Validate RED state.
  - Dispatch: `solve --task check` (**inline**)
- [ ] 3. **RED doublecheck.** Verify RED test fails correctly.
  - Dispatch: `verification-before-completion --task verify` (**clean-room**)
  - Context: `{issue_number: 2085, plan_path: ".opencode/.issues/2085/plan.md"}`
- [ ] 4. **Z3 check RED doublecheck.** Validate RED doublecheck state.
  - Dispatch: `solve --task check` (**inline**)
- [ ] 5. **Post-RED enforcement.** Enforce RED gate.
  - Dispatch: `implementation-pipeline --task post-red-enforcement` (**clean-room**)
  - Context: `{issue_number: 2085}`
- [ ] 6. **Z3 check post-RED.** Validate post-RED state.
  - Dispatch: `solve --task check` (**inline**)
- [ ] 7. **GREEN.** Update `tests/behaviors/writing-plans.sh` to verify new workflow tables, 9 task cards, and plan format.
  - File: `tests/behaviors/writing-plans.sh`
  - Dispatch: `test-driven-development --task green` (**clean-room**)
  - Context: `{issue_number: 2085, plan_path: ".opencode/.issues/2085/plan.md", target_file: "tests/behaviors/writing-plans.sh"}`
- [ ] 8. **Z3 check GREEN.** Validate GREEN state.
  - Dispatch: `solve --task check` (**inline**)
- [ ] 9. **Post-GREEN enforcement.** Enforce GREEN gate.
  - Dispatch: `implementation-pipeline --task post-green-enforcement` (**clean-room**)
  - Context: `{issue_number: 2085}`
- [ ] 10. **Z3 check post-GREEN.** Validate post-GREEN state.
  - Dispatch: `solve --task check` (**inline**)
- [ ] 11. **Checkpoint tag.** Create checkpoint tag.
  - Dispatch: `implementation-pipeline --task checkpoint-tag-create` (**clean-room**)
  - Context: `{issue_number: 2085}`
- [ ] 12. **Checkpoint commit.** Commit with checkpoint.
  - Files: `tests/behaviors/writing-plans.sh`
  - Dispatch: `git-workflow --task commit-prep` (**clean-room**)
  - Context: `{issue_number: 2085, files: ["tests/behaviors/writing-plans.sh"]}`

### Task 2: Create explore skill behavioral test

- [ ] 1. **RED.** Write failing test asserting explore skill dispatches correctly.
  - Test file: `tests/behaviors/explore-skill.sh`
  - Expected failure: explore skill doesn't exist yet
  - Dispatch: `test-driven-development --task red` (**clean-room**)
  - Context: `{issue_number: 2085, plan_path: ".opencode/.issues/2085/plan.md", test_file: "tests/behaviors/explore-skill.sh", expected_failure: "explore skill doesn't exist yet"}`
- [ ] 2. **Z3 check RED.** Validate RED state.
  - Dispatch: `solve --task check` (**inline**)
- [ ] 3. **RED doublecheck.** Verify RED test fails correctly.
  - Dispatch: `verification-before-completion --task verify` (**clean-room**)
  - Context: `{issue_number: 2085, plan_path: ".opencode/.issues/2085/plan.md"}`
- [ ] 4. **Z3 check RED doublecheck.** Validate RED doublecheck state.
  - Dispatch: `solve --task check` (**inline**)
- [ ] 5. **Post-RED enforcement.** Enforce RED gate.
  - Dispatch: `implementation-pipeline --task post-red-enforcement` (**clean-room**)
  - Context: `{issue_number: 2085}`
- [ ] 6. **Z3 check post-RED.** Validate post-RED state.
  - Dispatch: `solve --task check` (**inline**)
- [ ] 7. **GREEN.** Create `tests/behaviors/explore-skill.sh` to verify explore skill dispatches correctly.
  - File: `tests/behaviors/explore-skill.sh`
  - Dispatch: `test-driven-development --task green` (**clean-room**)
  - Context: `{issue_number: 2085, plan_path: ".opencode/.issues/2085/plan.md", target_file: "tests/behaviors/explore-skill.sh"}`
- [ ] 8. **Z3 check GREEN.** Validate GREEN state.
  - Dispatch: `solve --task check` (**inline**)
- [ ] 9. **Post-GREEN enforcement.** Enforce GREEN gate.
  - Dispatch: `implementation-pipeline --task post-green-enforcement` (**clean-room**)
  - Context: `{issue_number: 2085}`
- [ ] 10. **Z3 check post-GREEN.** Validate post-GREEN state.
  - Dispatch: `solve --task check` (**inline**)
- [ ] 11. **Checkpoint tag.** Create checkpoint tag.
  - Dispatch: `implementation-pipeline --task checkpoint-tag-create` (**clean-room**)
  - Context: `{issue_number: 2085}`
- [ ] 12. **Checkpoint commit.** Commit with checkpoint.
  - Files: `tests/behaviors/explore-skill.sh`
  - Dispatch: `git-workflow --task commit-prep` (**clean-room**)
  - Context: `{issue_number: 2085, files: ["tests/behaviors/explore-skill.sh"]}`

---

## Post-Implementation

- [ ] 1. **SC-12 verification.** Verify plan artifact has no machine-parseable cross-references, no REQ-001/TASK-001 patterns, no JSON/YAML code blocks in body.
  - Dispatch: `verification-before-completion --task verify` (**clean-room**)
  - Context: `{issue_number: 2085, sc_id: "SC-12", evidence_type: "string", check: "grep for REQ-001/TASK-001/JSON/YAML code blocks in plan body"}`
- [ ] 2. **SC-13 verification.** Verify plan artifact follows KISS/DRY/Unix: each task does one action, no repeated code blocks, simple format.
  - Dispatch: `verification-before-completion --task verify` (**clean-room**)
  - Context: `{issue_number: 2085, sc_id: "SC-13", evidence_type: "semantic", check: "sub-agent reads plan and judges KISS/DRY/Unix compliance"}`
- [ ] 3. **Structural checks.** Run lint and typecheck.
  - Dispatch: `finishing-a-development-branch --task checklist` (**clean-room**)
  - Context: `{issue_number: 2085}`
- [ ] 2. **GREEN doublecheck.** Verify all GREEN passes.
  - Dispatch: `verification-before-completion --task verify` (**clean-room**)
  - Context: `{issue_number: 2085}`
- [ ] 3. **VbC.** Verification before completion.
  - Dispatch: `verification-before-completion --task completion` (**clean-room**)
  - Context: `{issue_number: 2085}`
- [ ] 4. **SC count gate.** Verify all SCs have verdicts.
  - Dispatch: `implementation-pipeline --task sc-count-gate` (**clean-room**)
  - Context: `{issue_number: 2085}`
- [ ] 5. **Pre-PR gate.** Block on any FAIL.
  - Dispatch: `verification-before-completion --task verify` (**clean-room**)
  - Context: `{issue_number: 2085}`
- [ ] 6. **Audit.** Independent audit.
  - Dispatch: `audit` skill (**clean-room**)
  - Context: `{issue_number: 2085}`
- [ ] 7. **Cross-validate.** Consensus check.
  - Dispatch: `audit --task cross-validate` (**clean-room**)
  - Context: `{issue_number: 2085}`
- [ ] 8. **Regression check.** Run regression tests.
  - Dispatch: `test-driven-development --task patterns` (**clean-room**)
  - Context: `{issue_number: 2085}`
- [ ] 9. **Review prep.** Prepare for review.
  - Dispatch: `git-workflow --task review-prep` (**clean-room**)
  - Context: `{issue_number: 2085}`
- [ ] 10. **Create PR.** Create pull request.
  - Dispatch: `pr-creation-workflow --task create` (**clean-room**)
  - Context: `{issue_number: 2085}`
- [ ] 11. **Exec summary.** Completion report.
  - Dispatch: `completion-core --task completion` (**clean-room**)
  - Context: `{issue_number: 2085}`
