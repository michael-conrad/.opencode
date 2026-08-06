> **Full spec and artifacts: [`.opencode/.issues/2250/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2250)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2250/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# SPEC — Remediate spec-writer and spec-audit skill card set inconsistencies

## 1. Intent and Executive Summary

### Problem Statement

A read-only audit of the spec-writer and spec-audit skill card sets (`spec-creation`, `writing-plans`, `audit`) and the consolidated reference standards (`.opencode/reference/`) identified 8 internal-consistency defects. Each defect is a drift between what a skill card or task card declares (its reference paths, artifact locations, result-contract schema, task references, and structure) and the actual on-disk reality of its task files, contracts, and reference documents. These drifts cause agents to resolve cross-references to non-existent files, write analytical artifacts to inconsistent locations, return result contracts the orchestrator cannot parse, and dispatch nonexistent tasks — producing defective specs, plans, and audits.

### Root Cause / Motivation

The skill cards accumulated stale content as the underlying task files, contracts, and reference documents were migrated to a consolidated `.opencode/reference/` location and a flat Workflows-style SKILL.md structure. The cards were not kept in sync with those migrations. Because agent-facing text is consumed as routing instructions, each drift is a defect vector: a card that points at a deleted file, mandates an unimplemented artifact, or returns a contract field the orchestrator does not read causes agents to route blind. These defects must be resolved now because they compound — every spec written or audited through the affected cards inherits the inconsistency.

### Approach Chosen

Apply exactly ONE prescriptive resolution per defect, each mapped one-to-one to a success criterion (SC-1–SC-10). The changes are confined to agent-facing skill/reference files (markdown/yaml) in `.opencode/` — no `src/` code changes. The work is decomposed into three concern-coherent phases: (1) reference-path and artifact-path remediation in `spec-creation`, (2) reference-path and stale-reference remediation in `writing-plans`, (3) structural migration and contract alignment in `audit`, followed by structure-standard reconciliation.

### Alternatives Considered & Why Discarded

- **Full rewrite of the skill cards** — discarded: the cards are largely correct; only 8 discrete drifts exist. A rewrite risks introducing new inconsistencies and loses the audit's precision.
- **Deferring to a future consolidation** — discarded: the drifts actively misroute agents today; deferral compounds the defect cost.
- **Single monolithic fix commit** — discarded: violates per-SC TDD decomposition; each defect is independently verifiable and must be implemented as its own RED/GREEN/commit cycle.

### Key Design Decisions

- **Consolidated `.opencode/reference/` as single source of truth:** all agent-facing `Read [Text](path)` targets resolve to existing canonical files under `.opencode/reference/`, not skill-local `reference/` dirs. This eliminates the broken relative-path defects (SC-1, SC-4).
- **`artifacts/` as the uniform analytical-artifact location:** `spec-creation/tasks/analyze.md` writes all outputs to `artifacts/`, eliminating the `contracts/` vs `artifacts/` mismatch (SC-2).
- **Flat Workflows-style SKILL.md structure:** the legacy `audit` SKILL.md TDT/Invocation/DISPATCH_GATE structure is migrated to a Workflows section while preserving the role-split DiMo 4-role dispatch (SC-6).
- **`finding_summary` result-contract schema:** audit sub-agent contracts use `finding_summary` (not `summary`) and the status enum includes `FAIL` (SC-7).
- **Current task references:** stale `approval-gate --task verify-authorization` and `sc-summary.yaml` references are replaced with current equivalents (SC-8, SC-9).
- **Reconciled plan/spec structure standards:** `reference/spec-structure-standards.md` and `reference/plan-structure-standards.md` are reconciled non-substantively for consistency (SC-10).

### User Intent / Original Prompt

The user requested execution of the `create` task from `spec-creation`, producing a remediation spec covering 8 internal-consistency defects in the spec-writer and spec-audit skill card sets (`spec-creation`, `writing-plans`, `audit`) and associated reference docs, based on the analysis artifacts produced by the completed `analyze` step.

## 2. Not Included

- **Runtime code changes** — Rationale: all defects concern agent-facing skill/reference files; no `src/` code is modified.
- **Change to spec-creation's 4-task pipeline topology** — Rationale: the analyze/create/validate/revise pipeline is unchanged; only its reference paths and artifact locations are corrected.
- **Collapse of audit DiMo role chains** — Rationale: the change is a structural migration, not role simplification; the 4-role dispatch is preserved.
- **Change to the consolidated reference standards content** — Rationale: the reference standards are the canonical target; only internal inconsistencies between them are reconciled (SC-10), not re-defined.
- **Behavioral-enforcement-test work** — Rationale: this spec remediates skill-card/task-card structure only; structural/string SCs are expected.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `spec-creation` task cards (`create.md`, `validate.md`) resolve all relative `reference/` paths to existing consolidated `.opencode/reference/` files | structural | grep `skills/spec-creation/tasks/{create,validate}.md` for `Read [.*](reference/` returns only `.opencode/reference/` targets that resolve to existing files |
| SC-2 | `spec-creation/tasks/analyze.md` writes all outputs to consistent `artifacts/` paths; no `contracts/` path remains | string | grep `skills/spec-creation/tasks/analyze.md` for `contracts/` returns zero; all output writes under `artifacts/` |
| SC-3 | `sc-table-columns.md` is removed from `skills/spec-creation/reference/`; any canonical content is merged into `reference/spec-structure-standards.md` | string | grep across `.opencode` for `sc-table-columns` returns zero consumers; `skills/spec-creation/reference/sc-table-columns.md` absent |
| SC-4 | `writing-plans` task cards resolve all relative `reference/` paths to existing consolidated `.opencode/reference/` files | structural | grep `skills/writing-plans/tasks/create.md` for `Read [.*](reference/` returns only `.opencode/reference/` targets that resolve to existing files |
| SC-5 | `plan-artifact-format.md` is removed from the `writing-plans/SKILL.md` file structure and deleted from `skills/writing-plans/reference/`; any canonical content is merged into `reference/plan-structure-standards.md` | string | grep `skills/writing-plans/SKILL.md` for `plan-artifact-format` returns zero; `skills/writing-plans/reference/plan-artifact-format.md` absent |
| SC-6 | `audit/SKILL.md` migrated to flat Workflows structure (replaces TDT/Invocation/DISPATCH_GATE) while preserving role-split DiMo dispatch | structural | read `skills/audit/SKILL.md`; assert a Workflows section exists, TDT/Invocation/DISPATCH_GATE sections are replaced, and role-chain dispatch strings are preserved |
| SC-7 | audit sub-agent result contracts use `finding_summary` (not `summary`); status enum includes `FAIL` | string | grep `skills/audit/tasks/` for `summary:` in result-contract blocks returns zero; `finding_summary:` present; status enum includes `FAIL` |
| SC-8 | stale `verify-authorization` task reference replaced with the current approval-gate task | string | grep `skills/writing-plans/tasks/handoff.md`, `skills/audit/tasks/completion.md` for `verify-authorization` returns zero; current approval-gate task used |
| SC-9 | stale `sc-summary.yaml` reference replaced with `analysis-summary.yaml` | string | grep `skills/writing-plans/tasks/research.md`, `skills/spec-creation/tasks/create.md` for `sc-summary` returns zero; `analysis-summary.yaml` used |
| SC-10 | plan/spec structure standards reconciled (spec Items/SC table consistent with plan phase decomposition; single source of truth in `reference/`) | structural | cross-check `reference/spec-structure-standards.md` and `reference/plan-structure-standards.md` for consistent section/column definitions; no divergent structure specs remain |

## 4. Requirements

- R-1. All agent-facing `Read [Text](path)` cross-references in the affected skill cards SHALL resolve to existing canonical files under `.opencode/reference/`.
- R-2. `spec-creation/tasks/analyze.md` SHALL write all analytical-artifact outputs to a single `artifacts/` location.
- R-3. Orphaned or stale reference documents (`sc-table-columns.md`, `plan-artifact-format.md`) SHALL be removed or repurposed so no dead file remains.
- R-4. The `audit` skill card SHALL use the flat Workflows-style structure and SHALL preserve the role-split DiMo dispatch.
- R-5. Audit sub-agent result contracts SHALL use the `finding_summary` field and SHALL include `FAIL` in the status enum.
- R-6. Stale task references (`verify-authorization`, `sc-summary.yaml`) SHALL be replaced with current equivalents.
- R-7. The plan/spec structure standards SHALL be reconciled so a single source of truth exists in `reference/`.
- R-8. Each defect SHALL be resolved by exactly one prescriptive change mapped to exactly one SC.

## 5. Items

### Item 1 (SC-1): Fix spec-creation reference paths

- RED: grep `create.md`/`validate.md` for `Read [.*](reference/` returns non-canonical targets
- GREEN: fix `Read [..](reference/...)` targets in `skills/spec-creation/tasks/create.md` and `validate.md` to `.opencode/reference/`
- verify: grep returns only `.opencode/reference/` targets that resolve
- commit: `skills/spec-creation/tasks/create.md`, `skills/spec-creation/tasks/validate.md`

### Item 2 (SC-2): Consolidate analyze.md artifact paths

- RED: `analyze.md` writes to `contracts/` (requirements, decompose) and `artifacts/` (inspection, artifacts)
- GREEN: consolidate all output writes in `skills/spec-creation/tasks/analyze.md` to `artifacts/`
- verify: grep for `contracts/` returns zero; all outputs under `artifacts/`
- commit: `skills/spec-creation/tasks/analyze.md`

### Item 3 (SC-3): Remove sc-table-columns.md

- RED: `skills/spec-creation/reference/sc-table-columns.md` present with zero consumers
- GREEN: delete the orphan file and merge any canonical content into `reference/spec-structure-standards.md` SC-table section
- verify: grep for `sc-table-columns` returns zero consumers; file absent
- commit: `skills/spec-creation/reference/sc-table-columns.md` (and `reference/spec-structure-standards.md` if merged)

### Item 4 (SC-4): Fix writing-plans reference paths

- RED: `create.md` `Read [.*](reference/` targets non-canonical
- GREEN: fix `Read [..](reference/...)` targets in `skills/writing-plans/tasks/create.md` to `.opencode/reference/`
- verify: grep returns only `.opencode/reference/` targets that resolve
- commit: `skills/writing-plans/tasks/create.md`

### Item 5 (SC-5): Reconcile plan-artifact-format.md

- RED: `plan-artifact-format.md` stale in `writing-plans/SKILL.md` file structure
- GREEN: remove `plan-artifact-format.md` from `writing-plans/SKILL.md` file structure and delete it from `skills/writing-plans/reference/`, merging any canonical content into `reference/plan-structure-standards.md`
- verify: grep for `plan-artifact-format` in `writing-plans/SKILL.md` returns zero; file absent
- commit: `skills/writing-plans/SKILL.md`, `skills/writing-plans/reference/plan-artifact-format.md`

### Item 6 (SC-6): Migrate audit SKILL.md to Workflows structure

- RED: `audit/SKILL.md` has legacy TDT/Invocation/DISPATCH_GATE sections
- GREEN: migrate `skills/audit/SKILL.md` to a flat Workflows section, replacing TDT/Invocation/DISPATCH_GATE, while preserving role-split DiMo dispatch strings
- verify: read `audit/SKILL.md`; assert Workflows section present, legacy sections replaced, role-chain dispatch preserved
- commit: `skills/audit/SKILL.md`

### Item 7 (SC-7): Align audit result-contract schema

- RED: audit task contracts use `summary:`; status enum lacks `FAIL`
- GREEN: replace `summary:` with `finding_summary:` in result-contract blocks across `skills/audit/tasks/*`; add `FAIL` to the status enum
- verify: grep for `summary:` in result-contract blocks returns zero; `finding_summary:` present; status enum includes `FAIL`
- commit: affected `skills/audit/tasks/*` files

### Item 8 (SC-8): Replace stale verify-authorization task reference

- RED: `handoff.md`/`completion.md` reference `approval-gate --task verify-authorization`
- GREEN: replace `verify-authorization` with the current approval-gate task
- verify: grep for `verify-authorization` returns zero; current task used
- commit: `skills/writing-plans/tasks/handoff.md`, `skills/audit/tasks/completion.md`

### Item 9 (SC-9): Replace stale sc-summary.yaml reference

- RED: `research.md`/`create.md` use `sc-summary.yaml`
- GREEN: replace `sc-summary.yaml` with `analysis-summary.yaml` (consistent with `writing-plans/tasks/analyze.md`)
- verify: grep for `sc-summary` returns zero; `analysis-summary.yaml` used
- commit: `skills/writing-plans/tasks/research.md`, `skills/spec-creation/tasks/create.md`

### Item 10 (SC-10): Reconcile plan/spec structure standards

- RED: `reference/spec-structure-standards.md` and `reference/plan-structure-standards.md` divergent
- GREEN: reconcile the two standards non-substantively for consistent section/column definitions; single source of truth in `reference/`
- verify: cross-check both standards for consistent section/column definitions; no divergent structure specs remain
- commit: `reference/spec-structure-standards.md`, `reference/plan-structure-standards.md`

## 6. Dependencies

- **Reference:** `reference/spec-structure-standards.md` — Relationship: canonical spec structure; consumed by SC-1 reference-path fixes and SC-10 reconciliation. Status: satisfied (file exists, unchanged).
- **Reference:** `reference/plan-structure-standards.md` — Relationship: canonical plan structure; consumed by SC-4 reference-path fixes and SC-10 reconciliation. Status: satisfied.
- **Reference:** `reference/cost-model-standards.md` — Relationship: read by `create.md`; reference-path fixes (SC-1, SC-4) must preserve these targets. Status: satisfied.
- **Reference:** `reference/skill-card-description-standards.md` — Relationship: defines the Workflows section that replaces TDT/Invocation/DISPATCH_GATE; consumed by SC-6 migration. Status: satisfied.
- **Reference:** `reference/task-card-structure-standards.md` — Relationship: defines the `finding_summary` result-contract schema; consumed by SC-7 alignment. Status: satisfied.
- **Reference:** `reference/skill-card-schema.md` — Relationship: defines SKILL.md frontmatter binary constraints; consumed by SC-6 migration. Status: satisfied.
- **Reference:** `skills/approval-gate/tasks/` — Relationship: current approval-gate task deck (apply-label, resolve-scope, route) that replaces the nonexistent `verify-authorization`; consumed by SC-8. Status: satisfied.

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1, SC-4 | Phase 1, Phase 2 |
| R-2 | SC-2 | Phase 1 |
| R-3 | SC-3, SC-5 | Phase 1, Phase 2 |
| R-4 | SC-6 | Phase 3 |
| R-5 | SC-7 | Phase 3 |
| R-6 | SC-8, SC-9 | Phase 2, Phase 3 |
| R-7 | SC-10 | Phase 3 |
| R-8 | SC-1 … SC-10 | Phase 1, Phase 2, Phase 3 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| `skills/spec-creation/tasks/create.md` | code | `.opencode/skills/spec-creation/tasks/create.md` | read/grep |
| `skills/spec-creation/tasks/validate.md` | code | `.opencode/skills/spec-creation/tasks/validate.md` | read/grep |
| `skills/spec-creation/tasks/analyze.md` | code | `.opencode/skills/spec-creation/tasks/analyze.md` | read/grep |
| `skills/spec-creation/reference/sc-table-columns.md` | code | `.opencode/skills/spec-creation/reference/` | read/grep |
| `skills/writing-plans/tasks/create.md` | code | `.opencode/skills/writing-plans/tasks/create.md` | read/grep |
| `skills/writing-plans/tasks/handoff.md` | code | `.opencode/skills/writing-plans/tasks/handoff.md` | read/grep |
| `skills/writing-plans/tasks/research.md` | code | `.opencode/skills/writing-plans/tasks/research.md` | read/grep |
| `skills/writing-plans/SKILL.md` | code | `.opencode/skills/writing-plans/SKILL.md` | read/grep |
| `skills/writing-plans/reference/plan-artifact-format.md` | code | `.opencode/skills/writing-plans/reference/` | read |
| `skills/audit/SKILL.md` | code | `.opencode/skills/audit/SKILL.md` | read/grep |
| `skills/audit/tasks/*` | code | `.opencode/skills/audit/tasks/` | read/grep |
| `skills/audit/tasks/completion.md` | code | `.opencode/skills/audit/tasks/completion.md` | read/grep |
| `reference/spec-structure-standards.md` | code | `.opencode/reference/spec-structure-standards.md` | read |
| `reference/plan-structure-standards.md` | code | `.opencode/reference/plan-structure-standards.md` | read |
| `reference/cost-model-standards.md` | code | `.opencode/reference/cost-model-standards.md` | read |
| `reference/skill-card-description-standards.md` | code | `.opencode/reference/skill-card-description-standards.md` | read |
| `reference/task-card-structure-standards.md` | code | `.opencode/reference/task-card-structure-standards.md` | read |
| `reference/skill-card-schema.md` | code | `.opencode/reference/skill-card-schema.md` | read |
| `skills/approval-gate/tasks/` | code | `.opencode/skills/approval-gate/tasks/` | ls |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1: Verifying the reference targets resolve costs one grep. Skipping means the spec writer reads the wrong reference directory and produces structurally wrong specs.
- SC-2: Verifying the artifact paths are uniform costs one grep. Skipping means analytical artifacts land in two locations and downstream consumers read the wrong one.
- SC-3: Verifying the orphan is gone costs one grep. Skipping means a dead reference doc remains and agents resolve to stale content.
- SC-4: Verifying the reference targets resolve costs one grep. Skipping means the plan writer reads the wrong reference directory and produces structurally wrong plans.
- SC-5: Verifying the stale plan-artifact-format reference is gone costs one grep. Skipping means the plan writer reads a stale artifact format and produces divergent plan artifacts.
- SC-6: Verifying the Workflows migration costs one read. Skipping means the audit card keeps a legacy structure that misroutes orchestrator dispatch.
- SC-7: Verifying the contract schema costs one grep. Skipping means the orchestrator cannot parse audit result contracts and routing fails.
- SC-8: Verifying the stale verify-authorization ref is gone costs one grep. Skipping means agents dispatch a nonexistent task.
- SC-9: Verifying the stale sc-summary ref is gone costs one grep. Skipping means agents read a divergent artifact.
- SC-10: Verifying the structure reconciliation costs one cross-check. Skipping means two divergent structure specs remain and producers/auditors disagree.

## 11. Edge Cases

- **Input boundaries:** Empty or missing reference files — Expected: `Read [Text](path)` targets must resolve to existing files; if a target file is absent, the fix must point to the correct existing canonical file. Resolution: SC-1, SC-4 verify target resolution.
- **State transitions:** Reference-source transition — Expected: after SC-1/SC-4, all reference targets point to consolidated `.opencode/reference/`; skill-local `reference/` dirs no longer hold canonical content. Resolution: SC-1, SC-4 verification asserts the transition.
- **Failure modes:** A reference-doc removal (SC-3, SC-5) could break a consumer if a task reads the orphan. Resolution: verify no task reads the orphan before removal; SC-3, SC-5 verified by consumer grep.
- **Concurrency:** Phase 1 (spec-creation) and Phase 2 (writing-plans) share consolidated reference targets; Phase 3 (audit + structure reconciliation) is sequential. Resolution: phase ordering keeps Phase 1 and Phase 2 sequential; Phase 3 depends on reference consolidation.
- **Recovery:** If a structural verification (SC-1–SC-10) cannot execute, the SC is FAIL per the functional/behavioral test substitution prohibition. Resolution: remediate and re-run; no structural substitute.

---

## 12. Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-08-05 | Initial spec creation from analysis artifacts | Assemble remediation spec for 8 skill-card-set consistency defects | spec-creation create gate |
| 2026-08-05 | Decomposed SC-4 into SC-4/SC-5 and SC-7 into SC-8/SC-9 (10 atomic SCs); reclassified SC-2, SC-3, SC-7, SC-8, SC-9 evidence types from structural to string; tightened SC-3 and SC-5 criterion wording to be deterministic; renumbered downstream SC references (Items, Traceability, Dependencies, Cost Frame, Edge Cases); updated testability-assessment artifact | spec-creation validate gate: atomicity (compound SCs), evidence-type correctness (grep-based SCs declared structural), determinism (either/or criterion wording) | spec-creation revise gate |

---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
