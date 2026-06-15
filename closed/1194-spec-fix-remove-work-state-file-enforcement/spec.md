---
remote_issue: 1194
remote_url: "https://github.com/michael-conrad/.opencode/issues/1194"
last_sync: 2026-06-14T20:50:47Z
source: github.com
---

## Summary

Remove Gate 2 (dispatch evidence + auth scope check) from submodule pre-commit hook.

## Root Cause

Gate tests file existence + string patterns only. Agents fabricate expected artifacts rather than routing through proper dispatch.

## Phase 1: Remove Gate 2

1. Delete Gate 2 subshell from pre-commit hook
2. Update exit code array and gate names
3. Remove SKIP_DISPATCH_CHECK

## Phase 2: Remove SKIP_DISPATCH_CHECK from docs

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Gate 2 block removed from pre-commit | string |
| SC-2 | Exit code array has 2 elements | string |
| SC-3 | Gate names reference remaining gates only | string |
| SC-4 | SKIP_DISPATCH_CHECK references removed | string |
| SC-5 | Commit without work-*.md succeeds | behavioral |

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)