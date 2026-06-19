# Implementation Plan — [`.opencode#1297`](https://github.com/michael-conrad/.opencode/issues/1297) — writing-plans checklist format

- [ ] **Goal:** Replace dispatch tables in the writing-plans `create` task with actionable enumerated checklists with sub-bullet metadata. Gate sequence discovered dynamically from `implementation-pipeline/SKILL.md`. Every step includes `(**clean-room**)` or `(**inline**)` dispatch mode indicator. No hardcoded gate sequence in plan writer skill cards. Update adversarial-audit task files (spec-audit.md, plan-fidelity.md) to validate the new checklist format.
- [ ] **Architecture:** Phase 1 → Phase 2 → Phase 3 → Phase 4 (sequential). All five files must be updated together for consistency. Phase 4 depends on Phase 1 and 2 establishing the new format so auditors can validate it.
- [ ] **Files:**
  - `.opencode/skills/writing-plans/tasks/create/plan-structure.md` — Phase 1
  - `.opencode/skills/writing-plans/tasks/create/create-and-validate.md` — Phase 2
  - `.opencode/skills/writing-plans/contracts/create-output-template.yaml` — Phase 3
  - `.opencode/skills/adversarial-audit/tasks/spec-audit.md` — Phase 4
  - `.opencode/skills/adversarial-audit/tasks/plan-fidelity.md` — Phase 4

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

---

## Phase 1 — Update plan-structure.md

**Concern:** Skill task file — dispatch table template and per-unit pipeline gate tables
**File:** `.opencode/skills/writing-plans/tasks/create/plan-structure.md`
**SCs:** SC-3, SC-1, SC-7
**Dependencies:** None
**Entry condition:** plan-structure.md contains 6-column dispatch table template at Step 4, 14-row per-unit gate table at Step 5, Z3 contract generation at Step 5.5
**Exit condition:** Dispatch tables removed. Output format spec, dispatch mode mapping, discovery directive, and sub-step expansion directive in place.

**Artifact paths:** `./tmp/1297/artifacts/pipeline-{step_label}-{STATUS}-{timestamp}.yaml`

- [ ] 1. **Coherence gate (**clean-room**).** Verify SC-3, SC-1, SC-7 consistent with codebase. Check current plan-structure.md for all dispatch table sections.
- [ ] 2. **Pre-RED baseline (**clean-room**).** Capture current plan-structure.md line count and all sections containing `| Gate |` or `Dispatch Table` patterns. Note hardcoded 14-row per-unit gate table at Step 5 and Z3 contract generation at Step 5.5.

#### RED+green P1-I1 — Replace dispatch table template

- [ ] 3. **RED (**clean-room**).** Write test grepping for `| Gate | Dispatch Type | Blind? |` in plan-structure.md — expects present, must FAIL. **→ SC-1**
- [ ] 4. **RED doublecheck (**clean-room**).** Confirm Step 3 fails as expected.
- [ ] 5. **Post-RED enforcement (**clean-room**).** Verify FAIL artifacts.
- [ ] 6. **GREEN (**clean-room**).** Replace Step 4 dispatch table template and Step 5 per-unit 14-row gate table with: output format spec (numbered checklists with sub-bullets and dispatch indicators), dispatch mode mapping (`sub-task` → `(**clean-room**)`, everything else → `(**inline**)`), discovery directive to read `implementation-pipeline/SKILL.md` §Dispatch Routing Table for gate sequence + dispatch types, sub-step expansion directive (gates with sub-steps become multiple `- [ ] N.` entries — prohibit collapsing sub-steps into prose). Keep Step 3 (item decomposition), Step 3.3 (phase dependency solve), Step 3.5 (RED/GREEN condition language). **→ SC-1, SC-3, SC-7**
- [ ] 7. **Post-GREEN enforcement (**clean-room**).** Verify file was modified — header uses correct marker.
- [ ] 8. **Structural checks (**clean-room**).** `wc -w` — under 3,000 words.
- [ ] 9. **GREEN doublecheck (**clean-room**).** grep for `| Gate |` — 0 matches. grep for hardcoded gate names — 0 matches. **→ SC-1, SC-3**
- [ ] 10. **Checkpoint commit (**inline**).** `git commit -m "plan-structure.md: dispatch tables → checklist format with dispatch indicators"`

