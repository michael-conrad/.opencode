---
remote_issue: 951
remote_url: "https://github.com/michael-conrad/.opencode/issues/951"
last_sync: 2026-06-14T20:50:47Z
source: github.com
---

## Problem

The solve tool exists but no skill task files call it.

Each dispatching task file needs:
- Pre-dispatch solve check gate
- Per-variable solve state update calls
- Post-return solve check gate

## Scope

Adding solve check gates and state update calls to existing task files only.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | At least one task file has pre-dispatch solve check | structural |
| SC-2 | At least one task file has post-return solve check | structural |
| SC-3 | At least one task file has state update calls | structural |
| SC-4 | Agent executes solve check before dispatch | behavioral |

🤖 Co-authored with AI: OpenCode