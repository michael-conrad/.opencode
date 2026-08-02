---
plan_schema_version: "1.0"
issue: 2214
title: "Consolidate 5 redundant representations in implementation-workflow.md into 3 focused tables"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 4
---

# Implementation Plan — #2214 — Consolidate implementation-workflow.md Redundant Representations

**Goal:** Rewrite `skills/writing-plans/reference/implementation-workflow.md` from 5 redundant representations (Pipeline Step Catalog, Trigger Dispatch Table, Gate Sequence, Audit Sequence Exception, Artifact Pre-Cleanup) into 3 focused tables (Pre-implementation, RED-GREEN Daisy-Chain, Post-implementation), each carrying all 4 columns (step name, owning skill, dispatch string, description) in one place.

**Architecture:** Single-file rewrite. Strip orchestrator-level routing content (YAML frontmatter, Persona, Worktree Mode, Mandatory Task Discipline, DISPATCH_GATE, Sub-Agent Routing). Consolidate 5 data representations into 3 phase-grouped tables. Preserve cross-cutting sections (Per-Task Cycle, Coercion Rules, Artifact Retention). No consumer-side changes — all task files that read this path continue to resolve.

**Files:**
- `skills/writing-plans/reference/implementation-workflow.md`

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Strip orchestrator content | `test-driven-development` | `red`/`green` | `skills/writing-plans/reference/implementation-workflow.md` | SC-1, SC-2 | — |
| 2 — Consolidate 5 representations into 3 tables | `test-driven-development` | `red`/`green` | `skills/writing-plans/reference/implementation-workflow.md` | SC-3, SC-4, SC-6 | 1 |
| 3 — Preserve cross-cutting sections | `test-driven-development` | `red`/`green` | `skills/writing-plans/reference/implementation-workflow.md` | SC-5, SC-7, SC-8 | 2 |
| 4 — Verify cross-references | `test-driven-development` | `red`/`green` | `skills/writing-plans/reference/implementation-workflow.md` | SC-9, SC-10 | 3 |

---

## Phase Details

### Phase 1 — Strip Orchestrator Content

| Field | Value |
|-------|-------|
| Concern | content-purity |
| Skill | `test-driven-development` |
| Task | `red`/`green` |
| Target | `skills/writing-plans/reference/implementation-workflow.md` |
| SCs | SC-1, SC-2 |
| Depends On | — |
| Dispatch Mode | inline |

**Procedure:**

- [ ] 1. Read the current file at `skills/writing-plans/reference/implementation-workflow.md`
- [ ] 2. Remove YAML frontmatter delimiters (`---`) and all frontmatter fields (`name:`, `license:`, `provenance:`)
- [ ] 3. Remove the Persona section
- [ ] 4. Remove the Worktree Mode section
- [ ] 5. Remove the Mandatory Task Discipline section
- [ ] 6. Remove the DISPATCH_GATE section
- [ ] 7. Remove the Sub-Agent Routing section
- [ ] 8. Remove the Invocation section
- [ ] 9. Remove the Orchestrator Entry Criteria section
- [ ] 10. Remove the State Management section
- [ ] 11. Remove the Remediation Routing section
- [ ] 12. Remove the Lifecycle Manifest section
- [ ] 13. Remove the Pipeline Enforcement Rules section
- [ ] 14. Remove the Sub-agent Context Shape section
- [ ] 15. Remove the Context Passing section
- [ ] 16. Remove the Dispatch Mode Verification Gate section
- [ ] 17. Remove the Overflow Signal section
- [ ] 18. Remove the Cross-References section
- [ ] 19. Verify no orchestrator-level routing sections remain (grep for prohibited section headers)
- [ ] 20. Verify no YAML frontmatter with `name:`, `license:`, or `provenance:` remains

### Phase 2 — Consolidate 5 Representations into 3 Tables

| Field | Value |
|-------|-------|
| Concern | table-consolidation |
| Skill | `test-driven-development` |
| Task | `red`/`green` |
| Target | `skills/writing-plans/reference/implementation-workflow.md` |
| SCs | SC-3, SC-4, SC-6 |
| Depends On | 1 |
| Dispatch Mode | inline |

**Procedure:**

