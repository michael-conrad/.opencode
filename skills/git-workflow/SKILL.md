---
name: git-workflow
description: "Use when creating a branch, committing, pushing, or creating a PR, rebase/merge conflicts (invoke conflict-resolution), \"check pr\"/\"check prs\"/\"check merged prs\"/\"pr merged\" (PR state verification + cleanup), \"release PR\"/\"promote to main\"/\"dev to main\" (release-promotion). Branch-and-PR discipline is not bureaucracy — it is what separates maintainable projects from chaos."
type: discipline-enforcing
license: MIT
compatibility: opencode
---

# Skill: git-workflow

## Overview

Git Workflow Enforcer. Three-branch model: feature → dev → main. AI commits blocked on protected branches. Feature branches merge to `dev` via PR. Squash at PR creation only. Submodule-aware.



## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "pre-work" / "setup branch" / "sync dev" | `pre-work` | `sub-task` | {branch_name} |
| "implementation" / "commit" / "save work" | `implementation` | `sub-task` | {branch_name} |
| "review-prep" / "prepare review" | `review-prep` | `sub-task` | {branch_name} |
| "pr-creation" / "create PR" | `pr-creation` | `sub-task` | {branch_name, spec_summary} |
| "rebase" / "rebase pending" | `rebase-pending` | `sub-task` | {branch_name} |
| "cleanup" / "post-merge cleanup" | `cleanup` | `sub-task` | {pr_merge_status} |
| "release" / "promote to main" / "dev to main" | `release-promotion` | `sub-task` | {branch_name} |
| "check pr" / "check prs" / "check merged prs" / "pr merged" | `check-pr` | `sub-task` | {branch_name} |
| "provenance" / "provenance check" | `provenance` | `sub-task` | {submodule_path} |
| completion / workflow end | `completion` | `sub-task` | {workflow_state} |

## Persona

Git Workflow Enforcer. Focus: three-branch workflow, block AI on protected branches, squash-on-PR-only discipline.

## Tasks


| `pre-work` |
| `implementation` |
| `review-prep` |
| `pr-creation` |
| `rebase-pending` |
| `cleanup` |
| `release-promotion` |
| `check-pr` |
| `provenance` |
| `pair-pre-work` |
| `pair-commit` |
| `pair-pr-creation` |
| `pair-cleanup` |
| `pair-mode-resume` |
| `completion` |

## Routing: Feature PR vs Release PR

| Request Type | Target |

| Feature PR (feature/* → dev) | `pr-creation-workflow` skill |
| Release PR (dev → main) | `git-workflow --task release-promotion` |

## Invocation

`skill({name: "git-workflow"})` — call the skill, then call via task():

| Task | Call via task() |

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

| Sub-Agent Task | Trigger | Task Context (MUST receive) | Exclusions (MUST NOT receive) | Config |
|----------------|---------|----------------------------------|-------------------------------|--------|
| `submodule-tag-prework` | pre-work Step 3.5 | parent_repo, issue_number, submodule_paths | Implementation context, agent memory, other sub-agent results | `.opencode/agents/submodule-tag-prework.jsonc` |
| `submodule-feature-push` | review-prep Step 0 | parent_repo, issue_number, submodule_paths, submodule_branches | Implementation context, agent memory, orchestrator reasoning | `.opencode/agents/submodule-feature-push.jsonc` |
| `submodule-liveness-check` | enforcement-gate Step 0, PR-time | submodule_paths, referenced_hashes, parent_repo, issue_number | Implementation context, agent memory, prior verification results | `.opencode/agents/submodule-liveness-check.jsonc` |
| `submodule-dev-restore` | cleanup Step 1.9 | submodule_paths | Implementation context, agent memory, other sub-agent results | `.opencode/agents/submodule-dev-restore.jsonc` |

## Operating Protocol

- [ ] 1. **Worktree first:** set `worktree.path` before file ops (direct-branch mode when `WORKTREE_REQUIRED` not set).
- [ ] 2. **Protected branches:** never commit to `main`/`dev`.
- [ ] 3. **Squash discipline:** squash ONLY at PR creation, not during feature dev.
- [ ] 4. **Clean-room content diff:** before branch deletion, verify content exists on target branch.
- [ ] 5. **Compare URL base:** feature → `compare/dev...<branch>`. Release → `compare/main...dev`.
- [ ] 6. **Submodule repos:** git ops from inside submodule dir. No `--recursive`.
- [ ] 7. **Pair mode:** `pair-*` branches use WIP-commit switching, not worktrees.
- [ ] 8. **Adversarial-audit call:** after issue closure, before branch cleanup, call `adversarial-audit --task closure-verification --pr <N>` with `audit_phase: post_merge`.
- [ ] 9. **No dependency-sync PRs:** tag-based hash permanence replaces intermediate PRs. Submodule SHAs are preserved via parent-repo-prefixed tags. See AGENTS.md §Tag Layers.

### Tag Convention (Canonical)

All git tags in this project follow a unified naming convention. The suffix rule is defined in spec #950 and applies to ALL tag types.

**Suffix Rule:** Tag suffix MUST be derived from the submodule directory name in `.gitmodules` (e.g., `.opencode` → `-opencode`). DO NOT use issue title, phase name, or any ad-hoc string.

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

> **Context cost frame:** The orchestrator's context is the most expensive resource in the pipeline — sub-agents do the work, not the orchestrator. Every byte held by the orchestrator costs `byte × remaining_dispatches²`. See `020-go-prohibitions.md` §1.1.

The orchestrator MUST NOT preload execution context into `task()` prompts.
Every sub-agent MUST independently discover scope and produce its own result contract.

#### Forbidden in task() Prompts

| Violation | Forbidden Pattern | Correct Pattern |
|-----------|-------------------|-----------------|
| Preloaded file paths | "Read cleanup/branch-cleanup.md then execute step 1" | "execute cleanup task from git-workflow" |
| Preloaded step sequences | "Step 1: sync dev. Step 2: delete branch." | "execute cleanup task from git-workflow" |
| Preloaded expected outcomes | "Return { cleanup_status, branch_deleted }" | Let sub-agent define its own result contract |
| Preloaded orchestrator reasoning | "The merge was just completed so we need to..." | Pure objective, no narrative |

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
