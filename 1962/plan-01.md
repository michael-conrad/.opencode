# Phase 1: Fix skill metadata and task files

**Issue:** #1962
**Spec:** `.opencode/.issues/1962/spec.md`
**Plan index:** `.opencode/.issues/1962/plan.md`
**Status:** DRAFT
**Created:** 2026-07-19

## Concern

Dispatch routing, contract paths, and skill card structure for `writing-plans` and `writing-plans-creation`.

## Entry Criteria

- [ ] Spec #1962 is approved (`approved-for-plan` label present)
- [ ] Feature branch exists (current: `feature/1962-writing-plans-workflow-fix`)
- [ ] All 7 analytical artifacts exist at `.opencode/.issues/1962/artifacts/`
- [ ] `local-issues sync` run before any file changes

## Implementation Items

### Item A: Update `writing-plans/SKILL.md`

**SCs:** SC-1, SC-2, SC-7, SC-8
**Files:** `.opencode/skills/writing-plans/SKILL.md`

Replace TDT with exactly 4 entries. Add Pipeline section with 4 workflows and step-level dispatch classification. Update Invocation with 4 canonical dispatch strings. Document `clean-room` as internal/referenced task.

### Item B: Convert `writing-plans-creation/SKILL.md` to task card

**SCs:** SC-3
**Files:** `.opencode/skills/writing-plans-creation/SKILL.md`

Remove YAML frontmatter, remove "Skill:" header, remove Contracts section. Keep plain task list only.

### Item C: Fix contract paths in `create.md`

**SCs:** SC-4, SC-5
**Files:** `.opencode/skills/writing-plans-creation/tasks/create.md`

Replace 11 references to `writing-plans/contracts/` with `writing-plans-creation/contracts/`. Add plan-creation-pipeline dispatch step. Update chain refs.

### Item D: Fix contract paths in `update.md`

**SCs:** SC-4
**Files:** `.opencode/skills/writing-plans-creation/tasks/update.md`

Replace references to `writing-plans/contracts/` with `writing-plans-creation/contracts/`.

### Item E: Fix contract paths in `retroactive.md`

**SCs:** SC-4
**Files:** `.opencode/skills/writing-plans-creation/tasks/retroactive.md`

Replace references to `writing-plans/contracts/` with `writing-plans-creation/contracts/`.

### Item F: Verify `pre-plan-readiness.md` has solve readiness gate

**SCs:** SC-6
**Files:** `.opencode/skills/writing-plans-creation/tasks/pre-plan-readiness.md`

Confirm solve readiness gate is present (already done per commit eda50974). Add if missing.

## Pipeline Steps

### Step 1: assemble-work

**Dispatch:** `(**orchestrator**)`
**Chain:** entry criteria

- [ ] 1.1 `(**inline**)` Read plan from `.opencode/.issues/1962/plan-01.md`
- [ ] 1.2 `(**inline**)` Verify every step has explicit dispatch indicator
- [ ] 1.3 `(**inline**)` Create work state at `./tmp/1962/work.md` with 6 items (A-F)
- [ ] 1.4 `(**inline**)` Set `pipeline_phase = pipeline-executor`

### Step 2: sc-coherence-gate

**Dispatch:** `(**sub-agent**)`
**Chain:** step 1

- [ ] 2.1 `(**sub-agent**)` Dispatch `audit --task coherence-extraction` for issue #1962
- [ ] 2.2 `(**inline**)` On PASS: proceed. On FAIL: remediate and re-run.

### Step 3: pre-red-baseline

**Dispatch:** `(**sub-agent**)`
**Chain:** step 2

- [ ] 3.1 `(**sub-agent**)` Dispatch `implementation-pipeline --task pre-red-baseline` for issue #1962
- [ ] 3.2 `(**inline**)` Initialize solve state at `./tmp/1962/state/`

### Step 4: RED phase — Item A (writing-plans/SKILL.md)

