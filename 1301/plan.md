# Implementation Plan — [`.opencode#1301`](https://github.com/michael-conrad/.opencode/issues/1301) — fix create.md dispatch tables + plan-creation-pipeline

- [ ] **Goal:** Fix `create.md` still containing old dispatch table format, and build a formal plan-creation-pipeline skill with Z3-verified state transitions. Plan creation gets the same structural discipline as implementation.
- [ ] **Architecture:** Phase 1 → Phase 2 → Phase 3 → Phase 4 (sequential). Phase 2 depends on Phase 1 (create.md is the entry point). Phase 4 depends on Phase 2 (pipeline references the fixed create.md).
- [ ] **Files:**
  - `.opencode/skills/writing-plans/SKILL.md` — Phase 1
  - `.opencode/skills/writing-plans/tasks/create.md` — Phase 2
  - `.opencode/skills/writing-plans/tasks/create/plan-structure.md` — Phase 3
  - `.opencode/skills/plan-creation-pipeline/SKILL.md` — Phase 4 (new)
  - `.opencode/skills/plan-creation-pipeline/pipeline-state-machine.yaml` — Phase 4 (new)

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

---

## Phase 1 — Fix writing-plans SKILL.md trigger keywords

**Concern:** Skill card — Trigger Dispatch Table missing keywords
**File:** `.opencode/skills/writing-plans/SKILL.md`
**SCs:** SC-1
**Dependencies:** None
**Entry condition:** Trigger Dispatch Table has `"create plan" / "implementation plan" / "write plan"` only
**Exit condition:** Trigger Dispatch Table also has `"plan" / "draft plan"`

**Artifact paths:** `./tmp/1301/artifacts/pipeline-{step_label}-{STATUS}-{timestamp}.yaml`

- [ ] 1. **Coherence gate (**clean-room**).** Verify SC-1 consistent with codebase. Check current SKILL.md Trigger Dispatch Table.
- [ ] 2. **Pre-RED baseline (**clean-room**).** Capture current Trigger Dispatch Table row — only 3 keywords.

#### RED+green P1-I1 — Add trigger keywords

- [ ] 3. **RED (**clean-room**).** Write test grepping for `"plan"` and `"draft plan"` in Trigger Dispatch Table row — expects present, must FAIL. **→ SC-1**
- [ ] 4. **RED doublecheck (**clean-room**).** Confirm Step 3 fails as expected.
- [ ] 5. **Post-RED enforcement (**clean-room**).** Verify FAIL artifacts.
- [ ] 6. **GREEN (**clean-room**).** Update line 21: change `"create plan" / "implementation plan" / "write plan"` to `"create plan" / "implementation plan" / "write plan" / "plan" / "draft plan"`. **→ SC-1**
- [ ] 7. **Post-GREEN enforcement (**clean-room**).** Verify file was modified.
- [ ] 8. **Structural checks (**clean-room**).** `wc -w` — under 4,000 words.
- [ ] 9. **GREEN doublecheck (**clean-room**).** grep for `"plan"` and `"draft plan"` in Trigger Dispatch Table row — both present. **→ SC-1**
- [ ] 10. **Checkpoint commit (**inline**).** `git commit -m "writing-plans SKILL.md: add plan/draft plan trigger keywords"`

#### Phase 1 completion

- [ ] 11. **VbC (**clean-room**).** Verify SC-1 passes.
- [ ] 12. **Resolve models (**inline**).** Run `.opencode/tools/resolve-models`.
- [ ] 13. **Auditor 1: verification-audit (**clean-room**).** Dispatch to auditor_1. On non-clean-pass: remediate, re-run resolve-models, restart from Step 12.
- [ ] 14. **Auditor 2: verification-audit (**clean-room**).** Dispatch to auditor_2. On non-clean-pass: remediate, re-run resolve-models, restart from Step 12. Both PASS: collect artifact paths.
- [ ] 15. **Cross-validate (**clean-room**).** Consensus check.
- [ ] 16. **Regression check (**clean-room**).** `bash .opencode/tests/test-enforcement.sh --tag plan` — pass.
- [ ] 17. **Review prep (**clean-room**).** `git-workflow review-prep`.

