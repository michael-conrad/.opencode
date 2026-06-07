# Card Catalogue — Handoff Gates

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

> `.opencode/.issues/1062/spec-artifacts/cards.md`

## Spec Card

| Field | Value |
|-------|-------|
| **ID** | 1062 |
| **Title** | Handoff Gates — Spec-to-Plan, Plan-to-Pipeline, SC Close-Out, Revision Re-Entry |
| **Status** | `spec` |
| **Scope** | `handoff-gates` |
| **Dependencies** | #850, #1060, #1061 |
| **Items Covered** | 26, 27, 28, 38 |
| **Source** | `tmp/spec-output-requirements-analysis.md` |
| **Affected Repo** | `michael-conrad/.opencode` |
| **Affected Files** | `writing-plans/tasks/create.md`, `implementation-pipeline/SKILL.md`, new: `writing-plans/tasks/handoffs/spec-to-plan.md`, new: `implementation-pipeline/tasks/pre-flight-handoff.md`, new: `implementation-pipeline/tasks/sc-closeout.md` |
| **SC Count** | 16 |
| **Decomposition** | single-task |
| **Risk Count** | 4 |
| **Created** | 2026-06-07 |

## Handoff Gate Card

| Gate | Entry Criterion | Consumes From | Produces | Blocks On |
|------|----------------|---------------|----------|-----------|
| Spec-to-Plan | writing-plans entry | `spec-artifacts/`, `sc-summary.yaml`, `pre-approval-gate-contract` | `spec-to-plan-handoff-*.yaml` manifest | MISSING_SPEC_ARTIFACTS, SC_COVERAGE_MISMATCH, PRE_APPROVAL_UNSAT |
| Plan-to-Pipeline | pipeline pre-flight | Plan body, `sc-summary.yaml`, `dependency-ordering-verification/` | `plan-to-pipeline-handoff-*.yaml` manifest | MISSING_CHECKPOINT, MISSING_TRACEABILITY, DEPENDENCY_CYCLE, MISSING_SUB_ISSUES, APPROVAL_MISMATCH, GATE_DEVIATION |
| Handoff-Consistency | pipeline pre-flight | Both handoff manifests | Lifecycle manifest entry | SC_COVERAGE_MISMATCH, DECOMPOSITION_MISMATCH, PHASE_COUNT_MISMATCH |
| SC Close-Out | exec-summary | `sc-summary.yaml`, `./tmp/{issue-N}/artifacts/pipeline-*.yaml` | Issue comment SC close-out table | UNVERIFIED_SC |

## Manifest Format Card

| Key | Type | Source | Example |
|-----|------|--------|---------|
| `handoff.status` | PASS\|BLOCKED | Gate result | `PASS` |
| `handoff.artifacts_found` | int | artifact enumeration | `7` |
| `handoff.sc_summary_valid` | bool | YAML parse check | `true` |
| `handoff.pre_approval_sat` | bool | solve check | `true` |
| `handoff.solve_contracts_sat` | list[string] | solve check per contract | `[dependency-ordering-v1]` |
| `handoff.decomposition_consistent` | bool | phase binding check | `true` |
| `handoff.risk_cross_refs_valid` | bool | risk→SC mapping | `true` |
| `handoff.decision_ledger_contradictions` | string | auditor finding | `none` |
| `handoff.blocked_reason` | string\|null | failure explanation | `null` |
| `handoff.phases` | int | plan phase count | `3` |
| `handoff.total_tasks` | int | plan TDD task count | `12` |
| `handoff.red_checkpoints_present` | int | RED checkpoint count | `12` |
| `handoff.sc_ids_in_plan` | list[string] | plan TDD headings | `[SC-1, SC-2]` |
| `handoff.sc_ids_in_summary` | list[string] | sc-summary.yaml | `[SC-1, SC-2]` |
| `handoff.sc_coverage_complete` | bool | plan ↔ summary match | `true` |
| `handoff.phase_dependency_sat` | bool | solve check | `true` |
| `handoff.sub_issues_created` | list[string] | GitHub sub-issue list | `[SC-1_SC-2]` |
| `handoff.approval_cascade_applied` | string | authorization scope | `auto-approved` |

