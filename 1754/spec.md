> **Full spec and artifacts: `.opencode/.issues/1060/`**

## Exec Summary

The `write.md` skill for spec-creation produces specs with basic SC tables (4 columns), optional preamble sections, and a 4-step self-review. Over 42 items of spec-output requirements from cross-project analysis remain unmapped — SCs lack traceability, verification gates, artifact paths, and binding metadata. The solution adds 8 new SC table columns, 5 new preamble sections, 2 new mandatory content areas, and 2 new self-review substeps.

### Cards (dependency order)
1. **SC Table Columns** — 8 new columns: Pipeline Step Binding, Artifact Path, Requirement Traceability, Phase Binding, Verification Gate, Integration Mode, Affinity Group, Re-Entry Step
2. **Preamble Sections** — 5 new: Decision Ledger, Risk Traceability Table, Revision Policy, Decomposition Classification, Spec Family Annotation
3. **Self-Review Checks** — SC-to-SC coherence check, Verification-Method-to-Artifact-Path consistency check

### Key Decisions
- **Requirement Traceability is mandatory all tiers** — not conditional like other new columns
- **Existing 4-column format is the base** — new columns are additions, not replacements
- **Grandfather clause** — no retroactive migration for existing specs

### Risk Callouts
- **12-column SC table may exceed readability** — rendering note with fork-table pattern for >8 columns
- **3,000-word limit pressure** — write.md may need structural split if additions push over limit

## AI Agent Instructions

This issue is an executive summary for human stakeholders.
The authoritative spec and plan artifacts are at `.opencode/.issues/1060/`.
After creation, `local-issues sync 1060` MUST be run and the result committed to create the local `.issues/1060/` entry.
The implementation plan will be created in `.issues/1060/plan.md` after approval.
AI agents MUST read the local spec/plan files for implementation
and MUST NOT base implementation on this summary.

---
*Migrated from local tracking. Original local directory: `.opencode/.issues/1060/`*