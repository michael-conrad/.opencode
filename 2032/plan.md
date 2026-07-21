# Plan: Strip dispatch markers from task cards

**Issue:** #2032
**Spec:** `.opencode/.issues/2032/spec.md`
**Authorization scope:** `for_pr` (auto-approves plan)
**Created:** 2026-07-21
**Revised:** 2026-07-21 — Added Phase 2 (sub-role entry/exit criteria) and Phase 3 (behavioral test) per audit findings

## Phase Table

| Phase | Description | Depends On | SCs |
|-------|-------------|------------|-----|
| 1 | Strip dispatch markers from 19 task cards | None | SC-1, SC-2, SC-3, SC-5 |
| 2 | Add entry/exit criteria to 12 sub-role task cards + resolve-models.md | Phase 1 | SC-4 |
| 3 | Create behavioral test for SC-7 | Phase 2 | SC-7 |
| 4 | Verify audit SKILL.md TDT documents DiMo chain | Phase 3 | SC-6 |

## SC-to-Step Traceability

| SC ID | Criterion | Phase | Step(s) |
|-------|-----------|-------|---------|
| SC-1 | No task card contains DiMo role descriptions or chain flow documentation | 1 | Strip DiMo markers from 19 files |
| SC-2 | No task card contains dispatch markers | 1 | Strip dispatch markers from 19 files |
| SC-3 | No task card contains "Never task()" or "orchestrator dispatches" | 1 | Strip from cross-validate.md |
| SC-4 | All 31 remediated task cards have entry criteria and exit criteria | 2 | Add to 12 sub-role files + resolve-models.md |
| SC-5 | All remediated task cards are self-contained (inline-only steps) | 1 | Verify no dispatch markers remain |
| SC-6 | audit SKILL.md TDT documents DiMo chain dispatch | 4 | Verify TDT |
| SC-7 | Behavioral test: sub-agent executes remediated task card inline | 3 | Create behavioral test |

## Safety/Rollback Considerations

**Phase 1 — Safety/Rollback:**
- Destructive operations: None (documentation-only edits to `.md` files)
- Rollback plan: `git checkout --` on each modified file
- Data loss risk: None

**Phase 2 — Safety/Rollback:**
- Destructive operations: None (documentation-only edits to `.md` files)
- Rollback plan: `git checkout --` on each modified file
- Data loss risk: None

**Phase 3 — Safety/Rollback:**
- Destructive operations: None (new test file)
- Rollback plan: `rm .opencode/tests-v2/behaviors/task-card-inline-execution.sh`
- Data loss risk: None

## Feasibility Verification

| Step | Reference | Verified? | Evidence |
|------|-----------|-----------|----------|
| 1.1-1.19 | 19 task cards with DiMo content | ✅ | `read` of all files |
| 2.1-2.12 | 12 sub-role files missing entry/exit criteria | ✅ | `grep` confirmed missing |
| 2.13 | resolve-models.md missing exit criteria | ✅ | `grep` confirmed missing |
| 3.1 | Behavioral test template | ✅ | Existing tests in `tests-v2/behaviors/` |
| 4.1 | audit SKILL.md TDT | ✅ | `read` of SKILL.md |

## Evidence/Provenance

| Claim | Evidence Source | Verified? |
|-------|----------------|----------|
| 19 task cards contain dispatch-level markers | `read` of all 19 files | ✅ |
| 12 sub-role files missing entry/exit criteria | `grep` confirmed | ✅ |
| resolve-models.md missing exit criteria | `grep` confirmed | ✅ |
| audit SKILL.md TDT documents DiMo chain | `read` of SKILL.md | ✅ |
| No behavioral test exists for SC-7 | `ls tests-v2/behaviors/` | ✅ |
