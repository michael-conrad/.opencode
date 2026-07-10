# [SPEC-FIX] DISPATCH_GATE Migration Broke Enforcement Chain — Restore Hard-Gate Content to SKILL.md + Add Analysis-Depth Prevention Gate

**STATUS:** DRAFT
**CREATED:** 2026-07-10
**Issue:** [michael-conrad/.opencode#1836](https://github.com/michael-conrad/.opencode/issues/1836)

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Intent and Executive Summary

**Problem Statement:** The DISPATCH_GATE migration (commit bfb0a212) moved critical enforcement content from SKILL.md files into task files that are never read by any agent in the execution chain. This caused two regressions: broken incremental TDD chaining and missing analysis depth in plans.

**Root Cause / Motivation:** The `skill()` function loads SKILL.md only. Task files are read by sub-agents dispatched to specific tasks. Content moved to `operating-protocol.md` files is invisible to the execution chain because no sub-agent is dispatched to read those files. The orchestrator is prohibited from reading task files. The result: hard-gate enforcement text is preserved on disk but invisible to every agent.

**Approach Chosen:** Restore critical enforcement content to SKILL.md files where `skill()` loads it, and add an analysis-depth prevention gate to the plan creation pipeline.

**Alternatives Considered & Why Discarded:**
- **Add dispatch entries for operating-protocol.md files:** Would require every sub-agent to read an additional file, adding context overhead without benefit. SKILL.md is already loaded — putting content there is zero additional cost.
- **Leave content in task files and have orchestrator read them:** Violates the orchestrator context discipline (orchestrator MUST NOT read task files).

**Key Design Decisions:**
1. Content that contains hard enforcement gates MUST live in SKILL.md or be added to the Trigger Dispatch Table as a dispatchable task.
2. Operating protocol files that are never dispatched are dead content — they must either be restored to SKILL.md or given dispatch entries.
3. The analysis-depth prevention gate is a pre-creation gate, not a post-creation audit — it prevents defective plans from being created, rather than catching them after creation.

After this spec is approved, invoke `writing-plans` to create `.issues/1836/plan.md` before implementation begins.

## Objective

Fix two regressions caused by the DISPATCH_GATE migration (commit bfb0a212) that moved critical enforcement content from SKILL.md files into task files that are never read by any agent in the execution chain.

## Problem

### Regression 1: Broken Incremental TDD Chaining

The agent has regressed to running red/red/red → green/green/green instead of interleaved red/green → red/green → red/green. This makes red tests for items 2..N worthless since they all fail because item 1 isn't implemented yet.

**Root cause:** The TDD hard gate "RED and GREEN may NEVER be combined into a single phase or step. RED must complete (test written and confirmed FAIL) before GREEN begins. This is a hard gate — no authorization or developer instruction may override it" was moved from `test-driven-development/SKILL.md` to `test-driven-development/tasks/operating-protocol.md` in commit bfb0a212.

The execution chain never reads operating-protocol.md:
- The orchestrator loads `skill({name: "test-driven-development"})` → gets SKILL.md only (which has a pointer, not the content)
- The orchestrator is prohibited from reading task files ("No task files are read by the orchestrator")
- RED sub-agents read `red.md`, not `operating-protocol.md`
- GREEN sub-agents read `green.md`, not `operating-protocol.md`

The hard gate text is preserved on disk but invisible to every agent in the execution chain.

The same pattern affects:
- `writing-plans/SKILL.md` — 35 lines of operating protocol moved to `tasks/operating-protocol.md`
- `implementation-pipeline/SKILL.md` — 15 lines moved to `tasks/operating-protocol.md`, plus `assemble-work.md` and `pipeline-executor.md` deleted entirely

### Regression 2: Missing Analysis Depth in Plans

Plans no longer include: blast radius analysis, separation of concerns, decomposition down to lowest level, cross-cutting concerns, mandatory full code path exercising. These are missing even when absent from the specs the plans are written from.

**Root cause:** Analysis depth requirements exist in spec-creation tasks (risk.md, decompose.md, requirements.md) and audit tasks (concern-separation.md, plan-fidelity.md, spec-audit.md), but there is no explicit gate in the plan creation pipeline that verifies the spec contains these analyses BEFORE plan creation begins. The audits catch missing analysis depth only post-creation, requiring rework.

Additionally, `writing-plans/tasks/validate.md` has 20 structural checks but NONE verify analysis depth (blast radius, separation of concerns, decomposition quality, cross-cutting concerns, full code path exercising).

## Context

The DISPATCH_GATE migration (bfb0a212) was a structural change that moved procedural content from SKILL.md files into task files. The migration correctly moved task-specific procedures (e.g., how to write a RED test, how to implement GREEN), but it also moved cross-cutting enforcement content that applies to ALL tasks within a skill — content that must be visible to every sub-agent regardless of which specific task they're executing.

The `skill()` function loads SKILL.md into the agent's context. Task files are loaded only when a sub-agent is dispatched to execute that specific task. Content in `operating-protocol.md` is loaded by no one — it sits on disk as dead content.

## Affected Files

| File | Change |
|------|--------|
| `test-driven-development/SKILL.md` | Restore Five Core Principles from `tasks/operating-protocol.md` |
| `test-driven-development/tasks/operating-protocol.md` | Remove restored content; keep only non-enforcement protocol or convert to pointer |
| `writing-plans/SKILL.md` | Restore operating protocol from `tasks/operating-protocol.md` |
| `writing-plans/tasks/operating-protocol.md` | Remove restored content |
| `writing-plans/tasks/validate.md` | Add analysis-depth checks (blast radius, SoC, decomposition, cross-cutting, full code path) |
| `writing-plans/tasks/handoffs/spec-to-plan.md` | Add analysis-depth prevention gate (alternative location) |
| `implementation-pipeline/SKILL.md` | Restore content moved to `tasks/operating-protocol.md` |
| `implementation-pipeline/tasks/operating-protocol.md` | Remove restored content |

## Fix Approach

### Phase 1: Restore Hard-Gate Content to SKILL.md Files

For each affected skill (`test-driven-development`, `writing-plans`, `implementation-pipeline`):

1. Read the current `tasks/operating-protocol.md` to identify hard-gate enforcement content
2. Read the current SKILL.md to identify where content was removed
3. Restore hard-gate content to SKILL.md in the appropriate section
4. Update `tasks/operating-protocol.md` to either:
   - Remove the restored content entirely, OR
   - Replace it with a pointer: "See SKILL.md §Operating Protocol for enforcement rules"
5. Verify the restored content is reachable via `skill()` by confirming it appears in SKILL.md

### Phase 2: Add Analysis-Depth Prevention Gate

Add a pre-creation gate to the plan creation pipeline that verifies the spec contains:

1. **Blast radius analysis** — What files/symbols are affected and what depends on them
2. **Separation of concerns** — Each concern is isolated to its own phase/item
3. **Decomposition depth** — Work is decomposed to the lowest testable level
4. **Cross-cutting concern identification** — Concerns that span multiple phases are explicitly identified
5. **Full code path exercising** — All affected code paths are enumerated

This gate fires BEFORE `writing-plans` begins creating the plan. If the spec lacks any of these analyses, the gate returns BLOCKED with a specific finding about what's missing.

**Implementation location:** Add to `writing-plans/tasks/validate.md` as new checks, OR add as a new gate in `writing-plans/tasks/handoffs/spec-to-plan.md`. The implementing agent determines the optimal location based on codebase inspection.

### Phase 3: Audit and Verify

1. Audit all `operating-protocol.md` files across all skills for hard-gate content that is not reachable via the Trigger Dispatch Table
2. For any found: either restore to SKILL.md or add a dispatch entry
3. Write behavioral enforcement tests for both regressions
4. Run the full enforcement test suite to verify no regressions

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
|----|-----------|---------------|---------------------|-------------|----------------------|--------------|-------------------------|--------------|-----------------|----------------|--------------|-------------|-----------|--------------|
| SC-1 | `test-driven-development/SKILL.md` contains the Five Core Principles including the RED/GREEN interleaving hard gate | `string` | `grep -q "RED and GREEN may NEVER be combined" test-driven-development/SKILL.md` | Restore content from operating-protocol.md | VbC | `.opencode/skills/test-driven-development/SKILL.md` | Regression 1 root cause | Phase 1 | pre-commit | exact | phase-1-restore | verify | — | Phase 1 |
| SC-2 | `test-driven-development/tasks/operating-protocol.md` no longer contains the Five Core Principles as primary content | `string` | `grep -c "Five Core Principles" test-driven-development/tasks/operating-protocol.md` returns 0 or only a pointer reference | Remove restored content from operating-protocol.md | VbC | `.opencode/skills/test-driven-development/tasks/operating-protocol.md` | Regression 1 root cause | Phase 1 | pre-commit | exact | phase-1-restore | verify | — | Phase 1 |
| SC-3 | `writing-plans/SKILL.md` contains the operating protocol content that was moved to `tasks/operating-protocol.md` | `string` | `grep` for key operating protocol phrases in SKILL.md | Restore content from operating-protocol.md | VbC | `.opencode/skills/writing-plans/SKILL.md` | Regression 1 root cause | Phase 1 | pre-commit | exact | phase-1-restore | verify | — | Phase 1 |
| SC-4 | `writing-plans/tasks/operating-protocol.md` no longer contains the restored content as primary | `string` | `grep` for restored phrases in operating-protocol.md — must be absent or reduced to a pointer | Remove restored content | VbC | `.opencode/skills/writing-plans/tasks/operating-protocol.md` | Regression 1 root cause | Phase 1 | pre-commit | exact | phase-1-restore | verify | — | Phase 1 |
| SC-5 | `implementation-pipeline/SKILL.md` contains the content that was moved to `tasks/operating-protocol.md` | `string` | `grep` for key phrases in SKILL.md | Restore content from operating-protocol.md | VbC | `.opencode/skills/implementation-pipeline/SKILL.md` | Regression 1 root cause | Phase 1 | pre-commit | exact | phase-1-restore | verify | — | Phase 1 |
| SC-6 | `writing-plans/tasks/validate.md` includes checks for all five analysis-depth dimensions | `string` | `grep` for "blast radius", "separation of concerns", "decomposition", "cross-cutting", "full code path" in validate.md | Add missing checks to validate.md | VbC | `.opencode/skills/writing-plans/tasks/validate.md` | Regression 2 root cause | Phase 2 | pre-commit | exact | phase-2-gate | verify | — | Phase 2 |
| SC-7 | A behavioral enforcement test verifies the agent interleaves RED/GREEN (not batch RED then batch GREEN) | `behavioral` | `opencode-cli run` with a multi-item TDD prompt; `assert_semantic` verifies interleaved dispatch pattern in stderr | Fix test prompt or assertion; re-run | VbC | `tmp/1836/behavioral/` | Regression 1 behavioral verification | Phase 1 | pre-commit | exact | phase-1-behavioral | verify | `.opencode/tests/behaviors/tdd-interleaving.sh` | Phase 1 |
| SC-8 | A behavioral enforcement test verifies the plan creation pipeline rejects a spec missing analysis depth | `behavioral` | `opencode-cli run` with a spec lacking analysis depth; `assert_semantic` verifies plan creation is blocked | Fix test prompt or assertion; re-run | VbC | `tmp/1836/behavioral/` | Regression 2 behavioral verification | Phase 2 | pre-commit | exact | phase-2-behavioral | verify | `.opencode/tests/behaviors/analysis-depth-gate.sh` | Phase 2 |
| SC-9 | No hard-gate enforcement content remains in any `operating-protocol.md` file that is not reachable via the Trigger Dispatch Table | `string` | Audit all `operating-protocol.md` files for hard-gate language; verify each is either in SKILL.md or has a dispatch entry | Restore or add dispatch entry | VbC | `.opencode/skills/*/tasks/operating-protocol.md` | Phase 3 audit | Phase 3 | pre-commit | exact | phase-3-audit | verify | — | Phase 3 |
| SC-10 | `implementation-pipeline/tasks/assemble-work.md` and `pipeline-executor.md` content is either restored or integrated into SKILL.md | `string` | Verify deleted content is present in SKILL.md or the files are recreated with dispatch entries | Restore content or recreate files | VbC | `.opencode/skills/implementation-pipeline/` | Regression 1 root cause | Phase 1 | pre-commit | exact | phase-1-restore | verify | — | Phase 1 |

## Edge Cases

- **operating-protocol.md contains both enforcement and non-enforcement content:** Only enforcement content is restored to SKILL.md. Non-enforcement procedural content stays in operating-protocol.md.
- **SKILL.md already has an Operating Protocol section:** Merge restored content into existing section rather than creating a duplicate.
- **A skill has no operating-protocol.md:** No action needed for that skill.
- **Content was deleted entirely (assemble-work.md, pipeline-executor.md):** The implementing agent must determine whether the deleted content contained enforcement gates. If yes, restore to SKILL.md. If no, leave deleted.

## Dependencies

- Commit bfb0a212 must be inspected to identify the exact content that was moved
- The `test-driven-development/tasks/operating-protocol.md` file must be read to identify the Five Core Principles
- The `writing-plans/tasks/operating-protocol.md` file must be read to identify the moved operating protocol
- The `implementation-pipeline/tasks/operating-protocol.md` file must be read to identify moved content

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