**Dispatch:** `(**sub-agent**)`
**Chain:** step 3

- [ ] 4.1 `(**sub-agent**)` Dispatch `test-driven-development --task red` — write behavioral test verifying current TDT is wrong (not 4 entries, no Pipeline section)
- [ ] 4.2 `(**inline**)` Z3 check: `solve check` — verify RED test fails
- [ ] 4.3 `(**sub-agent**)` Dispatch `verification-before-completion --task verify` — confirm RED test fails as expected

### Step 5: GREEN phase — Item A (writing-plans/SKILL.md)

**Dispatch:** `(**sub-agent**)`
**Chain:** step 4

- [ ] 5.1 `(**sub-agent**)` Dispatch `test-driven-development --task green` — implement: replace TDT with 4 entries, add Pipeline section with 4 workflows, update Invocation with 4 canonical strings, document clean-room as internal
- [ ] 5.2 `(**inline**)` Z3 check: `solve check` — verify GREEN test passes
- [ ] 5.3 `(**sub-agent**)` Dispatch `verification-before-completion --task verify` — confirm all SCs for Item A pass
- [ ] 5.4 `(**inline**)` Create checkpoint tag: `opencode-config/checkpoint/1962/phase-1-item-A-opencode-config`
- [ ] 5.5 `(**inline**)` Run structural checks: `uvx ruff check .opencode/skills/writing-plans/SKILL.md` (advisory)

### Step 6: RED phase — Item B (writing-plans-creation/SKILL.md)

**Dispatch:** `(**sub-agent**)`
**Chain:** step 5

- [ ] 6.1 `(**sub-agent**)` Dispatch `test-driven-development --task red` — write behavioral test verifying current SKILL.md has YAML frontmatter and "Skill:" header
- [ ] 6.2 `(**inline**)` Z3 check: `solve check` — verify RED test fails
- [ ] 6.3 `(**sub-agent**)` Dispatch `verification-before-completion --task verify` — confirm RED test fails

### Step 7: GREEN phase — Item B (writing-plans-creation/SKILL.md)

**Dispatch:** `(**sub-agent**)`
**Chain:** step 6

- [ ] 7.1 `(**sub-agent**)` Dispatch `test-driven-development --task green` — implement: remove YAML frontmatter, remove "Skill:" header, remove Contracts section, keep plain task list
- [ ] 7.2 `(**inline**)` Z3 check: `solve check` — verify GREEN test passes
- [ ] 7.3 `(**sub-agent**)` Dispatch `verification-before-completion --task verify` — confirm SC-3 passes
- [ ] 7.4 `(**inline**)` Create checkpoint tag: `opencode-config/checkpoint/1962/phase-1-item-B-opencode-config`

### Step 8: RED phase — Item C (create.md contract paths)

**Dispatch:** `(**sub-agent**)`
**Chain:** step 7

- [ ] 8.1 `(**sub-agent**)` Dispatch `test-driven-development --task red` — write test verifying `create.md` still references `writing-plans/contracts/`
- [ ] 8.2 `(**inline**)` Z3 check: `solve check` — verify RED test fails
- [ ] 8.3 `(**sub-agent**)` Dispatch `verification-before-completion --task verify` — confirm RED test fails

### Step 9: GREEN phase — Item C (create.md contract paths + plan-creation-pipeline)

**Dispatch:** `(**sub-agent**)`
**Chain:** step 8

- [ ] 9.1 `(**sub-agent**)` Dispatch `test-driven-development --task green` — implement: replace 11 contract paths, add plan-creation-pipeline dispatch step, update chain refs
- [ ] 9.2 `(**inline**)` Z3 check: `solve check` — verify GREEN test passes
- [ ] 9.3 `(**sub-agent**)` Dispatch `verification-before-completion --task verify` — confirm SC-4, SC-5 pass
- [ ] 9.4 `(**inline**)` Create checkpoint tag: `opencode-config/checkpoint/1962/phase-1-item-C-opencode-config`

