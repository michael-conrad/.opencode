---
name: programming-principles
description: "Use when designing functions, classes, or modules; writing or reviewing implementation code; making architecture decisions; evaluating tradeoffs, or enforcing code size limits. Also use when auditing code against design principles or detecting principle violations. Invoke for: code design, architecture review, principle enforcement, code audit, tradeoff evaluation, size limit enforcement. Programming principles MUST be followed. Trigger phrases: design function, review code, enforce principle, audit code, evaluate tradeoff, code size limit."
license: MIT
compatibility: opencode
---

# Skill: programming-principles

## Overview

20 engineering principles as single authoritative source for design judgment and enforcement. Code decomposition decisions are based on single-responsibility principle and cohesion, not word/line counts. Grandfather policy exempts existing files; only new/modified files must comply.

> **Implementation work is measured ONLY by whether tested verified correct code operations pass with 100% clean PASS. Document size metrics (word count, line count, token count) are NOT valid proxies for implementation complexity.**

## Persona

Principle enforcer. Routes code review and principle-violation detection to sub-agents that independently assess code against design standards. An orchestrator that evaluates code inline instead of dispatching to an audit sub-agent has produced a self-review, not an independent principle check — every violation finding carries the orchestrator's own coding style rather than an independent standard assessment. Professional enforcers dispatch to audit sub-agents. Inlining means no principle check was ever independently performed.

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
| "principles" / "check principles" / "design review" | `principles` | `sub-task` | {context} |
| "check-limits" / "size check" / "word count" | `check-limits` | `sub-task` | {file_paths} |
| "decompose" / "split function" / "refactor" | `decompose` | `sub-task` | {file_paths} |

## Tasks


| `principles` |
| `check-limits` |
| `decompose` |

## Invocation

`skill({name: "programming-principles"})` — call the skill, then call via task():

| Task | Call via task() |

| `principles` | `task(..., prompt: "execute principles task from programming-principles")` |
| `check-limits` | `task(..., prompt: "execute check-limits task from programming-principles")` |
| `decompose` | `task(..., prompt: "execute decompose task from programming-principles")` |

**CLI equivalent (for human TUI use):** `` `skill({name: "programming-principles"})` ``

## Relationship

This skill is the master source. `080-code-standards.md` holds project-specific conventions only. Other skills reference HERE, never the reverse.

## Sub-Agent Routing

`principles` runs via `task(subagent_type="general")` with `{ context, worktree.path, github.owner, github.repo }`. `check-limits` and `decompose` with `{ file_paths, worktree.path, github.owner, github.repo }`. Exclusions: implementation context, agent memory. `pre-analysis` receives only `{ issue_number, task_description, audit_phase, github.owner, github.repo }`. No inline work.

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


```
