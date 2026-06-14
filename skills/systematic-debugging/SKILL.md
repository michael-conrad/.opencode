---
name: systematic-debugging
description: "Use when encountering a bug, error, or unexpected behavior, or before making code changes to fix an issue. Triggers on: bug, error, fix, debug, diagnose, crash, failure, unexpected behavior, vibe debugging. Patching without diagnosis is guessing. Systematic debugging finds root causes."
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: systematic-debugging

## Overview

Enforces root cause analysis, hypothesis testing, and minimal fixes. Prevents "vibe debugging" — random changes without understanding. Diagnose before fixing, fixes must be minimal and targeted.

## Tasks


| `diagnose` |
| `fix` |
| `completion` |

## Invocation

`skill({name: "systematic-debugging"})` — call the skill, then call via task():

| Task | Call via task() |

| `diagnose` | `task(..., prompt: "execute diagnose task from systematic-debugging")` |
| `fix` | `task(..., prompt: "execute fix task from systematic-debugging")` |
| `completion` | `task(..., prompt: "execute completion task from systematic-debugging")` |

**CLI equivalent (for human TUI use):** `/skill systematic-debugging --task <task>`

## Operating Protocol

1. **Read-only during diagnosis:** no code changes until root cause identified.
2. **Bug discovery ≠ authorization:** new bugs reported as issues, not fixed inline.
3. **Hypothesis must be verified** against live evidence before proceeding.
4. **Fix targets root cause, not symptoms.**
5. **Fix requires authorization** per `approval-gate`.
6. **No scope creep:** fix only what diagnosis identified.

## Sub-Agent Routing

Sub-agents run via `task(subagent_type="general")` with `{ bug_description, file_paths, worktree.path, github.owner, github.repo }`. Exclusions: implementation context, agent memory. Auditor tasks use subagent_type from resolve-models result contract (auditor_1/auditor_2) — NOT `general`. Include audit_phase in task context when routing auditors. See adversarial-audit SKILL.md §DISPATCH_GATE. `pre-analysis` receives only `{ issue_number, task_description, github.owner, github.repo }`. No inline work.

### DISPATCH_GATE — Orchestrator task() Prompt Protocol

> **Context cost frame:** The orchestrator's context is the most expensive resource in the pipeline — sub-agents do the work, not the orchestrator. Every byte held by the orchestrator costs `byte × remaining_dispatches²`. See `020-go-prohibitions.md` §1.1.

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

## Cross-References

Skills: `issue-review`, `approval-gate`, `verification-before-completion`. Guidelines: `000-critical-rules.md`.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: sys-debug-001
    title: "Read-only analysis mandate during diagnosis"
    conditions:
      all: ["current_task == 'diagnose'", "code_modification_attempted == true"]
    actions: [HALT, REVERT]
    source: "systematic-debugging/SKILL.md"

  - id: sys-debug-002
    title: "Bug discovery does NOT authorize fixing"
    conditions:
      all: ["bug_found_during_diagnosis == true", "fix_authorization_received == false"]
    actions: [HALT, CREATE(bug_report), CALL(issue-review)]
    source: "systematic-debugging/SKILL.md"
