---
plan_schema_version: 1
issue: 2210
title: "Spec A — reference docs and producer templates"
dispatch: [spec-creation, writing-plans]
---

# Plan: `.opencode#2210` — Spec A: Reference Docs and Producer Templates

## Goal

Create three canonical reference documents (`spec-structure-standards.md`, `plan-structure-standards.md`, `cost-model-standards.md`) and update the producer templates (`spec-creation/tasks/create.md`, `writing-plans/tasks/create.md`) to read from them via `Read [Text](path)` instead of hard-coding inline section lists.

## Architecture

Three reference docs → two producer templates read them. No new pipeline steps, YAML schemas, manifests, or backward-compat handling.

## Files

- `.opencode/reference/spec-structure-standards.md` — new
- `.opencode/reference/plan-structure-standards.md` — new
- `.opencode/reference/cost-model-standards.md` — new
- `.opencode/skills/spec-creation/tasks/create.md` — update Step 2, add Cost Frame section
- `.opencode/skills/writing-plans/tasks/create.md` — update Steps 4-8, add per-phase cost frame

## Dispatch

- Phase 1-2, 6: `(**clean-room**)` — create reference docs
- Phase 3-4: `(**sub-agent**)` — update producer templates
- Phase 5: `(**inline**)` — verify no ceremony added

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Enforcement gate:** All 8 SCs must pass before this plan is complete.

## Blast Radius

- `.opencode/reference/` — three new files
- `.opencode/skills/spec-creation/tasks/create.md` — Step 2 section list replaced, Cost Frame section added
- `.opencode/skills/writing-plans/tasks/create.md` — Steps 4-8 structure description replaced, per-phase cost frame added
- `.opencode/guidelines/250-dark-prose-reference.md` — stale cross-reference to 065 fixed (indirectly, via cost-model-standards.md)

## Phase Table

| Phase | Name | SCs | Dependencies | Dispatch |
|-------|------|-----|--------------|----------|
| 1 | Create spec-structure-standards.md | SC-1 | None | clean-room |
| 2 | Create plan-structure-standards.md | SC-2 | None | clean-room |
| 3 | Update spec-creation/create.md | SC-3 | Phase 1 | sub-agent |
| 4 | Update writing-plans/create.md | SC-4 | Phase 2 | sub-agent |
| 5 | Verify no ceremony added | SC-5 | Phase 3, 4 | inline |
| 6 | Create cost-model-standards.md + update producers | SC-6, SC-7, SC-8 | Phase 3, 4 | clean-room + sub-agent |

## Self-Remediation Protocol

If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

## Exit Criteria

- [ ] C1: `reference/spec-structure-standards.md` exists with all 11 required sections
- [ ] C2: `reference/plan-structure-standards.md` exists with all structural elements
- [ ] C3: `spec-creation/tasks/create.md` Step 2 references spec-structure-standards
- [ ] C4: `writing-plans/tasks/create.md` references plan-structure-standards
- [ ] C5: No manifest, schema, or backward-compat patterns introduced
- [ ] C6: `reference/cost-model-standards.md` exists with DDL model and dark-prose-007 formula
- [ ] C7: `spec-creation/tasks/create.md` references cost-model-standards for Cost Frame
- [ ] C8: `writing-plans/tasks/create.md` references cost-model-standards for per-phase cost frame

---

# Phase 1 — Create spec-structure-standards.md

**Concern:** Reference doc creation
**Files:** `.opencode/reference/spec-structure-standards.md`
**SCs:** SC-1
**Dependencies:** None
**Entry:** Branch created, spec read
**Exit:** `reference/spec-structure-standards.md` exists with all 11 required sections

### Item 1 (SC-1): Create spec-structure-standards.md

