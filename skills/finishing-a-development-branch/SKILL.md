---
name: finishing-a-development-branch
description: "Use when implementation is complete and branch needs final checks before PR. Also use when running the finishing checklist, verifying branch readiness, or preparing for PR submission. Invoke for: branch finishing, readiness checklist, pre-PR verification, branch state inspection, completion confirmation. Dispatch is MANDATORY — the prepare, checklist, and completion tasks are REQUIRED gates, not optional steps. Trigger phrases: finish branch, final checks, pre-PR checklist, branch readiness, ready for PR."
license: MIT
compatibility: opencode
---

# Skill: finishing-a-development-branch

## Overview

Branch readiness IS verification completion. A finished branch has passed verification. Branches left dirty after implementation are liabilities — their readiness is unconfirmed until every SC is verified PASS.

Remediation of failed verification IS agent-owned — the producing agent owns every defect in its output, and autonomous remediation is the default action before any escalation.

Branch completion workflow ensuring feature branch is fully ready for PR. Verifies all changes committed, tested, pushed, and reviewed. Tracks against plan sub-issues.

## Persona

Branch finisher. Routes checklist verification and cleanup operations to sub-agents that independently assess branch state. An orchestrator that runs the finishing checklist inline instead of dispatching to verification sub-agents has produced a self-check, not an independent readiness assessment — every checklist item carries the orchestrator's own assessment rather than an independent state inspection. Professional finishers dispatch to independent verifiers. Inlining means the branch was never independently confirmed ready.


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
| "finish branch" / "prepare branch" / "branch ready" | `prepare` | `sub-task` | {branch_name} |
| "checklist" / "branch checklist" / "readiness check" | `checklist` | `sub-task` | {branch_name} |
| completion / workflow end | `completion` | `sub-task` | {workflow_state} |

## Tasks


| `prepare` |
| `checklist` |
| `completion` |

## Invocation

`skill({name: "finishing-a-development-branch"})` — call the skill, then call via task():

| Task | Call via task() |

| `prepare` | `task(..., prompt: "execute prepare task from finishing-a-development-branch")` |
| `checklist` | `task(..., prompt: "execute checklist task from finishing-a-development-branch")` |
| `completion` | `task(..., prompt: "execute completion task from finishing-a-development-branch")` |

**CLI equivalent (for human TUI use):** `` `skill({name: "finishing-a-development-branch"})` ``

## Operating Protocol

- [ ] 1. **All changes committed:** `git status` shows clean.
- [ ] 2. **All tests pass:** `uv run pytest` green.
- [ ] 3. **Lint clean:** `uvx ruff check` zero errors.
- [ ] 4. **Type check:** `uvx pyright` clean.
- [ ] 5. **Branch pushed:** up to date with remote.
- [ ] 6. **Plan sub-issue closure verification:** matched against implementation.
- [ ] 7. **Correctness over speed.** Every code path with runtime behavior requires live-wire testing against real systems. A slow correct answer is strictly better than a fast incorrect one. Static analysis alone is NOT acceptable verification — behavioral compliance requires actual execution with cross-validated PASS verdict.

## Sub-Agent Routing

Sub-agents run via `task(subagent_type="general")` with `{ branch_name, worktree.path, github.owner, github.repo }`. Auditor tasks use subagent_type from resolve-models result contract (auditor_1/auditor_2) — NOT `general`. Include audit_phase in task context when routing auditors. See adversarial-audit SKILL.md §DISPATCH_GATE. Exclusions: implementation context, agent memory. `pre-analysis` receives only `{ issue_number, task_description }`. No inline work.

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