- [ ] 1. Read the current file state (post-strip from Phase 1)
- [ ] 2. Remove the Pipeline Step Catalog section
- [ ] 3. Remove the Trigger Dispatch Table section
- [ ] 4. Remove the Gate Sequence section
- [ ] 5. Remove the Audit Sequence Exception section
- [ ] 6. Remove the Artifact Pre-Cleanup section
- [ ] 7. Create the Pre-implementation table with columns: step name, owning skill, dispatch string, description — include all pre-implementation dispatch entries (pre-regression, pre-regression-verify)
- [ ] 8. Create the RED-GREEN Daisy-Chain table with columns: step name, owning skill, dispatch string, description — include all RED/GREEN dispatch entries (red, green, post-regression, verify, commit-inline)
- [ ] 9. Create the Post-implementation table with columns: step name, owning skill, dispatch string, description — include all post-implementation dispatch entries (audit, z3-check, structural-checks, pre-pr-gate, regression-check, review-prep, create-pr, exec-summary)
- [ ] 10. Verify each table has all 4 columns present
- [ ] 11. Verify all current dispatch entries from the spec (REQ-3) are present across the 3 tables
- [ ] 12. Verify no redundant representations remain (grep for removed section headers)

### Phase 3 — Preserve Cross-Cutting Sections

| Field | Value |
|-------|-------|
| Concern | cross-cutting-sections |
| Skill | `test-driven-development` |
| Task | `red`/`green` |
| Target | `skills/writing-plans/reference/implementation-workflow.md` |
| SCs | SC-5, SC-7, SC-8 |
| Depends On | 2 |
| Dispatch Mode | inline |

**Procedure:**

- [ ] 1. Read the current file state (post-consolidation from Phase 2)
- [ ] 2. Verify the Per-Task Cycle section exists and defines the RED→GREEN→COMMIT sequence — if missing, add it
- [ ] 3. Verify the Coercion Rules section exists and documents DONE_WITH_CONCERNS → FAIL and evidence type mismatch rules — if missing, add it
- [ ] 4. Verify the Artifact Retention section exists and documents what gets cleaned when — if missing, add it
- [ ] 5. Verify all 3 cross-cutting sections are standalone (not embedded in tables)
- [ ] 6. Verify no cross-cutting section duplicates content from the 3 focused tables

### Phase 4 — Verify Cross-Reference Integrity

| Field | Value |
|-------|-------|
| Concern | cross-reference-integrity |
| Skill | `test-driven-development` |
| Task | `red`/`green` |
| Target | `skills/writing-plans/reference/implementation-workflow.md` |
| SCs | SC-9, SC-10 |
| Depends On | 3 |
| Dispatch Mode | clean-room |

**Procedure:**

- [ ] 1. Read the final file state
- [ ] 2. Grep for all read paths referencing `implementation-workflow.md` in consuming task files:
  - `skills/writing-plans/tasks/create.md`
  - `skills/writing-plans/tasks/research.md`
  - `skills/writing-plans/tasks/validate.md`
  - `skills/audit/tasks/`
- [ ] 3. Confirm all paths still resolve to the same file path
- [ ] 4. Verify no task file references section anchors that were removed (confirm references point to file path only, not section headers)
- [ ] 5. Report cross-reference integrity status

---

## Exit Criteria

- [ ] C1. File contains only 3 focused tables (Pre-implementation, RED-GREEN Daisy-Chain, Post-implementation) plus cross-cutting sections (Per-Task Cycle, Coercion Rules, Artifact Retention)
- [ ] C2. No YAML frontmatter with `name:`, `license:`, or `provenance:`
- [ ] C3. Pre-implementation table exists with columns: step name, owning skill, dispatch string, description
- [ ] C4. RED-GREEN Daisy-Chain table exists with columns: step name, owning skill, dispatch string, description
- [ ] C5. Per-Task Cycle section defines the RED→GREEN→COMMIT sequence
- [ ] C6. Post-implementation table exists with columns: step name, owning skill, dispatch string, description
- [ ] C7. Coercion Rules section documents DONE_WITH_CONCERNS → FAIL and evidence type mismatch rules
- [ ] C8. Artifact Retention section documents what gets cleaned when
- [ ] C9. All existing cross-references to this file from other task files remain valid after rewrite
- [ ] C10. Plan writer task files (create.md, research.md, validate.md) still read the file at the same path

---

## Lifecycle Events

| Timestamp | Event | Details |
|-----------|-------|---------|
| 2026-08-02T14:48:00Z | `plan_created` | File: `.opencode/.issues/2214/plan.md`, Phases: 4 |
