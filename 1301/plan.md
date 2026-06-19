# Implementation Plan — [`.opencode#1301`](https://github.com/michael-conrad/.opencode/issues/1301) — fix create.md dispatch tables + plan-creation-pipeline

- [ ] **Goal:** Fix `create.md` still containing old dispatch table format, and build a formal plan-creation-pipeline skill with Z3-verified state transitions. Plan creation gets the same structural discipline as implementation.
- [ ] **Architecture:** Phase 1 → Phase 2 (sequential). Phase 1 fixes all existing writing-plans files. Phase 2 creates the new pipeline skill.
- [ ] **Files:**
  - `.opencode/skills/writing-plans/SKILL.md` — Phase 1
  - `.opencode/skills/writing-plans/tasks/create.md` — Phase 1
  - `.opencode/skills/writing-plans/tasks/create/plan-structure.md` — Phase 1
  - `.opencode/skills/plan-creation-pipeline/SKILL.md` — Phase 2 (new)
  - `.opencode/skills/plan-creation-pipeline/pipeline-state-machine.yaml` — Phase 2 (new)

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

---

## Phase 1 — Fix existing writing-plans files

**Concern:** Three writing-plans files still reference old dispatch table format. Fix all three in one pass.
**Files:** `writing-plans/SKILL.md`, `writing-plans/tasks/create.md`, `writing-plans/tasks/create/plan-structure.md`
**SCs:** SC-1, SC-2, SC-3, SC-4, SC-5, SC-6
**Dependencies:** None
**Entry condition:** SKILL.md missing trigger keywords. create.md has dispatch table section, "16-gate dispatch table format mandatory", "Read the dispatch tables in the plan". plan-structure.md line 260 references old format.
**Exit condition:** All three files updated. No dispatch table references remain in writing-plans task files.

**Artifact paths:** `./tmp/1301/artifacts/pipeline-{step_label}-{STATUS}-{timestamp}.yaml`

- [ ] 1. **Coherence gate (**clean-room**).** Read all three files. Verify SC-1 through SC-6 are consistent with the codebase. Capture current state of each file.
- [ ] 2. **Pre-RED baseline (**clean-room**).** Capture current line counts and all dispatch table patterns in all three files.

#### RED+green P1-I1 — Fix SKILL.md trigger keywords

- [ ] 3. **RED (**clean-room**).** Write test grepping for `"plan"` and `"draft plan"` in SKILL.md Trigger Dispatch Table row — expects present, must FAIL. **→ SC-1**
- [ ] 4. **RED doublecheck (**clean-room**).** Confirm Step 3 fails as expected.
- [ ] 5. **Post-RED enforcement (**clean-room**).** Verify FAIL artifacts.
- [ ] 6. **GREEN (**clean-room**).** Add `"plan" / "draft plan"` to Trigger Dispatch Table row in SKILL.md. **→ SC-1**
- [ ] 7. **Post-GREEN enforcement (**clean-room**).** Verify file modified.
- [ ] 8. **Structural checks (**clean-room**).** `wc -w` — under 4,000 words.
- [ ] 9. **GREEN doublecheck (**clean-room**).** grep for `"plan"` and `"draft plan"` in Trigger Dispatch Table row — both present. **→ SC-1**
- [ ] 10. **Checkpoint commit (**inline**).** `git commit -m "fix(#1301): add plan/draft plan trigger keywords to writing-plans SKILL.md"`

#### RED+green P1-I2 — Fix create.md Operating Protocol step 7

- [ ] 11. **RED (**clean-room**).** Write test grepping for `16-gate dispatch table format mandatory` in create.md — expects present, must FAIL. **→ SC-3**
- [ ] 12. **RED doublecheck (**clean-room**).** Confirm Step 11 fails.
- [ ] 13. **Post-RED enforcement (**clean-room**).** Verify FAIL artifacts.
- [ ] 14. **GREEN (**clean-room**).** Replace line 22: `"16-gate dispatch table format mandatory"` → `"Checklist format mandatory — numbered \`- [ ] N.\` steps with dispatch indicators"`. **→ SC-3**
- [ ] 15. **Post-GREEN enforcement (**clean-room**).** Verify changed.
- [ ] 16. **Structural checks (**clean-room**).** `wc -w` — under 3,000 words.
- [ ] 17. **GREEN doublecheck (**clean-room**).** grep for `16-gate` — absent. **→ SC-3**
- [ ] 18. **Checkpoint commit (**inline**).** `git commit -m "fix(#1301): fix create.md Operating Protocol step 7 to checklist format"`

#### RED+green P1-I3 — Fix create.md Orchestrator Execution Protocol

