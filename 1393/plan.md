# Implementation Plan — [#1393](https://github.com/michael-conrad/.opencode/issues/1393) — Fix writing-plans skill: task file structure, dispatch markers, contract schemas, and checklist format

**Goal:** Fix structural defects in `writing-plans` and `spec-creation` skill task files to make plans produced by AI agents compliant with the implementation workflow pipeline.

**Architecture:** All changes are to `.opencode/skills/writing-plans/` and `.opencode/skills/spec-creation/` task files, SKILL.md files, and contracts. No code changes outside these directories.

**Files:**
- `.opencode/skills/writing-plans/tasks/create.md` — Convert prose pipeline to structured dispatch table + Trigger Dispatch Table + nested sub-bullets + remove dead template refs + add dispatch markers + add z3-check instructions with contract validation
- `.opencode/skills/writing-plans/tasks/write.md` — Add dispatch markers + standardize checklist format + add phase sections format + add validation rule 6 format + remove hard-coded RED/GREEN chain + remove contradictory rule + specify three-tier plan structure + add output contract validation instruction + add dynamic sub-step metadata requirements (R11) + add failure condition requirements (R13)
- `.opencode/skills/writing-plans/tasks/validate.md` — Add dispatch markers + add check 13 (checkbox format) + add check 14 (full workflow sequence) + add check 15 (no duplicated global steps) + add check 16 (three-tier structure) + add check 17 (failure conditions on RED steps) + add contract schema + add output contract validation instruction
- `.opencode/skills/writing-plans/tasks/solve.md` — Add instruction to validate against output contract from `contracts/<task>-output-template.yaml` for z3-check steps (R14)
- `.opencode/skills/writing-plans/tasks/structure.md` — Add three-tier structure requirement to exit criteria (R15)
- `.opencode/skills/writing-plans/SKILL.md` — Add dispatch markers to Operating Protocol steps + remove dead template references
- `.opencode/skills/writing-plans/contracts/write-output-template.yaml` — Expand with compliance fields
- `.opencode/skills/writing-plans/contracts/validate-output-template.yaml` — Expand with structured validation_results schema
- `.opencode/skills/implementation-pipeline/SKILL.md` — Add z3-check entries to Dispatch Routing Table between each RED/GREEN gate pair (R12)
- `.opencode/skills/spec-creation/tasks/write.md` — Produce spec-to-plan-handoff.yaml manifest (R16) + align sc-summary.yaml schema (R17) + save full spec to .issues/{N}/spec.md (R18) + run local-issues sync after spec folder changes (R22)
- `.opencode/skills/spec-creation/tasks/decompose.md` — Define three-tier phase structure for multi-phase specs (R19)
- `.opencode/skills/spec-creation/tasks/pipeline-readiness-gate.md` — Add PR-5 check for three-tier structure validation (R20)
- `.opencode/skills/spec-creation/tasks/traceability.md` — Verify every SC has a phase binding (R21)

**Approval Cascade:** `authorization_scope: for_pr`, `halt_at: pr_created`, `pr_strategy: stacked`

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Phase 1 — Global Pre-Phase

- [ ] 1. (**sub-agent**) Pre-flight handoff — execute pre-flight-handoff from implementation-pipeline
  - Context: `{ issue_number: 1393, plan_path: .opencode/.issues/1393/plan.md }`

- [ ] 2. (**inline**) Handoff-consistency check — compare spec-to-plan and plan-to-pipeline manifests

- [ ] 3. (**sub-agent**) SC coherence gate — execute sc-coherence-gate from implementation-pipeline
  - Context: `{ issue_number: 1393 }`

- [ ] 4. (**sub-agent**) Pre-RED baseline — execute pre-red-baseline from implementation-pipeline
  - Context: `{ issue_number: 1393 }`

## Phase 2 — Fix create.md

**Files:** `.opencode/skills/writing-plans/tasks/create.md`
**SCs:** SC-1, SC-2, SC-3, SC-5, SC-16, SC-17

