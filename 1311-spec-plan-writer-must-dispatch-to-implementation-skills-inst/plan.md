# Plan — Plan Writer Must Dispatch to Implementation Skills Instead of Emitting Inline Prose

**Spec:** [michael-conrad/.opencode#1311](https://github.com/michael-conrad/.opencode/issues/1311)
**Goal:** Replace the plan writer's `(**clean-room**)`/`(**inline**)` two-mode dispatch with skill-name dispatch markers, phase-to-skill mapping at plan-creation time, and mandatory pipeline gates in post-RED sections.
**Architecture:** 4-phase sequential: format change → mapping generation → gate coverage → template updates.
**Tech Stack:** Markdown (skill task files).

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Dependency Order

**Phase 1 → Phase 2 → Phase 3 → Phase 4.** Sequential — each phase builds on the previous. Phase 1 establishes the new dispatch format. Phase 2 adds mapping generation. Phase 3 adds the gate template. Phase 4 updates templates and validation rules.

## SC-ID Mapping

| SC-ID | Plan Phase | TDD Item | Evidence Type |
|-------|-----------|----------|---------------|
| SC-1 | Phase 1 | TDD-1 | `string + behavioral` |
| SC-2 | Phase 1 | TDD-2 | `behavioral` |
| SC-3 | Phase 1 | TDD-3 | `behavioral` |
| SC-4 | Phase 2 | TDD-4 | `string` |
| SC-5 | Phase 2 | TDD-5 | `behavioral` |
| SC-6 | Phase 2 | TDD-6 | `string` |
| SC-7 | Phase 3 | TDD-7 | `string` |
| SC-8 | Phase 3 | TDD-8 | `string` |
| SC-9 | Phase 3 | TDD-9 | `string` |
| SC-10 | Phase 4 | TDD-10 | `behavioral` |
| SC-11 | Phase 4 | TDD-11 | `string` |
| SC-12 | Phase 4 | TDD-12 | `string` |

---

## Phase 1: Dispatch Format Change

**Concern:** Update format templates and validation in plan-writer task files to require skill-name dispatch markers.
**Files:** `tasks/create/create-and-validate.md`, `tasks/create/plan-structure.md`, `tasks/create.md`
**SCs covered:** SC-1, SC-2, SC-3

### Pre-RED Common

- [ ] 1. Read approved spec — `skill-creator` for task file update (**inline**). Read spec at [michael-conrad/.opencode#1311](https://github.com/michael-conrad/.opencode/issues/1311) Phase 1 SCs. Confirm all 3 SCs before implementation. → SC-1, SC-2, SC-3
- [ ] 2. Read target files — `skill-creator` for task file update (**inline**). Read the format template in `create-and-validate.md` §Phase body requirements and the output format spec in `plan-structure.md` Step 5. Confirm current bare `(**clean-room**)` pattern exists for RED-phase evidence. → SC-1

### Per-Item RED+green Chains

- [ ] 3. TDD-1: Update dispatch format template in `create-and-validate.md` — `skill-creator` for task file update (SC-1)
  - [ ] 3a. RED: Format template uses bare `(**<clean-room|inline>**)` with no skill name — `test-driven-development` for behavioral test (**clean-room**). → SC-1
  - [ ] 3b. GREEN: Update format template to require `<skill-name>` in dispatch marker — `skill-creator` for task file update (**clean-room**). → SC-1

- [ ] 4. TDD-2: Prohibit implementation prose in clean-room step bodies — `skill-creator` for task file update (SC-2)
  - [ ] 4a. RED: Plan step body contains inline implementation prose instead of dispatch target — `test-driven-development` for behavioral test (**clean-room**). → SC-2
  - [ ] 4b. GREEN: Update output format spec to require dispatch-target-only prose — `skill-creator` for task file update (**clean-room**). → SC-2

- [ ] 5. TDD-3: Update output format in `plan-structure.md` Step 5 — `skill-creator` for task file update (SC-1, SC-12)
  - [ ] 5a. RED: Per-unit output format lacks skill name — `test-driven-development` for behavioral test (**clean-room**). → SC-1, SC-12
  - [ ] 5b. GREEN: Update per-unit output format to include `<skill-name>` and `→ dispatch` instruction — `skill-creator` for task file update (**clean-room**). → SC-1, SC-12

### Post-RED/green

- [ ] 6. COMPLETENESS GATE — `completeness-gate` (**clean-room**). Verify all 3 Phase 1 SCs have TDD items with RED/GREEN separation. → SC-all
- [ ] 7. ADVERSARIAL AUDIT — `adversarial-audit` (**orchestrator**). resolve-models → auditor 1 (spec-audit) → remediate → auditor 2 (spec-audit) → cross-validate. → SC-all
- [ ] 8. EXEC SUMMARY — `completion-core` (**clean-room**). Push, URL extraction, phase-complete issue comment, byline. → SC-all

---

## Phase 2: Concern-to-Skill Mapping at Plan-Creation Time

**Concern:** Add phase-to-skill-mapping.yaml generation to plan-structure sub-agent.
**Files:** `tasks/create/plan-structure.md`
**SCs covered:** SC-4, SC-5, SC-6

### Pre-RED Common

- [ ] 1. Read approved spec — `skill-creator` for task file update (**inline**). Read spec Phase 2 SCs. Confirm all 3 SCs. → SC-4, SC-5, SC-6
- [ ] 2. Read target file — `skill-creator` for task file update (**inline**). Read `plan-structure.md` Step 3.3 (phase dependency solve contract) and Step 2 (file structure mapping). Identify where to insert mapping generation step. → SC-4

### Per-Item RED+green Chains

- [ ] 3. TDD-4: Add mapping generation step to plan-structure — `skill-creator` for task file update (SC-4)
  - [ ] 3a. RED: No `phase-to-skill-mapping.yaml` artifact produced by plan-structure — `test-driven-development` for behavioral test (**clean-room**). → SC-4
  - [ ] 3b. GREEN: Add mapping generation step to `plan-structure.md` procedure — `skill-creator` for task file update (**clean-room**). Step reads Dispatch Routing Table, builds mapping, writes artifact. → SC-4

- [ ] 4. TDD-5: Mapping covers all concern types per Dispatch Routing Table — `skill-creator` for task file update (SC-5)
  - [ ] 4a. RED: Plan with mixed concerns produces bare `(**clean-room**)` without skill name — `test-driven-development` for behavioral test (**clean-room**). → SC-5
  - [ ] 4b. GREEN: Ensure mapping generation step covers all concern types in the spec's phases — `skill-creator` for task file update (**clean-room**). → SC-5

- [ ] 5. TDD-6: Mapping includes engineering-approach for code-implementation concerns — `skill-creator` for task file update (SC-6)
  - [ ] 5a. RED: Mapping file lacks `engineering-approach` for code concerns — `test-driven-development` for behavioral test (**clean-room**). → SC-6
  - [ ] 5b. GREEN: Ensure mapping generation includes `engineering-approach` for any code-implementation concern — `skill-creator` for task file update (**clean-room**). → SC-6

### Post-RED/green

- [ ] 6. COMPLETENESS GATE — `completeness-gate` (**clean-room**). Verify all 3 Phase 2 SCs covered. → SC-all
- [ ] 7. ADVERSARIAL AUDIT — `adversarial-audit` (**orchestrator**). resolve-models → auditor 1 (plan-fidelity) → remediate → auditor 2 (plan-fidelity) → cross-validate. → SC-all
- [ ] 8. EXEC SUMMARY — `completion-core` (**clean-room**). Push, URL extraction, phase-complete issue comment, byline. → SC-all

---

## Phase 3: Post-RED/green Pipeline Gate Coverage

**Concern:** Add mandatory adversarial-audit, completeness-gate, and completion-core to post-RED template.
**Files:** `tasks/create/create-and-validate.md`, `tasks/create/plan-structure.md`
**SCs covered:** SC-7, SC-8, SC-9

### Pre-RED Common

- [ ] 1. Read approved spec — `skill-creator` for task file update (**inline**). Read spec Phase 3 SCs. Confirm all 3 SCs. → SC-7, SC-8, SC-9

### Per-Item RED+green Chains

- [ ] 2. TDD-7: Add adversarial-audit step to post-RED template — `skill-creator` for task file update (SC-7)
  - [ ] 2a. RED: Post-RED section lacks adversarial-audit step — `test-driven-development` for behavioral test (**clean-room**). → SC-7
  - [ ] 2b. GREEN: Add adversarial-audit step with expanded multi-dispatch format to post-RED template — `skill-creator` for task file update (**clean-room**). → SC-7

- [ ] 3. TDD-8: Add completeness-gate bridge to post-RED template — `skill-creator` for task file update (SC-8)
  - [ ] 3a. RED: Post-RED section lacks completeness-gate step — `test-driven-development` for behavioral test (**clean-room**). → SC-8
  - [ ] 3b. GREEN: Add completeness-gate step between last GREEN and adversarial audit — `skill-creator` for task file update (**clean-room**). → SC-8

- [ ] 4. TDD-9: Add completion-core exec summary to post-RED template — `skill-creator` for task file update (SC-9)
  - [ ] 4a. RED: Post-RED section lacks completion-core step — `test-driven-development` for behavioral test (**clean-room**). → SC-9
  - [ ] 4b. GREEN: Add completion-core step to end of post-RED template — `skill-creator` for task file update (**clean-room**). → SC-9

### Post-RED/green

- [ ] 5. COMPLETENESS GATE — `completeness-gate` (**clean-room**). Verify all 3 Phase 3 SCs covered. → SC-all
- [ ] 6. ADVERSARIAL AUDIT — `adversarial-audit` (**orchestrator**). resolve-models → auditor 1 (verification-audit) → remediate → auditor 2 (verification-audit) → cross-validate. → SC-all
- [ ] 7. EXEC SUMMARY — `completion-core` (**clean-room**). Push, URL extraction, phase-complete issue comment, byline. → SC-all

---

## Phase 4: Plan Format Template Updates

**Concern:** Add skill-name existence validation rule and sync all format templates.
**Files:** `tasks/create/create-and-validate.md`, `tasks/create/plan-structure.md`
**SCs covered:** SC-10, SC-11, SC-12

### Pre-RED Common

- [ ] 1. Read approved spec — `skill-creator` for task file update (**inline**). Read spec Phase 4 SCs. Confirm all 3 SCs. → SC-10, SC-11, SC-12
- [ ] 2. Read target files — `skill-creator` for task file update (**inline**). Read `create-and-validate.md` Step 10 validation rules and `plan-structure.md` Step 5 per-unit output format. → SC-10, SC-12

### Per-Item RED+green Chains

- [ ] 3. TDD-10: Add skill-name existence validation to Step 10 — `skill-creator` for task file update (SC-10)
  - [ ] 3a. RED: Validation passes plan with non-existent skill name — `test-driven-development` for behavioral test (**clean-room**). → SC-10
  - [ ] 3b. GREEN: Add rule 9 to Step 10 validation rule set — `skill-creator` for task file update (**clean-room**). Check `.opencode/skills/<name>` exists. HALT with `SKILL_NOT_FOUND`. → SC-10

- [ ] 4. TDD-11: Update Phase body requirements template — `skill-creator` for task file update (SC-11)
  - [ ] 4a. RED: Phase body format template still uses bare `(**<clean-room|inline>**)` — `test-driven-development` for behavioral test (**clean-room**). → SC-11
  - [ ] 4b. GREEN: Update template to require skill name and dispatch directive — `skill-creator` for task file update (**clean-room**). → SC-11

- [ ] 5. TDD-12: Update per-unit output format — `skill-creator` for task file update (SC-12)
  - [ ] 5a. RED: Per-unit output format lacks skill name — `test-driven-development` for behavioral test (**clean-room**). → SC-12
  - [ ] 5b. GREEN: Update Step 5 output format to include `<skill-name>` and dispatch instruction — `skill-creator` for task file update (**clean-room**). → SC-12

### Post-RED/green

- [ ] 6. COMPLETENESS GATE — `completeness-gate` (**clean-room**). Verify all 3 Phase 4 SCs covered. → SC-all
- [ ] 7. ADVERSARIAL AUDIT — `adversarial-audit` (**orchestrator**). resolve-models → auditor 1 (spec-audit) → remediate → auditor 2 (spec-audit) → cross-validate. → SC-all
- [ ] 8. EXEC SUMMARY — `completion-core` (**clean-room**). Push, URL extraction, issue comment (PR created, close issue), byline. → SC-all

---

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

**Plan:** See [plan.md](.opencode/.issues/1311-spec-plan-writer-must-dispatch-to-implementation-skills-inst/plan.md) for the implementation plan.