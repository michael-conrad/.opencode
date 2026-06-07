# [SPEC] Handoff Gates — Spec-to-Plan, Plan-to-Pipeline, SC Close-Out, Revision Re-Entry

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

> **Spec folder:** `.opencode/.issues/1062/`

## Intent and Executive Summary

Add four mandatory verification gates to the plan-writing and pipeline-execution workflow that validate handoff integrity between pipeline stages. Each gate reads structured artifacts from the previous stage and validates completeness, consistency, and traceability before the next stage begins. The gates catch structural defects — missing artifacts, SC-ID mismatches, decomposition inconsistencies, unverified success criteria — at the handoff boundary instead of at pipeline step 10 (adversarial audit) or step 14 (exec-summary).

**Decomposition Classification:** single-task (one spec, one concern: handoff integrity verification)

## Objective

Prevent structural handoff defects from propagating silently through the pipeline. A spec with missing artifacts reaches the plan author; a plan with untracked SC-IDs reaches the pipeline; an implementation with unverified SCs reaches exec-summary and is closed as "done." Each handoff gate catches the defect at the boundary, returning BLOCKED + a structured manifest documenting what was missing, instead of letting the defect surface 5-14 pipeline steps later.

## Problem

The current pipeline has no structural integrity verification at three critical handoff boundaries:

1. **Spec → Plan:** The plan author reads the spec and starts writing. There is no verification that the spec's SC table is complete, that `sc-summary.yaml` (if it exists) matches the prose table, that pre-approval gate confirmed SAT, or that solve contracts are valid. A plan written against a structurally defective spec produces downstream SCHEDULING rework at pipeline step 10.

2. **Plan → Pipeline:** The pipeline dispatches to sc-coherence-gate with no verification that the plan has RED checkpoints for every TDD task, that every SC-ID in the plan maps to the spec's SC table, that phase dependency solve contracts return SAT, or that sub-issues exist for multi-phase decompositions. A structurally incomplete plan reaches the pipeline and fails at step 1 or step 3.

3. **Implementation → Close-Out:** The pipeline's exec-summary step posts a completion comment without verifying that every SC-ID from the spec's SC table received at least one PASS verdict. Unverified SCs slip through as "done" — discovered only when the next pipeline stage fails or when a downstream consumer reports missing behavior.

4. **Cross-handoff consistency:** There is no check that the spec-to-plan and plan-to-pipeline handoffs agree on shared variables (SC count, decomposition type, phase count). If one handoff used an outdated spec version, the inconsistency is invisible.

## Context

Items 26, 27, 28, and 38 from the requirements analysis (`tmp/spec-output-requirements-analysis.md`) define four handoff gates. Items 26 and 38 affect `writing-plans` entry criteria; items 27 and 38 affect `implementation-pipeline` pre-flight. Items 26, 27, and 38 are structural/gate checks — they verify artifact completeness and consistency without model calls. Item 28 is a post-hoc verification that runs at pipeline completion.

These gates depend on:
- #1060: SC Coverage Summary infrastructure (`sc-summary.yaml`, `spec-artifacts/` directory convention)
- #1061: Solve contract infrastructure (`dependency-ordering-verification/`, `solve check` integration)

Without #1060, the spec-to-plan handoff cannot verify SC-ID coverage (check 2, 5, 7). Without #1061, the plan-to-pipeline handoff cannot verify phase dependency ordering (check 5).

## Affected Files

### Writing-plans

| File | Change |
|------|--------|
| `writing-plans/tasks/create.md` | Add spec-to-plan handoff verification as entry criterion (precondition before `create/plan-structure`); add handoff-consistency check as substep in `create/create-and-validate` |

### Implementation-pipeline

| File | Change |
|------|--------|
| `implementation-pipeline/SKILL.md` | Add plan-to-pipeline handoff verification as pre-flight step before `sc-coherence-gate` dispatcher; add handoff-consistency check as pre-flight substep |

### New Artifacts

