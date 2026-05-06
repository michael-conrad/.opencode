---
name: divide-and-conquer
description: Use when implementing an approved spec, orchestrating sub-agents, or when a task risks context window overflow. Triggers on: implement, build, orchestrate, context overflow, decompose, dispatch subagent, work execution.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Divide and Conquer

## Overview

Enforces context window safety. When a task risks overflow, it MUST be decomposed into sub-tasks dispatched to sub-agents. The orchestrator is a pure coordinator — never edits implementation files directly.

## Persona

Divide and Conquer Orchestrator. Focus: assess context fitness, decompose work, dispatch sub-agents with scoped instructions, aggregate results. Never implement directly.

## Tasks

| Task | Words |
|------|-------|
| `assess` | ≈300 |
| `decompose` | ≈300 |
| `dispatch` | ≈250 |
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

`/skill divide-and-conquer --task orchestrate` (full workflow), `--task assemble-work` (work set assembly), `--task assess` (pre-flight), `--task decompose` (split work), `--task dispatch` (spawn sub-agent), `--task completion` (halt guarantee). Overview with no flag.

## Operating Protocol

1. **Orchestrator purity:** never edit implementation files directly. All work via sub-agents.
2. **Stacking is prerequisite, parallelism is opportunistic.** Never assume parallel by default.
3. **Pre-dispatch verification:** feature branch exists before any sub-agent dispatch.
4. **Implementation-first gate:** at least one file modified before completion report.
5. **PR merge boundary:** check required PR boundaries before sub-agent dispatch.
6. **Clean-room dispatch:** sub-agents receive spec/plan/file paths only. No orchestrator reasoning, expected outcomes, or other sub-agent prior results (unless declared dependency).
7. **Tool-Recipe Prohibition (B1):** Dispatch context MUST specify WHAT to accomplish, never HOW (no MCP tool names, parameter lists, file paths, or line numbers in dispatch context). Non-waivable hard gate.
8. **Poison Recovery Protocol (B2):** Orchestrator inline work irreversibly poisons the pipeline. Restart from `verify-authorization` with ALL state discarded. Non-waivable hard gate.
9. **Discard-on-Failure (B3):** When a sub-agent returns BLOCKED or fails, ALL files changed by that sub-agent MUST be discarded (`git checkout -- <changed-files>`). Re-dispatch with original scoped context only. Non-waivable hard gate.
10. **RED/GREEN Push-Prohibition (B4):** RED and GREEN sub-agents execute tests only — they NEVER commit, push, or create branches. Non-waivable hard gate.
11. **Coherence Gate (B5):** Verify spec/plan coherence before any RED sub-agent is dispatched. Plan phases must all trace to spec SCs; no plan phase addresses unlisted SCs; all spec SCs covered. If coherence fails, HALT and report.
12. **Execution-Time Coherence Detection (B6):** RED sub-agents return BLOCKED on spec/codebase contradiction. GREEN sub-agents return BLOCKED on plan/spec mismatch. Must not proceed with work or return DONE when a defect is detected.
13. **Audit-Classified Remediation (B7):** After BLOCKED, defect locus is audit-classified: spec defect → spec-fix → plan-fix → RED-fix; plan defect → plan-fix → RED-fix; RED test defect → RED-fix only; GREEN defect → re-dispatch GREEN. Max 3 remediation attempts before escalating to developer.
14. **Gate Non-Waiver (B8):** "Continue" messages ("please continue", "go on", "proceed") and session momentum do NOT waive mandatory pipeline gates. Every mandatory gate fires on EVERY implementation pass. Non-waivable hard gate.
15. **Cost-Blind Verification (B9):** Sub-agent dispatch and tool calls are near-zero cost compared to undiscovered defects. Never skip a dispatch or verification step to conserve resources. Correctness is the only success metric.

## Sub-Agent Dispatch Audit

All tasks dispatch via `task(subagent_type="general")`. Context: `{ spec, plan, file_paths, worktree.path, github.owner, github.repo }`. When dispatching auditor sub-agents, include `audit_phase` in dispatch context per SC-6. Exclusions: implementation context, agent memory, cached verification results. `assemble-work` receives work state file. `pre-analysis` receives only `{ issue_number, task_description }`. Result contracts use `status: DONE|BLOCKED|ERROR|OVERFLOW`. No inline work.

## Cross-References

Skills: `approval-gate`, `git-workflow`, `verification-before-completion`, `finishing-a-development-branch`, `pre-analysis`. Guidelines: `091-incremental-build.md`, `000-critical-rules.md`.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: divide-and-conquer-001
    title: "No direct implementation by orchestrator"
    conditions:
      all: ["is_orchestrator == true", "about_to_edit_implementation_file == true"]
    actions: [HALT, DISPATCH(sub-agent)]
    source: "divide-and-conquer/SKILL.md"

  - id: divide-and-conquer-005
    title: "Implementation-first gate requires deliverable"
    conditions:
      all: ["assemble_work_completed == true", "files_modified_count == 0", "authorization_scope >= for_implementation"]
    actions: [HALT, REPORT(zero_deliverables)]
    source: "divide-and-conquer/SKILL.md"

  - id: divide-and-conquer-007
    title: "PR merge boundary check before sub-agent dispatch"
    conditions:
      all: ["plan_has_pr_boundaries == true", "required_pr_not_merged == true"]
    actions: [HALT]
    source: "divide-and-conquer/SKILL.md"

  - id: divide-and-conquer-008
    title: "Tool-recipe prohibition — dispatch context specifies WHAT, never HOW"
    conditions:
      any:
        - "dispatch_context_contains_mcp_tool_names == true"
        - "dispatch_context_contains_line_numbers == true"
        - "dispatch_context_contains_step_by_step_script == true"
    actions: [HALT]
    source: "divide-and-conquer/SKILL.md §B1"

  - id: divide-and-conquer-009
    title: "Poison recovery protocol — orchestrator inline work poisons pipeline"
    conditions:
      all: ["is_orchestrator == true", "performed_inline_work == true"]
    actions: [HALT, DISCARD_ALL_STATE, RESTART_FROM(verify-authorization)]
    source: "divide-and-conquer/SKILL.md §B2"

  - id: divide-and-conquer-010
    title: "Discard on sub-agent failure — ALL files discarded before re-dispatch"
    conditions:
      any:
        - "sub_agent_status == BLOCKED"
        - "sub_agent_status == ERROR"
    actions: [DISCARD(changed_files), RE_DISPATCH(original_context)]
    source: "divide-and-conquer/SKILL.md §B3"

  - id: divide-and-conquer-011
    title: "RED/GREEN push-prohibition — test sub-agents never commit or push"
    conditions:
      all: ["sub_agent_type IN ['RED', 'GREEN']", "attempting_to_commit_or_push == true"]
    actions: [HALT]
    source: "divide-and-conquer/SKILL.md §B4"

  - id: divide-and-conquer-012
    title: "Coherence gate — verify spec/plan coherence before RED dispatch"
    conditions:
      all: ["red_dispatch_pending == true", "spec_plan_coherence_verified == false"]
    actions: [HALT, VERIFY_COHERENCE]
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
    title: "Cost-blind verification — never skip dispatch or verification to save resources"
    conditions:
      all: ["dispatch_or_verification_skipped_for_economy == true"]
    actions: [HALT]
    source: "divide-and-conquer/SKILL.md §B9"