- [ ] 1. RED: Verify the file does not exist yet — `ls .opencode/reference/spec-structure-standards.md` should fail
- [ ] 2. GREEN: Create `.opencode/reference/spec-structure-standards.md` with:
  - Required sections (11): Intent and Executive Summary (6 fields), Not Included, Success Criteria (ID/Criterion/Evidence Type/Verification Method), Requirements (numbered SHALL), Items (per-SC enumeration), Dependencies, Traceability (Req→SC→Phase), Documentation Sources (Source/Type/Location/Verification), Enforcement Gate (all-or-nothing), Cost Frame (per-SC, dark-prose-007 pattern), Edge Cases
  - Evidence type taxonomy (structural/string/semantic/behavioral, EVIDENCE_TYPE_MISMATCH rules, default to string)
  - Prohibited content patterns (no tracking/status language, no prescriptive code)
  - Format requirements (canonical checklist format, no gate tables, no dispatch tables)
- [ ] 3. Verify: Read the file, diff sections against Phase 1 section list in the spec
- [ ] 4. Commit: `git add .opencode/reference/spec-structure-standards.md && git commit -m "feat(#2210): create spec-structure-standards.md reference doc"`

---

# Phase 2 — Create plan-structure-standards.md

**Concern:** Reference doc creation
**Files:** `.opencode/reference/plan-structure-standards.md`
**SCs:** SC-2
**Dependencies:** None
**Entry:** Phase 1 committed
**Exit:** `reference/plan-structure-standards.md` exists with all structural elements

### Item 2 (SC-2): Create plan-structure-standards.md

- [ ] 1. RED: Verify the file does not exist yet
- [ ] 2. GREEN: Create `.opencode/reference/plan-structure-standards.md` with:
  - Three-tier structure (global pre/post, per-phase, per-item)
  - Per-item daisy chain (RED → GREEN → verify → commit)
  - Dispatch indicators (inline/sub-agent/clean-room)
  - Step format (numbered checkbox with sub-bullets, no prescriptive code)
  - Admonishments (compliance top-only, one-step-at-a-time, step status, self-remediation, enforcement gate)
  - Blast radius section
  - Phase file sections (code path coverage, cross-cutting SCs, interface boundaries, state transitions)
  - Prohibited patterns (no dispatch tables, no TBD/TODO, no shared cross-references, no zero-indexed, no line numbers, no multi-dispatch steps, no non-standard indicators, no omitted mandatory gates)
  - Cost frame per phase (dark-prose-007 pattern)
- [ ] 3. Verify: Read the file, diff elements against Phase 2 section list in the spec
- [ ] 4. Commit: `git add .opencode/reference/plan-structure-standards.md && git commit -m "feat(#2210): create plan-structure-standards.md reference doc"`

---

# Phase 3 — Update spec-creation/create.md

**Concern:** Producer template update
**Files:** `.opencode/skills/spec-creation/tasks/create.md`
**SCs:** SC-3
**Dependencies:** Phase 1 committed (reference doc must exist)
**Entry:** Phase 2 committed
**Exit:** `spec-creation/tasks/create.md` Step 2 references spec-structure-standards

### Item 3 (SC-3): Update spec-creation/create.md Step 2

- [ ] 1. RED: Verify Step 2 still has the inline section list (Objective, Background, Not Included, etc.)
- [ ] 2. GREEN: Replace the inline section list in Step 2 with:
  ```
  Read [spec-structure-standards.md](reference/spec-structure-standards.md) and assemble the spec against its required sections.
  ```
  Add `Read [cost-model-standards.md](reference/cost-model-standards.md)` to the Cost Frame section assembly step.
- [ ] 3. Verify: grep for inline section list removed; grep for Read reference to spec-structure-standards; grep for Read reference to cost-model-standards
- [ ] 4. Commit: `git add .opencode/skills/spec-creation/tasks/create.md && git commit -m "feat(#2210): update spec-creation/create.md to read from reference docs"`

---

# Phase 4 — Update writing-plans/create.md

**Concern:** Producer template update
**Files:** `.opencode/skills/writing-plans/tasks/create.md`
**SCs:** SC-4
**Dependencies:** Phase 2 committed (reference doc must exist)
**Entry:** Phase 3 committed
**Exit:** `writing-plans/tasks/create.md` references plan-structure-standards

### Item 4 (SC-4): Update writing-plans/create.md Steps 4-8

