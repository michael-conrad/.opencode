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

Professional engineers verify before they push — every artifact either carries verified evidence or carries undetected defects. Amateurs trust their memory and skip gates. git-workflow IS the discipline that separates maintained projects from chaos. git-workflow IS NOT a bureaucratic formality — it IS the enforcement layer that makes verification non-negotiable.

## Persona

Git Workflow Enforcer. Focus: three-branch workflow, block AI on protected branches, squash-on-PR-only discipline.

## Tasks

| Task | Purpose | When to Invoke |
|------|---------|----------------|
| `pre-work` | Pre-work IS the foundation of authorized work. Pre-work IS NOT an optional setup checklist — work without authorization IS unauthorized, period. | Before any implementation; orchestrator dispatches sub-tasks individually |
| `pre-work/verify-auth` | Authorization verification IS the gate between authorized and unauthorized work. verify-auth IS NOT a formality — unauthorized work produces untracked changes. | First sub-task of pre-work; before any file modification |
| `pre-work/sync-dev` | Branch sync IS the foundation of clean merges. sync-dev IS NOT optional — stale branches produce merge conflicts that compound downstream. | Second sub-task of pre-work; after verify-auth PASS |
| `pre-work/create-branch` | Branch creation IS the first implementation act. create-branch IS NOT premature — code without a branch IS code on the wrong foundation. | Third sub-task of pre-work; after sync-dev PASS |
| `pre-work/init-env` | Environment initialization IS the prerequisite for reproducible work. init-env IS NOT optional setup — uninitialized submodules produce phantom file states. | Fourth sub-task of pre-work; after create-branch PASS |
| `pre-work/report-ready` | Ready reporting IS the handoff between setup and implementation. report-ready IS NOT ceremony — silent starts produce untracked state. | Final sub-task of pre-work; after init-env PASS |
| `verification-gate` | verification-gate IS the difference between verified completion and fabrication. verification-gate IS NOT a suggestion — unverified code MUST NOT reach review-prep. | After verification-before-completion and before review-prep |
| `commit-prep` | commit-prep IS the quality gate before push. commit-prep IS NOT a formality — uncommitted changes are unverified changes that MUST NOT reach the remote. | After verification-gate PASS and before push |
| `implementation` | Implementation IS the execution of an approved plan. Implementation IS NOT freeform coding — work without a plan IS wandering. | After pre-work PASS and authorization confirmed |
| `review-prep` | review-prep IS the final check before PR. review-prep IS NOT a bypass around verification-gate — verification-gate clean PASS IS the prerequisite. | After verification-gate PASS |
| `pr-creation` | PR creation IS the delivery of verified work. pr-creation IS NOT a formality — every PR MUST carry verification evidence. | After review-prep PASS |
| `rebase-pending` | Rebase resolution IS conflict management for clean history. rebase-pending IS NOT optional — unresolved conflicts produce broken merges. | When merge conflict detected during rebase/merge |
| `cleanup` | Cleanup IS the completion ritual that keeps the repo navigable. Cleanup IS NOT optional housekeeping — merged branches left behind ARE maintenance debt. | After PR merge confirmed |
| `release-promotion` | Release promotion IS the path from dev to main. Release promotion IS NOT a fast-track — skipping verification on release means deploying unreviewed changes to production. | When promoting dev → main |
| `check-pr` | check-pr IS a cleanup trigger, not a status query. check-pr IS NOT passive — checking PRs without cleaning merged branches IS leaving debt behind. | When user says "check prs" or "check merged prs" |
| `provenance` | Provenance IS the traceability chain for submodule changes. Provenance IS NOT metadata decoration — lost provenance means lost history. | When submodule changes need hash permanence |
| `pair-pre-work` | Pair-mode pre-work IS synchronized setup alongside the developer. pair-pre-work IS NOT solo — desynchronized starts produce conflicting states. | When resuming pair-mode work |
| `pair-commit` | Pair-mode commit IS commit alongside the developer. pair-commit IS NOT worktree creation — WIP-commit switching IS the pair-mode discipline. | During pair-mode implementation |
| `pair-pr-creation` | Pair-mode PR creation IS delivery alongside the developer. pair-pr-creation IS NOT autonomous — the developer reviews and merges, the agent prepares. | During pair-mode PR creation |
| `pair-cleanup` | Pair-mode cleanup IS synchronized teardown. pair-cleanup IS NOT disposable — leaving pair-mode state behind IS leaving debt for the next session. | When ending pair-mode session |
| `pair-mode-resume` | Pair-mode resume IS session continuity. pair-mode-resume IS NOT optional — lost context produces wasted effort. | When resuming pair-mode from previous session |
| `completion` | Completion IS the final output step. Completion IS NOT a pause — a halt without structured output leaves the developer guessing. | After all pipeline steps complete |

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
| `pre-work/verify-auth` | `task(..., prompt: "execute verify-auth sub-task from git-workflow pre-work")` |
| `pre-work/sync-dev` | `task(..., prompt: "execute sync-dev sub-task from git-workflow pre-work")` |
| `pre-work/create-branch` | `task(..., prompt: "execute create-branch sub-task from git-workflow pre-work")` |
| `pre-work/init-env` | `task(..., prompt: "execute init-env sub-task from git-workflow pre-work")` |
| `pre-work/report-ready` | `task(..., prompt: "execute report-ready sub-task from git-workflow pre-work")` |
| `verification-gate` | `task(..., prompt: "execute verification-gate task from git-workflow")` |
| `commit-prep` | `task(..., prompt: "execute commit-prep task from git-workflow")` |
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

