---
name: using-git-worktrees
description: "Use when creating a feature branch or worktree for implementation. Also use when setting up isolated git worktrees for parallel agent work or managing worktree lifecycle. Invoke for: worktree creation, feature branch setup, worktree lifecycle management, worktree cleanup, worktree path resolution. Always invoke before git-workflow pre-work. Worktrees are REQUIRED — always use them. Trigger phrases: create worktree, setup worktree, add worktree, remove worktree, worktree path, isolated branch."
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: using-git-worktrees

## Overview

Git worktrees create isolated workspaces sharing same repository. Opt-in only — default is direct-branch (feature branch in main repo). Created when `WORKTREE_REQUIRED` set or developer requests isolation.

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
| "create-worktree" / "create worktree" / "new worktree" | `create-worktree` | `sub-task` | {branch_name} |
| "verify-worktree" / "check worktree" | `verify-worktree` | `sub-task` | {worktree_path} |
| completion / workflow end | `completion` | `sub-task` | {workflow_state} |

## Persona

Worktree Setup Specialist. Focus: creating safe, isolated git worktrees for parallel agent work.

## Tasks


| `create-worktree` |
| `verify-worktree` |
| `completion` |

## Invocation

`skill({name: "using-git-worktrees"})` — call the skill, then call via task():

| Task | Call via task() |

| `create-worktree` | `task(..., prompt: "execute create-worktree task from using-git-worktrees")` |
| `verify-worktree` | `task(..., prompt: "execute verify-worktree task from using-git-worktrees")` |
| `completion` | `task(..., prompt: "execute completion task from using-git-worktrees")` |

**CLI equivalent (for human TUI use):** `/skill using-git-worktrees --task <task>`

## Worktree Location

`.worktrees/<branch-name>/`. Directory auto-selected with incremented suffix (-2, -3) if taken.

## Operating Protocol

- [ ] 1. **Opt-in only** — created when `WORKTREE_REQUIRED` or developer requests.
- [ ] 2. **Safety verification:** confirm git worktree add succeeded, verify path is writable.
- [ ] 3. **Path resolution:** `worktree.path` set; all file ops prefix paths.

## Sub-Agent Routing

Sub-agents run via `task(subagent_type="general")` with `{ worktree.path, branch_name, github.owner, github.repo }`. Exclusions: implementation context, agent memory. `pre-analysis` receives only `{ issue_number, task_description, audit_phase, github.owner, github.repo }`. No inline work.

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
  - id: worktrees-001
    title: "Worktrees opt-in — direct branch is default"
    conditions:
      all: ["WORKTREE_REQUIRED_not_set == true", "developer_not_requested_worktree == true", "worktree_created == true"]
    actions: [USE_DIRECT_BRANCH]
    source: "using-git-worktrees/SKILL.md"
