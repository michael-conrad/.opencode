# Card Catalogue — Spec Structure Expansion

## STATUS: spec
## SCOPE: spec-structure-expansion
## DEPENDENCIES: [#850](https://github.com/michael-conrad/.opencode/issues/850)
## ITEMS COVERED: 3,8,11,12,13,14,15,16,17,18,19,20,31,32,34,40,41,42

## Cards

### Card 1: Item mapping to SCs

| Item | Subject | SC(s) | Status |
|------|---------|-------|--------|
| 3 | Explicit Non-Goals section | SC-11 | COVERED |
| 8 | Regression Invariants subsection | SC-12 | COVERED |
| 11 | Pipeline Step Binding column | SC-1 | COVERED |
| 12 | Artifact Path column + ./tmp/{issue-N}/ convention | SC-1, SC-17 | COVERED |
| 13 | Requirement Traceability column (mandatory all tiers) | SC-1, SC-2 | COVERED |
| 14 | Decision Ledger in spec preamble | SC-7, SC-8 | COVERED |
| 15 | Risk Traceability Table | SC-7, SC-9 | COVERED |
| 16 | SC-to-SC Coherence check in self-review | SC-13 | COVERED |
| 17 | Revision Policy section in preamble | SC-7, SC-10 | COVERED |
| 18 | Decomposition Classification annotation | SC-7, SC-18 | COVERED |
| 19 | Phase Binding column (multi-phase only) | SC-1, SC-3 | COVERED |
| 20 | Verification Gate column (3 tiers) | SC-1, SC-4 | COVERED |
| 31 | Integration Mode column for CI-gate SCs | SC-1, SC-5 | COVERED |
| 32 | Spec-Family annotation (punch list) | SC-7, SC-19 | COVERED |
| 34 | Cross-cutting (common) SC designation | SC-15 | COVERED |
| 40 | SC Affinity Groups for shared verification | SC-16 | COVERED |
| 41 | Verification-Method-to-Artifact-Path consistency check | SC-14 | COVERED |
| 42 | SC Re-Entry Binding column | SC-1, SC-6 | COVERED |

### Card 2: Column conditionality matrix

| Column | Mandatory All Tiers | Multi-Phase Only | CI-Gate Only | Optional |
|--------|---------------------|------------------|--------------|----------|
| Pipeline Step Binding | YES | — | — | — |
| Artifact Path | YES | — | — | — |
| Requirement Traceability | **YES (MUST)** | — | — | — |
| Phase Binding | — | YES | — | — |
| Verification Gate | YES (3 tiers) | — | — | — |
| Integration Mode | — | — | YES (when Gate=ci) | otherwise |
| Affinity Group | — | — | — | YES |
| Re-Entry Step | **YES (all tiers)** | — | — | — |

**Status**: DESIGNED — column conditions documented per SC-2 through SC-6 and reflected in SC-1 column header definitions.

### Card 3: Preamble section status

| Section | Mandatory | Status |
|---------|-----------|--------|
| Decision Ledger | YES (complex/standard specs) | SC-7, SC-8 |
| Risk Traceability Table | YES (complex/standard specs) | SC-7, SC-9 |
| Revision Policy | YES (complex/standard specs) | SC-7, SC-10 |
| Decomposition Classification | YES (complex/standard specs) | SC-7, SC-18 |
| Spec Family Annotation | OPTIONAL (punch list) | SC-7, SC-19 |

**Status**: DESIGNED — all 5 preamble sections defined with purpose sentences and example blocks per SC-7.

### Card 4: Content area status

| Content Area | Mandatory | Template Header | SC |
|-------------|-----------|-----------------|-----|
| Explicit Non-Goals | YES (all specs) | `## Explicit Non-Goals` | SC-11 |
| Regression Invariants | YES (all specs) | `## Regression Invariants` | SC-12 |
| Cross-cutting/Common SC designation | YES (multi-phase) | Column annotation or preamble marker | SC-15 |

**Status**: DESIGNED — both content areas are mandatory per SC-11 and SC-12; Common SC designation documented per SC-15.

### Card 5: Self-review substeps

| Substop | Check | SC |
|---------|-------|-----|
| SC-to-SC coherence | Pairwise comparison scan for contradictions | SC-13 |
| Verification-Method-to-Artifact-Path | Cross-column consistency check | SC-14 |

**Status**: DESIGNED — both substeps appended to existing Step 6 self-review per SC-13 and SC-14.

### Card 6: Evidence type rationale

All 19 SCs are classified as `string` evidence type:

- **Rationale**: Implementation targets `write.md` prose/formatting changes only — adding new column headers, section definitions, template headers, and substep descriptions. No runtime behavioral changes to agent dispatch, tool selection, decision-making, or enforcement gates.
- **Verification method**: `grep` for pattern presence in the modified `write.md` file.
- **No behavioral RED/GREEN required**: Per `080-code-standards.md` §Evidence Type Taxonomy, behavioral testing is required when the change affects runtime behavior. Adding table columns and section headers to a task file does not affect runtime behavior — agents read the new content during spec generation, but the content (not the agent's reading) is the deliverable.

**Status**: CONFIRMED

### Card 7: Word count risk for write.md

| Metric | Current | With Expansion | Limit |
|--------|---------|----------------|-------|
| Lines | 331 | ~450-480 (est.) | — |
| Words | ~2,700 (est.) | ~3,600-3,900 (est.) | 3,000 |

- **Risk**: write.md may exceed the 3,000-word limit per `091-incremental-build.md` task file constraint.
- **Mitigation**: If implementation detects word count approaching 3,000, preamble section definitions (Decision Ledger, Risk Traceability, Revision Policy, Decomposition Classification, Spec Family) MUST be moved to a reference file under `.opencode/skills/spec-creation/reference/preamble-sections.md` with write.md referencing the file via a one-sentence include statement per section.
- **Trigger**: `wc -w write.md` > 2,800 during implementation triggers the split decision.

**Status**: OPEN — flagged as RISK-1 in spec risk table.

### Card 8: Grandfather clause precedent

Per `080-code-standards.md` §Numbering grandfather clause, existing specs written before this change are NOT subject to retroactive column expansion. Only newly created specs after implementation MUST include the new columns. This is documented in the Edge Cases section.

**Status**: AGREED

### Card 9: Behavioral enforcement test — deferred

Per spec format mandate (write.md Step 0.5), behavioral enforcement tests are written during implementation, not spec creation. However, since all 19 SCs are `string` evidence type, no behavioral RED/GREEN cycle is required. The implementation plan MUST include content-verification test assertions (grep-based) for each SC's pattern.

**Status**: NOTED — deferred to implementation plan

<!-- Provenance: AI-generated -->
<!-- Co-authored with AI: OpenCode (deepseek-v4-flash) -->