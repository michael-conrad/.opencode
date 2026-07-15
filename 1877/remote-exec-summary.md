> **Full spec and artifacts: [`.opencode/.issues/1877/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1877/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/1877/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Exec Summary

Fixes hardcoded `dev` references in `cleanup.md` that conflict with trunk-based development using `main`. The `branch-cleanup.md` file was already fixed in a prior commit (0f901a3e). The `git branch --show-current` check and parent repo inclusion in repos-to-clean list are already implemented.

### Cards (dependency order)
1. **Replace hardcoded `dev` in cleanup.md** — 7 occurrences of `dev` in prose/step descriptions must use `$DEFAULT_BRANCH` or trunk-equivalent prose

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
