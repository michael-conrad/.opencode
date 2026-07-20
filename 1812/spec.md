## Intent and Executive Summary

- **Problem:** The agent keeps creating submodule-only PRs despite existing prohibitions. Root cause analysis found the prohibition in `020-go-prohibitions.md` is scoped to "during cleanup" only, and `implementation.md`/`pr-creation.md` task files instruct the agent to stage dirty submodule pointers without checking for non-submodule changes.
- **Success Criteria:** 5 SCs covering task file guards, universal prohibition, and behavioral test.
- **Implementation Plan:** Fix task file guards → add universal prohibition → add behavioral test.
- **Change Control:** This is a spec-fix for an existing behavioral defect. No new features.
- **Authorization Scope:** `for_pr` — implement all SCs and create PR.

## Problem

The agent keeps creating submodule-only PRs despite explicit prohibitions. Root cause analysis found two contributing factors:

1. **`implementation.md` and `pr-creation.md`** tell the agent to stage dirty submodule pointers without checking for non-submodule changes — the agent follows these instructions and creates submodule-only PRs.
2. **Prohibition is scoped to cleanup only** — the existing rule in `020-go-prohibitions.md` says "NEVER create a submodule-only PR **during cleanup**", which the agent interprets as applying only during the cleanup workflow, not during implementation or PR creation.

The pre-push hook already blocks submodule-only pushes with a clear message ("Do NOT create a submodule-only PR"), but the agent never reaches the hook because it creates the PR locally without pushing first.

## Fix Approach

### Fix 1: Task file guards
Add a guard in `git-workflow/tasks/implementation.md` and `git-workflow/tasks/pr-creation.md`: before staging the submodule pointer, verify there are non-submodule changes staged. If not, HALT — do not stage the pointer.

### Fix 2: Universal prohibition
Change the existing prohibition in `020-go-prohibitions.md` from "during cleanup" to "in ANY context, for ANY reason" — making it truly universal.

### Fix 3: Behavioral test
Add a test that sends a prompt like "the submodule pointer is dirty, create a PR" and verifies the agent declines.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `implementation.md` guards against submodule-only staging — before staging submodule pointer, verifies non-submodule changes exist | `string` |
| SC-2 | `pr-creation.md` guards against submodule-only staging — before staging submodule pointer, verifies non-submodule changes exist | `string` |
| SC-3 | Universal prohibition in `020-go-prohibitions.md` says "in ANY context, for ANY reason" (not scoped to cleanup only) | `string` |
| SC-4 | Behavioral test exists that verifies agent declines submodule-only PR creation | `behavioral` |

## Documentation Sources

- `.opencode/hooks/pre-push` — pre-push hook (line 125: "Do NOT create a submodule-only PR")
- `.opencode/guidelines/020-go-prohibitions.md` — existing prohibition (lines 216-223, scoped to "during cleanup")
- `.opencode/skills/git-workflow/tasks/implementation.md` — implementation task file (lines 36-41, submodule pointer handling)
- `.opencode/skills/git-workflow/tasks/pr-creation.md` — PR creation task file (lines 49-54, submodule pointer handling)

## Alternatives Considered

- **Strengthen pre-push hook message only**: The hook already blocks submodule-only pushes, but the agent creates PRs locally without pushing. This fix alone is insufficient.
- **Add prohibition to `000-critical-rules.md`**: The existing prohibition in `020-go-prohibitions.md` just needs its scope widened. No need for a duplicate rule.
- **Remove submodule staging from task files entirely**: Submodule pointers need to be staged alongside real changes. The fix is to add a guard, not remove the capability.

## Edge Cases

- **Branch with only submodule changes + no real code**: Guard catches this — HALT before staging.
- **Branch with real code changes + dirty submodule**: Guard passes — submodule pointer is staged alongside real changes.
- **Cleanup workflow**: The existing cleanup prohibition already handles this. The guard in task files is an additional safety net.
- **Pre-push hook still fires**: The hook remains as a last-resort block. The task file guards prevent the agent from ever reaching the hook with a submodule-only PR.

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)