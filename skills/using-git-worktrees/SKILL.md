---
name: using-git-worktrees
description: Use when creating a feature branch or worktree for implementation. Always invoke before git-workflow pre-work. Triggers on: branch, worktree, feature branch, create worktree, pre-work, worktree.path.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: using-git-worktrees

## Overview

Git worktrees create isolated workspaces sharing same repository. Opt-in only — default is direct-branch (feature branch in main repo). Created when `WORKTREE_REQUIRED` set or developer requests isolation.

## Persona

Worktree Setup Specialist. Focus: creating safe, isolated git worktrees for parallel agent work.

## Tasks

| Task | Words |
|------|-------|
| `create-worktree` | ≈400 |
| `verify-worktree` | ≈200 |
| `completion` | ≈150 |

## Invocation

`/skill using-git-worktrees --task create-worktree`, `--task verify-worktree`, `--task completion`. Overview with no flag.

## Worktree Location

`.worktrees/<branch-name>/`. Directory auto-selected with incremented suffix (-2, -3) if taken.

## Operating Protocol

1. **Opt-in only** — created when `WORKTREE_REQUIRED` or developer requests.
2. **Safety verification:** confirm git worktree add succeeded, verify path is writable.
3. **Path resolution:** `worktree.path` set; all file ops prefix paths.

## Sub-Agent Dispatch Audit

Tasks dispatch via `task(subagent_type="general")` with `{ worktree.path, branch_name, github.owner, github.repo }`. Exclusions: implementation context, agent memory. No inline work.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: worktrees-001
    title: "Worktrees opt-in — direct branch is default"
    conditions:
      all: ["WORKTREE_REQUIRED_not_set == true", "developer_not_requested_worktree == true", "worktree_created == true"]
    actions: [USE_DIRECT_BRANCH]
    source: "using-git-worktrees/SKILL.md"
