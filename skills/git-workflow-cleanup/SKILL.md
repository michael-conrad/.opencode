---
name: git-workflow-cleanup
description: "Clean up after a PR merge, verify PR merge status, check PR state, and close completed issues. Cleanup is REQUIRED after every merge and is the sole authorized path for closing GitHub Issues."
license: MIT
provenance: AI-generated
---

# Skill: git-workflow-cleanup

## Overview

Cleanup management sub-skill of git-workflow. Handles post-merge cleanup, PR state checking, and pair mode cleanup. Enforces parent/child issue closure ordering, merged branch deletion, and behavioral evidence artifact preservation. Cleanup is triggered by "pr merged" events and "check prs" requests.

## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work that should be delegated to a sub-agent produces defective deliverables that must be discarded
- [ ] 3. Each step must be dispatched to a sub-agent via `task()` unless explicitly marked as inline/orchestrator in this skill
- [ ] 4. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Workflows

### Clean up after a PR merge

When the agent needs to clean up after a PR merge — delete merged branches, close issues, sync trunk — or when a "pr merged" event or "check prs" request is detected.

1. **Cleanup** — Deletes merged branches, closes issues, and syncs trunk.
   - Prompt: `Dispatch a sub-agent with the prompt "Follow the instructions in [git-workflow-cleanup/tasks/cleanup.md](.opencode/skills/git-workflow-cleanup/tasks/cleanup.md). pr_merge_status: {pr_merge_status}, branch_name: {branch_name}"`
   - Context: `{pr_merge_status, branch_name}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

### Clean up a pair mode branch

When the agent needs to clean up a pair mode branch after a merge.

1. **Pair cleanup** — Cleans up a pair mode branch after merge.
   - Prompt: `Dispatch a sub-agent with the prompt "Follow the instructions in [git-workflow-cleanup/tasks/pair-cleanup.md](.opencode/skills/git-workflow-cleanup/tasks/pair-cleanup.md). branch_name: {branch_name}"`
   - Context: `{branch_name}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

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
