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
7. **Tool-recipe prohibition:** sub-agents MUST NOT be dispatched with exact file paths, line numbers, or expected outcomes. Pre-analysis sub-agents independently discover scope.
8. **Poison Recovery Protocol:** when a sub-agent fails (empty/error/timeout), discard all group work via `git reset --hard <last-clean-commit>`. Re-dispatch clean. No inline fallback.
9. **RED/GREEN push-prohibition:** sub-agents MUST NOT commit or push. Only the orchestrator commits at gate boundaries after VbC + dual-auditor PASS.
10. **Coherence gate:** pre-dispatch gate verifying spec/plan coherence. Sub-agents detecting spec/plan defects MUST flag them rather than proceeding with implementation.
11. **Execution-time coherence detection:** sub-agents that detect spec/plan defects during execution MUST report them as BLOCKED with defect classification.
12. **Audit-classified remediation:** coherence issues classified into auto-fix, conditional, or flag-for-review tiers. Auto-fix applied directly; conditional requires authorization; flag-for-review reported only.
13. **Gate Non-Waiver:** "continue"/"proceed" messages do NOT waive mandatory pipeline gates. Every pipeline step MUST still invoke all mandatory verification gates.
14. **Cost-Blind Verification:** verification MUST use the correct tool/method regardless of cost. Never substitute grep/static-analysis/cheaper methods for actual behavioral test execution.

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
