> **Full spec and artifacts: [`.opencode/.issues/2167/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2167)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2167/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Objective

Fix the stale-artifact problem: when a spec is revised via the spec-creation revise pipeline, the analytical artifacts in `.opencode/.issues/{N}/artifacts/` become stale. The audit skill currently halts with "developer intervention required" when stale artifacts are detected — this should instead auto-delete stale artifacts and route to backfill for fresh generation.

## Background

The spec-creation pipeline generates 7 analytical artifacts (blast radius, concern map, code path inventory, cross-cutting matrix, interface compatibility, state analysis, testability assessment) during initial spec creation. When a spec is later revised via the spec-creation revise pipeline, these artifacts are NOT updated — they become stale because they were generated from the pre-revision spec.

The audit skill's Mandatory Task Discipline section defines three artifact-missing scenarios:

- **(a) Missing at orchestration level** — routes to backfill (correct)
- **(b) Missing discovered by sub-agent** — routes to backfill (correct)
- **(c) Stale artifacts** — HALT with "developer intervention is required" (WRONG)

Scenario (c) is incorrect because:
1. It claims backfill "would reproduce the same outdated content" — this is false. Backfill generates artifacts FROM THE SPEC BODY, not from existing artifacts. After a spec revision, the spec body IS current, so backfill would produce correct fresh artifacts.
2. Developer intervention is unnecessary — the pipeline can auto-delete stale artifacts and route to backfill autonomously.

Additionally, the spec-creation revise pipeline has no step to clean stale artifacts after revision. Adding a cleanup step proactively prevents stale artifacts from accumulating.

## Not Included

- Changes to the backfill task itself (it correctly fills gaps — the fix is to delete stale artifacts first)
- Changes to scenarios (a) or (b) (they already route to backfill correctly)
- Changes to the audit skill's Overview section (it already says stale artifacts route to backfill)
- Behavioral enforcement tests (this is a string/semantic change to skill/task files)

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Audit SKILL.md scenario (c) changed: stale artifacts trigger auto-delete + backfill, not HALT | string | grep for absence of 'developer intervention is required' in scenario (c) |
| SC-2 | Audit SKILL.md scenario (c) includes explicit instruction to delete stale artifact files before routing to backfill | string | grep for 'delete stale artifact' or 'rm' in scenario (c) |
| SC-3 | spec-creation/tasks/revise.md includes a step to delete stale artifacts after revision | string | grep for 'artifact' and 'delete' or 'clean' in revise.md |
| SC-4 | No orphaned cross-references to old "developer intervention required" language | string | grep for 'developer intervention is required' across .opencode/ — only expected matches remain |
| SC-5 | All 3 artifact-missing scenarios (a, b, c) now route to backfill uniformly | semantic | Read all 3 scenarios, verify they all route to backfill |

## Requirements

1. The audit SKILL.md Mandatory Task Discipline scenario (c) SHALL be changed from "HALT + developer intervention" to "delete stale artifacts + route to backfill".
2. The audit SKILL.md scenario (c) SHALL include explicit instructions to delete stale artifact files before routing to backfill.
3. The spec-creation/tasks/revise.md SHALL include a step to delete stale analytical artifacts after revision is complete.
4. All orphaned cross-references to the old "developer intervention required" language SHALL be removed.
5. All 3 artifact-missing scenarios SHALL route to backfill uniformly.

## Items

| Item | SC | Description |
|------|----|-------------|
| 1 | SC-1, SC-2 | Fix audit SKILL.md scenario (c): change from HALT to auto-delete + backfill |
| 2 | SC-3 | Add artifact cleanup step to spec-creation/tasks/revise.md |
| 3 | SC-4, SC-5 | Verify no orphaned references and uniform backfill routing |

## Phases

### Phase 1: Fix audit SKILL.md scenario (c) [R1, R2]
Dispatch: RED/GREEN sub-agent

### Phase 2: Add artifact cleanup step to revise.md [R3]
Dispatch: RED/GREEN sub-agent

### Phase 3: Verify no orphaned references and uniform routing [R4, R5]
Dispatch: verification sub-agent

## Dependencies

- None — this is a self-contained fix to skill/task files

## Traceability

| Requirement | SC(s) | Phase |
|-------------|-------|-------|
| R1 | SC-1, SC-2 | 1 |
| R2 | SC-2 | 1 |
| R3 | SC-3 | 2 |
| R4 | SC-4 | 3 |
| R5 | SC-5 | 3 |

## Change Control

| Date | Change | Reason | Author |
|------|--------|--------|--------|
| 2026-07-27 | Added Phases section with 3 phases and REQ references in headings | Validation: Completeness FAIL (missing Phases section), Phase coverage FAIL | spec-creation revise pipeline |
