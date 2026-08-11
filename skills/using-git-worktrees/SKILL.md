---
name: using-git-worktrees
description: "Git worktree manager that creates isolated feature branch worktrees for parallel agent work. Load via skill() when creating a feature branch or worktree for implementation. Also load when setting up isolated git worktrees for parallel agent work or managing worktree lifecycle. Always invoke before git-workflow pre-work. Worktrees are REQUIRED — always use them. User phrases: create worktree, set up worktree, manage worktree, isolated branch"
license: MIT
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
- [ ] 4. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

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

**CLI equivalent (for human TUI use):** `` `skill({name: "using-git-worktrees"})` ``

## Worktree Location

`.worktrees/<branch-name>/`. Directory auto-selected with incremented suffix (-2, -3) if taken.

## Operating Protocol

Read [the full operating protocol](using-git-worktrees/tasks/operating-protocol.md)

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
| Preloaded step sequences | "Step 1: sync $DEFAULT_BRANCH. Step 2: delete branch." | "execute cleanup task from git-workflow" |
| Preloaded expected outcomes | "Return { cleanup_status, branch_deleted }" | Let sub-agent define its own result contract |
| Preloaded orchestrator reasoning | "The merge was just completed so we need to..." | Pure objective, no narrative |

#### Dispatch Context Contract

Every `task()` call MUST include only:

- `worktree.path`
- `github.owner`
- `github.repo`
- `authorization_scope`
- `halt_at`
- `pipeline_phase`

Plus skill-specific fields per the `## Sub-Agent Routing` section above.

Exclusions (MUST NOT be in prompt):
- `orchestrator_reasoning`
- `expected_outcomes`
- `inline_file_paths`
- `agent_memory`
- `cached_verification_results`

#### Orchestrator Entry Criteria

Reading the Trigger Dispatch Table and Invocation section in the orchestrator's own context is small, necessary, routing-relevant work assigned to the orchestrator by allocation-by-context-cost: the skill card is routing metadata the orchestrator must hold, and sub-agents cannot call `skill()` or load skills. The no-preloaded-context substance below is unchanged.

After loading this skill and reading the Trigger Dispatch Table, the orchestrator MUST:
- Use the exact `task(..., prompt: "...")` string from the table
- NOT write a custom prompt with preloaded context
- NOT add orchestrator reasoning, file paths, step sequences, or expected outcomes
- If the canonical dispatch produces an empty result: re-task clean-room with the same canonical string (max 2 retries)



### [critical-rules-007] Worktree Bypass — using stash+checkout instead of worktrees when WORKTREE_REQUIRED
Using stash+checkout means contaminating your workspace state. Professional engineers isolate work in worktrees — amateurs juggle stashes and risk losing uncommitted context.

#### 🚫 FORBIDDEN

- Using stash+checkout instead of worktrees when `WORKTREE_REQUIRED` is set

#### ✅ REQUIRED

- Always use `git worktree add` when `WORKTREE_REQUIRED` is set
- Isolate each feature branch in its own worktree to prevent workspace contamination

#### Why This Matters

| Violation Pattern | Consequence |
|-------------------|-------------|
| Using stash+checkout when WORKTREE_REQUIRED set | Contaminates workspace state; risk of losing uncommitted context via stash juggling |


### [critical-rules-007] Relative File Paths in Worktree Context — using relative paths when worktree.path is set
Relative paths in worktree mode silently target the wrong repo. Every edit you make goes to the main repo instead of the worktree — your changes land in the wrong place. Professional agents prefix ALL paths with `worktree.path`.

#### 🚫 FORBIDDEN

- Using relative paths when `worktree.path` is set

#### ✅ REQUIRED

- Always prefix file operation paths with `worktree.path` when operating in a worktree
- Use `workdir` parameter in bash tool calls to target the worktree

#### Why This Matters

| Violation Pattern | Consequence |
|-------------------|-------------|
| Using relative paths when worktree.path set | Edits silently target the main repo instead of the worktree |


### [critical-rules-030] Sub-Agents Ignoring Worktree Context — sub-agents modifying main repo instead of worktree
Sub-agents that modify the main repo instead of the worktree are contaminating the wrong workspace. Every file they write goes to the wrong directory. Professional orchestrators always pass `worktree.path` in task context.

#### 🚫 FORBIDDEN

- Sub-agents modifying the main repo when operating in a worktree

#### ✅ REQUIRED

- Always pass `worktree.path` in task context to sub-agents
- Sub-agents must prefix all file paths with the received `worktree.path`

#### Why This Matters

| Violation Pattern | Consequence |
|-------------------|-------------|
| Sub-agents modifying main repo instead of worktree | Every file they write goes to the wrong directory |


