# Implementation Plan — #1311

**Goal:** Update the writing-plans skill's plan output format so that plan steps dispatch to named implementation skills instead of emitting inline implementation prose, eliminating the `PRELOADED_CONTEXT_REJECTED` pattern. 15 SCs across 4 phases: dispatch format change, concern-to-skill mapping, post-RED gate coverage, and format template/validation updates (including indented checkbox sub-step enforcement).

**Architecture:** The plan writer (`writing-plans/tasks/create/`) produces plan documents with phase sections containing TDD steps. The output format changes from bare `(**clean-room**)` markers to `— <skill-name> for <concern> (**clean-room**)` with dispatch directives. A new `phase-to-skill-mapping.yaml` artifact is produced at plan-creation time. Post-RED/green sections gain three mandatory pipeline skills.

**Tech Stack:** Markdown task files (`.md`), YAML artifacts, skill deck at `.opencode/skills/`, `implementation-pipeline/SKILL.md` §Dispatch Routing Table as canonical gate source.

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

---

## Phase 1 — Dispatch Format Change

**Concern:** Skill task file format updates — updating the plan output format template and validation rules in `plan-structure.md` and `create-and-validate.md` to require skill-dispatch markers.
**Files:** `.opencode/skills/writing-plans/tasks/create/plan-structure.md`, `.opencode/skills/writing-plans/tasks/create/create-and-validate.md`, `.opencode/skills/writing-plans/tasks/create.md`
**SCs covered:** SC-1, SC-2, SC-3

### Pre-RED Common

- [ ] 1. Verification gate — `verification-enforcement` for spec content verification (**inline**)
    - [ ] 1a. Verify spec claims against live source files → SC-1, SC-2, SC-3
- [ ] 2. Read approved spec — `issue-review` for spec content (**inline**)
    - [ ] 2a. Extract objectives, constraints, success criteria, affected sub-folders → SC-1, SC-2, SC-3
- [ ] 3. Read `implementation-pipeline/SKILL.md` §Dispatch Routing Table — `pre-analysis` for canonical gate discovery (**inline**)
    - [ ] 3a. Confirm gate labels and dispatch types → SC-1, SC-3

### Per-Item RED+green Chains

- [ ] TDD-1: Update `plan-structure.md` Step 5 output format to require skill-dispatch markers (SC-1, SC-12)
    - [ ] 1. RED: The `plan-structure.md` Step 5 output format section shows bare `(**clean-room**)` markers without skill names — `skill-creator` for task file format updates (**clean-room**)
        → dispatch: "execute validate task from skill-creator"
        → SC-1, SC-12
    - [ ] 2. GREEN: The `plan-structure.md` Step 5 output format section requires `— <skill-name> for <concern> (**<dispatch-mode>**)` with dispatch directive — `skill-creator` for task file format updates (**clean-room**)
        → dispatch: "execute validate task from skill-creator"
        → SC-1, SC-12
- [ ] TDD-2: Update `create-and-validate.md` format template to require skill-dispatch format (SC-1, SC-11)
    - [ ] 1. RED: The `create-and-validate.md` Phase body requirements section shows bare `(**clean-room**)` markers without skill names — `skill-creator` for task file format updates (**clean-room**)
        → dispatch: "execute validate task from skill-creator"
        → SC-1, SC-11
    - [ ] 2. GREEN: The `create-and-validate.md` Phase body requirements section requires `— <skill-name> for <concern> (**<dispatch-mode>**)` with dispatch directive — `skill-creator` for task file format updates (**clean-room**)
        → dispatch: "execute validate task from skill-creator"
        → SC-1, SC-11
- [ ] TDD-3: Update `create-and-validate.md` Step 10 validation to reject bare `(**clean-room**)` without skill name (SC-3)
    - [ ] 1. RED: Step 10 validation passes plans with bare `(**clean-room**)` markers — `skill-creator` for task file format updates (**clean-room**)
        → dispatch: "execute validate task from skill-creator"
        → SC-3
    - [ ] 2. GREEN: Step 10 validation rejects plans with bare `(**clean-room**)` markers that lack a skill name — `skill-creator` for task file format updates (**clean-room**)
        → dispatch: "execute validate task from skill-creator"
        → SC-3
- [ ] TDD-4: Update `create-and-validate.md` Step 10 validation to verify skill names exist in skill deck (SC-3)
    - [ ] 1. RED: Step 10 validation accepts dispatch markers referencing non-existent skill names — `skill-creator` for task file format updates (**clean-room**)
        → dispatch: "execute validate task from skill-creator"
        → SC-3
    - [ ] 2. GREEN: Step 10 validation HALT with `SKILL_NOT_FOUND` when dispatch marker references a non-existent skill directory — `skill-creator` for task file format updates (**clean-room**)
        → dispatch: "execute validate task from skill-creator"
        → SC-3
