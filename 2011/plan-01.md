# Phase 1: BEH-EV classification gate, clean-room evaluator, fix 8 evaluators, fix cross-validate

**Issue:** #2011
**Spec:** `.opencode/.issues/2011/spec.md`
**Plan index:** `.opencode/.issues/2011/plan.md`
**Status:** DRAFT
**Created:** 2026-07-19

## Concern

Behavioral SC evidence pipeline: classification at spec-writing, clean-room evaluation at audit.

## Entry Criteria

- [ ] Spec #2011 is approved (`approved-for-plan` label present)
- [ ] Feature branch exists (current: `feature/1962-writing-plans-workflow-fix`)
- [ ] `local-issues sync` run before any file changes

## Implementation Items

### Item A: BEH-EV classification step in spec-creation/write.md

**SCs:** SC-1
**Files:** `.opencode/skills/spec-creation/tasks/write.md`

Add mandatory "Evidence Type Classification Gate" step between SC definition and spec finalization. Include presumptive runtime-behavioral file types: SKILL.md, tasks/*.md, guidelines/*.md, enforcement/*.md.

### Item B: Clean-room evaluation task + fix all 8 evaluators

**SCs:** SC-2, SC-3
**Files:** `.opencode/skills/audit/tasks/behavioral-sc-evaluator.md` (new), all 8 `*-evaluator.md` files

Create `behavioral-sc-evaluator.md` — receives ONLY artifact directory path, reads stdout.log/stderr.log, renders binary PASS/FAIL. File-existence alone returns FAIL. Then add dispatch step to each of the 8 evaluator tasks.

### Item C: EVIDENCE_TYPE_MISMATCH detection in cross-validate

**SCs:** SC-4
**Files:** `.opencode/skills/audit/tasks/cross-validate.md`

Add detection: if behavioral SC verdict cites only file paths (no content analysis), downgrade to FAIL.

## Pipeline Steps

### Step 1: assemble-work

**Dispatch:** `(**orchestrator**)`
**Chain:** entry criteria

- [ ] 1.1 `(**inline**)` Read plan from `.opencode/.issues/2011/plan-01.md`
- [ ] 1.2 `(**inline**)` Verify every step has explicit dispatch indicator
- [ ] 1.3 `(**inline**)` Create work state at `./tmp/2011/work.md` with 3 items (A-C)
- [ ] 1.4 `(**inline**)` Set `pipeline_phase = pipeline-executor`

### Step 2: sc-coherence-gate

**Dispatch:** `(**sub-agent**)`
**Chain:** step 1

- [ ] 2.1 `(**sub-agent**)` Dispatch `audit --task coherence-extraction` for issue #2011
- [ ] 2.2 `(**inline**)` On PASS: proceed. On FAIL: remediate and re-run.

### Step 3: pre-red-baseline

**Dispatch:** `(**sub-agent**)`
**Chain:** step 2

- [ ] 3.1 `(**sub-agent**)` Dispatch `implementation-pipeline --task pre-red-baseline` for issue #2011
- [ ] 3.2 `(**inline**)` Initialize solve state at `./tmp/2011/state/`

### Step 4: RED phase — Item A (BEH-EV classification step)

**Dispatch:** `(**sub-agent**)`
**Chain:** step 3

- [ ] 4.1 `(**sub-agent**)` Dispatch `test-driven-development --task red` — write behavioral test verifying spec-creation agent includes BEH-EV classification step when writing specs. Test MUST FAIL because write.md has no classification step yet.
- [ ] 4.2 `(**inline**)` Z3 check: `solve check` — verify RED test fails
- [ ] 4.3 `(**sub-agent**)` Dispatch `verification-before-completion --task verify` — confirm RED test fails

### Step 5: GREEN phase — Item A (BEH-EV classification step)

**Dispatch:** `(**sub-agent**)`
**Chain:** step 4

- [ ] 5.1 `(**sub-agent**)` Dispatch `test-driven-development --task green` — implement: add "Evidence Type Classification Gate" step to `spec-creation/tasks/write.md` between SC definition and spec finalization. Include presumptive runtime-behavioral file types.
- [ ] 5.2 `(**inline**)` Z3 check: `solve check` — verify GREEN test passes
- [ ] 5.3 `(**sub-agent**)` Dispatch `verification-before-completion --task verify` — confirm SC-1 passes
- [ ] 5.4 `(**inline**)` Create checkpoint tag: `opencode-config/checkpoint/2011/phase-1-item-A-opencode-config`

### Step 6: GREEN phase — Item B (clean-room evaluator task)

**Dispatch:** `(**sub-agent**)`
**Chain:** step 5

- [ ] 6.1 `(**sub-agent**)` Dispatch `test-driven-development --task green` — create `audit/tasks/behavioral-sc-evaluator.md`. Task receives ONLY artifact directory path. Reads stdout.log/stderr.log. Renders binary PASS/FAIL per SC. File-existence alone returns FAIL. No orchestrator context, no expected outcomes, no cached results.
- [ ] 6.2 `(**inline**)` Z3 check: `solve check` — verify task file exists and has correct structure
- [ ] 6.3 `(**sub-agent**)` Dispatch `verification-before-completion --task verify` — confirm SC-3 passes
- [ ] 6.4 `(**inline**)` Create checkpoint tag: `opencode-config/checkpoint/2011/phase-1-item-B1-opencode-config`

### Step 7: GREEN phase — Item B (fix verification-audit evaluator)

**Dispatch:** `(**sub-agent**)`
**Chain:** step 6

- [ ] 7.1 `(**sub-agent**)` Dispatch `test-driven-development --task green` — add clean-room sub-agent dispatch step to `verification-audit-evaluator.md`. For each behavioral SC, dispatch `behavioral-sc-evaluator` with artifact dir only. If clean-room returns FAIL, evaluator verdict is FAIL.
- [ ] 7.2 `(**inline**)` Z3 check: `solve check` — verify change
- [ ] 7.3 `(**sub-agent**)` Dispatch `verification-before-completion --task verify` — confirm

### Step 8: GREEN phase — Item B (fix spec-audit evaluator)

**Dispatch:** `(**sub-agent**)`
**Chain:** step 7

- [ ] 8.1 `(**sub-agent**)` Dispatch `test-driven-development --task green` — add clean-room sub-agent dispatch step to `spec-audit-evaluator.md`
- [ ] 8.2 `(**inline**)` Z3 check
- [ ] 8.3 `(**sub-agent**)` Dispatch `verification-before-completion --task verify`

### Step 9: GREEN phase — Item B (fix plan-fidelity evaluator)

**Dispatch:** `(**sub-agent**)`
**Chain:** step 8

- [ ] 9.1 `(**sub-agent**)` Dispatch `test-driven-development --task green` — add clean-room sub-agent dispatch step to `plan-fidelity-evaluator.md`
- [ ] 9.2 `(**inline**)` Z3 check
- [ ] 9.3 `(**sub-agent**)` Dispatch `verification-before-completion --task verify`

### Step 10: GREEN phase — Item B (fix concern-separation evaluator)

**Dispatch:** `(**sub-agent**)`
**Chain:** step 9

- [ ] 10.1 `(**sub-agent**)` Dispatch `test-driven-development --task green` — add clean-room sub-agent dispatch step to `concern-separation-evaluator.md`
- [ ] 10.2 `(**inline**)` Z3 check
- [ ] 10.3 `(**sub-agent**)` Dispatch `verification-before-completion --task verify`

### Step 11: GREEN phase — Item B (fix coherence-maintenance evaluator)

**Dispatch:** `(**sub-agent**)`
**Chain:** step 10

- [ ] 11.1 `(**sub-agent**)` Dispatch `test-driven-development --task green` — add clean-room sub-agent dispatch step to `coherence-maintenance-evaluator.md`
- [ ] 11.2 `(**inline**)` Z3 check
- [ ] 11.3 `(**sub-agent**)` Dispatch `verification-before-completion --task verify`

### Step 12: GREEN phase — Item B (fix drift-detection evaluator)

**Dispatch:** `(**sub-agent**)`
**Chain:** step 11

- [ ] 12.1 `(**sub-agent**)` Dispatch `test-driven-development --task green` — add clean-room sub-agent dispatch step to `drift-detection-evaluator.md`
- [ ] 12.2 `(**inline**)` Z3 check
- [ ] 12.3 `(**sub-agent**)` Dispatch `verification-before-completion --task verify`

### Step 13: GREEN phase — Item B (fix test-quality-audit and content-audit evaluators)

**Dispatch:** `(**sub-agent**)`
**Chain:** step 12

- [ ] 13.1 `(**sub-agent**)` Dispatch `test-driven-development --task green` — add clean-room sub-agent dispatch step to `test-quality-audit-evaluator.md` and `content-audit-evaluator.md`
- [ ] 13.2 `(**inline**)` Z3 check
- [ ] 13.3 `(**sub-agent**)` Dispatch `verification-before-completion --task verify`

### Step 14: RED phase — Item C (cross-validate EVIDENCE_TYPE_MISMATCH)

**Dispatch:** `(**sub-agent**)`
**Chain:** step 13

- [ ] 14.1 `(**sub-agent**)` Dispatch `test-driven-development --task red` — write behavioral test verifying cross-validate FAILs when behavioral SC verdict cites only file paths. Test MUST FAIL because cross-validate has no EVIDENCE_TYPE_MISMATCH check yet.
- [ ] 14.2 `(**inline**)` Z3 check
- [ ] 14.3 `(**sub-agent**)` Dispatch `verification-before-completion --task verify`

### Step 15: GREEN phase — Item C (cross-validate EVIDENCE_TYPE_MISMATCH)

**Dispatch:** `(**sub-agent**)`
**Chain:** step 14

- [ ] 15.1 `(**sub-agent**)` Dispatch `test-driven-development --task green` — add EVIDENCE_TYPE_MISMATCH detection to `cross-validate.md`. If behavioral SC verdict cites only file paths (no content analysis), downgrade to FAIL.
- [ ] 15.2 `(**inline**)` Z3 check
- [ ] 15.3 `(**sub-agent**)` Dispatch `verification-before-completion --task verify` — confirm SC-4 passes
- [ ] 15.4 `(**inline**)` Create checkpoint tag: `opencode-config/checkpoint/2011/phase-1-item-C-opencode-config`

### Step 16: green-vbc

**Dispatch:** `(**sub-agent**)`
**Chain:** step 15

- [ ] 16.1 `(**sub-agent**)` Dispatch `verification-before-completion --task completion` for issue #2011
- [ ] 16.2 `(**inline**)` Verify all 5 SCs have PASS verdicts

### Step 17: sc-count-gate

**Dispatch:** `(**sub-agent**)`
**Chain:** step 16

- [ ] 17.1 `(**sub-agent**)` Dispatch `implementation-pipeline --task sc-count-gate`
- [ ] 17.2 `(**inline**)` On BLOCKED: remediate

### Step 18: pre-pr-gate

**Dispatch:** `(**sub-agent**)`
**Chain:** step 17

- [ ] 18.1 `(**sub-agent**)` Dispatch `verification-before-completion --task verify`
- [ ] 18.2 `(**inline**)` On BLOCKED: remediate

### Step 19: audit

**Dispatch:** `(**orchestrator**)`
**Chain:** step 18

- [ ] 19.1 `(**sub-agent**)` Dispatch `audit --task verification-audit` for issue #2011
- [ ] 19.2 `(**inline**)` On non-clean-pass: remediate, restart
- [ ] 19.3 `(**sub-agent**)` On clean PASS: dispatch `audit --task cross-validate`

### Step 20: regression-check

**Dispatch:** `(**sub-agent**)`
**Chain:** step 19

- [ ] 20.1 `(**sub-agent**)` Dispatch `test-driven-development --task patterns`
- [ ] 20.2 `(**inline**)` On FAIL: remediate

### Step 21: review-prep + create-pr + exec-summary

**Dispatch:** `(**sub-agent**)`
**Chain:** step 20

- [ ] 21.1 `(**sub-agent**)` Dispatch `git-workflow --task review-prep`
- [ ] 21.2 `(**sub-agent**)` Dispatch `pr-creation-workflow --task create`
- [ ] 21.3 `(**sub-agent**)` Dispatch `completion-core --task completion`
- [ ] 21.4 `(**inline**)` Report final status with PR URL

## RED/GREEN Chains

| Item | RED | GREEN |
|------|-----|-------|
| A | write.md has no BEH-EV classification step | write.md has "Evidence Type Classification Gate" step |
| B | No behavioral-sc-evaluator.md; evaluators accept file-existence | behavioral-sc-evaluator.md created; all 8 evaluators dispatch clean-room |
| C | cross-validate has no EVIDENCE_TYPE_MISMATCH check | cross-validate FAILs on file-path-only behavioral verdicts |

## VbC Blocks

| SC | Verification | Evidence |
|----|-------------|----------|
| SC-1 | `read` write.md → "Evidence Type Classification Gate" section | File content |
| SC-2 | `opencode run` → clean-room dispatch in stderr for each evaluator | stderr log |
| SC-3 | `opencode run` → clean-room sub-agent returns binary verdict | stderr log |
| SC-4 | `opencode run` → cross-validate FAILs on file-path-only verdict | stderr log |
| SC-5 | `grep` #2009 spec → SC-1 through SC-5 all present | grep output |

## Phase Completion

- [ ] All 5 SCs verified PASS
- [ ] Audit clean PASS
- [ ] Cross-validate consensus PASS
- [ ] Regression tests PASS
- [ ] Review prep complete
- [ ] PR created
- [ ] `local-issues sync` run
- [ ] Changes committed to feature branch
