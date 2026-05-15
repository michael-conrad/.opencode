---
name: finishing-a-development-branch
description: Use when implementation is complete and branch needs final checks before PR. Triggers on: done, finished, ready for PR, implementation complete, branch ready, push changes, final check.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: finishing-a-development-branch

## Overview

Branch completion workflow ensuring feature branch is fully ready for PR. Verifies all changes committed, tested, pushed, and reviewed. Tracks against plan sub-issues.

## Tasks

| Task | Words |
|------|-------|
| `prepare` | ≈450 |
| `checklist` | ≈350 |
| `completion` | ≈200 |

## Invocation

`skill({name: "finishing-a-development-branch"})` — call the skill, then dispatch a task:

| Task | Dispatch |
|------|----------|
| `prepare` | `task(..., prompt: "execute prepare task from finishing-a-development-branch")` |
| `checklist` | `task(..., prompt: "execute checklist task from finishing-a-development-branch")` |
| `completion` | `task(..., prompt: "execute completion task from finishing-a-development-branch")` |

**CLI equivalent (for human TUI use):** `/skill finishing-a-development-branch --task <task>`

## Operating Protocol

1. **All changes committed:** `git status` shows clean.
2. **All tests pass:** `uv run pytest` green.
3. **Lint clean:** `uvx ruff check` zero errors.
4. **Type check:** `uvx pyright` clean.
5. **Branch pushed:** up to date with remote.
6. **Plan sub-issue closure verification:** matched against implementation.

## Sub-Agent Dispatch Audit

Sub-agents dispatch via `task(subagent_type="general")` with `{ branch_name, worktree.path, github.owner, github.repo }`. When dispatching auditor sub-agents, include `audit_phase` in dispatch context per SC-6. Exclusions: implementation context, agent memory. `pre-analysis` receives only `{ issue_number, task_description }`. No inline work.

## Cross-References

Skills: `git-workflow`, `verification-before-completion`. Guidelines: `000-critical-rules.md`.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: finish-branch-001
    title: "All changes committed and pushed before PR readiness"
    conditions:
      all: ["uncommitted_changes_exist == true"]
    actions: [HALT, COMMIT]
    source: "finishing-a-development-branch/SKILL.md"
