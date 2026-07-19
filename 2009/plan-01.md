# Phase 1: Fix critical rule, behavioral test, plan template, audit evaluator

**Issue:** #2009
**Spec:** `.opencode/.issues/2009/spec.md`
**Plan index:** `.opencode/.issues/2009/plan.md`
**Status:** DRAFT
**Created:** 2026-07-19

## Concern

Spec-creation pipeline enforcement and plan template completeness.

## Entry Criteria

- [ ] Spec #2009 is approved (`approved-for-plan` label present)
- [ ] Feature branch exists (current: `feature/1962-writing-plans-workflow-fix`)
- [ ] All 7 analytical artifacts exist at `.opencode/.issues/2009/artifacts/`
- [ ] `local-issues sync` run before any file changes

## Implementation Items

### Item A: Upgrade critical rule + behavioral test

**SCs:** SC-1, SC-2
**Files:** `.opencode/guidelines/000-critical-rules.md`, `.opencode/tests-v2/behaviors/spec-creation-pipeline-routing.sh`

Upgrade direct `github_issue_write` for spec content from Tier 2 to Tier 1 CRITICAL VIOLATION. Create behavioral enforcement test verifying agent routes spec creation through spec-creation pipeline.

### Item B: Fix plan template (write.md)

**SCs:** SC-3
**Files:** `.opencode/skills/writing-plans-creation/tasks/write.md`

Add mandatory Pipeline Steps section to plan template with all 15 implementation pipeline stages.

### Item C: Fix plan-fidelity evaluator

**SCs:** SC-4
**Files:** `.opencode/skills/audit/tasks/plan-fidelity-evaluator.md`

Add pipeline completeness check — FAILs if mandatory pipeline steps are missing.

## Pipeline Steps

### Step 1: assemble-work

**Dispatch:** `(**orchestrator**)`
**Chain:** entry criteria

- [ ] 1.1 `(**inline**)` Read plan from `.opencode/.issues/2009/plan-01.md`
- [ ] 1.2 `(**inline**)` Verify every step has explicit dispatch indicator
- [ ] 1.3 `(**inline**)` Create work state at `./tmp/2009/work.md` with 3 items (A-C)
- [ ] 1.4 `(**inline**)` Set `pipeline_phase = pipeline-executor`

### Step 2: sc-coherence-gate

**Dispatch:** `(**sub-agent**)`
**Chain:** step 1

- [ ] 2.1 `(**sub-agent**)` Dispatch `audit --task coherence-extraction` for issue #2009
- [ ] 2.2 `(**inline**)` On PASS: proceed. On FAIL: remediate and re-run.

### Step 3: pre-red-baseline

**Dispatch:** `(**sub-agent**)`
**Chain:** step 2

- [ ] 3.1 `(**sub-agent**)` Dispatch `implementation-pipeline --task pre-red-baseline` for issue #2009
- [ ] 3.2 `(**inline**)` Initialize solve state at `./tmp/2009/state/`

### Step 4: RED phase — Item A (critical rule + behavioral test)

**Dispatch:** `(**sub-agent**)`
**Chain:** step 3

- [ ] 4.1 `(**sub-agent**)` Dispatch `test-driven-development --task red` — write behavioral test `spec-creation-pipeline-routing.sh` that sends a "create spec" prompt and asserts the agent dispatches spec-creation pipeline (not direct `github_issue_write`). Test MUST FAIL because no Tier 1 rule exists yet.
- [ ] 4.2 `(**inline**)` Z3 check: `solve check` — verify RED test fails
- [ ] 4.3 `(**sub-agent**)` Dispatch `verification-before-completion --task verify` — confirm RED test fails as expected

### Step 5: GREEN phase — Item A (critical rule + behavioral test)

**Dispatch:** `(**sub-agent**)`
**Chain:** step 4

