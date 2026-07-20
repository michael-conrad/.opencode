## Problem

The pre-push hook's Gate 2 (submodule-pointer-only push blocker) silently skips the check on the first push of a new branch. When a branch has never been pushed, `$REMOTE_SHA` is `0000...` (all zeros per git pre-push protocol). The command:

```bash
git diff --name-only "$REMOTE_SHA".."$LOCAL_SHA"
```

fails because `0000...` is not a valid commit. `$CHANGED_FILES` is empty, so the gate's `if [ -n "$CHANGED_FILES" ]` check evaluates to false, and the gate silently exits without blocking.

This allowed two submodule-pointer-only PRs (#260, #261) to be created via `github_create_pull_request` API — the hook never fired because the push was never attempted (the PRs were created via API), but even if a `git push` had been attempted on a new branch, the gate would have silently passed.

## Root Cause

The gate uses `$REMOTE_SHA` (the remote's current tip for the ref being pushed) to compute the diff. On first push, this is `0000...` — not a valid commit SHA. The `git diff` command fails, `$CHANGED_FILES` is empty, and the gate skips.

## Fix

When `$REMOTE_SHA` is all zeros (new branch), compare against the default branch tip instead:

```bash
if echo "$REMOTE_SHA" | grep -q '^0\{40\}$'; then
    # New branch — compare against default branch tip
    DEFAULT_BRANCH=$(git remote show origin 2>/dev/null | sed -n 's/.*HEAD branch: //p')
    CHANGED_FILES=$(git diff --name-only "origin/$DEFAULT_BRANCH".."$LOCAL_SHA" 2>/dev/null || true)
else
    CHANGED_FILES=$(git diff --name-only "$REMOTE_SHA".."$LOCAL_SHA" 2>/dev/null || true)
fi
```

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Gate 2 uses default branch tip for diff when REMOTE_SHA is all zeros | `string` | Grep pre-push hook — `REMOTE_SHA` zero-check with default branch fallback present |
| SC-2 | Gate 2 still uses REMOTE_SHA for existing branch pushes | `string` | Grep pre-push hook — existing `git diff --name-only "$REMOTE_SHA".."$LOCAL_SHA"` path preserved |
| SC-3 | Submodule-pointer-only push on new branch is blocked | `behavioral` | Create new branch with only submodule pointer change, push — verify BLOCKED message |

## Change Control

| Section | Scope |
|---------|-------|
| `.git/hooks/pre-push` | Modify Gate 2 — add REMOTE_SHA zero-check with default branch fallback |

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)