- [ ] 19. **RED (**clean-room**).** Write test grepping for `dispatch tables in the plan` in create.md — expects present, must FAIL. **→ SC-4**
- [ ] 20. **RED doublecheck (**clean-room**).** Confirm Step 19 fails.
- [ ] 21. **Post-RED enforcement (**clean-room**).** Verify FAIL artifacts.
- [ ] 22. **GREEN (**clean-room**).** Replace lines 52-61: change "Read the dispatch tables in the plan" to "Read the numbered checklist steps in the plan". Remove "Receives Context", "Sub-Agent Type", "SCs column". Keep sequential execution intent. **→ SC-4**
- [ ] 23. **Post-GREEN enforcement (**clean-room**).** Verify changed.
- [ ] 24. **Structural checks (**clean-room**).** `wc -w` — under 3,000 words.
- [ ] 25. **GREEN doublecheck (**clean-room**).** grep for `dispatch tables in the plan` — absent. **→ SC-4**
- [ ] 26. **Checkpoint commit (**inline**).** `git commit -m "fix(#1301): fix create.md Orchestrator Execution Protocol to checklist steps"`

#### RED+green P1-I4 — Replace create.md Dispatch Table section

- [ ] 27. **RED (**clean-room**).** Write test grepping for `| Gate | Dispatch Type | Blind? |` in create.md — expects present, must FAIL. **→ SC-2**
- [ ] 28. **RED doublecheck (**clean-room**).** Confirm Step 27 fails.
- [ ] 29. **Post-RED enforcement (**clean-room**).** Verify FAIL artifacts.
- [ ] 30. **GREEN (**clean-room**).** Replace lines 63-87 (Dispatch Table section) with: dispatch mode mapping (`sub-task` → `(**clean-room**)`, else → `(**inline**)`), discovery directive (read `implementation-pipeline/SKILL.md` §Dispatch Routing Table), sub-step expansion directive, output format (numbered `- [ ] N.` checklists with dispatch indicators). Keep Inter-Phase Handoff, Post-All-Phases Sweep, Concern Boundary Annotations. **→ SC-2, SC-5**
- [ ] 31. **Post-GREEN enforcement (**clean-room**).** Verify dispatch table section replaced.
- [ ] 32. **Structural checks (**clean-room**).** `wc -w` — under 3,000 words.
- [ ] 33. **GREEN doublecheck (**clean-room**).** grep for `| Gate | Dispatch Type | Blind? |` — 0 matches. grep for `clean-room`, `discovery directive`, `sub-step expansion` — all present. **→ SC-2, SC-5**
- [ ] 34. **Checkpoint commit (**inline**).** `git commit -m "fix(#1301): replace create.md Dispatch Table section with checklist format spec"`

#### RED+green P1-I5 — Fix plan-structure.md line 260

- [ ] 35. **RED (**clean-room**).** Write test grepping for `dispatch table template (Step 4)` in plan-structure.md — expects present, must FAIL. **→ SC-6**
- [ ] 36. **RED doublecheck (**clean-room**).** Confirm Step 35 fails.
- [ ] 37. **Post-RED enforcement (**clean-room**).** Verify FAIL artifacts.
- [ ] 38. **GREEN (**clean-room**).** Replace line 260: "dispatch table template (Step 4) and per-unit pipeline gate tables (Step 5)" → "checklist format (Step 4) and per-unit output format (Step 5)". **→ SC-6**
- [ ] 39. **Post-GREEN enforcement (**clean-room**).** Verify changed.
- [ ] 40. **Structural checks (**clean-room**).** `wc -w` — under 3,000 words.
- [ ] 41. **GREEN doublecheck (**clean-room**).** grep for `dispatch table template (Step 4)` — absent. **→ SC-6**
- [ ] 42. **Checkpoint commit (**inline**).** `git commit -m "fix(#1301): fix plan-structure.md stale historical note to reference checklist format"`

#### Phase 1 completion

- [ ] 11. **VbC (**clean-room**).** Verify SC-1 through SC-6 all pass.
- [ ] 12. **Resolve models (**inline**).** Run `resolve-models`.
- [ ] 13. **Auditor 1: verification-audit (**clean-room**).** Dispatch to auditor_1. On non-clean-pass: remediate, re-run resolve-models, restart from Step 12.
- [ ] 14. **Auditor 2: verification-audit (**clean-room**).** Dispatch to auditor_2. On non-clean-pass: remediate, re-run resolve-models, restart from Step 12. Both PASS: collect artifact paths.
- [ ] 15. **Cross-validate (**clean-room**).** Consensus check.
- [ ] 16. **Regression check (**clean-room**).** `bash .opencode/tests/test-enforcement.sh --tag plan` — pass.
- [ ] 17. **Review prep (**clean-room**).** `git-workflow review-prep`.

**Concern transition:** Leaving writing-plans fixes → entering new skill creation. Phase 2 creates the plan-creation-pipeline.

---

## Phase 2 — Create plan-creation-pipeline skill

**Concern:** New skill — formal pipeline for plan creation with Z3-verified state transitions
**Files:** `plan-creation-pipeline/SKILL.md`, `plan-creation-pipeline/pipeline-state-machine.yaml`
**SCs:** SC-7, SC-8, SC-9, SC-10, SC-11, SC-12
**Dependencies:** Phase 1 complete (pipeline references the fixed create.md)
**Entry condition:** No plan-creation-pipeline directory exists
**Exit condition:** SKILL.md with Trigger Dispatch Table, Dispatch Routing Table (6 steps), state machine. pipeline-state-machine.yaml with Z3-verified transitions.