#### RED+green P1-I2 — Remove Z3 contract generation section

- [ ] 11. **RED (**clean-room**).** Write test grepping for `P1_p1` or `14 boolean variables` — expects present, must FAIL.
- [ ] 12. **RED doublecheck (**clean-room**).** Confirm fails.
- [ ] 13. **Post-RED enforcement (**clean-room**).** Verify FAIL artifacts.
- [ ] 14. **GREEN (**clean-room**).** Remove Z3 contract generation section and `plan` utility invocation at Step 5.5. Keep phase-level dependency solve contract (Step 3.3) — that is structural, not dispatch. **→ SC-1, SC-3**
- [ ] 15. **Post-GREEN enforcement (**clean-room**).** Verify removed.
- [ ] 16. **Structural checks (**clean-room**).** `wc -w` — under 3,000 words.
- [ ] 17. **GREEN doublecheck (**clean-room**).** grep for `P1_p1` or `14 boolean` — 0 matches.
- [ ] 18. **Checkpoint commit (**inline**).** `git commit -m "plan-structure.md: remove per-unit Z3 contract templates"`

#### Phase 1 completion

- [ ] 19. **VbC (**clean-room**).** Verify SC-1, SC-3, SC-7 pass: no dispatch tables in template, no hardcoded gate names, dispatch indicator rules present.
- [ ] 20. **Resolve models (**inline**).** Run `.opencode/tools/resolve-models` to select cross-family auditors for verification-audit. Produces `auditor_1` and `auditor_2` with `artifact_path` contracts.
- [ ] 21. **Auditor 1: verification-audit (**clean-room**).** Dispatch `adversarial-audit --task verification-audit --issue 1297` with `audit_phase: post_implementation` to auditor_1. On non-clean-pass (FAIL or DONE_WITH_CONCERNS): remediate root cause, re-run resolve-models, restart from Step 20. Do NOT dispatch auditor 2.
- [ ] 22. **Auditor 2: verification-audit (**clean-room**).** Dispatch same audit task to auditor_2. On non-clean-pass: remediate, re-run resolve-models, restart from Step 20. Both clean PASS: collect both `artifact_path` values.
- [ ] 23. **Cross-validate (**clean-room**).** Pass `auditor_artifact_paths` to `adversarial-audit --task cross-validate`. Both PASS or DISAGREE with remediation.
- [ ] 24. **Regression check (**clean-room**).** `bash .opencode/tests/test-enforcement.sh --tag plan` — pass.
- [ ] 25. **Review prep (**clean-room**).** `git-workflow review-prep`.

**Concern transition:** Leaving skill task file (plan-structure.md) → entering validation task file (create-and-validate.md). Phase 2 depends on Phase 1's new output format being established so it can validate against it.

---

## Phase 2 — Update create-and-validate.md