- [ ] 5.1 `(**sub-agent**)` Dispatch `test-driven-development --task green` — implement: upgrade critical-rules-XXX to Tier 1 in `000-critical-rules.md`. Ensure the rule states: direct `github_issue_write` for spec content is a CRITICAL VIOLATION — never overridable, never waivable.
- [ ] 5.2 `(**inline**)` Z3 check: `solve check` — verify GREEN test passes
- [ ] 5.3 `(**sub-agent**)` Dispatch `verification-before-completion --task verify` — confirm SC-1, SC-2 pass
- [ ] 5.4 `(**inline**)` Create checkpoint tag: `opencode-config/checkpoint/2009/phase-1-item-A-opencode-config`
- [ ] 5.5 `(**inline**)` Run structural checks: `uvx ruff check .opencode/guidelines/000-critical-rules.md` (advisory)

### Step 6: RED phase — Item B (plan template write.md)

**Dispatch:** `(**sub-agent**)`
**Chain:** step 5

- [ ] 6.1 `(**sub-agent**)` Dispatch `test-driven-development --task red` — write behavioral test verifying plan-fidelity audit FAILs on plan missing pipeline steps. Test MUST FAIL because write.md has no Pipeline Steps section yet.
- [ ] 6.2 `(**inline**)` Z3 check: `solve check` — verify RED test fails
- [ ] 6.3 `(**sub-agent**)` Dispatch `verification-before-completion --task verify` — confirm RED test fails

### Step 7: GREEN phase — Item B (plan template write.md)

**Dispatch:** `(**sub-agent**)`
**Chain:** step 6

- [ ] 7.1 `(**sub-agent**)` Dispatch `test-driven-development --task green` — implement: add mandatory Pipeline Steps section to `write.md` plan template with all 15 stages: assemble-work, sc-coherence-gate, pre-red-baseline, red-phase, z3-check-red, red-doublecheck, green-phase, z3-check-green, green-doublecheck, checkpoint-tag-create, checkpoint-commit, green-vbc, sc-count-gate, pre-pr-gate, audit, cross-validate, regression-check, review-prep, create-pr, exec-summary
- [ ] 7.2 `(**inline**)` Z3 check: `solve check` — verify GREEN test passes
- [ ] 7.3 `(**sub-agent**)` Dispatch `verification-before-completion --task verify` — confirm SC-3 passes
- [ ] 7.4 `(**inline**)` Create checkpoint tag: `opencode-config/checkpoint/2009/phase-1-item-B-opencode-config`

### Step 8: RED phase — Item C (plan-fidelity evaluator)

**Dispatch:** `(**sub-agent**)`
**Chain:** step 7

- [ ] 8.1 `(**sub-agent**)` Dispatch `test-driven-development --task red` — write behavioral test verifying plan-fidelity audit checks for pipeline completeness. Test MUST FAIL because evaluator has no pipeline check yet.
- [ ] 8.2 `(**inline**)` Z3 check: `solve check` — verify RED test fails
- [ ] 8.3 `(**sub-agent**)` Dispatch `verification-before-completion --task verify` — confirm RED test fails

### Step 9: GREEN phase — Item C (plan-fidelity evaluator)

**Dispatch:** `(**sub-agent**)`
**Chain:** step 8

- [ ] 9.1 `(**sub-agent**)` Dispatch `test-driven-development --task green` — implement: add pipeline completeness check to `plan-fidelity-evaluator.md`. Check that all 15 mandatory pipeline stages are present in the plan. FAIL if any are missing.
- [ ] 9.2 `(**inline**)` Z3 check: `solve check` — verify GREEN test passes
- [ ] 9.3 `(**sub-agent**)` Dispatch `verification-before-completion --task verify` — confirm SC-4 passes
- [ ] 9.4 `(**inline**)` Create checkpoint tag: `opencode-config/checkpoint/2009/phase-1-item-C-opencode-config`

### Step 10: green-vbc (Verification Before Completion)

**Dispatch:** `(**sub-agent**)`
**Chain:** step 9

- [ ] 10.1 `(**sub-agent**)` Dispatch `verification-before-completion --task completion` for issue #2009
- [ ] 10.2 `(**inline**)` Verify all 5 SCs have PASS verdicts

### Step 11: sc-count-gate

**Dispatch:** `(**sub-agent**)`
**Chain:** step 10

