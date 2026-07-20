> **Full spec and artifacts: `.opencode/.issues/1063/`**

## Exec Summary

Add five pipeline enforcement gates that close gaps in the current pipeline's enforcement coverage: an evidence-type uplift scan at `sc-coherence-gate` (catches behavioral SCs declared as structural), a doc-source-currency check at `pre-red-baseline` (re-verifies spec file paths before RED-phase), SC-ID traceability verification (all spec SC-IDs have plan references), semantic-intent verification at `green-doublecheck` (PASS satisfies spec intent), RED/GREEN anti-merge enforcement (git diff structural gates), and mandatory SC-ID referencing format for plan TDD tasks.

### Cards (dependency order)
1. **Evidence-type uplift scan** — sc-coherence-gate step validates SC evidence type vs substrate classification
2. **Doc-source-currency check** — pre-red-baseline re-verifies spec file paths, signatures, config
3. **SC-ID traceability** — all spec SC-IDs must have plan TDD task references
4. **Anti-merge enforcement** — RED must not touch src/, GREEN must not touch test/

### Key Decisions
- **Six items merged into one spec** — all modify the same files (pipeline SKILL.md + TDD task files)
- **Grandfather existing plans** — only new plans after PR merge must use SC-ID parenthetical format

### Risk Callouts
- **Git diff gate may false-positive on generated files** — scope limited to `-- src/` and `-- test/`
- **Dependencies on #1060 and #1062** — pipeline routing table and plan handoff must be ready first

## AI Agent Instructions

This issue is an executive summary for human stakeholders.
The authoritative spec and plan artifacts are at `.opencode/.issues/1063/`.
After creation, `local-issues sync 1063` MUST be run and the result committed to create the local `.issues/1063/` entry.
The implementation plan will be created in `.issues/1063/plan.md` after approval.
AI agents MUST read the local spec/plan files for implementation
and MUST NOT base implementation on this summary.

---
*Migrated from local tracking. Original local directory: `.opencode/.issues/1063/`*