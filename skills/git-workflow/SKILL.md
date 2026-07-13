---
name: git-workflow
description: "Git branch, commit, push, and PR workflow manager with cleanup and provenance tracking. Dispatch when creating a branch, committing, pushing, or creating a PR. Also dispatch when handling rebase/merge conflicts (invoke conflict-resolution), checking PR state and cleanup, or running provenance tracking. Branch-and-PR discipline is REQUIRED — always follow the workflow"
license: MIT
compatibility: opencode
---

# Skill: git-workflow

## Overview

Git Workflow Enforcer. Trunk-based development: feature branches target any branch. AI commits blocked on protected branches. Feature branches merge via PR. Squash at PR creation only. Submodule-aware.

## Worktree Mode

This skill operates in the main repo directory (direct-branch mode). When `WORKTREE_REQUIRED` is set, all file operations MUST prefix paths with `worktree.path`.

## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work that should be delegated to a sub-agent produces defective deliverables that must be discarded
- [ ] 3. Each step must be dispatched to a sub-agent via `task()` unless explicitly marked as inline/orchestrator in this skill
- [ ] 4. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "pre-work" / "setup branch" / "sync default branch" | `pre-work` | `sub-task` | {branch_name} |
| "implementation" / "commit" / "save work" | `implementation` | `sub-task` | {branch_name} |
| "review-prep" / "prepare review" | `review-prep` | `sub-task` | {branch_name} |
| "pr-creation" / "create PR" | `pr-creation` | `sub-task` | {branch_name, spec_summary} |
| "rebase" / "rebase pending" | `rebase-pending` | `sub-task` | {branch_name} |
| "cleanup" / "post-merge cleanup" | `cleanup` | `sub-task` | {pr_merge_status} |
| "check pr" / "check prs" / "check merged prs" / "pr merged" | `check-pr` | `sub-task` | {branch_name} |
| "provenance" / "provenance check" | `provenance` | `sub-task` | {submodule_path} |
| "sync submodules" / "update submodules" | `submodule-sync` | `sub-task` | {submodule_paths} |
| "release" / "release/v" | `pre-work` | `sub-task` | {branch_name: release/v{semver}} |
| "release PR" / "is_release" | `pr-creation` | `sub-task` | {branch_name, spec_summary, is_release: true} |
| "pre-commit-pointer-check" / "check submodule pointers" | `pre-commit-pointer-check` | `sub-task` | {branch_name} |
| completion / workflow end | `completion` | `sub-task` | {workflow_state} |

## Persona

Git Workflow Enforcer. Focus: trunk-based development workflow, block AI on protected branches, squash-on-PR-only discipline.

## Tasks


| `pre-work` |
| `implementation` |
| `review-prep` |
| `pr-creation` |
| `rebase-pending` |
| `cleanup` |
| `check-pr` |
| `provenance` |
| `pair-pre-work` |
| `pair-commit` |
| `pair-pr-creation` |
| `pair-cleanup` |
| `pair-mode-resume` |
| `submodule-sync` |
| `pre-commit-pointer-check` |
| `completion` |

## Routing: Feature PR

| Request Type | Target |

