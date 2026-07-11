> **Full spec and artifacts: [`.opencode/.issues/1877/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1877/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/1877/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Exec Summary

Fixes two root causes discovered during post-merge cleanup of PR #1876: (1) the parent repo is left on a stale feature branch after submodule PR merge, and (2) `branch-cleanup.md` contains 40+ hardcoded `dev` references that conflict with trunk-based development using `main`.

### Cards (dependency order)
1. **Replace hardcoded `dev` with `$DEFAULT_BRANCH`** — All 40+ occurrences of `dev` in `branch-cleanup.md` must use the dynamically resolved default branch variable
2. **Add `git branch --show-current` to cleanup.md Step 3** — Post-cleanup verification must check current branch (was supposed to be done in #1873 but wasn't)
3. **Ensure parent repo is included in repos-to-clean list** — The cleanup task must park the parent repo on trunk, not just submodules

### Key Decisions
- **DEC-1**: Use `$DEFAULT_BRANCH` (dynamically resolved via `git remote show origin`) instead of hardcoded `dev` — MUST
- **DEC-2**: Parent repo trunk parking is mandatory, not optional — the parent repo must be on trunk after cleanup

### Risk Callouts
- **RISK-1**: Hardcoded `dev` references silently break on repos using `main` as trunk — cleanup operations target wrong branch
- **RISK-2**: Parent repo left on stale feature branch causes confusion and potential work loss on next session

## AI Agent Instructions

This issue is an executive summary for human stakeholders.
The authoritative spec and plan artifacts are at `.opencode/.issues/1877/`.
After creation, `local-issues sync 1877` MUST be run and the result committed to create the local `.opencode/.issues/1877/` entry.
The implementation plan will be created in `.opencode/.issues/1877/plan.md` after approval.
AI agents MUST read the local spec/plan files for implementation
and MUST NOT base implementation on this summary.

🤖 Co-authored with AI: OpenCode (deepseek-v4-pro)
