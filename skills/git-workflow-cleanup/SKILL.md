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

- Load [git-workflow skill](skills/git-workflow/SKILL.md) for the parent workflow and full task documentation
- Load [critical-rules-013](guidelines/000-critical-rules.md) for issue closure timing rules
- Load [critical-rules-039](guidelines/000-critical-rules.md) for parent/child closure ordering
- Load [critical-rules-041](guidelines/000-critical-rules.md) for cleanup-on-PR-check trigger
- Load [critical-rules-042](guidelines/000-critical-rules.md) for content verification before branch deletion
- Load [critical-rules-049](guidelines/000-critical-rules.md) for submodule-only PR prohibition during cleanup
- Load [critical-rules-070](guidelines/000-critical-rules.md) for issue closure outside cleanup workflow
- Load [§3](guidelines/060-tool-usage.md) for behavioral evidence artifact preservation rules
