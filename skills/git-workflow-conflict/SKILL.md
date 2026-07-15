---
name: git-workflow-conflict
description: "Dispatch when the agent needs to resolve git conflicts during rebase, merge, or cherry-pick operations. Triggers when: agent determines a conflict resolution is needed, agent encounters a rebase conflict, agent needs to resolve merge conflicts."
license: MIT
provenance: AI-generated
---

# Skill: git-workflow-conflict

## Overview

Conflict resolution sub-skill of git-workflow. Handles rebase-pending conflict resolution during rebase, merge, or cherry-pick operations. Delegates intent analysis and tier classification to the `conflict-resolution` skill. Enforces the three-tier conflict model: Trivial (auto-resolve), Textual (note), Intent (HALT).

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "rebase" / "rebase pending" / "rebase conflict" | `rebase-pending` | `sub-task` | {branch_name, worktree.path} |
| "merge conflict" / "resolve conflict" | `rebase-pending` | `sub-task` | {branch_name, worktree.path} |
| "cherry-pick conflict" | `rebase-pending` | `sub-task` | {branch_name, worktree.path} |

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
| `rebase-pending` | Resolve rebase/merge/cherry-pick conflicts — classify tier, apply resolution |

## Cross-References

- Read [git-workflow skill](skills/git-workflow/SKILL.md) for the parent workflow and full task documentation
- Read [conflict-resolution skill](skills/conflict-resolution/SKILL.md) for intent analysis and tier classification
- Read [critical-rules-042](guidelines/000-critical-rules.md) for blind conflict resolution prohibition