**Concern transition:** Leaving SKILL.md → entering create.md. Phase 2 fixes the entry-point task file.

---

## Phase 2 — Fix create.md

**Concern:** Task file — dispatch table section, Operating Protocol step 7, Orchestrator Execution Protocol
**File:** `.opencode/skills/writing-plans/tasks/create.md`
**SCs:** SC-2, SC-3, SC-4, SC-5
**Dependencies:** None
**Entry condition:** create.md has dispatch table section (lines 63-87), "16-gate dispatch table format mandatory" at line 22, "Read the dispatch tables in the plan" at line 52
**Exit condition:** Dispatch table section replaced with checklist format spec. Operating Protocol step 7 references checklist format. Orchestrator Execution Protocol references checklist steps.

**Artifact paths:** `./tmp/1301/artifacts/pipeline-{step_label}-{STATUS}-{timestamp}.yaml`

- [ ] 18. **Coherence gate (**clean-room**).** Verify SC-2, SC-3, SC-4, SC-5 consistent with codebase.
- [ ] 19. **Pre-RED baseline (**clean-room**).** Capture current line count and all sections containing `| Gate |` or `Dispatch Table` patterns.

#### RED+green P2-I1 — Fix Operating Protocol step 7

- [ ] 20. **RED (**clean-room**).** Write test grepping for `16-gate dispatch table format mandatory` — expects present, must FAIL. **→ SC-3**
- [ ] 21. **RED doublecheck (**clean-room**).** Confirm fails.
- [ ] 22. **Post-RED enforcement (**clean-room**).** Verify FAIL artifacts.
- [ ] 23. **GREEN (**clean-room**).** Replace line 22: `"16-gate dispatch table format mandatory"` → `"Checklist format mandatory — numbered \`- [ ] N.\` steps with dispatch indicators"`. **→ SC-3**
- [ ] 24. **Post-GREEN enforcement (**clean-room**).** Verify changed.
- [ ] 25. **Structural checks (**clean-room**).** `wc -w` — under 3,000 words.
- [ ] 26. **GREEN doublecheck (**clean-room**).** grep for `16-gate` — absent. **→ SC-3**
- [ ] 27. **Checkpoint commit (**inline**).** `git commit -m "create.md: fix Operating Protocol step 7 to checklist format"`

#### RED+green P2-I2 — Fix Orchestrator Execution Protocol

- [ ] 28. **RED (**clean-room**).** Write test grepping for `dispatch tables in the plan` — expects present, must FAIL. **→ SC-4**
- [ ] 29. **RED doublecheck (**clean-room**).** Confirm fails.
- [ ] 30. **Post-RED enforcement (**clean-room**).** Verify FAIL artifacts.
- [ ] 31. **GREEN (**clean-room**).** Replace lines 52-61: change "Read the dispatch tables in the plan" to "Read the numbered checklist steps in the plan". Remove references to "Receives Context", "Sub-Agent Type", "SCs column". Keep the sequential execution intent (execute every step in order, do not skip, do not reorder). **→ SC-4**
- [ ] 32. **Post-GREEN enforcement (**clean-room**).** Verify changed.
- [ ] 33. **Structural checks (**clean-room**).** `wc -w` — under 3,000 words.
- [ ] 34. **GREEN doublecheck (**clean-room**).** grep for `dispatch tables in the plan` — absent. **→ SC-4**
- [ ] 35. **Checkpoint commit (**inline**).** `git commit -m "create.md: fix Orchestrator Execution Protocol to checklist steps"`

#### RED+green P2-I3 — Replace Dispatch Table section

- [ ] 36. **RED (**clean-room**).** Write test grepping for `| Gate | Dispatch Type | Blind? |` — expects present, must FAIL. **→ SC-2**
- [ ] 37. **RED doublecheck (**clean-room**).** Confirm fails.
- [ ] 38. **Post-RED enforcement (**clean-room**).** Verify FAIL artifacts.
- [ ] 39. **GREEN (**clean-room**).** Replace lines 63-87 (Dispatch Table section) with:
  - Dispatch mode mapping: `sub-task` → `(**clean-room**)`, everything else → `(**inline**)`
  - Discovery directive: read `implementation-pipeline/SKILL.md` §Dispatch Routing Table for gate sequence
  - Sub-step expansion directive: gates with sub-steps expand into multiple `- [ ] N.` entries
  - Output format: numbered `- [ ] N.` checklists with dispatch indicators
  - Keep Inter-Phase Handoff, Post-All-Phases Sweep, Concern Boundary Annotations (format-agnostic)
  **→ SC-2, SC-5**