- [ ] 1. RED: Verify Steps 4-8 still have inline plan structure descriptions
- [ ] 2. GREEN: Replace the inline plan structure description in Steps 4-8 with a reference to plan-structure-standards.md. Add `Read [cost-model-standards.md](reference/cost-model-standards.md)` to the per-phase cost frame step.
- [ ] 3. Verify: grep for Read reference to plan-structure-standards; grep for Read reference to cost-model-standards
- [ ] 4. Commit: `git add .opencode/skills/writing-plans/tasks/create.md && git commit -m "feat(#2210): update writing-plans/create.md to read from reference docs"`

---

# Phase 5 — Verify no ceremony added

**Concern:** Verification
**Files:** None (verification only)
**SCs:** SC-5
**Dependencies:** Phase 3, 4 committed
**Entry:** All producer templates updated
**Exit:** No ceremony patterns found

### Item 5 (SC-5): Verify no ceremony added

- [ ] 1. RED: (N/A — verification only, no RED phase)
- [ ] 2. GREEN: grep for manifest, schema, backward-compat patterns in all changed files
- [ ] 3. Verify: Confirm no matches found
- [ ] 4. Commit: `git add .opencode/.issues/2210/plan.md && git commit -m "feat(#2210): verify no ceremony added"`

---

# Phase 6 — Create cost-model-standards.md and update producer templates

**Concern:** Reference doc creation + producer template update
**Files:** `.opencode/reference/cost-model-standards.md`, `.opencode/skills/spec-creation/tasks/create.md`, `.opencode/skills/writing-plans/tasks/create.md`
**SCs:** SC-6, SC-7, SC-8
**Dependencies:** Phase 3, 4 committed (producer templates already updated for spec/plan structure)
**Entry:** Phase 5 committed
**Exit:** cost-model-standards.md exists, both producer templates reference it

### Item 6 (SC-6): Create cost-model-standards.md

- [ ] 1. RED: Verify the file does not exist yet
- [ ] 2. GREEN: Create `.opencode/reference/cost-model-standards.md` with:
  - DDL cost model: cost IS defect-discovery-latency, not tool calls
  - Death spiral definition: structural PASS → defect ships → production discovery → 1000× rework
  - Break definition: behavioral FAIL at gate 1 → immediate fix → zero downstream cost
  - Tiered table by evidence type (behavioral/semantic/string/structural) with DDL multiplier and death spiral/break classification
  - Research grounding: IBM 100×, NIST $59.5B, Capers Jones DRE
  - dark-prose-007 formula: computation frame, action cost, skipping cost, identity anchor
  - Examples of correctly formed per-SC cost-frame statements
- [ ] 3. Verify: Read the file, diff sections against Phase 6 section list in the spec
- [ ] 4. Commit: `git add .opencode/reference/cost-model-standards.md && git commit -m "feat(#2210): create cost-model-standards.md reference doc"`

### Item 7 (SC-7): Update spec-creation/create.md Cost Frame section

- [ ] 1. RED: Verify the Cost Frame section in create.md does not yet reference cost-model-standards
- [ ] 2. GREEN: Add `Read [cost-model-standards.md](reference/cost-model-standards.md)` to the Cost Frame section assembly step
- [ ] 3. Verify: grep for Read reference to cost-model-standards in spec-creation/create.md
- [ ] 4. Commit: `git add .opencode/skills/spec-creation/tasks/create.md && git commit -m "feat(#2210): add cost-model-standards reference to spec-creation/create.md"`

### Item 8 (SC-8): Update writing-plans/create.md per-phase cost frame

- [ ] 1. RED: Verify the per-phase cost frame section in create.md does not yet reference cost-model-standards
- [ ] 2. GREEN: Add `Read [cost-model-standards.md](reference/cost-model-standards.md)` to the per-phase cost frame step
- [ ] 3. Verify: grep for Read reference to cost-model-standards in writing-plans/create.md
- [ ] 4. Commit: `git add .opencode/skills/writing-plans/tasks/create.md && git commit -m "feat(#2210): add cost-model-standards reference to writing-plans/create.md"`

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