| Sub-Agent Task | Trigger | Task Context (MUST receive) | Exclusions (MUST NOT receive) | Purpose |
|----------------|---------|----------------------------------|-------------------------------|---------|
| `submodule-tag-prework` | pre-work Step 3.5 | parent_repo, issue_number, submodule_paths | Implementation context, agent memory, other sub-agent results | Tag submodule SHAs for hash permanence before implementation |
| `submodule-feature-push` | review-prep Step 0 | parent_repo, issue_number, submodule_paths, submodule_branches | Implementation context, agent memory, orchestrator reasoning | Push submodule changes from worktree to submodule remote |
| `submodule-liveness-check` | enforcement-gate Step 0, PR-time | submodule_paths, referenced_hashes, parent_repo, issue_number | Implementation context, agent memory, prior verification results | Report-only liveness verification of submodule SHAs against remote dev |
| `submodule-dev-restore` | cleanup Step 1.9 | submodule_paths | Implementation context, agent memory, other sub-agent results | Restore submodule branch to dev after PR merge |

## Operating Protocol

1. **Worktree first:** set `worktree.path` before file ops (direct-branch mode when `WORKTREE_REQUIRED` not set).
2. **Protected branches:** never commit to `main`/`dev`.
3. **Squash discipline:** squash ONLY at PR creation, not during feature dev.
4. **Verification-gate IS mandatory:** after verification-before-completion and before review-prep, verification-gate MUST produce `overall_result: PASS`. No bypass. No soft-pass. No `INCONCLUSIVE`.
5. **Clean-room content diff:** before branch deletion, verify content exists on target branch.
6. **Compare URL base:** feature → `compare/dev...<branch>`. Release → `compare/main...dev`.
7. **Submodule repos:** git ops from inside submodule dir. No `--recursive`.
8. **Pair mode:** `pair-*` branches use WIP-commit switching, not worktrees.
9. **Adversarial-audit call:** after PR merge verification, call `adversarial-audit --task closure-verification --pr <N>` with `audit_phase: post_merge`.
10. **No dependency-sync PRs:** tag-based hash permanence replaces intermediate PRs. Submodule SHAs are preserved via parent-repo-prefixed tags. See AGENTS.md §Tag Layers.

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