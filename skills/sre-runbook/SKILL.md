---
name: sre-runbook
description: "Operational runbook generator for infrastructure incidents and procedures. Dispatch when generating operational runbooks for infrastructure incidents or procedures. Also dispatch when documenting incident response steps, recovery procedures, or operational playbooks. SRE discipline is REQUIRED"
license: MIT
compatibility: opencode
---

# Skill: sre-runbook

## Overview

Generates operational runbooks — step-by-step procedures a sysop can execute without thinking. Commands verified against live documentation. Values from actual environment. Single-path per operation.

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
| "generate" / "generate runbook" / "create runbook" | `generate` | `sub-task` | {runbook_type, domain_context} |
| "track" / "track runbook" / "runbook status" | `track` | `sub-task` | {runbook_id} |
| completion / workflow end | `completion` | `sub-task` | {workflow_state} |

## Persona

SRE-oriented operator writing runbooks for sysops under pressure. Runbooks are operational procedures, not analysis documents.

## Tasks


| `generate` |
| `track` |
| `completion` |

## Invocation

`skill({name: "sre-runbook"})` — call the skill, then call via task():

| Task | Call via task() |

| `generate` | `task(..., prompt: "execute generate task from sre-runbook")` |
| `track` | `task(..., prompt: "execute track task from sre-runbook")` |
| `completion` | `task(..., prompt: "execute completion task from sre-runbook")` |

**CLI equivalent (for human TUI use):** `` `skill({name: "sre-runbook"})` ``

## Operating Protocol

See `sre-runbook/tasks/operating-protocol.md` for the full operating protocol.

## Sub-Agent Routing

All tasks run via `task(subagent_type="general")` with `{ runbook_type, domain_context, environment_context, worktree.path, github.owner, github.repo }`, excluding implementation context and agent memory. Auditor tasks use subagent_type from resolve-models result contract (auditor_1/auditor_2) — NOT `general`. Include audit_phase in task context when routing auditors. See audit SKILL.md §DISPATCH_GATE. `pre-analysis` receives only `{ issue_number, task_description, github.owner, github.repo }`. No inline work.

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

## Operating Protocol

- [ ] 1. **Environment context:** Environment context MUST be collected before runbook generation
- [ ] 2. **Live verification:** Commands MUST be verified against live documentation — no training knowledge fallback
- [ ] 3. **Single-path rule:** One method per operation — no multiple alternative paths
- [ ] 4. **Exact-match verification:** Verification mismatches MUST be reported as FAIL — no soft-passing
- [ ] 5. **DNS validation:** DNS runbooks MUST validate record constraints against reference data and RFC compliance

## Cross-References

Skills: `systematic-debugging`, `verification-before-completion`, `issue-operations`, `spec-auditor`. Guidelines: `010-approval-gate.md`, `000-critical-rules.md`, `065-verification-honesty.md`. Reference data: `reference/directnic-record-types.md`.