- [ ] 40. **Post-GREEN enforcement (**clean-room**).** Verify dispatch table section replaced.
- [ ] 41. **Structural checks (**clean-room**).** `wc -w` — under 3,000 words.
- [ ] 42. **GREEN doublecheck (**clean-room**).** grep for `| Gate | Dispatch Type | Blind? |` — 0 matches. grep for `clean-room`, `discovery directive`, `sub-step expansion` — all present. **→ SC-2, SC-5**
- [ ] 43. **Checkpoint commit (**inline**).** `git commit -m "create.md: replace Dispatch Table section with checklist format spec"`

#### Phase 2 completion

- [ ] 44. **VbC (**clean-room**).** Verify SC-2, SC-3, SC-4, SC-5 pass.
- [ ] 45. **Resolve models (**inline**).** Run `resolve-models`.
- [ ] 46. **Auditor 1: verification-audit (**clean-room**).** Dispatch to auditor_1. On non-clean-pass: remediate, re-run resolve-models, restart from Step 45.
- [ ] 47. **Auditor 2: verification-audit (**clean-room**).** Dispatch to auditor_2. On non-clean-pass: remediate, re-run resolve-models, restart from Step 45. Both PASS: collect artifact paths.
- [ ] 48. **Cross-validate (**clean-room**).** Consensus check.
- [ ] 49. **Regression check (**clean-room**).** `bash .opencode/tests/test-enforcement.sh --tag plan` — pass.
- [ ] 50. **Review prep (**clean-room**).** `git-workflow review-prep`.

**Concern transition:** Leaving create.md → entering plan-structure.md. Phase 3 fixes the stale historical note.

---

## Phase 3 — Fix plan-structure.md line 260

**Concern:** Task file — stale historical note referencing old dispatch table format
**File:** `.opencode/skills/writing-plans/tasks/create/plan-structure.md`
**SCs:** SC-6
**Dependencies:** None
**Entry condition:** Line 260 says "The dispatch table template (Step 4) and per-unit pipeline gate tables (Step 5) provide sufficient execution guidance"
**Exit condition:** Line 260 references new checklist format

**Artifact paths:** `./tmp/1301/artifacts/pipeline-{step_label}-{STATUS}-{timestamp}.yaml`

- [ ] 51. **Coherence gate (**clean-room**).** Verify SC-6 consistent with codebase.
- [ ] 52. **Pre-RED baseline (**clean-room**).** Capture current line 260 text.

#### RED+green P3-I1 — Fix historical note

- [ ] 53. **RED (**clean-room**).** Write test grepping for `dispatch table template (Step 4)` — expects present, must FAIL. **→ SC-6**
- [ ] 54. **RED doublecheck (**clean-room**).** Confirm fails.
- [ ] 55. **Post-RED enforcement (**clean-room**).** Verify FAIL artifacts.
- [ ] 56. **GREEN (**clean-room**).** Replace line 260: change "The dispatch table template (Step 4) and per-unit pipeline gate tables (Step 5) provide sufficient execution guidance" to "The checklist format (Step 4) and per-unit output format (Step 5) provide sufficient execution guidance". **→ SC-6**
- [ ] 57. **Post-GREEN enforcement (**clean-room**).** Verify changed.
- [ ] 58. **Structural checks (**clean-room**).** `wc -w` — under 3,000 words.
- [ ] 59. **GREEN doublecheck (**clean-room**).** grep for `dispatch table template (Step 4)` — absent. **→ SC-6**
- [ ] 60. **Checkpoint commit (**inline**).** `git commit -m "plan-structure.md: fix stale historical note to reference checklist format"`

#### Phase 3 completion

