---
name: git-workflow
description: "Route branch, commit, push, and PR workflow operations to git-workflow sub-skills, including creating branches, committing, pushing, creating PRs, resolving rebase/merge conflicts, checking PR state, cleaning up after merges, and tracking provenance. Branch-and-PR discipline is REQUIRED — always follow the workflow."
license: MIT
compatibility: opencode
provenance: AI-generated
---

# Skill: git-workflow (Dispatcher)

## Overview

This is a **dispatcher skill** that routes to 5 sub-skills. All original trigger phrases are preserved for backward compatibility. Each sub-skill is loaded independently via `skill({name: "..."})` and its tasks dispatched via `task()`.

## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work that should be delegated to a sub-agent produces defective deliverables that must be discarded
- [ ] 3. Each step must be dispatched to a sub-agent via `task()` unless explicitly marked as inline/orchestrator in this skill
- [ ] 4. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Workflows

### Set up a feature branch

When the agent needs to create a feature branch before implementation work, sync submodules, verify trunk tip, or set up a pair mode branch.

1. **Verify trunk tip** — Verifies that parent repo and submodules are at trunk tip with clean working trees.
   - Prompt: `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [git-workflow-branch/tasks/trunk-tip-verification.md](.opencode/skills/git-workflow-branch/tasks/trunk-tip-verification.md). branch_name: ", branch_name))`
   - Context: `{branch_name}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

2. **Submodule sync** — Syncs dirty submodule pointers to latest trunk tip.
   - Prompt: `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [git-workflow-branch/tasks/submodule-sync.md](.opencode/skills/git-workflow-branch/tasks/submodule-sync.md). branch_name: ", branch_name, ", submodule_paths: ", submodule_paths))`
   - Context: `{branch_name, submodule_paths}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

3. **Pre-work** — Creates the feature branch and sets up the working environment.
   - Prompt: `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [git-workflow-branch/tasks/pre-work.md](.opencode/skills/git-workflow-branch/tasks/pre-work.md). branch_name: ", branch_name))`
   - Context: `{branch_name}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

4. **Pre-commit pointer check** — Verifies submodule pointers are staged before commit.
   - Prompt: `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [git-workflow-branch/tasks/pre-commit-pointer-check.md](.opencode/skills/git-workflow-branch/tasks/pre-commit-pointer-check.md). branch_name: ", branch_name))`
   - Context: `{branch_name}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

5. **Provenance** — Verifies provenance of submodule state.
   - Prompt: `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [git-workflow-branch/tasks/provenance.md](.opencode/skills/git-workflow-branch/tasks/provenance.md). submodule_path: ", submodule_path))`
   - Context: `{submodule_path}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

### Implement changes and commit

When the agent needs to implement changes and commit them with a structured message.

1. **Implementation** — Implements changes and commits with a structured message.
   - Prompt: `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [git-workflow-commit/tasks/implementation.md](.opencode/skills/git-workflow-commit/tasks/implementation.md). branch_name: ", branch_name))`
   - Context: `{branch_name}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

2. **Commit prep** — Prepares a commit message from the diff and spec context.
   - Prompt: `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [git-workflow-commit/tasks/commit-prep.md](.opencode/skills/git-workflow-commit/tasks/commit-prep.md). branch_name: ", branch_name, ", diff_summary: ", diff_summary))`
   - Context: `{branch_name, diff_summary}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

### Create a PR

When the agent needs to create a PR, prepare for review, or run post-implementation and completion tasks after implementation.

1. **Review-prep** — Prepares a branch for review by verifying readiness and generating context.
   - Prompt: `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [git-workflow-pr/tasks/review-prep.md](.opencode/skills/git-workflow-pr/tasks/review-prep.md). branch_name: ", branch_name))`
   - Context: `{branch_name}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

2. **Pr-creation** — Creates a pull request with a structured body and compare URL.
   - Prompt: `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [git-workflow-pr/tasks/pr-creation.md](.opencode/skills/git-workflow-pr/tasks/pr-creation.md). branch_name: ", branch_name, ", spec_summary: ", spec_summary, ", is_release: ", is_release))`
   - Context: `{branch_name, spec_summary, is_release}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason, pr_url}`

3. **Completion** — Runs PR lifecycle completion, final status, and URL reporting.
   - Prompt: `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [git-workflow-pr/tasks/completion.md](.opencode/skills/git-workflow-pr/tasks/completion.md). workflow_state: ", workflow_state))`
   - Context: `{workflow_state}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

### Clean up after a PR merge

When the agent needs to clean up after a PR merge — delete merged branches, close issues, sync trunk — or when a "pr merged" event or "check prs" request is detected.

1. **Cleanup** — Deletes merged branches, closes issues, and syncs trunk.
   - Prompt: `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [git-workflow-cleanup/tasks/cleanup.md](.opencode/skills/git-workflow-cleanup/tasks/cleanup.md). pr_merge_status: ", pr_merge_status, ", branch_name: ", branch_name))`
   - Context: `{pr_merge_status, branch_name}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

### Resolve a rebase, merge, or cherry-pick conflict

When the agent needs to resolve git conflicts during a rebase, merge, or cherry-pick operation, rebase pending PRs onto the updated default branch, or classify conflicts by tier.

1. **Rebase pending** — Resolves rebase/merge/cherry-pick conflicts by classifying tier and applying resolution.
   - Prompt: `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [git-workflow-conflict/tasks/rebase-pending.md](.opencode/skills/git-workflow-conflict/tasks/rebase-pending.md). branch_name: ", branch_name))`
   - Context: `{branch_name}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

## Cross-References

Sub-skills: `git-workflow-branch`, `git-workflow-commit`, `git-workflow-pr`, `git-workflow-cleanup`, `git-workflow-conflict`. Skills: `conflict-resolution`, `using-git-worktrees`, `pre-analysis`, `gh-cli` (gh-specific PR operations), `gb-cli` (gb-specific GitBucket PR operations). Guidelines: `010-approval-gate.md`, `000-critical-rules.md`.

### [critical-rules-016] Wrong Chat Output at Halt Points
A halt without structured output leaves the developer guessing what happened, what was produced, and what to do next. Professional engineers always produce: Summary → Outcome → Blockers (if applicable) → URL (if applicable) → Byline. Amateurs vanish without telling anyone what they did. Read [git-workflow skill](skills/git-workflow/SKILL.md).


### [critical-rules-016] Missing Progress Reports
Halting without structured output means leaving the developer guessing what happened — and that is amateur-hour behavior. Professional engineers always produce: Summary → URL → Byline. Issue comments are for substantive information only.