- [ ] TDD-5: Update `create.md` operating protocol Step 7 to reference skill-dispatch format (SC-1)
    - [ ] 1. RED: The `create.md` Step 7 checklist format section references bare `(**clean-room**)` markers — `skill-creator` for task file format updates (**clean-room**)
        → dispatch: "execute validate task from skill-creator"
        → SC-1
    - [ ] 2. GREEN: The `create.md` Step 7 checklist format section references skill-dispatch markers — `skill-creator` for task file format updates (**clean-room**)
        → dispatch: "execute validate task from skill-creator"
        → SC-1

### Post-RED/green

- [ ] 6. COMPLETENESS GATE — `completeness-gate` for SC coverage verification (**clean-room**)
    - [ ] 6a. Verify all SCs (SC-1, SC-2, SC-3) covered before audit → SC-all
- [ ] 7. ADVERSARIAL AUDIT — `adversarial-audit` for plan-fidelity audit (**orchestrator**)
    - [ ] 7a. Run resolve-models to select cross-family auditors → SC-all
    - [ ] 7b. Dispatch audit task with auditor_1 → SC-all
    - [ ] 7c. If auditor_1 returned non-clean-pass: remediate root cause, restart from 7a → SC-all
    - [ ] 7d. Dispatch audit task with auditor_2 → SC-all
    - [ ] 7e. If auditor_2 returned non-clean-pass: remediate root cause, restart from 7a → SC-all
    - [ ] 7f. Both auditors clean PASS. Collect artifact_path values, pass as auditor_artifact_paths to cross-validate → SC-all
- [ ] 8. EXEC SUMMARY — `completion-core` for push and report (**clean-room**)
    - [ ] 8a. Write phase-complete event to lifecycle manifest at `./tmp/1311/lifecycle.yaml` → SC-all
    - [ ] 8b. Report completion in chat with byline → SC-all

---

## Phase 2 — Concern-to-Skill Mapping

**Concern:** Skill task file format updates — adding phase-to-skill-mapping.yaml generation to `plan-structure.md`.
**Files:** `.opencode/skills/writing-plans/tasks/create/plan-structure.md`
**SCs covered:** SC-4, SC-5, SC-6

### Pre-RED Common

- [ ] 1. Verification gate — `verification-enforcement` for spec content verification (**inline**)
    - [ ] 1a. Verify spec claims against live source files → SC-4, SC-5, SC-6
- [ ] 2. Read approved spec — `issue-review` for spec content (**inline**)
    - [ ] 2a. Extract objectives, constraints, success criteria, affected sub-folders → SC-4, SC-5, SC-6
- [ ] 3. Read `implementation-pipeline/SKILL.md` §Dispatch Routing Table — `pre-analysis` for canonical gate discovery (**inline**)
    - [ ] 3a. Confirm concern categories and skill mappings → SC-4, SC-5

### Per-Item RED+green Chains

- [ ] TDD-1: Add phase-to-skill-mapping.yaml generation step to `plan-structure.md` (SC-4)
    - [ ] 1. RED: The `plan-structure.md` procedure does not produce a `phase-to-skill-mapping.yaml` artifact — `skill-creator` for task file format updates (**clean-room**)
        → dispatch: "execute validate task from skill-creator"
        → SC-4
    - [ ] 2. GREEN: The `plan-structure.md` procedure includes a step to read `implementation-pipeline/SKILL.md` §Dispatch Routing Table and write `.issues/{N}/phase-to-skill-mapping.yaml` — `skill-creator` for task file format updates (**clean-room**)
        → dispatch: "execute validate task from skill-creator"
        → SC-4
- [ ] TDD-2: Add validation that mapping is exhaustive per dispatch routing table (SC-5)
    - [ ] 1. RED: Step 10 validation does not check that all concern types have a named skill — `skill-creator` for task file format updates (**clean-room**)
        → dispatch: "execute validate task from skill-creator"
        → SC-5
    - [ ] 2. GREEN: Step 10 validation verifies no phase step is assigned bare `(**clean-room**)` without a named skill — `skill-creator` for task file format updates (**clean-room**)
        → dispatch: "execute validate task from skill-creator"
        → SC-5
