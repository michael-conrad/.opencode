---
name: using-git-worktrees
description: Use when creating a feature branch or worktree for implementation. Always invoke before git-workflow pre-work when worktrees are needed. Triggers on: branch, worktree, feature branch, create worktree, pre-work, worktree.path.
type: discipline-enforcing
license: MIT
---

# Skill: using-git-worktrees

## Overview

Git worktrees create isolated workspaces sharing the same repository, allowing work on multiple branches simultaneously without switching. This skill adapts the [obra/superpowers using-git-worktrees](https://github.com/obra/superpowers/blob/main/skills/using-git-worktrees/SKILL.md) pattern for the `feature→dev→main` three-branch workflow used in this project.

**Core principle:** Worktrees are the OPT-IN exception for concurrent checkout scenarios, not the default workflow. Direct-branch is the primary workflow — use this skill only when worktree isolation is explicitly needed.

**Announce at start:** "Using the using-git-worktrees skill to set up an isolated worktree workspace."

**Source attribution:** Adapted from [obra/superpowers `using-git-worktrees`](https://github.com/obra/superpowers/tree/main/skills/using-git-worktrees). Original concepts and structure used with attribution.

## When Worktrees Are Appropriate

Worktrees are NOT the default — they are opt-in. Use a worktree ONLY when ANY of these conditions are met:

| Condition | Trigger |
| -- | -- |
| `WORKTREE_REQUIRED` flag is set | Session init or configuration explicitly activates worktree mode |
| Developer explicitly requests worktree isolation | Direct request for isolated checkout |
| Concurrent agent work requires separate checkouts | Multiple agents working on different branches simultaneously |

When NONE of these conditions are met, use **direct-branch** — create a feature branch in the main repo with `git checkout -b` or `git switch -c`. No worktree, no `worktree.path` needed.

### WORKTREE_REQUIRED Flag Mechanism

The `WORKTREE_REQUIRED` flag activates worktree mode for a session. When set:

- The agent MUST create a worktree before any file operations
- `worktree.path` MUST be set in session context
- Path rules switch to worktree mode (see `060-tool-usage.md` §2)
- `worktree.fatal=1` errors MUST halt the workflow

When NOT set, the agent uses direct-branch mode by default.

## Persona

You are a Worktree Setup Specialist. Your focus is creating safe, isolated git worktrees so agents can work in parallel without conflict — when worktree mode is explicitly activated.

## Tasks

| Task | Purpose | Words |
|------|---------|-------|
| `create-worktree` | Full worktree creation workflow: sync, verify, setup, export env | ≈600 |
| `tool-usage` | File operation and bash tool compliance rules for worktrees | ≈250 |
| `reference` | Quick reference, common mistakes, fatal errors, integration | ≈450 |
| `completion` | Ensure mandatory terminal-state dispatch occurred; remediate if not; report status | ≈200 |

## Invocation

- `/skill using-git-worktrees` — Overview only (this document)
- `/skill using-git-worktrees --task create-worktree` — Create a new worktree
- `/skill using-git-worktrees --task tool-usage` — Tool usage compliance rules
- `/skill using-git-worktrees --task reference` — Quick reference and troubleshooting
- `/skill using-git-worktrees --task completion` — Invoke when workflow halts at any point

## Operating Protocol

1. **Announce intent** at start: "Using the using-git-worktrees skill to set up an isolated worktree workspace."
1. **Default base branch is `dev`** — never from `main`. For work execution workflows, `BASE_BRANCH` may be a prior feature branch or work branch. Feature branches target `dev`.
1. **Only invoked when worktree mode is active** — direct-branch is the primary workflow; this skill is the opt-in exception.
1. **Always use `.worktrees/` directory** — when creating a worktree, stash+checkout is FORBIDDEN.
1. **Verify `.worktrees/` is gitignored** before creating worktree. If not, add it and commit.
1. **Check for name collisions** before creating — reuse existing worktree for same branch, HALT on mismatch.
1. **Export `worktree.path`, `branch`, `DEV_BASE_HASH`** after creation — downstream skills require these.
1. **If `worktree.fatal=1`** appears in session init when `WORKTREE_REQUIRED` is set: HALT immediately, report to developer, do NOT proceed.
1. **If `worktree.path` is empty after creation**: FATAL ERROR → FLAG DEV → HALT.
1. **Verify clean test baseline** after setup — report failures, get explicit permission to proceed.
1. **Cleanup** is handled by `finishing-a-development-branch`, not by this skill.

## Three-Branch Model Adaptation

| Original (superpowers) | This Project |
|------------------------|-------------|
| Worktrees from `main` | Worktrees from `dev` |
| Feature branches target `main` | Feature branches target `dev` |
| No project setup step | Auto-detect and run `uv sync` |
| No cleanup integration | Integrates with `finishing-a-development-branch` |
| Worktrees mandatory | Worktrees opt-in (direct-branch primary) |

Branch naming: `spec/<short-name>` for spec-driven work, `feature/<description>` for general feature work, `work/<short-name>` for work execution branches.

**BASE_BRANCH parameter:** The `create-worktree` task supports creating worktrees from branches other than `dev`. Defaults to `dev` for standalone branches. In work execution workflows, set to a prior feature branch (for dependency merge) or the work branch. Agent decides at creation time based on context.

## Tool Usage Compliance

When operating in a worktree, tool usage compliance rules apply (see `060-tool-usage.md` §2 for the complete two-mode path rules):

- **Direct-branch mode** (`worktree.path` NOT set): Relative paths work directly, no prefixing needed
- **Worktree mode** (`worktree.path` set): ALL file operation paths MUST be prefixed with `worktree.path`

Tool compliance enforcement is conditional — it only applies when `worktree.path` is set. See `--task tool-usage` for the detailed rules.

## Simple Work and Worktrees

When the authorization qualifies as "clearly simple work" (per `000-critical-rules.md` → "Simple Work Dispatch Path (Tier 2 Waiver)"), a worktree is NOT needed unless `WORKTREE_REQUIRED` is set. Direct-branch is the default for simple work too.

### What Does NOT Change for Simple Work

| Step | Simple Work | Complex Work |
|------|-------------|--------------|
| Worktree required? | Only when `WORKTREE_REQUIRED` set | Only when `WORKTREE_REQUIRED` set |
| No commits to main/dev? | YES (Tier 1) | YES (Tier 1) |
| Path rules apply? | In worktree mode only | In worktree mode only |
| Spec/plan needed? | NO (Tier 2 waiver) | YES (Tier 2) |
| Sub-agent dispatch? | NO (single concern) | YES (divide-and-conquer) |
| Pre-implementation analysis? | NO (no plan) | YES (expand sub-issues) |

## Cross-References

- **Called by:** `brainstorming` (Phase 4), `divide-and-conquer`, `executing-plans` — only when worktree mode is active
- **Pairs with:** `finishing-a-development-branch` (cleanup), `git-workflow` (branch/PR management)
- **Related guidelines:** `000-critical-rules.md` (direct-branch default, worktree conditional rules), `060-tool-usage.md` (path rules)

**⚠️ COMPLETION GUARANTEE:** If this workflow halts at ANY point — including error, failure, or early termination — you MUST invoke `--task completion` before halting. The completion subtask ensures mandatory steps are never skipped. It is idempotent and safe to invoke multiple times.