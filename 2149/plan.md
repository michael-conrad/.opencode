---
plan_schema_version: "1.0"
issue: 2149
title: "PR body writer uses invalid GitHub closing keyword syntax"
dispatch:
  - phase: phase-1
    skill: implementation-pipeline
    task: assemble-work
  - phase: phase-2
    skill: implementation-pipeline
    task: assemble-work
  - phase: phase-3
    skill: implementation-pipeline
    task: assemble-work
---

## Pre-Implementation

- [ ] **Coherence gate** — dispatch `sc-coherence-gate` from implementation-pipeline. Verify spec/plan coherence before RED routing. (**sub-agent**)
  - Context: issue_number=2149
- [ ] **Baseline check** — dispatch `pre-red-baseline` from implementation-pipeline. Verify baseline state before any RED phase. (**sub-agent**)
  - Context: issue_number=2149

## Phase 1: Centralized closing-keyword formatter

**Concern:** Create a centralized closing-keyword formatter, update all PR body generation files, update downstream consumers, and add behavioral tests for valid keyword usage.
**SC coverage:** SC-1, SC-3

### Item 1 — SC-1: PR body uses only valid GitHub closing keywords

- [ ] **RED phase** — dispatch `red-phase` from implementation-pipeline. Write a failing behavioral enforcement test that verifies the agent uses only valid GitHub closing keywords (`Fixes`/`Closes`/`Resolves`/`Implements`). (**sub-agent**)
  - Context: issue_number=2149, sc=SC-1
- [ ] **Z3 check RED** — dispatch `z3-check-red` from implementation-pipeline. Validate RED step state transition. (**inline**)
  - Context: issue_number=2149
- [ ] **RED doublecheck** — dispatch `red-doublecheck` from implementation-pipeline. Verify RED test is correctly failing. (**sub-agent**)
  - Context: issue_number=2149, sc=SC-1
- [ ] **Z3 check RED doublecheck** — dispatch `z3-check-red-doublecheck` from implementation-pipeline. Validate RED doublecheck state transition. (**inline**)
  - Context: issue_number=2149
- [ ] **Post-RED enforcement** — dispatch `post-red-enforcement` from implementation-pipeline. Enforce RED gate. (**sub-agent**)
  - Context: issue_number=2149
- [ ] **Z3 check post-RED** — dispatch `z3-check-post-red` from implementation-pipeline. Validate post-RED state transition. (**inline**)
  - Context: issue_number=2149
- [ ] **GREEN phase** — dispatch `green-phase` from implementation-pipeline. Create a centralized closing-keyword formatter utility and update all PR body generation files to use it. (**sub-agent**)
  - Context: issue_number=2149, sc=SC-1
- [ ] **Z3 check GREEN** — dispatch `z3-check-green` from implementation-pipeline. Validate GREEN step state transition. (**inline**)
  - Context: issue_number=2149
- [ ] **Post-GREEN enforcement** — dispatch `post-green-enforcement` from implementation-pipeline. Enforce GREEN gate. (**sub-agent**)
  - Context: issue_number=2149
- [ ] **Z3 check post-GREEN** — dispatch `z3-check-post-green` from implementation-pipeline. Validate post-GREEN state transition. (**inline**)
  - Context: issue_number=2149
- [ ] **Checkpoint tag create** — dispatch `checkpoint-tag-create` from implementation-pipeline. Create checkpoint tag for this item. (**sub-agent**)
  - Context: issue_number=2149, item=item-1
- [ ] **Checkpoint commit** — dispatch `checkpoint-commit` from implementation-pipeline. Commit checkpoint. (**sub-agent**)
  - Context: issue_number=2149
- [ ] **Structural checks** — dispatch `structural-checks` from implementation-pipeline. Run lint/typecheck on modified files. (**sub-agent**)
  - Context: issue_number=2149
- [ ] **GREEN doublecheck** — dispatch `green-doublecheck` from implementation-pipeline. Verify GREEN implementation is correct. (**sub-agent**)
  - Context: issue_number=2149, sc=SC-1
- [ ] **GREEN VbC** — dispatch `green-vbc` from implementation-pipeline. Verification before completion for this item. (**sub-agent**)
  - Context: issue_number=2149, sc=SC-1

### Item 2 — SC-3: All PR body generation files use centralized formatter

- [ ] **RED phase** — dispatch `red-phase` from implementation-pipeline. Write a failing test that verifies all PR body generation files use the centralized formatter (or consistently correct inline patterns). (**sub-agent**)
  - Context: issue_number=2149, sc=SC-3
- [ ] **Z3 check RED** — dispatch `z3-check-red` from implementation-pipeline. Validate RED step state transition. (**inline**)
  - Context: issue_number=2149