- [ ] 5. (**sub-agent**) RED phase — execute red-phase from implementation-pipeline
  - Context: `{ issue_number: 1393 }`
  - Failure condition: RED enforcement test does not fail → BLOCKED

- [ ] 6. (**inline**) Z3 check — `solve check` against RED output contract
  - Contract: `skills/writing-plans/contracts/red-phase-output-template.yaml`

- [ ] 7. (**sub-agent**) RED doublecheck — execute red-doublecheck from implementation-pipeline
  - Context: `{ issue_number: 1393 }`

- [ ] 8. (**inline**) Z3 check — `solve check` against RED doublecheck output contract
  - Contract: `skills/writing-plans/contracts/red-doublecheck-output-template.yaml`

- [ ] 9. (**sub-agent**) Post-RED enforcement — execute post-red-enforcement from implementation-pipeline
  - Context: `{ issue_number: 1393 }`

- [ ] 10. (**inline**) Z3 check — `solve check` against post-RED enforcement output contract
  - Contract: `skills/writing-plans/contracts/post-red-enforcement-output-template.yaml`

- [ ] 11. (**sub-agent**) GREEN phase — execute green-phase from implementation-pipeline
  - Context: `{ issue_number: 1393, files: [.opencode/skills/writing-plans/tasks/create.md], scs: [SC-1, SC-2, SC-3, SC-5, SC-16, SC-17] }`
  - SC-1: Add Trigger Dispatch Table after Prerequisites with rows for all 10 sub-steps
  - SC-2: Convert 21-step prose pipeline to `- [ ] N.` entries with nested sub-bullets
  - SC-3: Remove `input:`, `output:`, `template:` contract path references from all 21 steps
  - SC-5: Add `(**inline**)` or `(**sub-agent**)` dispatch markers to all steps including prerequisites
  - SC-16: Add instruction to load output contract from `contracts/create-output-template.yaml` and validate before returning
  - SC-17: Add z3-check instructions with contract validation paths

- [ ] 12. (**inline**) Z3 check — `solve check` against GREEN output contract
  - Contract: `skills/writing-plans/contracts/create-output-template.yaml`
  - SC-20: verify plan compliance fields before proceeding to audit

- [ ] 13. (**sub-agent**) Post-GREEN enforcement — execute post-green-enforcement from implementation-pipeline
  - Context: `{ issue_number: 1393 }`

- [ ] 14. (**inline**) Z3 check — `solve check` against post-GREEN enforcement output contract
  - Contract: `skills/writing-plans/contracts/post-green-enforcement-output-template.yaml`

- [ ] 15. (**sub-agent**) Checkpoint tag create — execute checkpoint-tag-create from implementation-pipeline
  - Context: `{ issue_number: 1393 }`

- [ ] 16. (**sub-agent**) Checkpoint commit — execute checkpoint-commit from implementation-pipeline
  - Context: `{ issue_number: 1393 }`

- [ ] 17. (**sub-agent**) Structural checks — execute structural-checks from implementation-pipeline
  - Context: `{ issue_number: 1393 }`

- [ ] 18. (**sub-agent**) GREEN doublecheck — execute green-doublecheck from implementation-pipeline
  - Context: `{ issue_number: 1393 }`

- [ ] 19. (**sub-agent**) GREEN VbC — execute green-vbc from implementation-pipeline
  - Context: `{ issue_number: 1393 }`

## Phase 3 — Fix write.md

**Files:** `.opencode/skills/writing-plans/tasks/write.md`
**SCs:** SC-5, SC-6, SC-7, SC-8, SC-11, SC-12, SC-14, SC-16, SC-18, SC-21, SC-23

- [ ] 20. (**sub-agent**) RED phase — execute red-phase from implementation-pipeline
  - Context: `{ issue_number: 1393 }`
  - Failure condition: RED enforcement test does not fail → BLOCKED

- [ ] 21. (**inline**) Z3 check — `solve check` against RED output contract
  - Contract: `skills/writing-plans/contracts/red-phase-output-template.yaml`

- [ ] 22. (**sub-agent**) RED doublecheck — execute red-doublecheck from implementation-pipeline
  - Context: `{ issue_number: 1393 }`

