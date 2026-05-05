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
7. **Universal re-dispatch:** sub-agent empty/error/failure results (any pipeline stage) handled by clean-room re-dispatch, never inline fallback. On double-failure: invoke `--task completion`, HALT with status message + byline. This applies universally, not just to behavioral testing.
8. **Poisoned pipeline gate:** orchestrator inline work irreversibly poisons the pipeline. Entire pipeline MUST restart from coherence gate. All sub-agent state discarded. No partial resume permitted.
9. **Discard on sub-agent failure:** when a sub-agent returns FAIL/BLOCKED/ERROR, its work is contaminated by definition — discard all output before re-dispatch. Never cherry-pick partial results from a failed sub-agent.
10. **No tool-recipe dispatch:** sub-agents receive task objectives (e.g., "implement Phase 2 of #N"), never exact MCP tool names with parameter lists (e.g., "call srclight_get_symbol then edit line 42"). Tool-recipe dispatch violates clean-room isolation at the dispatch-content level — see `000-critical-rules.md` §Preloading Sub-Agent Context.
11. **Sub-agent coercion boundaries:** sub-agents MUST NOT be instructed to mutate remote state (commit, push, create PR). Test sub-agents (RED/GREEN) verify correctness, never commit or push.
12. **Sub-agent blocking authority:** sub-agents detecting spec/plan defects MUST BLOCK, never proceed. Sub-agents have authority to halt the pipeline on coherence failures. Sub-agent detecting a defect but proceeding with GREEN anyway is a critical violation.
13. **Execution-time coherence detection:** RED and GREEN sub-agents verify spec/plan coherence at execution time. If coherence failure detected → BLOCK → audit triage, not GREEN continuation.
14. **Audit-classified remediation:** on BLOCKED, classify defect locus via audit triage: spec defect → spec-fix → plan-fix → RED-fix; plan defect → plan-fix → RED-fix; RED test defect → RED-fix only; GREEN failure → re-dispatch GREEN. Max 3 remediation attempts before escalating to developer.
15. **Gate Non-Waiver Principle:** "continue" messages and session momentum do NOT waive mandatory pipeline gates (coherence gate, verification-before-completion, finishing-a-development-branch checklist). Only pipeline-scoped authorization (`approved #N to PR`) changes `halt_at`.
16. **Cost-blind verification:** agent MUST NOT cite command count, execution time, model speed, or any resource metric as justification for skipping or shortcutting verification. Behavioral enforcement tests run via `opencode-cli run` against real models — grep, static analysis, or pattern matching are NOT substitutes. The cost of verification is ZERO in the decision calculus — see `000-critical-rules.md` §Correctness over economy.

## Sub-Agent Dispatch Audit

All tasks dispatch via `task(subagent_type="general")`. Context: `{ spec, plan, file_paths, worktree.path, github.owner, github.repo }`. Exclusions: implementation context, agent memory, cached verification results. `assemble-work` receives work state file. `pre-analysis` receives only `{ issue_number, task_description }`. Result contracts use `status: DONE|BLOCKED|ERROR|OVERFLOW`. No inline work.

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
