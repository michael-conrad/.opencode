---
name: verification-before-completion
description: Use when claiming a task is complete, marking a step done, or closing an issue. Triggers on: task complete, done, finished, step complete, mark done, verify completion, success criteria. A completion claim without verification is not a completion — it is a placeholder for undiscovered defects.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: verification-before-completion

## Overview

Verification IS completion — there is no valid state called "implemented but unverified." Every claim of completion requires verified PASS for all success criteria. Completion without verification is not completion — it is a placeholder for undiscovered defects.

Remediation of failed verification IS agent-owned — the producing agent owns every defect in its output, and autonomous remediation is the default action before any escalation.

Ensures ALL success criteria are verified with actual evidence before ANY task or phase is marked complete. Structural completeness checked before per-SC verification.

## Persona

Verification Gatekeeper. Focus: no completion claim without verified evidence. Enforce live-source verification only.

## Tasks

| Task | Words |
|------|-------|
| `verify` | ≈700 |
| `collect` | ≈500 |
| `structural-verify` | ≈500 |
| `completion` | ≈150 |

## Invocation

`skill({name: "verification-before-completion"})` — call the skill, then call via task():

| Task | Call via task() |
|------|----------|
| `verify` | `task(..., prompt: "execute verify task from verification-before-completion")` |
| `structural-verify` | `task(..., prompt: "execute structural-verify task from verification-before-completion")` |
| `collect` | `task(..., prompt: "execute collect task from verification-before-completion")` |
| `completion` | `task(..., prompt: "execute completion task from verification-before-completion")` |

**CLI equivalent (for human TUI use):** `/skill verification-before-completion --task <task>`

## Operating Protocol

1. **Structural completeness first:** verify all specified files/components exist before SC verification.
2. **Adversarial-audit call:** during verify task, call `adversarial-audit --task drift-detection --issue <N>` with `audit_phase: implementation_verification` to check spec/code reality alignment.
3. **Per-SC evidence table:** every SC must produce a tool-call artifact with PASS/FAIL.
4. **Exact comparison:** external verifications use exact mode. No "functionally equivalent" soft-passes.
5. **Live-source only:** evidence from memory/training data is FORBIDDEN. Tool-call artifact required.
6. **Clean-room routing:** verification sub-agents receive ONLY spec SC list + file paths. No implementation context, no prior results.

## Sub-Agent Routing

All tasks run via `task(subagent_type="general")` with `{ spec_sc_list, file_paths, worktree.path, github.owner, github.repo, authorization_scope, halt_at, pr_strategy, pipeline_phase }`. Auditor tasks use subagent_type from resolve-models result contract (auditor_1/auditor_2) — NOT `general`. Include audit_phase in task context when routing auditors. See adversarial-audit SKILL.md §DISPATCH_GATE. Exclusions: implementation context, agent memory, prior verification results. `structural-verify` receives spec structure. `pre-analysis` receives only `{ issue_number, task_description, pipeline_phase, authorization_scope, halt_at, pr_strategy, github.owner, github.repo }`. No inline work.

### Authorization Context
```
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr|for_pr_only|for_review_only>
halt_at: <analysis_complete|spec_created|plan_created|verification_complete|review_prep|pr_created>
pr_strategy: <none|individual|stacked>
pipeline_phase: <current_phase_name>
authorization_source: "User approved #N on YYYY-MM-DD"
```

### Routing Rules
- Missing `authorization_scope` in task context → return `status: BLOCKED`
- Instructed to exceed `halt_at` → return `status: BLOCKED`

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
