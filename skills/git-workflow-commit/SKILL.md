---
name: git-workflow-commit
description: "Implement changes and prepare atomic, well-described commits including commit message preparation and pair mode commits. Commits MUST be atomic and well-described; single-issue branches produce exactly one squash commit."
license: MIT
provenance: AI-generated
---

# Skill: git-workflow-commit

## Overview

Commit management sub-skill of git-workflow. Handles implementation commits, commit message preparation, and pair mode commits. Enforces squash-on-PR-only discipline — single-issue branches produce exactly one commit. All commits require a feature branch; direct commits to protected branches are blocked.

## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work that should be delegated to a sub-agent produces defective deliverables that must be discarded
- [ ] 3. Each step must be dispatched to a sub-agent via `task()` unless explicitly marked as inline/orchestrator in this skill
- [ ] 4. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Workflows

### Implement changes and commit

When the agent needs to implement changes and commit them with a structured message during the implementation phase.

1. **Implementation** — Implements changes and commits with a structured message.
   - Prompt: `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [git-workflow-commit/tasks/implementation.md](.opencode/skills/git-workflow-commit/tasks/implementation.md). branch_name: ", branch_name, ", worktree.path: ", worktree_path))`
   - Context: `{branch_name, worktree.path}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

### Prepare a commit message

When the agent needs to prepare a commit message from the diff and spec context (read-only analysis, no commit executed).

1. **Commit prep** — Prepares a commit message from the diff and spec context.
   - Prompt: `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [git-workflow-commit/tasks/commit-prep.md](.opencode/skills/git-workflow-commit/tasks/commit-prep.md). branch_name: ", branch_name, ", diff_summary: ", diff_summary))`
   - Context: `{branch_name, diff_summary}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

### Make a pair mode commit

When the agent needs to make a WIP commit in pair mode with developer attribution.

1. **Pair commit** — Makes a WIP commit in pair mode with developer attribution.
   - Prompt: `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [git-workflow-commit/tasks/pair-commit.md](.opencode/skills/git-workflow-commit/tasks/pair-commit.md). branch_name: ", branch_name))`
   - Context: `{branch_name}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

## Cross-References

- Read [git-workflow skill](skills/git-workflow/SKILL.md) for the parent workflow and full task documentation
- Read [critical-rules-026](guidelines/000-critical-rules.md) for commit authorization rules
- Read [critical-rules-040](guidelines/000-critical-rules.md) for single-commit discipline
- Read [AI co-authored attribution requirements](guidelines/080-code-standards.md)
- Read [§1](guidelines/020-go-prohibitions.md) for `--no-verify` restrictions
