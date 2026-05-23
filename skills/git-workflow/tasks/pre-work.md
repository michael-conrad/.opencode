# Task: pre-work (Sequence Reference)

## Purpose

Pre-work IS the foundation of authorized work. Work without authorization IS unauthorized — period. The pre-work sequence establishes the branch, syncs the repository, and initializes the environment before any implementation begins.

This file is a **sequence reference** — not a routing file. The orchestrator reads this file to understand the correct sequence order, then dispatches each sub-task individually via `task()`.

## 🚫 ZERO TOLERANCE: Branch Before Edit

**The agent MUST create a feature branch BEFORE ANY filesystem change.** This is a Tier 1 (Non-Yielding) mandate.

**Branch creation mode is determined by `WORKTREE_REQUIRED`:**

| Mode | When | Branch Command | Path Behavior |
|------|------|---------------|---------------|
| **Direct-branch (default)** | `WORKTREE_REQUIRED` NOT set | `git checkout -b feature/X` or `git switch -c feature/X` | Relative paths work directly |
| **Worktree (opt-in)** | `WORKTREE_REQUIRED` set or developer request | `git worktree add .worktrees/feature-X -b feature/X dev` | All paths prefixed with `worktree.path` |

**In both modes, the agent MUST NOT commit to `main` or `dev`.**

## Sub-Task Sequence

The orchestrator dispatches each sub-task individually via `task()`. The sequence order is:

| Order | Sub-Task | File | Achieves |
|-------|----------|------|----------|
| 1 | `verify-auth` | `tasks/pre-work/verify-auth.md` | Authorization verification — confirms scope, halt_at, issue state, labels |
| 2 | `sync-dev` | `tasks/pre-work/sync-dev.md` | Branch sync — verifies remote dev, syncs local dev, notes submodule presence |
| 3 | `create-branch` | `tasks/pre-work/create-branch.md` | Branch creation — creates feature branch, delegates submodule-tag-prework, initializes .issues/ |
| 4 | `init-env` | `tasks/pre-work/init-env.md` | Environment init — indexes srclight, installs dependencies, verifies toolchain |
| 5 | `report-ready` | `tasks/pre-work/report-ready.md` | Ready reporting — collects branch state, confirms scope alignment, yields to orchestration |

Each sub-task has its own entry criteria, procedure, exit criteria, and task context rules defined in its respective file.

## Automatic Prerequisite Operations

**When authorization has been verified (approval-gate `verify-authorization` passed), the following operations are AUTOMATIC prerequisites that MUST be performed WITHOUT soliciting developer confirmation:**

| Operation | Sub-Task | Classification | Condition |
|-----------|----------|----------------|-----------|
| `git fetch origin` | sync-dev | Pipeline prerequisite | Remote exists |
| `git checkout dev && git pull origin dev` | sync-dev | Tier 1 mandate prerequisite | Always when remote exists |
| `submodule-tag-prework` (separate invocation) | create-branch Step 2 | Tier 1 mandate prerequisite | `.gitmodules` exists |
| `git checkout -b feature/N-xyz` or `git switch -c feature/N-xyz` | create-branch | Tier 1 mandate — required by `000-critical-rules.md` §Skipping Git Pre-Check | Always |
| `git push -u origin feature/N-xyz` | Post-report-ready | Pipeline prerequisite for `for_pr` scope | Remote exists, `halt_at >= pr_created` |

**🚫 FORBIDDEN: Soliciting developer confirmation for automatic prerequisites.** See `020-go-prohibitions.md` §1 ALWAYS DO — Cost-blind verification.

## Three-Branch Workflow Context

| Branch Type | Naming | Source | Target |
|-------------|--------|--------|--------|
| Feature | `feature/*` or `spec/*` | `dev` | `dev` |
| Dev | `dev` | — | Staging/integration (evergreen, never deleted) |
| Main | `main` or `master` | — | Production-ready code |

**AI Commit Restrictions:**
- AI cannot commit to `main`, `master`, or `dev` (blocked by git hooks)
- AI must create feature branches from `dev` (not `main`)
- AI must sync with `dev` before creating feature branch

## Authorization Context

```yaml
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr|for_pr_only|for_review_only>
halt_at: <analysis_complete|spec_created|plan_created|verification_complete|review_prep|pr_created>
pr_strategy: <none|stacked>
pipeline_phase: <current_phase_name>
authorization_source: "User approved #N on YYYY-MM-DD"
```

Task context rules: Missing `authorization_scope` → return `status: BLOCKED`. Instructed to exceed `halt_at` → return `status: BLOCKED`.

## Context Received from Orchestration Layer

```yaml
authorization: confirmed (from approval-gate)
issue: <issue-number>
```

This task does NOT re-check authorization. Authorization was verified by `approval-gate` before this task was invoked.

## Yield-Back to Orchestration Layer

After all five sub-tasks complete, the final yield provides:

```yaml
status: success | failure
branch: "spec/<feature-name>" | "feature/<feature-name>"
worktree_path: ".worktrees/<sanitized-branch-name>" | null
direct_branch: true | false
dev_base_hash: "<7-char-sha>"
working_tree_clean: true
authorization_scope: <scope>
halt_at: <stage>
pr_strategy: <strategy>
pipeline_phase: <phase>
ready_for: "implementation"
```

## Enforcement Mechanisms

| Layer | Mechanism | Scope | Bypassable? |
|------|-----------|-------|-------------|
| **Local** | `.opencode/hooks/pre-commit` | Blocks commit to main | No |
| **Local** | `.opencode/hooks/post-commit` | Warns after commit to main | N/A (post) |
| **GitHub** | Branch protection rules | Requires PR | No |

There is NO emergency bypass. If you need to make an urgent fix, create a `hotfix/` branch, make changes, push, and create PR with `hotfix` label.

## Context Required

- Related skills: `approval-gate` (authorization check), `using-git-worktrees` (worktree creation, opt-in only)
- Related tasks: `cleanup` (branch cleanup after PR merge)

Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)