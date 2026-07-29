---
plan_schema_version: "1.0"
issue: 2170
title: "Git workflow regression: three root causes in cleanup/authorization/pointer lifecycle"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 4
dispatch:
  - phase: 1
    skill: test-driven-development
    task: red
  - phase: 2
    skill: test-driven-development
    task: red
  - phase: 3
    skill: test-driven-development
    task: red
  - phase: 4
    skill: test-driven-development
    task: red
---

# Implementation Plan — #2170 — Git Workflow Regression Fixes

**Goal:** Resolve three distinct root causes in the git workflow: dirty pointer deadlock, check-pr authorization ambiguity, and excessive deliberation about cleanup authorization.

**Architecture:** Each phase targets a separate concern with independent file modifications. All 4 phases are independent — no phase depends on the output of another phase. Each item follows the per-task cycle from the implementation-pipeline Trigger Dispatch Table.

**Files:**
- `.opencode/skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md`
- `.opencode/skills/git-workflow-branch/tasks/pre-work.md`
- `.opencode/skills/git-workflow-cleanup/tasks/check-pr.md`
- `.git/hooks/pre-push`
- `.opencode/guidelines/010-approval-gate.md`
- `.opencode/guidelines/020-go-prohibitions.md`

---

## Pre-Implementation Steps

- [ ] **Coherence gate.** Dispatch `audit --task coherence-extraction` to verify spec/plan coherence. Context: issue 2170.
- [ ] **Pre-RED baseline.** Dispatch `implementation-pipeline --task pre-red-baseline` to capture current state of all affected files before any modifications. Context: issue 2170.

---

## Phase 1 — Resolve Dirty Pointer Deadlock

**Concern:** Submodule pointer lifecycle must have a single unambiguous path: cleanup leaves dirty, pointer commits only alongside real code changes on a feature branch.

**Files:**
- `.opencode/skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md`
- `.opencode/skills/git-workflow-branch/tasks/pre-work.md`

**SCs:** SC-1a, SC-1b, SC-1c

**Dependencies:** None

**Entry Conditions:**
- Pre-implementation steps complete
- Feature branch exists

**Exit Conditions:**
- branch-cleanup.md has explicit dirty pointer exemption statement
- pre-work.md No-Op Branch Guard cross-references branch-cleanup.md
- Behavioral test verifies no deliberation about pointer handling during cleanup

---

### Item 1 — SC-1a: branch-cleanup.md dirty pointer exemption

- [ ] **RED phase.** Dispatch `test-driven-development --task red` to write a content-verification test asserting branch-cleanup.md contains the pointer lifecycle statement. SC-1a.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Z3 check RED.** Dispatch `solve --task check` to validate RED phase state transition. SC-1a.
  - Dispatch indicator: inline
  - Context: issue 2170, contract path from dependency-contract.yaml
- [ ] **RED doublecheck.** Dispatch `verification-before-completion --task verify` to confirm RED test fails as expected. SC-1a.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Z3 check RED doublecheck.** Dispatch `solve --task check` to validate RED doublecheck state transition. SC-1a.
  - Dispatch indicator: inline
  - Context: issue 2170, contract path from dependency-contract.yaml
- [ ] **Post-RED enforcement.** Dispatch `implementation-pipeline --task post-red-enforcement` to verify RED gate conditions. SC-1a.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Z3 check post-RED.** Dispatch `solve --task check` to validate post-RED state transition. SC-1a.
  - Dispatch indicator: inline
  - Context: issue 2170, contract path from dependency-contract.yaml
- [ ] **GREEN phase.** Dispatch `test-driven-development --task green` to update branch-cleanup.md with the pointer lifecycle statement. SC-1a.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Z3 check GREEN.** Dispatch `solve --task check` to validate GREEN phase state transition. SC-1a.
  - Dispatch indicator: inline
  - Context: issue 2170, contract path from dependency-contract.yaml
- [ ] **Post-GREEN enforcement.** Dispatch `implementation-pipeline --task post-green-enforcement` to verify GREEN gate conditions. SC-1a.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Z3 check post-GREEN.** Dispatch `solve --task check` to validate post-GREEN state transition. SC-1a.
  - Dispatch indicator: inline
  - Context: issue 2170, contract path from dependency-contract.yaml
