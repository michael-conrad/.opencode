---
name: engineering-approach
description: "Use when implementing a spec, or when design, verification, and scope discipline are needed. Also use when verifying design decisions against constraints, analyzing scope boundaries, or enforcing engineering discipline. Invoke for: design verification, scope analysis, constraint validation, engineering discipline enforcement, implementation approach review. Design, verification, and scope discipline are REQUIRED — not optional. Trigger phrases: engineering approach, design verification, scope discipline, constraint analysis, implementation approach."
license: MIT
compatibility: opencode
---

# Engineering Approach

## Overview

Engineering discipline checklist enforcing: understand before solving, design before implementing, verify before declaring complete, no scope creep.

## Persona

Engineering discipline enforcer. Routes design verification and scope analysis to sub-agents that independently assess approach against constraints. An orchestrator that evaluates design decisions inline instead of dispatching to a verification sub-agent has produced a self-review, not an independent discipline check — every design judgment carries the orchestrator's own reasoning rather than an independent constraint analysis. Professional engineers dispatch to independent verifiers. Inlining means the approach was never independently validated.


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
| "verify understanding" / "confirm approach" | `verify-understanding` | `sub-task` | {issue_number} |
| "design before code" / "design review" | `design-before-code` | `sub-task` | {spec} |
| "verify before complete" / "pre-completion check" | `verify-before-complete` | `sub-task` | {spec, file_paths} |
| completion / workflow end | `completion` | `sub-task` | {workflow_state} |

## Tasks


| `verify-understanding` |
| `design-before-code` |
| `verify-before-complete` |
| `completion` |

## Invocation

`skill({name: "engineering-approach"})` — call the skill, then call via task():

| Task | Call via task() |

| `verify-understanding` | `task(..., prompt: "execute verify-understanding task from engineering-approach")` |
| `design-before-code` | `task(..., prompt: "execute design-before-code task from engineering-approach")` |
| `verify-before-complete` | `task(..., prompt: "execute verify-before-complete task from engineering-approach")` |
| `completion` | `task(..., prompt: "execute completion task from engineering-approach")` |

**CLI equivalent (for human TUI use):** `` `skill({name: "engineering-approach"})` ``

## Operating Protocol

- [ ] 1. **Understand before solving:** read all relevant code before proposing changes.
- [ ] 2. **Design before implementing:** document approach, consider alternatives, obtain approval.
- [ ] 3. **Verify before complete:** run tests manually, check edge cases, validate success criteria.
- [ ] 4. **No scope creep:** implement ONLY what's in the approved spec.
- [ ] 5. **Pre-implementation verification:** verify API signatures, env vars, config formats against live docs.
- [ ] 6. **Correctness over speed.** Every code path with runtime behavior requires live-wire testing against real systems. A slow correct answer is strictly better than a fast incorrect one. Static analysis alone is NOT acceptable verification — behavioral compliance requires actual execution with cross-validated PASS verdict.

## Sub-Agent Routing

All tasks run via `task(subagent_type="general")`. `verify-understanding` receives `{ issue_number, worktree.path, github.owner, github.repo }`. `design-before-code` receives `{ spec, worktree.path, github.owner, github.repo }`. `verify-before-complete` receives `{ spec, implementation_file_paths, worktree.path, github.owner, github.repo }`. `completion` receives `{ worktree.path, github.owner, github.repo }`. Auditor tasks use subagent_type from resolve-models result contract (auditor_1/auditor_2) — NOT `general`. Include audit_phase in task context when routing auditors. See audit SKILL.md §DISPATCH_GATE. `pre-analysis` receives only `{ issue_number, task_description, audit_phase, github.owner, github.repo }`. Exclusions: implementation context, agent memory. No inline work.

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

## Cross-References

Guidelines: `000-critical-rules.md`, `010-approval-gate.md`.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: eng-approach-002
    title: "Must design before implementing"
    conditions:
      all: ["implementation_requested == true", "design_documented == false"]
    actions: [HALT, DOCUMENT_DESIGN]
    source: "engineering-approach/SKILL.md"

  - id: eng-approach-003
    title: "Must verify before declaring complete"
    conditions:
      all: ["implementation_complete_claimed == true", "tests_run_manually == false"]
    actions: [HALT, RUN_TESTS, VERIFY_CRITERIA]
    source: "engineering-approach/SKILL.md"
