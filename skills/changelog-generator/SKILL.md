---
name: changelog-generator
description: "Use when creating release notes, documenting changes between versions, or preparing a changelog. Also use when comparing diffs between releases or generating structured version history. Invoke for: release note creation, changelog generation, version diff analysis, release documentation. Changelog generation is REQUIRED before every release — not optional. Trigger phrases: create changelog, generate release notes, document changes, version history, release diff."
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: changelog-generator

## Overview

Transforms git commits into polished, user-friendly changelogs. Category-based organization into Added, Changed, Deprecated, Removed, Fixed, Security.

## Persona

Changelog assembler. Routes diff analysis and release note generation to sub-agents that independently compare versions. An orchestrator that generates changelog entries inline instead of dispatching to a diff-analysis sub-agent has produced a memory-recall document, not a verified changelog — every entry carries the orchestrator's recollection of what changed rather than an independent diff inspection. Professional changelog generators dispatch to sub-agents that read actual diffs. Inlining means the changelog was never verified against source.

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
| "changelog" / "since last release" | `since-last-release` | `sub-task` | {date_range} |
| "changelog date range" / "changes between dates" | `date-range` | `sub-task` | {from_date, to_date} |
| "backfill changelog" | `backfill` | `sub-task` | {date_range} |
| completion / workflow end | `completion` | `sub-task` | {workflow_state} |

## Tasks


| `since-last-release` |
| `date-range` |
| `backfill` |
| `completion` |

## Invocation

`skill({name: "changelog-generator"})` — call the skill, then call via task():

| Task | Call via task() |

| `since-last-release` | `task(..., prompt: "execute since-last-release task from changelog-generator")` |
| `date-range` | `task(..., prompt: "execute date-range task from changelog-generator with --from DATE --to DATE")` |
| `backfill` | `task(..., prompt: "execute backfill task from changelog-generator")` |
| `completion` | `task(..., prompt: "execute completion task from changelog-generator")` |

**CLI equivalent (for human TUI use):** `/skill changelog-generator --task <task>`

## Sub-Agent Routing

Sub-agents run via `task(subagent_type="general")` with `{ date_range, worktree.path, github.owner, github.repo }`. Exclusions: implementation context, agent memory. Auditor tasks use subagent_type from resolve-models result contract (auditor_1/auditor_2) — NOT `general`. Include audit_phase in task context when routing auditors. See adversarial-audit SKILL.md §DISPATCH_GATE. `pre-analysis` receives only `{ issue_number, task_description, github.owner, github.repo }`. No inline work.

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