**Concern:** Skill task file — dispatch table validation rules and phase body format
**File:** `.opencode/skills/writing-plans/tasks/create/create-and-validate.md`
**SCs:** SC-1, SC-6, SC-7, SC-8
**Dependencies:** Phase 1 complete (validation rules reference Phase 1's format)
**Entry condition:** create-and-validate.md contains 8-rule dispatch table validation at Step 10, phase body format referencing pipeline checkboxes at Step 7, and compliance requirement blockquote
**Exit condition:** Dispatch table validation replaced with checklist validation rules including SC coverage, dispatch indicator check, sub-step expansion check, admonishment presence. Phase body format updated.

**Artifact paths:** `./tmp/1297/artifacts/pipeline-{step_label}-{STATUS}-{timestamp}.yaml`

- [ ] 26. **Coherence gate (**clean-room**).** Verify SC-1, SC-6, SC-7, SC-8 consistent with Phase 1 changes.
- [ ] 27. **Pre-RED baseline (**clean-room**).** Capture current Step 7 (phase body format referencing pipeline checkboxes) and Step 10 (dispatch table validation with 8 rules).

#### RED+green P2-I1 — Replace validations

- [ ] 28. **RED (**clean-room**).** Write test grepping for `6-column requirement` or `Dispatch Table Validation` — expects present, must FAIL. **→ SC-1**
- [ ] 29. **RED doublecheck (**clean-room**).** Confirm fails.
- [ ] 30. **Post-RED enforcement (**clean-room**).** Verify FAIL artifacts.
- [ ] 31. **GREEN (**clean-room**).** Replace dispatch table validation (lines 134–146) with checklist validation:
  1. Every step is `- [ ] N.` with at least one sub-bullet.
  2. Every step title contains `(**clean-room**)` or `(**inline**)`.
  3. Gate sequence matches `implementation-pipeline/SKILL.md` dispatch routing table.
  4. No step describes more than one atomic action — every sub-operation from pipeline task files is expanded into its own `- [ ] N.` entry.
  5. All SCs referenced via `→ SC-N` annotations.
  6. No TBD/TODO placeholders.
  7. Admonishment blockquote present.
  8. Phase dependency ordering matches spec architecture.
  - Update Step 7 phase body format to reference checklist format with dispatch indicators. Keep admonishment requirement. **→ SC-1, SC-6, SC-7, SC-8**
- [ ] 32. **Post-GREEN enforcement (**clean-room**).** Verify dispatch validation section replaced.
- [ ] 33. **Structural checks (**clean-room**).** `wc -w` — under 3,000 words.
- [ ] 34. **GREEN doublecheck (**clean-room**).** grep for `Dispatch Table Validation` — 0. grep for `(**clean-room**)` or `dispatch indicator` — positive. **→ SC-6, SC-7**
- [ ] 35. **Checkpoint commit (**inline**).** `git commit -m "create-and-validate.md: dispatch table validation → checklist validation"`

#### Phase 2 completion

- [ ] 36. **VbC (**clean-room**).** Verify SC-1, SC-6, SC-7, SC-8 pass.
- [ ] 37. **Resolve models (**inline**).** Run `resolve-models` for cross-family auditors.
- [ ] 38. **Auditor 1: verification-audit (**clean-room**).** Dispatch to auditor_1. On non-clean-pass: remediate, re-run resolve-models, restart from Step 37.
- [ ] 39. **Auditor 2: verification-audit (**clean-room**).** Dispatch to auditor_2. On non-clean-pass: remediate, re-run resolve-models, restart from Step 37. Both PASS: collect artifact paths.
- [ ] 40. **Cross-validate (**clean-room**).** Consensus check.
- [ ] 41. **Regression check (**clean-room**).** `bash .opencode/tests/test-enforcement.sh --tag plan` — pass.
- [ ] 42. **Review prep (**clean-room**).** `git-workflow review-prep`.

**Concern transition:** Leaving validation task file (create-and-validate.md) → entering contract template (create-output-template.yaml). Phase 3 depends on Phase 1 and Phase 2 establishing the new checklist format.

---

## Phase 3 — Update create-output-template.yaml

**Concern:** Contract template — output schema for plan creation validation
**File:** `.opencode/skills/writing-plans/contracts/create-output-template.yaml`
**SCs:** SC-1, SC-4, SC-6, SC-7
**Dependencies:** Phase 1 and Phase 2 complete (schema fields must match checklist format)
**Entry condition:** Template only has schema v1.0 fields: status, plan_path, finding_summary, artifact_paths
**Exit condition:** Template updated to v2.0 with checklist validation fields: checklist_step_count, phase_count, sc_coverage, gate_sequence_source, admonishment_present, dispatch_table_free, dispatch_modes_used

**Artifact paths:** `./tmp/1297/artifacts/pipeline-{step_label}-{STATUS}-{timestamp}.yaml`

- [ ] 43. **Coherence gate (**clean-room**).** Verify SC-1, SC-4, SC-6, SC-7 consistent with Phase 1 and 2 changes.
- [ ] 44. **Pre-RED baseline (**clean-room**).** Capture current create-output-template.yaml — only status, plan_path, finding_summary, artifact_paths.

#### RED+green P3-I1 — Update output schema

- [ ] 45. **RED (**clean-room**).** Write test verifying template lacks `dispatch_modes_used` or `sc_coverage` fields — expects absent, must FAIL.
- [ ] 46. **RED doublecheck (**clean-room**).** Confirm fails.
- [ ] 47. **Post-RED enforcement (**clean-room**).** Verify FAIL artifacts.
- [ ] 48. **GREEN (**clean-room**).** Update to schema v2.0. Add: `checklist_step_count` (int), `phase_count` (int), `sc_coverage` (list of SC IDs with PASS/FAIL per SC), `gate_sequence_source` (string — must reference `implementation-pipeline/SKILL.md`), `admonishment_present` (bool), `dispatch_table_free` (bool), `dispatch_modes_used` (list — `clean-room` and/or `inline`). **→ SC-1, SC-4, SC-6, SC-7**
- [ ] 49. **Post-GREEN enforcement (**clean-room**).** Verify file modified.
- [ ] 50. **Structural checks (**clean-room**).** `python3 -c "import yaml; yaml.safe_load(open('.opencode/skills/writing-plans/contracts/create-output-template.yaml'))"`.
- [ ] 51. **GREEN doublecheck (**clean-room**).** grep for `dispatch_modes_used`, `gate_sequence_source` — positive. **→ SC-1, SC-4**
- [ ] 52. **Checkpoint commit (**inline**).** `git commit -m "create-output-template.yaml: add checklist validation fields v2"`

#### Phase 3 completion

- [ ] 53. **VbC (**clean-room**).** Verify SC-1, SC-4, SC-6, SC-7 pass.
- [ ] 54. **Resolve models (**inline**).** Run `resolve-models` for cross-family auditors.
- [ ] 55. **Auditor 1: verification-audit (**clean-room**).** Dispatch to auditor_1. On non-clean-pass: remediate, re-run resolve-models, restart from Step 54.
- [ ] 56. **Auditor 2: verification-audit (**clean-room**).** Dispatch to auditor_2. On non-clean-pass: remediate, re-run resolve-models, restart from Step 54. Both PASS: collect artifact paths.
- [ ] 57. **Cross-validate (**clean-room**).** Consensus.
- [ ] 58. **Regression check (**clean-room**).** `bash .opencode/tests/test-enforcement.sh --tag plan` — pass.
- [ ] 59. **Review prep (**clean-room**).** `git-workflow review-prep`.

**Concern transition:** Leaving contract template (create-output-template.yaml) → entering adversarial-audit task files (spec-audit.md, plan-fidelity.md). Phase 4 updates the auditor criteria that validate plan output format — depends on Phase 1 and Phase 2 establishing what the new format looks like.

---

## Phase 4 — Update adversarial-audit task files

**Concern:** Spec-audit and plan-fidelity criteria reference old dispatch-table format conventions
**Files:** `.opencode/skills/adversarial-audit/tasks/spec-audit.md`, `.opencode/skills/adversarial-audit/tasks/plan-fidelity.md`
**SCs:** SC-11, SC-12, SC-13, SC-14
**Dependencies:** Phase 1 and Phase 2 complete (auditor criteria must match the new checklist format they validate)
**Entry condition:** spec-audit.md has SC-PIPELINE-GATES validating per-unit gate tables (line 100). plan-fidelity.md has PF-Z3-CONTRACT with 14-boolean per-unit booleans (line 69), PF-6 without dispatch indicator check, and no PF-CHECKLIST-FORMAT/PF-DISPATCH-MODE/PF-SUBSTEP-EXPAND/PF-ADMONISHMENT/PF-SEQUENCE-MATCHES criteria.
**Exit condition:** spec-audit.md SC-PIPELINE-GATES validates checklist format (not per-unit gate tables). SC-CANONICAL-PLAN-FORM added. plan-fidelity.md PF-Z3-CONTRACT references hierarchical phase→item→gate booleans. PF-6 adds dispatch indicator check. All 5 new criteria present.

**Artifact paths:** `./tmp/1297/artifacts/pipeline-{step_label}-{STATUS}-{timestamp}.yaml`

- [ ] 60. **Coherence gate (**clean-room**).** Verify SC-11, SC-12, SC-13, SC-14 consistent with spec. Read spec-audit.md SC-PIPELINE-GATES (line 100) and plan-fidelity.md PF-Z3-CONTRACT (line 69), PF-6 (line 65).
- [ ] 61. **Pre-RED baseline (**clean-room**).** Capture current line counts for both files. Note exact text of stale criteria.

#### RED+green P4-I1 — Update spec-audit.md

- [ ] 62. **RED (**clean-room**).** Write test grepping for `per-unit gate tables` at SC-PIPELINE-GATES in spec-audit.md — expects present, must FAIL. **→ SC-11**
- [ ] 63. **RED doublecheck (**clean-room**).** Confirm fails.
- [ ] 64. **Post-RED enforcement (**clean-room**).** Verify FAIL artifacts.
- [ ] 65. **GREEN (**clean-room**).** Update SC-PIPELINE-GATES validation text: replace "per-unit gate tables" with "dispatch indicators in RED+green chains". Add new criterion SC-CANONICAL-PLAN-FORM: "If the spec defines plan output format requirements, validate that those requirements use the canonical checklist format (no dispatch tables, no shared cross-references)." **→ SC-11**
- [ ] 66. **Post-GREEN enforcement (**clean-room**).** Verify SC-PIPELINE-GATES text changed and SC-CANONICAL-PLAN-FORM present.
- [ ] 67. **Structural checks (**clean-room**).** `wc -w` — under 3,000 words.
- [ ] 68. **GREEN doublecheck (**clean-room**).** grep for `per-unit gate tables` at SC-PIPELINE-GATES — absent. grep for `dispatch indicator` near SC-PIPELINE-GATES — present. grep for `SC-CANONICAL-PLAN-FORM` — present. **→ SC-11**
- [ ] 69. **Checkpoint commit (**inline**).** `git commit -m "spec-audit.md: update SC-PIPELINE-GATES, add SC-CANONICAL-PLAN-FORM"`

#### RED+green P4-I2 — Update plan-fidelity.md PF-Z3-CONTRACT

- [ ] 70. **RED (**clean-room**).** Write test grepping for `14 per unit` or `P1_p1` at PF-Z3-CONTRACT in plan-fidelity.md — expects present, must FAIL. **→ SC-12**
- [ ] 71. **RED doublecheck (**clean-room**).** Confirm fails.
- [ ] 72. **Post-RED enforcement (**clean-room**).** Verify FAIL artifacts.
- [ ] 73. **GREEN (**clean-room**).** Update PF-Z3-CONTRACT validation text: replace "14-boolean per-unit (e.g., P1_p1..P1_p14)" with "hierarchical phase→item→gate booleans". Keep phase-level solve contract validation. **→ SC-12**
- [ ] 74. **Post-GREEN enforcement (**clean-room**).** Verify PF-Z3-CONTRACT text changed.
- [ ] 75. **Structural checks (**clean-room**).** `wc -w` — under 3,000 words.
- [ ] 76. **GREEN doublecheck (**clean-room**).** grep for `14 per unit` at PF-Z3-CONTRACT — absent. grep for `hierarchical` near PF-Z3-CONTRACT — present. **→ SC-12**
- [ ] 77. **Checkpoint commit (**inline**).** `git commit -m "plan-fidelity.md: update PF-Z3-CONTRACT to hierarchical booleans"`

#### RED+green P4-I3 — Update plan-fidelity.md PF-6 and add new criteria

- [ ] 78. **RED (**clean-room**).** Write test grepping for `dispatch indicator` near PF-6 in plan-fidelity.md — expects absent, must FAIL. Also verify PF-CHECKLIST-FORMAT criterion absent — must FAIL. **→ SC-13, SC-14**
- [ ] 79. **RED doublecheck (**clean-room**).** Confirm fails.
- [ ] 80. **Post-RED enforcement (**clean-room**).** Verify FAIL artifacts.
- [ ] 81. **GREEN (**clean-room**).** Update PF-6 validation text: append "Every step has `(**clean-room**)` or `(**inline**)` dispatch mode indicator in title." Add 5 new criteria to plan-fidelity.md:

  | Criterion | What It Checks |
  |-----------|----------------|
  | PF-CHECKLIST-FORMAT | All steps use `- [ ] N.` format with sub-bullets |
  | PF-DISPATCH-MODE | Every step has `(**clean-room**)` or `(**inline**)` indicator |
  | PF-SUBSTEP-EXPAND | No collapsed multi-operation steps — every sub-operation gets its own `- [ ] N.` |
  | PF-ADMONISHMENT | Compliance admonishment blockquote at top and bottom with full canonical text |
  | PF-SEQUENCE-MATCHES | Gate sequence matches `implementation-pipeline/SKILL.md` dispatch routing table |

  **→ SC-13, SC-14**
- [ ] 82. **Post-GREEN enforcement (**clean-room**).** Verify PF-6 updated and new criteria present.
- [ ] 83. **Structural checks (**clean-room**).** `wc -w` — under 3,000 words.
- [ ] 84. **GREEN doublecheck (**clean-room**).** grep for `dispatch indicator` near `PF-6` — present. grep for `PF-CHECKLIST-FORMAT`, `PF-DISPATCH-MODE`, `PF-SUBSTEP-EXPAND`, `PF-ADMONISHMENT`, `PF-SEQUENCE-MATCHES` — all 5 present. **→ SC-13, SC-14**
- [ ] 85. **Checkpoint commit (**inline**).** `git commit -m "plan-fidelity.md: update PF-6, add 5 checklist-format criteria"`

#### Phase 4 completion

- [ ] 86. **VbC (**clean-room**).** Verify SC-11, SC-12, SC-13, SC-14 all pass. Both files updated.
- [ ] 87. **Resolve models (**inline**).** Run `resolve-models` for cross-family auditors.
- [ ] 88. **Auditor 1: verification-audit (**clean-room**).** Dispatch `adversarial-audit --task verification-audit --issue 1297` with `audit_phase: post_implementation` to auditor_1. On non-clean-pass: remediate, re-run resolve-models, restart from Step 87.
- [ ] 89. **Auditor 2: verification-audit (**clean-room**).** Dispatch same to auditor_2. On non-clean-pass: remediate, re-run resolve-models, restart from Step 87. Both PASS: collect artifact paths.
- [ ] 90. **Cross-validate (**clean-room**).** Consensus check.
- [ ] 91. **Regression check (**clean-room**).** `bash .opencode/tests/test-enforcement.sh --tag plan` — pass.
- [ ] 92. **Review prep (**clean-room**).** `git-workflow review-prep`.

---

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Exit Criteria

- [ ] C1: All 5 files modified — dispatch tables removed from 3 writing-plans files, checklist format indicators in place. Both adversarial-audit files updated with new validation criteria.
- [ ] C2: No hardcoded gate sequence in plan-structure.md or create-and-validate.md.
- [ ] C3: Gate sequence and dispatch modes discovered from `implementation-pipeline/SKILL.md` at plan-creation time.
- [ ] C4: Adversarial-audit expanded into 3+ numbered steps per phase (resolve-models, auditor 1, auditor 2).
- [ ] C5: All SC-1 through SC-10 pass verification.
- [ ] C6: Plan stored at `.opencode/.issues/1297/plan.md`.
- [ ] C7: SC-11 through SC-14 pass verification — auditor files validate checklist format, not per-unit gate tables.