- [ ] **Checkpoint tag create.** Dispatch `implementation-pipeline --task checkpoint-tag-create` to create checkpoint tag. SC-1a.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Checkpoint commit.** Dispatch `git-workflow --task commit-prep` to commit SC-1a changes. SC-1a.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Structural checks.** Dispatch `finishing-a-development-branch --task checklist` to run lint/typecheck. SC-1a.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **GREEN doublecheck.** Dispatch `verification-before-completion --task verify` to confirm SC-1a content change is correct. SC-1a.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **GREEN VbC.** Dispatch `verification-before-completion --task completion` to produce SC-1a verdict. SC-1a.
  - Dispatch indicator: clean-room
  - Context: issue 2170

---

### Item 2 — SC-1b: pre-work.md No-Op Branch Guard cross-reference

- [ ] **RED phase.** Dispatch `test-driven-development --task red` to write a content-verification test asserting pre-work.md cross-references branch-cleanup.md. SC-1b.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Z3 check RED.** Dispatch `solve --task check` to validate RED phase state transition. SC-1b.
  - Dispatch indicator: inline
  - Context: issue 2170, contract path from dependency-contract.yaml
- [ ] **RED doublecheck.** Dispatch `verification-before-completion --task verify` to confirm RED test fails as expected. SC-1b.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Z3 check RED doublecheck.** Dispatch `solve --task check` to validate RED doublecheck state transition. SC-1b.
  - Dispatch indicator: inline
  - Context: issue 2170, contract path from dependency-contract.yaml
- [ ] **Post-RED enforcement.** Dispatch `implementation-pipeline --task post-red-enforcement` to verify RED gate conditions. SC-1b.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Z3 check post-RED.** Dispatch `solve --task check` to validate post-RED state transition. SC-1b.
  - Dispatch indicator: inline
  - Context: issue 2170, contract path from dependency-contract.yaml
- [ ] **GREEN phase.** Dispatch `test-driven-development --task green` to update pre-work.md with cross-reference to branch-cleanup.md. SC-1b.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Z3 check GREEN.** Dispatch `solve --task check` to validate GREEN phase state transition. SC-1b.
  - Dispatch indicator: inline
  - Context: issue 2170, contract path from dependency-contract.yaml
- [ ] **Post-GREEN enforcement.** Dispatch `implementation-pipeline --task post-green-enforcement` to verify GREEN gate conditions. SC-1b.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Z3 check post-GREEN.** Dispatch `solve --task check` to validate post-GREEN state transition. SC-1b.
  - Dispatch indicator: inline
  - Context: issue 2170, contract path from dependency-contract.yaml
- [ ] **Checkpoint tag create.** Dispatch `implementation-pipeline --task checkpoint-tag-create` to create checkpoint tag. SC-1b.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Checkpoint commit.** Dispatch `git-workflow --task commit-prep` to commit SC-1b changes. SC-1b.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Structural checks.** Dispatch `finishing-a-development-branch --task checklist` to run lint/typecheck. SC-1b.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **GREEN doublecheck.** Dispatch `verification-before-completion --task verify` to confirm SC-1b content change is correct. SC-1b.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **GREEN VbC.** Dispatch `verification-before-completion --task completion` to produce SC-1b verdict. SC-1b.
  - Dispatch indicator: clean-room
  - Context: issue 2170

---

### Item 3 — SC-1c: Behavioral test for no deliberation about pointer handling

- [ ] **RED phase.** Dispatch `test-driven-development --task red` to write a behavioral enforcement test asserting agent does not deliberate about submodule pointer handling during cleanup. SC-1c.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Z3 check RED.** Dispatch `solve --task check` to validate RED phase state transition. SC-1c.
  - Dispatch indicator: inline
  - Context: issue 2170, contract path from dependency-contract.yaml
- [ ] **RED doublecheck.** Dispatch `verification-before-completion --task verify` to confirm RED behavioral test fails as expected. SC-1c.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Z3 check RED doublecheck.** Dispatch `solve --task check` to validate RED doublecheck state transition. SC-1c.
  - Dispatch indicator: inline
  - Context: issue 2170, contract path from dependency-contract.yaml