- [ ] 23. (**inline**) Z3 check — `solve check` against RED doublecheck output contract
  - Contract: `skills/writing-plans/contracts/red-doublecheck-output-template.yaml`

- [ ] 24. (**sub-agent**) Post-RED enforcement — execute post-red-enforcement from implementation-pipeline
  - Context: `{ issue_number: 1393 }`

- [ ] 25. (**inline**) Z3 check — `solve check` against post-RED enforcement output contract
  - Contract: `skills/writing-plans/contracts/post-red-enforcement-output-template.yaml`

- [ ] 26. (**sub-agent**) GREEN phase — execute green-phase from implementation-pipeline
  - Context: `{ issue_number: 1393, files: [.opencode/skills/writing-plans/tasks/write.md], scs: [SC-5, SC-6, SC-7, SC-8, SC-11, SC-12, SC-14, SC-16, SC-18] }`
  - SC-5: Add dispatch markers to all 6 procedure steps
  - SC-6: Fix dispatch indicator examples table to use `- [ ] N.` format
  - SC-7: Update phase sections format to say "checkbox steps (`- [ ] N.`)"
  - SC-8: Update validation rule 6 to say "checkbox steps (`- [ ] N.`)"
  - SC-11: Remove hard-coded RED/GREEN chain from line 91; add instruction to read `implementation-pipeline/SKILL.md` §Dispatch Routing Table
  - SC-12: Remove line 65 ("No hardcoded gate sequences")
  - SC-14: Specify three-tier plan structure in plan format requirements
  - SC-16: Add instruction to load output contract from `contracts/write-output-template.yaml` and validate before returning
  - SC-18: Expand `write-output-template.yaml` with compliance fields
  - SC-21: Add dynamic sub-step metadata requirements (dispatch context, SC references, failure conditions, contract paths — derived from spec and step purpose, not hard-coded)
  - SC-23: Add failure condition requirements on RED phase steps

- [ ] 27. (**inline**) Z3 check — `solve check` against GREEN output contract
  - Contract: `skills/writing-plans/contracts/write-output-template.yaml`

- [ ] 28. (**sub-agent**) Post-GREEN enforcement — execute post-green-enforcement from implementation-pipeline
  - Context: `{ issue_number: 1393 }`

- [ ] 29. (**inline**) Z3 check — `solve check` against post-GREEN enforcement output contract
  - Contract: `skills/writing-plans/contracts/post-green-enforcement-output-template.yaml`

- [ ] 30. (**sub-agent**) Checkpoint tag create — execute checkpoint-tag-create from implementation-pipeline
  - Context: `{ issue_number: 1393 }`

- [ ] 31. (**sub-agent**) Checkpoint commit — execute checkpoint-commit from implementation-pipeline
  - Context: `{ issue_number: 1393 }`

- [ ] 32. (**sub-agent**) Structural checks — execute structural-checks from implementation-pipeline
  - Context: `{ issue_number: 1393 }`

- [ ] 33. (**sub-agent**) GREEN doublecheck — execute green-doublecheck from implementation-pipeline
  - Context: `{ issue_number: 1393 }`

- [ ] 34. (**sub-agent**) GREEN VbC — execute green-vbc from implementation-pipeline
  - Context: `{ issue_number: 1393 }`

## Phase 4 — Fix validate.md

**Files:** `.opencode/skills/writing-plans/tasks/validate.md`
**SCs:** SC-4, SC-5, SC-9, SC-13, SC-15, SC-16, SC-17, SC-19, SC-24

- [ ] 35. (**sub-agent**) RED phase — execute red-phase from implementation-pipeline
  - Context: `{ issue_number: 1393 }`
  - Failure condition: RED enforcement test does not fail → BLOCKED

- [ ] 36. (**inline**) Z3 check — `solve check` against RED output contract
  - Contract: `skills/writing-plans/contracts/red-phase-output-template.yaml`

- [ ] 37. (**sub-agent**) RED doublecheck — execute red-doublecheck from implementation-pipeline
  - Context: `{ issue_number: 1393 }`