- [ ] 61. **VbC (**clean-room**).** Verify SC-6 passes.
- [ ] 62. **Resolve models (**inline**).** Run `resolve-models`.
- [ ] 63. **Auditor 1: verification-audit (**clean-room**).** Dispatch to auditor_1. On non-clean-pass: remediate, re-run resolve-models, restart from Step 62.
- [ ] 64. **Auditor 2: verification-audit (**clean-room**).** Dispatch to auditor_2. On non-clean-pass: remediate, re-run resolve-models, restart from Step 62. Both PASS: collect artifact paths.
- [ ] 65. **Cross-validate (**clean-room**).** Consensus check.
- [ ] 66. **Regression check (**clean-room**).** `bash .opencode/tests/test-enforcement.sh --tag plan` — pass.
- [ ] 67. **Review prep (**clean-room**).** `git-workflow review-prep`.

**Concern transition:** Leaving plan-structure.md → entering new skill creation. Phase 4 creates the plan-creation-pipeline skill.

---

## Phase 4 — Create plan-creation-pipeline skill

**Concern:** New skill — formal pipeline for plan creation with Z3-verified state transitions
**Files:** `.opencode/skills/plan-creation-pipeline/SKILL.md`, `.opencode/skills/plan-creation-pipeline/pipeline-state-machine.yaml`
**SCs:** SC-7, SC-8, SC-9, SC-10, SC-11, SC-12
**Dependencies:** Phase 2 complete (pipeline references the fixed create.md)
**Entry condition:** No plan-creation-pipeline skill exists
**Exit condition:** SKILL.md with Trigger Dispatch Table, Dispatch Routing Table (6 steps), state machine. pipeline-state-machine.yaml with Z3-verified transitions.

**Artifact paths:** `./tmp/1301/artifacts/pipeline-{step_label}-{STATUS}-{timestamp}.yaml`

- [ ] 68. **Coherence gate (**clean-room**).** Verify SC-7, SC-8, SC-9, SC-10, SC-11, SC-12 consistent with spec.
- [ ] 69. **Pre-RED baseline (**clean-room**).** Confirm no plan-creation-pipeline directory exists.

#### RED+green P4-I1 — Create SKILL.md

- [ ] 70. **RED (**clean-room**).** Write test verifying plan-creation-pipeline SKILL.md does not exist — expects absent, must FAIL. **→ SC-7**
- [ ] 71. **RED doublecheck (**clean-room**).** Confirm fails.
- [ ] 72. **Post-RED enforcement (**clean-room**).** Verify FAIL artifacts.
- [ ] 73. **GREEN (**clean-room**).** Create `.opencode/skills/plan-creation-pipeline/SKILL.md` with:
  - Trigger Dispatch Table: `"plan-creation" / "create plan pipeline"` → dispatches to plan-creation pipeline
  - Dispatch Routing Table with 6 steps:
    - `spec-to-plan-handoff` → `approval-gate --task verify-authorization` → handoff artifact
    - `plan-create` → `writing-plans --task create` → plan artifact at `.issues/{N}/plan.md`
    - `solve-model` → `solve model` → dependency-ordering constraints contract
    - `solve-check` → `solve check` → SAT verification
    - `plan-plan` → `plan plan` → phase solvability validation
    - `plan-completion` → `local-issues sync` → commits plan to `.issues/` worktree. Then produce chat output: detailed and formatted exec summary + URL to blob for spec folder on remote API (if remote API exists) + AI byline. No push, no issue comment, no approval cascade.
  - State machine with Z3-verified transitions between steps
  - Artifact path convention: `./tmp/{issue-N}/artifacts/plan-pipeline-{step_label}-{STATUS}-{timestamp}.yaml`
  - SPDX headers, provenance, AI byline
  **→ SC-7, SC-8, SC-10, SC-11**
- [ ] 74. **Post-GREEN enforcement (**clean-room**).** Verify file exists.
- [ ] 75. **Structural checks (**clean-room**).** `wc -w` — under 4,000 words.
- [ ] 76. **GREEN doublecheck (**clean-room**).** grep for all 6 step labels — all present. grep for `local-issues sync` — present. grep for `push`, `URL`, `comment`, `cascade` — absent from plan-completion. grep for `exec summary`, `blob`, `byline` — present. **→ SC-8, SC-10, SC-11**
- [ ] 77. **Checkpoint commit (**inline**).** `git commit -m "plan-creation-pipeline: create SKILL.md with 6-step pipeline"`

