## Problem

The pre-push hook (`hooks/pre-push`) fails silently on branches whose name does not contain a numeric segment immediately after the first `/`. The hook has `set -e` at line 7, and line 143 runs:

```bash
ISSUE_NUM=$(echo "$LOCAL_BRANCH" | grep -oP '^\w+/\K\d+')
```

When the branch is `feature/update-submodule-pointer-1718-1709`, the regex `^\w+/\K\d+` expects digits immediately after the first `/`, but the branch has `update-submodule-pointer-1718-1709` which starts with letters. `grep` exits 1 (no match), and `set -e` kills the entire script before any `echo` output reaches stderr.

**Impact:** The hook blocks pushes with zero diagnostic output. The user sees only `error: failed to push some refs to 'github.com:michael-conrad/opencode-config.git'` with no explanation.

## Root Cause

Two compounding defects:

1. **`set -e` at line 7** — Any command that exits non-zero kills the script silently.
2. **`grep -oP '^\w+/\K\d+'` at line 143** — Brittle regex that only matches branches where the segment after the first `/` starts with digits.

The tag lookup logic (lines 143-155) is unnecessary complexity. If no tag exists, a tag needs to be created — the hook doesn't need to check. The tag suggestion at lines 170-177 already handles this correctly.

## Fix

1. Remove `set -e` and add explicit error handling (`|| true` guards) on commands that can legitimately fail
2. Remove the tag lookup block (lines 143-155) — the tag suggestion at lines 170-177 is sufficient
3. Remove the `ISSUE_NUM` extraction (line 143) — use the branch name directly in tag suggestions

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `set -e` removed from pre-push hook | `string` | grep for `set -e` in `hooks/pre-push` — must return no match |
| SC-2 | No `ISSUE_NUM` extraction or tag lookup logic in Gate 2 | `string` | grep for `ISSUE_NUM` in `hooks/pre-push` — must return no match |
| SC-3 | Tag suggestion uses branch name directly instead of issue number | `string` | grep for tag suggestion in `hooks/pre-push` — must reference `$LOCAL_BRANCH` not `$ISSUE_NUM` |
| SC-4 | Hook outputs BLOCKED message on submodule-pointer-only push | `behavioral` | Simulate push with submodule-only changes — stderr must contain "BLOCKED" message |

## Files Affected

- `hooks/pre-push` — Fix `set -e`, remove tag lookup, simplify tag suggestion

## Change Control

- **Status**: DRAFT
- **Version**: 2
- **Created**: 2026-07-07