- [ ] **Post-RED enforcement.** Dispatch `implementation-pipeline --task post-red-enforcement` to verify RED gate conditions. SC-1c.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Z3 check post-RED.** Dispatch `solve --task check` to validate post-RED state transition. SC-1c.
  - Dispatch indicator: inline
  - Context: issue 2170, contract path from dependency-contract.yaml
- [ ] **GREEN phase.** Dispatch `test-driven-development --task green` to update branch-cleanup.md and pre-work.md with unambiguous pointer lifecycle rules. SC-1c.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Z3 check GREEN.** Dispatch `solve --task check` to validate GREEN phase state transition. SC-1c.
  - Dispatch indicator: inline
  - Context: issue 2170, contract path from dependency-contract.yaml
- [ ] **Post-GREEN enforcement.** Dispatch `implementation-pipeline --task post-green-enforcement` to verify GREEN gate conditions. SC-1c.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Z3 check post-GREEN.** Dispatch `solve --task check` to validate post-GREEN state transition. SC-1c.
  - Dispatch indicator: inline
  - Context: issue 2170, contract path from dependency-contract.yaml
- [ ] **Checkpoint tag create.** Dispatch `implementation-pipeline --task checkpoint-tag-create` to create checkpoint tag. SC-1c.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Checkpoint commit.** Dispatch `git-workflow --task commit-prep` to commit SC-1c changes. SC-1c.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Structural checks.** Dispatch `finishing-a-development-branch --task checklist` to run lint/typecheck. SC-1c.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **GREEN doublecheck.** Dispatch `verification-before-completion --task verify` to confirm SC-1c behavioral test passes. SC-1c.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **GREEN VbC.** Dispatch `verification-before-completion --task completion` to produce SC-1c verdict. SC-1c.
  - Dispatch indicator: clean-room
  - Context: issue 2170

---

#### Phase 1 VbC

- [ ] **SC count gate.** Dispatch `implementation-pipeline --task sc-count-gate` to verify all 3 Phase 1 SCs have verdicts. Context: issue 2170.
- [ ] **Pre-PR gate.** Dispatch `verification-before-completion --task verify` to check all Phase 1 SC verdicts are PASS. Context: issue 2170.

**Concern transition:** Leaving dirty pointer deadlock resolution — entering check-pr authorization ambiguity fix. Phase 2 is independent — no dependency on Phase 1 output.

---

## Phase 2 — Fix check-pr Authorization Ambiguity

**Concern:** check-pr Phase 3 must explicitly state that merge verification (Phase 2) satisfies the authorization requirement for issue closure, and agent must not deliberate about authorization for post-merge cleanup.

**Files:**
- `.opencode/skills/git-workflow-cleanup/tasks/check-pr.md`

**SCs:** SC-2, SC-3

**Dependencies:** None

**Entry Conditions:**
- Pre-implementation steps complete
- Feature branch exists

**Exit Conditions:**
- check-pr.md Phase 3 explicitly states merge verification satisfies authorization
- Behavioral test verifies no deliberation about cleanup authorization

---

### Item 4 — SC-2: check-pr Phase 3 authorization clarity

- [ ] **RED phase.** Dispatch `test-driven-development --task red` to write a content-verification test asserting check-pr.md Phase 3 contains the authorization statement. SC-2.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Z3 check RED.** Dispatch `solve --task check` to validate RED phase state transition. SC-2.
  - Dispatch indicator: inline
  - Context: issue 2170, contract path from dependency-contract.yaml
- [ ] **RED doublecheck.** Dispatch `verification-before-completion --task verify` to confirm RED test fails as expected. SC-2.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Z3 check RED doublecheck.** Dispatch `solve --task check` to validate RED doublecheck state transition. SC-2.
  - Dispatch indicator: inline
  - Context: issue 2170, contract path from dependency-contract.yaml
