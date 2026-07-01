---
name: git-workflow
description: "Use when creating a branch, committing, pushing, or creating a PR. Also use when handling rebase/merge conflicts (invoke conflict-resolution), checking PR state and cleanup, or creating release PRs. Invoke for: branch creation, commit, push, PR creation, rebase, merge, conflict resolution dispatch, PR state verification, cleanup, release PR promotion. Branch-and-PR discipline is REQUIRED — always follow the workflow. Trigger phrases: create branch, commit, push, create PR, rebase, merge, check pr, check prs, check merged prs, pr merged, release PR, promote to main, dev to main."
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
- [ ] 4. Sub-agents must not dispatch sub-agents
- [ ] 5. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "pre-work" / "setup branch" / "sync default branch" | `pre-work` | `sub-task` | {branch_name} |
| "implementation" / "commit" / "save work" | `implementation` | `sub-task` | {branch_name} |
| "review-prep" / "prepare review" | `review-prep` | `sub-task` | {branch_name} |
| "pr-creation" / "create PR" | `pr-creation` | `sub-task` | {branch_name, spec_summary} |
| "rebase" / "rebase pending" | `rebase-pending` | `sub-task` | {branch_name} |
| "cleanup" / "post-merge cleanup" | `cleanup` | `sub-task` | {pr_merge_status} |
| "release" / "promote to main" / "target to main" | `pr-creation` | `sub-task` | {branch_name, is_release: true} |
| "check pr" / "check prs" / "check merged prs" / "pr merged" | `check-pr` | `sub-task` | {branch_name} |
| "provenance" / "provenance check" | `provenance` | `sub-task` | {submodule_path} |
| "sync submodules" / "update submodules" | `submodule-sync` | `sub-task` | {submodule_paths} |
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
| `completion` |

## Routing: Feature PR vs Release PR

| Request Type | Target |

