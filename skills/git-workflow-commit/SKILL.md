---
name: git-workflow-commit
description: "Change implementation and commit preparation. Load via skill() when the agent needs to commit changes or prepare commit messages. Also load when implementing changes and committing them, or handling pair mode commits. Commits MUST be atomic and well-described. User phrases: commit changes, prepare commit, implement and commit, pair mode commit"
license: MIT
provenance: AI-generated
---

# Skill: git-workflow-commit

## Overview

Commit management sub-skill of git-workflow. Handles implementation commits, commit message preparation, and pair mode commits. Enforces squash-on-PR-only discipline — single-issue branches produce exactly one commit. All commits require a feature branch; direct commits to protected branches are blocked.

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "implementation" / "commit" / "save work" | `implementation` | `sub-task` | {branch_name, worktree.path} |
| "commit-prep" / "prepare commit" / "write message" | `commit-prep` | `sub-task` | {branch_name, diff_summary} |
| "pair-commit" / "pair save" / "WIP commit" | `pair-commit` | `sub-task` | {branch_name} |

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
| `implementation` | Implement changes and commit with structured message |
| `commit-prep` | Prepare commit message from diff and spec context |
| `pair-commit` | WIP commit for pair mode with developer attribution |

## Cross-References

- Read [git-workflow skill](skills/git-workflow/SKILL.md) for the parent workflow and full task documentation
- Read [critical-rules-026](guidelines/000-critical-rules.md) for commit authorization rules
- Read [critical-rules-040](guidelines/000-critical-rules.md) for single-commit discipline
- Read [AI co-authored attribution requirements](guidelines/080-code-standards.md)
- Read [§1](guidelines/020-go-prohibitions.md) for `--no-verify` restrictions