- [ ] **Post-RED enforcement.** Dispatch `implementation-pipeline --task post-red-enforcement` to verify RED gate conditions. SC-2.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Z3 check post-RED.** Dispatch `solve --task check` to validate post-RED state transition. SC-2.
  - Dispatch indicator: inline
  - Context: issue 2170, contract path from dependency-contract.yaml
- [ ] **GREEN phase.** Dispatch `test-driven-development --task green` to update check-pr.md Phase 3 with explicit authorization statement. SC-2.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Z3 check GREEN.** Dispatch `solve --task check` to validate GREEN phase state transition. SC-2.
  - Dispatch indicator: inline
  - Context: issue 2170, contract path from dependency-contract.yaml
- [ ] **Post-GREEN enforcement.** Dispatch `implementation-pipeline --task post-green-enforcement` to verify GREEN gate conditions. SC-2.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Z3 check post-GREEN.** Dispatch `solve --task check` to validate post-GREEN state transition. SC-2.
  - Dispatch indicator: inline
  - Context: issue 2170, contract path from dependency-contract.yaml
- [ ] **Checkpoint tag create.** Dispatch `implementation-pipeline --task checkpoint-tag-create` to create checkpoint tag. SC-2.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Checkpoint commit.** Dispatch `git-workflow --task commit-prep` to commit SC-2 changes. SC-2.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Structural checks.** Dispatch `finishing-a-development-branch --task checklist` to run lint/typecheck. SC-2.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **GREEN doublecheck.** Dispatch `verification-before-completion --task verify` to confirm SC-2 content change is correct. SC-2.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **GREEN VbC.** Dispatch `verification-before-completion --task completion` to produce SC-2 verdict. SC-2.
  - Dispatch indicator: clean-room
  - Context: issue 2170

---

### Item 5 — SC-3: Behavioral test for no deliberation about cleanup authorization

- [ ] **RED phase.** Dispatch `test-driven-development --task red` to write a behavioral enforcement test asserting agent does not deliberate about authorization for post-merge cleanup operations. SC-3.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Z3 check RED.** Dispatch `solve --task check` to validate RED phase state transition. SC-3.
  - Dispatch indicator: inline
  - Context: issue 2170, contract path from dependency-contract.yaml
- [ ] **RED doublecheck.** Dispatch `verification-before-completion --task verify` to confirm RED behavioral test fails as expected. SC-3.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Z3 check RED doublecheck.** Dispatch `solve --task check` to validate RED doublecheck state transition. SC-3.
  - Dispatch indicator: inline
  - Context: issue 2170, contract path from dependency-contract.yaml
- [ ] **Post-RED enforcement.** Dispatch `implementation-pipeline --task post-red-enforcement` to verify RED gate conditions. SC-3.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Z3 check post-RED.** Dispatch `solve --task check` to validate post-RED state transition. SC-3.
  - Dispatch indicator: inline
  - Context: issue 2170, contract path from dependency-contract.yaml
- [ ] **GREEN phase.** Dispatch `test-driven-development --task green` to update check-pr.md with non-deliberation mandate for post-merge cleanup. SC-3.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Z3 check GREEN.** Dispatch `solve --task check` to validate GREEN phase state transition. SC-3.
  - Dispatch indicator: inline
  - Context: issue 2170, contract path from dependency-contract.yaml
- [ ] **Post-GREEN enforcement.** Dispatch `implementation-pipeline --task post-green-enforcement` to verify GREEN gate conditions. SC-3.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Z3 check post-GREEN.** Dispatch `solve --task check` to validate post-GREEN state transition. SC-3.
  - Dispatch indicator: inline
  - Context: issue 2170, contract path from dependency-contract.yaml
- [ ] **Checkpoint tag create.** Dispatch `implementation-pipeline --task checkpoint-tag-create` to create checkpoint tag. SC-3.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Checkpoint commit.** Dispatch `git-workflow --task commit-prep` to commit SC-3 changes. SC-3.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Structural checks.** Dispatch `finishing-a-development-branch --task checklist` to run lint/typecheck. SC-3.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **GREEN doublecheck.** Dispatch `verification-before-completion --task verify` to confirm SC-3 behavioral test passes. SC-3.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **GREEN VbC.** Dispatch `verification-before-completion --task completion` to produce SC-3 verdict. SC-3.
  - Dispatch indicator: clean-room
  - Context: issue 2170