- [ ] **RED doublecheck** — dispatch `red-doublecheck` from implementation-pipeline. Verify RED test is correctly failing. (**sub-agent**)
  - Context: issue_number=2149, sc=SC-3
- [ ] **Z3 check RED doublecheck** — dispatch `z3-check-red-doublecheck` from implementation-pipeline. Validate RED doublecheck state transition. (**inline**)
  - Context: issue_number=2149
- [ ] **Post-RED enforcement** — dispatch `post-red-enforcement` from implementation-pipeline. Enforce RED gate. (**sub-agent**)
  - Context: issue_number=2149
- [ ] **Z3 check post-RED** — dispatch `z3-check-post-red` from implementation-pipeline. Validate post-RED state transition. (**inline**)
  - Context: issue_number=2149
- [ ] **GREEN phase** — dispatch `green-phase` from implementation-pipeline. Update remaining PR body generation files to use the centralized formatter. (**sub-agent**)
  - Context: issue_number=2149, sc=SC-3
- [ ] **Z3 check GREEN** — dispatch `z3-check-green` from implementation-pipeline. Validate GREEN step state transition. (**inline**)
  - Context: issue_number=2149
- [ ] **Post-GREEN enforcement** — dispatch `post-green-enforcement` from implementation-pipeline. Enforce GREEN gate. (**sub-agent**)
  - Context: issue_number=2149
- [ ] **Z3 check post-GREEN** — dispatch `z3-check-post-green` from implementation-pipeline. Validate post-GREEN state transition. (**inline**)
  - Context: issue_number=2149
- [ ] **Checkpoint tag create** — dispatch `checkpoint-tag-create` from implementation-pipeline. Create checkpoint tag for this item. (**sub-agent**)
  - Context: issue_number=2149, item=item-2
- [ ] **Checkpoint commit** — dispatch `checkpoint-commit` from implementation-pipeline. Commit checkpoint. (**sub-agent**)
  - Context: issue_number=2149
- [ ] **Structural checks** — dispatch `structural-checks` from implementation-pipeline. Run lint/typecheck on modified files. (**sub-agent**)
  - Context: issue_number=2149
- [ ] **GREEN doublecheck** — dispatch `green-doublecheck` from implementation-pipeline. Verify GREEN implementation is correct. (**sub-agent**)
  - Context: issue_number=2149, sc=SC-3
- [ ] **GREEN VbC** — dispatch `green-vbc` from implementation-pipeline. Verification before completion for this item. (**sub-agent**)
  - Context: issue_number=2149, sc=SC-3

## Phase 2: Cross-repo closing keyword support

**Concern:** Add cross-repo detection logic to all PR body generation files so that `owner/repo#N` format is used when the issue repo differs from the PR repo.
**SC coverage:** SC-2

### Item 3 — SC-2: Cross-repo references use owner/repo#N format

- [ ] **RED phase** — dispatch `red-phase` from implementation-pipeline. Write a failing behavioral enforcement test that verifies the agent uses `owner/repo#N` format when the issue repo differs from the PR repo. (**sub-agent**)
  - Context: issue_number=2149, sc=SC-2
- [ ] **Z3 check RED** — dispatch `z3-check-red` from implementation-pipeline. Validate RED step state transition. (**inline**)
  - Context: issue_number=2149
- [ ] **RED doublecheck** — dispatch `red-doublecheck` from implementation-pipeline. Verify RED test is correctly failing. (**sub-agent**)
  - Context: issue_number=2149, sc=SC-2
- [ ] **Z3 check RED doublecheck** — dispatch `z3-check-red-doublecheck` from implementation-pipeline. Validate RED doublecheck state transition. (**inline**)
  - Context: issue_number=2149
- [ ] **Post-RED enforcement** — dispatch `post-red-enforcement` from implementation-pipeline. Enforce RED gate. (**sub-agent**)
  - Context: issue_number=2149
- [ ] **Z3 check post-RED** — dispatch `z3-check-post-red` from implementation-pipeline. Validate post-RED state transition. (**inline**)
  - Context: issue_number=2149
- [ ] **GREEN phase** — dispatch `green-phase` from implementation-pipeline. Add cross-repo detection logic to the centralized formatter and all PR body generation files. (**sub-agent**)
  - Context: issue_number=2149, sc=SC-2
- [ ] **Z3 check GREEN** — dispatch `z3-check-green` from implementation-pipeline. Validate GREEN step state transition. (**inline**)
  - Context: issue_number=2149
