---
name: git-workflow-pr
description: "Pull request creation, review preparation, and PR lifecycle management. Load via skill() when the agent needs to create pull requests, prepare reviews, or handle PR lifecycle completion. Also load when handling pair mode PR creation or post-implementation tasks. Every PR MUST be an authorized, intentional delivery. User phrases: create PR, prepare review, complete PR lifecycle, pair mode PR"
license: MIT
provenance: AI-generated
---

# Skill: git-workflow-pr

## Overview

Pull request management sub-skill of git-workflow. Handles PR creation, review preparation, pair mode PR creation, post-implementation tasks, and PR lifecycle completion. Enforces stacked PR strategy — one branch, N commits, one PR. PR creation requires `for_pr` authorization scope or explicit developer instruction.

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "pr-creation" / "create PR" | `pr-creation` | `sub-task` | {branch_name, spec_summary, is_release} |
| "review-prep" / "prepare review" | `review-prep` | `sub-task` | {branch_name} |
| "pair-pr-creation" / "pair PR" | `pair-pr-creation` | `sub-task` | {branch_name} |
| "post-implementation" / "post-impl" | `post-implementation` | `sub-task` | {branch_name} |
| completion / workflow end | `completion` | `sub-task` | {workflow_state} |

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

2. Sub-agent loads task file content independently — never from orchestrator context
3. Sub-agent reads source files, runs analysis tools, executes tests freely
4. Sub-agent returns only routing-significant data: status, finding_summary, artifact_path, blocker_reason
5. Full evidence artifacts go to disk — never in the result contract

## Tasks

| Task | Description |
|------|-------------|
| `pr-creation` | Create pull request with structured body and compare URL |
| `review-prep` | Prepare branch for review — verify readiness, generate context |
| `pair-pr-creation` | Create PR from pair mode branch |
| `post-implementation` | Post-implementation tasks — verification, finishing checklist |
| `completion` | PR lifecycle completion — final status, URL reporting |

## Cross-References

- Read [git-workflow skill](skills/git-workflow/SKILL.md) for the parent workflow and full task documentation
- Read [pr-creation-workflow skill](skills/pr-creation-workflow/SKILL.md) for PR authorization and readiness verification
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


