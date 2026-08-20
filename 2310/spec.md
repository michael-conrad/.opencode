---
number: 2310
title: "[BUG] scripts/session_context_triggers.py uses hardcoded 'origin/dev' in diff stat"
status: open
labels: []
created: 2026-08-20T03:08:06Z
updated: 2026-08-20T03:08:06Z
remote_issue: 2310
remote_url: "https://github.com/michael-conrad/.opencode/issues/2310"
promoted_at: 2026-08-20T18:30:00Z
promotion_type: retroactive_import
last_sync: 2026-08-20T18:30:00Z
author: michael-newsrx
---

> **Full spec and artifacts: [`.opencode/.issues/2310/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2310)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2310/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# Spec: Dynamic Trunk Resolution in session_context_triggers.py

## 1. Intent and Executive Summary

| # | Field | Description |
|---|-------|-------------|
| 1 | **Problem Statement** | `build_pair_mode_resume()` in `.opencode/scripts/session_context_triggers.py` line 70 runs `git diff --stat origin/dev..HEAD`. Repos that use trunk-based development on `master` or `main` (with the `dev` branch removed) cause this command to fail, so the pair-mode resume trigger silently omits its diff-stat summary. |
| 2 | **Root Cause / Motivation** | The diff stat hardcodes the `origin/dev` ref. The `dev` branch has been removed across this ecosystem in favor of trunk-based development directly on `master`/`main`. `run_git()` returns `None` on failure, so the diff stat silently disappears rather than surfacing an error. This must be fixed now because pair-mode resume output is incomplete on every trunk-based repo. |
| 3 | **Approach Chosen** | Add a `get_default_branch()` helper that resolves the trunk branch dynamically via `git remote show origin` (parsing the `HEAD branch:` line), with a `main` fallback when resolution fails. `build_pair_mode_resume()` uses the resolved branch to compute the diff stat. |
| 4 | **Alternatives Considered & Why Discarded** | **Hardcode `main`** — discarded because SEC-Filings-Scraper uses `master`; a hardcoded `main` reproduces the same bug for that repo. **Use `git symbolic-ref refs/remotes/origin/HEAD`** — discarded because it requires the remote HEAD symref to be set locally, which is not guaranteed; `git remote show origin` is the established codebase pattern. |
| 5 | **Key Design Decisions** | (1) Reuse the existing `run_git()` helper for remote inspection — no new subprocess handling. (2) Follow the canonical trunk-resolution pattern already present in 5 task files (`git remote show origin` HEAD branch, fallback `main`). (3) Keep `build_pair_mode_resume(branch: str) -> str` signature unchanged — backward compatible. (4) No external dependencies — PEP 723 `dependencies = []` preserved. |
| 6 | **User Intent / Original Prompt** | Issue #2310: "Resolve the trunk dynamically via `$DEFAULT_BRANCH` (`git remote show origin` HEAD branch), not hardcoded `origin/dev`." |

## 2. Not Included

- **[Feedback boundary detection]** — `check_feedback_in_recent_commits()` is out of scope; no change to feedback pattern detection.
- **[Nested opencode detection]** — `has_nested_opencode()` / `build_nested_opencode_warning()` are out of scope.
- **[Trigger emitter structure]** — the trigger structure (only `pair_mode_resume` and `nested_opencode_fatal` remain) and exit codes are unchanged.
- **[Other hardcoded refs]** — only the diff-stat ref in `build_pair_mode_resume()` is addressed; no other refs are modified.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC-1 | `build_pair_mode_resume()` computes the diff stat against the dynamically resolved trunk branch (e.g., `origin/master..HEAD` or `origin/main..HEAD`), never the hardcoded `origin/dev`, and falls back to `main` when the remote HEAD branch cannot be resolved. | behavioral | Behavioral enforcement test via `with-test-home`: send a real-domain prompt in a pair-mode branch context; assert stderr shows the script resolves the trunk dynamically (no `origin/dev`) and computes the diff stat against the resolved trunk. | `.opencode/scripts/session_context_triggers.py`; canonical pattern in `.opencode/skills/completion-core/completion-core.md`, `.opencode/skills/finishing-a-development-branch/tasks/prepare.md`, `.opencode/skills/finishing-a-development-branch/tasks/checklist.md`, `.opencode/skills/verification-before-completion/tasks/verify.md`, `.opencode/skills/git-workflow-commit/tasks/pair-commit.md` |

## 4. Requirements

- R-1. The script SHALL resolve the trunk branch dynamically via `git remote show origin` HEAD branch, not a hardcoded `origin/dev`.
- R-2. The diff stat SHALL be computed against the resolved trunk branch.
- R-3. When the remote HEAD branch cannot be resolved, the script SHALL fall back to `main`.
- R-4. For local-only repos (no remote), the script SHALL omit the diff stat gracefully without crashing.
- R-5. The script SHALL preserve existing pair-mode resume behavior: the diff-stat summary is appended only when a diff exists.
- R-6. The fix SHALL follow the established codebase trunk-resolution pattern (`git remote show origin` HEAD branch, fallback `main`).
- R-7. The fix SHALL NOT change the trigger structure (only `pair_mode_resume` and `nested_opencode_fatal` remain).
- R-8. The fix SHALL NOT introduce external dependencies (PEP 723 `dependencies = []` preserved).

## 5. Items

### Item 1 (SC-1): Resolve trunk branch dynamically in session_context_triggers.py diff stat

- RED: Behavioral test asserts the script does NOT resolve the trunk dynamically (hardcoded `origin/dev` present) — FAIL.
- GREEN: Implement `get_default_branch()` helper and use it in `build_pair_mode_resume()`; behavioral test asserts dynamic resolution — PASS.
- verify: Run behavioral test via `with-test-home`; assert stderr shows dynamic trunk resolution.
- commit: Test + change committed as one working slice.

## 6. Dependencies

- **Reference:** Canonical trunk-resolution pattern in `.opencode/skills/completion-core/completion-core.md` and 4 other task files.
- **Relationship:** The fix must mirror this established pattern for consistency.
- **Status:** Satisfied — pattern is present and verified in the codebase.

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | Phase 1 |
| R-2 | SC-1 | Phase 1 |
| R-3 | SC-1 | Phase 1 |
| R-4 | SC-1 | Phase 1 |
| R-5 | SC-1 | Phase 1 |
| R-6 | SC-1 | Phase 1 |
| R-7 | SC-1 | Phase 1 |
| R-8 | SC-1 | Phase 1 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| `session_context_triggers.py` | code | `.opencode/scripts/session_context_triggers.py` | read — line 70 hardcodes `origin/dev..HEAD` |
| Canonical trunk-resolution pattern | code | `.opencode/skills/completion-core/completion-core.md`, `.opencode/skills/finishing-a-development-branch/tasks/prepare.md`, `.opencode/skills/finishing-a-development-branch/tasks/checklist.md`, `.opencode/skills/verification-before-completion/tasks/verify.md`, `.opencode/skills/git-workflow-commit/tasks/pair-commit.md` | grep — `git remote show origin` HEAD branch pattern present in all 5 files |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1: Running the behavioral test costs minutes of execution time — a bounded delay that surfaces the dynamic-resolution defect before it ships. Skipping it means the hardcoded `origin/dev` defect ships to every trunk-based repo, silently omitting pair-mode diff stats, and costs 1000× more to diagnose and fix in production.

## 11. Edge Cases

- **Input boundaries:** Empty `git remote show origin` output (no HEAD branch line) — `get_default_branch()` returns the `main` fallback; the diff stat is computed against `origin/main..HEAD`.
- **State transitions:** Remote HEAD branch changes (e.g., repo migrates from `dev` to `main`) — the branch is resolved fresh on each invocation, so the diff stat always targets the current trunk.
- **Failure modes:** `git remote show origin` times out or returns non-zero — `run_git()` returns `None`; `get_default_branch()` returns the `main` fallback. Local-only repo (no remote) — `run_git(["remote", "-v"])` returns empty, `is_local_only_repo()` is true, and the diff stat is omitted gracefully.
- **Concurrency:** No shared mutable state; `get_default_branch()` and `build_pair_mode_resume()` are stateless pure functions — no race conditions.
- **Recovery:** On any git failure, the script degrades to the `main` fallback or omits the diff stat; it never crashes and never emits a spurious diff stat.

---

*Co-authored with AI: OpenCode (deepseek-v4-flash)*
