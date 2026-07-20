## Compliance Admonishment

> **⚠️ CRITICAL VIOLATION — Tier 1 Safety-Critical**
>
> The pre-push hook Gate 2 (submodule-pointer-only push blocker) has a `DEFAULT_BRANCH` fallback that hardcodes `"main"` on line 9. This is a hardcoded branch name violation per the trunk-based development remediation (#1817). The fallback must resolve dynamically.

---

## Root Cause

Commit `0f901a3e` ("fix: replace all hardcoded dev/main branch references") removed the `DEFAULT_BRANCH` re-resolution inside Gate 2's new-branch path and moved it to the top of the hook. The top-level resolution has no fallback:

```bash
DEFAULT_BRANCH=$(git remote show origin 2>/dev/null | sed -n 's/.*HEAD branch: //p')
```

When `git remote show origin` returns empty (network glitch, detached state, etc.), `DEFAULT_BRANCH` is empty, `origin/$DEFAULT_BRANCH` becomes `origin/`, the diff silently fails, and Gate 2 skips — allowing submodule-only pushes through.

The attempted fix added `[ -z "$DEFAULT_BRANCH" ] && DEFAULT_BRANCH="main"` which hardcodes `"main"` — a regression from the trunk-based remediation.

---

## Fix

Replace the hardcoded `"main"` fallback with a dynamic resolution from `origin/HEAD`:

```bash
[ -z "$DEFAULT_BRANCH" ] && DEFAULT_BRANCH=$(git rev-parse --abbrev-ref origin/HEAD 2>/dev/null | sed 's|^origin/||')
```

`origin/HEAD` is a symbolic ref that points to the remote's HEAD branch. This resolves dynamically without hardcoding any branch name.

---

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|-------------------|
| SC-1 | `DEFAULT_BRANCH` fallback uses `git rev-parse --abbrev-ref origin/HEAD` instead of hardcoded `"main"` | structural | Grep for `origin/HEAD` in `hooks/pre-push`; confirm no `"main"` fallback |
| SC-2 | Gate 2 blocks submodule-only pushes when `git remote show origin` fails | behavioral | Simulate failed remote query, push submodule-only branch; verify block |
| SC-3 | Gate 2 still works normally when `git remote show origin` succeeds | behavioral | Push submodule-only branch with normal remote; verify block |

---

## Evidence

- `.opencode/hooks/pre-push` line 9: `[ -z "$DEFAULT_BRANCH" ] && DEFAULT_BRANCH="main"`
- Commit `0f901a3e` removed the re-resolution inside Gate 2
- `origin/HEAD` is a standard git symbolic ref that tracks the remote's default branch
