---
number: 2306
title: "git-workflow-branch submodule-sync task card invites submodule recursion, violating the standing no-`--recursive` guideline and producing false \"changed submodule\" flags"
status: open
labels: [needs-approval, spec-draft]
created: 2026-08-20T02:19:08Z
updated: 2026-08-20T18:26:04Z
remote_issue: 2306
remote_url: "https://github.com/michael-conrad/.opencode/issues/2306"
promoted_at: 2026-08-20T18:26:04Z
promotion_type: retroactive_import
last_sync: 2026-08-20T18:26:04Z
author: michael-newsrx
---

# Spec: Bound submodule-sync task card scope to direct pointers and forbid recursion

## 1. Intent and Executive Summary

1. **Problem Statement:** The task card `.opencode/skills/git-workflow-branch/tasks/submodule-sync.md` instructs syncing "dirty submodule pointers to latest trunk tip" but does not bound scope to the parent repo's direct submodule pointers or forbid recursion into nested submodules. A literal reading invites `git submodule foreach` recursion, which violates the standing no-`--recursive` guideline and produces false "changed submodule" (`+`) flags in the parent repo.

2. **Root Cause / Motivation:** The task card's Step 2 iterates "submodule paths" without an explicit scope bound or recursion prohibition. The standing constraint already exists in `.opencode/guidelines/060-tool-usage.md` §4 but is not mirrored into the task card. Recursion causes the parent repo to see every submodule pointer diverge from the committed SHA, showing all as `M`/`+` — a false-changed-state that triggers needless re-pointer churn and can corrupt branch/PR intent.

3. **Approach Chosen:** Modify the task card text to (a) explicitly bound scope to the parent repo's direct submodule pointers passed in `submodule_paths`, (b) forbid recursion into nested submodules and forbid `git submodule foreach` for the sync operation, (c) mirror the no-`--recursive` language from `060-tool-usage.md` §4, and (d) direct explicit per-submodule operations. Preserve the existing `--ff-only` divergence handling unchanged.

4. **Alternatives Considered & Why Discarded:**
   - *Modify `060-tool-usage.md` to add more language* — discarded: the guideline is already correct and authoritative; the defect is that the task card fails to mirror it.
   - *Change `trunk-tip-verification.md`'s `foreach` usage* — discarded: that is a separate read-only verification concern, out of scope.
   - *Add a runtime guard/script* — discarded: this is a documentation/instruction defect; no runtime code path changes.

5. **Key Design Decisions:**
   - The task card operates only on the `submodule_paths` context variable passed by the orchestrator (already scoped to direct paths).
   - The no-`--recursive` constraint is mirrored verbatim from the authoritative guideline to keep wording consistent.
   - The `--ff-only` divergence handling block is preserved byte-identical to avoid regressing a correct feature.

6. **User Intent / Original Prompt:** The issue reports that an orchestrator acting on the task card (plus a "do this for all submodules" directive) attempted to recurse into nested submodules, violating the no-`--recursive` guideline and producing false "changed submodule" flags. The expected behavior is that the task card bounds scope to direct pointers and forbids recursion.

## 2. Not Included

- **`trunk-tip-verification.md`** — Its read-only use of `git submodule foreach` for verification is a separate concern and out of scope.
- **`reference/submodule-divergence.md`** — The shared divergence reference is not a modification target.
- **`060-tool-usage.md`** — The guideline is already correct; it is the authoritative source to mirror, not to change.
- **Git behavior, config, or runtime** — This is a documentation/instruction fix; no executable code changes.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC-1 | The `submodule-sync.md` task card explicitly bounds scope to the parent repo's direct submodule pointers passed in `submodule_paths`. | structural | Read the task card; assert a scope-bound statement referencing `submodule_paths` and direct pointers | `.opencode/skills/git-workflow-branch/tasks/submodule-sync.md` |
| SC-2 | The task card explicitly forbids recursion into nested submodules. | structural | Read the task card; assert recursion prohibition present | task card; `.opencode/guidelines/060-tool-usage.md` §4 |
| SC-3 | The task card explicitly forbids `git submodule foreach` for the sync operation. | structural | Read the task card; assert `foreach` prohibition present | task card; `.opencode/guidelines/060-tool-usage.md` §4 |
| SC-4 | The task card mirrors the standing no-`--recursive` guideline from `060-tool-usage.md` §4. | structural | Read the task card; assert no-`--recursive` constraint consistent with guideline wording | `.opencode/guidelines/060-tool-usage.md` §4 |
| SC-5 | The task card directs explicit per-submodule operations (not recursive/foreach iteration). | structural | Read the task card; assert explicit per-submodule `git -C <path>` operation directive | task card |
| SC-6 | The task card documents that syncing each submodule to its own trunk tip must not be reported as a parent pointer change (no false `+` flag). | structural | Read the task card; assert false-pointer-flag avoidance note present | task card |
| SC-7 | The existing `--ff-only` divergence handling and autonomous resolution logic is preserved unchanged. | structural | Read the task card; assert divergence block byte-identical to pre-change state | task card |

## 4. Requirements

- R-1. The task card SHALL bound scope to the parent repo's direct submodule pointers passed in `submodule_paths`.
- R-2. The task card SHALL forbid recursion into nested submodules.
- R-3. The task card SHALL forbid `git submodule foreach` for the sync operation.
- R-4. The task card SHALL mirror the no-`--recursive` constraint from `060-tool-usage.md` §4.
- R-5. The task card SHALL direct explicit per-submodule operations.
- R-6. The task card SHALL document that syncing a submodule to its own trunk tip must not be reported as a parent pointer change.
- R-7. The task card SHALL preserve the existing `--ff-only` divergence handling unchanged.