- [ ] **Post-GREEN enforcement** — dispatch `post-green-enforcement` from implementation-pipeline. Enforce GREEN gate. (**sub-agent**)
  - Context: issue_number=2149
- [ ] **Z3 check post-GREEN** — dispatch `z3-check-post-green` from implementation-pipeline. Validate post-GREEN state transition. (**inline**)
  - Context: issue_number=2149
- [ ] **Checkpoint tag create** — dispatch `checkpoint-tag-create` from implementation-pipeline. Create checkpoint tag for this item. (**sub-agent**)
  - Context: issue_number=2149, item=item-3
- [ ] **Checkpoint commit** — dispatch `checkpoint-commit` from implementation-pipeline. Commit checkpoint. (**sub-agent**)
  - Context: issue_number=2149
- [ ] **Structural checks** — dispatch `structural-checks` from implementation-pipeline. Run lint/typecheck on modified files. (**sub-agent**)
  - Context: issue_number=2149
- [ ] **GREEN doublecheck** — dispatch `green-doublecheck` from implementation-pipeline. Verify GREEN implementation is correct. (**sub-agent**)
  - Context: issue_number=2149, sc=SC-2
- [ ] **GREEN VbC** — dispatch `green-vbc` from implementation-pipeline. Verification before completion for this item. (**sub-agent**)
  - Context: issue_number=2149, sc=SC-2

## Phase 3: Standalone reference and terminology fixes

**Concern:** Fix invalid reference syntax in `skill-card-change-types.md` and rename "autoclose list" to "issue-reference list" in `sub-issue-collection.md`.
**SC coverage:** SC-4, SC-5

### Item 4 — SC-4: skill-card-change-types.md uses valid GitHub reference syntax

- [ ] **RED phase** — dispatch `red-phase` from implementation-pipeline. Write a failing test that verifies `skill-card-change-types.md` does not use `.opencode#N` pattern. (**sub-agent**)
  - Context: issue_number=2149, sc=SC-4
- [ ] **Z3 check RED** — dispatch `z3-check-red` from implementation-pipeline. Validate RED step state transition. (**inline**)
  - Context: issue_number=2149
- [ ] **RED doublecheck** — dispatch `red-doublecheck` from implementation-pipeline. Verify RED test is correctly failing. (**sub-agent**)
  - Context: issue_number=2149, sc=SC-4
- [ ] **Z3 check RED doublecheck** — dispatch `z3-check-red-doublecheck` from implementation-pipeline. Validate RED doublecheck state transition. (**inline**)
  - Context: issue_number=2149
- [ ] **Post-RED enforcement** — dispatch `post-red-enforcement` from implementation-pipeline. Enforce RED gate. (**sub-agent**)
  - Context: issue_number=2149
- [ ] **Z3 check post-RED** — dispatch `z3-check-post-red` from implementation-pipeline. Validate post-RED state transition. (**inline**)
  - Context: issue_number=2149
- [ ] **GREEN phase** — dispatch `green-phase` from implementation-pipeline. Fix `.opencode#N` references in `skill-card-change-types.md` to use valid GitHub reference syntax. (**sub-agent**)
  - Context: issue_number=2149, sc=SC-4
- [ ] **Z3 check GREEN** — dispatch `z3-check-green` from implementation-pipeline. Validate GREEN step state transition. (**inline**)
  - Context: issue_number=2149
- [ ] **Post-GREEN enforcement** — dispatch `post-green-enforcement` from implementation-pipeline. Enforce GREEN gate. (**sub-agent**)
  - Context: issue_number=2149
- [ ] **Z3 check post-GREEN** — dispatch `z3-check-post-green` from implementation-pipeline. Validate post-GREEN state transition. (**inline**)
  - Context: issue_number=2149
- [ ] **Checkpoint tag create** — dispatch `checkpoint-tag-create` from implementation-pipeline. Create checkpoint tag for this item. (**sub-agent**)
  - Context: issue_number=2149, item=item-4
- [ ] **Checkpoint commit** — dispatch `checkpoint-commit` from implementation-pipeline. Commit checkpoint. (**sub-agent**)
  - Context: issue_number=2149
- [ ] **Structural checks** — dispatch `structural-checks` from implementation-pipeline. Run lint/typecheck on modified files. (**sub-agent**)
  - Context: issue_number=2149
- [ ] **GREEN doublecheck** — dispatch `green-doublecheck` from implementation-pipeline. Verify GREEN implementation is correct. (**sub-agent**)
  - Context: issue_number=2149, sc=SC-4
- [ ] **GREEN VbC** — dispatch `green-vbc` from implementation-pipeline. Verification before completion for this item. (**sub-agent**)
  - Context: issue_number=2149, sc=SC-4