#### RED+green P4-I2 — Create pipeline-state-machine.yaml

- [ ] 78. **RED (**clean-room**).** Write test verifying pipeline-state-machine.yaml does not exist — expects absent, must FAIL. **→ SC-9**
- [ ] 79. **RED doublecheck (**clean-room**).** Confirm fails.
- [ ] 80. **Post-RED enforcement (**clean-room**).** Verify FAIL artifacts.
- [ ] 81. **GREEN (**clean-room**).** Create `pipeline-state-machine.yaml` with:
  - Variables: `current_step` (domain: all 6 step labels), `previous_step` (domain: init + all 6 step labels), `pipeline_state` (domain: init, running, complete, failed)
  - Preconditions enforcing serial ordering: `init → handoff → create → solve-model → solve-check → plan-plan → completion`
  - Postconditions: completion at `plan-completion`, no self-transitions, state transitions to `running` after init
  - SPDX headers, provenance, AI byline
  **→ SC-9**
- [ ] 82. **Post-GREEN enforcement (**clean-room**).** Verify file exists.
- [ ] 83. **Structural checks (**clean-room**).** `python3 -c "import yaml; yaml.safe_load(open('.opencode/skills/plan-creation-pipeline/pipeline-state-machine.yaml'))"`.
- [ ] 84. **GREEN doublecheck (**clean-room**).** grep for all 6 step labels in domain — all present. **→ SC-9**
- [ ] 85. **Checkpoint commit (**inline**).** `git commit -m "plan-creation-pipeline: create pipeline-state-machine.yaml with Z3 transitions"`

#### RED+green P4-I3 — Verify implementation-pipeline has no plan-creation steps

- [ ] 86. **RED (**clean-room**).** Write test grepping for `plan-creation` in implementation-pipeline SKILL.md — expects absent, must PASS (already absent). **→ SC-12**
- [ ] 87. **RED doublecheck (**clean-room**).** Confirm passes (no RED needed — this is a verification-only item).
- [ ] 88. **GREEN (**clean-room**).** No changes needed — verify implementation-pipeline has no plan-creation references. **→ SC-12**
- [ ] 89. **GREEN doublecheck (**clean-room**).** grep for `plan-creation` in implementation-pipeline — absent. **→ SC-12**

#### Phase 4 completion

- [ ] 90. **VbC (**clean-room**).** Verify SC-7, SC-8, SC-9, SC-10, SC-11, SC-12 all pass.
- [ ] 91. **Resolve models (**inline**).** Run `resolve-models`.
- [ ] 92. **Auditor 1: verification-audit (**clean-room**).** Dispatch to auditor_1. On non-clean-pass: remediate, re-run resolve-models, restart from Step 91.
- [ ] 93. **Auditor 2: verification-audit (**clean-room**).** Dispatch to auditor_2. On non-clean-pass: remediate, re-run resolve-models, restart from Step 91. Both PASS: collect artifact paths.
- [ ] 94. **Cross-validate (**clean-room**).** Consensus check.
- [ ] 95. **Regression check (**clean-room**).** `bash .opencode/tests/test-enforcement.sh --tag plan` — pass.
- [ ] 96. **Review prep (**clean-room**).** `git-workflow review-prep`.

---

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Exit Criteria

- [ ] C1: All 5 files modified/created — SKILL.md trigger keywords fixed, create.md dispatch tables removed, plan-structure.md historical note fixed, plan-creation-pipeline skill created with SKILL.md and state machine.
- [ ] C2: No dispatch table references remain in writing-plans task files.
- [ ] C3: Plan creation has a formal 6-step pipeline with Z3-verified transitions.
- [ ] C4: plan-completion uses `local-issues sync` — no push, no URL, no comment, no approval cascade.
- [ ] C5: All SC-1 through SC-12 pass verification.
- [ ] C6: Plan stored at `.opencode/.issues/1301/plan.md`.