### Step 10: RED phase — Item D (update.md contract paths)

**Dispatch:** `(**sub-agent**)`
**Chain:** step 9

- [ ] 10.1 `(**sub-agent**)` Dispatch `test-driven-development --task red` — write test verifying `update.md` still references `writing-plans/contracts/`
- [ ] 10.2 `(**inline**)` Z3 check: `solve check` — verify RED test fails
- [ ] 10.3 `(**sub-agent**)` Dispatch `verification-before-completion --task verify` — confirm RED test fails

### Step 11: GREEN phase — Item D (update.md contract paths)

**Dispatch:** `(**sub-agent**)`
**Chain:** step 10

- [ ] 11.1 `(**sub-agent**)` Dispatch `test-driven-development --task green` — implement: replace contract paths
- [ ] 11.2 `(**inline**)` Z3 check: `solve check` — verify GREEN test passes
- [ ] 11.3 `(**sub-agent**)` Dispatch `verification-before-completion --task verify` — confirm SC-4 for update.md passes
- [ ] 11.4 `(**inline**)` Create checkpoint tag: `opencode-config/checkpoint/1962/phase-1-item-D-opencode-config`

### Step 12: RED phase — Item E (retroactive.md contract paths)

**Dispatch:** `(**sub-agent**)`
**Chain:** step 11

- [ ] 12.1 `(**sub-agent**)` Dispatch `test-driven-development --task red` — write test verifying `retroactive.md` still references `writing-plans/contracts/`
- [ ] 12.2 `(**inline**)` Z3 check: `solve check` — verify RED test fails
- [ ] 12.3 `(**sub-agent**)` Dispatch `verification-before-completion --task verify` — confirm RED test fails

### Step 13: GREEN phase — Item E (retroactive.md contract paths)

**Dispatch:** `(**sub-agent**)`
**Chain:** step 12

- [ ] 13.1 `(**sub-agent**)` Dispatch `test-driven-development --task green` — implement: replace contract paths
- [ ] 13.2 `(**inline**)` Z3 check: `solve check` — verify GREEN test passes
- [ ] 13.3 `(**sub-agent**)` Dispatch `verification-before-completion --task verify` — confirm SC-4 for retroactive.md passes
- [ ] 13.4 `(**inline**)` Create checkpoint tag: `opencode-config/checkpoint/1962/phase-1-item-E-opencode-config`

### Step 14: Verify Item F (pre-plan-readiness.md solve gate)

**Dispatch:** `(**inline**)`
**Chain:** step 13

- [ ] 14.1 `(**inline**)` Read `writing-plans-creation/tasks/pre-plan-readiness.md`
- [ ] 14.2 `(**inline**)` Confirm solve readiness gate is present (already done per commit eda50974)
- [ ] 14.3 `(**inline**)` If missing, dispatch GREEN sub-agent to add it
- [ ] 14.4 `(**inline**)` Verify SC-6 passes

### Step 15: green-vbc (Verification Before Completion)

**Dispatch:** `(**sub-agent**)`
**Chain:** step 14

- [ ] 15.1 `(**sub-agent**)` Dispatch `verification-before-completion --task completion` for issue #1962
- [ ] 15.2 `(**inline**)` Verify all 8 SCs have PASS verdicts

### Step 16: sc-count-gate

**Dispatch:** `(**sub-agent**)`
**Chain:** step 15

- [ ] 16.1 `(**sub-agent**)` Dispatch `implementation-pipeline --task sc-count-gate` — verify all 8 SCs have verdicts
- [ ] 16.2 `(**inline**)` On BLOCKED: remediate missing SC verdicts

### Step 17: pre-pr-gate

**Dispatch:** `(**sub-agent**)`
**Chain:** step 16

