---
name: git-workflow
description: Use when creating a branch, committing, pushing, or creating a PR. Also for rebase/merge conflicts (invoke conflict-resolution). Also for "check pr"/"check prs"/"check merged prs"/"pr merged" (PR state verification + cleanup). Also for "release PR"/"promote to main"/"dev to main" (release-promotion). Triggers on: branch, commit, push, PR, pull request, pre-work, review-prep, feature branch, dev branch, squash, conflict, merge conflict, rebase conflict, check pr, check prs, check merged prs, check merged pr, check pull request, check pull requests, release PR, release pr, promote to main, dev to main, release promotion, pr merged, cleanup, clean up, sync submodules, update submodules, submodule update. Branch-and-PR discipline is not bureaucracy — it is what separates maintainable projects from chaos.
type: discipline-enforcing
license: MIT
provenance: AI-generated (feature-branch push + tip tag context; tag layers: `<parent>/<issue>`, `<parent>/<issue>-<sub>`, `<parent>/v<version>`)
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
| `completion` | ≈200 |

## Routing: Feature PR vs Release PR

| Request Type | Target |
|---|---|
| Feature PR (feature/* → dev) | `pr-creation-workflow` skill |
| Release PR (dev → main) | `git-workflow --task release-promotion` |

## Invocation

`skill({name: "git-workflow"})` — call the skill, then call via task():

| Task | Call via task() |
|------|----------|
| `pre-work` | `task(..., prompt: "execute pre-work task from git-workflow")` |
| `implementation` | `task(..., prompt: "execute implementation task from git-workflow")` |
| `review-prep` | `task(..., prompt: "execute review-prep task from git-workflow")` |
| `pr-creation` | `task(..., prompt: "execute pr-creation task from git-workflow")` |
| `rebase-pending` | `task(..., prompt: "execute rebase-pending task from git-workflow")` |
| `cleanup` | `task(..., prompt: "execute cleanup task from git-workflow")` |
| `release-promotion` | `task(..., prompt: "execute release-promotion task from git-workflow")` |
| `check-pr` | `task(..., prompt: "execute check-pr task from git-workflow")` |
| `provenance` | `task(..., prompt: "execute provenance task from git-workflow")` |
| `completion` | `task(..., prompt: "execute completion task from git-workflow")` |

**CLI equivalent (for human TUI use):** `/skill git-workflow --task <task>`

## Sub-Agent Tasks for Submodule Operations

| Sub-Agent Task | Trigger | Task Context (MUST receive) | Exclusions (MUST NOT receive) | Words |
|----------------|---------|----------------------------------|-------------------------------|-------|
| `submodule-tag-prework` | pre-work Step 3.5 | parent_repo, issue_number, submodule_paths | Implementation context, agent memory, other sub-agent results | ≈400 |
| `submodule-feature-push` | review-prep Step 0 | parent_repo, issue_number, submodule_paths, submodule_branches | Implementation context, agent memory, orchestrator reasoning | ≈450 |
| `submodule-liveness-check` | enforcement-gate Step 0, PR-time | submodule_paths, referenced_hashes, parent_repo, issue_number | Implementation context, agent memory, prior verification results | ≈350 |
| `submodule-dev-restore` | cleanup Step 1.9 | submodule_paths | Implementation context, agent memory, other sub-agent results | ≈300 |

## Operating Protocol

1. **Worktree first:** set `worktree.path` before file ops (direct-branch mode when `WORKTREE_REQUIRED` not set).
2. **Protected branches:** never commit to `main`/`dev`.
3. **Squash discipline:** squash ONLY at PR creation, not during feature dev.
4. **Clean-room content diff:** before branch deletion, verify content exists on target branch.
5. **Compare URL base:** feature → `compare/dev...<branch>`. Release → `compare/main...dev`.
6. **Submodule repos:** git ops from inside submodule dir. No `--recursive`.
7. **Pair mode:** `pair-*` branches use WIP-commit switching, not worktrees.
8. **Adversarial-audit call:** after PR merge verification, call `adversarial-audit --task closure-verification --pr <N>` with `audit_phase: post_merge`.
9. **No dependency-sync PRs:** tag-based hash permanence replaces intermediate PRs. Submodule SHAs are preserved via parent-repo-prefixed tags. See AGENTS.md §Tag Layers.

## Sub-Agent Routing

All tasks run via `task(subagent_type="general")` with `{ branch_name, worktree.path, github.owner, github.repo }`, excluding implementation context and agent memory. Auditor tasks use subagent_type from resolve-models result contract (auditor_1/auditor_2) — NOT `general`. Include audit_phase in task context when routing auditors. See adversarial-audit SKILL.md §DISPATCH_GATE. `pr-creation` receives spec summary. `cleanup` receives PR merge status. `provenance` receives submodule path. `pre-analysis` receives only `{ issue_number, task_description, github.owner, github.repo }`. No inline work.

Submodule sub-agents (`submodule-tag-prework`, `submodule-feature-push`, `submodule-liveness-check`, `submodule-dev-restore`) receive scoped context per the Sub-Agent Tasks for Submodule Operations table above. All are clean-room runs — no implementation context, agent memory, or orchestrator reasoning shared. Submodule git operations are NEVER performed inline.

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

  - id: git-workflow-submodule-001
    title: "Pre-work MUST tag submodule dev tips with <parent>/<issue> format"
    conditions:
      all: ["pipeline_stage == 'pre_work'", "has_submodules == true", "submodule_tag_created == false"]
    actions: [HALT, REQUIRE_TAG]
    source: "git-workflow/SKILL.md"

  - id: git-workflow-submodule-002
    title: "Submodule changes MUST use feature-branch pushes with tip tags, not dev pushes"
    conditions:
      all: ["submodule_push_attempted == true", "push_target == 'dev'", "is_feature_branch_push == false"]
    actions: [HALT]
    source: "git-workflow/SKILL.md"

  - id: git-workflow-submodule-003
    title: "PR-time MUST verify submodule hash reachability via tags (liveness check, no auto-remediation)"
    conditions:
      all: ["pipeline_stage == 'pr_time'", "has_submodules == true", "submodule_liveness_verified == false"]
    actions: [HALT, REQUIRE_LIVENESS_CHECK]
    source: "git-workflow/SKILL.md"

  - id: git-workflow-submodule-004
    title: "Cleanup MUST restore submodules to dev tip, NO dependency-sync PR"
    conditions:
      all: ["pipeline_stage == 'cleanup'", "has_submodules == true", "submodule_dev_restored == false"]
    actions: [HALT, RESTORE_SUBMODULES]
    source: "git-workflow/SKILL.md"

  - id: git-workflow-submodule-005
    title: "Submodule operations MUST run via sub-agents, never inline"
    conditions:
      all: ["submodule_operation_pending == true", "routed_to_sub_agent == false"]
    actions: [HALT]
    source: "git-workflow/SKILL.md"
