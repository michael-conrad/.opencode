---
name: git-workflow-pr
description: "Create pull requests, prepare branches for review, manage the PR lifecycle, and perform post-implementation tasks. Every PR MUST be an authorized, intentional delivery requiring `for_pr` authorization scope or explicit developer instruction."
license: MIT
provenance: AI-generated
---

# Skill: git-workflow-pr

## Overview

Pull request management sub-skill of git-workflow. Handles PR creation, review preparation, pair mode PR creation, post-implementation tasks, and PR lifecycle completion. Enforces stacked PR strategy — one branch, N commits, one PR. PR creation requires `for_pr` authorization scope or explicit developer instruction.

## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work that should be delegated to a sub-agent produces defective deliverables that must be discarded
- [ ] 3. Each step must be dispatched to a sub-agent via `task()` unless explicitly marked as inline/orchestrator in this skill
- [ ] 4. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Workflows

### Create a PR

When the agent needs to create a pull request, squash commits to a single commit, push the branch, and create the PR targeting `$DEFAULT_BRANCH`.

- [ ] 1. **Pr-creation** — Creates a pull request with a structured body and compare URL
  - **Prompt:** `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [git-workflow-pr/tasks/pr-creation.md](.opencode/skills/git-workflow-pr/tasks/pr-creation.md). branch_name: ", branch_name, ", spec_summary: ", spec_summary, ", is_release: ", is_release))`
  - **Context passed:** `{branch_name, spec_summary, is_release}`
  - **Returns:** `{status, finding_summary, artifact_path, blocker_reason, pr_url}`
  - **Execution mode:** sub-agent dispatch
  - On completion, MUST read the ticket's current status via `local-issues read` BEFORE reporting completion, then updates it to the PR-created state (`for_pr`/`approved-for-pr`) when an update is warranted, skipping the update only when the read shows the status is already correct (see Step 9 Ticket Status Reconciliation in `tasks/pr-creation.md`).

### Prepare for review

When the agent needs to generate a GitHub compare URL for developer review after implementation completes.

- [ ] 1. **Review-prep** — Prepares a branch for review by verifying readiness and generating context
  - **Prompt:** `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [git-workflow-pr/tasks/review-prep.md](.opencode/skills/git-workflow-pr/tasks/review-prep.md). branch_name: ", branch_name))`
  - **Context passed:** `{branch_name}`
  - **Returns:** `{status, finding_summary, artifact_path, blocker_reason}`
  - **Execution mode:** sub-agent dispatch

### Create a pair mode PR

When the agent needs to create a PR from a pair mode branch.

- [ ] 1. **Pair-pr-creation** — Creates a PR from a pair mode branch
  - **Prompt:** `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [git-workflow-pr/tasks/pair-pr-creation.md](.opencode/skills/git-workflow-pr/tasks/pair-pr-creation.md). branch_name: ", branch_name))`
  - **Context passed:** `{branch_name}`
  - **Returns:** `{status, finding_summary, artifact_path, blocker_reason, pr_url}`
  - **Execution mode:** sub-agent dispatch

### Perform post-implementation tasks

When the agent needs to push the feature branch, generate a compare URL, and report completion after implementation.

- [ ] 1. **Post-implementation** — Pushes the feature branch, generates a compare URL, and reports completion
  - **Prompt:** `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [git-workflow-pr/tasks/post-implementation.md](.opencode/skills/git-workflow-pr/tasks/post-implementation.md). branch_name: ", branch_name))`
  - **Context passed:** `{branch_name}`
  - **Returns:** `{status, finding_summary, artifact_path, blocker_reason}`
  - **Execution mode:** sub-agent dispatch

### Complete the workflow

When the agent needs to run idempotent completion steps to ensure mandatory checks run regardless of where the workflow halted.

- [ ] 1. **Completion** — Runs PR lifecycle completion, final status, and URL reporting
  - **Prompt:** `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [git-workflow-pr/tasks/completion.md](.opencode/skills/git-workflow-pr/tasks/completion.md). workflow_state: ", workflow_state))`
  - **Context passed:** `{workflow_state}`
  - **Returns:** `{status, finding_summary, artifact_path, blocker_reason}`
  - **Execution mode:** sub-agent dispatch
  - After the completion summary is produced, MUST read the ticket's current status via `local-issues read` BEFORE reporting completion, then updates it to the PR-created state (`for_pr`/`approved-for-pr`) when an update is warranted, skipping the update only when the read shows the status is already correct (see Ticket Status Reconciliation in `tasks/completion.md`).

## Cross-References

- Read [git-workflow skill](skills/git-workflow/SKILL.md) for the parent workflow and full task documentation
- Read [critical-rules-016](guidelines/000-critical-rules.md) for PR body format requirements
- Read [critical-rules-016](guidelines/000-critical-rules.md) for compare URL base branch rules
- Read [critical-rules-019](guidelines/000-critical-rules.md) for PR creation authorization
- Read [critical-rules-PR-ORG](guidelines/000-critical-rules.md) for stacked PR strategy
- Read [critical-rules-040](guidelines/000-critical-rules.md) for single-commit PR discipline

### [critical-rules-042] Skipping PR for Documentation/Guideline Changes
Exception: zero files modified, or already-implemented (verified by `verify-already-implemented`). Amateurs skip PRs for documentation changes. Professionals maintain review discipline for every change.


### [critical-rules-038] Implementing Before PR Merge Boundary
Implementing a dependent phase before its PR boundary has merged means you are building on a foundation that does not exist yet. Professional engineers respect PR merge boundaries. Amateurs stack work on unreviewed code.


### [critical-rules-040] Un-Squashed PR — creating single-issue PR with multiple commits
Single-issue: exactly 1 commit. Work branch: N commits = N items.


### [critical-rules-PR-ORG] Stacked PR Is the Only Valid Organization

Creating N branches for N issues under any authorization scope is a critical violation. All issues within an authorization scope share one feature branch with one commit per issue. The only valid PR strategy is `stacked` — one branch, N commits, one PR. The `individual` strategy (N branches, N PRs) does not exist.

An authorization scope that halts before PR creation declares `pr_strategy: none`. An authorization scope that creates PRs declares `pr_strategy: stacked`. There is no third option.

Bright-line companion:

PR organization IS branch organization. Stacked PR IS the only valid organization.
Every authorization scope declares exactly one strategy: stacked or none.
Creating N branches for N issues IS a critical violation — Period.
