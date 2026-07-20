---
title: "[SPEC-FIX] Missing task cards in spec-creation pipeline: research-card-consultation and interdependency-check"
status: draft
created: 2026-07-20
license: MIT
provenance: AI-generated
issue: 2026
authors:
  - OpenCode (ollama-cloud/deepseek-v4-flash)
---

**STATUS:** DRAFT
**CREATED:** 2026-07-20

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Problem Statement

The `spec-creation` pipeline (defined in `spec-creation/SKILL.md`) references two sub-task steps — `research-card-consultation` (step 4) and `interdependency-check` (step 20) — that have no corresponding task card files in `spec-creation-validation/tasks/`. The pipeline dispatches these steps via `task()` but the sub-agents have no task file to read, producing empty or default behavior. This is a structural defect: the pipeline contract promises dispatch targets that do not exist.

## Root Cause Analysis

The `spec-creation/SKILL.md` Trigger Dispatch Table and Pipeline section enumerate 25 steps, including steps 4 (`research-card-consultation`) and 20 (`interdependency-check`). The Step-by-Step Contract Table also documents these steps with their read/write contracts. However, the task card files were never created in `spec-creation-validation/tasks/`. The 9 existing task files (`completion.md`, `create-remote-stub.md`, `create.md`, `holistic-self-check.md`, `pipeline-readiness-gate.md`, `pre-spec-inspection.md`, `revise-remote-body.md`, `risk.md`, `traceability.md`) do not include these two.

The root cause is an oversight during the initial spec-creation-validation skill creation: the pipeline was designed with all 25 steps, but the task card files for steps 4 and 20 were not authored.

## Alternatives Considered & Why Discarded

| Alternative | Discard Rationale |
|---|---|
| Remove the steps from the pipeline | The steps serve distinct, valuable purposes — research card consultation prevents redundant research, interdependency check prevents conflicting specs. Removing them degrades pipeline quality. |
| Inline the steps in the orchestrator | Violates the orchestrator context discipline (critical-rules-034). The orchestrator MUST NOT perform inline work that should be delegated to sub-agents. |
| Merge into existing task files | Each step has a distinct purpose and contract. Merging would violate Single Concern Principle (critical-rules-042). |

## Anti-Lobotomization

Tests MUST NOT be lobotomized. Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is a CRITICAL VIOLATION. SCs must achieve 100% clean PASS. No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation. Load [Test Integrity Mandate](guidelines/080-code-standards.md).

## Interdependency

