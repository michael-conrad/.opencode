---
plan_schema_version: 1
issue: 2210
title: "Canonical reference docs for spec and plan structure (Spec A)"
dispatch:
  - phase: 1
    skill: spec-creation
    task: create
    dispatch: clean-room
  - phase: 2
    skill: spec-creation
    task: create
    dispatch: clean-room
  - phase: 3
    skill: customize-opencode
    task: edit
    dispatch: clean-room
  - phase: 4
    skill: customize-opencode
    task: edit
    dispatch: clean-room
  - phase: 5
    skill: verification-before-completion
    task: verify
    dispatch: clean-room
  - phase: 6
    skill: customize-opencode
    task: edit
    dispatch: clean-room
---

# Plan for .opencode#2210 — Canonical reference docs for spec and plan structure (Spec A)

Issue: [.opencode#2210](https://github.com/michael-conrad/.opencode/issues/2210)

## Goal

Create two canonical reference documents (`reference/spec-structure-standards.md` and `reference/plan-structure-standards.md`) that define the required structure for specs and plans. Update the producer templates to read from these reference docs instead of hard-coding inline lists. Also create `reference/cost-model-standards.md` with the DDL cost model and dark-prose-007 formula, and update both producer templates to reference it.

## Architecture

Six phases in dependency order:
- Phases 1-2 create the reference docs (no dependencies)
- Phases 3-4 update producer templates to reference the new docs (depend on Phases 1-2)
- Phase 6 creates cost-model-standards.md and updates both producer templates (depends on Phases 3-4)
- Phase 5 verifies no ceremony was added (depends on Phases 3, 4, 6)

## Files Affected

- `.opencode/reference/spec-structure-standards.md` — new
- `.opencode/reference/plan-structure-standards.md` — new
- `.opencode/reference/cost-model-standards.md` — new
- `.opencode/skills/spec-creation/tasks/create.md` — update Step 2, add Cost Frame section
- `.opencode/skills/writing-plans/tasks/create.md` — update Steps 4-8, add per-phase cost frame

## Dispatch

| Phase | Skill | Task | Mode |
|-------|-------|------|------|
| 1 | spec-creation | create | clean-room |
| 2 | spec-creation | create | clean-room |
| 3 | customize-opencode | edit | clean-room |
| 4 | customize-opencode | edit | clean-room |
| 5 | verification-before-completion | verify | clean-room |
| 6 | customize-opencode | edit | clean-room |

## Blast Radius

- `.opencode/reference/` — three new reference documents
- `.opencode/skills/spec-creation/tasks/create.md` — Step 2 section list replaced with Read reference; Cost Frame section added
- `.opencode/skills/writing-plans/tasks/create.md` — Steps 4-8 structural expectations replaced with Read reference; per-phase cost frame added

> **Compliance requirement:** All success criteria MUST pass before this plan is considered complete. Partial implementation is not permitted. Every step in every phase MUST be executed — none are optional. Every gate from the implementation-workflow reference card is mandatory.

> **One-step-at-a-time protocol:** Execute exactly one step at a time. Do not skip ahead, batch steps, or combine multiple steps into one. After each step, report status. If a step fails, stop and report the failure — do not attempt to work around it.

> **Step status format:** After each step, report: `[PASS|FAIL|BLOCKED] Step N — <step description>`. If BLOCKED, include the reason.

> **Enforcement gate:** All success criteria must pass before this plan is considered complete. Partial implementation is not permitted.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Steps | Dispatch |
|-------|------|---------|-----|-------------|-------|----------|
| 1 | Create spec-structure-standards.md | spec-structure-standards | SC-1 | None | 1-5 | clean-room |
| 2 | Create plan-structure-standards.md | plan-structure-standards | SC-2 | None | 6-10 | clean-room |
| 3 | Update spec-creation/create.md | producer-template-update-spec | SC-3 | Phase 1 | 11-15 | clean-room |
| 4 | Update writing-plans/create.md | producer-template-update-plan | SC-4 | Phase 2 | 16-20 | clean-room |
| 5 | Verify no ceremony added | no-ceremony | SC-5 | Phases 3, 4, 6 | 21-25 | clean-room |
| 6 | Create cost-model-standards.md + updates | cost-model-standards | SC-6, SC-7, SC-8 | Phases 3, 4 | 26-30 | clean-room |

> **Self-remediation protocol:** If a step fails, diagnose the root cause, fix it, and re-run the step. Do not skip failed steps. Do not proceed past a failed step. If remediation requires changes outside the current phase scope, file a bug issue and halt.

## Exit Criteria

- [ ] C1: `reference/spec-structure-standards.md` exists with all required sections
- [ ] C2: `reference/plan-structure-standards.md` exists with all required elements
- [ ] C3: `spec-creation/tasks/create.md` references spec-structure-standards.md and includes all missing required sections
- [ ] C4: `writing-plans/tasks/create.md` references plan-structure-standards.md and includes all missing required elements
- [ ] C5: No new pipeline steps, YAML schemas, manifest write/read operations, or backward-compat handling introduced
- [ ] C6: `reference/cost-model-standards.md` exists with DDL cost model and dark-prose-007 formula
- [ ] C7: `spec-creation/tasks/create.md` references cost-model-standards.md for Cost Frame section
- [ ] C8: `writing-plans/tasks/create.md` references cost-model-standards.md for per-phase cost frame

---

# Phase 1 — Create spec-structure-standards.md

**Concern:** spec-structure-standards
**Files:** `.opencode/reference/spec-structure-standards.md` (new)
**SCs:** SC-1
**Dependencies:** None
**Entry condition:** Phase 1 is the first phase — no dependencies
**Exit condition:** `reference/spec-structure-standards.md` exists with all required sections

## Code Path Coverage

- New file creation only — no existing code paths to modify

## Cross-Cutting SCs

- None — SC-1 is self-contained

## Interface Boundaries

- The reference doc is read by `spec-creation/tasks/create.md` (Phase 3) and by auditor task files (`.opencode#2211`)
- Must use `Read [Text](path)` pattern for cross-references

## State Transitions

- Before: No canonical spec structure reference exists
- After: `reference/spec-structure-standards.md` exists and is the single source of truth for spec structure

## Step-by-step

### Item 1 (SC-1): Create reference/spec-structure-standards.md

- [ ] 1. **RED** — Write a failing enforcement test that verifies `reference/spec-structure-standards.md` does not exist yet. (**clean-room**)
  - Assert: file does not exist at `.opencode/reference/spec-structure-standards.md`
  - Test MUST fail (file doesn't exist yet)

- [ ] 2. **GREEN** — Create `reference/spec-structure-standards.md` with all required sections. (**clean-room**)
  - Required sections from spec Phase 1:
    1. Intent and Executive Summary — Preamble with 6 fields: Problem Statement, Root Cause / Motivation, Approach Chosen, Alternatives Considered & Why Discarded, Key Design Decisions, User Intent / Original Prompt
    2. Not Included — Explicitly excluded scope
    3. Success Criteria — Table with ID, Criterion, Evidence Type, Verification Method columns
    4. Requirements — Numbered requirements with SHALL language
    5. Items — Per-SC item enumeration. Each SC maps to exactly one item. Items numbered sequentially from 1.
    6. Dependencies — Prerequisite specs, skills, guidelines
    7. Traceability — Table mapping Requirements → SCs → Phases
    8. Documentation Sources — Table with Source, Type, Location, Verification columns
    9. Enforcement Gate — All-or-nothing statement: all SCs must pass before completion
    10. Cost Frame — Per-SC cost-frame language justifying verification costs relative to defect-discovery cost
    11. Edge Cases — Boundary conditions, failure modes, and their resolutions
  - SC table column requirements: ID, Criterion, Evidence Type, Verification Method
  - Evidence type taxonomy: structural, string, semantic, behavioral with EVIDENCE_TYPE_MISMATCH rules
  - Prohibited content patterns: no tracking/status language, no prescriptive code, no dispatch tables
  - Format requirements: canonical checklist format, no gate tables, no shared cross-references

- [ ] 3. **Post-regression** — Run regression test patterns after GREEN. (**clean-room**)
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`

- [ ] 4. **Verify** — Verify SC-1: reference doc exists and contains all required sections. (**clean-room**)
  - Evidence type: string
  - Diff reference doc sections against Phase 1 section list in the spec
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`

- [ ] 5. **Commit** — Stage and commit the new reference doc. (**inline**)
  - `git add .opencode/reference/spec-structure-standards.md`
  - `git commit -m "Phase 1: Create reference/spec-structure-standards.md"`
  - No co-author trailers during implementation commits

---

# Phase 2 — Create plan-structure-standards.md

**Concern:** plan-structure-standards
**Files:** `.opencode/reference/plan-structure-standards.md` (new)
**SCs:** SC-2
**Dependencies:** None
**Entry condition:** Phase 1 complete (no structural dependency, but logical ordering)
**Exit condition:** `reference/plan-structure-standards.md` exists with all required elements

## Code Path Coverage

- New file creation only — no existing code paths to modify

## Cross-Cutting SCs

- None — SC-2 is self-contained

## Interface Boundaries

- The reference doc is read by `writing-plans/tasks/create.md` (Phase 4) and by auditor task files (`.opencode#2211`)
- Must use `Read [Text](path)` pattern for cross-references

## State Transitions

- Before: No canonical plan structure reference exists
- After: `reference/plan-structure-standards.md` exists and is the single source of truth for plan structure

## Step-by-step

### Item 2 (SC-2): Create reference/plan-structure-standards.md

- [ ] 6. **RED** — Write a failing enforcement test that verifies `reference/plan-structure-standards.md` does not exist yet. (**clean-room**)
  - Assert: file does not exist at `.opencode/reference/plan-structure-standards.md`
  - Test MUST fail (file doesn't exist yet)

- [ ] 7. **GREEN** — Create `reference/plan-structure-standards.md` with all required elements. (**clean-room**)
  - Three-tier plan structure:
    - Tier 1 (Global): Pre-phase steps + post-phase steps
    - Tier 2 (Per-Phase): Phase sections with metadata and daisy-chained per-item tuples
    - Tier 3 (Per-Item): Each item: RED → GREEN → verify → commit
  - Plan frontmatter: plan_schema_version, issue, title, dispatch array
  - Plan index sections: Title, Goal/Architecture/Files/Dispatch, Blast Radius, Admonishment, One-step-at-a-time protocol, Step Status instruction, Enforcement Gate, Phase table, Self-remediation protocol, Exit Criteria
  - Phase file sections: Title, Phase metadata, Code Path Coverage, Cross-Cutting SCs, Interface Boundaries, State Transitions, Step-by-step, Phase completion block, Concern transition
  - Dispatch indicators: `(**inline**)`, `(**sub-agent**)`, `(**clean-room**)`
  - Step format: numbered checkbox with sub-bullets
  - Prohibited patterns: no dispatch tables, no TBD/TODO, no shared cross-references, no zero-indexed, no line numbers, no multi-dispatch steps, no non-standard indicators, no omitted mandatory gates
  - Cost frame: Per-phase cost-frame language

- [ ] 8. **Post-regression** — Run regression test patterns after GREEN. (**clean-room**)
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`

- [ ] 9. **Verify** — Verify SC-2: reference doc exists and contains all required elements. (**clean-room**)
  - Evidence type: string
  - Diff reference doc elements against Phase 2 section list in the spec
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`

- [ ] 10. **Commit** — Stage and commit the new reference doc. (**inline**)
  - `git add .opencode/reference/plan-structure-standards.md`
  - `git commit -m "Phase 2: Create reference/plan-structure-standards.md"`
  - No co-author trailers during implementation commits

---

# Phase 3 — Update spec-creation/create.md

**Concern:** producer-template-update-spec
**Files:** `.opencode/skills/spec-creation/tasks/create.md`
**SCs:** SC-3
**Dependencies:** Phase 1 (spec-structure-standards.md must exist)
**Entry condition:** Phase 1 complete — `reference/spec-structure-standards.md` exists
**Exit condition:** `spec-creation/tasks/create.md` Step 2 references spec-structure-standards.md and includes all missing required sections

## Code Path Coverage

- `.opencode/skills/spec-creation/tasks/create.md` Step 2 — replace inline section list with Read reference
- Add preamble (6 fields), Documentation Sources, Enforcement Gate, Cost Frame (per-SC), Edge Cases as required sections

## Cross-Cutting SCs

- None — SC-3 is self-contained

## Interface Boundaries

- The updated task file is read by the spec-creation skill's orchestrator
- Must maintain backward compatibility with existing spec-creation pipeline

## State Transitions

- Before: Step 2 has an inline section list that is incomplete
- After: Step 2 reads from `reference/spec-structure-standards.md` and includes all missing required sections

## Step-by-step

### Item 3 (SC-3): Update spec-creation/tasks/create.md

- [ ] 11. **RED** — Write a failing enforcement test that verifies the current Step 2 still has an inline section list. (**clean-room**)
  - Assert: Step 2 contains inline section enumeration (not a Read reference)
  - Test MUST fail (inline list exists)

- [ ] 12. **GREEN** — Update `spec-creation/tasks/create.md` Step 2. (**clean-room**)
  - Replace the inline section list with: `Read [spec-structure-standards.md](reference/spec-structure-standards.md) and assemble the spec against its required sections.`
  - Add preamble (6 fields): Problem Statement, Root Cause / Motivation, Approach Chosen, Alternatives Considered & Why Discarded, Key Design Decisions, User Intent / Original Prompt
  - Add Documentation Sources section
  - Add Enforcement Gate section
  - Add Cost Frame (per-SC) section
  - Add Edge Cases section
  - The existing Objective and Background sections are subsumed by the preamble's Problem Statement and Root Cause fields

- [ ] 13. **Post-regression** — Run regression test patterns after GREEN. (**clean-room**)
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`

- [ ] 14. **Verify** — Verify SC-3: inline section list removed, Read reference added, all new required sections present. (**clean-room**)
  - Evidence type: string
  - grep for inline section list removed
  - grep for Read reference to spec-structure-standards.md
  - grep for each new required section
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`

- [ ] 15. **Commit** — Stage and commit the updated task file. (**inline**)
  - `git add .opencode/skills/spec-creation/tasks/create.md`
  - `git commit -m "Phase 3: Update spec-creation/create.md to reference spec-structure-standards.md"`
  - No co-author trailers during implementation commits

---

# Phase 4 — Update writing-plans/create.md

**Concern:** producer-template-update-plan
**Files:** `.opencode/skills/writing-plans/tasks/create.md`
**SCs:** SC-4
**Dependencies:** Phase 2 (plan-structure-standards.md must exist)
**Entry condition:** Phase 2 complete — `reference/plan-structure-standards.md` exists
**Exit condition:** `writing-plans/tasks/create.md` Steps 4-8 reference plan-structure-standards.md and include all missing required elements

## Code Path Coverage

- `.opencode/skills/writing-plans/tasks/create.md` Steps 4-8 — replace inline plan structure description with Read reference

## Cross-Cutting SCs

- None — SC-4 is self-contained

## Interface Boundaries

- The updated task file is read by the writing-plans skill's orchestrator
- Must maintain backward compatibility with existing plan-creation pipeline

## State Transitions

- Before: Steps 4-8 have inline plan structure descriptions that are incomplete
- After: Steps 4-8 read from `reference/plan-structure-standards.md` for structural expectations

## Step-by-step

### Item 4 (SC-4): Update writing-plans/tasks/create.md

- [ ] 16. **RED** — Write a failing enforcement test that verifies the current Steps 4-8 still have inline plan structure descriptions. (**clean-room**)
  - Assert: Steps 4-8 contain inline structural descriptions (not Read references)
  - Test MUST fail (inline descriptions exist)

- [ ] 17. **GREEN** — Update `writing-plans/tasks/create.md` Steps 4-8. (**clean-room**)
  - Replace inline plan structure descriptions with: `Read [plan-structure-standards.md](reference/plan-structure-standards.md) for structural expectations`
  - The steps still describe the procedure (read artifacts, build frontmatter, build body, write to disk) but the structural expectations come from the reference doc
  - Add three-tier layout (global pre-steps → per-phase daisy-chained items → global post-steps)
  - Add per-item daisy chain: RED → GREEN → verify → commit
  - Add dispatch indicators: `(**inline**)`, `(**sub-agent**)`, `(**clean-room**)`
  - Add step format: numbered checkbox with sub-bullets, no prescriptive code
  - Add admonishments: compliance top-only, one-step-at-a-time, step status, self-remediation, enforcement gate
  - Add blast radius section
  - Add phase file sections: code path coverage, cross-cutting SCs, interface boundaries, state transitions
  - Add prohibited patterns: no dispatch tables, no TBD/TODO, no shared cross-references, no zero-indexed, no line numbers, no multi-dispatch steps, no non-standard indicators, no omitted mandatory gates
  - Add cost-frame per phase

- [ ] 18. **Post-regression** — Run regression test patterns after GREEN. (**clean-room**)
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`

- [ ] 19. **Verify** — Verify SC-4: Read reference added, all new required elements present. (**clean-room**)
  - Evidence type: string
  - grep for Read reference to plan-structure-standards.md
  - grep for each new required element
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`

- [ ] 20. **Commit** — Stage and commit the updated task file. (**inline**)
  - `git add .opencode/skills/writing-plans/tasks/create.md`
  - `git commit -m "Phase 4: Update writing-plans/create.md to reference plan-structure-standards.md"`
  - No co-author trailers during implementation commits

---

# Phase 5 — Verify no ceremony added

**Concern:** no-ceremony
**Files:** Verification only — no file modifications
**SCs:** SC-5
**Dependencies:** Phases 3, 4, 6 (all producer template changes must be complete)
**Entry condition:** Phases 3, 4, and 6 complete
**Exit condition:** Verified that no new pipeline steps, YAML schemas, manifest write/read operations, or backward-compat handling were introduced

## Code Path Coverage

- All files modified in Phases 1-4 and 6

## Cross-Cutting SCs

- SC-5 applies to all changed files across all phases

## Interface Boundaries

- No interface changes — this is a verification-only phase

## State Transitions

- Before: Unverified ceremony state
- After: Confirmed no ceremony creep

## Step-by-step

### Item 5 (SC-5): Verify no ceremony added

- [ ] 21. **RED** — Write a failing enforcement test that checks for prohibited ceremony patterns in the current state. (**clean-room**)
  - Assert: grep for manifest, schema, backward-compat patterns returns no matches in changed files
  - Test MUST fail if any prohibited pattern is found

- [ ] 22. **GREEN** — If any prohibited patterns are found, remove them. (**clean-room**)
  - Remove any YAML schemas, manifest write/read operations, backward-compat handling, or new pipeline steps
  - This phase is verification-only — GREEN is a no-op if RED passes

- [ ] 23. **Post-regression** — Run regression test patterns after GREEN. (**clean-room**)
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`

- [ ] 24. **Verify** — Verify SC-5: no prohibited ceremony patterns. (**clean-room**)
  - Evidence type: string
  - grep for manifest, schema, backward-compat patterns in all changed files
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`

- [ ] 25. **Commit** — Stage and commit any ceremony fixes (if needed). (**inline**)
  - `git add <files> && git commit -m "Phase 5: Remove prohibited ceremony patterns"`
  - If no changes needed, skip commit
  - No co-author trailers during implementation commits

---

# Phase 6 — Create cost-model-standards.md and update producer templates

**Concern:** cost-model-standards
**Files:**
- `.opencode/reference/cost-model-standards.md` (new)
- `.opencode/skills/spec-creation/tasks/create.md` (update Cost Frame section)
- `.opencode/skills/writing-plans/tasks/create.md` (update per-phase cost frame)
**SCs:** SC-6, SC-7, SC-8
**Dependencies:** Phases 3, 4 (producer templates must already be updated to reference structure standards)
**Entry condition:** Phases 3 and 4 complete
**Exit condition:** `reference/cost-model-standards.md` exists, both producer templates reference it

## Code Path Coverage

- `.opencode/reference/cost-model-standards.md` — new file
- `.opencode/skills/spec-creation/tasks/create.md` — add Read reference to cost-model-standards.md in Cost Frame section
- `.opencode/skills/writing-plans/tasks/create.md` — add Read reference to cost-model-standards.md in per-phase cost frame step

## Cross-Cutting SCs

- SC-7 and SC-8 both depend on SC-6 (the reference doc must exist before templates can reference it)

## Interface Boundaries

- The cost model reference doc is read by both producer templates
- Must use `Read [Text](path)` pattern for cross-references

## State Transitions

- Before: No canonical cost model reference exists; cost frames are written without a standard formula
- After: `reference/cost-model-standards.md` exists; both producer templates reference it

## Step-by-step

### Item 6 (SC-6): Create reference/cost-model-standards.md

- [ ] 26. **RED** — Write a failing enforcement test that verifies `reference/cost-model-standards.md` does not exist yet. (**clean-room**)
  - Assert: file does not exist at `.opencode/reference/cost-model-standards.md`
  - Test MUST fail (file doesn't exist yet)

- [ ] 27. **GREEN** — Create `reference/cost-model-standards.md` with DDL cost model and dark-prose-007 formula. (**clean-room**)
  - DDL cost model:
    - Cost is measured in defect-discovery-latency, not tool calls
    - Death spiral: structural PASS → defect ships → production discovery → 1000× rework cost
    - Break: behavioral FAIL at gate 1 → immediate fix → zero downstream cost
    - Tiered table by evidence type (behavioral/semantic/string/structural) with DDL multiplier and death spiral/break classification
    - Research grounding: IBM 100×, NIST $59.5B, Capers Jones DRE
  - Cost-frame formula (dark-prose-007):
    - Computation frame: cost IS defect-discovery-latency
    - Action cost: [action] costs [magnitude] — [consequence]
    - Skipping cost: [skipped action] costs [magnitude] — [consequence]
    - Identity anchor: Correctness is the only metric
  - Examples: Correctly formed per-SC cost-frame statements

### Item 7 (SC-7): Update spec-creation/create.md Cost Frame section

- [ ] 28. **GREEN** — Update `spec-creation/tasks/create.md` Cost Frame section. (**clean-room**)
  - Add `Read [cost-model-standards.md](reference/cost-model-standards.md)` to the Cost Frame section assembly step
  - The Cost Frame section is assembled by reading the reference doc and writing per-SC cost-frame statements following the dark-prose-007 pattern

### Item 8 (SC-8): Update writing-plans/create.md per-phase cost frame

- [ ] 29. **GREEN** — Update `writing-plans/tasks/create.md` per-phase cost frame step. (**clean-room**)
  - Add `Read [cost-model-standards.md](reference/cost-model-standards.md)` to the per-phase cost frame step
  - The per-phase cost frame is assembled by reading the reference doc and writing per-phase cost-frame statements following the dark-prose-007 pattern

### Verification and commit for Phase 6

- [ ] 30. **Post-regression** — Run regression test patterns after all GREEN items. (**clean-room**)
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`

- [ ] 31. **Verify** — Verify SC-6, SC-7, SC-8. (**clean-room**)
  - SC-6 (string): diff reference doc sections against Phase 6 section list in the spec
  - SC-7 (string): grep for Read reference to cost-model-standards in spec-creation/create.md
  - SC-8 (string): grep for Read reference to cost-model-standards in writing-plans/create.md
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`

- [ ] 32. **Commit** — Stage and commit all Phase 6 changes together. (**inline**)
  - `git add .opencode/reference/cost-model-standards.md .opencode/skills/spec-creation/tasks/create.md .opencode/skills/writing-plans/tasks/create.md`
  - `git commit -m "Phase 6: Create cost-model-standards.md and update producer templates"`
  - No co-author trailers during implementation commits

---

# Post-implementation

- [ ] 33. **Audit** — Adversarial audit of all deliverables. (**clean-room**)
  - Dispatch: `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")`
  - Followed by validator, evaluator, arbiter in sequence

- [ ] 34. **Z3 check** — Run Z3 constraint solver verification. (**inline**)
  - `.opencode/tools/solve check --state-path ... --contract-path ...`

- [ ] 35. **Structural checks** — Run finishing checklist. (**clean-room**)
  - Dispatch: `task(..., prompt: "execute checklist task from finishing-a-development-branch")`
  - Lint, typecheck, format checks

- [ ] 36. **Pre-PR gate** — Verify all SC verdicts before PR creation. (**clean-room**)
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Reads all SC verdicts, BLOCKs if any FAIL

- [ ] 37. **Regression check** — Final regression check before PR. (**clean-room**)
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`

- [ ] 38. **Review prep** — Prepare PR review context. (**clean-room**)
  - Dispatch: `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")`

- [ ] 39. **Create PR** — Create the pull request. (**clean-room**)
  - Dispatch: `task(..., prompt: "execute create task from git-workflow-pr")`

- [ ] 40. **Executive summary** — Generate completion executive summary. (**clean-room**)
  - Dispatch: `task(..., prompt: "execute completion task from completion-core")`

---

---
## Lifecycle Events

- **2026-08-03T00:18:00Z** — `plan_created` — Plan file at `.opencode/.issues/2210/plan.md` with 6 phases

---

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **Phase 1 (SC-1):** Creating the spec structure reference doc costs one write operation. Skipping means every spec created from the producer template has no canonical structure to validate against — the 39-item gap persists indefinitely.
- **Phase 2 (SC-2):** Creating the plan structure reference doc costs one write operation. Skipping means every plan created from the producer template has no canonical structure — plan-fidelity audits catch structural defects at review time instead of design time.
- **Phase 3 (SC-3):** Updating the spec producer template costs one edit operation. Skipping means the producer template still hard-codes an incomplete section list — the root cause of the 39-item gap remains unfixed.
- **Phase 4 (SC-4):** Updating the plan producer template costs one edit operation. Skipping means the plan producer template still hard-codes an incomplete structure — plan-fidelity audits continue to catch structural defects at review time.
- **Phase 5 (SC-5):** Verifying no ceremony costs one grep search. Skipping means ceremony creep goes undetected — the whole point of `.opencode#2176` is violated.
- **Phase 6 (SC-6, SC-7, SC-8):** Creating the cost model reference doc and updating both producer templates costs three operations. Skipping means cost-frame statements drift from the dark-prose-007 pattern — per-SC cost justifications become inconsistent and unverifiable.
