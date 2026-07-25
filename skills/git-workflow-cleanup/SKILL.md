---
name: git-workflow-cleanup
description: "Post-merge cleanup, PR state verification, and issue closure. Load via skill() when the agent needs to clean up after a PR merge, check PR state, or handle pair mode cleanup. Also load when verifying merge status or closing completed issues. Cleanup is REQUIRED after every merge — not optional. User phrases: cleanup after merge, check PR state, close issues, post-merge cleanup"
license: MIT
provenance: AI-generated
---

# Skill: git-workflow-cleanup

## Overview

Cleanup management sub-skill of git-workflow. Handles post-merge cleanup, PR state checking, and pair mode cleanup. Enforces parent/child issue closure ordering, merged branch deletion, and behavioral evidence artifact preservation. Cleanup is triggered by "pr merged" events and "check prs" requests.

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "cleanup" / "post-merge cleanup" | `cleanup` | `sub-task` | {pr_merge_status, branch_name} |
| "check pr" / "check prs" / "check merged prs" / "pr merged" | `check-pr` | `sub-task` | {branch_name} |
| "pair-cleanup" / "pair cleanup" | `pair-cleanup` | `sub-task` | {branch_name} |

## DISPATCH_GATE

### Orchestrator Entry Criteria

1. Confirm the next action is `task()` — not inline execution
2. Use the canonical dispatch string from the Trigger Dispatch Table verbatim
3. Do NOT preload file paths, step sequences, expected outcomes, or orchestrator reasoning
4. Task a clean-room sub-agent via `task(subagent_type="general")`
5. Receive result contract (status, finding_summary, artifact_path, blocker_reason)
6. Log in work state file — record which sub-agent was tasked and when
7. Proceed based on result contract — route to next pipeline step

### Sub-Agent Entry Criteria

1. Sub-agent MUST return `PRELOADED_CONTEXT_REJECTED` if the task() prompt contains preloaded file paths, step definitions, expected outcomes, or orchestrator reasoning
2. Sub-agent loads task file content independently — never from orchestrator context
3. Sub-agent reads source files, runs analysis tools, executes tests freely
4. Sub-agent returns only routing-significant data: status, finding_summary, artifact_path, blocker_reason
5. Full evidence artifacts go to disk — never in the result contract

## Tasks

| Task | Description |
|------|-------------|
| `cleanup` | Post-merge cleanup — delete merged branches, close issues, sync trunk |
| `check-pr` | Check PR state — verify merge status, trigger cleanup on merge |
| `pair-cleanup` | Clean up pair mode branch after merge |

## Cross-References

- Read [git-workflow skill](skills/git-workflow/SKILL.md) for the parent workflow and full task documentation
- Read [critical-rules-013](guidelines/000-critical-rules.md) for issue closure timing rules
- Read [critical-rules-039](guidelines/000-critical-rules.md) for parent/child closure ordering
- Read [critical-rules-041](guidelines/000-critical-rules.md) for cleanup-on-PR-check trigger
- Read [critical-rules-042](guidelines/000-critical-rules.md) for content verification before branch deletion
- Read [critical-rules-049](guidelines/000-critical-rules.md) for submodule-only PR prohibition during cleanup
- Read [critical-rules-070](guidelines/000-critical-rules.md) for issue closure outside cleanup workflow
- Read [§3](guidelines/060-tool-usage.md) for behavioral evidence artifact preservation rules

### [critical-rules-016] Skipping Post-Merge Cleanup
Leaving merged branches and open issues after a merge creates a maintenance tax on every future session. Cleanup is not overhead — it is the completion ritual that keeps the repo navigable. Professional engineers clean up after every merge — amateurs leave a trail of orphaned branches and stale issues for someone else to find. Read [git-workflow --task cleanup](skills/git-workflow/SKILL.md). Deletes merged branches, closes issues, syncs trunk.


### [critical-rules-042] Content Verification Before Branch Deletion
Deleting a branch without verifying its content against the target branch means you are destroying code whose status you have not confirmed. Professional engineers diff first. Amateurs delete blind and lose work.


### [critical-rules-013] Sub-issue Closure Timing
Read [git-workflow --task cleanup](skills/git-workflow/SKILL.md).


### [critical-rules-041] Listing Merged PRs Without Calling Cleanup
"check prs" = cleanup trigger.


### [critical-rules-013] Closing Issues Before PR Merge
Read [git-workflow --task cleanup](skills/git-workflow/SKILL.md) for post-merge closure.


### [critical-rules-013] Parent/Child Issue Closure
Close children first, then parent. Read [git-workflow --task cleanup](skills/git-workflow/SKILL.md).


### [critical-rules-039] Parent Issue Left Open After All Children Closed
See verify-already-implemented Step 6, cleanup Step 2.8.


### [critical-rules-070] Issue Closure Outside Cleanup Workflow — agent MUST NOT close GitHub Issues through direct API calls
The agent MUST NOT call `github_issue_write(method=update, state=closed)` or equivalent on any GitHub Issue outside the `git-workflow --task cleanup` workflow. The cleanup workflow is the sole authorized closure path, and it enforces PR merge verification, body-preservation safeguards, and parent/child ordering before closure. Issues created by the agent in a session MUST survive at least one session boundary before closure. Read [git-workflow --task cleanup](skills/git-workflow/SKILL.md) for the authorized closure path. Read [issue-operations/tasks/close.md](skills/issue-operations/SKILL.md) for the structured close workflow (only callable from within cleanup).


### [critical-rules-049] Standalone Submodule-Only PR Creation During Cleanup

Creating a PR whose sole purpose is to update a submodule pointer during the cleanup pipeline stage. Read [git-workflow cleanup task](skills/git-workflow/SKILL.md) Step 1.7 for the complete prohibition and correct behavior (leave dirty pointer untouched).

**Scope clarification:** This prohibition applies to PR creation only. It does NOT exempt the agent from dispatching `git-workflow --task cleanup` on "pr merged" triggers. The cleanup sub-agent independently determines which cleanup actions apply — including whether to leave the submodule pointer dirty. Using this prohibition as a rationalization to skip the entire cleanup workflow is a routing-bypass self-authorization violation (critical-rules-006).


### [critical-rules-039] Parent Issue Left Open After All Children Closed
See verify-already-implemented Step 6, cleanup Step 2.8.


### [critical-rules-041] Listing Merged PRs Without Calling Cleanup
"check prs" = cleanup trigger.


