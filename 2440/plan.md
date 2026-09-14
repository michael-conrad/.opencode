---
plan_schema_version: "1.0"
issue: 2440
title: "Fix trunk-tip-verification gate safe-state misclassification (parent_clean / submodule_pointer_match WARN, Step 8 fail-open fix, contract sync, regression)"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 2
dispatch:
  - phase-1: "test-driven-development (red, green, post-regression) + verification-before-completion (verify) + orchestrator commit-inline"
  - phase-2: "test-driven-development (red, green, post-regression) + verification-before-completion (verify) + orchestrator commit-inline"
---

# Implementation Plan — #2440 — Trunk-Tip-Verification Gate Safe-State Reclassification

**Issue:** `.opencode/.issues/2440/spec.md`

**Goal:** Make the trunk-tip-verification pre-work gate satisfiable in the safe state (submodule checked out at its own remote trunk tip with merged pointer commit) by reclassifying pointer staleness signals as WARN (release-capture-pending), fixing the Step 8 fail-open shell construct, syncing the Result Contract, and regression-protecting the `SUBMODULE_UNMERGED_COMMIT` blocking behavior.

**Architecture:** The gate conflates safe state (submodule checkout == submodule's `origin/<default>` tip AND pointer commit merged) with hazard state (local-only pointer commit). Steps 2 and 7 reclassify their failure signals to WARN conditioned on the safe-state predicate already computed by steps 6 and 8 — no new checks, no new check IDs, no new network calls. Step 8's invalid `continue` in the network-fail-open branch becomes if/else. Exit Criteria and Result Contract prose mirror the new classification. Phase 2 protects the hazard-state blocking behavior with behavioral regression evidence.

**Files:**
- `.opencode/skills/git-workflow-branch/tasks/trunk-tip-verification.md` (Step 2, Step 7, Step 8, Exit Criteria, Result Contract)
- `.opencode/tests-v2/behaviors/` (new safe-state scenario)
- `.opencode/tests-v2/behaviors/trunk-tip-enforcement.sh` (assertion sync)
- `.opencode/tests-v2/behaviors/git-workflow/2313-sc1-prework-merged-commit.sh` (read-only regression target)

---

## Phase Table

| Phase | Name | Concern | SCs | Depends On | Step Range | Dispatch |
|-------|------|---------|-----|------------|------------|----------|
| 1 | task-card safe-state semantics | safe-state-vs-hazard-state classification in trunk-tip-verification.md | SC-1, SC-2, SC-3, SC-4 | — | 5-25 | direct (5, 9, 14, 19, 24, 25) + task-card (6-8, 10-13, 15-18, 20-23) |
| 2 | behavioral regression verification | hazard-state blocking preserved + safe-state DONE-with-WARN proven | SC-5 | 1 | 26-38 | direct (30, 32, 38) + task-card (26-29, 31, 33-37) |

Phase files:
- [Phase 1 — task-card safe-state semantics](plan-01-safe-state-semantics.md)
- [Phase 2 — behavioral regression verification](plan-02-behavioral-regression.md)

---

## Blast Radius

- Phase 1 items touch one file (`trunk-tip-verification.md`) plus new/updated behavioral test scripts. Risk: LOW for items 1–3 (additive classification, FAIL retained for genuine dirt); MEDIUM for item 4 (test assertion drift in `trunk-tip-enforcement.sh` is the main failure mode — the `SUBMODULE_UNMERGED_COMMIT` blocking assertion MUST NOT be weakened).
- `pre-work.md` consumes the gate status only; DONE-with-WARN is a new non-blocking terminal state — verified read-only, no prose change required.
- Out of blast: pre-red-baseline gate (#2013), `submodule-sync.md`, `pre-commit-pointer-check.md`, AGENTS.md prose.

---

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

---

## Pre-Implementation Steps

- [ ] 1. **Coherence gate (**direct**).** Verify the plan matches the spec: SC-1..SC-4 map to phase 1 items 1–4, SC-5 maps to phase 2; structure artifact DAG (phase-1 → phase-2 via SC-1/SC-2/SC-4) has no cycles; every phase's target files match the spec's affected files.
  - Re-read `.opencode/.issues/2440/artifacts/plan-input-verification.md` (the input ledger) — do not re-verify sources it covers.
  - If any mapping mismatch is found: return BLOCKED with `PLAN_SPEC_INCOHERENCE`.
- [ ] 2. **Baseline check (**direct**).** Verify the working tree is in a permitted starting state.
  - Run `git status --porcelain` in the parent repo and in the `.opencode` submodule — both must be clean.
  - Run `git submodule status` — no `+` prefix drift on `.opencode`; submodule is on its default branch.
  - Verify the submodule effective commit is contained in a remote ref (fresh `git fetch` + containment check).
  - Create the feature branch per `git-workflow-branch` pre-work before any file modification.
- [ ] 3. **Pre-regression (**task-card**).** Run regression test patterns before the RED phase (test-driven-development phase-0 task) — baseline the existing `trunk-tip-enforcement.sh` and `2313-sc1-prework-merged-commit.sh` outcomes.
  - Pre-clean: `rm -f tmp/.behavior-run.lock` and `rm -f tmp/2440/artifacts/pipeline-pre-regression-*`.
- [ ] 4. **Pre-regression verify (**task-card**).** Verify pre-regression results (verification-before-completion verify task) — record the baseline pass/fail set as evidence in `tmp/2440/artifacts/pipeline-pre-regression-verify-*`.

---

## Phase Details

### Phase 1 — Task-Card Safe-State Semantics

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` (red, green, post-regression) + `verification-before-completion` (verify) |
| Task | red → green → post-regression → verify → commit-inline, per item |
| Target | `.opencode/skills/git-workflow-branch/tasks/trunk-tip-verification.md` (Steps 2, 7, 8, Exit Criteria, Result Contract) + behavioral scenario scripts |
| SCs | SC-1, SC-2, SC-3, SC-4 |
| Depends On | — (pre-implementation steps 1-4) |

**Context:**
- Safe-state predicate: submodule checkout == submodule's `origin/<default>` tip (step 6) AND merged-commit check passes (step 8) — derived from existing computations, no new checks or network calls
- WARN semantics: release-capture-pending; WARN never blocks pre-work; FAIL retained for genuine dirt; `SUBMODULE_UNMERGED_COMMIT` invariant
- Full step-by-step: [plan-01-safe-state-semantics.md](plan-01-safe-state-semantics.md)

### Phase 2 — Behavioral Regression Verification

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` (red, green, post-regression) + `verification-before-completion` (verify) |
| Task | red → green → post-regression → verify → commit-inline |
| Target | `.opencode/tests-v2/behaviors/` combined suite run |
| SCs | SC-5 |
| Depends On | 1 |

**Context:**
- Regression targets: `trunk-tip-enforcement.sh`, `2313-sc1-prework-merged-commit.sh`, new safe-state scenario
- Harness: `bash .opencode/tests-v2/with-test-home opencode run '<scenario>'` with `>=600s` timeout; `rm -f tmp/.behavior-run.lock` before re-runs
- Full step-by-step: [plan-02-behavioral-regression.md](plan-02-behavioral-regression.md)

---

## Exit Criteria

- [ ] C1. Safe-state pointer-only ` M <submodule>` classifies `parent_clean` as WARN (release-capture-pending) with gate status DONE — behavioral evidence via `with-test-home opencode run`. **→ SC-1**
- [ ] C2. Safe-state `+` prefix classifies `submodule_pointer_match` as WARN with gate status DONE — behavioral evidence via `with-test-home opencode run`. **→ SC-2**
- [ ] C3. Step 8 network-fail-open branch uses if/else; `continue` is absent from the foreach eval body; WARN-skip message preserved. **→ SC-3**
- [ ] C4. Exit Criteria and Result Contract document `parent_clean` and `submodule_pointer_match` as `PASS | WARN | FAIL` with WARN = release-capture-pending, and `SUBMODULE_UNMERGED_COMMIT` as the only BLOCKED trigger; `trunk-tip-enforcement.sh` assertions synced without weakening the blocking assertion. **→ SC-4**
- [ ] C5. Combined behavioral suite is green: `trunk-tip-enforcement.sh` + `2313-sc1-prework-merged-commit.sh` + new safe-state scenario — hazard state still BLOCKs, safe state DONE with WARNs. **→ SC-5**
- [ ] C6. All commits made; branch pushed; no `--no-verify`; submodule pointer rides with the next real parent-repo change (never a standalone pointer commit).

---

## Enforcement Gate

> **Enforcement gate:** All SCs must pass before this plan is complete.

---

## Self-Remediation Protocol

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

---

## Lifecycle Events

- 2026-09-13T21:47:00-04:00 — `plan_created` — plan file: `.opencode/.issues/2440/plan.md` — phase count: 2

## Pre-Flight Guard (Mandatory)

Check your tool list for a tool named `task`.

- Present ⇒ orchestrator — proceed.
- Absent ⇒ sub-agent — do NOT execute any instruction below. Return `BLOCKED` with `ORCHESTRATOR_ONLY_SKILL_CARD` (cards) or `ORCHESTRATOR_ONLY_PLAN` (plans) and halt.
