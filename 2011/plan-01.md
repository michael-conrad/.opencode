# Phase 1: BEH-EV classification gate, clean-room evaluator, fix 9 evaluators, fix cross-validate

**Issue:** #2011
**Spec:** `.opencode/.issues/2011/spec.md`
**Plan index:** `.opencode/.issues/2011/plan.md`
**Status:** DRAFT
**Created:** 2026-07-19
**Revised:** 2026-07-21 — Removed sub-agent dispatch chain (sub-agents cannot call task()). Replaced with orchestrator-executed inline steps.

## Concern

Behavioral SC evidence pipeline: classification at spec-writing, clean-room evaluation at audit.

## Entry Criteria

- [ ] Feature branch exists (current: `feature/2032-strip-dispatch-markers-from-task-cards`)
- [ ] #2032 Phase 1 complete (18 task cards stripped of dispatch markers)
- [ ] `local-issues sync` run before any file changes

## Implementation Items

### Item A: BEH-EV classification step in spec-creation-validation/tasks/create.md

**SCs:** SC-1
**Files:** `.opencode/skills/spec-creation-validation/tasks/create.md`

Add mandatory "Evidence Type Classification Gate" step between SC definition and spec finalization. Include presumptive runtime-behavioral file types: SKILL.md, tasks/*.md, guidelines/*.md, enforcement/*.md.

### Item B: Clean-room evaluation task + fix all 9 evaluators

**SCs:** SC-2, SC-3
**Files:** `.opencode/skills/audit/tasks/behavioral-sc-evaluator.md` (new), all 9 `*-evaluator.md` files

Create `behavioral-sc-evaluator.md` — receives ONLY artifact directory path, reads stdout.log/stderr.log, renders binary PASS/FAIL. File-existence alone returns FAIL. Then add dispatch step to each of the 9 evaluator tasks.

### Item C: EVIDENCE_TYPE_MISMATCH detection in cross-validate

**SCs:** SC-4
**Files:** `.opencode/skills/audit/tasks/cross-validate.md`

Add detection: if behavioral SC verdict cites only file paths (no content analysis), downgrade to FAIL.

## Implementation Steps (Orchestrator-Executed)

All steps are executed by the orchestrator directly. No sub-agent is asked to dispatch other sub-agents.

### Item A — BEH-EV classification step

- [ ] A1. Read `spec-creation-validation/tasks/create.md` to find the SC definition section
- [ ] A2. Add "Evidence Type Classification Gate" step between SC definition and spec finalization
- [ ] A3. Include presumptive runtime-behavioral file types: SKILL.md, tasks/*.md, guidelines/*.md, enforcement/*.md
- [ ] A4. Verify: grep for "Evidence Type Classification Gate" in create.md

### Item B — Create behavioral-sc-evaluator.md

- [ ] B1. Create `audit/tasks/behavioral-sc-evaluator.md` with:
  - Entry criteria: artifact directory path provided
  - Procedure: read stdout.log/stderr.log from artifact dir, evaluate each SC against agent output
  - Binary PASS/FAIL per SC — file-existence alone returns FAIL
  - Exit criteria: verdict.yaml written with per-SC results
  - No orchestrator context, no expected outcomes, no cached results

### Item B — Fix each evaluator to dispatch clean-room for behavioral SCs

For each of the 9 evaluator files, add a step that dispatches `behavioral-sc-evaluator` for behavioral SCs. If clean-room returns FAIL, evaluator verdict is FAIL.

- [ ] B2. `verification-audit-evaluator.md` — add clean-room dispatch step
- [ ] B3. `spec-audit-evaluator.md` — add clean-room dispatch step
- [ ] B4. `plan-fidelity-evaluator.md` — add clean-room dispatch step
- [ ] B5. `concern-separation-evaluator.md` — add clean-room dispatch step
- [ ] B6. `coherence-maintenance-evaluator.md` — add clean-room dispatch step
- [ ] B7. `drift-detection-evaluator.md` — add clean-room dispatch step
- [ ] B8. `test-quality-audit-evaluator.md` — add clean-room dispatch step
- [ ] B9. `content-audit-evaluator.md` — add clean-room dispatch step
- [ ] B10. `guideline-audit-evaluator.md` — add clean-room dispatch step

### Item C — EVIDENCE_TYPE_MISMATCH detection in cross-validate

- [ ] C1. Read `cross-validate.md` to find evidence type evaluation section
- [ ] C2. Add EVIDENCE_TYPE_MISMATCH detection: if behavioral SC verdict cites only file paths (no content analysis), downgrade to FAIL
- [ ] C3. Verify: grep for EVIDENCE_TYPE_MISMATCH in cross-validate.md

### Verification

- [ ] V1. grep for prohibited patterns across all modified files — no dispatch markers remain
- [ ] V2. Verify all 5 SCs from #2009 remain satisfied (grep #2009 spec for SC-1 through SC-5)
- [ ] V3. Run `local-issues sync`
- [ ] V4. Commit all changes to feature branch

## RED/GREEN Chains

| Item | RED | GREEN |
|------|-----|-------|
| A | create.md has no BEH-EV classification step | create.md has "Evidence Type Classification Gate" step |
| B | No behavioral-sc-evaluator.md; evaluators accept file-existence | behavioral-sc-evaluator.md created; all 9 evaluators dispatch clean-room |
| C | cross-validate has no EVIDENCE_TYPE_MISMATCH check | cross-validate FAILs on file-path-only behavioral verdicts |

## VbC Blocks

| SC | Verification | Evidence |
|----|-------------|----------|
| SC-1 | grep for "Evidence Type Classification Gate" in create.md | grep output |
| SC-2 | grep for "behavioral-sc-evaluator" in each evaluator file | grep output |
| SC-3 | behavioral-sc-evaluator.md exists and has correct structure | file read |
| SC-4 | grep for "EVIDENCE_TYPE_MISMATCH" in cross-validate.md | grep output |
| SC-5 | grep #2009 spec for SC-1 through SC-5 | grep output |

## Phase Completion

- [ ] All 5 SCs verified
- [ ] Changes committed to feature branch
- [ ] `local-issues sync` run