- [ ] TDD-3: Ensure mapping includes `engineering-approach` for code-implementation concerns (SC-6)
    - [ ] 1. RED: The mapping does not include `engineering-approach` for code-implementation concerns — `skill-creator` for task file format updates (**clean-room**)
        → dispatch: "execute validate task from skill-creator"
        → SC-6
    - [ ] 2. GREEN: The mapping includes `engineering-approach` for code-implementation concerns regardless of language — `skill-creator` for task file format updates (**clean-room**)
        → dispatch: "execute validate task from skill-creator"
        → SC-6

### Post-RED/green

- [ ] 4. COMPLETENESS GATE — `completeness-gate` for SC coverage verification (**clean-room**)
    - [ ] 4a. Verify all SCs (SC-4, SC-5, SC-6) covered before audit → SC-all
- [ ] 5. ADVERSARIAL AUDIT — `adversarial-audit` for plan-fidelity audit (**orchestrator**)
    - [ ] 5a. Run resolve-models to select cross-family auditors → SC-all
    - [ ] 5b. Dispatch audit task with auditor_1 → SC-all
    - [ ] 5c. If auditor_1 returned non-clean-pass: remediate root cause, restart from 5a → SC-all
    - [ ] 5d. Dispatch audit task with auditor_2 → SC-all
    - [ ] 5e. If auditor_2 returned non-clean-pass: remediate root cause, restart from 5a → SC-all
    - [ ] 5f. Both auditors clean PASS. Collect artifact_path values, pass as auditor_artifact_paths to cross-validate → SC-all
- [ ] 6. EXEC SUMMARY — `completion-core` for push and report (**clean-room**)
    - [ ] 6a. Write phase-complete event to lifecycle manifest at `./tmp/1311/lifecycle.yaml` → SC-all
    - [ ] 6b. Report completion in chat with byline → SC-all

---

## Phase 3 — Post-RED/green Pipeline Gate Coverage

**Concern:** Skill task file format updates — adding adversarial-audit, completeness-gate, and completion-core steps to post-RED sections in `plan-structure.md` and `create-and-validate.md`.
**Files:** `.opencode/skills/writing-plans/tasks/create/plan-structure.md`, `.opencode/skills/writing-plans/tasks/create/create-and-validate.md`
**SCs covered:** SC-7, SC-8, SC-9

### Pre-RED Common

- [ ] 1. Verification gate — `verification-enforcement` for spec content verification (**inline**)
    - [ ] 1a. Verify spec claims against live source files → SC-7, SC-8, SC-9
- [ ] 2. Read approved spec — `issue-review` for spec content (**inline**)
    - [ ] 2a. Extract objectives, constraints, success criteria, affected sub-folders → SC-7, SC-8, SC-9
- [ ] 3. Read `implementation-pipeline/SKILL.md` §Dispatch Routing Table — `pre-analysis` for canonical gate discovery (**inline**)
    - [ ] 3a. Confirm post-RED gate sequence → SC-7, SC-8, SC-9

### Per-Item RED+green Chains

- [ ] TDD-1: Add adversarial-audit step to post-RED sections in `plan-structure.md` (SC-7)
    - [ ] 1. RED: The `plan-structure.md` Post-RED/green section does not include an adversarial-audit step — `skill-creator` for task file format updates (**clean-room**)
        → dispatch: "execute validate task from skill-creator"
        → SC-7
    - [ ] 2. GREEN: The `plan-structure.md` Post-RED/green section includes an adversarial-audit step with multi-dispatch format — `skill-creator` for task file format updates (**clean-room**)
        → dispatch: "execute validate task from skill-creator"
        → SC-7
- [ ] TDD-2: Add completeness-gate bridge step to post-RED sections in `plan-structure.md` (SC-8)
    - [ ] 1. RED: The `plan-structure.md` Post-RED/green section does not include a completeness-gate step between GREEN and audit — `skill-creator` for task file format updates (**clean-room**)
        → dispatch: "execute validate task from skill-creator"
        → SC-8
    - [ ] 2. GREEN: The `plan-structure.md` Post-RED/green section includes a completeness-gate step between the last GREEN and adversarial audit — `skill-creator` for task file format updates (**clean-room**)
        → dispatch: "execute validate task from skill-creator"
        → SC-8
- [ ] TDD-3: Add completion-core step to post-RED sections in `plan-structure.md` (SC-9)
    - [ ] 1. RED: The `plan-structure.md` Post-RED/green section does not include a completion-core step — `skill-creator` for task file format updates (**clean-room**)
        → dispatch: "execute validate task from skill-creator"
        → SC-9
    - [ ] 2. GREEN: The `plan-structure.md` Post-RED/green section includes a completion-core step at the end — `skill-creator` for task file format updates (**clean-room**)
        → dispatch: "execute validate task from skill-creator"
        → SC-9