| Issue | Classification | Description |
|-------|---------------|-------------|
| [#2025](https://github.com/michael-conrad/.opencode/issues/2026) | SELF | This spec |

No blocking or related open issues identified. This is a standalone SPEC-FIX.

## Objectives

Create the two missing task card files so the `spec-creation` pipeline's sub-task dispatches for steps 4 and 20 resolve to real task files that sub-agents can execute.

## Goals

1. `research-card-consultation.md` exists in `spec-creation-validation/tasks/` with a complete task card
2. `interdependency-check.md` exists in `spec-creation-validation/tasks/` with a complete task card
3. Both task cards are structurally valid (Entry Criteria, Procedure, Exit Criteria, Result Contract)
4. The pipeline dispatches for these steps produce correct sub-agent behavior

## Non-Goals

- **Modifying the SKILL.md pipeline definition** — The pipeline already correctly references these steps. Only the task files are missing.
- **Modifying existing task cards** — No changes to the 9 existing task files.
- **Adding new pipeline steps** — This fix only adds the two missing task files, not new pipeline functionality.

## Constraints and Scope

- **Scope:** `spec-creation-validation/tasks/` only
- **Task card format:** Must follow the same structure as existing task cards in `spec-creation-validation/tasks/` (e.g., `pre-spec-inspection.md`, `risk.md`)
- **Contract alignment:** Must match the Step-by-Step Contract Table in `spec-creation/SKILL.md`
- **Sub-agent discipline:** Task cards MUST NOT contain `task()` or `skill()` calls (per critical-rules-XXX — sub-agent task cards must not contain dispatch instructions)

## Safety Considerations

No destructive operations. Adding task card files is additive only. Rollback is `git rm` of the two new files.

## Evidence/Provenance

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `ls spec-creation-validation/tasks/` | Verify task files exist |
| Direct source search | `spec-creation/SKILL.md` Pipeline section | Verify pipeline references steps 4 and 20 |
| Direct source search | `spec-creation/SKILL.md` Contract Table | Verify read/write contracts for both steps |

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `ls .opencode/skills/spec-creation-validation/tasks/` | Confirm missing files |
| Direct source search | `.opencode/skills/spec-creation/SKILL.md` | Verify pipeline and contract references |
| Direct source search | `.opencode/skills/spec-creation-validation/tasks/pre-spec-inspection.md` | Reference existing task card structure |
| Direct source search | `.opencode/skills/spec-creation-validation/tasks/risk.md` | Reference existing task card structure |

## Success Criteria

| ID | Criterion | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
|----|-----------|-------------------|-------------|----------------------|--------------|-------------------------|--------------|-----------------|----------------|--------------|-------------|-----------|--------------|
| SC-1 | `research-card-consultation.md` exists in `spec-creation-validation/tasks/` with Entry Criteria, Procedure, Exit Criteria, and Result Contract sections | `ls .opencode/skills/spec-creation-validation/tasks/research-card-consultation.md` returns a file; `grep -c "## Entry Criteria"` returns 1; `grep -c "## Procedure"` returns 1; `grep -c "## Exit Criteria"` returns 1; `grep -c "## Result Contract"` returns 1 | If missing: create the file with correct structure. If structurally incomplete: add missing sections. | create | `.opencode/skills/spec-creation-validation/tasks/research-card-consultation.md` | Root cause: missing task file | Phase 1 | pre-commit | sequential | N/A | N/A | N/A | Phase 1 |
| SC-2 | `interdependency-check.md` exists in `spec-creation-validation/tasks/` with Entry Criteria, Procedure, Exit Criteria, and Result Contract sections | `ls .opencode/skills/spec-creation-validation/tasks/interdependency-check.md` returns a file; `grep -c "## Entry Criteria"` returns 1; `grep -c "## Procedure"` returns 1; `grep -c "## Exit Criteria"` returns 1; `grep -c "## Result Contract"` returns 1 | If missing: create the file with correct structure. If structurally incomplete: add missing sections. | create | `.opencode/skills/spec-creation-validation/tasks/interdependency-check.md` | Root cause: missing task file | Phase 1 | pre-commit | sequential | N/A | N/A | N/A | Phase 1 |
| SC-3 | Both task cards match the Step-by-Step Contract Table in `spec-creation/SKILL.md` for their respective steps | Read `spec-creation/SKILL.md` contract table rows for `research-card-consultation` and `interdependency-check`; verify each task card's Result Contract fields match | If mismatch: update task card Result Contract to match SKILL.md contract table | create | `.opencode/skills/spec-creation-validation/tasks/research-card-consultation.md`, `.opencode/skills/spec-creation-validation/tasks/interdependency-check.md` | Contract alignment requirement | Phase 1 | pre-commit | sequential | N/A | N/A | N/A | Phase 1 |
| SC-4 | Neither task card contains `task()` or `skill()` calls | `grep -c "task("` returns 0; `grep -c "skill("` returns 0 for both files | If found: remove the dispatch calls; task cards must not contain dispatch instructions | create | Both task card files | critical-rules-XXX: sub-agent task cards must not contain dispatch instructions | Phase 1 | pre-commit | sequential | N/A | N/A | N/A | Phase 1 |
| SC-5 | Behavioral enforcement test exists and verifies the pipeline dispatches for these steps produce correct behavior | Behavioral test in `.opencode/tests-v2/behaviors/` sends a prompt triggering the spec-creation pipeline and asserts stderr shows correct skill dispatch for both steps | If missing: create behavioral test per RED/GREEN TDD cycle | create | `.opencode/tests-v2/behaviors/spec-creation-missing-task-cards.sh` | Behavioral test mandate per 080-code-standards.md | Phase 1 | pre-commit | sequential | N/A | N/A | N/A | Phase 1 |
| SC-6 | No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation | Audit of implementation against spec SC table | If violation found: revert and re-implement with full SC coverage | create | N/A | Anti-lobotomization mandate | Phase 1 | pre-approval-gate | sequential | N/A | N/A | N/A | Phase 1 |

## Risk and Edge Cases

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Task card structure diverges from existing convention | Low | Medium | Reference existing task cards (`pre-spec-inspection.md`, `risk.md`) as templates |
| Contract table in SKILL.md is updated but task cards are not | Low | Medium | SC-3 verifies contract alignment at creation time |
| Behavioral test cannot execute (model unavailable) | Low | High | Per 065-verification-honesty.md: report FAIL, attempt remediation, escalate only after exhaustion |

## Implementation Approach

1. Create `research-card-consultation.md` in `spec-creation-validation/tasks/` following the structure of existing task cards, with read/write contract matching the SKILL.md Step-by-Step Contract Table
2. Create `interdependency-check.md` in `spec-creation-validation/tasks/` following the same pattern
3. Write behavioral enforcement test in `.opencode/tests-v2/behaviors/`
4. Verify both files exist and are structurally valid

After this spec is approved, invoke `writing-plans` to create `.issues/2025/plan.md` before implementation begins.

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
