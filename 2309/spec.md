---
number: 2309
title: "[BUG] tools/session-init references 'dev branch' creation from origin/dev"
status: open
labels:
- needs-approval
- spec-draft
created: 2026-08-20T03:08:06Z
updated: 2026-08-20T18:26:18Z
remote_issue: 2309
remote_url: "https://github.com/michael-conrad/.opencode/issues/2309"
promoted_at: 2026-08-20T18:26:18Z
promotion_type: retroactive_import
last_sync: 2026-08-20T18:26:18Z
author: michael-newsrx
---

> **Full spec and artifacts: [`.opencode/.issues/2309/`](https://github.com/michael-conrad/.opencode/tree/issues-data/.issues/2309/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2309/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# Spec: Correct stale 'Guard checks' docstring in tools/session-init

## 1. Intent and Executive Summary

| # | Field | Description |
|---|-------|-------------|
| 1 | **Problem Statement** | The "Guard checks" docstring section in `tools/session-init` (line 36) references a `dev branch: Create from origin/dev or main/master if missing` guard check that no longer exists in the code. |
| 2 | **Root Cause / Motivation** | The `_ensure_dev_branch()` function that implemented the dev-branch guard check was removed in commit bb2851f0 (#1657), and the worktree bootstrap was removed in commit 77459166 (#1659). The docstring was not updated at those times, leaving stale references to removed behavior. |
| 3 | **Approach Chosen** | Correct the docstring: remove the stale `dev branch` and `.worktrees/main/` lines, preserving the still-current `.env gitignore` line. This is a documentation-only correction — no code logic is changed. |
| 4 | **Alternatives Considered & Why Discarded** | The issue's proposed fix — "resolve the trunk dynamically via `$DEFAULT_BRANCH`, not a hardcoded `dev`" — presumes a dev-branch guard check still exists. It does not; the code was already removed. Re-introducing a `$DEFAULT_BRANCH`-based branch-creation guard check would add dead logic contradicting the trunk-based-development model. Discarded in favor of docstring correction. |
| 5 | **Key Design Decisions** | Docstring-only change: no runtime behavior, no function signatures, no output format changes. The docstring must accurately enumerate only the guard checks `run_guard_checks()` actually performs. |
| 6 | **User Intent / Original Prompt** | Issue #2309: "tools/session-init references 'dev branch' creation from origin/dev" — the SEC-Filings-Scraper repo no longer has a `dev` branch (trunk-based development on `master`). |

## 2. Not Included

- **`scripts/validate-submodule-refs.sh`** — defaults `BRANCH='dev'` (line 9); a separate file with the same hardcoded-dev pattern but out of scope for #2309.
- **`scripts/session_context_triggers.py`** — diffs against `origin/dev..HEAD` (line 70); a separate file, out of scope.
- **Re-introducing a `$DEFAULT_BRANCH`-based branch-creation guard check** — the guard check was intentionally removed in #1657; trunk-based development uses `$DEFAULT_BRANCH`.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC-1 | The "Guard checks" docstring in `tools/session-init` no longer references a `dev branch` guard check or the `.worktrees/main/` bootstrap, and still references the `.env gitignore` guard check. | structural | `grep -n 'dev branch\|origin/dev\|worktrees/main' tools/session-init` returns no match in the docstring; `grep -n '.env gitignore' tools/session-init` still matches. | `tools/session-init` (source); commit bb2851f0; commit 77459166 |

## 4. Requirements

- R-1. The "Guard checks" docstring in `tools/session-init` SHALL NOT reference a `dev branch` guard check or any `origin/dev` branch-creation behavior.
- R-2. The "Guard checks" docstring SHALL NOT reference the `.worktrees/main/` worktree bootstrap.
- R-3. The "Guard checks" docstring SHALL retain the `.env gitignore` guard check line, as `_check_credential_files_gitignored()` still exists and is called by `run_guard_checks()`.
- R-4. The fix SHALL be limited to `tools/session-init`; `scripts/validate-submodule-refs.sh` and `scripts/session_context_triggers.py` SHALL NOT be modified.
- R-5. The fix SHALL NOT re-introduce a dev-branch or `$DEFAULT_BRANCH`-based branch-creation guard check.

## 5. Items

### Item 1 (SC-1): Correct the stale 'Guard checks' docstring in tools/session-init

- RED: Structural assertion that the docstring still contains `dev branch` or `origin/dev` (fails — the stale line is present).
- GREEN: Edit the docstring to remove the stale `dev branch` and `.worktrees/main/` lines, preserving the `.env gitignore` line.
- verify: `grep -n 'dev branch\|origin/dev\|worktrees/main' tools/session-init` returns no match; `grep -n '.env gitignore' tools/session-init` matches; run `uv run pytest .opencode/tests/` for regression.
- commit: The docstring edit in `tools/session-init`.

## 6. Dependencies

- **Reference:** Issue #1657 (commit bb2851f0) — removed `_ensure_dev_branch()`. **Relationship:** Established that the dev-branch guard check no longer exists. **Status:** Satisfied.
- **Reference:** Issue #1659 (commit 77459166) — removed worktree bootstrap. **Relationship:** Established that the `.worktrees/main/` docstring line is stale. **Status:** Satisfied.

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | Phase 1 |
| R-2 | SC-1 | Phase 1 |
| R-3 | SC-1 | Phase 1 |
| R-4 | SC-1 | Phase 1 |
| R-5 | SC-1 | Phase 1 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| `tools/session-init` | code | `.opencode/tools/session-init` | `grep -n 'dev branch\|origin/dev\|worktrees/main\|.env gitignore'` |
| Commit bb2851f0 | code | git history | `git show bb2851f0 -- tools/session-init` |
| Commit 77459166 | code | git history | `git show 77459166 --stat` |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1: Verifying the docstring no longer references removed guard checks costs one grep search. Skipping means the stale docstring misleads the next engineer into believing a dev-branch guard check exists, propagating the documentation defect into future work.

## 11. Edge Cases

- **Input boundaries:** The docstring is static text; no input boundaries apply.
- **State transitions:** The docstring transitions from referencing removed guard checks to accurately enumerating current guard checks. `run_guard_checks()` behavior is unchanged throughout.
- **Failure modes:** If the edit accidentally removes the still-current `.env gitignore` line, the docstring would understate the actual guard checks. Mitigated by the structural assertion in SC-1.
- **Concurrency:** Not applicable — docstring-only change, no shared state.
- **Recovery:** If the edit is incorrect, the docstring can be reverted via git; no runtime impact.