---

#### Phase 2 VbC

- [ ] **SC count gate.** Dispatch `implementation-pipeline --task sc-count-gate` to verify both Phase 2 SCs have verdicts. Context: issue 2170.
- [ ] **Pre-PR gate.** Dispatch `verification-before-completion --task verify` to check all Phase 2 SC verdicts are PASS. Context: issue 2170.

**Concern transition:** Leaving check-pr authorization fix — entering pre-push hook message update. Phase 3 is independent — no dependency on Phase 2 output.

---

## Phase 3 — Update Pre-push Hook Gate 2 Message

**Concern:** Pre-push hook Gate 2 message must state only the block and reason — no instructions, no workarounds.

**Files:**
- `.git/hooks/pre-push`

**SCs:** SC-4

**Dependencies:** None

**Entry Conditions:**
- Pre-implementation steps complete
- Feature branch exists

**Exit Conditions:**
- Pre-push hook Gate 2 message contains only block and reason

---

### Item 6 — SC-4: Pre-push hook Gate 2 message cleanup

- [ ] **RED phase.** Dispatch `test-driven-development --task red` to write a content-verification test asserting pre-push hook Gate 2 has no instructional text. SC-4.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Z3 check RED.** Dispatch `solve --task check` to validate RED phase state transition. SC-4.
  - Dispatch indicator: inline
  - Context: issue 2170, contract path from dependency-contract.yaml
- [ ] **RED doublecheck.** Dispatch `verification-before-completion --task verify` to confirm RED test fails as expected. SC-4.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Z3 check RED doublecheck.** Dispatch `solve --task check` to validate RED doublecheck state transition. SC-4.
  - Dispatch indicator: inline
  - Context: issue 2170, contract path from dependency-contract.yaml
- [ ] **Post-RED enforcement.** Dispatch `implementation-pipeline --task post-red-enforcement` to verify RED gate conditions. SC-4.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Z3 check post-RED.** Dispatch `solve --task check` to validate post-RED state transition. SC-4.
  - Dispatch indicator: inline
  - Context: issue 2170, contract path from dependency-contract.yaml
- [ ] **GREEN phase.** Dispatch `test-driven-development --task green` to update pre-push hook Gate 2 message to state only block and reason. SC-4.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Z3 check GREEN.** Dispatch `solve --task check` to validate GREEN phase state transition. SC-4.
  - Dispatch indicator: inline
  - Context: issue 2170, contract path from dependency-contract.yaml
- [ ] **Post-GREEN enforcement.** Dispatch `implementation-pipeline --task post-green-enforcement` to verify GREEN gate conditions. SC-4.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Z3 check post-GREEN.** Dispatch `solve --task check` to validate post-GREEN state transition. SC-4.
  - Dispatch indicator: inline
  - Context: issue 2170, contract path from dependency-contract.yaml
- [ ] **Checkpoint tag create.** Dispatch `implementation-pipeline --task checkpoint-tag-create` to create checkpoint tag. SC-4.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Checkpoint commit.** Dispatch `git-workflow --task commit-prep` to commit SC-4 changes. SC-4.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Structural checks.** Dispatch `finishing-a-development-branch --task checklist` to run lint/typecheck. SC-4.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **GREEN doublecheck.** Dispatch `verification-before-completion --task verify` to confirm SC-4 content change is correct. SC-4.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **GREEN VbC.** Dispatch `verification-before-completion --task completion` to produce SC-4 verdict. SC-4.
  - Dispatch indicator: clean-room
  - Context: issue 2170

---

#### Phase 3 VbC

- [ ] **SC count gate.** Dispatch `implementation-pipeline --task sc-count-gate` to verify SC-4 has a verdict. Context: issue 2170.
- [ ] **Pre-PR gate.** Dispatch `verification-before-completion --task verify` to check SC-4 verdict is PASS. Context: issue 2170.

**Concern transition:** Leaving pre-push hook message update — entering approval-gate and go-prohibitions wording update. Phase 4 is independent — no dependency on Phase 3 output.

