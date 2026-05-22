---
name: divide-and-conquer
description: Orchestrating implementation without verification gates produces defects that compound through every downstream consumer. Every artifact assembled without a verification gate carries undiscoverable failures. Professional engineers verify every step.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Divide and Conquer

## Overview

Professional orchestration is what verified delivery looks like. Monolithic implementation means undetected defects in every downstream consumer. Professional engineers verify every step — amateur implementations skip verification gates.

## Tasks

| Task | Purpose |
|------|---------|
| `assemble-work` | Single-branch pipeline — the only task in this skill |

## Invocation

`skill({name: "divide-and-conquer"})` — call the skill, then route to:

| Task | Call via task() |
|------|----------|
| `assemble-work` | `task(..., prompt: "execute assemble-work task from divide-and-conquer")` |

**CLI equivalent (for human TUI use):** `/skill divide-and-conquer --task assemble-work`

## Sub-Agent Routing

All substantive work runs via `task(subagent_type="general")`. The orchestrator is a pure router — no creative work, no file edits, no inline analysis. Every task context MUST include the authorization context block:

```yaml
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr|for_pr_only|for_review_only>
halt_at: <analysis_complete|spec_created|plan_created|verification_complete|review_prep|pr_created>
pr_strategy: <none|individual|stacked>
pipeline_phase: <current_phase_name>
authorization_source: "User approved #N on YYYY-MM-DD"
```

Additional context: `{ spec, plan, file_paths, worktree.path, github.owner, github.repo }`. Exclusions: implementation context, agent memory, cached verification results. Auditor tasks use subagent_type from resolve-models result contract (auditor_1/auditor_2) — NOT `general`. Include audit_phase in task context when routing auditors. See adversarial-audit SKILL.md §DISPATCH_GATE. `pre-analysis` receives only `{ issue_number, task_description, github.owner, github.repo }`.

Result contracts: `status: DONE | DONE_WITH_CONCERNS | BLOCKED | OVERFLOW | FAIL`.

**`must_receive` validation:** Every task context MUST include `authorization_scope` in the `must_receive` array. If the task context object lacks `must_receive` or `must_receive` does not contain `authorization_scope`, HALT and report the missing field as a context-contamination violation.

**No acceptance without verification evidence:** Unverified result contracts are unfinished work — re-task instead.

## Enforcement Reference

| Document | Purpose |
|----------|---------|
| Sub-agent context shape | Context shape and exclusions for task() routing |
| `enforcement/overflow-signal.md` | OVERFLOW contract and re-routing strategies |
| `enforcement/work-state-verification.md` | Verification table and work state format |

## Cross-References

Skills: `approval-gate`, `git-workflow`, `VbC`, `finishing-a-development-branch`, `pre-analysis`, `adversarial-audit --task coherence-maintenance`, `completeness-gate`. Guidelines: `091-incremental-build.md`, `000-critical-rules.md`.

```yaml+symbolic
schema_version: "3.0"
last_updated: "2026-05-21T00:00:00Z"
rules:
  - id: divide-and-conquer-001
    title: "No direct implementation by orchestrator"
    conditions:
      all: ["is_orchestrator == true", "about_to_edit_implementation_file == true"]
    actions: [HALT, TASK(sub-agent)]
    source: "divide-and-conquer/SKILL.md"

  - id: divide-and-conquer-005
    title: "Implementation-first gate requires deliverable"
    conditions:
      all: ["assemble_work_completed == true", "files_modified_count == 0", "authorization_scope >= for_implementation"]
    actions: [HALT, REPORT(zero_deliverables)]
    source: "divide-and-conquer/SKILL.md"

  - id: divide-and-conquer-007
    title: "PR merge boundary check before sub-agent routing"
    conditions:
      all: ["plan_has_pr_boundaries == true", "required_pr_not_merged == true"]
    actions: [HALT]
    source: "divide-and-conquer/SKILL.md"

  - id: divide-and-conquer-008
    title: "Tool-recipe prohibition — task context specifies WHAT, never HOW"
    conditions:
      any:
        - "task_context_contains_mcp_tool_names == true"
        - "task_context_contains_line_numbers == true"
        - "task_context_contains_step_by_step_script == true"
    actions: [HALT]
    source: "divide-and-conquer/SKILL.md §B1"

  - id: divide-and-conquer-009
    title: "Poison recovery protocol — orchestrator inline work poisons pipeline"
    conditions:
      all: ["is_orchestrator == true", "performed_inline_work == true"]
    actions: [HALT, DISCARD_ALL_STATE, RESTART_FROM(verify-authorization)]
    source: "divide-and-conquer/SKILL.md §B2"

  - id: divide-and-conquer-010
    title: "Discard on sub-agent failure — ALL files discarded before re-task"
    conditions:
      any:
        - "sub_agent_status == BLOCKED"
        - "sub_agent_status == ERROR"
    actions: [DISCARD(changed_files), RE_TASK(original_context)]
    source: "divide-and-conquer/SKILL.md §B3"

  - id: divide-and-conquer-011
    title: "RED/GREEN push-prohibition — test sub-agents never commit or push"
    conditions:
      all: ["sub_agent_type IN ['RED', 'GREEN']", "attempting_to_commit_or_push == true"]
    actions: [HALT]
    source: "divide-and-conquer/SKILL.md §B4"

  - id: divide-and-conquer-012
    title: "Coherence gate — verify spec/plan coherence before RED routing"
    conditions:
      all: ["red_routing_pending == true", "spec_plan_coherence_verified == false"]
    actions: [CALL(adversarial-audit --task coherence-maintenance), VERIFY_COHERENCE]
    source: "divide-and-conquer/SKILL.md §B5"

  - id: divide-and-conquer-013
    title: "Execution-time coherence detection — RED/GREEN return BLOCKED on defect"
    conditions:
      any:
        - "red_sub_agent_detected_spec_codebase_contradiction == true"
        - "green_sub_agent_detected_plan_spec_mismatch == true"
    actions: [RETURN(status=BLOCKED)]
    source: "divide-and-conquer/SKILL.md §B6"

  - id: divide-and-conquer-014
    title: "Audit-classified remediation — max 3 attempts before escalating"
    conditions:
      all: ["sub_agent_status == BLOCKED", "remediation_attempts >= 3"]
    actions: [ESCALATE_TO_DEVELOPER]
    source: "divide-and-conquer/SKILL.md §B7"

  - id: divide-and-conquer-015
    title: "Gate non-waiver — 'continue' does not waive mandatory gates"
    conditions:
      all: ["user_input_type == 'continue'", "mandatory_gate_skipped == true"]
    actions: [HALT]
    source: "divide-and-conquer/SKILL.md §B8"

  - id: divide-and-conquer-016
    title: "Cost-blind verification — never skip routing or verification to save resources"
    conditions:
      all: ["routing_or_verification_skipped_for_economy == true"]
    actions: [HALT]
    source: "divide-and-conquer/SKILL.md §B9"

  - id: divide-and-conquer-017
    title: "Completeness gate required after RED/GREEN before adversarial audit"
    conditions:
      all: ["sub_agent_result_collected == true", "completeness_gate_run == false", "adversarial_audit_routing_pending == true"]
    actions: [CALL(completeness-gate --task check)]
    source: "divide-and-conquer/SKILL.md §B10"
```