### Item 5 — SC-5: "autoclose list" renamed to "issue-reference list"

- [ ] **RED phase** — dispatch `red-phase` from implementation-pipeline. Write a failing test that verifies `sub-issue-collection.md` uses "issue-reference list" instead of "autoclose list". (**sub-agent**)
  - Context: issue_number=2149, sc=SC-5
- [ ] **Z3 check RED** — dispatch `z3-check-red` from implementation-pipeline. Validate RED step state transition. (**inline**)
  - Context: issue_number=2149
- [ ] **RED doublecheck** — dispatch `red-doublecheck` from implementation-pipeline. Verify RED test is correctly failing. (**sub-agent**)
  - Context: issue_number=2149, sc=SC-5
- [ ] **Z3 check RED doublecheck** — dispatch `z3-check-red-doublecheck` from implementation-pipeline. Validate RED doublecheck state transition. (**inline**)
  - Context: issue_number=2149
- [ ] **Post-RED enforcement** — dispatch `post-red-enforcement` from implementation-pipeline. Enforce RED gate. (**sub-agent**)
  - Context: issue_number=2149
- [ ] **Z3 check post-RED** — dispatch `z3-check-post-red` from implementation-pipeline. Validate post-RED state transition. (**inline**)
  - Context: issue_number=2149
- [ ] **GREEN phase** — dispatch `green-phase` from implementation-pipeline. Rename "autoclose list" to "issue-reference list" in `sub-issue-collection.md`. (**sub-agent**)
  - Context: issue_number=2149, sc=SC-5
- [ ] **Z3 check GREEN** — dispatch `z3-check-green` from implementation-pipeline. Validate GREEN step state transition. (**inline**)
  - Context: issue_number=2149
- [ ] **Post-GREEN enforcement** — dispatch `post-green-enforcement` from implementation-pipeline. Enforce GREEN gate. (**sub-agent**)
  - Context: issue_number=2149
- [ ] **Z3 check post-GREEN** — dispatch `z3-check-post-green` from implementation-pipeline. Validate post-GREEN state transition. (**inline**)
  - Context: issue_number=2149
- [ ] **Checkpoint tag create** — dispatch `checkpoint-tag-create` from implementation-pipeline. Create checkpoint tag for this item. (**sub-agent**)
  - Context: issue_number=2149, item=item-5
- [ ] **Checkpoint commit** — dispatch `checkpoint-commit` from implementation-pipeline. Commit checkpoint. (**sub-agent**)
  - Context: issue_number=2149
- [ ] **Structural checks** — dispatch `structural-checks` from implementation-pipeline. Run lint/typecheck on modified files. (**sub-agent**)
  - Context: issue_number=2149
- [ ] **GREEN doublecheck** — dispatch `green-doublecheck` from implementation-pipeline. Verify GREEN implementation is correct. (**sub-agent**)
  - Context: issue_number=2149, sc=SC-5
- [ ] **GREEN VbC** — dispatch `green-vbc` from implementation-pipeline. Verification before completion for this item. (**sub-agent**)
  - Context: issue_number=2149, sc=SC-5

## Post-Implementation

- [ ] **SC count gate** — dispatch `sc-count-gate` from implementation-pipeline. Verify all SCs have verdicts. (**sub-agent**)
  - Context: issue_number=2149
- [ ] **Pre-PR gate** — dispatch `pre-pr-gate` from implementation-pipeline. Verify no SC has a FAIL verdict. (**sub-agent**)
  - Context: issue_number=2149
- [ ] **Rationalization check** — dispatch `rationalization-check` from implementation-pipeline. Verify no rationalization of skipped steps. (**sub-agent**)
  - Context: issue_number=2149
- [ ] **Audit** — dispatch audit task from audit skill. Phase-appropriate audit of the implementation. (**sub-agent**)
  - Context: issue_number=2149
- [ ] **Cross-validate** — dispatch `cross-validate` from audit. Consensus check on audit findings. (**sub-agent**)
  - Context: issue_number=2149
- [ ] **Regression check** — dispatch `regression-check` from implementation-pipeline. Run regression tests. (**sub-agent**)
  - Context: issue_number=2149
- [ ] **Review prep** — dispatch `review-prep` from git-workflow. Prepare PR for review. (**sub-agent**)
  - Context: issue_number=2149
- [ ] **Create PR** — dispatch `create-pr` from pr-creation-workflow. Create pull request. (**sub-agent**)
  - Context: issue_number=2149, authorization_scope=for_pr, halt_at=pr_created
- [ ] **Executive summary** — dispatch `exec-summary` from completion-core. Report completion. (**sub-agent**)
  - Context: issue_number=2149
