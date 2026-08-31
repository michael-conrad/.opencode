---
plan_schema_version: 1
issue: 2410
title: "Skill deck workflow/contract defects remediation"
dispatch:
  - test-driven-development
  - verification-before-completion
  - audit
  - finishing-a-development-branch
  - git-workflow-pr
  - completion-core
---

# Implementation Plan — Skill Deck Workflow/Contract Defects Remediation

Issue: [.opencode#2410](https://github.com/michael-conrad/.opencode/tree/issues-data/2410)

## Goal

Repair the two classes of workflow/contract defects in the skill deck that break orchestrator→sub-agent routing: (1) dispatch contract mismatches where SKILL.md dispatch steps declare a Returns/Context contract that disagrees with the target task card's Result Contract / required context, and (2) task-card-internal-dispatch where task cards embed internal `task()`/`skill({)` dispatch instructions. The task card is the authoritative source for the execution procedure; SKILL.md Workflows Returns/Context must match it. Task cards must not instruct sub-agents to dispatch further sub-agents — the orchestrator alone performs dispatch.

## Architecture

- **Phase 1 — Dispatch contract alignment:** Align SKILL.md Workflows Returns/Context sub-bullets with the target task-card Result Contract / Entry Criteria. Touches `git-workflow-branch`, `git-workflow-cleanup`, `git-workflow-commit`, `git-workflow-pr`, `git-workflow-conflict` SKILL.md files and `writing-plans/tasks/analyze.md` Entry Criteria wording.
- **Phase 2 — Task-card internal-dispatch remediation:** Replace embedded `task()`/`skill({)` dispatch instructions in task cards with orchestrator-routing markers; reword prose mentions that trigger the lint token pattern. Touches 22 task-card files across 10 skills.

## Files

- `.opencode/skills/git-workflow-branch/SKILL.md`
- `.opencode/skills/git-workflow-cleanup/SKILL.md`
- `.opencode/skills/git-workflow-commit/SKILL.md`
- `.opencode/skills/git-workflow-pr/SKILL.md`
- `.opencode/skills/git-workflow-conflict/SKILL.md`
- `.opencode/skills/writing-plans/tasks/analyze.md`
- `.opencode/skills/git-workflow-branch/tasks/pre-work.md`
- `.opencode/skills/git-workflow-pr/tasks/pr-creation.md`
- `.opencode/skills/issue-operations-comments/tasks/*.md`
- `.opencode/skills/issue-operations-core/tasks/{body-edit,close,creation,list-issues,read-comments,read-issue,read-labels,search-issues,update-issue}.md`
- `.opencode/skills/issue-operations-sub-issues/tasks/{link-sub-issue,read-sub-issues}.md`
- `.opencode/skills/issue-operations-sync/tasks/{import-remote,sync-pull-to-local}.md`
- `.opencode/skills/issue-review/tasks/audit.md`
- `.opencode/skills/sre-runbook/tasks/track.md`
- `.opencode/skills/multimodal-dispatch/tasks/{completion,dispatch}.md`
- `.opencode/skills/pre-analysis/tasks/analyze.md`
- `.opencode/skills/verification/tasks/verify.md`

## Dispatch

- `test-driven-development` — RED, GREEN, post-regression, regression-check
- `verification-before-completion` — verify, pre-pr-gate
- `audit` — verification-audit DiMo investigator
- `finishing-a-development-branch` — structural-checks
- `git-workflow-pr` — review-prep, create-pr
- `completion-core` — exec-summary

## Blast Radius

- **Phase 1:** SKILL.md Workflows Returns/Context sub-bullets for `git-workflow-branch` (Verify remote trunk tip, Pair pre-work, Pair mode resume, Pre-work), `git-workflow-cleanup` (pair-cleanup), `git-workflow-commit` (pair-commit), `git-workflow-pr` (pair-pr-creation, completion), `git-workflow-conflict` (Rebase pending), and `writing-plans/tasks/analyze.md` Entry Criteria. Impact zone: orchestrator routing contract shape for these dispatch steps.
- **Phase 2:** 22 task-card files across 10 skills. Impact zone: sub-agent execution procedures; removing embedded dispatch instructions changes how sub-agents execute but not the underlying operation.

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Enforcement gate:** All SCs must pass before this plan is complete.

## Phase Table

| Phase | Name | SCs | Dependencies | Step Range | Dispatch |
|-------|------|-----|--------------|------------|----------|
| 1 | Dispatch contract alignment | SC-1..SC-10, SC-33 | none | 1–11 | test-driven-development, verification-before-completion |
| 2 | Task-card internal-dispatch remediation | SC-11..SC-32 | none | 11–32 | test-driven-development, verification-before-completion |

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

## Exit Criteria

- [ ] C1. All 33 SCs pass their `skildeck lint` verification gate.
- [ ] C2. Phase 1 aligns all 11 dispatch contracts (SC-1..SC-10, SC-33).
- [ ] C3. Phase 2 removes all 22 task-card-internal-dispatch findings (SC-11..SC-32).
- [ ] C4. Each item committed as one atomic slice (test + change together).
- [ ] C5. No circular dependencies in the phase DAG.
- [ ] C6. Audit, structural checks, regression check, review-prep, and PR creation complete.

---

# Pre-Implementation Steps

- [ ] P1. **Coherence gate.** (**inline**) Verify the structure artifact and spec are coherent: all 32 SCs map to exactly one phase, each item references exactly one SC-ID, and the phase DAG has no dependency edges. If any SC is missing or an item covers multiple SCs, return BLOCKED.
- [ ] P2. **Baseline check.** (**inline**) Run `./.opencode/tools/skildeck lint` and record the baseline finding counts for `dispatch-contract-result-mismatch`, `dispatch-contract-incomplete`, and `task-card-internal-dispatch`. Confirm the baseline matches the spec's asserted evidence (19 result-mismatch, 5 incomplete, 22 internal-dispatch). If the baseline does not match, return BLOCKED with the discrepancy.

---

# Phase 1 — Dispatch Contract Alignment

## Phase Metadata

- **Concern:** SKILL.md Workflows Returns/Context must match task-card Result Contract / Entry Criteria. Touches SKILL.md Workflows Returns/Context sub-bullets and, for lint false-positives, task-card Entry Criteria wording.
- **Files:** `git-workflow-branch/SKILL.md`, `git-workflow-cleanup/SKILL.md`, `git-workflow-commit/SKILL.md`, `git-workflow-pr/SKILL.md`, `git-workflow-conflict/SKILL.md`, `writing-plans/tasks/analyze.md`, `git-workflow-branch/tasks/trunk-tip-verification.md`
- **SCs:** SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8, SC-9, SC-10, SC-33
- **Dependencies:** none
- **Entry condition:** Baseline check (P2) passed.
- **Exit condition:** `skildeck lint` shows zero `dispatch-contract-result-mismatch` and `dispatch-contract-incomplete` findings for the affected steps.

## Code Path Coverage

- `git-workflow-branch/SKILL.md` — "Verify remote trunk tip", "Pair pre-work", "Pair mode resume", "Pre-work" Workflows Returns/Context sub-bullets.
- `git-workflow-cleanup/SKILL.md` — "pair-cleanup" Returns.
- `git-workflow-commit/SKILL.md` — "pair-commit" Returns.
- `git-workflow-pr/SKILL.md` — "pair-pr-creation", "completion" Returns.
- `git-workflow-conflict/SKILL.md` — "Rebase pending" Context.
- `writing-plans/tasks/analyze.md` — Entry Criteria BLOCK reason token wording.

## Cross-Cutting SCs

- All Phase 1 SCs share the `skildeck lint` verification gate: GREEN verify runs `./.opencode/tools/skildeck lint` and asserts the specific finding class is eliminated for the affected step.

## Interface Boundaries

- The task-card Result Contract / Entry Criteria is the authoritative source. SKILL.md Workflows Returns/Context must match it. Where the SKILL.md is correct, the task card is corrected.

## State Transitions

- Each item transitions the deck from a defective finding state to a clean state for the affected step. The invariant is that the task-card Result Contract / Entry Criteria remain the authoritative source.

**Cost frame:** Verifying each Returns/Context alignment costs one `skildeck lint` run. Skipping means the orchestrator routes with the wrong contract shape and downstream routing fails at review time — a defect that costs 1000× more to fix than the skipped behavioral check.

## Step-by-Step

### Item 1 (SC-1): Align git-workflow-branch "Verify remote trunk tip" Returns contract

- [ ] 1. **RED.** (**sub-agent**) Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Assert `skildeck lint` shows `dispatch-contract-result-mismatch` for the git-workflow-branch "Verify remote trunk tip" step.
- [ ] 2. **GREEN.** (**sub-agent**) Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Update `git-workflow-branch/SKILL.md` "Verify remote trunk tip" Returns to `{status, checks, blocker_reason}` matching the `trunk-tip-verification.md` Result Contract.
- [ ] 3. **Post-regression.** (**sub-agent**) Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run regression test patterns after GREEN.
- [ ] 4. **Verify.** (**sub-agent**) Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Assert `./.opencode/tools/skildeck lint` output inspection shows zero `dispatch-contract-result-mismatch` findings for this step.
- [ ] 5. **Commit.** (**inline**) Run `git add <files> && git commit -m "<message>"` for the `git-workflow-branch/SKILL.md` Returns alignment.

### Item 2 (SC-2): Align git-workflow-branch "Pair pre-work" Returns contract

- [ ] 1. **RED.** (**sub-agent**) Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Assert `skildeck lint` shows `dispatch-contract-result-mismatch` for the git-workflow-branch "Pair pre-work" step.
- [ ] 2. **GREEN.** (**sub-agent**) Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Update `git-workflow-branch/SKILL.md` "Pair pre-work" Returns to match its task-card Result Contract.
- [ ] 3. **Post-regression.** (**sub-agent**) Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run regression test patterns after GREEN.
- [ ] 4. **Verify.** (**sub-agent**) Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Assert `./.opencode/tools/skildeck lint` output inspection shows zero `dispatch-contract-result-mismatch` findings for this step.
- [ ] 5. **Commit.** (**inline**) Run `git add <files> && git commit -m "<message>"` for the `git-workflow-branch/SKILL.md` "Pair pre-work" Returns alignment.

### Item 3 (SC-3): Align git-workflow-branch "Pair mode resume" Returns contract

- [ ] 1. **RED.** (**sub-agent**) Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Assert `skildeck lint` shows `dispatch-contract-result-mismatch` for the git-workflow-branch "Pair mode resume" step.
- [ ] 2. **GREEN.** (**sub-agent**) Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Update `git-workflow-branch/SKILL.md` "Pair mode resume" Returns to match its task-card Result Contract.
- [ ] 3. **Post-regression.** (**sub-agent**) Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run regression test patterns after GREEN.
- [ ] 4. **Verify.** (**sub-agent**) Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Assert `./.opencode/tools/skildeck lint` output inspection shows zero `dispatch-contract-result-mismatch` findings for this step.
- [ ] 5. **Commit.** (**inline**) Run `git add <files> && git commit -m "<message>"` for the `git-workflow-branch/SKILL.md` "Pair mode resume" Returns alignment.

### Item 4 (SC-4): Add 'approved' to git-workflow-branch "Pre-work" Context

- [ ] 1. **RED.** (**sub-agent**) Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Assert `skildeck lint` shows `dispatch-contract-incomplete` for the git-workflow-branch "Pre-work" step.
- [ ] 2. **GREEN.** (**sub-agent**) Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Add the `approved` field to the `git-workflow-branch/SKILL.md` "Pre-work" Context.
- [ ] 3. **Post-regression.** (**sub-agent**) Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run regression test patterns after GREEN.
- [ ] 4. **Verify.** (**sub-agent**) Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Assert `./.opencode/tools/skildeck lint` output inspection shows zero `dispatch-contract-incomplete` findings for this step.
- [ ] 5. **Commit.** (**inline**) Run `git add <files> && git commit -m "<message>"` for the `git-workflow-branch/SKILL.md` Context alignment.

### Item 5 (SC-5): Align git-workflow-cleanup "pair-cleanup" Returns contract

- [ ] 1. **RED.** (**sub-agent**) Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Assert `skildeck lint` shows `dispatch-contract-result-mismatch` for the git-workflow-cleanup "pair-cleanup" step.
- [ ] 2. **GREEN.** (**sub-agent**) Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Align the `git-workflow-cleanup/SKILL.md` "pair-cleanup" Returns contract with its task-card Result Contract.
- [ ] 3. **Post-regression.** (**sub-agent**) Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run regression test patterns after GREEN.
- [ ] 4. **Verify.** (**sub-agent**) Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Assert `./.opencode/tools/skildeck lint` output inspection shows zero `dispatch-contract-result-mismatch` findings for this step.
- [ ] 5. **Commit.** (**inline**) Run `git add <files> && git commit -m "<message>"` for the `git-workflow-cleanup/SKILL.md` Returns alignment.

### Item 6 (SC-6): Align git-workflow-commit "pair-commit" Returns contract

- [ ] 1. **RED.** (**sub-agent**) Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Assert `skildeck lint` shows `dispatch-contract-result-mismatch` for the git-workflow-commit "pair-commit" step.
- [ ] 2. **GREEN.** (**sub-agent**) Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Align the `git-workflow-commit/SKILL.md` "pair-commit" Returns contract with its task-card Result Contract.
- [ ] 3. **Post-regression.** (**sub-agent**) Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run regression test patterns after GREEN.
- [ ] 4. **Verify.** (**sub-agent**) Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Assert `./.opencode/tools/skildeck lint` output inspection shows zero `dispatch-contract-result-mismatch` findings for this step.
- [ ] 5. **Commit.** (**inline**) Run `git add <files> && git commit -m "<message>"` for the `git-workflow-commit/SKILL.md` Returns alignment.

### Item 7 (SC-7): Align git-workflow-pr "pair-pr-creation" Returns contract

- [ ] 1. **RED.** (**sub-agent**) Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Assert `skildeck lint` shows `dispatch-contract-result-mismatch` for the git-workflow-pr "pair-pr-creation" step.
- [ ] 2. **GREEN.** (**sub-agent**) Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Align the `git-workflow-pr/SKILL.md` "pair-pr-creation" Returns contract with its task-card Result Contract.
- [ ] 3. **Post-regression.** (**sub-agent**) Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run regression test patterns after GREEN.
- [ ] 4. **Verify.** (**sub-agent**) Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Assert `./.opencode/tools/skildeck lint` output inspection shows zero `dispatch-contract-result-mismatch` findings for this step.
- [ ] 5. **Commit.** (**inline**) Run `git add <files> && git commit -m "<message>"` for the `git-workflow-pr/SKILL.md` Returns alignment.

### Item 8 (SC-8): Align git-workflow-pr "completion" Returns contract

- [ ] 1. **RED.** (**sub-agent**) Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Assert `skildeck lint` shows `dispatch-contract-result-mismatch` for the git-workflow-pr "completion" step.
- [ ] 2. **GREEN.** (**sub-agent**) Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Align the `git-workflow-pr/SKILL.md` "completion" Returns contract with its task-card Result Contract.
- [ ] 3. **Post-regression.** (**sub-agent**) Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run regression test patterns after GREEN.
- [ ] 4. **Verify.** (**sub-agent**) Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Assert `./.opencode/tools/skildeck lint` output inspection shows zero `dispatch-contract-result-mismatch` findings for this step.
- [ ] 5. **Commit.** (**inline**) Run `git add <files> && git commit -m "<message>"` for the `git-workflow-pr/SKILL.md` Returns alignment.

### Item 9 (SC-9): Resolve git-workflow-conflict "Rebase pending" merged_at context

- [ ] 1. **RED.** (**sub-agent**) Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Assert `skildeck lint` shows `dispatch-contract-incomplete` for the git-workflow-conflict "Rebase pending" step.
- [ ] 2. **GREEN.** (**sub-agent**) Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Add the `merged_at` field to the `git-workflow-conflict/SKILL.md` "Rebase pending" Context.
- [ ] 3. **Post-regression.** (**sub-agent**) Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run regression test patterns after GREEN.
- [ ] 4. **Verify.** (**sub-agent**) Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Assert `./.opencode/tools/skildeck lint` output inspection shows zero `dispatch-contract-incomplete` findings for this step.
- [ ] 5. **Commit.** (**inline**) Run `git add <files> && git commit -m "<message>"` for the `git-workflow-conflict/SKILL.md` Context alignment.

### Item 10 (SC-10): Resolve writing-plans 'analyze' SPEC_NOT_FOUND/SPEC_NOT_APPROVED false-positives

- [ ] 1. **RED.** (**sub-agent**) Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Assert `skildeck lint` shows `dispatch-contract-incomplete` for the writing-plans "analyze" step.
- [ ] 2. **GREEN.** (**sub-agent**) Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Reword `writing-plans/tasks/analyze.md` Entry Criteria to avoid backtick-quoting the `SPEC_NOT_FOUND` and `SPEC_NOT_APPROVED` BLOCK reason tokens.
- [ ] 3. **Post-regression.** (**sub-agent**) Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run regression test patterns after GREEN.
- [ ] 4. **Verify.** (**sub-agent**) Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Assert `./.opencode/tools/skildeck lint` output inspection shows zero `dispatch-contract-incomplete` findings for this step.
- [ ] 5. **Commit.** (**inline**) Run `git add <files> && git commit -m "<message>"` for the `writing-plans/tasks/analyze.md` Entry Criteria rewording.

### Item 11 (SC-33): Resolve git-workflow-branch 'Verify remote trunk tip' origin false-positive

- [ ] 1. **RED.** (**sub-agent**) Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Assert `skildeck lint` shows `dispatch-contract-incomplete` for the git-workflow-branch "Verify remote trunk tip" step.
- [ ] 2. **GREEN.** (**sub-agent**) Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Reword `trunk-tip-verification.md` Entry Criteria to avoid backtick-quoting the git remote name `origin` as a required context parameter.
- [ ] 3. **Post-regression.** (**sub-agent**) Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run regression test patterns after GREEN.
- [ ] 4. **Verify.** (**sub-agent**) Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Assert `./.opencode/tools/skildeck lint` output inspection shows zero `dispatch-contract-incomplete` findings for this step.
- [ ] 5. **Commit.** (**inline**) Run `git add <files> && git commit -m "<message>"` for the `trunk-tip-verification.md` Entry Criteria rewording.

## Phase 1 Completion Block

- [ ] V1. `skildeck lint` shows zero `dispatch-contract-result-mismatch` findings for the git-workflow-branch, git-workflow-cleanup, git-workflow-commit, and git-workflow-pr steps.
- [ ] V2. `skildeck lint` shows zero `dispatch-contract-incomplete` findings for the git-workflow-branch "Pre-work", git-workflow-conflict "Rebase pending", writing-plans "analyze", and git-workflow-branch "Verify remote trunk tip" steps.
- [ ] V3. All 11 Phase 1 items committed as atomic slices.

## Concern Transition

Phase 1 is complete. Proceed to Phase 2 — Task-card internal-dispatch remediation. The two phases are independent concern silos touching disjoint file sets; no Phase 1 output is consumed by Phase 2.

---

# Phase 2 — Task-card Internal-Dispatch Remediation

## Phase Metadata

- **Concern:** Task cards must not instruct sub-agents to dispatch further sub-agents. Embedded `task()`/`skill({)` dispatch instructions replaced with orchestrator-routing markers; prose mentions reworded to avoid the lint token pattern.
- **Files:** 22 task-card files across `git-workflow-branch`, `git-workflow-pr`, `issue-operations-comments`, `issue-operations-core`, `issue-operations-sub-issues`, `issue-operations-sync`, `issue-review`, `sre-runbook`, `multimodal-dispatch`, `pre-analysis`, `verification`.
- **SCs:** SC-11, SC-12, SC-13, SC-14, SC-15, SC-16, SC-17, SC-18, SC-19, SC-20, SC-21, SC-22, SC-23, SC-24, SC-25, SC-26, SC-27, SC-28, SC-29, SC-30, SC-31, SC-32
- **Dependencies:** none
- **Entry condition:** Phase 1 completion block passed.
- **Exit condition:** `skildeck lint` shows zero `task-card-internal-dispatch` findings for all 22 task-card files.

## Code Path Coverage

- `git-workflow-branch/tasks/pre-work.md`
- `git-workflow-pr/tasks/pr-creation.md`
- `issue-operations-comments/tasks/*.md`
- `issue-operations-core/tasks/{body-edit,close,creation,list-issues,read-comments,read-issue,read-labels,search-issues,update-issue}.md`
- `issue-operations-sub-issues/tasks/{link-sub-issue,read-sub-issues}.md`
- `issue-operations-sync/tasks/{import-remote,sync-pull-to-local}.md`
- `issue-review/tasks/audit.md`
- `sre-runbook/tasks/track.md`
- `multimodal-dispatch/tasks/{completion,dispatch}.md`
- `pre-analysis/tasks/analyze.md`
- `verification/tasks/verify.md`

## Cross-Cutting SCs

- All Phase 2 SCs share the `skildeck lint` verification gate: GREEN verify runs `./.opencode/tools/skildeck lint` and asserts the `task-card-internal-dispatch` finding class is eliminated for the specific task card.
- SC-27 through SC-32 additionally require rewording prose mentions that trigger the lint token pattern.

## Interface Boundaries

- The orchestrator alone performs dispatch. Task cards must not embed `task()`/`skill({)` dispatch instructions. Sub-agents execute single clean-room units.

## State Transitions

- Each item transitions the task card from an internal-dispatch state to a clean state where the orchestrator performs all dispatch. The invariant is that the task card describes the execution procedure only.

**Cost frame:** Verifying each task-card remediation costs one `skildeck lint` run. Skipping means sub-agents re-dispatch instead of executing, wasting context and violating clean-room isolation — a defect that costs 1000× more to fix than the skipped behavioral check.

## Step-by-Step

### Item 11 (SC-11): Remediate git-workflow-branch pre-work task-card internal dispatch

- [ ] 1. **RED.** (**sub-agent**) Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Assert `skildeck lint` shows `task-card-internal-dispatch` for `git-workflow-branch/tasks/pre-work.md`.
- [ ] 2. **GREEN.** (**sub-agent**) Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Replace embedded `task()` dispatch instructions with orchestrator-routing markers.
- [ ] 3. **Post-regression.** (**sub-agent**) Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run regression test patterns after GREEN.
- [ ] 4. **Verify.** (**sub-agent**) Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Assert `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for this task card.
- [ ] 5. **Commit.** (**inline**) Run `git add <files> && git commit -m "<message>"` for `git-workflow-branch/tasks/pre-work.md`.

### Item 12 (SC-12): Remediate git-workflow-pr pr-creation task-card internal dispatch

- [ ] 1. **RED.** (**sub-agent**) Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Assert `skildeck lint` shows `task-card-internal-dispatch` for `git-workflow-pr/tasks/pr-creation.md`.
- [ ] 2. **GREEN.** (**sub-agent**) Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Replace embedded `task()` dispatch instructions with orchestrator-routing markers.
- [ ] 3. **Post-regression.** (**sub-agent**) Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run regression test patterns after GREEN.
- [ ] 4. **Verify.** (**sub-agent**) Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Assert `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for this task card.
- [ ] 5. **Commit.** (**inline**) Run `git add <files> && git commit -m "<message>"` for `git-workflow-pr/tasks/pr-creation.md`.

### Item 13 (SC-13): Remediate issue-operations-comments task-card internal dispatch

- [ ] 1. **RED.** (**sub-agent**) Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Assert `skildeck lint` shows `task-card-internal-dispatch` for the `issue-operations-comments` task cards.
- [ ] 2. **GREEN.** (**sub-agent**) Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Replace embedded `task()` routing instructions with orchestrator-routing markers.
- [ ] 3. **Post-regression.** (**sub-agent**) Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run regression test patterns after GREEN.
- [ ] 4. **Verify.** (**sub-agent**) Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Assert `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for these task cards.
- [ ] 5. **Commit.** (**inline**) Run `git add <files> && git commit -m "<message>"` for the `issue-operations-comments` task cards.

### Item 14 (SC-14): Remediate issue-operations-core body-edit task-card internal dispatch

- [ ] 1. **RED.** (**sub-agent**) Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Assert `skildeck lint` shows `task-card-internal-dispatch` for `issue-operations-core/tasks/body-edit.md`.
- [ ] 2. **GREEN.** (**sub-agent**) Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Replace embedded `task()` routing instructions with orchestrator-routing markers.
- [ ] 3. **Post-regression.** (**sub-agent**) Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run regression test patterns after GREEN.
- [ ] 4. **Verify.** (**sub-agent**) Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Assert `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for this task card.
- [ ] 5. **Commit.** (**inline**) Run `git add <files> && git commit -m "<message>"` for `issue-operations-core/tasks/body-edit.md`.

### Item 15 (SC-15): Remediate issue-operations-core close task-card internal dispatch

- [ ] 1. **RED.** (**sub-agent**) Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Assert `skildeck lint` shows `task-card-internal-dispatch` for `issue-operations-core/tasks/close.md`.
- [ ] 2. **GREEN.** (**sub-agent**) Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Replace embedded `task()` routing instructions with orchestrator-routing markers.
- [ ] 3. **Post-regression.** (**sub-agent**) Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run regression test patterns after GREEN.
- [ ] 4. **Verify.** (**sub-agent**) Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Assert `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for this task card.
- [ ] 5. **Commit.** (**inline**) Run `git add <files> && git commit -m "<message>"` for `issue-operations-core/tasks/close.md`.

### Item 16 (SC-16): Remediate issue-operations-core creation task-card internal dispatch

- [ ] 1. **RED.** (**sub-agent**) Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Assert `skildeck lint` shows `task-card-internal-dispatch` for `issue-operations-core/tasks/creation.md`.
- [ ] 2. **GREEN.** (**sub-agent**) Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Replace embedded `task()` routing instructions with orchestrator-routing markers.
- [ ] 3. **Post-regression.** (**sub-agent**) Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run regression test patterns after GREEN.
- [ ] 4. **Verify.** (**sub-agent**) Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Assert `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for this task card.
- [ ] 5. **Commit.** (**inline**) Run `git add <files> && git commit -m "<message>"` for `issue-operations-core/tasks/creation.md`.

### Item 17 (SC-17): Remediate issue-operations-core list-issues task-card internal dispatch

- [ ] 1. **RED.** (**sub-agent**) Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Assert `skildeck lint` shows `task-card-internal-dispatch` for `issue-operations-core/tasks/list-issues.md`.
- [ ] 2. **GREEN.** (**sub-agent**) Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Replace embedded `task()` routing instructions with orchestrator-routing markers.
- [ ] 3. **Post-regression.** (**sub-agent**) Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run regression test patterns after GREEN.
- [ ] 4. **Verify.** (**sub-agent**) Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Assert `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for this task card.
- [ ] 5. **Commit.** (**inline**) Run `git add <files> && git commit -m "<message>"` for `issue-operations-core/tasks/list-issues.md`.

### Item 18 (SC-18): Remediate issue-operations-core read-comments task-card internal dispatch

- [ ] 1. **RED.** (**sub-agent**) Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Assert `skildeck lint` shows `task-card-internal-dispatch` for `issue-operations-core/tasks/read-comments.md`.
- [ ] 2. **GREEN.** (**sub-agent**) Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Replace embedded `task()` routing instructions with orchestrator-routing markers.
- [ ] 3. **Post-regression.** (**sub-agent**) Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run regression test patterns after GREEN.
- [ ] 4. **Verify.** (**sub-agent**) Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Assert `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for this task card.
- [ ] 5. **Commit.** (**inline**) Run `git add <files> && git commit -m "<message>"` for `issue-operations-core/tasks/read-comments.md`.

### Item 19 (SC-19): Remediate issue-operations-core read-issue task-card internal dispatch

- [ ] 1. **RED.** (**sub-agent**) Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Assert `skildeck lint` shows `task-card-internal-dispatch` for `issue-operations-core/tasks/read-issue.md`.
- [ ] 2. **GREEN.** (**sub-agent**) Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Replace embedded `task()` routing instructions with orchestrator-routing markers.
- [ ] 3. **Post-regression.** (**sub-agent**) Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run regression test patterns after GREEN.
- [ ] 4. **Verify.** (**sub-agent**) Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Assert `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for this task card.
- [ ] 5. **Commit.** (**inline**) Run `git add <files> && git commit -m "<message>"` for `issue-operations-core/tasks/read-issue.md`.

### Item 20 (SC-20): Remediate issue-operations-core read-labels task-card internal dispatch

- [ ] 1. **RED.** (**sub-agent**) Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Assert `skildeck lint` shows `task-card-internal-dispatch` for `issue-operations-core/tasks/read-labels.md`.
- [ ] 2. **GREEN.** (**sub-agent**) Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Replace embedded `task()` routing instructions with orchestrator-routing markers.
- [ ] 3. **Post-regression.** (**sub-agent**) Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run regression test patterns after GREEN.
- [ ] 4. **Verify.** (**sub-agent**) Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Assert `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for this task card.
- [ ] 5. **Commit.** (**inline**) Run `git add <files> && git commit -m "<message>"` for `issue-operations-core/tasks/read-labels.md`.

### Item 21 (SC-21): Remediate issue-operations-core search-issues task-card internal dispatch

- [ ] 1. **RED.** (**sub-agent**) Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Assert `skildeck lint` shows `task-card-internal-dispatch` for `issue-operations-core/tasks/search-issues.md`.
- [ ] 2. **GREEN.** (**sub-agent**) Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Replace embedded `task()` routing instructions with orchestrator-routing markers.
- [ ] 3. **Post-regression.** (**sub-agent**) Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run regression test patterns after GREEN.
- [ ] 4. **Verify.** (**sub-agent**) Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Assert `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for this task card.
- [ ] 5. **Commit.** (**inline**) Run `git add <files> && git commit -m "<message>"` for `issue-operations-core/tasks/search-issues.md`.

### Item 22 (SC-22): Remediate issue-operations-core update-issue task-card internal dispatch

- [ ] 1. **RED.** (**sub-agent**) Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Assert `skildeck lint` shows `task-card-internal-dispatch` for `issue-operations-core/tasks/update-issue.md`.
- [ ] 2. **GREEN.** (**sub-agent**) Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Replace embedded `task()` routing instructions with orchestrator-routing markers.
- [ ] 3. **Post-regression.** (**sub-agent**) Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run regression test patterns after GREEN.
- [ ] 4. **Verify.** (**sub-agent**) Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Assert `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for this task card.
- [ ] 5. **Commit.** (**inline**) Run `git add <files> && git commit -m "<message>"` for `issue-operations-core/tasks/update-issue.md`.

### Item 23 (SC-23): Remediate issue-operations-sub-issues link-sub-issue task-card internal dispatch

- [ ] 1. **RED.** (**sub-agent**) Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Assert `skildeck lint` shows `task-card-internal-dispatch` for `issue-operations-sub-issues/tasks/link-sub-issue.md`.
- [ ] 2. **GREEN.** (**sub-agent**) Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Replace embedded `task()` routing instructions with orchestrator-routing markers.
- [ ] 3. **Post-regression.** (**sub-agent**) Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run regression test patterns after GREEN.
- [ ] 4. **Verify.** (**sub-agent**) Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Assert `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for this task card.
- [ ] 5. **Commit.** (**inline**) Run `git add <files> && git commit -m "<message>"` for `issue-operations-sub-issues/tasks/link-sub-issue.md`.

### Item 24 (SC-24): Remediate issue-operations-sub-issues read-sub-issues task-card internal dispatch

- [ ] 1. **RED.** (**sub-agent**) Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Assert `skildeck lint` shows `task-card-internal-dispatch` for `issue-operations-sub-issues/tasks/read-sub-issues.md`.
- [ ] 2. **GREEN.** (**sub-agent**) Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Replace embedded `task()` routing instructions with orchestrator-routing markers.
- [ ] 3. **Post-regression.** (**sub-agent**) Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run regression test patterns after GREEN.
- [ ] 4. **Verify.** (**sub-agent**) Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Assert `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for this task card.
- [ ] 5. **Commit.** (**inline**) Run `git add <files> && git commit -m "<message>"` for `issue-operations-sub-issues/tasks/read-sub-issues.md`.

### Item 25 (SC-25): Remediate issue-operations-sync import-remote task-card internal dispatch

- [ ] 1. **RED.** (**sub-agent**) Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Assert `skildeck lint` shows `task-card-internal-dispatch` for `issue-operations-sync/tasks/import-remote.md`.
- [ ] 2. **GREEN.** (**sub-agent**) Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Replace embedded `task()` routing instructions with orchestrator-routing markers.
- [ ] 3. **Post-regression.** (**sub-agent**) Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run regression test patterns after GREEN.
- [ ] 4. **Verify.** (**sub-agent**) Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Assert `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for this task card.
- [ ] 5. **Commit.** (**inline**) Run `git add <files> && git commit -m "<message>"` for `issue-operations-sync/tasks/import-remote.md`.

### Item 26 (SC-26): Remediate issue-operations-sync sync-pull-to-local task-card internal dispatch

- [ ] 1. **RED.** (**sub-agent**) Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Assert `skildeck lint` shows `task-card-internal-dispatch` for `issue-operations-sync/tasks/sync-pull-to-local.md`.
- [ ] 2. **GREEN.** (**sub-agent**) Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Replace embedded `task()` routing instructions with orchestrator-routing markers.
- [ ] 3. **Post-regression.** (**sub-agent**) Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run regression test patterns after GREEN.
- [ ] 4. **Verify.** (**sub-agent**) Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Assert `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for this task card.
- [ ] 5. **Commit.** (**inline**) Run `git add <files> && git commit -m "<message>"` for `issue-operations-sync/tasks/sync-pull-to-local.md`.

### Item 27 (SC-27): Remediate issue-review audit task-card internal dispatch and prose mentions

- [ ] 1. **RED.** (**sub-agent**) Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Assert `skildeck lint` shows `task-card-internal-dispatch` for `issue-review/tasks/audit.md`.
- [ ] 2. **GREEN.** (**sub-agent**) Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Replace embedded dispatch in `issue-review/tasks/audit.md`; reword prose mentions that trigger the lint token pattern.
- [ ] 3. **Post-regression.** (**sub-agent**) Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run regression test patterns after GREEN.
- [ ] 4. **Verify.** (**sub-agent**) Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Assert `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for this task card.
- [ ] 5. **Commit.** (**inline**) Run `git add <files> && git commit -m "<message>"` for `issue-review/tasks/audit.md`.

### Item 28 (SC-28): Remediate sre-runbook track task-card internal dispatch and prose mentions

- [ ] 1. **RED.** (**sub-agent**) Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Assert `skildeck lint` shows `task-card-internal-dispatch` for `sre-runbook/tasks/track.md`.
- [ ] 2. **GREEN.** (**sub-agent**) Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Replace embedded dispatch in `sre-runbook/tasks/track.md`; reword prose mentions that trigger the lint token pattern.
- [ ] 3. **Post-regression.** (**sub-agent**) Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run regression test patterns after GREEN.
- [ ] 4. **Verify.** (**sub-agent**) Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Assert `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for this task card.
- [ ] 5. **Commit.** (**inline**) Run `git add <files> && git commit -m "<message>"` for `sre-runbook/tasks/track.md`.

### Item 29 (SC-29): Remediate multimodal-dispatch completion task-card internal dispatch and prose mentions

- [ ] 1. **RED.** (**sub-agent**) Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Assert `skildeck lint` shows `task-card-internal-dispatch` for `multimodal-dispatch/tasks/completion.md`.
- [ ] 2. **GREEN.** (**sub-agent**) Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Replace embedded dispatch in `multimodal-dispatch/tasks/completion.md`; reword prose mentions that trigger the lint token pattern.
- [ ] 3. **Post-regression.** (**sub-agent**) Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run regression test patterns after GREEN.
- [ ] 4. **Verify.** (**sub-agent**) Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Assert `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for this task card.
- [ ] 5. **Commit.** (**inline**) Run `git add <files> && git commit -m "<message>"` for `multimodal-dispatch/tasks/completion.md`.

### Item 30 (SC-30): Remediate multimodal-dispatch dispatch task-card internal dispatch and prose mentions

- [ ] 1. **RED.** (**sub-agent**) Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Assert `skildeck lint` shows `task-card-internal-dispatch` for `multimodal-dispatch/tasks/dispatch.md`.
- [ ] 2. **GREEN.** (**sub-agent**) Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Replace embedded dispatch in `multimodal-dispatch/tasks/dispatch.md`; reword prose mentions that trigger the lint token pattern.
- [ ] 3. **Post-regression.** (**sub-agent**) Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run regression test patterns after GREEN.
- [ ] 4. **Verify.** (**sub-agent**) Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Assert `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for this task card.
- [ ] 5. **Commit.** (**inline**) Run `git add <files> && git commit -m "<message>"` for `multimodal-dispatch/tasks/dispatch.md`.

### Item 31 (SC-31): Remediate pre-analysis analyze task-card internal dispatch and prose mentions

- [ ] 1. **RED.** (**sub-agent**) Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Assert `skildeck lint` shows `task-card-internal-dispatch` for `pre-analysis/tasks/analyze.md`.
- [ ] 2. **GREEN.** (**sub-agent**) Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Replace embedded dispatch in `pre-analysis/tasks/analyze.md`; reword prose mentions that trigger the lint token pattern.
- [ ] 3. **Post-regression.** (**sub-agent**) Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run regression test patterns after GREEN.
- [ ] 4. **Verify.** (**sub-agent**) Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Assert `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for this task card.
- [ ] 5. **Commit.** (**inline**) Run `git add <files> && git commit -m "<message>"` for `pre-analysis/tasks/analyze.md`.

### Item 32 (SC-32): Remediate verification verify task-card internal dispatch and prose mentions

- [ ] 1. **RED.** (**sub-agent**) Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Assert `skildeck lint` shows `task-card-internal-dispatch` for `verification/tasks/verify.md`.
- [ ] 2. **GREEN.** (**sub-agent**) Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Replace embedded dispatch in `verification/tasks/verify.md`; reword prose mentions that trigger the lint token pattern.
- [ ] 3. **Post-regression.** (**sub-agent**) Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run regression test patterns after GREEN.
- [ ] 4. **Verify.** (**sub-agent**) Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Assert `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for this task card.
- [ ] 5. **Commit.** (**inline**) Run `git add <files> && git commit -m "<message>"` for `verification/tasks/verify.md`.

## Phase 2 Completion Block

- [ ] V1. `skildeck lint` shows zero `task-card-internal-dispatch` findings for all 22 task-card files.
- [ ] V2. All 22 Phase 2 items committed as atomic slices, one commit per task card.

---

# Post-Implementation Steps

- [ ] Q1. **Audit.** (**sub-agent**) Dispatch `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")`, followed by validator, evaluator, arbiter in sequence. Adversarial audit of the deliverable.
- [ ] Q2. **Z3 check.** (**inline**) Run `.opencode/tools/solve check --state-path ... --contract-path ...` to verify workflow constraints.
- [ ] Q3. **Structural checks.** (**sub-agent**) Dispatch `task(..., prompt: "execute checklist task from finishing-a-development-branch")`. Run finishing checklist (lint, typecheck, etc.).
- [ ] Q4. **Pre-PR gate.** (**sub-agent**) Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Read all SC verdicts; BLOCK if any FAIL.
- [ ] Q5. **Regression check.** (**sub-agent**) Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Final regression check before PR.
- [ ] Q6. **Review-prep.** (**sub-agent**) Dispatch `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")`. Prepare PR review context.
- [ ] Q7. **Create PR.** (**sub-agent**) Dispatch `task(..., prompt: "execute create task from git-workflow-pr")`. Create the pull request.
- [ ] Q8. **Exec summary.** (**sub-agent**) Dispatch `task(..., prompt: "execute completion task from completion-core")`. Generate completion executive summary.

---

## Lifecycle Events

- **`plan_created`** at `2026-08-31T16:04:35Z` — Plan file created at `.opencode/.issues/2410/plan.md`. Content: 2 phases (Dispatch contract alignment, Task-card internal-dispatch remediation), 32 SCs, 32 daisy-chained items. Execution: Phase 1 and Phase 2 both dispatched via test-driven-development (RED/GREEN/post-regression/verify) with clean-room sub-agents; commits inline. Downstream pipeline signal: proceed to pre-implementation coherence gate (P1) then baseline check (P2).