- [ ] 11.1 `(**sub-agent**)` Dispatch `implementation-pipeline --task sc-count-gate` — verify all 5 SCs have verdicts
- [ ] 11.2 `(**inline**)` On BLOCKED: remediate missing SC verdicts

### Step 12: pre-pr-gate

**Dispatch:** `(**sub-agent**)`
**Chain:** step 11

- [ ] 12.1 `(**sub-agent**)` Dispatch `verification-before-completion --task verify` — read all SC verdicts, BLOCK on any FAIL
- [ ] 12.2 `(**inline**)` On BLOCKED: remediate and re-run

### Step 13: audit

**Dispatch:** `(**orchestrator**)`
**Chain:** step 12

- [ ] 13.1 `(**sub-agent**)` Dispatch `audit --task verification-audit` for issue #2009
- [ ] 13.2 `(**inline**)` On non-clean-pass (FAIL or DONE_WITH_CONCERNS): remediate root cause, restart from step 13.1
- [ ] 13.3 `(**sub-agent**)` On clean PASS: dispatch `audit --task cross-validate` for consensus

### Step 14: regression-check

**Dispatch:** `(**sub-agent**)`
**Chain:** step 13

- [ ] 14.1 `(**sub-agent**)` Dispatch `test-driven-development --task patterns` — run regression tests
- [ ] 14.2 `(**inline**)` On FAIL: remediate and re-run

### Step 15: review-prep

**Dispatch:** `(**sub-agent**)`
**Chain:** step 14

- [ ] 15.1 `(**sub-agent**)` Dispatch `git-workflow --task review-prep` for issue #2009

### Step 16: create-pr

**Dispatch:** `(**sub-agent**)`
**Chain:** step 15

- [ ] 16.1 `(**sub-agent**)` Dispatch `pr-creation-workflow --task create` for issue #2009

### Step 17: exec-summary

**Dispatch:** `(**sub-agent**)`
**Chain:** step 16

- [ ] 17.1 `(**sub-agent**)` Dispatch `completion-core --task completion` for issue #2009
- [ ] 17.2 `(**inline**)` Report final status with PR URL

## RED/GREEN Chains

| Item | RED | GREEN |
|------|-----|-------|
| A | No Tier 1 rule for spec-creation bypass; no behavioral test | Tier 1 rule in 000-critical-rules.md; behavioral test passes |
| B | write.md has no Pipeline Steps section | write.md has mandatory Pipeline Steps with all 15 stages |
| C | plan-fidelity evaluator has no pipeline check | plan-fidelity evaluator FAILs on missing pipeline steps |

## Z3 Checks

| Step | Check | Contract |
|------|-------|----------|
| 4.2 | RED test fails | `writing-plans-creation/contracts/tdt-format.yaml` |
| 5.2 | GREEN test passes | `writing-plans-creation/contracts/create-output-template.yaml` |
| 6.2 | RED test fails | `writing-plans-creation/contracts/contract-path-format.yaml` |
| 7.2 | GREEN test passes | `writing-plans-creation/contracts/create-output-template.yaml` |
| 8.2 | RED test fails | `writing-plans-creation/contracts/contract-path-format.yaml` |
| 9.2 | GREEN test passes | `writing-plans-creation/contracts/create-output-template.yaml` |

## VbC Blocks

| SC | Verification | Evidence |
|----|-------------|----------|
| SC-1 | `read` 000-critical-rules.md → find Tier 1 rule for spec-creation bypass | File content |
| SC-2 | `opencode run` → behavioral test PASSes | stderr log |
| SC-3 | `read` write.md → Pipeline Steps section with all 15 stages | File content |
| SC-4 | `opencode run` → plan-fidelity FAILs on missing pipeline steps | stderr log |
| SC-5 | `grep` #1962 spec → SC-1 through SC-8 all present | grep output |

## Phase Completion

- [ ] All 5 SCs verified PASS
- [ ] Audit clean PASS
- [ ] Cross-validate consensus PASS
- [ ] Regression tests PASS
- [ ] Review prep complete
- [ ] PR created
- [ ] `local-issues sync` run
- [ ] Changes committed to feature branch
