---
number: 2225
title: "[SPEC] Spec-creation pipeline: validate/create task defects and reference-document loading rules"
status: open
labels: []
created: 2026-08-01T23:30:00Z
updated: 2026-08-01T23:30:00Z
remote_issue: 2225
remote_url: "https://github.com/michael-conrad/.opencode/issues/2225"
promoted_at: 2026-08-01T23:30:00Z
promotion_type: retroactive_import
last_sync: 2026-08-01T23:30:00Z
author: michael-conrad
approved: true
authorization_scope: for_pr
---

> **Full spec and artifacts: [`.opencode/.issues/2225/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2225)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2225/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Intent and Executive Summary

### Problem Statement

The spec-creation pipeline has 12 structural defects identified during the spec audit and remediation of #2223. These defects cause specs to pass the pipeline's own validation but fail independent audit, requiring multiple remediation cycles. The root cause is a systematic pattern: task files hardcode reference-dependent criteria instead of loading them dynamically from canonical reference documents, and the validate task lacks structured procedures for format-level, determinism, and consistency checks that the audit performs.

### Root Cause/Motivation

The spec-creation pipeline was built incrementally. The create task was written to load `spec-structure-standards.md` dynamically, but the validate task was written with a hardcoded inline section list that drifted from the canonical reference. Format-level rules (SHALL language, dark-prose-007 pattern, SC determinism) were never incorporated into either task because the reference documents existed but the task files had no mechanism to load and apply them. The validate→revise loop has no iteration limit or tiered escalation, so a spec with structural defects can cycle indefinitely without converging.

### Approach Chosen

Add a rule to `task-card-structure-standards.md` requiring dynamic loading of reference-dependent criteria. Fix `create.md` to load and apply all format-level rules from reference documents during assembly. Fix `validate.md` to load section inventory dynamically, add structured checks for determinism, compound-SCs, causal-chain verification, evidence-type-to-method cross-check, and artifact cross-reference. Add tiered escalation to the validate→revise loop. Fix the artifact lifecycle: create copies artifacts to `.issues/{N}/artifacts/`, audit investigator auto-backfills if missing.

### Alternatives Considered & Why Discarded

- **Add a separate validation skill**: Discarded because the validate task already exists in spec-creation. Adding a new skill duplicates infrastructure.
- **Make the audit the only quality gate**: Discarded because catching defects at audit time is more expensive than catching them at pipeline time. The pipeline should validate its own output.
- **Keep hardcoded lists but add a sync check**: Discarded because a sync check is the same work as dynamic loading, with the added risk of the sync check itself drifting.

### Key Design Decisions

1. **Dynamic loading from reference documents**: Task files use `Read [Text](path)` to load criteria at runtime, not hardcoded lists. This is enforced by a new rule in `task-card-structure-standards.md`.
2. **Tiered escalation in validate→revise loop**: After 3 iterations, dispatch a structural diagnostic. If that fails, escalate to user. This prevents infinite loops on unfixable specs.
3. **Artifact lifecycle**: create copies artifacts to `.issues/{N}/artifacts/`. revise no longer deletes them (the audit investigator's pre-flight handles staleness). The investigator auto-backfills if artifacts are missing.
4. **Structured procedures over subjective dimensions**: Every validate dimension that says "check X" has an executable procedure, not a subjective judgment call.

### User Intent/Original Prompt

Fix the spec-creation pipeline's validate and create tasks so they load criteria dynamically from reference documents, apply format-level rules during assembly, and catch structural defects before audit.

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| `task-card-structure-standards.md` | Reference | `.opencode/reference/task-card-structure-standards.md` | Contains task card format rules |
| `spec-structure-standards.md` | Reference | `.opencode/reference/spec-structure-standards.md` | Contains required sections, format rules, prohibited patterns |
| `cost-model-standards.md` | Reference | `.opencode/reference/cost-model-standards.md` | Contains dark-prose-007 pattern |
| `create.md` | Task file | `.opencode/skills/spec-creation/tasks/create.md` | Spec assembly task — needs format-level reference loading |
| `validate.md` | Task file | `.opencode/skills/spec-creation/tasks/validate.md` | Spec validation task — needs dynamic section loading + structured checks |
| `revise.md` | Task file | `.opencode/skills/spec-creation/tasks/revise.md` | Spec revision task — remove stale artifact deletion |
| `spec-creation/SKILL.md` | Skill card | `.opencode/skills/spec-creation/SKILL.md` | Pipeline sequence — needs tiered escalation |
| `spec-audit-investigator.md` | Task file | `.opencode/skills/audit/tasks/spec-audit-investigator.md` | Audit investigator — needs artifact pre-flight gate |
| `analyze.md` | Task file | `.opencode/skills/spec-creation/tasks/analyze.md` | Pre-spec analysis — produces analytical artifacts |

## Cost Frame

Implementation cost is measured in defect-discovery latency, not tool-call count.

- **SC-1**: Adding a rule to task-card-structure-standards.md costs one paragraph of text. Skipping it costs every future task file drifting from its reference documents. Correctness is the only success metric — there is no score for speed.
- **SC-2 through SC-12**: Each task file edit costs 1-5 text replacement or addition operations. Each operation is a discovery point where a stale reference or missing check would be caught. Skipping any SC costs a spec that passes pipeline validation but fails audit. Correctness is the only success metric — there is no score for speed.

## Enforcement Gate

**All-or-nothing:** This spec's success criteria are individually verifiable but collectively required. No SC may be skipped, deferred, or weakened. If any SC cannot be implemented, the entire spec is BLOCKED and must be reported as such. Partial implementation is not an acceptable outcome.

## Not Included

- Changes to the DiMo 4-role chain audit pipeline itself
- Changes to the spec-audit evaluator, validator, or arbiter tasks
- Behavioral enforcement tests for validate.md (separate spec)
- Any changes to the brainstorming skill or its task files
- Any changes to the writing-plans skill or its task files

## Requirements

| ID | Requirement |
|----|-------------|
| REQ-1 | Task card structure standards SHALL require dynamic loading of reference-dependent criteria via `Read [Text](path)` |
| REQ-2 | `create.md` SHALL load and apply all format-level rules from `spec-structure-standards.md` and `cost-model-standards.md` during assembly |
| REQ-3 | `validate.md` SHALL load required section inventory dynamically from `spec-structure-standards.md` |
| REQ-4 | `validate.md` SHALL have structured checks for format-level conformance (SHALL language, dark-prose-007, Documentation Sources columns) |
| REQ-5 | `validate.md` SHALL have a structured determinism check with prohibited pattern list from `spec-structure-standards.md` |
| REQ-6 | `validate.md` SHALL have a structured compound-SC detection procedure |
| REQ-7 | `validate.md` SHALL verify the causal chain: every root cause maps to at least one SC, every SC maps to at least one root cause |
| REQ-8 | `validate.md` SHALL have a verification-method-to-evidence-type cross-check lookup table |
| REQ-9 | `validate.md` SHALL cross-reference spec against analytical artifacts for consistency |
| REQ-10 | `spec-creation/SKILL.md` SHALL document tiered escalation in the validate→revise loop (3 iterations → structural diagnostic → user) |
| REQ-11 | `create.md` SHALL copy analytical artifacts from `tmp/` to `.issues/{N}/artifacts/` |
| REQ-12 | `spec-audit-investigator.md` SHALL have a pre-flight gate checking analytical artifact presence, returning REMEDIATION_REQUIRED with backfill dispatch if missing |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `task-card-structure-standards.md` contains a rule: any task that validates against reference-dependent criteria MUST load those criteria dynamically via `Read [Text](path)` from the canonical reference document. Hardcoded inline lists that duplicate reference content are prohibited. | string | grep for "reference-dependent criteria" and "Read [Text]" in task-card-structure-standards.md |
| SC-2 | `create.md` Step 2 loads `spec-structure-standards.md` and `cost-model-standards.md` and applies all format-level rules during assembly (SHALL language, dark-prose-007 pattern, SC determinism, Documentation Sources columns) | string | grep for "Read [spec-structure-standards.md]" and "Read [cost-model-standards.md]" in create.md |
| SC-3 | `validate.md` loads required section inventory dynamically from `spec-structure-standards.md` via `Read [Text](path)` instead of hardcoding the section list | string | grep for "Read [spec-structure-standards.md]" in validate.md; no hardcoded section list in entry criteria or procedure |
| SC-4 | `validate.md` has structured checks for format-level conformance: REQs use SHALL not must, Cost Frame uses dark-prose-007 pattern, Documentation Sources has all 4 columns | string | grep for "SHALL" and "dark-prose-007" and "Documentation Sources" in validate.md procedure |
| SC-5 | `validate.md` has a structured determinism check that checks each SC against the prohibited pattern list from `spec-structure-standards.md` (TBD, TODO, "use best judgment", "if time permits", "implementor's discretion", escape hatches, ambiguity markers) | string | grep for prohibited patterns list in validate.md |
| SC-6 | `validate.md` has a structured compound-SC detection procedure that checks for conjunctions, multiple verification targets, and cross-concern references in each SC criterion | string | grep for "compound" or "conjunction" or "multiple verification" in validate.md |
| SC-7 | `validate.md` verifies the causal chain: every root cause in the problem statement is addressed by at least one SC, and every SC traces to at least one root cause. Reports orphan root causes and orphan SCs as FAIL. | string | grep for "causal chain" or "root cause" in validate.md |
| SC-8 | `validate.md` has a verification-method-to-evidence-type cross-check lookup table: behavioral→test execution, semantic→sub-agent read, string→grep, structural→file existence | string | grep for lookup table mapping evidence types to verification methods in validate.md |
| SC-9 | `validate.md` cross-references spec against analytical artifacts: blast-radius→Affected Files, concern-map→phases, interface-compatibility→breaking changes, testability-assessment→SC evidence types | string | grep for "blast-radius" or "concern-map" or "interface-compatibility" in validate.md |
| SC-10 | `spec-creation/SKILL.md` Workflows section documents tiered escalation: after 3 validate→revise iterations, dispatch structural diagnostic; if that fails, escalate to user | string | grep for "tiered escalation" or "structural diagnostic" in spec-creation SKILL.md |
| SC-11 | `create.md` copies analytical artifacts from `tmp/{issue_number}/artifacts/` to `.issues/{N}/artifacts/` as part of its exit criteria | string | grep for "copy" and "artifacts" in create.md exit criteria |
| SC-12 | `spec-audit-investigator.md` Step 1 (Pre-Flight Validation Gate) checks for analytical artifact presence at `{analytical_artifact_dir}` and returns REMEDIATION_REQUIRED with backfill dispatch if missing | string | grep for "analytical_artifact_dir" and "REMEDIATION_REQUIRED" in spec-audit-investigator.md |

## Items

1. Add dynamic-loading rule to `task-card-structure-standards.md` (SC-1)
2. Update `create.md` to load and apply format-level rules from reference documents (SC-2)
3. Update `validate.md` to load section inventory dynamically (SC-3)
4. Add format-level conformance checks to `validate.md` (SC-4)
5. Add structured determinism check to `validate.md` (SC-5)
6. Add compound-SC detection to `validate.md` (SC-6)
7. Add causal-chain verification to `validate.md` (SC-7)
8. Add evidence-type-to-method cross-check to `validate.md` (SC-8)
9. Add artifact cross-reference check to `validate.md` (SC-9)
10. Add tiered escalation to `spec-creation/SKILL.md` (SC-10)
11. Add artifact copy to `create.md` exit criteria (SC-11)
12. Add artifact pre-flight gate to `spec-audit-investigator.md` (SC-12)

## Dependencies

- #2223 (this spec was discovered during its audit/remediation cycle)
- spec-audit DiMo 4-role chain must already be implemented (prerequisite for SC-12)

## Traceability

| REQ | SCs | Phase |
|-----|-----|-------|
| REQ-1 | SC-1 | Phase 1 |
| REQ-2 | SC-2 | Phase 2 |
| REQ-3 | SC-3 | Phase 3 |
| REQ-4 | SC-4 | Phase 3 |
| REQ-5 | SC-5 | Phase 3 |
| REQ-6 | SC-6 | Phase 3 |
| REQ-7 | SC-7 | Phase 3 |
| REQ-8 | SC-8 | Phase 3 |
| REQ-9 | SC-9 | Phase 3 |
| REQ-10 | SC-10 | Phase 4 |
| REQ-11 | SC-11 | Phase 2 |
| REQ-12 | SC-12 | Phase 5 |

## Edge Cases

- **Task file already has dynamic loading**: If `create.md` or `validate.md` already loads from reference documents, the SC still applies — verify the loading is complete (all format rules, not just section names).
- **Reference document doesn't exist**: If `cost-model-standards.md` or another reference is missing, the SC is BLOCKED until the reference is created. Report and escalate.
- **Spec has no analytical artifacts**: SC-9 (artifact cross-reference) is N/A for specs that skipped the analyze step. The validate task should handle this gracefully.
- **Spec has no problem statement with root causes**: SC-7 (causal chain) is N/A for specs that don't have a structured problem statement. The validate task should handle this gracefully.
- **Spec-audit-investigator already has artifact check**: If the pre-flight gate already exists, SC-12 still applies — verify it returns REMEDIATION_REQUIRED (not just BLOCKED) and includes backfill dispatch context.