- [ ] 38. (**inline**) Z3 check — `solve check` against RED doublecheck output contract
  - Contract: `skills/writing-plans/contracts/red-doublecheck-output-template.yaml`

- [ ] 39. (**sub-agent**) Post-RED enforcement — execute post-red-enforcement from implementation-pipeline
  - Context: `{ issue_number: 1393 }`

- [ ] 40. (**inline**) Z3 check — `solve check` against post-RED enforcement output contract
  - Contract: `skills/writing-plans/contracts/post-red-enforcement-output-template.yaml`

- [ ] 41. (**sub-agent**) GREEN phase — execute green-phase from implementation-pipeline
  - Context: `{ issue_number: 1393, files: [.opencode/skills/writing-plans/tasks/validate.md], scs: [SC-4, SC-5, SC-9, SC-13, SC-15, SC-16, SC-17, SC-19] }`
  - SC-5: Add dispatch markers to all validation check steps
  - SC-9: Add validation check 13: "All implementation steps use `- [ ] N.` checkbox format"
  - SC-13: Add validation check 14: "Every phase contains the full implementation workflow step sequence from `implementation-pipeline/SKILL.md` §Dispatch Routing Table"
  - SC-15: Add validation check 15: "Global pre/post steps are not duplicated across per-file phases"
  - SC-16: Add instruction to load output contract from `contracts/validate-output-template.yaml` and validate before returning
  - SC-17: Add instruction: each z3-check step runs `solve check` against previous step's output contract
  - SC-19: Expand `validate-output-template.yaml` with structured `validation_results` schema
  - SC-24: Add validation check 17: "Every RED phase step has a failure condition derived from the step's purpose"
  - SC-4: Add "## Result Contract Schema" section with fields: status, per_check_results, artifact_path, summary

- [ ] 42. (**inline**) Z3 check — `solve check` against GREEN output contract
  - Contract: `skills/writing-plans/contracts/validate-output-template.yaml`

- [ ] 43. (**sub-agent**) Post-GREEN enforcement — execute post-green-enforcement from implementation-pipeline
  - Context: `{ issue_number: 1393 }`

- [ ] 44. (**inline**) Z3 check — `solve check` against post-GREEN enforcement output contract
  - Contract: `skills/writing-plans/contracts/post-green-enforcement-output-template.yaml`

- [ ] 45. (**sub-agent**) Checkpoint tag create — execute checkpoint-tag-create from implementation-pipeline
  - Context: `{ issue_number: 1393 }`

- [ ] 46. (**sub-agent**) Checkpoint commit — execute checkpoint-commit from implementation-pipeline
  - Context: `{ issue_number: 1393 }`

- [ ] 47. (**sub-agent**) Structural checks — execute structural-checks from implementation-pipeline
  - Context: `{ issue_number: 1393 }`

- [ ] 48. (**sub-agent**) GREEN doublecheck — execute green-doublecheck from implementation-pipeline
  - Context: `{ issue_number: 1393 }`

- [ ] 49. (**sub-agent**) GREEN VbC — execute green-vbc from implementation-pipeline
  - Context: `{ issue_number: 1393 }`

## Phase 5 — Fix SKILL.md

**Files:** `.opencode/skills/writing-plans/SKILL.md`
**SCs:** SC-3, SC-5

- [ ] 50. (**sub-agent**) RED phase — execute red-phase from implementation-pipeline
  - Context: `{ issue_number: 1393 }`
  - Failure condition: RED enforcement test does not fail → BLOCKED

- [ ] 51. (**inline**) Z3 check — `solve check` against RED output contract
  - Contract: `skills/writing-plans/contracts/red-phase-output-template.yaml`

- [ ] 52. (**sub-agent**) RED doublecheck — execute red-doublecheck from implementation-pipeline
  - Context: `{ issue_number: 1393 }`

- [ ] 53. (**inline**) Z3 check — `solve check` against RED doublecheck output contract
  - Contract: `skills/writing-plans/contracts/red-doublecheck-output-template.yaml`

- [ ] 54. (**sub-agent**) Post-RED enforcement — execute post-red-enforcement from implementation-pipeline
  - Context: `{ issue_number: 1393 }`

