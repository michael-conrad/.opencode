# Plan: Holistic Semantic Evaluation Gate

**Issue:** #1850 — Spec-audit must add holistic semantic evaluation as primary gate
**Authorization scope:** `for_pr` (halt after PR created, stacked PR strategy)
**Branch:** `feature/1850-holistic-semantic-gate`

## Phase Table

| Phase | File | Description | SCs | Dependencies |
|-------|------|-------------|-----|--------------|
| 1 | `plan-01.md` | Central cross-reference file + sync headers | SC-26, SC-27, SC-28 | None |
| 2 | `plan-02.md` | Spec-audit holistic gate (Step 2) + DRAFT protocol | SC-1, SC-2, SC-3, SC-4, SC-9 | Phase 1 |
| 3 | `plan-03.md` | Writing-plans pre-flight gates (create + update) | SC-10, SC-11, SC-12, SC-15, SC-16 | Phase 1 |
| 4 | `plan-04.md` | Plan-fidelity + implementation-pipeline pre-flight gates | SC-13, SC-14, SC-17, SC-18 | Phase 1 |
| 5 | `plan-05.md` | Behavioral enforcement tests (5 new files) | SC-5, SC-6, SC-7, SC-8, SC-19, SC-20, SC-21, SC-22, SC-23, SC-24, SC-25 | Phases 2, 3, 4 |

## Summary

This plan adds an 11-dimension holistic semantic evaluation gate as the primary check in 5 consumer locations (spec-audit, writing-plans create, writing-plans update, plan-fidelity, implementation-pipeline), backed by a central cross-reference file and 5 behavioral enforcement tests. Phase ordering follows dependency order: cross-reference file first, then gates in consumer order, then behavioral tests last.

## Exit Criteria

- All 28 SCs verified PASS
- 5 consumer files modified with holistic gate + sync headers
- 1 new cross-reference file created
- 5 new behavioral test files created
- All existing narrow criteria preserved in spec-audit
- PR created on `feature/1850-holistic-semantic-gate` targeting `main`
