> **Full spec and artifacts: [`.opencode/.issues/1812/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1812/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/1812/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem

The agent keeps creating submodule-only PRs despite explicit prohibitions. Root cause analysis (`.opencode/tmp/submodule-pr-root-cause.md`) identified a three-layer failure:

1. **Pre-commit hook Gate 3 pattern bug** — checks for `.opencode/*` (files *inside* submodule), but a gitlink entry is `.opencode` (the directory itself). The pattern doesn't match, so submodule-pointer-only commits pass undetected.

2. **Pre-push hook message is ambiguous** — says "BLOCKED" but then gives tagging instructions and "To proceed: 1. Continue implementation..." An agent reads this as a workaround path, not a hard stop.

3. **Pre-work creates a submodule-pointer-only commit as the first branch action** (`pre-work.md:294-298`). When no implementation follows, that commit becomes a standalone submodule-only PR candidate.

## Fix Approach

### Fix 1: Pre-commit hook Gate 3 — fix pattern match
Add `.opencode` (bare directory, no `/*`) to the case pattern so gitlink entries are detected.

### Fix 2: Pre-push hook — clarify error message
Replace ambiguous "create a tag and continue" messaging with a hard-stop directive that says "delete this branch."

### Fix 3: Pre-work — add no-op branch guard
After committing the submodule pointer, add a guard that checks whether the branch has any non-submodule changes before allowing PR creation.

### Fix 4: Behavioral enforcement test
Add a test that verifies the agent does NOT create a submodule-only PR.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Pre-commit hook Gate 3 detects gitlink entries (`.opencode` without `/*`) | `behavioral` |
| SC-2 | Pre-push hook message says "HARD BLOCK" and "delete this branch" not "create a tag" | `string` |
| SC-3 | Pre-push hook message does NOT contain tagging instructions | `string` |
| SC-4 | `pre-work.md` has no-op branch guard after submodule pointer commit | `string` |
| SC-5 | Behavioral test verifies agent declines submodule-only PR creation | `behavioral` |

## Files Affected

| File | Change |
|------|--------|
| `hooks/pre-commit` | Fix Gate 3 pattern to match gitlink entries |
| `hooks/pre-push` | Replace ambiguous error message with hard-stop directive |
| `skills/git-workflow/tasks/pre-work.md` | Add no-op branch guard |
| `tests/behaviors/submodule-only-pr-blocked.sh` | New behavioral test |

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)