| Feature PR (feature/* → target) | `pr-creation-workflow` skill |
| Release PR (target → main) | `pr-creation-workflow` skill with `{is_release: true}` |

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
| `completion` | `task(..., prompt: "execute completion task from git-workflow")` |

**CLI equivalent (for human TUI use):** `/skill git-workflow --task <task>`

## Sub-Agent Tasks for Submodule Operations

| Sub-Agent Task | Trigger | Task Context (MUST receive) | Exclusions (MUST NOT receive) | Config |
|----------------|---------|----------------------------------|-------------------------------|--------|
| `submodule-tag-prework` | pre-work Step 3.5 | parent_repo, issue_number, submodule_paths | Implementation context, agent memory, other sub-agent results | `.opencode/agents/submodule-tag-prework.jsonc` |
| `submodule-feature-push` | review-prep Step 0 | parent_repo, issue_number, submodule_paths, submodule_branches | Implementation context, agent memory, orchestrator reasoning | `.opencode/agents/submodule-feature-push.jsonc` |
| `submodule-liveness-check` | enforcement-gate Step 0, PR-time | submodule_paths, referenced_hashes, parent_repo, issue_number | Implementation context, agent memory, prior verification results | `.opencode/agents/submodule-liveness-check.jsonc` |
| `submodule-dev-restore` | cleanup Step 1.9 | submodule_paths | Implementation context, agent memory, other sub-agent results | `.opencode/agents/submodule-dev-restore.jsonc` |
| `submodule-sync` | user "sync submodules" / mid-feature currency | submodule_paths | Implementation context, agent memory, orchestrator reasoning | `.opencode/agents/submodule-sync.jsonc` |

## Operating Protocol

- [ ] 1. **Worktree first:** set `worktree.path` before file ops (direct-branch mode when `WORKTREE_REQUIRED` not set).
- [ ] 2. **Protected branches:** never commit to `main`.
- [ ] 3. **Squash discipline:** squash ONLY at PR creation, not during feature dev.
- [ ] 4. **Clean-room content diff:** before branch deletion, verify content exists on target branch.
- [ ] 5. **Compare URL base:** feature → `compare/<target>...<branch>`. Release → `compare/main...<target>`.
- [ ] 6. **Submodule repos:** git ops from inside submodule dir. No `--recursive`.
- [ ] 7. **Pair mode:** `pair-*` branches use WIP-commit switching, not worktrees.
- [ ] 8. **Adversarial-audit call:** after issue closure, before branch cleanup, call `adversarial-audit --task closure-verification --pr <N>` with `audit_phase: post_merge`.
- [ ] 9. **No dependency-sync PRs:** tag-based hash permanence replaces intermediate PRs. Submodule SHAs are preserved via parent-repo-prefixed tags. See AGENTS.md §Tag Layers.
- [ ] 10. **Correctness over speed.** Every result will be independently audited by two different cloud models. A slow correct answer is strictly better than a fast incorrect one. Fabrication wastes time — the work will be re-dispatched. Static grep is NOT acceptable verification — behavioral compliance requires actual model execution with cross-validated PASS verdict.

### Tag Convention (Canonical)

All git tags in this project follow a unified naming convention. The suffix rule is defined in spec #950 and applies to ALL tag types.

**Suffix Rule:** Tag suffix MUST be derived from the discovered repo's directory name (e.g., `.opencode` → `-opencode`). Use glob scan to discover repo directories: `REPO_PATHS=$(ls -d .git/ */.git/ */.git 2>/dev/null | sed 's|/\.git$||' | sed 's|/$||')`. For each non-root path, use the directory name as the suffix. DO NOT use issue title, phase name, or any ad-hoc string.

| Tag Type | Format | Example | Purpose |
|----------|--------|---------|---------|
| Hash permanence | `<parent>/<issue>-<submodule>` | `opencode-config/950-opencode` | Pin submodule SHA at feature-branch tip |
| Checkpoint | `<parent>/checkpoint/<issue>/phase-<N>-<submodule>` | `opencode-config/checkpoint/391/phase-1-opencode` | Rollback anchor after sub-agent verification PASS |
| Release | `<parent>/v<version>` | `opencode-config/v0.1.1` | Release marker (no suffix) |

**Cross-references:**
- Spec #950 — canonical suffix derivation rule
- Spec #391 — checkpoint tag lifecycle (create during assemble-work, delete during cleanup)
- `submodule-tag-prework` task — hash permanence tag creation
- `pipeline-executor.md` — checkpoint creation and rollback substeps
- `branch-cleanup.md` Step 3.3 — checkpoint tag deletion

## Sub-Agent Routing

All tasks run via `task(subagent_type="general")` with `{ branch_name, worktree.path, github.owner, github.repo }`, excluding implementation context and agent memory. Auditor tasks use subagent_type from resolve-models result contract (auditor_1/auditor_2) — NOT `general`. Include audit_phase in task context when routing auditors. See adversarial-audit SKILL.md §DISPATCH_GATE. `pr-creation` receives spec summary. `cleanup` receives PR merge status. `provenance` receives submodule path. `pre-analysis` receives only `{ issue_number, task_description, github.owner, github.repo }`. No inline work.

Submodule sub-agents (`submodule-tag-prework`, `submodule-feature-push`, `submodule-liveness-check`, `submodule-dev-restore`) receive scoped context per the Sub-Agent Tasks for Submodule Operations table above. All are clean-room runs — no implementation context, agent memory, or orchestrator reasoning shared. Submodule git operations are NEVER performed inline.

### DISPATCH_GATE — Orchestrator task() Prompt Protocol

> **Context cost frame:** These are internal operational bookkeeping notes describing how context flows through the pipeline — they are NOT implementation complexity measures. Implementation work is measured ONLY by whether tested verified correct code operations pass with 100% clean PASS.
> This cost frame applies to orchestrator context only — it does NOT mean the agent should minimize message count, pipeline steps, or user-facing output.

The orchestrator MUST NOT preload execution context into `task()` prompts.
Every sub-agent MUST independently discover scope and produce its own result contract.

#### Forbidden in task() Prompts

| Violation | Forbidden Pattern | Correct Pattern |
|-----------|-------------------|-----------------|
| Preloaded file paths | "Read cleanup/branch-cleanup.md then execute step 1" | "execute cleanup task from git-workflow" |
| Preloaded step sequences | "Step 1: sync dev. Step 2: delete branch." | "execute cleanup task from git-workflow" |
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
- `pr_strategy`
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

## Cross-References

Skills: `conflict-resolution`, `pr-creation-workflow`, `using-git-worktrees`, `pre-analysis`, `adversarial-audit --task closure-verification`. Guidelines: `010-approval-gate.md`, `000-critical-rules.md`.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-06-01T00:00:00Z"
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
    title: "Compare URL base must be target for feature branches"
    conditions:
      all: ["compare_url_generated == true", "base_branch != '<target>'", "is_feature_branch == true"]
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
