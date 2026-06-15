---
number: 1228
title: "[PLAN] Mandate compliance statement in every spec and plan body"
status: draft
parent_spec: 1228
created: 2026-06-15
---

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Plan: Mandate Compliance Statement in Every Spec and Plan Body

**Spec:** #1228
**Authorization scope:** `for_plan` | `halt_at: plan_created` | `pr_strategy: none`
**Type:** Combined (single-task, single concern — all items modify skill task files)

## Summary

Insert a fixed compliance statement into spec and plan body generation at the task file level. Statement must appear at top and bottom of every generated spec and plan body. Add behavioral and content-verification enforcement tests.

**SCs covered:**
| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `spec-creation/tasks/write.md` Step 1 mandates compliance statement at top and bottom of spec body | `string` |
| SC-2 | `writing-plans/tasks/create/create-and-validate.md` Step 7 mandates compliance statement at top and bottom of plan body | `string` |
| SC-3 | Behavioral test exists at `.opencode/tests/behaviors/compliance-statement-spec.sh` and passes after GREEN | `behavioral` |
| SC-4 | Behavioral test exists at `.opencode/tests/behaviors/compliance-statement-plan.sh` and passes after GREEN | `behavioral` |
| SC-5 | The compliance statement uses the exact wording specified in this spec | `string` |
| SC-6 | Compliance statement appears at both top and bottom of generated artifacts | `behavioral` |

**Affected files:**
- `.opencode/skills/spec-creation/tasks/write.md`
- `.opencode/skills/writing-plans/tasks/create/create-and-validate.md`
- `.opencode/tests/behaviors/compliance-statement-spec.sh` (new)
- `.opencode/tests/behaviors/compliance-statement-plan.sh` (new)

---

## Pre-Work (before pipeline)

1. Create feature branch: `feature/1228-compliance-statement`
2. Tag `.opencode` submodule: `.opencode/checkpoint/1228/pre`
3. Initialize pipeline state

## RED Assertions

