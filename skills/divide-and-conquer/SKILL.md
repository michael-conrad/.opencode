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
7. **Tool-recipe prohibition:** dispatch context MUST NOT include MCP tool recipes (exact tool names with parameter lists). Sub-agents receive task objectives, not tool instructions. Heuristic: MCP patterns with parameter lists = recipe.
8. **Discard on Sub-Agent Failure:** when a sub-agent returns BLOCKED or ERROR, its work is assumed to be wrong. All files it modified, branches it created, and commits it made MUST be discarded before re-dispatch. Contaminated by definition; no work preservation.
9. **RED/GREEN push-prohibition:** RED and GREEN test sub-agents MUST NOT commit and push. Test sub-agents validate correctness in isolation; commits and pushes are the orchestrator's responsibility.
10. **Spec/Plan coherence gate (pre-RED):** before dispatching RED, verify spec and plan are internally coherent (no contradictory requirements, no missing required sections, no undefined references). If BLOCKED → audit triage → surgical remediation chain (item 12).
11. **Execution-time coherence detection:** RED and GREEN sub-agents MUST verify spec/plan coherence at execution time. If a defect is detected (contradictory requirement, missing prerequisite, undefined reference), the sub-agent MUST return BLOCKED with the specific defect — it MUST NOT proceed.
12. **Audit-classified remediation chain:** when sub-agents BLOCKED on coherence, audit triage classifies defect locus: spec defect → spec-fix → plan-fix → RED-fix; plan defect → plan-fix → RED-fix; RED test defect → RED-fix only; GREEN defect → re-dispatch GREEN. Max 3 remediation attempts before escalating to developer.
13. **Gate Non-Waiver Principle:** "Continue", "next", session momentum, or cumulative approval messages do NOT waive mandatory pipeline gates. Only explicit pipeline-scoped authorization changes `halt_at`. A sub-agent that detects a mandatory check was skipped MUST return BLOCKED regardless of what the user said.
14. **Cost-Blind Verification:** agent MUST NOT consider execution cost, command count, model speed, session duration, or any resource metric when deciding whether to run verification steps. There is no budget for correctness. Every required verification step must be executed regardless of how many tool calls it consumes. Behavioral enforcement tests MUST run via `opencode-cli run` against real AI models — no substitution with grep, static analysis, pattern matching, or metadata inspection. The cost of `opencode-cli run` is ZERO in the decision calculus.

## Sub-Agent Dispatch Audit

All tasks dispatch via `task(subagent_type="general")`. Context: `{ spec, plan, file_paths, worktree.path, github.owner, github.repo }`. Exclusions: implementation context, agent memory, cached verification results, orchestrator reasoning, expected outcomes, MCP tool recipes (exact tool names with parameter lists), pre-written edit instructions. `assemble-work` receives work state file. `pre-analysis` receives only `{ issue_number, task_description }`. Result contracts use `status: DONE|BLOCKED|ERROR|OVERFLOW`. No inline work.

## Orchestrator-Poison Recovery Protocol

When the orchestrator performs inline work (file reads, edits, analysis, verification, or decision-making without sub-agent dispatch), the pipeline is irreversibly poisoned. ALL subsequent deliverables are contaminated regardless of when the contamination occurred.

**Only remediation:** full pipeline restart.
1. Discard ALL work from the poisoned session — no work preservation, no salvage.
2. Re-dispatch from `pre-implementation-analysis` onward with fresh orchestrator context.
3. Flag the incident as CRITICAL PROCESS VIOLATION.
4. Report the restart in chat with explicit statement: "Pipeline restarted due to orchestrator inline work."

The orchestrator is a pure router. It dispatches sub-agents and collects result contracts. Zero inline operations are permitted in the main agent context.

## Cross-References

Skills: `approval-gate`, `git-workflow`, `verification-before-completion`, `finishing-a-development-branch`, `pre-analysis`. Guidelines: `091-incremental-build.md`, `000-critical-rules.md`.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-04T00:00:00Z"
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
    title: "Tool-recipe prohibition — no MCP tool recipes in dispatch context"
    conditions:
      all: ["dispatch_context_contains_mcp_tool_names_with_parameters == true"]
    actions: [HALT, REMOVE_TOOL_RECIPES]
    source: "divide-and-conquer/SKILL.md"

   - id: divide-and-conquer-009
    title: "Discard on sub-agent failure — work assumed wrong before re-dispatch"
    conditions:
      all: ["sub_agent_returned == BLOCKED|ERROR", "retry_count < 2"]
    actions: [DISCARD_FAILED_WORK, RE_DISPATCH]
    source: "divide-and-conquer/SKILL.md"

   - id: divide-and-conquer-010
    title: "RED/GREEN sub-agents must not commit and push"
    conditions:
      all: ["sub_agent_role IN [RED, GREEN]", "sub_agent_attempting_commit_or_push == true"]
    actions: [HALT, BLOCK_COMMIT_PUSH]
    source: "divide-and-conquer/SKILL.md"

   - id: divide-and-conquer-011
    title: "Spec/plan coherence gate before RED dispatch"
    conditions:
      all: ["pre_red_phase == true", "spec_plan_coherence_validated == false"]
    actions: [VALIDATE_COHERENCE, BLOCK_IF_INCOHERENT]
    source: "divide-and-conquer/SKILL.md"

   - id: divide-and-conquer-012
    title: "Execution-time coherence detection — RED/GREEN must block on defects"
    conditions:
      all: ["sub_agent_role IN [RED, GREEN]", "coherence_defect_detected == true", "sub_agent_proceeded_anyway == true"]
    actions: [HALT, RETURN_BLOCKED_WITH_DEFECT]
    source: "divide-and-conquer/SKILL.md"

   - id: divide-and-conquer-013
    title: "Audit-classified remediation chain — defect-locus-based triage"
    conditions:
      all: ["sub_agent_blocked_on_coherence == true", "remediation_attempts < 3"]
    actions: [CLASSIFY_DEFECT_LOCUS, DISPATCH_REMEDIATION_CHAIN]
    source: "divide-and-conquer/SKILL.md"

   - id: divide-and-conquer-014
    title: "Gate Non-Waiver — continue/session momentum does not skip gates"
    conditions:
      all: ["user_input_type == continue|next|proceed", "pipeline_scoped_authorization_received == false", "halt_at > current_stage"]
    actions: [ENFORCE_GATE, RETURN_BLOCKED_IF_GATE_SKIPPED]
    source: "divide-and-conquer/SKILL.md"

   - id: divide-and-conquer-015
    title: "Cost-blind verification — resource cost is never a decision factor"
    conditions:
      all: ["verification_decision_made == true", "cost_or_speed_was_factor == true"]
    actions: [HALT, EXECUTE_FULL_VERIFICATION]
    source: "divide-and-conquer/SKILL.md"