- [ ] 17.1 `(**sub-agent**)` Dispatch `verification-before-completion --task verify` — read all SC verdicts, BLOCK on any FAIL
- [ ] 17.2 `(**inline**)` On BLOCKED: remediate and re-run

### Step 18: audit

**Dispatch:** `(**orchestrator**)`
**Chain:** step 17

- [ ] 18.1 `(**sub-agent**)` Dispatch `audit --task verification-audit` for issue #1962
- [ ] 18.2 `(**inline**)` On non-clean-pass (FAIL or DONE_WITH_CONCERNS): remediate root cause, restart from step 18.1
- [ ] 18.3 `(**sub-agent**)` On clean PASS: dispatch `audit --task cross-validate` for consensus

### Step 19: regression-check

**Dispatch:** `(**sub-agent**)`
**Chain:** step 18

- [ ] 19.1 `(**sub-agent**)` Dispatch `test-driven-development --task patterns` — run regression tests
- [ ] 19.2 `(**inline**)` On FAIL: remediate and re-run

### Step 20: review-prep

**Dispatch:** `(**sub-agent**)`
**Chain:** step 19

- [ ] 20.1 `(**sub-agent**)` Dispatch `git-workflow --task review-prep` for issue #1962

### Step 21: create-pr

**Dispatch:** `(**sub-agent**)`
**Chain:** step 20

- [ ] 21.1 `(**sub-agent**)` Dispatch `pr-creation-workflow --task create` for issue #1962

### Step 22: exec-summary

**Dispatch:** `(**sub-agent**)`
**Chain:** step 21

- [ ] 22.1 `(**sub-agent**)` Dispatch `completion-core --task completion` for issue #1962
- [ ] 22.2 `(**inline**)` Report final status with PR URL

## RED/GREEN Chains

| Item | RED | GREEN |
|------|-----|-------|
| A | Current TDT has wrong entries | TDT has exactly 4 entries, Pipeline section present |
| B | SKILL.md has YAML frontmatter + "Skill:" header | Plain task list, no YAML, no "Skill:" |
| C | `create.md` references `writing-plans/contracts/` | All paths point to `writing-plans-creation/contracts/` |
| D | `update.md` references `writing-plans/contracts/` | All paths point to `writing-plans-creation/contracts/` |
| E | `retroactive.md` references `writing-plans/contracts/` | All paths point to `writing-plans-creation/contracts/` |

## Z3 Checks

| Step | Check | Contract |
|------|-------|----------|
| 4.2 | RED test fails | `writing-plans-creation/contracts/tdt-format.yaml` |
| 5.2 | GREEN test passes | `writing-plans-creation/contracts/create-output-template.yaml` |
| 8.2 | RED test fails | `writing-plans-creation/contracts/contract-path-format.yaml` |
| 9.2 | GREEN test passes | `writing-plans-creation/contracts/create-output-template.yaml` |

## VbC Blocks

| SC | Verification | Evidence |
|----|-------------|----------|
| SC-1 | `read` SKILL.md → count TDT rows = 4 | File content |
| SC-2 | `read` SKILL.md → Pipeline section with 4 workflows | File content |
| SC-3 | `read` SKILL.md → no YAML frontmatter, no "Skill:" header | File content |
| SC-4 | `grep` for `writing-plans/contracts/` → zero matches in 3 files | grep output |
| SC-5 | `opencode run` → verify skill dispatch in stderr | stderr log |
| SC-6 | `read` pre-plan-readiness.md → find solve check | File content |
| SC-7 | `read` Invocation sections → verify DISPATCH_GATE format | File content |
| SC-8 | `ls tasks/` vs Pipeline refs → diff empty | Directory listing |

## Phase Completion

- [ ] All 8 SCs verified PASS
- [ ] Audit clean PASS
- [ ] Cross-validate consensus PASS
- [ ] Regression tests PASS
- [ ] Review prep complete
- [ ] PR created
- [ ] `local-issues sync` run
- [ ] Changes committed to feature branch