---

## Phase 4 — Update approval-gate.md and 020-go-prohibitions.md Wording

**Concern:** Clarify approval-gate.md rule 10 wording and remove stale "resolves on next pre-work cycle" language from 020-go-prohibitions.md and branch-cleanup.md.

**Files:**
- `.opencode/guidelines/010-approval-gate.md`
- `.opencode/guidelines/020-go-prohibitions.md`
- `.opencode/skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md`

**SCs:** SC-5, SC-6

**Dependencies:** None

**Entry Conditions:**
- Pre-implementation steps complete
- Feature branch exists

**Exit Conditions:**
- approval-gate.md rule 10 clarifies "confirmed" means "verified by check-pr Phase 2"
- "resolves on next pre-work cycle" removed from 020-go-prohibitions.md and branch-cleanup.md

---

### Item 7 — SC-5: approval-gate.md rule 10 clarification

- [ ] **RED phase.** Dispatch `test-driven-development --task red` to write a content-verification test asserting approval-gate.md rule 10 has clarified wording. SC-5.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Z3 check RED.** Dispatch `solve --task check` to validate RED phase state transition. SC-5.
  - Dispatch indicator: inline
  - Context: issue 2170, contract path from dependency-contract.yaml
- [ ] **RED doublecheck.** Dispatch `verification-before-completion --task verify` to confirm RED test fails as expected. SC-5.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Z3 check RED doublecheck.** Dispatch `solve --task check` to validate RED doublecheck state transition. SC-5.
  - Dispatch indicator: inline
  - Context: issue 2170, contract path from dependency-contract.yaml
- [ ] **Post-RED enforcement.** Dispatch `implementation-pipeline --task post-red-enforcement` to verify RED gate conditions. SC-5.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Z3 check post-RED.** Dispatch `solve --task check` to validate post-RED state transition. SC-5.
  - Dispatch indicator: inline
  - Context: issue 2170, contract path from dependency-contract.yaml
- [ ] **GREEN phase.** Dispatch `test-driven-development --task green` to update approval-gate.md rule 10 with clarified wording. SC-5.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Z3 check GREEN.** Dispatch `solve --task check` to validate GREEN phase state transition. SC-5.
  - Dispatch indicator: inline
  - Context: issue 2170, contract path from dependency-contract.yaml
- [ ] **Post-GREEN enforcement.** Dispatch `implementation-pipeline --task post-green-enforcement` to verify GREEN gate conditions. SC-5.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Z3 check post-GREEN.** Dispatch `solve --task check` to validate post-GREEN state transition. SC-5.
  - Dispatch indicator: inline
  - Context: issue 2170, contract path from dependency-contract.yaml
- [ ] **Checkpoint tag create.** Dispatch `implementation-pipeline --task checkpoint-tag-create` to create checkpoint tag. SC-5.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Checkpoint commit.** Dispatch `git-workflow --task commit-prep` to commit SC-5 changes. SC-5.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Structural checks.** Dispatch `finishing-a-development-branch --task checklist` to run lint/typecheck. SC-5.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **GREEN doublecheck.** Dispatch `verification-before-completion --task verify` to confirm SC-5 content change is correct. SC-5.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **GREEN VbC.** Dispatch `verification-before-completion --task completion` to produce SC-5 verdict. SC-5.
  - Dispatch indicator: clean-room
  - Context: issue 2170

---

### Item 8 — SC-6: Remove stale "resolves on next pre-work cycle" language

- [ ] **RED phase.** Dispatch `test-driven-development --task red` to write a content-verification test asserting "resolves on next pre-work cycle" is absent from 020-go-prohibitions.md and branch-cleanup.md. SC-6.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Z3 check RED.** Dispatch `solve --task check` to validate RED phase state transition. SC-6.
  - Dispatch indicator: inline
  - Context: issue 2170, contract path from dependency-contract.yaml
- [ ] **RED doublecheck.** Dispatch `verification-before-completion --task verify` to confirm RED test fails as expected. SC-6.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Z3 check RED doublecheck.** Dispatch `solve --task check` to validate RED doublecheck state transition. SC-6.
  - Dispatch indicator: inline
  - Context: issue 2170, contract path from dependency-contract.yaml
