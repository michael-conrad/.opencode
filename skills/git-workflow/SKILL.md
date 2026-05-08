---
name: git-workflow
description: Use when creating a branch, committing, pushing, or creating a PR. Also for rebase/merge conflicts (invoke conflict-resolution). Also for "check pr"/"check prs"/"check merged prs" (PR state verification + cleanup). Also for "release PR"/"promote to main"/"dev to main" (release-promotion). Triggers on: branch, commit, push, PR, pull request, pre-work, review-prep, feature branch, dev branch, squash, conflict, merge conflict, rebase conflict, check pr, check prs, check merged prs, check merged pr, check pull request, check pull requests, release PR, release pr, promote to main, dev to main, release promotion, sync submodules, update submodules, dependency sync, submodule update.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: git-workflow

## Overview

Git Workflow Enforcer. Three-branch model: feature → dev → main. AI commits blocked on protected branches. Feature branches merge to `dev` via PR. Squash at PR creation only. Submodule-aware.

## Persona

Git Workflow Enforcer. Focus: three-branch workflow, block AI on protected branches, squash-on-PR-only discipline.

## Tasks

| Task | Words |
|------|-------|
| `pre-work` | ≈480 |
| `implementation` | ≈400 |
| `review-prep` | ≈390 |
| `pr-creation` | ≈385 |
| `rebase-pending` | ≈1666 |
| `cleanup` | ≈950 |
| `release-promotion` | ≈500 |
| `check-pr` | ≈50 |
| `provenance` | ≈460 |
| `pair-pre-work` | ≈400 |
| `pair-commit` | ≈350 |
| `pair-pr-creation` | ≈300 |
| `pair-cleanup` | ≈350 |
| `pair-mode-resume` | ≈300 |
| `dependency-sync` | ≈450 |
| `completion` | ≈200 |

## Routing: Feature PR vs Release PR

| Request Type | Target |
|---|---|
| Feature PR (feature/* → dev) | `pr-creation-workflow` skill |
| Release PR (dev → main) | `git-workflow --task release-promotion` |

## Invocation

`/skill git-workflow --task pre-work` (before impl), `--task implementation` (during impl), `--task review-prep` (after impl), `--task pr-creation` (create PR), `--task rebase-pending` (post-merge rebase), `--task cleanup` (post-merge), `--task release-promotion` (dev→main), `--task check-pr` (check prs trigger), `--task provenance` (submodule tracking), `--task dependency-sync` (submodule update lifecycle), `--task pair-*` (pair mode), `--task completion` (halt guarantee). Overview with no flag.

## Operating Protocol

1. **Worktree first:** set `worktree.path` before file ops (direct-branch mode when `WORKTREE_REQUIRED` not set).
2. **Protected branches:** never commit to `main`/`dev`.
3. **Squash discipline:** squash ONLY at PR creation, not during feature dev.
4. **Clean-room content diff:** before branch deletion, verify content exists on target branch.
5. **Compare URL base:** feature → `compare/dev...<branch>`. Release → `compare/main...dev`.
6. **Submodule repos:** git ops from inside submodule dir. No `--recursive`.
7. **Pair mode:** `pair-*` branches use WIP-commit switching, not worktrees.
8. **Adversarial-audit invocation:** after PR merge verification, invoke `adversarial-audit --task closure-verification --pr <N>` with `audit_phase: post_merge`.

## Sub-Agent Dispatch Audit

All tasks dispatch via `task(subagent_type="general")` with `{ branch_name, worktree.path, github.owner, github.repo }`, excluding implementation context and agent memory. `pr-creation` receives spec summary. `cleanup` receives PR merge status. `provenance` receives submodule path. `pre-analysis` receives only `{ task_description }`. No inline work.

## Cross-References

Skills: `conflict-resolution`, `pr-creation-workflow`, `using-git-worktrees`, `pre-analysis`, `adversarial-audit --task closure-verification`. Guidelines: `010-approval-gate.md`, `000-critical-rules.md`.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: git-workflow-001
    title: "No commits to main or dev branches"
    conditions:
      any: ["current_branch == 'main'", "current_branch == 'dev'"]
    actions: [HALT]
    source: "git-workflow/SKILL.md"

  - id: git-workflow-002
    title: "Squash only at PR creation time"
    conditions:
      all: ["squash_attempted == true", "pr_creation_context == false"]
    actions: [HALT]
    source: "git-workflow/SKILL.md"

  - id: git-workflow-003
    title: "Compare URL base must be dev for feature branches"
    conditions:
      all: ["compare_url_generated == true", "base_branch != 'dev'", "is_feature_branch == true"]
    actions: [HALT]
    source: "git-workflow/SKILL.md"
