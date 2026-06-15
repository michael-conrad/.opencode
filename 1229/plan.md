---
number: 1229
title: "[PLAN] spec-creation/write: post-SC uplift check"
status: draft
parent_spec: 1229
created: 2026-06-15
---

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Plan: spec-creation/write — post-SC uplift check after initial creation with remediation and recheck

**Spec:** #1229
**Authorization scope:** `for_plan` | `halt_at: plan_created` | `pr_strategy: none`
**Type:** Combined (single-task, single concern — all items modify spec-creation task files)

## Summary

Add a post-SC uplift check substep in `write.md` after Step 6 (self-review), before Step 6.5 (evidence artifact verification). The step re-examines each SC's evidence type against the BEH-EV substrate question, auto-uplifts misclassified SCs to `behavioral`, provides remediation guidance, and re-checks after remediation. Also update `completion.md` and the Operating Protocol checklist.

**SCs covered:**
| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Post-SC uplift check substep exists in write.md between Step 6 and Step 6.5 | `string` |
| SC-2 | Uplift check performs SC evidence type re-check against BEH-EV substrate question | `string` |
| SC-3 | Auto-uplift structural/string SCs to behavioral when runtime-behavioral change detected | `string` |
| SC-4 | Downgrade flag path exists for behavioral→structural false positives (flag-for-review, no auto-change) | `string` |
| SC-5 | Remediation guidance provided for each uplifted SC | `string` |
| SC-6 | Re-check step runs after remediation to confirm no remaining misclassifications | `string` |
| SC-7 | Findings written to `.issues/{N}/post-sc-uplift-check.yaml` | `string` |
| SC-8 | completion.md verifies post-SC uplift check step ran before spec completion | `string` |
| SC-9 | write.md Operating Protocol checklist includes the new step | `string` |

**Affected files:**
- `.opencode/skills/spec-creation/tasks/write.md` — add substep between Step 6 and Step 6.5
- `.opencode/skills/spec-creation/tasks/completion.md` — add verification that uplift check ran

---

## Pre-Work (before pipeline)

1. Create feature branch: `feature/1229-post-sc-uplift-check`
2. Tag `.opencode` submodule: `.opencode/checkpoint/1229/pre`
3. Initialize pipeline state

## RED Assertions

