---
title: "Plan: Dispatch boundary violations across skill deck"
issue: 2020
status: draft
created: 2026-07-20
license: MIT
provenance: AI-generated
spec: "#2020"
---

## Goal

Fix all dispatch boundary violations across the skill deck: SKILL.md Invocation sections that dispatch pipelines with `[sub-task]` steps to sub-agents, writing-plans/SKILL.md TDT classification defects, related task file defects, assemble-work.md content gaps, and behavioral enforcement tests.

## Architecture

6 sequential phases, each with strict chain dependency. No parallel execution possible due to cross-cutting concerns (SKILL.md Invocation consistency, writing-plans/SKILL.md consistency).

### Shared-File Dependency: Phase 2 ↔ Phase 3 (writing-plans/SKILL.md)

Phase 2 (Step 5) and Phase 3 (Steps 7-12) both modify `writing-plans/SKILL.md`. This is intentional — Phase 2 fixes the Invocation section (general `[sub-task]` → `inline` conversion), while Phase 3 fixes the Trigger Dispatch Table classification and Sub-Agent Routing claims (writing-plans-specific defects D1-D7). The phases are sequential (Phase 2 must complete before Phase 3 begins) to avoid merge conflicts on the same file. Phase 2's Concern Transition explicitly states: "Phase 2 general Invocation fix must precede Phase 3 writing-plans-specific fix to avoid conflict."

## Files

| File | Phase | Change |
|------|-------|--------|
| `.opencode/skills/spec-creation/SKILL.md` | 2 | Fix Invocation — orchestrator executes pipeline, dispatches each step individually |
| `.opencode/skills/writing-plans/SKILL.md` | 2, 3 | Fix Invocation (P2), fix TDT classification + Sub-Agent Routing + .issues/ refs (P3) |
| `.opencode/skills/writing-plans-creation/tasks/audit-fidelity.md` | 3 | Remove "with auditor sub-agent type context" |
| `.opencode/skills/writing-plans-creation/tasks/audit-concern.md` | 3 | Remove "with auditor sub-agent type context" |
| `.opencode/skills/writing-plans-creation/tasks/completion.md` | 3 | Fix path: `completion-core/completion-core.md` → `completion-core/SKILL.md` |
| `.opencode/skills/implementation-pipeline/tasks/assemble-work.md` | 4 | Add entry proof, OVERFLOW, work state verification, completion checkpoint |
| `.opencode/guidelines/000-critical-rules.md` | 5 | Add critical violation entry for sub-agent task() dispatch |
| `.opencode/tests-v2/behaviors/dispatch-boundary-spec-creation.sh` | 6 | New behavioral test |
| `.opencode/tests-v2/behaviors/dispatch-boundary-writing-plans.sh` | 6 | New behavioral test |

## Phase Table

| Phase | Name | Dependencies | SC Coverage |
|-------|------|-------------|-------------|
| 1 | Audit and classify all SKILL.md Invocation sections | None | SC-1 (audit scope) |
| 2 | Fix SKILL.md Invocation sections | 1 | SC-1 |
| 3 | Fix writing-plans/SKILL.md dispatch classification and related defects | 2 | SC-2 through SC-11 |
| 4 | Fix assemble-work.md content completeness | 3 | SC-12 through SC-15 |
| 5 | Add critical violation to guidelines | 4 | SC-16 |
| 6 | Behavioral enforcement tests | 5 | SC-17 through SC-19 |

## Exit Criteria

- All 19 SCs verified PASS
- No SKILL.md Invocation section dispatches a pipeline with `[sub-task]` steps to a sub-agent
- All writing-plans defects (D1-D7) resolved
- assemble-work.md has all 4 content sections
- Behavioral tests pass

## Self-Remediation Protocol

> **One step at a time.** Each step in every phase is a discrete unit. If a step fails, remediate that step before proceeding to the next. Do not batch steps. Do not skip failed steps. Rollback to the last verified checkpoint if remediation fails.

## Admonishments

> **Phase 5 may be a no-op.** Research indicates SC-16 is already RESOLVED — `000-critical-rules.md` already has the critical-rules-XXX entry for sub-agent task() dispatch. Verify before executing.

> **D7 status: verify before fix.** The spec lists D7 as ACTIVE (`completion.md` references `completion-core/completion-core.md` instead of `completion-core/SKILL.md`). Step 12.5 in Phase 3 reads the file, verifies the current reference, and fixes it if needed.

> **Violation B (task cards with task() calls) and Violation C (missing orchestrator entry points) are already RESOLVED.** No work needed.

## Self-Review Evidence

- Spec read and verified: `.opencode/.issues/2020/spec.md` — 19 SCs, 6 phases, clear dependency chain
- Structure artifact: `.opencode/.issues/2020/artifacts/structure.yaml` — DONE, 6 phases with dependency contract
- Solve state: `.opencode/.issues/2020/artifacts/solve-state.yaml` — SAT, all phases can complete
- Dependency contract: `.opencode/.issues/2020/artifacts/dependency-contract.yaml` — sequential chain, no parallel paths
- Readiness: `.opencode/.issues/2020/artifacts/readiness.yaml` — all checks pass