- **SC-1 RED:** Grep `spec-creation/tasks/write.md` for compliance statement mandate — should NOT find it (feature doesn't exist yet)
- **SC-2 RED:** Grep `writing-plans/tasks/create/create-and-validate.md` for compliance statement mandate — should NOT find it
- **SC-3 RED:** Run `.opencode/tests/behaviors/compliance-statement-spec.sh` — should fail (test expects compliance statement in output, but generation doesn't include it)
- **SC-4 RED:** Run `.opencode/tests/behaviors/compliance-statement-plan.sh` — should fail
- **SC-5 RED:** No task files contain the exact compliance statement wording
- **SC-6 RED:** Generated specs and plans have 0 occurrences of the compliance statement

## Verification Methods

- **SC-1 (string):** `grep -c "Compliance Requirement" .opencode/skills/spec-creation/tasks/write.md` returns ≥ 1
- **SC-2 (string):** `grep -c "Compliance Requirement" .opencode/skills/writing-plans/tasks/create/create-and-validate.md` returns ≥ 1
- **SC-3 (behavioral):** `bash .opencode/tests/behaviors/compliance-statement-spec.sh` exits 0
- **SC-4 (behavioral):** `bash .opencode/tests/behaviors/compliance-statement-plan.sh` exits 0
- **SC-5 (string):** Grep both task files for the exact compliance paragraph text
- **SC-6 (behavioral):** Behavioral test verifies two occurrences of the statement in generated output

---

## Phase 1: Skill Task File Modifications

**Concern:** Insert compliance statement mandate into spec-creation and writing-plans task files.

**Files:**
- `.opencode/skills/spec-creation/tasks/write.md` — Step 1: add mandate for compliance statement at top and bottom
- `.opencode/skills/writing-plans/tasks/create/create-and-validate.md` — Step 7: add mandate for compliance statement at top and bottom

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"issue":1228,"phase":1,"task":"verify SC-1 through SC-6 are coherent with the spec — confirm write.md and create-and-validate.md are the correct insertion points, check for existing compliance-related language"}` | SC-1, SC-2 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"issue":1228,"phase":1,"task":"capture baseline: grep write.md and create-and-validate.md for 'Compliance Requirement' — expect 0 matches; log baseline to tmp/1228/baseline.json"}` | SC-1, SC-2 |
| G3: red-phase | sub-task | yes (blind) | general | `{"issue":1228,"phase":1,"remediation":true,"task":"write RED enforcement tests: (1) compliance-statement-spec.sh — verifies spec body lacks compliance statement, (2) compliance-statement-plan.sh — verifies plan body lacks compliance statement; both tests MUST fail before implementation"}` | SC-3, SC-4 |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"issue":1228,"phase":1,"task":"verify RED tests actually fail: run each behavioral test script, confirm expected-failure output; log to tmp/1228/red-verified.json"}` | SC-3, SC-4 |
| G5: post-red-enforcement | sub-task | yes (blind) | general | `{"issue":1228,"phase":1,"task":"confirm RED phase complete: all RED tests written, all verified failing, no GREEN work started"}` | SC-3, SC-4 |
| G6: green-phase | sub-task | yes (blind) | general | `{"issue":1228,"phase":1,"remediation":true,"task":"implement: (1) modify write.md Step 1 to mandate compliance statement at top and bottom of spec body, (2) modify create-and-validate.md Step 7 to mandate compliance statement at top and bottom of plan body; use exact wording from spec"}` | SC-1, SC-2, SC-5 |
| G7: post-green-enforcement | sub-task | yes (blind) | general | `{"issue":1228,"phase":1,"task":"verify GREEN changes applied: grep write.md for compliance statement → expect ≥ 1 match; grep create-and-validate.md → expect ≥ 1 match"}` | SC-1, SC-2 |
| G8: checkpoint-commit | inline | N/A | N/A | — | SC-1, SC-2, SC-5 |
| G9: structural-checks | sub-task | yes (blind) | general | `{"issue":1228,"phase":1,"task":"structural verification: (1) write.md has compliance statement mandate in Step 1, (2) create-and-validate.md has mandate in Step 7, (3) exact wording matches spec exactly"}` | SC-1, SC-2, SC-5 |
| G10: green-doublecheck | sub-task | yes (blind) | general | `{"issue":1228,"phase":1,"task":"independent re-verification: re-run all RED tests (now expect compliance statement present), confirm all pass"}` | SC-3, SC-4 |
| G11: green-vbc | sub-task | yes (blind) | general | `{"issue":1228,"phase":1,"task":"verification-before-completion: for each SC (SC-1 through SC-6), collect evidence artifact, report PASS/FAIL with tool-call evidence"}` | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6 |
| G12: adversarial-audit | sub-task | yes (blind) | general | `{"issue":1228,"phase":1,"task":"adversarial audit of Phase 1: audit insertion points, exact wording match, both top and bottom placement, behavioral test completeness; report findings per SC"}` | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6 |
| G13: cross-validate | sub-task | yes (blind) | general | `{"issue":1228,"phase":1,"task":"cross-validate: compare G11 VbC results against G12 audit results; report consensus (PASS/FAIL/DISAGREE) per SC"}` | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6 |
| G14: regression-check | sub-task | yes (blind) | general | `{"issue":1228,"phase":1,"task":"regression check: run all existing behavioral tests — confirm nothing broke"}` | — |
| G15: review-prep | sub-task | yes (blind) | general | `{"issue":1228,"phase":1,"task":"prepare review: generate diff summary, list files modified, produce compare URL"}` | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6 |
| G16: exec-summary | sub-task | yes (blind) | general | `{"issue":1228,"phase":1,"task":"produce executive summary: what was done, SC PASS/FAIL table, any blockers or concerns, artifact paths"}` | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6 |

---

## SC-ID Traceability

| SC | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `spec-creation/tasks/write.md` Step 1 mandates compliance statement at top and bottom of spec body | `string` |
| SC-2 | `writing-plans/tasks/create/create-and-validate.md` Step 7 mandates compliance statement at top and bottom of plan body | `string` |
| SC-3 | Behavioral test exists at `.opencode/tests/behaviors/compliance-statement-spec.sh` and passes after GREEN | `behavioral` |
| SC-4 | Behavioral test exists at `.opencode/tests/behaviors/compliance-statement-plan.sh` and passes after GREEN | `behavioral` |
| SC-5 | The compliance statement uses the exact wording specified in this spec | `string` |
| SC-6 | Compliance statement appears at both top and bottom of generated artifacts | `behavioral` |

---

## Post-All-Phases Sweep

1. Tag submodule: `.opencode/checkpoint/1228/post`
2. Run enforcement tests: `bash .opencode/tests/test-enforcement.sh --changed`
3. Run finish-checklist: `skill({name: "finishing-a-development-branch"})`

---

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.