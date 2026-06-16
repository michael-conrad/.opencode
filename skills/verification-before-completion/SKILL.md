---
name: verification-before-completion
description: "Use when claiming a task is complete, marking a step done, or closing an issue. A completion claim without verification is not a completion — it is a placeholder for undiscovered defects."
type: discipline-enforcing
license: MIT
compatibility: opencode
---

# Skill: verification-before-completion

## Overview

Verification IS completion — there is no valid state called "implemented but unverified." Every claim of completion requires verified PASS for all success criteria. Completion without verification is not completion — it is a placeholder for undiscovered defects.

Remediation of failed verification IS agent-owned — the producing agent owns every defect in its output, and autonomous remediation is the default action before any escalation.

Ensures ALL success criteria are verified with actual evidence before ANY task or phase is marked complete. Structural completeness checked before per-SC verification.



## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "verify" / "verify SCs" / "check completion" | `verify` | `sub-task` | {spec_sc_list, file_paths} |
| "collect" / "collect evidence" | `collect` | `sub-task` | {spec_sc_list, file_paths} |
| "structural-verify" / "structural check" | `structural-verify` | `sub-task` | {spec_structure} |
| completion / workflow end | `completion` | `sub-task` | {workflow_state} |

## Persona

Verification Gatekeeper. Focus: no completion claim without verified evidence. Enforce live-source verification only.

## Tasks


| `verify` |
| `collect` |
| `structural-verify` |
| `completion` |

## Invocation

`skill({name: "verification-before-completion"})` — call the skill, then call via task():

| Task | Call via task() |

| `verify` | `task(..., prompt: "execute verify task from verification-before-completion")` |
| `structural-verify` | `task(..., prompt: "execute structural-verify task from verification-before-completion")` |
| `collect` | `task(..., prompt: "execute collect task from verification-before-completion")` |
| `completion` | `task(..., prompt: "execute completion task from verification-before-completion")` |

**CLI equivalent (for human TUI use):** `/skill verification-before-completion --task <task>`

## Operating Protocol

- [ ] 1. **Structural completeness first:** verify all specified files/components exist before SC verification.
- [ ] 2. **Adversarial-audit call:** during verify task, call `adversarial-audit --task drift-detection --issue <N>` with `audit_phase: implementation_verification` to check spec/code reality alignment.
- [ ] 3. **Per-SC evidence table:** every SC must produce a tool-call artifact with PASS/FAIL.
- [ ] 4. **Exact comparison:** external verifications use exact mode. No "functionally equivalent" soft-passes.
- [ ] 5. **Live-source only:** evidence from memory/training data is FORBIDDEN. Tool-call artifact required.
- [ ] 6. **Clean-room routing:** verification sub-agents receive ONLY spec SC list + file paths. No implementation context, no prior results.

## Sub-Agent Routing

All tasks run via `task(subagent_type="general")` with `{ spec_sc_list, file_paths, worktree.path, github.owner, github.repo, authorization_scope, halt_at, pr_strategy, pipeline_phase }`. Auditor tasks use subagent_type from resolve-models result contract (auditor_1/auditor_2) — NOT `general`. Include audit_phase in task context when routing auditors. See adversarial-audit SKILL.md §DISPATCH_GATE. Exclusions: implementation context, agent memory, prior verification results. `structural-verify` receives spec structure. `pre-analysis` receives only `{ issue_number, task_description, pipeline_phase, authorization_scope, halt_at, pr_strategy, github.owner, github.repo }`. No inline work.

### Authorization Context
```
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr|for_pr_only|for_review_only>
halt_at: <analysis_complete|spec_created|plan_created|verification_complete|review_prep|pr_created>
pr_strategy: <none|stacked>
pipeline_phase: <current_phase_name>
authorization_source: "User approved #N on YYYY-MM-DD"
```

### Routing Rules
- Missing `authorization_scope` in task context → return `status: BLOCKED`
- Instructed to exceed `halt_at` → return `status: BLOCKED`

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

#### Orchestrator Entry Criteria

After loading this skill and reading the Trigger Dispatch Table, the orchestrator MUST:
- Use the exact `task(..., prompt: "...")` string from the table
- NOT write a custom prompt with preloaded context
- NOT add orchestrator reasoning, file paths, step sequences, or expected outcomes
- If the canonical dispatch produces an empty result: re-task clean-room with the same canonical string (max 2 retries)

## Cross-References

Skills: `finishing-a-development-branch`, `adversarial-audit --task drift-detection`. Guidelines: `065-verification-honesty.md`, `000-critical-rules.md`.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: verification-before-completion-001
    title: "No completion claim without evidence"
    conditions:
      all: ["agent_claims_complete == true", "all_sc_have_evidence == false"]
    actions: [HALT, REQUIRE_EVIDENCE]
    source: "verification-before-completion/SKILL.md"

  - id: verification-before-completion-004
    title: "Exact comparison mode for external verifications"
    conditions:
      all: ["external_verification == true", "comparison_mode != exact"]
    actions: [SET(comparison_mode=exact)]
    source: "verification-before-completion/SKILL.md"

  - id: verification-before-completion-005
    title: "Structural completeness required before per-SC verification"
    conditions:
      all: ["verify_task_executed == true", "structural_completeness_checked == false"]
    actions: [HALT, TASK(structural-verify)]
    source: "verification-before-completion/SKILL.md"