| File | Purpose |
|------|---------|
| `.opencode/skills/writing-plans/tasks/handoffs/spec-to-plan.md` | Spec-to-plan handoff verification task file |
| `.opencode/skills/implementation-pipeline/tasks/pre-flight-handoff.md` | Plan-to-pipeline handoff + handoff-consistency check task file |
| `.opencode/skills/implementation-pipeline/tasks/sc-closeout.md` | SC close-out verification task file (referenced by exec-summary step) |

## Non-Goals

- Not modifying the SC table format, evidence-type taxonomy, or verification-gate definitions — those are spec-level concerns covered by #1060
- Not adding new pipeline steps to the 14-step routing table — handoff gates integrate as pre-flight substeps or entry criteria, not as new dispatch entries
- Not implementing revision re-entry protocol (item 29) — that is a separate dependency

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Remediation | Re-Entry Step |
|----|-----------|---------------|---------------------|-------------|---------------|
| SC-1 | writing-plans entry criteria includes spec-to-plan handoff with PASS condition | `structural` | Read `writing-plans/tasks/create.md`; confirm entry criteria section includes spec-to-plan handoff as precondition | Add precondition line to entry criteria | rewrite-entry-criteria |
| SC-2 | writing-plans create-and-validate includes handoff-consistency substep | `structural` | Read `writing-plans/tasks/create.md`; confirm create-and-validate procedure references handoff-consistency check | Add substep reference to create-and-validate procedure | rewrite-entry-criteria |
| SC-3 | Spec-to-plan handoff enumerates expected artifacts and validates SC summary YAML | `string` | Grep `writing-plans/tasks/handoffs/spec-to-plan.md` for artifact enumeration key (`sc-summary`) and YAML validation key (`parse`, `valid`) | Add missing artifact or validation check | rewrite-task |
| SC-4 | Spec-to-plan handoff writes manifest at `./tmp/{issue-N}/artifacts/spec-to-plan-handoff-*.yaml` with PASS/BLOCKED status | `string` | Grep `writing-plans/tasks/handoffs/spec-to-plan.md` for manifest path pattern (`spec-to-plan-handoff`) and status field pattern (`status:` or `PASS`|`BLOCKED`) | Add manifest write step with status field | rewrite-task |
| SC-5 | Plan-to-pipeline handoff validates every TDD task has RED checkpoint with failure condition | `string` | Grep `implementation-pipeline/tasks/pre-flight-handoff.md` for RED checkpoint validation key (`red_checkpoint`, `failure_condition`, `MISSING-CHECKPOINT`) and SC-ID traceability key (`sc_ids_in_plan`, `sc_ids_in_summary`, `MISSING-TRACEABILITY`) | Add RED checkpoint validation substep; add SC-ID traceability substep | rewrite-task |
| SC-6 | Plan-to-pipeline handoff writes manifest at `./tmp/{issue-N}/artifacts/plan-to-pipeline-handoff-*.yaml` with PASS/BLOCKED status | `string` | Grep `implementation-pipeline/tasks/pre-flight-handoff.md` for manifest path pattern (`plan-to-pipeline-handoff`) and status field pattern | Add manifest write step with status field | rewrite-task |
| SC-7 | Implementation-pipeline pre-flight includes handoff-consistency check that reads both manifests and compares shared variables | `string` | Grep `implementation-pipeline/tasks/pre-flight-handoff.md` for cross-manifest comparison patterns: (`sc_coverage_total` OR `sc_coverage`) AND (`decomposition_classification` OR `decomposition`) AND (`phase_count` OR `phases`) AND `BLOCK` | Add cross-manifest comparison substep for each shared variable | rewrite-task |
| SC-8 | SC close-out verification runs at exec-summary step and blocks issue closure on UNVERIFIED SCs | `string` | Grep `implementation-pipeline/tasks/sc-closeout.md` for patterns: (`exec-summary` or `exec_summary`) AND (`UNVERIFIED` or `blocker` or `BLOCK`) AND (`sc-summary` or `sc_summary` or `pipeline-*.yaml` or `Pipeline Step`) | Add SC close-out procedure; ensure it blocks on UNVERIFIED | rewrite-task |
| SC-9 | Spec-to-plan handoff preconditions exist: (a) spec is approved, (b) `spec-artifacts/` directory exists, (c) `sc-summary.yaml` exists and parses | `string` | Grep `writing-plans/tasks/handoffs/spec-to-plan.md` for precondition patterns: (`spec approved` or `approved spec`) AND (`spec-artifacts` or `spec_artifacts`) AND (`sc-summary.yaml` or `sc_summary` or `valid YAML` or `parse`) | Add missing precondition check to entry criteria | rewrite-task |
| SC-10 | Spec-to-plan handoff validates every RISK-ID with Verifying SC maps to existing SC-ID in `sc-summary.yaml` | `string` | Grep `writing-plans/tasks/handoffs/spec-to-plan.md` for risk cross-reference patterns: (`RISK` or `risk_cross_refs` or `risk.*SC` or `Verifying SC`) AND (`sc-summary` or `sc_summary` or `SC-ID` or `scs[].id`) | Add risk traceability cross-ref substep | rewrite-task |
| SC-11 | Spec-to-plan handoff validates decision ledger has no detected contradictions from spec-auditor | `string` | Grep `writing-plans/tasks/handoffs/spec-to-plan.md` for decision ledger patterns: (`decision_ledger` or `decision.*contradict` or `DEC-ID`) AND (`none` or `detected` or `auditor`) | Add decision ledger contradiction check substep | rewrite-task |
| SC-12 | Spec-to-plan handoff validates decomposition classification is consistent with SC-to-phase bindings | `string` | Grep `writing-plans/tasks/handoffs/spec-to-plan.md` for decomposition consistency patterns: (`decomposition_consistent` or `decomposition.*classification` or `single-task` or `multi-phase`) AND (`phase bind` or `scs[].phase` or `all SCs in phase` or `SCs distributed`) | Add decomposition consistency substep | rewrite-task |
| SC-13 | Plan-to-pipeline handoff validates approval cascade state matches authorization scope | `string` | Grep `implementation-pipeline/tasks/pre-flight-handoff.md` for approval validation patterns: (`approval_cascade` or `approval.*match` or `APPROVAL-MISMATCH`) AND (`authorization_scope` or `authorization context` or `halt_at`) | Add approval cascade validation substep | rewrite-task |
| SC-14 | Plan-to-pipeline handoff validates every Verification Gate from spec is preserved in plan TDD steps | `string` | Grep `implementation-pipeline/tasks/pre-flight-handoff.md` for verification gate preservation patterns: (`Verification Gate` or `verification_gate` or `GATE-DEVIATION`) AND (`preserved` or `preserv` or `match` or `deviation`) | Add verification gate preservation check substep | rewrite-task |
| SC-15 | writing-plans entry criteria includes handoff-consistency check reference | `structural` | Read `writing-plans/tasks/create.md`; confirm create-and-validate references handoff-consistency check | Add substep reference to create-and-validate | rewrite-entry-criteria |
| SC-16 | Implementation-pipeline SKILL.md pre-flight section references plan-to-pipeline handoff before sc-coherence-gate | `structural` | Read `implementation-pipeline/SKILL.md`; confirm pre-flight procedures reference plan-to-pipeline handoff AND handoff-consistency check | Add pre-flight section to SKILL.md or update dispatch routing table notes | rewrite-skill |

