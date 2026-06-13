# Implementation Checklist — #1062 Handoff Gates

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

**Issue:** [#1062](https://github.com/michael-conrad/.opencode/issues/1062)
**Phase:** 1 (Handoff Gate Task Creation)
**Items:** A (spec-to-plan.md), B (pre-flight-handoff.md), C (sc-closeout.md), D (create.md entry criteria), E (SKILL.md pre-flight)
**SCs:** 20 (SC-1 through SC-20)
**Authorization Scope:** `for_pr` — auto-approves plan, auto-creates PR
**Halt At:** `pr_created`

---

## Pre-Cleanup (Before Phase 1)

- [ ] Remove stale artifacts from `./tmp/1062/` if any exist from prior runs
- [ ] Verify `./tmp/1062/artifacts/` directory exists (create if not)
- [ ] Verify `.opencode/.issues/1062/spec-artifacts/` directory is intact
- [ ] Verify `sc-pipeline-readiness.yaml` status is PASS (confirmed: PASS)
- [ ] Verify `sc-summary.yaml` exists with 20 SCs (confirmed)
- [ ] Verify `dependency-ordering-verification/ordering.yaml` exists (confirmed: VALID)

---

## Phase 1 — Gate-by-Gate Checklist

### Gate 1: SC-COHERENCE-GATE

**Dispatch:** orchestrator routes to pre-analysis

- [ ] Task pre-analysis sub-agent: verify spec SCs are internally consistent and complete for Phase 1
- [ ] Receive result contract from pre-analysis
- [ ] If BLOCKED: HALT, report blocker
- [ ] Post-step: `solve state update --set P1_p1=True`
- [ ] Append lifecycle manifest event: `sc_coherence_gate_passed`

### Gate 2: PRE-RED-BASELINE

**Dispatch:** orchestrator routes to exploration

- [ ] Task exploration sub-agent: run full test suite, confirm all existing tests PASS
- [ ] Receive result contract
- [ ] If any test FAIL: HALT, report regression
- [ ] Post-step: `solve state update --set P1_p2=True`
- [ ] Append lifecycle manifest event: `pre_red_baseline_passed`

### Gate 3: RED-PHASE

**Dispatch:** orchestrator routes to RED sub-agent

- [ ] Task RED sub-agent: write enforcement test at permanent path → run → capture output to `./tmp/1062/artifacts/phase1-test-output.log`
- [ ] Expected: FAIL (exit non-zero)
- [ ] Receive result contract
- [ ] If PASS (exit 0): HALT — RED test passed when it should fail; test is defective
- [ ] Post-step: `solve state update --set P1_p3=True`
- [ ] Append lifecycle manifest event: `red_phase_completed`

### Gate 4: RED-DOUBLECHECK

**Dispatch:** orchestrator inline

- [ ] Confirm `./tmp/1062/artifacts/phase1-test-output.log` exists
- [ ] Confirm file shows non-zero exit code
- [ ] If missing or shows exit 0: HALT — RED evidence artifact is defective
- [ ] Post-step: `solve state update --set P1_p4=True`
- [ ] Append lifecycle manifest event: `red_doublecheck_passed`

### Gate 5: GREEN-PHASE

**Dispatch:** orchestrator routes to GREEN sub-agent (clean-room)

- [ ] Task GREEN sub-agent: receives spec + test path only (no preloaded context)
- [ ] GREEN sub-agent implements all 5 items (A through E):
  - Item A: Create `writing-plans/tasks/handoffs/spec-to-plan.md`
  - Item B: Create `implementation-pipeline/tasks/pre-flight-handoff.md`
  - Item C: Create `implementation-pipeline/tasks/sc-closeout.md`
  - Item D: Update `writing-plans/tasks/create.md` entry criteria
  - Item E: Update `implementation-pipeline/SKILL.md` pre-flight section
- [ ] Run test → capture output to `./tmp/1062/artifacts/phase1-test-output.log`
- [ ] Expected: PASS (exit 0)
- [ ] Receive result contract
- [ ] If FAIL: remediate and re-task (max 3 attempts)
- [ ] Post-step: `solve state update --set P1_p5=True`
- [ ] Append lifecycle manifest event: `green_phase_completed`

### Gate 6: CHECKPOINT-COMMIT

**Dispatch:** orchestrator inline

- [ ] `git add` all changed files (new task files + modified files)
- [ ] `git commit -m "phase 1 checkpoint"` with test + change
- [ ] Verify commit succeeded (`git log -1`)
- [ ] Create checkpoint tag: `opencode-config/checkpoint/1062/phase-1-opencode`
- [ ] Verify tag exists: `git tag -l 'opencode-config/checkpoint/1062/*'`
- [ ] Post-step: `solve state update --set P1_p6=True`
- [ ] Append lifecycle manifest event: `checkpoint_commit_completed`

### Gate 7: STRUCTURAL-CHECKS

**Dispatch:** orchestrator routes to structural sub-agent

- [ ] Task structural sub-agent: lint, format, typecheck on changed files
- [ ] Receive result contract
- [ ] If any check FAIL: remediate and re-task
- [ ] Post-step: `solve state update --set P1_p7=True`
- [ ] Append lifecycle manifest event: `structural_checks_passed`

### Gate 8: GREEN-DOUBLECHECK

**Dispatch:** orchestrator inline

- [ ] Confirm `./tmp/1062/artifacts/phase1-test-output.log` exists
- [ ] Confirm file shows exit 0
- [ ] If missing or shows non-zero exit: HALT — GREEN evidence artifact is defective
- [ ] Post-step: `solve state update --set P1_p8=True`
- [ ] Append lifecycle manifest event: `green_doublecheck_passed`

### Gate 9: GREEN-VBC

**Dispatch:** orchestrator routes to VbC sub-agent

- [ ] Task VbC sub-agent: verification-before-completion against Phase 1's SCs (SC-1 through SC-20)
- [ ] Receive result contract
- [ ] If any SC FAIL: remediate and re-task (max 3 attempts)
- [ ] Post-step: `solve state update --set P1_p9=True`
- [ ] Append lifecycle manifest event: `green_vbc_passed`

### Gate 10: ADVERSARIAL-AUDIT

**Dispatch:** orchestrator routes to resolve-models

- [ ] Task resolve-models: select 2 auditors from different families
- [ ] Task auditor 1: plan-fidelity audit
- [ ] Task auditor 2: concern-separation audit
- [ ] Receive both result contracts
- [ ] If either FAIL: remediate and re-audit (max 3 attempts)
- [ ] Post-step: `solve state update --set P1_p10=True`
- [ ] Append lifecycle manifest event: `adversarial_audit_passed`

### Gate 11: CROSS-VALIDATE

**Dispatch:** orchestrator inline

- [ ] Verify dual-auditor consensus on all Phase 1 SCs
- [ ] If DISAGREE: remediate and re-audit
- [ ] If consensus FAIL: HALT with blocker report
- [ ] Post-step: `solve state update --set P1_p11=True`
- [ ] Append lifecycle manifest event: `cross_validate_passed`

### Gate 12: REGRESSION-CHECK

**Dispatch:** orchestrator routes to regression sub-agent

- [ ] Task regression sub-agent: full test suite, confirm nothing previously passing is now broken
- [ ] Receive result contract
- [ ] If any regression: remediate and re-task (max 3 attempts)
- [ ] Post-step: `solve state update --set P1_p12=True`
- [ ] Append lifecycle manifest event: `regression_check_passed`

### Gate 13: REVIEW-PREP

**Dispatch:** orchestrator routes to review-prep sub-agent

- [ ] Task review-prep sub-agent: compare URL (verified from session-init), PR body draft for Phase 1
- [ ] Receive result contract
- [ ] Post-step: `solve state update --set P1_p13=True`
- [ ] Append lifecycle manifest event: `review_prep_passed`

### Gate 14: EXEC-SUMMARY

**Dispatch:** orchestrator inline

- [ ] Read all sub-agent result contracts
- [ ] Produce phase completion report with SC status, artifact paths, byline
- [ ] Post-step: `solve state update --set P1_p14=True`
- [ ] Append lifecycle manifest event: `exec_summary_passed`

---

## Inter-Phase Handoff

Single-phase plan — no inter-phase handoff required. After gate 14:

- [ ] Update Z3 state file: `solve state update` with Phase 1 gate states
- [ ] Run `solve check`: confirm Phase 1 dependency contract still SAT
- [ ] Verify checkpoint tag exists for Phase 1: `git tag -l 'opencode-config/checkpoint/1062/*'`
- [ ] Append lifecycle manifest event: `phase_1_completed`

---

## Remediation Routing

| ID | Condition | Action |
|----|-----------|--------|
| R.1 | RED test passes (exit 0) when it should fail | HALT — test is defective; rewrite RED test to assert the correct failure condition |
| R.2 | GREEN test fails (exit non-zero) | Re-task GREEN sub-agent with same spec + test path; max 3 attempts |
| R.3 | Structural checks fail | Re-task structural sub-agent with fix instructions; max 3 attempts |
| R.4 | VbC returns FAIL for any SC | Re-task VbC sub-agent; max 3 attempts |
| R.5 | Adversarial audit returns FAIL | Re-audit with new auditors; max 3 attempts |
| R.6 | Cross-validate shows DISAGREE | Re-audit with new auditors; max 3 attempts |
| R.7 | Regression check finds failures | HALT — regression introduced; diagnose and fix before proceeding |
| R.8 | Checkpoint tag creation fails | HALT — tag is required for rollback; fix tag creation |
| R.9 | `solve check` returns UNSAT | HALT — dependency contract violated; investigate state corruption |
| R.10 | Any sub-agent returns BLOCKED | Re-task clean-room sub-agent with same scoped context; max 3 attempts; if still BLOCKED, dispatch researcher sub-agent to investigate root cause |

**Max 3 remediation attempts per gate.** After 3 failures: HALT with full blocker report including all failure artifacts.

---

## Phase Completion

| ID | Check | Verification |
|----|-------|-------------|
| PC.1 | All 14 gates PASS | `solve check` confirms all P1_p1..P1_p14 = True |
| PC.2 | All 20 SCs verified PASS | VbC result contract shows PASS for SC-1 through SC-20 |
| PC.3 | Checkpoint tag exists | `git tag -l 'opencode-config/checkpoint/1062/phase-1-opencode'` returns tag |
| PC.4 | Lifecycle manifest complete | `lifecycle.yaml` contains all phase 1 events |
| PC.5 | Z3 state file updated | `solve state` shows P1_p1..P1_p14 = True |
| PC.6 | No uncommitted changes | `git status --porcelain` returns empty |

---

## Overall Completion

| ID | Check | Verification |
|----|-------|-------------|
| OC.1 | All phases complete | Phase 1 gates 1-14 all PASS |
| OC.2 | Full regression suite PASS | `solve state update` + full test suite run |
| OC.3 | Finishing checklist PASS | `finishing-a-development-branch --task checklist` |
| OC.4 | PR created | `github_create_pull_request` response `html_url` extracted |
| OC.5 | PR body includes Summary/Outcome/Fixes | Verified by review-prep sub-agent |
| OC.6 | Compare URL uses correct base branch | `compare/dev...<branch>` — verified from session-init |
| OC.7 | Byline present in all AI-authored content | `🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)` |

---

## Key Constraints

- **No inline fallback on sub-agent failure** — always re-task clean-room (per `000-critical-rules.md` §critical-rules-043)
- **No preloading sub-agent context** — sub-agents receive only spec + test path (per `000-critical-rules.md` §critical-rules-044)
- **No orchestrator inline work** — orchestrator routes via task(), never performs file modifications (per `000-critical-rules.md` §critical-rules-034)
- **Behavioral RED/GREEN for rule changes** — Items D and E modify existing files; use behavioral TDD (per `080-code-standards.md` §Behavioral RED/GREEN)
- **Evidence type compliance** — SC-1,2,19,20 are `structural` (read file); SC-3..18 are `string` (grep). No behavioral SCs in this spec (per spec SC table)
- **All-or-nothing gate** — ALL 20 SCs must PASS for implementation to be complete (per spec §Success Criteria)
- **`for_pr` scope** — auto-approves plan, auto-creates PR; halt at `pr_created` (per authorization context)
- **Stacked PR strategy** — one branch, one PR for all 5 items (per authorization context)
- **Submodule tagging** — tag `.opencode` submodule at pre-work: `opencode-config/checkpoint/1062/phase-1-opencode` (per `000-critical-rules.md` §critical-rules-051)
- **No `--recursive` with git submodule commands** (per `060-tool-usage.md` §4)

---

## SC Coverage Verification

| SC ID | Plan Item | Evidence Type | Covered by Checklist? |
|-------|-----------|---------------|----------------------|
| SC-1 | Item D | structural | ✅ Gate 9 (VbC), Gate 5 (GREEN implements entry criteria) |
| SC-2 | Item D | structural | ✅ Gate 9 (VbC), Gate 5 (GREEN implements create-and-validate) |
| SC-3 | Item A | string | ✅ Gate 9 (VbC), Gate 5 (GREEN creates spec-to-plan.md) |
| SC-4 | Item A | string | ✅ Gate 9 (VbC), Gate 5 (GREEN creates spec-to-plan.md) |
| SC-5 | Item A | string | ✅ Gate 9 (VbC), Gate 5 (GREEN creates spec-to-plan.md) |
| SC-6 | Item B | string | ✅ Gate 9 (VbC), Gate 5 (GREEN creates pre-flight-handoff.md) |
| SC-7 | Item B | string | ✅ Gate 9 (VbC), Gate 5 (GREEN creates pre-flight-handoff.md) |
| SC-8 | Item B | string | ✅ Gate 9 (VbC), Gate 5 (GREEN creates pre-flight-handoff.md) |
| SC-9 | Item B | string | ✅ Gate 9 (VbC), Gate 5 (GREEN creates pre-flight-handoff.md) |
| SC-10 | Item C | string | ✅ Gate 9 (VbC), Gate 5 (GREEN creates sc-closeout.md) |
| SC-11 | Item A | string | ✅ Gate 9 (VbC), Gate 5 (GREEN creates spec-to-plan.md) |
| SC-12 | Item A | string | ✅ Gate 9 (VbC), Gate 5 (GREEN creates spec-to-plan.md) |
| SC-13 | Item A | string | ✅ Gate 9 (VbC), Gate 5 (GREEN creates spec-to-plan.md) |
| SC-14 | Item A | string | ✅ Gate 9 (VbC), Gate 5 (GREEN creates spec-to-plan.md) |
| SC-15 | Item A | string | ✅ Gate 9 (VbC), Gate 5 (GREEN creates spec-to-plan.md) |
| SC-16 | Item A | string | ✅ Gate 9 (VbC), Gate 5 (GREEN creates spec-to-plan.md) |
| SC-17 | Item B | string | ✅ Gate 9 (VbC), Gate 5 (GREEN creates pre-flight-handoff.md) |
| SC-18 | Item B | string | ✅ Gate 9 (VbC), Gate 5 (GREEN creates pre-flight-handoff.md) |
| SC-19 | Item D | structural | ✅ Gate 9 (VbC), Gate 5 (GREEN implements create-and-validate) |
| SC-20 | Item E | structural | ✅ Gate 9 (VbC), Gate 5 (GREEN updates SKILL.md) |

**All 20 SCs covered.** No uncovered SCs.

---

**Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)**
