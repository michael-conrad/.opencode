---
name: sync-guidelines
description: "Use when synchronizing guidelines, skills, or tools between repositories. Sync is REQUIRED maintenance."
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: sync-guidelines

## Overview

Intelligently synchronizes guidelines, skills, and tools between repos via GitHub issues. Files classified by content understanding — not pattern matching — as core (syncable) vs project-specific (protected).

## Persona

Sync operator. Routes diff detection and content synchronization to sub-agents that independently compare source and target. An orchestrator that syncs content inline instead of dispatching to diff-analysis sub-agents has produced a blind copy, not a verified synchronization — every synced change carries the orchestrator's own assessment of what changed rather than an independent diff inspection. Professional sync operators dispatch to diff-analysis sub-agents. Inlining means the sync was never independently verified.

## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work that should be delegated to a sub-agent produces defective deliverables that must be discarded
- [ ] 3. Each step must be dispatched to a sub-agent via `task()` unless explicitly marked as inline/orchestrator in this skill
- [ ] 4. Sub-agents must not dispatch sub-agents
- [ ] 5. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "classify" / "classify files" / "sync classification" | `classify` | `sub-task` | {source_repo, file_paths} |
| "sync-push" / "push guidelines" / "export" | `sync-push` | `sub-task` | {source_repo, target_repo, file_paths} |
| "sync-pull" / "pull guidelines" / "import" | `sync-pull` | `sub-task` | {source_repo, target_repo, file_paths} |
| "issue-format" / "format sync issue" | `issue-format` | `sub-task` | {sync_data} |
| completion / workflow end | `completion` | `sub-task` | {workflow_state} |

## Tasks


| `classify` |
| `sync-push` |
| `sync-pull` |
| `issue-format` |
| `completion` |

## Invocation

`skill({name: "sync-guidelines"})` — call the skill, then call via task():

| Task | Call via task() |

| `classify` | `task(..., prompt: "execute classify task from sync-guidelines")` |
| `sync-push` | `task(..., prompt: "execute sync-push task from sync-guidelines")` |
| `sync-pull` | `task(..., prompt: "execute sync-pull task from sync-guidelines")` |
| `issue-format` | `task(..., prompt: "execute issue-format task from sync-guidelines")` |
| `completion` | `task(..., prompt: "execute completion task from sync-guidelines")` |

**CLI equivalent (for human TUI use):** `/skill sync-guidelines --task <task>`

## Sub-Agent Routing

Sub-agents run via `task(subagent_type="general")` with `{ source_repo, target_repo, file_paths, worktree.path, github.owner, github.repo }`. Exclusions: implementation context, agent memory. Auditor tasks use subagent_type from resolve-models result contract (auditor_1/auditor_2) — NOT `general`. Include audit_phase in task context when routing auditors. See adversarial-audit SKILL.md §DISPATCH_GATE. `pre-analysis` receives only `{ issue_number, task_description, audit_phase, github.owner, github.repo }`. No inline work.

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
  - id: sync-001
    title: "Classify by content, not pattern matching"
    conditions:
      all: ["classification_by_pattern_only == true"]
    actions: [RE_CLASSIFY_BY_CONTENT]
    source: "sync-guidelines/SKILL.md"
