---
name: divide-and-conquer
description: Use when implementing an approved spec, orchestrating sub-agents, or when a task risks context window overflow. Triggers on: implement, build, orchestrate, context overflow, decompose, task subagent, work execution. Monolithic implementation always produces defects. Agents who decompose their work produce correct, reviewable results.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Divide and Conquer

## Overview

Enforces context window safety. Orchestrator is a pure coordinator — never edits implementation files directly.

## Persona

Divide and Conquer Orchestrator. Assess context fitness, decompose work, task sub-agents with scoped instructions, aggregate results.

## Tasks

| Task | Words |
|------|-------|
| `assess` | ≈300 |
| `decompose` | ≈300 |
| `route` | ≈250 |
| `completion-checkpoint` | ≈300 |
| `result-validation` | ≈200 |
| `overflow-signal` | ≈200 |
| `merge` | ≈150 |
| `context-passing` | ≈200 |
| `purification-and-enforcement` | ≈250 |
| `orchestrate` | ≈400 |
| `assemble-work` | ≈200 |
| `implementer-prompt` | ≈250 |
| `spec-reviewer-prompt` | ≈200 |
| `code-quality-reviewer-prompt` | ≈200 |
| `completion` | ≈150 |

## Invocation

`skill({name: "divide-and-conquer"})` — call the skill, then call via task():

| Task | Call via task() |
|------|----------|
| `orchestrate` | `task(..., prompt: "execute orchestrate task from divide-and-conquer")` |
| `assemble-work` | `task(..., prompt: "execute assemble-work task from divide-and-conquer")` |
| `assess` | `task(..., prompt: "execute assess task from divide-and-conquer")` |
| `decompose` | `task(..., prompt: "execute decompose task from divide-and-conquer")` |
| `route` | `task(..., prompt: "execute route task from divide-and-conquer")` |
| `completion` | `task(..., prompt: "execute completion task from divide-and-conquer")` |

**CLI equivalent (for human TUI use):** `/skill divide-and-conquer --task <task>`

## Sub-Agent Routing

All tasks run via `task(subagent_type="general")`. Every task context MUST include the authorization context block:

```yaml
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr|for_pr_only|for_review_only>
halt_at: <analysis_complete|spec_created|plan_created|verification_complete|review_prep|pr_created>
pr_strategy: <none|individual|stacked>
pipeline_phase: <current_phase_name>
authorization_source: "User approved #N on YYYY-MM-DD"
```

Additional context: `{ spec, plan, file_paths, worktree.path, github.owner, github.repo }`. Exclusions: implementation context, agent memory, cached verification results. Auditor tasks use subagent_type from resolve-models result contract (auditor_1/auditor_2) — NOT `general`. Include audit_phase in task context when routing auditors. See adversarial-audit SKILL.md §DISPATCH_GATE. `pre-analysis` receives only `{ issue_number, task_description, github.owner, github.repo }`. Result contracts: `status: DONE|BLOCKED|ERROR|OVERFLOW`.

**`must_receive` validation:** Every task context MUST include `authorization_scope` in the `must_receive` array. If the task context object lacks `must_receive` or `must_receive` does not contain `authorization_scope`, HALT and report the missing field as a context-contamination violation.

**No acceptance without verification evidence:** Unverified result contracts are unfinished work — re-task instead.

## Cross-References

Skills: `approval-gate`, `git-workflow`, `verification-before-completion`, `finishing-a-development-branch`, `pre-analysis`, `adversarial-audit --task coherence-maintenance`. Guidelines: `091-incremental-build.md`, `000-critical-rules.md`.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
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
