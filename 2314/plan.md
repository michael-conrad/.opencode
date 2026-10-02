---
plan_schema_version: "1.0"
issue: 2314
title: "Enforcement gate blocking spec-creation → implementation dispatch without plan.md"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 3
dispatch:
  - phase-1: test-driven-development (red, green, phase-4), verification-before-completion (verify)
  - phase-2: test-driven-development (red, green, phase-4), verification-before-completion (verify)
  - phase-3: test-driven-development (red, green, phase-4), verification-before-completion (verify)
---

# Implementation Plan — #2314 — Enforcement Gate Blocking Spec-to-Implementation Dispatch Without a Plan

**Issue:** `.opencode/.issues/2314/spec.md`

**Goal:** Add an enforcement gate at the spec-creation → implementation dispatch boundary that checks whether a local plan.md exists before allowing implementation dispatch, blocking with PLAN_MISSING when it does not.

**Architecture:** The gate is a routing entry in the skill deck (spec-creation and executing-plans skill cards) backed by a CRITICAL VIOLATION rule in the core guidelines and a PLAN_MISSING vocabulary registration in the canonical dispatch-vocabulary table. Behavioral enforcement tests then prove the gate blocks plan-less dispatch and permits plan-bearing dispatch — each leg as its own atomic SC.

**SC set (revised 2026-10-01 per validation findings):** SC-1 (spec-creation card gate), SC-2 (executing-plans card gate), SC-3 (CRITICAL VIOLATION entry), SC-4 (PLAN_MISSING vocabulary), SC-5 (plan-less dispatch blocked — behavioral), SC-6 (plan-bearing dispatch proceeds — behavioral), SC-7 (scenario block leg — behavioral), SC-8 (scenario permit leg — behavioral), SC-9 (supervision configuration — structural), SC-10 (supervised run §14 evidence — behavioral).

**Files:**
- `.opencode/skills/spec-creation/`
- `.opencode/skills/executing-plans/`
- `.opencode/guidelines/`
- `.opencode/reference/`
- `.opencode/tests-v2/behaviors/`

## Blast Radius

- Skill-card routing changes affect every spec-creation → implementation handoff session-wide; a false-positive block is a pipeline-availability defect, which is why SC-6 and SC-8 (no false-positive block) are separate atomic SCs with their own behavioral legs
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
| 1 | dispatch-gate-logic | Gate existence and block/permit behavior at the spec-creation → implementation boundary | SC-1..SC-6 | — | 3-32 | direct (6, 10, 14, 18, 23, 24, 30) + task-card (3-5, 7-9, 11-13, 15-17, 19-22, 25-29, 31-32) |
| 2 | behavioral-enforcement | End-to-end behavioral enforcement scenario (block + permit legs) | SC-7, SC-8 | 1 | 33-54 | direct (37, 38, 44, 47) + task-card (33-36, 39-43, 45-46, 48-54) |
| 3 | behavioral-run-supervision | Semantic monitoring of this issue's behavioral run legs per tests-v2 §14 | SC-9, SC-10 | 1, 2 | 55-62 | direct (58, 61) + task-card (55-57, 59-60, 62) |

## Pre-Implementation

- [ ] 1. **Coherence gate (**direct**).** Confirm no superseding open spec conflicts with #2314 and that this plan is the single active plan for the issue.
  - Blocking condition: a conflicting open spec or a second active plan for #2314 exists
- [ ] 2. **Baseline check (**direct**).** Verify parent repo and `.opencode` submodule are on `$DEFAULT_BRANCH` at remote tracking tip with zero pending changes, and create the feature branch before any file modification.
  - Blocking condition: trunk-tip verification fails or submodule pointer is dirty

## Phase Stubs

- Phase 1 file: `plan-01-dispatch-gate-logic.md`
- Phase 2 file: `plan-02-behavioral-enforcement.md` (includes post-implementation steps)
- Phase 3 file: `plan-03-behavioral-run-supervision.md`

## Self-Remediation and Enforcement

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

> **Enforcement gate:** All SCs must pass before this plan is complete.

## Exit Criteria

- [ ] C1. A gate entry exists in `.opencode/skills/spec-creation/SKILL.md` at the spec-creation → implementation dispatch boundary that checks plan.md existence (SC-1)
- [ ] C2. Gate routing exists in `.opencode/skills/executing-plans/SKILL.md` (SC-2)
- [ ] C3. A PLAN_MISSING CRITICAL VIOLATION (Tier 1) entry exists in `000-critical-rules.md` (SC-3)
- [ ] C4. PLAN_MISSING is registered in the canonical dispatch-vocabulary table (SC-4)
- [ ] C5. A plan-less dispatch attempt is BLOCKED with PLAN_MISSING (SC-5)
- [ ] C6. A plan-bearing dispatch attempt proceeds without a false-positive block (SC-6)
- [ ] C7. The registered scenario demonstrates the gate blocks plan-less dispatch end-to-end (SC-7)
- [ ] C8. The registered scenario demonstrates the gate permits plan-bearing dispatch end-to-end (SC-8)
- [ ] C9. 2314 scenario leg scripts set `BEHAVIOR_SEMANTIC_MONITOR=1` and plan run-step text carries the §14 Read-link (SC-9)
- [ ] C10. A supervised run produces §14 monitor evidence recorded alongside session.yaml (SC-10)
- [ ] C11. All SC verdicts are PASS with evidence-type-matched artifacts; no DONE_WITH_CONCERNS coercion applies
- [ ] C12. PR created (stacked strategy, one branch) with plan, test, and gate changes committed

## Lifecycle Events

```yaml
lifecycle_events:
  - timestamp: "2026-10-01T18:16:00-04:00"
    event: plan_created
    plan_file: ".opencode/.issues/2314/plan.md"
    phase_count: 2
  - timestamp: "2026-10-01T22:45:00-04:00"
    event: plan_revised
    plan_file: ".opencode/.issues/2314/plan.md"
    revision_reason: "Developer-directed SC addition after SC-2 behavioral-run regression — added Phase 3 (behavioral-run supervision), amended run-step instruction text with BEHAVIOR_SEMANTIC_MONITOR=1 and tests-v2 §14 Read-links"
    phase_count: 3
  - timestamp: "2026-10-01T23:10:00-04:00"
    event: plan_revised
    plan_file: ".opencode/.issues/2314/plan.md"
    revision_reason: "Spec validation findings (aggregate FAIL) — renumbered SC set to atomic 1:1 mapping (SC-1..SC-4 split from compound deck-surface SC; block/permit legs split into SC-7/SC-8 and SC-5/SC-6; supervision SC split into SC-9 structural + SC-10 behavioral); regenerated phase files and step ranges to match"
    phase_count: 3
```

## Pre-Flight Guard (Mandatory)

Check your tool list for a tool named `task`.

- Present ⇒ orchestrator — proceed.
- Absent ⇒ sub-agent — do NOT execute any instruction below. Return `BLOCKED` with `ORCHESTRATOR_ONLY_SKILL_CARD` (cards) or `ORCHESTRATOR_ONLY_PLAN` (plans) and halt.
