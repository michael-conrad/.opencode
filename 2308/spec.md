# [SPEC] Replace residual 'dev' trunk references in git-workflow-cleanup cleanup.md

> **Full spec and artifacts: [`.opencode/.issues/2308/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2308)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2308/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Intent and Executive Summary

| Field | Value |
|-------|-------|
| **Problem Statement** | `skills/git-workflow-cleanup/tasks/cleanup.md` contains 5 residual hardcoded `dev` branch references (lines 109, 141, 146, 180, 327) that reference a trunk that no longer exists |
| **Root Cause / Motivation** | The SEC-Filings-Scraper repo removed its fully-merged `dev` branch in favor of trunk-based development on `master` (issue #50). Commit 7c6f98d4 (#2304) already remediated the executable `dev` references; only prose/label `dev` references remain |
| **Approach Chosen** | Replace the 5 residual `dev` references with dynamic `$DEFAULT_BRANCH` resolution or neutral terminology, matching the existing pattern in `branch-cleanup.md` and `verify-merge.md` |
| **Alternatives Considered & Why Discarded** | Leaving the references as-is (they are stale and mislead agents executing the cleanup workflow); rewriting the whole file (over-scoped — only 5 prose/label references need changing) |
| **Key Design Decisions** | Terminology-only change confined to one task card; executable commands and the `$DEFAULT_BRANCH` resolution block (lines 9-12) are untouched; no behavioral change to cleanup operations |

## Not Included

- **`verify-merge.md` residual `dev` references** (lines 66, 146) — outside the issue's stated scope (cleanup.md only); noted as a related observation
- **`SKILL.md`** — no `dev` references exist
- **`branch-cleanup.md`** — already uses `$DEFAULT_BRANCH`
- **Functional/behavioral change** to branch deletion, sync, or verification logic — this is a documentation/task-card fix only

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC-1 | `cleanup.md` contains zero residual hardcoded `dev` trunk/tip references; all 5 residual references (lines 109, 141, 146, 180, 327) are replaced with `$DEFAULT_BRANCH` or neutral terminology | structural | `grep -nE "origin/dev\|local dev\|at dev\|to dev\|dev tip\|dev HEAD\|dev synced" skills/git-workflow-cleanup/tasks/cleanup.md` returns zero matches | `skills/git-workflow-cleanup/tasks/cleanup.md` (live read) |

## Requirements

R-1. The task card SHALL replace the hardcoded `dev` trunk/tip references in `cleanup.md` with dynamic `$DEFAULT_BRANCH` resolution or neutral terminology.
R-2. The task card SHALL leave the `$DEFAULT_BRANCH` resolution block (lines 9-12) unchanged.
R-3. The task card SHALL NOT alter any executable command in `cleanup.md`.
R-4. The task card SHALL NOT change the operational behavior of the cleanup workflow.

## Items

### Item 1 (SC-1): Replace residual 'dev' trunk references with $DEFAULT_BRANCH

- RED: `grep -nE "origin/dev|local dev|at dev|to dev|dev tip|dev HEAD|dev synced" skills/git-workflow-cleanup/tasks/cleanup.md` returns matches
- GREEN: Replace the 5 residual references:
  - Line 109: "Switches to dev" → "Switches to $DEFAULT_BRANCH"
  - Line 141: "Get local dev HEAD:" → "Get local $DEFAULT_BRANCH HEAD:"
  - Line 146: "Get remote dev HEAD:" → "Get remote $DEFAULT_BRANCH HEAD:"
  - Line 180: "ready for next dev cycle" → "ready for next cycle"
  - Line 327: "Local dev synced" → "Local $DEFAULT_BRANCH synced"
- verify: `grep -nE "origin/dev|local dev|at dev|to dev|dev tip|dev HEAD|dev synced" skills/git-workflow-cleanup/tasks/cleanup.md` returns zero matches
- commit: single atomic commit

## Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| Commit 7c6f98d4 (#2304) | Already remediated executable `dev` references; this spec completes the residual prose/label cleanup | Satisfied |
| `$DEFAULT_BRANCH` resolution pattern (branch-cleanup.md, verify-merge.md) | Pattern to follow for dynamic trunk resolution | Satisfied |

## Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | Phase 1 |
| R-2 | SC-1 | Phase 1 |
| R-3 | SC-1 | Phase 1 |
| R-4 | SC-1 | Phase 1 |

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| cleanup.md | code | `skills/git-workflow-cleanup/tasks/cleanup.md` | Live read during pre-spec inspection |
| branch-cleanup.md | code | `skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md` | Live read — uses $DEFAULT_BRANCH |
| verify-merge.md | code | `skills/git-workflow-cleanup/tasks/cleanup/verify-merge.md` | Live read — uses $DEFAULT_BRANCH |

## Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1: Verifying zero residual `dev` references costs one grep call. Skipping means a stale `dev` reference misleads the next agent executing the cleanup workflow, and the defect isn't caught until the workflow is mis-executed against a non-existent branch.

## Edge Cases

- **Condition:** A residual `dev` reference is missed during replacement.
  - **Expected behavior:** The grep verification returns a match, failing SC-1.
  - **Resolution:** The missed reference is replaced and verification re-run.
- **Condition:** A replacement accidentally alters an executable command.
  - **Expected behavior:** The executable command semantics change, violating R-3.
  - **Resolution:** The command is restored; only prose/label references are modified.
- **Condition:** `$DEFAULT_BRANCH` resolution fails (no remote).
  - **Expected behavior:** The fallback `DEFAULT_BRANCH="main"` applies per the existing resolution block.
  - **Resolution:** No change needed — the resolution block is untouched.
