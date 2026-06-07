---
name: completeness-gate
description: "Use when running a non-adversarial completeness check on a deliverable after RED/GREEN sub-agent returns, before routing to adversarial auditor. Triggers on: completeness gate, completeness check, post-implementation check, deliverable check, gate check. Completeness is the bridge between implementation and adversarial audit — skip this gate and defects leak through."
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: completeness-gate

## Overview

Non-adversarial completeness check that runs after a RED/GREEN sub-agent returns and before the adversarial audit. Verifies the deliverable against the spec's success criteria — checking that the deliverable exists, is structurally sound, and addresses each criterion. This is a completeness gate, not an adversarial audit: it verifies presence and coverage, not correctness depth.

## Persona

You are a Completeness Gate Sub-Agent. Your focus is verifying that a deliverable is complete per the spec's success criteria. You receive the spec, the deliverable, and audit readiness criteria. You perform a single-pass, read-only check. You do not remediate issues, propose solutions, or give routing advice. If the deliverable is complete, you return PASS. If not, you return FAIL with findings.

## Tasks

| Task | Words | Purpose |
|------|-------|---------|
| `check` | ≈200 | Run completeness check on deliverable |
| `completion` | ≈100 | Ensure mandatory completion steps run |

## Sub-Agent Tasks

| Task | Words |
|------|-------|
| `check` | ≈200 |
| `completion` | ≈100 |

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

## Invocation

`skill({name: "completeness-gate"})` — call the skill, then call via task():

| Task | Call via task() |
|------|----------|
| `check` | `task(..., prompt: "execute check task from completeness-gate")` |
| `completion` | `task(..., prompt: "execute completion task from completeness-gate")` |

**CLI equivalent (for human TUI use):** `/skill completeness-gate --task <task>`

**⚠️ COMPLETION GUARANTEE:** If this workflow halts at ANY point — including error, failure, or early termination — you MUST invoke `--task completion` before halting. The completion subtask is idempotent and safe to invoke multiple times.

## Operating Protocol

1. **Mandatory call:** The orchestrator MUST call this skill after every RED/GREEN sub-agent result and before routing to the adversarial auditor
2. **Single pass:** The check runs once per handoff — no internal loop, no re-checking
3. **Read-only:** No remediation, no routing advice, no fix suggestions
4. **Evidence-based:** All findings require tool-call evidence from live sources

## Routing Decision

After the completeness gate returns:
- **PASS** → proceed to adversarial auditor
- **FAIL + remediable only** → re-task RED/GREEN with completeness findings
- **FAIL + structural** → route to `writing-plans` or `spec-creation`

## Worktree Mode

When `worktree.path` is set, all file operations MUST use it as the base directory.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-20T00:00:00Z"
rules:
  - id: completeness-gate-001
    title: "Single-pass — no internal loop or re-checking"
    conditions:
      all:
        - "completeness_check_started == true"
        - "internal_loop_attempted == true"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: [implementation-pipeline, verification-before-completion]
    source: "completeness-gate/SKILL.md §Operating Protocol"

  - id: completeness-gate-002
    title: "Read-only gate — no remediation, no routing advice"
    conditions:
      any:
        - "completeness_finding_contains_remediation == true"
        - "completeness_result_contains_routing_advice == true"
    actions:
      - HALT
      - STRIP_PROHIBITED_CONTENT
    conflicts_with: []
    requires: []
    triggers: [implementation-pipeline]
    source: "completeness-gate/SKILL.md §Operating Protocol"

  - id: completeness-gate-003
    title: "Evidence-based findings — tool-call artifacts required"
    conditions:
      all:
        - "finding_reported == true"
        - "tool_call_evidence_missing == true"
    actions:
      - HALT
      - COLLECT_EVIDENCE
    conflicts_with: [verification-honesty-001]
    requires: []
    triggers: []
    source: "completeness-gate/SKILL.md §Operating Protocol"

  - id: completeness-gate-004
    title: "Non-adversarial — single sub-agent, not dual cross-family"
    conditions:
      all:
        - "completeness_check_in_progress == true"
        - "auditor_count > 1"
    actions:
      - HALT
      - REDUCE_TO_SINGLE_SUB_AGENT
    conflicts_with: [adversarial-audit-001]
    requires: []
    triggers: [implementation-pipeline]
    source: "completeness-gate/SKILL.md §Operating Protocol"
```