- **SC-1 RED:** grep write.md for "post-SC uplift check" — should NOT match (substep doesn't exist yet)
- **SC-2 RED:** No "BEH-EV" or "substrate" reference in write.md around Step 6
- **SC-3 RED:** No auto-uplift language in write.md
- **SC-4 RED:** No downgrade-flag path in write.md
- **SC-5 RED:** No remediation guidance in write.md for uplifted SCs
- **SC-6 RED:** No re-check step in write.md
- **SC-7 RED:** No "post-sc-uplift-check" artifact path in write.md
- **SC-8 RED:** grep completion.md for "post-sc-uplift-check" — should NOT match
- **SC-9 RED:** Operating Protocol checklist in write.md does not reference uplift check

## Verification Methods

- **SC-1 to SC-9 (string):** grep each modified file for the corresponding substep text

---

## Phase 1: Add Post-SC Uplift Check Substep

**Concern:** Insert the post-SC uplift check substep into spec-creation task files.

**Items (TDD order):**
1. **write.md substep** — Add substep between Step 6 and Step 6.5 with: evidence type re-check, auto-uplift, downgrade flag, remediation guidance, re-check, evidence artifact
2. **completion.md update** — Add verification that uplift check ran before spec completion
3. **write.md Operating Protocol** — Add the new step to the procedure checklist

**Files:**
- `.opencode/skills/spec-creation/tasks/write.md` — substep between Step 6 and Step 6.5
- `.opencode/skills/spec-creation/tasks/completion.md` — add uplift check verification

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"issue":1229,"phase":1,"task":"verify SC-1 through SC-9 are coherent with the spec — confirm write.md Step 6 structure and completion.md entry/exit criteria, check for existing uplift-related content"}` | SC-1, SC-8, SC-9 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"issue":1229,"phase":1,"task":"capture baseline: grep write.md for all expected substep markers, confirm 0 matches; log to tmp/1229/baseline.json"}` | SC-1 through SC-9 |
| G3: red-phase | sub-task | yes (blind) | general | `{"issue":1229,"phase":1,"remediation":true,"task":"RED item 1: verify write.md does NOT contain post-SC uplift check between Step 6 and Step 6.5 — grep for evidence type re-check language, auto-uplift, downgrade flag, remediation guidance, re-check, post-sc-uplift-check.yaml"}` | SC-1 through SC-7 |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"issue":1229,"phase":1,"task":"RED items 2-3: verify completion.md does NOT reference post-sc-uplift-check, and write.md Operating Protocol does NOT reference the new step"}` | SC-8, SC-9 |
| G5: post-red-enforcement | sub-task | yes (blind) | general | `{"issue":1229,"phase":1,"task":"confirm all 3 RED items verified failing, no GREEN work started"}` | SC-1 through SC-9 |
| G6: green-phase | sub-task | yes (blind) | general | `{"issue":1229,"phase":1,"remediation":true,"task":"implement all 3 items: (1) add post-SC uplift check substep to write.md between Step 6 and Step 6.5 — evidence type re-check, auto-uplift structural/string→behavioral, downgrade-flag path (flag-for-review), remediation guidance per uplift type, re-check, write findings to .issues/{N}/post-sc-uplift-check.yaml; (2) update completion.md entry criteria to verify uplift check ran; (3) update write.md Operating Protocol checklist"}` | SC-1 through SC-9 |
| G7: post-green-enforcement | sub-task | yes (blind) | general | `{"issue":1229,"phase":1,"task":"verify GREEN changes applied: grep write.md for all 7 substep components, grep completion.md for uplift check reference, grep write.md Operating Protocol for new step"}` | SC-1 through SC-9 |
| G8: checkpoint-commit | inline | N/A | N/A | — | SC-1 through SC-9 |
| G9: structural-checks | sub-task | yes (blind) | general | `{"issue":1229,"phase":1,"task":"structural verification: (1) write.md has post-SC uplift check substep after Step 6, (2) Step 6.5 still follows the new substep, (3) completion.md has uplift check verification, (4) write.md Operating Protocol includes new step"}` | SC-1, SC-8, SC-9 |
| G10: green-doublecheck | sub-task | yes (blind) | general | `{"issue":1229,"phase":1,"task":"independent re-verification: re-run all RED assertions, confirm all now match (features exist)"}` | SC-1 through SC-9 |
| G11: green-vbc | sub-task | yes (blind) | general | `{"issue":1229,"phase":1,"task":"verification-before-completion: for each SC (SC-1 through SC-9), collect evidence artifact, report PASS/FAIL with tool-call evidence"}` | SC-1 through SC-9 |
| G12: adversarial-audit | sub-task | yes (blind) | general | `{"issue":1229,"phase":1,"task":"adversarial audit of Phase 1: audit substep placement, completeness of uplift logic (re-check, auto-uplift, downgrade flag, remediation, re-check, artifact), completion.md integration"}` | SC-1 through SC-9 |
| G13: cross-validate | sub-task | yes (blind) | general | `{"issue":1229,"phase":1,"task":"cross-validate: compare G11 VbC results against G12 audit results; report consensus per SC"}` | SC-1 through SC-9 |
| G14: regression-check | sub-task | yes (blind) | general | `{"issue":1229,"phase":1,"task":"regression check: grep write.md to confirm Step 6 (self-review) and Step 6.5 (evidence artifact verification) still exist unchanged"}` | — |
| G15: review-prep | sub-task | yes (blind) | general | `{"issue":1229,"phase":1,"task":"prepare review: generate diff summary, list files modified, produce compare URL"}` | SC-1 through SC-9 |
| G16: exec-summary | sub-task | yes (blind) | general | `{"issue":1229,"phase":1,"task":"produce executive summary: what was done, SC PASS/FAIL table, any blockers or concerns, artifact paths"}` | SC-1 through SC-9 |

---

## SC-ID Traceability

| SC | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Post-SC uplift check substep exists in write.md between Step 6 and Step 6.5 | `string` |
| SC-2 | Uplift check performs SC evidence type re-check against BEH-EV substrate question | `string` |
| SC-3 | Auto-uplift structural/string SCs to behavioral when runtime-behavioral change detected | `string` |
| SC-4 | Downgrade flag path exists for behavioral→structural (flag-for-review, no auto-change) | `string` |
| SC-5 | Remediation guidance provided for each uplifted SC | `string` |
| SC-6 | Re-check step runs after remediation to confirm no remaining misclassifications | `string` |
| SC-7 | Findings written to `.issues/{N}/post-sc-uplift-check.yaml` | `string` |
| SC-8 | completion.md verifies post-SC uplift check step ran before spec completion | `string` |
| SC-9 | write.md Operating Protocol checklist includes the new step | `string` |

---

## Post-All-Phases Sweep

1. Tag submodule: `.opencode/checkpoint/1229/post`
2. Run enforcement tests: `bash .opencode/tests/test-enforcement.sh --changed`
3. Run finish-checklist: `skill({name: "finishing-a-development-branch"})`

---

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.