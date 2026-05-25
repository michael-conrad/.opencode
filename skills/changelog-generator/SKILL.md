---
name: changelog-generator
description: Use when creating release notes, documenting changes between versions, or preparing a changelog. Triggers on: changelog, release notes, what changed, version history, commit summary, release. Unrecorded changes become untracked regressions. Changelogs are the memory of the project — agents who skip them produce amnesiac workflows.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: changelog-generator

## Overview

Transforms git commits into polished, user-friendly changelogs. Category-based organization into Added, Changed, Deprecated, Removed, Fixed, Security.

## Tasks

| Task | Words |
|------|-------|
| `since-last-release` | ≈170 |
| `date-range` | ≈90 |
| `backfill` | ≈120 |
| `completion` | ≈200 |

## Invocation

`skill({name: "changelog-generator"})` — call the skill, then call via task():

| Task | Call via task() |
|------|----------|
| `since-last-release` | `task(..., prompt: "execute since-last-release task from changelog-generator")` |
| `date-range` | `task(..., prompt: "execute date-range task from changelog-generator with --from DATE --to DATE")` |
| `backfill` | `task(..., prompt: "execute backfill task from changelog-generator")` |
| `completion` | `task(..., prompt: "execute completion task from changelog-generator")` |

**CLI equivalent (for human TUI use):** `/skill changelog-generator --task <task>`

## Sub-Agent Routing

Sub-agents run via `task(subagent_type="general")` with `{ date_range, worktree.path, github.owner, github.repo }`. Exclusions: implementation context, agent memory. Auditor tasks use subagent_type from resolve-models result contract (auditor_1/auditor_2) — NOT `general`. Include audit_phase in task context when routing auditors. See adversarial-audit SKILL.md §DISPATCH_GATE. `pre-analysis` receives only `{ issue_number, task_description, github.owner, github.repo }`. No inline work.

### DISPATCH_GATE — Orchestrator task() Prompt Protocol

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

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: changelog-001
    title: "Must produce CHANGELOG.md before PR creation"
    conditions:
      all: ["pr_creation_pending == true", "changelog_exists == false"]
    actions: [HALT, GENERATE(changelog)]
    source: "changelog-generator/SKILL.md"