- [ ] **Post-RED enforcement.** Dispatch `implementation-pipeline --task post-red-enforcement` to verify RED gate conditions. SC-6.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Z3 check post-RED.** Dispatch `solve --task check` to validate post-RED state transition. SC-6.
  - Dispatch indicator: inline
  - Context: issue 2170, contract path from dependency-contract.yaml
- [ ] **GREEN phase.** Dispatch `test-driven-development --task green` to remove "resolves on next pre-work cycle" from 020-go-prohibitions.md and branch-cleanup.md, replace with accurate pointer lifecycle description. SC-6.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Z3 check GREEN.** Dispatch `solve --task check` to validate GREEN phase state transition. SC-6.
  - Dispatch indicator: inline
  - Context: issue 2170, contract path from dependency-contract.yaml
- [ ] **Post-GREEN enforcement.** Dispatch `implementation-pipeline --task post-green-enforcement` to verify GREEN gate conditions. SC-6.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Z3 check post-GREEN.** Dispatch `solve --task check` to validate post-GREEN state transition. SC-6.
  - Dispatch indicator: inline
  - Context: issue 2170, contract path from dependency-contract.yaml
- [ ] **Checkpoint tag create.** Dispatch `implementation-pipeline --task checkpoint-tag-create` to create checkpoint tag. SC-6.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Checkpoint commit.** Dispatch `git-workflow --task commit-prep` to commit SC-6 changes. SC-6.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **Structural checks.** Dispatch `finishing-a-development-branch --task checklist` to run lint/typecheck. SC-6.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **GREEN doublecheck.** Dispatch `verification-before-completion --task verify` to confirm SC-6 content change is correct. SC-6.
  - Dispatch indicator: clean-room
  - Context: issue 2170
- [ ] **GREEN VbC.** Dispatch `verification-before-completion --task completion` to produce SC-6 verdict. SC-6.
  - Dispatch indicator: clean-room
  - Context: issue 2170

---

#### Phase 4 VbC

- [ ] **SC count gate.** Dispatch `implementation-pipeline --task sc-count-gate` to verify both Phase 4 SCs have verdicts. Context: issue 2170.
- [ ] **Pre-PR gate.** Dispatch `verification-before-completion --task verify` to check all Phase 4 SC verdicts are PASS. Context: issue 2170.

---

## Post-Implementation Steps

- [ ] **Audit.** Dispatch audit task from `audit` skill with spec_local_dir and artifact_evidence_dir. If non-clean-pass, remediate and restart. Context: issue 2170.
- [ ] **Cross-validate.** Dispatch `audit --task cross-validate` to produce consensus findings. Context: issue 2170.
- [ ] **Regression check.** Dispatch `test-driven-development --task patterns` to run regression tests. Context: issue 2170.
- [ ] **Review prep.** Dispatch `git-workflow --task review-prep` to prepare PR for review. Context: issue 2170.
- [ ] **Create PR.** Dispatch `pr-creation-workflow --task create` to create the pull request. Context: issue 2170, authorization_scope for_pr, halt_at pr_created.
- [ ] **Executive summary.** Dispatch `completion-core --task completion` to produce final summary. Context: issue 2170.

---

## Exit Criteria

- [ ] All 8 SCs (SC-1a through SC-6) have PASS verdicts from VbC
- [ ] All 4 phases complete with clean SC count gate and pre-PR gate
- [ ] Audit and cross-validate produce clean PASS
- [ ] Regression tests pass
- [ ] PR created with review-prep complete
- [ ] No phase depends on another phase's output (all 4 phases are independent)

---

## Lifecycle Events

| Timestamp | Event | Details |
|-----------|-------|---------|
| 2026-07-28T16:21:00Z | plan_created | Plan file: `.opencode/.issues/2170/plan.md`, Phase count: 4, Authorization scope: for_pr, PR strategy: stacked |
| 2026-07-29T12:24:00Z | plan_validated | Plan validated PASS through writing-plans pipeline. 4 phases, 8 items, all independent. |
