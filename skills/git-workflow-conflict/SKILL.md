---
name: git-workflow-conflict
description: "Resolve git conflicts during rebase, merge, or cherry-pick operations, analyzing intent before applying changes. Conflict resolution MUST analyze intent before applying changes."
license: MIT
provenance: AI-generated
---

# Skill: git-workflow-conflict

## Overview

Conflict resolution sub-skill of git-workflow. Handles rebase-pending conflict resolution during rebase, merge, or cherry-pick operations. Delegates intent analysis and tier classification to the `conflict-resolution` skill. Enforces the three-tier conflict model: Trivial (auto-resolve), Textual (note), Intent (HALT).

## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work that should be delegated to a sub-agent produces defective deliverables that must be discarded
- [ ] 3. Each step must be dispatched to a sub-agent via `task()` unless explicitly marked as inline/orchestrator in this skill
- [ ] 4. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Pre-Flight Guard (Mandatory)

**This skill card is orchestrator-only routing metadata.**

If you are a sub-agent (dispatched via `task()`), you MUST NOT consume the routing metadata below. Sub-agents cannot call `task()` and cannot execute orchestrator-level dispatch instructions. Return `BLOCKED` with reason `ORCHESTRATOR_ONLY_SKILL_CARD` and halt.

If you are the orchestrator (loaded this card via `skill({name: "..."})`), proceed to the Workflows section.

## Workflows

### Resolve a rebase, merge, or cherry-pick conflict

When the agent needs to resolve git conflicts during a rebase, merge, or cherry-pick operation, rebase pending PRs onto the updated default branch, or classify conflicts by tier.

- [ ] 1. **Rebase pending** — Resolves rebase/merge/cherry-pick conflicts by classifying tier and applying resolution
  - **Prompt:** `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [rebase pending PRs after merge](.opencode/skills/git-workflow-conflict/tasks/rebase-pending.md). branch_name: ", branch_name, ", worktree.path: ", worktree_path))`
  - **Context passed:** `{branch_name, worktree.path, merged_at}`
  - **Returns:** `{status, finding_summary, artifact_path, blocker_reason}`
  - **Execution mode:** sub-agent dispatch

## Cross-References

- Read [git-workflow skill](skills/git-workflow/SKILL.md) for the parent workflow and full task documentation
- Read [conflict-resolution skill](skills/conflict-resolution/SKILL.md) for intent analysis and tier classification
- Read [critical-rules-042](guidelines/000-critical-rules.md) for blind conflict resolution prohibition