**Artifact paths:** `./tmp/1301/artifacts/pipeline-{step_label}-{STATUS}-{timestamp}.yaml`

- [ ] 18. **Coherence gate (**clean-room**).** Verify SC-7 through SC-12 consistent with spec.
- [ ] 19. **Pre-RED baseline (**clean-room**).** Confirm no plan-creation-pipeline directory exists.

#### RED+green — Create SKILL.md

- [ ] 20. **RED (**clean-room**).** Write test verifying plan-creation-pipeline SKILL.md does not exist — expects absent, must FAIL. **→ SC-7**
- [ ] 21. **RED doublecheck (**clean-room**).** Confirm fails.
- [ ] 22. **Post-RED enforcement (**clean-room**).** Verify FAIL artifacts.
- [ ] 23. **GREEN (**clean-room**).** Create `plan-creation-pipeline/SKILL.md` with:
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
- [ ] 24. **Post-GREEN enforcement (**clean-room**).** Verify file exists.
- [ ] 25. **Structural checks (**clean-room**).** `wc -w` — under 4,000 words.
- [ ] 26. **GREEN doublecheck (**clean-room**).** grep for all 6 step labels — all present. grep for `local-issues sync` — present. grep for `push`, `URL`, `comment`, `cascade` — absent from plan-completion. grep for `exec summary`, `blob`, `byline` — present. **→ SC-8, SC-10, SC-11**

#### RED+green — Create pipeline-state-machine.yaml

- [ ] 27. **RED (**clean-room**).** Write test verifying pipeline-state-machine.yaml does not exist — expects absent, must FAIL. **→ SC-9**
- [ ] 28. **RED doublecheck (**clean-room**).** Confirm fails.
- [ ] 29. **Post-RED enforcement (**clean-room**).** Verify FAIL artifacts.
- [ ] 30. **GREEN (**clean-room**).** Create `pipeline-state-machine.yaml` with:
  - Variables: `current_step` (domain: all 6 step labels), `previous_step` (domain: init + all 6 step labels), `pipeline_state` (domain: init, running, complete, failed)
  - Preconditions enforcing serial ordering: `init → handoff → create → solve-model → solve-check → plan-plan → completion`
  - Postconditions: completion at `plan-completion`, no self-transitions, state transitions to `running` after init
  - SPDX headers, provenance, AI byline
  **→ SC-9**
- [ ] 31. **Post-GREEN enforcement (**clean-room**).** Verify file exists.
- [ ] 32. **Structural checks (**clean-room**).** `python3 -c "import yaml; yaml.safe_load(open('.opencode/skills/plan-creation-pipeline/pipeline-state-machine.yaml'))"`.
- [ ] 33. **GREEN doublecheck (**clean-room**).** grep for all 6 step labels in domain — all present. **→ SC-9**

#### Verification — implementation-pipeline has no plan-creation steps

- [ ] 34. **Verify (**clean-room**).** grep for `plan-creation` in implementation-pipeline SKILL.md — must be absent. **→ SC-12**
- [ ] 35. **Checkpoint commit (**inline**).** `git commit -m "feat(#1301): create plan-creation-pipeline skill with 6-step pipeline and Z3 state machine"`

#### Phase 2 completion

- [ ] 38. **VbC (**clean-room**).** Verify SC-7 through SC-12 all pass.
- [ ] 39. **Resolve models (**inline**).** Run `resolve-models`.
- [ ] 40. **Auditor 1: verification-audit (**clean-room**).** Dispatch to auditor_1. On non-clean-pass: remediate, re-run resolve-models, restart from Step 39.
- [ ] 41. **Auditor 2: verification-audit (**clean-room**).** Dispatch to auditor_2. On non-clean-pass: remediate, re-run resolve-models, restart from Step 39. Both PASS: collect artifact paths.
- [ ] 42. **Cross-validate (**clean-room**).** Consensus check.
- [ ] 43. **Regression check (**clean-room**).** `bash .opencode/tests/test-enforcement.sh --tag plan` — pass.
- [ ] 44. **Review prep (**clean-room**).** `git-workflow review-prep`.

---

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Exit Criteria

- [ ] C1: All 5 files modified/created — SKILL.md trigger keywords fixed, create.md dispatch tables removed, plan-structure.md historical note fixed, plan-creation-pipeline skill created with SKILL.md and state machine.
- [ ] C2: No dispatch table references remain in writing-plans task files.
- [ ] C3: Plan creation has a formal 6-step pipeline with Z3-verified transitions.
- [ ] C4: plan-completion uses `local-issues sync` — no push, no URL, no comment, no approval cascade.
- [ ] C5: All SC-1 through SC-12 pass verification.
- [ ] C6: Plan stored at `.opencode/.issues/1301/plan.md`.