- [ ] TDD-4: Update `create-and-validate.md` Step 10 validation to require post-RED pipeline gates (SC-7, SC-8, SC-9)
    - [ ] 1. RED: Step 10 validation does not require adversarial-audit, completeness-gate, or completion-core in post-RED sections — `skill-creator` for task file format updates (**clean-room**)
        → dispatch: "execute validate task from skill-creator"
        → SC-7, SC-8, SC-9
    - [ ] 2. GREEN: Step 10 validation requires all three post-RED pipeline gates (adversarial-audit, completeness-gate, completion-core) — `skill-creator` for task file format updates (**clean-room**)
        → dispatch: "execute validate task from skill-creator"
        → SC-7, SC-8, SC-9

### Post-RED/green

- [ ] 5. COMPLETENESS GATE — `completeness-gate` for SC coverage verification (**clean-room**)
    - [ ] 5a. Verify all SCs (SC-7, SC-8, SC-9) covered before audit → SC-all
- [ ] 6. ADVERSARIAL AUDIT — `adversarial-audit` for plan-fidelity audit (**orchestrator**)
    - [ ] 6a. Run resolve-models to select cross-family auditors → SC-all
    - [ ] 6b. Dispatch audit task with auditor_1 → SC-all
    - [ ] 6c. If auditor_1 returned non-clean-pass: remediate root cause, restart from 6a → SC-all
    - [ ] 6d. Dispatch audit task with auditor_2 → SC-all
    - [ ] 6e. If auditor_2 returned non-clean-pass: remediate root cause, restart from 6a → SC-all
    - [ ] 6f. Both auditors clean PASS. Collect artifact_path values, pass as auditor_artifact_paths to cross-validate → SC-all
- [ ] 7. EXEC SUMMARY — `completion-core` for push and report (**clean-room**)
    - [ ] 7a. Write phase-complete event to lifecycle manifest at `./tmp/1311/lifecycle.yaml` → SC-all
    - [ ] 7b. Report completion in chat with byline → SC-all

---

## Phase 4 — Plan Format Template and Validation Updates

**Concern:** Skill task file format updates — updating validation rules, format templates, and adding prose-sub-step rejection.
**Files:** `.opencode/skills/writing-plans/tasks/create/create-and-validate.md`, `.opencode/skills/writing-plans/tasks/create/plan-structure.md`
**SCs covered:** SC-10, SC-11, SC-12, SC-13, SC-14, SC-15

### Pre-RED Common

- [ ] 1. Verification gate — `verification-enforcement` for spec content verification (**inline**)
    - [ ] 1a. Verify spec claims against live source files → SC-10, SC-11, SC-12, SC-13, SC-14, SC-15
- [ ] 2. Read approved spec — `issue-review` for spec content (**inline**)
    - [ ] 2a. Extract objectives, constraints, success criteria, affected sub-folders → SC-10, SC-11, SC-12, SC-13, SC-14, SC-15
- [ ] 3. Read `implementation-pipeline/SKILL.md` §Dispatch Routing Table — `pre-analysis` for canonical gate discovery (**inline**)
    - [ ] 3a. Confirm validation rule format and sub-step expansion requirements → SC-10, SC-15

### Per-Item RED+green Chains

- [ ] TDD-1: Add skill-name-exists validation rule to `create-and-validate.md` Step 10 (SC-10)
    - [ ] 1. RED: Step 10 validation does not check that dispatch marker skill names reference existing skill directories — `skill-creator` for task file format updates (**clean-room**)
        → dispatch: "execute validate task from skill-creator"
        → SC-10
    - [ ] 2. GREEN: Step 10 validation includes rule 9: every dispatch marker skill name must reference a directory under `.opencode/skills/` — `skill-creator` for task file format updates (**clean-room**)
        → dispatch: "execute validate task from skill-creator"
        → SC-10
- [ ] TDD-2: Update `create-and-validate.md` Phase body requirements format template (SC-11)
    - [ ] 1. RED: The Phase body requirements template shows `- [ ] 1. <STEP-LABEL> (**<clean-room|inline>**). <description> → SC-N` — `skill-creator` for task file format updates (**clean-room**)
        → dispatch: "execute validate task from skill-creator"
        → SC-11
    - [ ] 2. GREEN: The Phase body requirements template shows `- [ ] 1. <STEP-LABEL> — <skill-name> for <concern> (**<clean-room|inline>**)\n    → dispatch: "execute <task> from <skill-name>"\n    → SC-N` — `skill-creator` for task file format updates (**clean-room**)
        → dispatch: "execute validate task from skill-creator"
        → SC-11