| Feature PR (feature/* → target) | `pr-creation-workflow` skill |

## Invocation

`skill({name: "git-workflow"})` — call the skill, then call via task():

| Task | Call via task() |

| `pre-work` | `task(..., prompt: "execute pre-work task from git-workflow")` |
| `implementation` | `task(..., prompt: "execute implementation task from git-workflow")` |
| `review-prep` | `task(..., prompt: "execute review-prep task from git-workflow")` |
| `pr-creation` | `task(..., prompt: "execute pr-creation task from git-workflow")` |
| `rebase-pending` | `task(..., prompt: "execute rebase-pending task from git-workflow")` |
| `cleanup` | `task(..., prompt: "execute cleanup task from git-workflow")` |
| `check-pr` | `task(..., prompt: "execute check-pr task from git-workflow")` |
| `provenance` | `task(..., prompt: "execute provenance task from git-workflow")` |
| `submodule-sync` | `task(..., prompt: "execute submodule-sync task from git-workflow")` |
| `pre-commit-pointer-check` | `task(..., prompt: "execute pre-commit-pointer-check task from git-workflow")` |
| `completion` | `task(..., prompt: "execute completion task from git-workflow")` |

**CLI equivalent (for human TUI use):** `` `skill({name: "git-workflow"})` ``

## Operating Protocol

See `git-workflow/tasks/operating-protocol.md` for the full operating protocol and tag conventions.

## Sub-Agent Routing

All tasks run via `task(subagent_type="general")` with `{ branch_name, worktree.path, github.owner, github.repo }`, excluding implementation context and agent memory. Auditor tasks use subagent_type from resolve-models result contract (auditor_1/auditor_2) — NOT `general`. Include audit_phase in task context when routing auditors. See audit SKILL.md §DISPATCH_GATE. `pr-creation` receives spec summary. `cleanup` receives PR merge status. `provenance` receives submodule path. `pre-analysis` receives only `{ issue_number, task_description, github.owner, github.repo }`. No inline work.

Submodule operations are standard tasks dispatched via `task(subagent_type="general")` with scoped context. All are clean-room runs — no implementation context, agent memory, or orchestrator reasoning shared. Submodule git operations are NEVER performed inline.

### DISPATCH_GATE — Orchestrator task() Prompt Protocol

> **Context cost frame:** These are internal operational bookkeeping notes describing how context flows through the pipeline — they are NOT implementation complexity measures. Implementation work is measured ONLY by whether tested verified correct code operations pass with 100% clean PASS.
> This cost frame applies to orchestrator context only — it does NOT mean the agent should minimize message count, pipeline steps, or user-facing output.

The orchestrator MUST NOT preload execution context into `task()` prompts.
Every sub-agent MUST independently discover scope and produce its own result contract.

#### Forbidden in task() Prompts

| Violation | Forbidden Pattern | Correct Pattern |
|-----------|-------------------|-----------------|
| Preloaded file paths | "Read cleanup/branch-cleanup.md then execute step 1" | "execute cleanup task from git-workflow" |
| Preloaded step sequences | "Step 1: sync $DEFAULT_BRANCH. Step 2: delete branch." | "execute cleanup task from git-workflow" |
| Preloaded expected outcomes | "Return { cleanup_status, branch_deleted }" | Let sub-agent define its own result contract |
| Preloaded orchestrator reasoning | "The merge was just completed so we need to..." | Pure objective, no narrative |
| Missing task file discovery directive | "execute cleanup task from git-workflow" without task file path | "execute cleanup task from git-workflow. Read `git-workflow/tasks/cleanup.md` first" |

## Required: Sub-agent Task File Discovery Directive

Every `task()` prompt that dispatches a named task MUST include a discovery directive in the format:

```
execute <task> from <skill>. Read `<skill>/tasks/<task>.md` first
```

This directive tells the sub-agent which task file to load independently — it is NOT preloading the file content. The sub-agent opens and reads the task file in its own clean-room context, discovers the procedure, and executes autonomously. Without this directive, the sub-agent must search for the correct task file, which is wasted context and routing ambiguity.

This is NOT a violation of the preloading prohibition. The task file path is routing metadata (which file to load), not execution context (what the file contains). The sub-agent still reads the file independently and discovers scope on its own.

#### Dispatch Context Contract

Every `task()` call MUST include only:

- `worktree.path`
- `github.owner`
- `github.repo`
- `authorization_scope`
- `halt_at`
- `pipeline_phase`

Plus skill-specific fields per the `## Sub-Agent Routing` section above.

Exclusions (MUST NOT be in prompt):
- `orchestrator_reasoning`
- `expected_outcomes`
- `inline_file_paths`
- `agent_memory`
- `cached_verification_results`

#### Sub-Agent Entry Criteria

A sub-agent receiving a `task()` prompt MUST reject it if the prompt contains:
- Inline file paths to task files
- Inline step or procedure definitions
- Expected outcome structures or schema constraints
- Pre-loaded evidence or orchestrator-derived conclusions

Return `status: BLOCKED` with `reason: PRELOADED_CONTEXT_REJECTED`.

#### Orchestrator Entry Criteria

After loading this skill and reading the Trigger Dispatch Table, the orchestrator MUST:
- Use the exact `task(..., prompt: "...")` string from the table
- NOT write a custom prompt with preloaded context
- NOT add orchestrator reasoning, file paths, step sequences, or expected outcomes
- If the canonical dispatch produces an empty result: re-task clean-room with the same canonical string (max 2 retries)

## Operating Protocol

- [ ] 1. **No commits to trunk:** AI commits blocked on `main` or `$DEFAULT_BRANCH`
- [ ] 2. **Squash at PR only:** Squash commits only during PR creation, never before
- [ ] 3. **Compare URL base:** Feature branch compare URLs MUST use `$DEFAULT_BRANCH` as base
- [ ] 4. **Submodule tagging:** Pre-work MUST tag submodule trunk tips with `<parent>/<issue>` format
- [ ] 5. **Submodule feature-branch pushes:** Submodule changes MUST use feature-branch pushes with tip tags, not trunk pushes
- [ ] 6. **Submodule liveness check:** PR-time MUST verify submodule hash reachability via tags
- [ ] 7. **Cleanup restores submodules:** Cleanup MUST restore submodules to trunk tip, NO dependency-sync PR
- [ ] 8. **Submodule operations via sub-agents:** Submodule operations MUST run via sub-agents, never inline
- [ ] 9. **Submodule sync via $DEFAULT_BRANCH:** Submodule sync MUST resolve trunk branch via `$DEFAULT_BRANCH`, not hardcoded branch name
- [ ] 10. **Submodule divergence:** Submodule divergence MUST be handled autonomously before escalation
- [ ] 11. **No main branch fallback:** No `git checkout -b main dev || true` fallback in submodule sync operations

## Cross-References

Skills: `conflict-resolution`, `pr-creation-workflow`, `using-git-worktrees`, `pre-analysis`, `audit --task closure-verification`. Guidelines: `010-approval-gate.md`, `000-critical-rules.md`.


