---
name: git-workflow-pr
description: "Pull request creation, review preparation, and PR lifecycle management. Every PR MUST be an authorized, intentional delivery."
license: MIT
provenance: AI-generated
---

# Skill: git-workflow-pr

## Overview

Pull request management sub-skill of git-workflow. Handles PR creation, review preparation, pair mode PR creation, post-implementation tasks, and PR lifecycle completion. Enforces stacked PR strategy — one branch, N commits, one PR. PR creation requires `for_pr` authorization scope or explicit developer instruction.

## Workflows

### Create PR

1. **Orchestrator inline — Verify authorization scope.** Check `authorization_scope >= for_pr`. If not authorized, HALT with "PR creation requires `for_pr` scope or explicit developer instruction."
2. Dispatch `pr-creation` task via `task()` with `{branch_name, spec_summary, is_release}`.
3. Sub-agent reads `tasks/pr-creation/` and executes PR creation procedure.
4. Sub-agent returns result contract with PR URL and status.

### Prepare review

1. **Orchestrator inline — Verify authorization scope.** Check `authorization_scope >= for_pr`. If not authorized, HALT with "Review preparation requires `for_pr` scope."
2. Dispatch `review-prep` task via `task()` with `{branch_name}`.
3. Sub-agent reads `tasks/review-prep/` and executes review preparation.
4. Sub-agent returns result contract with readiness status.

### Create pair mode PR

1. **Orchestrator inline — Verify authorization scope.** Check `authorization_scope >= for_pr`. If not authorized, HALT with "PR creation requires `for_pr` scope."
2. Dispatch `pair-pr-creation` task via `task()` with `{branch_name}`.
3. Sub-agent reads `tasks/pair-pr-creation/` and executes pair mode PR creation.
4. Sub-agent returns result contract with PR URL and status.

### Post-implementation

1. **Orchestrator inline — Verify authorization scope.** Check `authorization_scope >= for_implementation`. If not authorized, HALT with "Post-implementation tasks require `for_implementation` scope."
2. Dispatch `post-implementation` task via `task()` with `{branch_name}`.
3. Sub-agent reads `tasks/post-implementation/` and executes post-implementation tasks.
4. Sub-agent returns result contract with completion status.

### Complete workflow

1. **Orchestrator inline — Verify authorization scope.** Check `authorization_scope >= for_pr`. If not authorized, HALT with "Workflow completion requires `for_pr` scope."
2. Dispatch `completion` task via `task()` with `{workflow_state}`.
3. Sub-agent reads `tasks/completion/` and executes completion procedure.
4. Sub-agent returns result contract with final status.

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