- [ ] 55. (**inline**) Z3 check — `solve check` against post-RED enforcement output contract
  - Contract: `skills/writing-plans/contracts/post-red-enforcement-output-template.yaml`

- [ ] 56. (**sub-agent**) GREEN phase — execute green-phase from implementation-pipeline
  - Context: `{ issue_number: 1393, files: [.opencode/skills/writing-plans/SKILL.md], scs: [SC-3, SC-5] }`
  - SC-5: Add dispatch markers to all 21 Operating Protocol pipeline steps
  - SC-3: Remove `input:`, `output:`, `template:` contract path references from all 21 steps

- [ ] 57. (**inline**) Z3 check — `solve check` against GREEN output contract
  - Contract: `skills/writing-plans/contracts/skill-output-template.yaml`

- [ ] 58. (**sub-agent**) Post-GREEN enforcement — execute post-green-enforcement from implementation-pipeline
  - Context: `{ issue_number: 1393 }`

- [ ] 59. (**inline**) Z3 check — `solve check` against post-GREEN enforcement output contract
  - Contract: `skills/writing-plans/contracts/post-green-enforcement-output-template.yaml`

- [ ] 60. (**sub-agent**) Checkpoint tag create — execute checkpoint-tag-create from implementation-pipeline
  - Context: `{ issue_number: 1393 }`

- [ ] 61. (**sub-agent**) Checkpoint commit — execute checkpoint-commit from implementation-pipeline
  - Context: `{ issue_number: 1393 }`

- [ ] 62. (**sub-agent**) Structural checks — execute structural-checks from implementation-pipeline
  - Context: `{ issue_number: 1393 }`

- [ ] 63. (**sub-agent**) GREEN doublecheck — execute green-doublecheck from implementation-pipeline
  - Context: `{ issue_number: 1393 }`

- [ ] 64. (**sub-agent**) GREEN VbC — execute green-vbc from implementation-pipeline
  - Context: `{ issue_number: 1393 }`

## Phase 6 — Verify plan-fidelity.md unchanged

- [ ] 65. (**inline**) Read `plan-fidelity.md` PF-CHECKLIST-FORMAT criterion — confirm already correct, no changes needed

## Phase 7 — Global Post-Phase: Implementation Pipeline Routing + Adversarial Audit + Cross-Validate + Regression

**Files:** `.opencode/skills/implementation-pipeline/SKILL.md`
**SCs:** SC-22

- [ ] 66. (**sub-agent**) Add z3-check entries to implementation-pipeline dispatch routing table
  - Context: `{ issue_number: 1393, files: [.opencode/skills/implementation-pipeline/SKILL.md], scs: [SC-22] }`
  - SC-22: Add z3-check entries between each RED/GREEN gate pair in the Dispatch Routing Table: red-phase → z3-check-red → red-doublecheck → z3-check-red-doublecheck → post-red-enforcement → z3-check-post-red → green-phase → z3-check-green → post-green-enforcement → z3-check-post-green

- [ ] 67. (**inline**) Resolve models — run `.opencode/tools/resolve-models`
- [ ] 67. (**sub-agent**) Auditor 1 — execute adversarial-audit with auditor_1
  - Context: `{ issue_number: 1393, audit_phase: verification-audit }`
- [ ] 68. (**inline**) Auditor 1 remediation — if non-clean-pass, remediate and restart from resolve-models
- [ ] 69. (**sub-agent**) Auditor 2 — execute adversarial-audit with auditor_2
  - Context: `{ issue_number: 1393, audit_phase: verification-audit }`
- [ ] 70. (**inline**) Auditor 2 remediation — if non-clean-pass, remediate and restart from resolve-models
- [ ] 71. (**sub-agent**) Cross-validate — execute cross-validate from implementation-pipeline
  - Context: `{ issue_number: 1393, auditor_artifact_paths: [...] }`
- [ ] 72. (**sub-agent**) Regression check — execute regression-check from implementation-pipeline
  - Context: `{ issue_number: 1393 }`

