# Phase 2 — Part A1: Create 7 New Analytical Task Files

**Concern:** Create new task files for spec-creation pipeline analytical depth

**Files:**
- `.opencode/skills/spec-creation/tasks/blast-radius.md` (NEW)
- `.opencode/skills/spec-creation/tasks/concern-analysis.md` (NEW)
- `.opencode/skills/spec-creation/tasks/cross-cutting.md` (NEW)
- `.opencode/skills/spec-creation/tasks/code-path-analysis.md` (NEW)
- `.opencode/skills/spec-creation/tasks/interface-compatibility.md` (NEW)
- `.opencode/skills/spec-creation/tasks/state-analysis.md` (NEW)
- `.opencode/skills/spec-creation/tasks/testability-assessment.md` (NEW)

**SCs:** SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-21

**Dependencies:** Phase 1

**Entry Criteria:** Phase 1 complete, baseline established

**Exit Criteria:** All 7 new task files exist with correct methodology (tool-agnostic, methodology-driven)

## Step-by-Step

- [ ] 6. (**sub-agent**) Create `blast-radius.md` — Dependency impact analysis methodology
  - Read `writing-plans/tasks/write.md` for format reference
  - Content: Purpose, Entry/Exit Criteria, Procedure with methodology for dependency graph traversal, data-flow impact mapping, impact classification (direct consumer, indirect consumer, data-flow dependent)
  - Must be tool-agnostic — describes *what to analyze and how to reason*, not which tool to call
  - SC: SC-1, SC-21

- [ ] 7. (**sub-agent**) Create `concern-analysis.md` — Separation of concerns methodology
  - Content: Methodology for concern boundary identification, overlap detection, leakage detection, concern-to-unit mapping
  - Tool-agnostic methodology
  - SC: SC-2, SC-21

- [ ] 8. (**sub-agent**) Create `cross-cutting.md` — Cross-cutting concerns methodology
  - Content: Methodology for discovering concerns spanning multiple phases/components, producing propagation maps, concern-to-phase matrix
  - Tool-agnostic methodology
  - SC: SC-3, SC-21

- [ ] 9. (**sub-agent**) Create `code-path-analysis.md` — Code path coverage methodology
  - Content: Methodology for enumerating all execution paths, mapping data flow through each path (inputs → transformations → outputs → side effects), mandating path-level test coverage
  - Tool-agnostic methodology
  - SC: SC-4, SC-21

- [ ] 10. (**sub-agent**) Create `interface-compatibility.md` — Contract compatibility methodology
  - Content: Methodology for verifying decomposed unit interfaces are compatible, comparing input/output types, verifying pre/postconditions
  - Tool-agnostic methodology
  - SC: SC-5, SC-21

- [ ] 11. (**sub-agent**) Create `state-analysis.md` — State machine/lifecycle methodology
  - Content: Methodology for modeling state transitions, verifying completeness (no deadlock states, no unreachable states, all transitions defined)
  - Tool-agnostic methodology
  - SC: SC-6, SC-21

- [ ] 12. (**sub-agent**) Create `testability-assessment.md` — Pre-finalization testability methodology
  - Content: Methodology for verifying SC testability with available tooling before spec finalization, evidence type classification, environment availability check
  - Tool-agnostic methodology
  - SC: SC-7, SC-21

## Phase Completion

- [ ] All 7 new task files exist at `.opencode/skills/spec-creation/tasks/`
- [ ] Each file has Purpose, Entry/Exit Criteria, Procedure sections
- [ ] Each file describes methodology in tool-agnostic terms
- [ ] No file names specific tools

## Concern Transition

Phase 2 creates the new analytical task files. Phase 3 deepens the 6 existing task files with additional methodology.
