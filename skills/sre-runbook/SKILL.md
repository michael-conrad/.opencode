---
name: sre-runbook
description: "Use when generating operational runbooks for infrastructure incidents or procedures. SRE discipline produces procedures that survive the next on-call."
type: discipline-enforcing
license: MIT
compatibility: opencode
---

# Skill: sre-runbook

## Overview

Generates operational runbooks — step-by-step procedures a sysop can execute without thinking. Commands verified against live documentation. Values from actual environment. Single-path per operation.

## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work that should be delegated to a sub-agent produces defective deliverables that must be discarded
- [ ] 3. Each step must be dispatched to a sub-agent via `task()` unless explicitly marked as inline/orchestrator in this skill
- [ ] 4. Sub-agents must not dispatch sub-agents
- [ ] 5. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

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

**CLI equivalent (for human TUI use):** `/skill sre-runbook --task <task>`

## Operating Protocol

- [ ] 1. **Environment context mandatory:** interface preference, tools, OS version before any instruction.
- [ ] 2. **Domain context mandatory:** infrastructure type, service name. Prompt if missing.
- [ ] 3. **Runbook type taxonomy:** `one-off-config` (steps-only, no YAML), `periodic-procedure` (steps-only, cadence stamp), `troubleshooting` (dual-output with YAML blocks), `incident-response` (dual-output with YAML blocks).
- [ ] 4. **Single-path rule:** one method per operation. No alternatives.
- [ ] 5. **Real-values rule:** actual hostnames/IPs/domains. No placeholders.
- [ ] 6. **Live-verification:** every CLI/GUI/API claim verified against live docs before inclusion. All sources fail → HALT with VERIFICATION-GAP.
- [ ] 7. **Exact-match verification:** row-by-row comparison template. No "functionally equivalent" soft-passes.
- [ ] 8. **DNS-specific validation:** RFC 1034 compliance (CNAME at apex invalid), provider-specific reference data.

## Sub-Agent Routing

All tasks run via `task(subagent_type="general")` with `{ runbook_type, domain_context, environment_context, worktree.path, github.owner, github.repo }`, excluding implementation context and agent memory. Auditor tasks use subagent_type from resolve-models result contract (auditor_1/auditor_2) — NOT `general`. Include audit_phase in task context when routing auditors. See adversarial-audit SKILL.md §DISPATCH_GATE. `pre-analysis` receives only `{ issue_number, task_description, github.owner, github.repo }`. No inline work.

### DISPATCH_GATE — Orchestrator task() Prompt Protocol

> **Context cost frame:** The orchestrator's context is the most expensive resource in the pipeline — sub-agents do the work, not the orchestrator. Every byte held by the orchestrator costs `byte × remaining_dispatches²`. See `020-go-prohibitions.md` §1.1.
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

## Cross-References

Skills: `systematic-debugging`, `verification-before-completion`, `issue-operations`, `spec-auditor`. Guidelines: `010-approval-gate.md`, `000-critical-rules.md`, `065-verification-honesty.md`. Reference data: `reference/directnic-record-types.md`.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: sre-runbook-001
    title: "Environment context mandatory before generation"
    conditions:
      all: ["environment_context_collected == false"]
    actions: [HALT, PROMPT_USER(environment details)]
    source: "sre-runbook/SKILL.md"

  - id: sre-runbook-004
    title: "Live verification mandatory — no training knowledge fallback"
    conditions:
      all: ["all_verification_sources_failed == true"]
    actions: [HALT, INSERT_VERIFICATION_GAP, PROMPT_USER]
    triggers: [verification-enforcement]
    source: "sre-runbook/SKILL.md"

  - id: sre-runbook-005
    title: "Single-path rule — one method per operation"
    conditions:
      all: ["multiple_alternative_paths_present == true"]
    actions: [REJECT(runbook section)]
    source: "sre-runbook/SKILL.md"

  - id: sre-runbook-007
    title: "Exact-match verification — no soft-passing mismatches"
    conditions:
      all: ["verification_mismatch_found == true"]
    actions: [REPORT_FAIL]
    source: "sre-runbook/SKILL.md"

  - id: sre-runbook-008
    title: "DNS-specific validation for DNS runbooks"
    conditions:
      all: ["runbook_type == dns", "dns_record_constraints_validated == false"]
    actions: [CHECK_REFERENCE_DATA, VALIDATE_RFC_COMPLIANCE]
    source: "sre-runbook/SKILL.md"
