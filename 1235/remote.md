---
remote_issue: 1235
remote_url: "https://github.com/michael-conrad/.opencode/issues/1235"
last_sync: "2026-06-16T04:28:11Z"
source: github
---

## Summary

The "pr merged" / "check pr" trigger lost its implicit authorization for post-merge cleanup during the authorization scope model overhaul (commit `2e72baf4`, May 13, 2026). Before the overhaul, the default `standard` scope permitted cleanup operations (branch deletion, issue closure, dev sync). After the overhaul, the default `for_analysis` scope explicitly blocks these operations.

The `check-pr` and `cleanup` tasks were never updated to handle authorization scope. They relied on the old implicit permission. The trigger "pr merged" is always a cleanup intent — nobody says it just to check.

## Root Cause

Commit `2e72baf4` introduced `for_analysis` as the default floor scope with an explicit blocklist that includes:
- Closing issues after PR merge
- Deleting branches (except `observe/*`)
- Committing to dev/main

The `check-pr` task and `cleanup` tasks have no mechanism to escalate scope when triggered by "pr merged". They never received scope-handling updates during the overhaul.

## Affected Files

| File | Path | Issue |
|------|------|-------|
| `check-pr.md` | `.opencode/skills/git-workflow/tasks/check-pr.md` | No scope escalation logic |
| `branch-cleanup.md` | `.opencode/skills/git-workflow/tasks/cleanup/branch-cleanup.md` | Receives `authorization_scope` but does not escalate |
| `010-approval-gate.md` | `.opencode/guidelines/010-approval-gate.md` | `for_analysis` blocklist blocks cleanup |
| `020-go-prohibitions.md` | `.opencode/guidelines/020-go-prohibitions.md` | `for_analysis` self-assignment rules |
| `approval-gate/SKILL.md` | `.opencode/skills/approval-gate/SKILL.md` | Authorization scope model table |

## Proposed Fix

The "pr merged" trigger in the git-workflow trigger dispatch table should carry implicit authorization for post-merge cleanup. Options:

1. **Trigger carries scope** — "pr merged" auto-escalates to a scope that permits cleanup (e.g., `for_implementation` or a new `for_cleanup` scope)
2. **Exempt cleanup from `for_analysis` blocklist** — when triggered by a verified PR merge, cleanup operations are permitted under `for_analysis`
3. **Add `for_cleanup` scope** — a dedicated scope between `for_analysis` and `for_implementation` that permits branch deletion, issue closure, and dev sync

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | "pr merged" trigger results in branch deletion, issue closure, and dev sync without requiring separate "approved" or "go" | behavioral |
| SC-2 | `for_analysis` scope still blocks cleanup when triggered by non-cleanup triggers (e.g., a question, a bug report) | behavioral |
| SC-3 | Cleanup operations still blocked under `for_analysis` when no PR merge is confirmed | behavioral |

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