## Lifecycle Events Card

| Event | Emitted By | When |
|-------|-----------|------|
| `spec_to_plan_handoff` | writing-plans spec-to-plan task | After handoff check completes |
| `plan_to_pipeline_handoff` | implementation-pipeline pre-flight task | After handoff check completes |
| `handoff_consistency_check` | implementation-pipeline pre-flight task | After both manifests read |
| `sc_close_out` | implementation-pipeline sc-closeout task | Before exec-summary completion post |

## SC Summary Card

| ID | Requirement ID | Phase | Pipeline Step | Verification Gate | Artifact Path |
|----|---------------|-------|---------------|-------------------|---------------|
| SC-1 | REQ-ITEM-26 | 1 | rewrite-entry-criteria | pipeline-auto | `.opencode/skills/writing-plans/tasks/create.md` |
| SC-2 | REQ-ITEM-26, REQ-ITEM-38 | 1 | rewrite-entry-criteria | pipeline-auto | `.opencode/skills/writing-plans/tasks/create.md` |
| SC-3 | REQ-ITEM-26 | 1 | rewrite-task | pipeline-auto | `.opencode/skills/writing-plans/tasks/handoffs/spec-to-plan.md` |
| SC-4 | REQ-ITEM-26 | 1 | rewrite-task | pipeline-auto | `.opencode/skills/writing-plans/tasks/handoffs/spec-to-plan.md` |
| SC-5 | REQ-ITEM-27 | 1 | rewrite-task | pipeline-auto | `.opencode/skills/implementation-pipeline/tasks/pre-flight-handoff.md` |
| SC-6 | REQ-ITEM-27 | 1 | rewrite-task | pipeline-auto | `.opencode/skills/implementation-pipeline/tasks/pre-flight-handoff.md` |
| SC-7 | REQ-ITEM-38 | 1 | rewrite-task | pipeline-auto | `.opencode/skills/implementation-pipeline/tasks/pre-flight-handoff.md` |
| SC-8 | REQ-ITEM-28 | 1 | rewrite-task | pipeline-auto | `.opencode/skills/implementation-pipeline/tasks/sc-closeout.md` |
| SC-9 | REQ-ITEM-26 | 1 | rewrite-task | pipeline-auto | `.opencode/skills/writing-plans/tasks/handoffs/spec-to-plan.md` |
| SC-10 | REQ-ITEM-26 | 1 | rewrite-task | pipeline-auto | `.opencode/skills/writing-plans/tasks/handoffs/spec-to-plan.md` |
| SC-11 | REQ-ITEM-26 | 1 | rewrite-task | pipeline-auto | `.opencode/skills/writing-plans/tasks/handoffs/spec-to-plan.md` |
| SC-12 | REQ-ITEM-26 | 1 | rewrite-task | pipeline-auto | `.opencode/skills/writing-plans/tasks/handoffs/spec-to-plan.md` |
| SC-13 | REQ-ITEM-27 | 1 | rewrite-task | pipeline-auto | `.opencode/skills/implementation-pipeline/tasks/pre-flight-handoff.md` |
| SC-14 | REQ-ITEM-27 | 1 | rewrite-task | pipeline-auto | `.opencode/skills/implementation-pipeline/tasks/pre-flight-handoff.md` |
| SC-15 | REQ-ITEM-26, REQ-ITEM-38 | 1 | rewrite-entry-criteria | pipeline-auto | `.opencode/skills/writing-plans/tasks/create.md` |
| SC-16 | REQ-ITEM-27, REQ-ITEM-38 | 1 | rewrite-skill | pipeline-auto | `.opencode/skills/implementation-pipeline/SKILL.md` |

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)