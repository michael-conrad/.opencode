---
name: sre-runbook
description: "Use when generating operational runbooks for infrastructure incidents or procedures. Triggers on: runbook, SRE, on-call, incident, outage, escalation, playbook, procedure, operation, diagnose, troubleshoot, debug. Runbooks written during incidents are incomplete. SRE discipline produces procedures that survive the next on-call."
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: sre-runbook

## Overview

Generates operational runbooks — step-by-step procedures a sysop can execute without thinking. Commands verified against live documentation. Values from actual environment. Single-path per operation.

## Persona

SRE-oriented operator writing runbooks for sysops under pressure. Runbooks are operational procedures, not analysis documents.

## Tasks

| Task | Words |
|------|-------|
| `generate` | ≈1000 |
| `track` | ≈450 |
| `completion` | ≈200 |

## Invocation

`skill({name: "sre-runbook"})` — call the skill, then call via task():

| Task | Call via task() |
|------|----------|
| `generate` | `task(..., prompt: "execute generate task from sre-runbook")` |
| `track` | `task(..., prompt: "execute track task from sre-runbook")` |
| `completion` | `task(..., prompt: "execute completion task from sre-runbook")` |

**CLI equivalent (for human TUI use):** `/skill sre-runbook --task <task>`

## Operating Protocol

1. **Environment context mandatory:** interface preference, tools, OS version before any instruction.
2. **Domain context mandatory:** infrastructure type, service name. Prompt if missing.
3. **Runbook type taxonomy:** `one-off-config` (steps-only, no YAML), `periodic-procedure` (steps-only, cadence stamp), `troubleshooting` (dual-output with YAML blocks), `incident-response` (dual-output with YAML blocks).
4. **Single-path rule:** one method per operation. No alternatives.
5. **Real-values rule:** actual hostnames/IPs/domains. No placeholders.
6. **Live-verification:** every CLI/GUI/API claim verified against live docs before inclusion. All sources fail → HALT with VERIFICATION-GAP.
7. **Exact-match verification:** row-by-row comparison template. No "functionally equivalent" soft-passes.
8. **DNS-specific validation:** RFC 1034 compliance (CNAME at apex invalid), provider-specific reference data.

## Sub-Agent Routing

All tasks run via `task(subagent_type="general")` with `{ runbook_type, domain_context, environment_context, worktree.path, github.owner, github.repo }`, excluding implementation context and agent memory. Auditor tasks use subagent_type from resolve-models result contract (auditor_1/auditor_2) — NOT `general`. Include audit_phase in task context when routing auditors. See adversarial-audit SKILL.md §DISPATCH_GATE. `pre-analysis` receives only `{ issue_number, task_description, github.owner, github.repo }`. No inline work.

### DISPATCH_GATE — Orchestrator task() Prompt Protocol

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