## 5. Items

### Item 1 (SC-1): Add explicit scope-bound statement to task card Step 2

- RED: Enforcement test asserts the task card does not contain a scope-bound statement referencing `submodule_paths`/direct pointers.
- GREEN: Add the scope-bound statement to Step 2.
- verify: Read the task card; assert the scope-bound statement is present.
- commit: Task card text change.

### Item 2 (SC-2): Add explicit recursion prohibition to task card

- RED: Enforcement test asserts the task card does not forbid recursion into nested submodules.
- GREEN: Add recursion prohibition to Step 2.
- verify: Read the task card; assert recursion prohibition present.
- commit: Task card text change.

### Item 3 (SC-3): Add explicit `foreach` prohibition to task card

- RED: Enforcement test asserts the task card does not forbid `git submodule foreach` for the sync operation.
- GREEN: Add `foreach` prohibition to Step 2.
- verify: Read the task card; assert `foreach` prohibition present.
- commit: Task card text change.

### Item 4 (SC-4): Mirror no-`--recursive` guideline language

- RED: Enforcement test asserts the task card lacks the no-`--recursive` constraint.
- GREEN: Add the no-`--recursive` constraint consistent with `060-tool-usage.md` §4.
- verify: Read the task card; assert wording consistent with guideline.
- commit: Task card text change.

### Item 5 (SC-5): Direct explicit per-submodule operations

- RED: Enforcement test asserts the task card does not direct explicit per-submodule operations.
- GREEN: Add explicit per-submodule `git -C <path>` operation directive.
- verify: Read the task card; assert directive present.
- commit: Task card text change.

### Item 6 (SC-6): Document false-pointer-flag avoidance

- RED: Enforcement test asserts the task card does not document false-flag avoidance.
- GREEN: Add a note that syncing to trunk tip must not be reported as a parent pointer change.
- verify: Read the task card; assert note present.
- commit: Task card text change.

### Item 7 (SC-7): Preserve `--ff-only` divergence handling

- RED: Enforcement test asserts the divergence block differs from the pre-change state.
- GREEN: Ensure the divergence block is unchanged.
- verify: Read the task card; assert divergence block byte-identical.
- commit: Task card text change (or no-op if already preserved).

## 6. Dependencies

- **Reference:** `.opencode/guidelines/060-tool-usage.md` §4 — Relationship: authoritative no-`--recursive` constraint to mirror — Status: satisfied.
- **Reference:** `git-workflow-branch/SKILL.md` — Relationship: dispatches the task card with `submodule_paths`; unchanged — Status: satisfied.
- **Reference:** `reference/submodule-divergence.md` — Relationship: shared divergence reference; unchanged — Status: satisfied.

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | Phase 1 |
| R-2 | SC-2 | Phase 1 |
| R-3 | SC-3 | Phase 1 |
| R-4 | SC-4 | Phase 1 |
| R-5 | SC-5 | Phase 1 |
| R-6 | SC-6 | Phase 2 |
| R-7 | SC-7 | Phase 2 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|-------------|----------|
| submodule-sync task card | code | `.opencode/skills/git-workflow-branch/tasks/submodule-sync.md` | read |
| no-`--recursive` guideline | code | `.opencode/guidelines/060-tool-usage.md` §4 | read |
| git-workflow-branch SKILL | code | `.opencode/skills/git-workflow-branch/SKILL.md` | read |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1: Verifying the scope-bound statement costs one read of the task card. Skipping means the task card still invites recursion and the regression ships unchanged.
- SC-2: Verifying the recursion prohibition costs one read. Skipping means nested-submodule recursion continues, violating the guideline.
- SC-3: Verifying the `foreach` prohibition costs one read. Skipping means the sync operation can still recurse via `git submodule foreach`.
- SC-4: Verifying the no-`--recursive` mirror costs one read against the guideline. Skipping means the task card wording diverges from the authoritative source.
- SC-5: Verifying the explicit per-submodule directive costs one read. Skipping means the agent falls back to recursive iteration.
- SC-6: Verifying the false-flag avoidance note costs one read. Skipping means false `+` pointer churn continues to corrupt branch/PR intent.
- SC-7: Verifying the divergence block is byte-identical costs one read. Skipping means a correct feature regresses silently.

## 11. Edge Cases

- **Input boundaries:** Empty `submodule_paths` — the task card SHALL handle an empty list by reporting no submodules to sync without error.
- **State transitions:** A submodule pointer that is already at trunk tip — the task card SHALL report it as already current, not as a change.
- **Failure modes:** `--ff-only` pull fails due to divergence — the task card SHALL preserve the existing autonomous resolution logic (ahead/behind/rebase/escalate).
- **Concurrency:** Multiple submodules synced sequentially — the task card SHALL operate on each direct path independently without cross-contamination.
- **Recovery:** A failed sync on one submodule — the task card SHALL report the failure and continue with remaining direct submodules without recursing.

## 12. Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-08-20 | Decomposed compound SC-2 into two atomic SCs: SC-2 (recursion prohibition, R-2) and SC-3 (`foreach` prohibition, R-3). Renumbered subsequent SCs (SC-4..SC-7), Items (Item 3..Item 7), Traceability, and Cost Frame accordingly. | Validation finding: SC-2 was compound — bundled recursion prohibition and `foreach` prohibition (R-2 and R-3 both mapped to SC-2). | Pipeline validation gate |