- [ ] TDD-3: Update `plan-structure.md` Step 5 per-unit output format (SC-12)
    - [ ] 1. RED: The `plan-structure.md` Step 5 per-unit output format shows bare `(**clean-room**)` markers — `skill-creator` for task file format updates (**clean-room**)
        → dispatch: "execute validate task from skill-creator"
        → SC-12
    - [ ] 2. GREEN: The `plan-structure.md` Step 5 per-unit output format includes skill name and dispatch directive alongside the dispatch mode marker — `skill-creator` for task file format updates (**clean-room**)
        → dispatch: "execute validate task from skill-creator"
        → SC-12
- [ ] TDD-4: Update `create-and-validate.md` format template to require indented checkbox sub-steps for Pre-RED common (SC-13)
    - [ ] 1. RED: Pre-RED common format template shows `→ prose` continuation lines — `skill-creator` for task file format updates (**clean-room**)
        → dispatch: "execute validate task from skill-creator"
        → SC-13
    - [ ] 2. GREEN: Pre-RED common format template shows `- [ ] Na.` indented checkbox sub-steps — `skill-creator` for task file format updates (**clean-room**)
        → dispatch: "execute validate task from skill-creator"
        → SC-13
- [ ] TDD-5: Update `plan-structure.md` Post-RED/green format template to expand gate sub-steps into indented checkboxes (SC-14)
    - [ ] 1. RED: Post-RED gate steps show collapsed arrow-chain prose (`→ step → step → step`) — `skill-creator` for task file format updates (**clean-room**)
        → dispatch: "execute validate task from skill-creator"
        → SC-14
    - [ ] 2. GREEN: Post-RED adversarial-audit, completeness-gate, and completion-core steps show expanded indented checkbox sub-steps — `skill-creator` for task file format updates (**clean-room**)
        → dispatch: "execute validate task from skill-creator"
        → SC-14
- [ ] TDD-6: Add prose-sub-step rejection rule to `create-and-validate.md` Step 10 validation (SC-15)
    - [ ] 1. RED: Step 10 validation passes plans with prose-format sub-steps (`→ verify spec claims...`) — `skill-creator` for task file format updates (**clean-room**)
        → dispatch: "execute validate task from skill-creator"
        → SC-15
    - [ ] 2. GREEN: Step 10 validation includes rule 10: reject any plan step with prose-format sub-steps (matched by `^\s+→ [^d]` — arrow continuations that are not `→ dispatch:` or `→ SC-N`). HALT with `PROSE_SUBSTEPS_DETECTED` — `skill-creator` for task file format updates (**clean-room**)
        → dispatch: "execute validate task from skill-creator"
        → SC-15

### Post-RED/green

- [ ] 4. COMPLETENESS GATE — `completeness-gate` for SC coverage verification (**clean-room**)
    - [ ] 4a. Verify all SCs (SC-10, SC-11, SC-12, SC-13, SC-14, SC-15) covered before audit → SC-all
- [ ] 5. ADVERSARIAL AUDIT — `adversarial-audit` for spec-audit (**orchestrator**)
    - [ ] 5a. Run resolve-models to select cross-family auditors → SC-all
    - [ ] 5b. Dispatch audit task with auditor_1 → SC-all
    - [ ] 5c. If auditor_1 returned non-clean-pass: remediate root cause, restart from 5a → SC-all
    - [ ] 5d. Dispatch audit task with auditor_2 → SC-all
    - [ ] 5e. If auditor_2 returned non-clean-pass: remediate root cause, restart from 5a → SC-all
    - [ ] 5f. Both auditors clean PASS. Collect artifact_path values, pass as auditor_artifact_paths to cross-validate → SC-all
- [ ] 6. EXEC SUMMARY — `completion-core` for push and report (**clean-room**)
    - [ ] 6a. Write completion event to lifecycle manifest at `./tmp/1311/lifecycle.yaml` → SC-all
    - [ ] 6b. Report completion in chat with byline → SC-all

---

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

---

## Exit Criteria

- Plan stored at `.opencode/.issues/1311-spec-plan-writer-must-dispatch-to-implementation-skills-inst/plan.md`
- All 15 SCs mapped across 4 phases
- Phase dependency ordering SAT-verified
- Phase solvability SOLVED_SATISFICING
- Approval cascade: `for_plan` scope → auto-approved
- Halt at: `plan_created`
