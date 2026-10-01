---
plan_schema_version: "1.0"
issue: 2314
title: "Enforcement gate blocking spec-creation → implementation dispatch without plan.md"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 2
dispatch:
  - phase-1: test-driven-development (red, green, phase-4), verification-before-completion (verify)
  - phase-2: test-driven-development (red, green, phase-4), verification-before-completion (verify)
---

# Implementation Plan — #2314 — Enforcement Gate Blocking Spec-to-Implementation Dispatch Without a Plan

**Issue:** `.opencode/.issues/2314/spec.md`

**Goal:** Add an enforcement gate at the spec-creation → implementation dispatch boundary that checks whether a local plan.md exists before allowing implementation dispatch, blocking with PLAN_MISSING when it does not.

**Architecture:** The gate is a routing entry in the skill deck (spec-creation and executing-plans skill cards) backed by a CRITICAL VIOLATION rule in the core guidelines and a PLAN_MISSING vocabulary registration in the canonical dispatch-vocabulary table. Behavioral enforcement tests then prove the gate blocks plan-less dispatch and permits plan-bearing dispatch.

**Files:**
- `.opencode/skills/spec-creation/`
- `.opencode/skills/executing-plans/`
- `.opencode/guidelines/`
- `.opencode/reference/`
- `.opencode/tests-v2/behaviors/`

## Blast Radius

- Skill-card routing changes affect every spec-creation → implementation handoff session-wide; a false-positive block is a pipeline-availability defect, which is why SC-3 (no false-positive block) is a separate SC with its own behavioral leg
- Guideline CRITICAL VIOLATION entry affects all agents loading the Tier 1 guideline set
- Vocabulary registration affects every deck surface that routes on PLAN_MISSING
- New behavioral scenario in `tests-v2/behaviors/` affects the enforcement test suite runtime only

## Admonishments

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

> **Enforcement gate:** All SCs must pass before this plan is complete.

## Phase Table

| Phase | Name | Concern | SCs | Depends On | Step Range | Dispatch |
|-------|------|---------|-----|------------|------------|----------|
| 1 | dispatch-gate-logic | Gate existence and block/permit behavior at the spec-creation → implementation boundary | SC-1, SC-2, SC-3 | — | 3-22 | direct (3-7, 12-13, 20) + task-card (8-11, 14-19, 21-22) |
| 2 | behavioral-enforcement | End-to-end behavioral enforcement scenario for the gate | SC-4 | 1 | 23-39 | direct (27-28) + task-card (23-26, 29-39) |

## Pre-Implementation

- [ ] 1. **Coherence gate (**direct**).** Confirm no superseding open spec conflicts with #2314 and that this plan is the single active plan for the issue.
  - Blocking condition: a conflicting open spec or a second active plan for #2314 exists
- [ ] 2. **Baseline check (**direct**).** Verify parent repo and `.opencode` submodule are on `$DEFAULT_BRANCH` at remote tracking tip with zero pending changes, and create the feature branch before any file modification.
  - Blocking condition: trunk-tip verification fails or submodule pointer is dirty

## Phase Stubs

- Phase 1 file: `plan-01-dispatch-gate-logic.md`
- Phase 2 file: `plan-02-behavioral-enforcement.md` (includes post-implementation steps)

## Self-Remediation and Enforcement

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

> **Enforcement gate:** All SCs must pass before this plan is complete.

## Exit Criteria

- [ ] C1. A gate exists at the spec-creation → implementation dispatch boundary that checks plan.md existence before allowing implementation dispatch (SC-1)
- [ ] C2. A dispatch attempt with no plan.md present is BLOCKED with PLAN_MISSING (SC-2)
- [ ] C3. A dispatch attempt with plan.md present at the expected path proceeds without a false-positive PLAN_MISSING block (SC-3)
- [ ] C4. A registered behavioral enforcement scenario demonstrates the gate blocks plan-less dispatch and permits plan-bearing dispatch (SC-4)
- [ ] C5. All SC verdicts are PASS with evidence-type-matched artifacts; no DONE_WITH_CONCERNS coercion applies
- [ ] C6. PR created (stacked strategy, one branch) with plan, test, and gate changes committed

## Pre-Flight Guard (Mandatory)

Check your tool list for a tool named `task`.

- Present ⇒ orchestrator — proceed.
- Absent ⇒ sub-agent — do NOT execute any instruction below. Return `BLOCKED` with `ORCHESTRATOR_ONLY_SKILL_CARD` (cards) or `ORCHESTRATOR_ONLY_PLAN` (plans) and halt.