## Dependencies

| Dependency | Required For | Status |
|------------|-------------|--------|
| #850 | Parent coordination — spec-to-plan and plan-to-pipeline handoff scope definition | Approved |
| #1060 | SC coverage summary (`sc-summary.yaml`) + spec-artifacts directory convention — consumed by spec-to-plan and plan-to-pipeline handoff checks | In progress |
| #1061 | Solve contract infrastructure (`dependency-ordering-verification/`, `solve check`) — consumed by plan-to-pipeline phase dependency check | In progress |

Both #1060 and #1061 must be merged before the handoff gate task files can be written — the handoff checks depend on artifacts those specs define.

## Edge Cases

| Case | Handling |
|------|----------|
| Spec has no `spec-artifacts/` directory (pre-#1060) | Handoff returns BLOCKED with reason: `MISSING_SPEC_ARTIFACTS`. The spec author must create artifacts per #1060 before the handoff can pass |
| Plan has no sub-issues (single-task decomposition) | Plan-to-pipeline handoff skips sub-issue check — single-task plans are exempt per `issue-operations` skill |
| Handoff manifests from a prior execution exist | Each handoff writes a new timestamped manifest; prior manifests are preserved until cleanup (artifacts/handoff-consistency check reads the latest manifest per step) |
| Spec revision occurs after spec-to-plan handoff passed | The handoff is invalidated — plan author must re-run spec-to-plan handoff after spec revision per #1062's revision policy |
| Plan-to-pipeline handoff detects SC-IDs in plan that don't exist in `sc-summary.yaml` | BLOCKED with MISSING-TRACEABILITY finding. Plan author must fix TDD task SC-ID references |
| SC close-out finds UNVERIFIED SCs at exec-summary | Blocks issue closure. Pipeline executor posts BLOCKER finding in the issue comment; remediation required before cleanup |
| Handoff-consistency check shows mismatch (e.g., spec-to-plan says 8 SCs, plan-to-pipeline says 6) | BLOCK the pipeline. The spec or plan was revised between handoffs; orchestrator must re-run spec-to-plan handoff and/or plan-to-pipeline handoff |

## Risk

| ID | Risk | Likelihood | Impact | Mitigation | Verifying SC | Pipeline Step |
|----|------|-----------|--------|------------|-------------|---------------|
| RISK-1 | Handoff manifests reference outdated SC-IDs after spec revision | Medium | High | Lifecycle manifest tracks spec revision; handoff checks fail when `spec-artifacts/` has newer timestamps than handoff manifest | SC-9, SC-13 | pre-flight (plan-to-pipeline) |
| RISK-2 | SC close-out at exec-summary cannot find artifact files (deleted by prior cleanup) | Low | High | Artifact retention policy exempts `./tmp/{issue-N}/` from pre-cleanup until PR merge; SC close-out runs before git-workflow cleanup | SC-8 | exec-summary |
| RISK-3 | Handoff task files grow beyond 3,000 word limit | Medium | Low | Each handoff is a separate task file with single concern; if any exceeds 3,000 words, split into substep task files | — | — |
| RISK-4 | Plan-to-pipeline handoff blocks on false-positive (plan structurally correct but handoff parsing fails) | Low | Medium | Handoff manifest format includes `blocked_reason` field with exact parsing failure; orchestrator can inspect and remediate | SC-5, SC-6 | pre-flight (plan-to-pipeline) |

## Documentation Sources

| Source | Content | Verified |
|--------|---------|----------|
| `tmp/spec-output-requirements-analysis.md` Lines 341-382 | Item 26: Spec-to-Plan Handoff Integrity Verification | Read |
| `tmp/spec-output-requirements-analysis.md` Lines 384-416 | Item 27: Plan-to-Pipeline Handoff Integrity Verification | Read |
| `tmp/spec-output-requirements-analysis.md` Lines 418-442 | Item 28: Post-Implementation SC Close-Out Verification | Read |
| `tmp/spec-output-requirements-analysis.md` Lines 708-717 | Item 38: Handoff-Consistency Check | Read |
| `.opencode/skills/writing-plans/tasks/create.md` | Entry criteria section — current preconditions | Read |
| `.opencode/skills/implementation-pipeline/SKILL.md` | Dispatch routing table — pre-flight is implicit before step 1 | Read |
| `.opencode/skills/implementation-pipeline/tasks/` | Task directory — contains only `pipeline-executor.md` | Read |

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)