## Phase 8 — Global Post-Phase: Review Prep + Exec Summary

- [ ] 73. (**sub-agent**) Review prep — execute review-prep from implementation-pipeline
  - Context: `{ issue_number: 1393 }`
- [ ] 74. (**sub-agent**) Exec summary — execute exec-summary from implementation-pipeline
  - Context: `{ issue_number: 1393 }`

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Exit Criteria

- [ ] C1. create.md has Trigger Dispatch Table covering all 10 sub-steps (SC-1)
- [ ] C2. Every `- [ ] N.` step in create.md, write.md, validate.md uses nested sub-bullets for data (SC-2)
- [ ] C3. Dead template references removed from create.md and SKILL.md (SC-3)
- [ ] C4. Write, validate, and revisit sub-agents have explicit result contract schemas (SC-4)
- [ ] C5. Every step in create.md, write.md, validate.md, and SKILL.md has a dispatch marker (SC-5)
- [ ] C6. write.md dispatch indicator examples use `- [ ] N.` format (SC-6)
- [ ] C7. write.md phase sections format explicitly says "checkbox steps (`- [ ] N.`)" (SC-7)
- [ ] C8. write.md validation rule 6 explicitly says "checkbox steps (`- [ ] N.`)" (SC-8)
- [ ] C9. validate.md has check 13: "All implementation steps use `- [ ] N.` checkbox format" (SC-9)
- [ ] C10. plan-fidelity.md PF-CHECKLIST-FORMAT unchanged (SC-10)
- [ ] C11. write.md does not hard-code any RED/GREEN chain — instructs agent to read `implementation-pipeline/SKILL.md` §Dispatch Routing Table (SC-11)
- [ ] C12. write.md line 65 ("No hardcoded gate sequences") removed (SC-12)
- [ ] C13. validate.md has check 14: full implementation workflow step sequence validation (SC-13)
- [ ] C14. write.md plan format specifies three-tier structure: global pre-phase, per-file RED/GREEN phases, global post-phase (SC-14)
- [ ] C15. validate.md has check 15: "Global pre/post steps are not duplicated across per-file phases" (SC-15)
- [ ] C16. Every sub-agent task file instructs agent to load its output contract and validate before returning (SC-16)
- [ ] C17. Every z3-check step runs `solve check` against previous step's output contract (SC-17)
- [ ] C18. write-output-template.yaml expanded with compliance fields (SC-18)
- [ ] C19. validate-output-template.yaml expanded with structured validation_results schema (SC-19)
- [ ] C20. Orchestrator runs `solve check` against create-output-template.yaml after write step (SC-20)
- [ ] C21. write.md specifies dynamic sub-step metadata derived from spec and step purpose — no hard-coded templates (SC-21)
- [ ] C22. implementation-pipeline/SKILL.md dispatch routing table includes z3-check entries between RED/GREEN gate pairs (SC-22)
- [ ] C23. write.md requires failure conditions on RED phase steps, derived from step purpose (SC-23)
- [ ] C24. validate.md has check 17: failure conditions on RED steps (SC-24)
- [ ] C25. solve.md instructs sub-agent to validate against output contract for z3-check steps (SC-25)
- [ ] C26. structure.md exit criteria specify three-tier structure (SC-26)
- [ ] C27. spec-creation/tasks/write.md produces spec-to-plan-handoff.yaml manifest (SC-27)
- [ ] C28. spec-creation/tasks/write.md sc-summary.yaml schema includes flat scs list matching plan writer expectations (SC-28)
- [ ] C29. spec-creation/tasks/write.md saves full spec to .issues/{N}/spec.md (SC-29)
- [ ] C30. spec-creation/tasks/decompose.md defines three-tier phase structure for multi-phase specs (SC-30)
- [ ] C31. spec-creation/tasks/pipeline-readiness-gate.md has PR-5 check for three-tier validation (SC-31)
- [ ] C32. spec-creation/tasks/traceability.md verifies every SC has a phase binding (SC-32)
- [ ] C33. spec-creation/tasks/write.md instructs agent to run local-issues sync after spec folder changes (SC-33)
