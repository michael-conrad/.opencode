---
name: git-workflow
description: "Git branch, commit, push, and PR workflow dispatcher that routes to sub-skills. Dispatch when creating a branch, committing, pushing, or creating a PR. Also dispatch when handling rebase/merge conflicts, checking PR state and cleanup, or running provenance tracking. Triggers when: agent determines a branch operation is needed, agent needs to commit changes, agent needs to create a PR, agent needs to clean up after merge, agent encounters a rebase conflict."
license: MIT
compatibility: opencode
provenance: AI-generated
---

# Skill: git-workflow (Dispatcher)

## Overview

This is a **dispatcher skill** that routes to 5 sub-skills. All original trigger phrases are preserved for backward compatibility.

## Sub-Skills

| Sub-Skill | Purpose | Task Count |
|-----------|---------|------------|
| `git-workflow-branch` | Branch creation, submodule sync, provenance, pair mode setup | 8 task files |
| `git-workflow-commit` | Implementation commits, commit prep, pair commits | 3 task files |
| `git-workflow-pr` | PR creation, review prep, pair PR, completion, post-implementation | 7 task files |
| `git-workflow-cleanup` | Post-merge cleanup, PR state check, pair cleanup | 4 task files |
| `git-workflow-conflict` | Rebase/merge conflict resolution | 1 task file |

## Trigger Dispatch Table

| User says / Context | Task | Dispatches To | Dispatch | Context passed |
|---------------------|------|---------------|----------|----------------|
| "pre-work" / "setup branch" / "sync default branch" | `pre-work` | `git-workflow-branch --task pre-work` | `sub-task` | {branch_name} |
| "implementation" / "commit" / "save work" | `implementation` | `git-workflow-commit --task implementation` | `sub-task` | {branch_name} |
| "review-prep" / "prepare review" | `review-prep` | `git-workflow-pr --task review-prep` | `sub-task` | {branch_name} |
| "pr-creation" / "create PR" | `pr-creation` | `git-workflow-pr --task pr-creation` | `sub-task` | {branch_name, spec_summary} |
| "rebase" / "rebase pending" | `rebase-pending` | `git-workflow-conflict --task rebase-pending` | `sub-task` | {branch_name} |
| "cleanup" / "post-merge cleanup" | `cleanup` | `git-workflow-cleanup --task cleanup` | `sub-task` | {pr_merge_status} |
| "check pr" / "check prs" / "check merged prs" / "pr merged" | `check-pr` | `git-workflow-cleanup --task check-pr` | `sub-task` | {branch_name} |
| "provenance" / "provenance check" | `provenance` | `git-workflow-branch --task provenance` | `sub-task` | {submodule_path} |
| "sync submodules" / "update submodules" | `submodule-sync` | `git-workflow-branch --task submodule-sync` | `sub-task` | {submodule_paths} |
| "release" / "release/v" | `pre-work` | `git-workflow-branch --task pre-work` | `sub-task` | {branch_name: release/v{semver}} |
| "release PR" / "is_release" | `pr-creation` | `git-workflow-pr --task pr-creation` | `sub-task` | {branch_name, spec_summary, is_release: true} |
| "pre-commit-pointer-check" / "check submodule pointers" | `pre-commit-pointer-check` | `git-workflow-branch --task pre-commit-pointer-check` | `sub-task` | {branch_name} |
| completion / workflow end | `completion` | `git-workflow-pr --task completion` | `sub-task` | {workflow_state} |

## Invocation

`skill({name: "git-workflow"})` — call the skill, then dispatch to the sub-skill:

| Task | Canonical Dispatch String |
|------|--------------------------|
| `pre-work` | `task(..., prompt: "execute pre-work from git-workflow-branch. Read \`git-workflow-branch/tasks/pre-work.md\` first")` |
| `implementation` | `task(..., prompt: "execute implementation from git-workflow-commit. Read \`git-workflow-commit/tasks/implementation.md\` first")` |
| `review-prep` | `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")` |
| `pr-creation` | `task(..., prompt: "execute pr-creation from git-workflow-pr. Read \`git-workflow-pr/tasks/pr-creation.md\` first")` |
| `rebase-pending` | `task(..., prompt: "execute rebase-pending from git-workflow-conflict. Read \`git-workflow-conflict/tasks/rebase-pending.md\` first")` |
| `cleanup` | `task(..., prompt: "execute cleanup from git-workflow-cleanup. Read \`git-workflow-cleanup/tasks/cleanup.md\` first")` |
| `check-pr` | `task(..., prompt: "execute check-pr from git-workflow-cleanup. Read \`git-workflow-cleanup/tasks/check-pr.md\` first")` |
| `provenance` | `task(..., prompt: "execute provenance from git-workflow-branch. Read \`git-workflow-branch/tasks/provenance.md\` first")` |
| `submodule-sync` | `task(..., prompt: "execute submodule-sync from git-workflow-branch. Read \`git-workflow-branch/tasks/submodule-sync.md\` first")` |
| `pre-commit-pointer-check` | `task(..., prompt: "execute pre-commit-pointer-check from git-workflow-branch. Read \`git-workflow-branch/tasks/pre-commit-pointer-check.md\` first")` |
| `completion` | `task(..., prompt: "execute completion from git-workflow-pr. Read \`git-workflow-pr/tasks/completion.md\` first")` |

## DISPATCH_GATE — Orchestrator task() Prompt Protocol

The orchestrator MUST NOT preload execution context into `task()` prompts. Every sub-agent MUST independently discover scope and produce its own result contract.

### Forbidden in task() Prompts

| Violation | Forbidden Pattern | Correct Pattern |
|-----------|-------------------|-----------------|
| Preloaded file paths | "Read the task file then execute step 1" | "execute pre-work from git-workflow-branch" |
| Preloaded step sequences | "Step 1: sync. Step 2: create branch." | "execute pre-work from git-workflow-branch" |
| Preloaded expected outcomes | "Return { branch_name }" | Let sub-agent define its own result contract |
| Preloaded orchestrator reasoning | "The merge was just completed so we need to..." | Pure objective, no narrative |

### Dispatch Context Contract

Every `task()` call MUST include only:
- `worktree.path`
- `github.owner`
- `github.repo`
- `authorization_scope`
- `halt_at`
- `pipeline_phase`

Plus skill-specific fields per the Trigger Dispatch Table above.

## Cross-References

Sub-skills: `git-workflow-branch`, `git-workflow-commit`, `git-workflow-pr`, `git-workflow-cleanup`, `git-workflow-conflict`. Skills: `conflict-resolution`, `pr-creation-workflow`, `using-git-worktrees`, `pre-analysis`. Guidelines: `010-approval-gate.md`, `000-critical-rules.md`.
