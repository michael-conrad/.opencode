> **Full spec and artifacts: [`.opencode/.issues/2250/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2250)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2250/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# SPEC — Plan Writer and Plan Audit Skill Card Internal-Consistency Audit Remediation

## 1. Intent and Executive Summary

### Problem Statement

A history-grounded read-only audit of the plan writer (`writing-plans`, `plan`) and plan audit (`audit`) skill card sets identified 19 internal-consistency findings (F1–F19). Each finding is a drift between what a skill card declares (its description, task listing, cross-references, dispatch contracts, and schema sources) and the actual on-disk reality of its task files, contracts, and reference documents. These drifts cause agents to dispatch nonexistent tasks, resolve cross-references to wrong or deleted files, and consume conflicting schema sources — producing defective plans and audits.

### Root Cause / Motivation

The skill cards accumulated stale content as the underlying task files, contracts, and reference documents were migrated, renamed, or deleted (git history refs `fc9372a4`, `5c74146e`, `b80aba25`, `2106acbc` confirm deleted files and migrations). The cards were not kept in sync with those migrations. Because agent-facing text is consumed as routing instructions, each drift is a defect vector: a card that advertises a nonexistent task, points at a deleted file, or mandates an unimplemented artifact causes agents to route blind. These defects must be resolved now because they compound — every plan written or audited through the affected cards inherits the inconsistency.

### Approach Chosen

Apply exactly ONE prescriptive resolution per finding (F1–F19), each mapped one-to-one to a success criterion (SC-1–SC-19). The changes are confined to agent-facing skill/reference files (markdown/yaml) in `.opencode/` — no `src/` code changes. The work is decomposed into three concern-coherent phases: (1) audit skill card consistency, (2) plan writer (writing-plans) consistency, (3) plan CLI card consistency.

### Alternatives Considered & Why Discarded

- **Full rewrite of the skill cards** — discarded: the cards are largely correct; only 19 discrete drifts exist. A rewrite risks introducing new inconsistencies and loses the audit's precision.
- **Deferring to a future consolidation** — discarded: the drifts actively misroute agents today; deferral compounds the defect cost.
- **Single monolithic fix commit** — discarded: violates per-SC TDD decomposition; each finding is independently verifiable and must be implemented as its own RED/GREEN/commit cycle.

### Key Design Decisions

- **Single canonical schema source:** `reference/plan-structure-standards.md` (with `plan_schema_version: 1` as integer) is adopted as the single source of truth for plan structure; the conflicting `writing-plans/reference/plan-artifact-format.md` (string `'1.0'`) is deprecated. This eliminates the schema conflict (F16).
- **DiMo 4-role chain is the sole audit dispatch mechanism:** no `cross-validate` task exists and the Arbiter role performs consensus. F1 removes all `cross-validate` references; F19 aligns `branch-cleanup.md` to the existing `closure-verification` DiMo chain.
- **Dispatch contract 2-field invariant:** audit dispatch contracts carry exactly `{spec_local_dir, artifact_evidence_dir}` and no `audit_phase` field. F12 aligns the TDT field name; F19 removes `audit_phase`.
- **Read-Link Cross-Reference Rule compliance:** all agent-facing `Read [Text](path)` targets must resolve to existing canonical files under `.opencode/reference/`, not skill-local `reference/` or deleted monoliths.

### User Intent / Original Prompt

The user requested execution of the `create` task from `spec-creation`, producing a consistency-fix spec covering 19 audit findings (F1–F19) about the plan writer (`writing-plans`, `plan`) and plan audit (`audit`) skill card sets, each with ONE prescriptive resolution, based on the analysis artifacts produced by the completed `analyze` step.

## 2. Not Included

- **Runtime code changes** — Rationale: all findings concern agent-facing skill/reference files; no `src/` code is modified.
- **Behavioral changes to the audit verdict semantics beyond F13** — Rationale: only the plan-fidelity evaluator's dual-plan model is corrected to single-plan; other audit verdict logic is out of scope.
- **New audit capabilities** — Rationale: the spec only restores consistency; it does not add new audit checks.
- **Changes to `reference/plan-structure-standards.md` content** — Rationale: it is adopted as the canonical single source and is unchanged; only the conflicting `plan-artifact-format.md` is deprecated.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `skills/audit/SKILL.md` contains no `cross-validate` references in the Trigger Dispatch Table, Tasks table, or Mandatory Task Discipline item 5; the Arbiter role remains the sole consensus authority | behavioral | `opencode run` behavior test dispatching a plan-fidelity audit asserts stderr shows Investigator→Validator→Evaluator→Arbiter chain with NO `cross-validate` dispatch; plus grep `skills/audit/SKILL.md` for `cross-validate` returns zero |
| SC-2 | No audit role file references the deleted monolithic task files (`tasks/plan-fidelity.md`, `tasks/spec-audit.md`, `tasks/verification-audit.md`, `tasks/test-quality-audit.md`) | string | grep `skills/audit/tasks/` for those four deleted paths returns zero matches |
| SC-3 | `skills/writing-plans/tasks/create.md` `Read [..](reference/...)` targets resolve to existing canonical `.opencode/reference/` files | string | grep `create.md` for `Read [.*](reference/` returns only `.opencode/reference/` targets that resolve to existing files |
| SC-4 | Audit role files' `Read [..](reference/...)` targets resolve to existing canonical `.opencode/reference/` files | string | grep `skills/audit/tasks/{plan-fidelity,spec-audit}-{investigator,evaluator}.md` for `Read [.*](reference/` returns only `.opencode/reference/` targets that resolve to existing files |
| SC-5 | `skills/audit/SKILL.md` Mandatory Task Discipline item 5 uses conditional "if provided, collect evidence" language with no hard artifact mandate | string | Read `skills/audit/SKILL.md` item 5; assert conditional language, no hard artifact mandate |
| SC-6 | `skills/writing-plans/tasks/research.md` step 12 uses `./.opencode/tools/plan plan --problem <path> > plan-output.yaml` (no `--contract-path`/`--output`) | string | Read `research.md` step 12; assert it matches the canonical plan invocation form |
| SC-7 | `skills/writing-plans/SKILL.md` claims "9 task files" and the File Structure lists 9 task entries | string | Read `writing-plans/SKILL.md` line 13; assert "9 task files"; count File Structure task entries = 9 |
| SC-8 | `skills/writing-plans/contracts/` is symmetric with the 9-task file structure: `handoff-*`, `research-*`, `verify-plan-pipeline-*` contracts present; orphan `self-review-*` and `structure-*` contracts absent; `solve-output.yaml` kept | string | glob `writing-plans/contracts/`; assert the required contracts present/absent per criterion |
| SC-9 | `reference/holistic-dimensions.yaml` cross-references point to role files (`spec-audit-investigator.md`, `plan-fidelity-investigator.md`) and contain no "Step 0 pre-flight gate" references | string | Read `reference/holistic-dimensions.yaml` lines 98–114; assert refs point to role files, no "Step 0 pre-flight gate", role-file paths resolve |
| SC-10 | `skills/audit/tasks/plan-fidelity-investigator.md` example uses canonical `plan-01-{slug}.md` naming (no `plan-phase-1.md`) | string | grep `plan-fidelity-investigator.md` for `plan-phase-` returns zero; `plan-01-` used |
| SC-11 | `skills/writing-plans/tasks/completion.md` Purpose and Exit Criteria reference "plan file at plan.md", not "issue body" | string | Read `completion.md` lines 5, 42; assert both reference "plan file at plan.md" |
| SC-12 | `skills/audit/SKILL.md` plan-fidelity TDT context uses `spec_local_dir` (no `plan_local_dir`) | string | grep `skills/audit/SKILL.md` for `plan_local_dir` returns zero; plan-fidelity TDT uses `spec_local_dir` |
| SC-13 | `skills/audit/tasks/plan-fidelity-evaluator.md` uses the single-plan (plan-vs-spec) model, not the dual-plan (clean-room vs existing) model | behavioral | `opencode run` behavior test runs plan-fidelity on a single plan and asserts the evaluator produces a verdict from single-plan evidence; plus grep `plan-fidelity-evaluator.md` for `clean-room`/`PLAN_INCOMPLETE`/`PLAN_OVERSCOPED`/`PLAN_DRIFT` returns zero |
| SC-14 | `skills/plan/SKILL.md` description contains a single `writing-plans` clause (no duplicate) | string | Read `plan/SKILL.md` line 3; assert single `writing-plans` clause |
| SC-15 | `skills/plan/SKILL.md` contains no `executing-plans` cross-reference | string | grep `plan/SKILL.md` for `executing-plans` returns zero |
| SC-16 | `writing-plans/reference/plan-artifact-format.md` is deprecated (deleted or reduced to a pointer to `reference/plan-structure-standards.md`); `reference/plan-structure-standards.md` is the single source | string | Read `writing-plans/SKILL.md` File Structure; `plan-artifact-format.md` absent; `plan-artifact-format.md` deleted or reduced to pointer |
| SC-17 | `skills/writing-plans/tasks/verify-plan-pipeline.md` checks for `plan-fidelity` and `concern-separation` output naming (not `audit-fidelity`/`audit-concern`) | string | grep `verify-plan-pipeline.md` for `audit-fidelity`/`audit-concern` returns zero; `plan-fidelity`/`concern-separation` used |
| SC-18 | `skills/plan/tasks/discover.md` exists, documents the `discover` subcommand, and is referenced in `plan/SKILL.md` File Structure | string | `file-exists skills/plan/tasks/discover.md`; read it and assert it documents the `discover` subcommand; `plan/SKILL.md` File Structure lists `discover.md` |
| SC-19 | `skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md` dispatches the closure-verification DiMo chain (Investigator→Validator→Evaluator→Arbiter) with a 2-field contract `{spec_local_dir, artifact_evidence_dir}` and no `audit_phase`/`resolve-models`/`cross-validate` | behavioral | `opencode run` behavior test triggers post-merge closure and asserts `branch-cleanup.md` dispatches the closure-verification DiMo chain with 2-field contract and no `audit_phase`/`resolve-models`/`cross-validate`; plus grep `branch-cleanup.md` for those three terms returns zero |

## 4. Requirements

- R-1. The audit skill card (`skills/audit/SKILL.md`) SHALL contain no references to the nonexistent `cross-validate` task.
- R-2. Audit role files SHALL NOT reference deleted monolithic task files.
- R-3. All agent-facing `Read [Text](path)` cross-references in the affected skill cards SHALL resolve to existing canonical files under `.opencode/reference/`.
- R-4. The plan writer skill card (`skills/writing-plans/SKILL.md`) SHALL accurately state its task count and file structure.
- R-5. The writing-plans contracts directory SHALL be symmetric with the task file structure.
- R-6. `reference/plan-structure-standards.md` SHALL be the single canonical source for plan structure; conflicting schema sources SHALL be deprecated.
- R-7. The plan skill card (`skills/plan/SKILL.md`) SHALL accurately describe its tasks and SHALL NOT reference nonexistent skills.
- R-8. The post-merge closure audit dispatch in `branch-cleanup.md` SHALL use the closure-verification DiMo chain with a 2-field contract and no `audit_phase`.
- R-9. Each finding (F1–F19) SHALL be resolved by exactly one prescriptive change mapped to exactly one SC.

## 5. Items

### Item 1 (SC-1): Remove `cross-validate` references from audit skill card

- RED: behavioral test asserts agent does NOT dispatch `cross-validate` (currently fails — `cross-validate` referenced)
- GREEN: remove `cross-validate` rows from TDT, Tasks table, and Mandatory Task Discipline item 5 in `skills/audit/SKILL.md`
- verify: `opencode run` behavior test + grep for `cross-validate` returns zero
- commit: `skills/audit/SKILL.md`

### Item 2 (SC-2): Remove stale monolithic task-file references from audit role files

- RED: grep for deleted monolithic paths returns matches
- GREEN: remove `tasks/plan-fidelity.md`, `tasks/spec-audit.md`, `tasks/verification-audit.md`, `tasks/test-quality-audit.md` references from audit role files
- verify: grep returns zero matches
- commit: affected `skills/audit/tasks/*` role files

### Item 3 (SC-3): Fix `create.md` reference paths

- RED: grep `create.md` for `Read [.*](reference/` returns non-canonical targets
- GREEN: fix `Read [..](reference/...)` targets in `skills/writing-plans/tasks/create.md` to `.opencode/reference/`
- verify: grep returns only `.opencode/reference/` targets that resolve
- commit: `skills/writing-plans/tasks/create.md`

### Item 4 (SC-4): Fix audit role file reference paths

- RED: grep audit role files for `Read [.*](reference/` returns non-canonical targets
- GREEN: fix `Read [..](reference/...)` targets in `plan-fidelity`/`spec-audit` investigator/evaluator role files to `.opencode/reference/`
- verify: grep returns only `.opencode/reference/` targets that resolve
- commit: affected `skills/audit/tasks/*` role files

### Item 5 (SC-5): Soften Mandatory Task Discipline item 5

- RED: item 5 contains hard artifact mandate
- GREEN: rewrite item 5 to conditional "if provided, collect evidence" form
- verify: read item 5, assert conditional language
- commit: `skills/audit/SKILL.md`

### Item 6 (SC-6): Fix `research.md` plan invocation

- RED: `research.md` step 12 uses `--contract-path`/`--output`
- GREEN: change step 12 to `./.opencode/tools/plan plan --problem <path> > plan-output.yaml`
- verify: read step 12, assert canonical form
- commit: `skills/writing-plans/tasks/research.md`

### Item 7 (SC-7): Correct writing-plans task count

- RED: `writing-plans/SKILL.md` claims "7 task files"
- GREEN: change to "9 task files"
- verify: read line 13, assert "9 task files"; count File Structure entries = 9
- commit: `skills/writing-plans/SKILL.md`

### Item 8 (SC-8): Rebalance writing-plans contracts

- RED: contracts dir has orphan `self-review-*`/`structure-*`, missing `handoff-*`/`research-*`/`verify-plan-pipeline-*`
- GREEN: add `handoff-input/output.yaml`, `research-input/output.yaml`, `verify-plan-pipeline-input/output.yaml`; remove `self-review-input/output.yaml`, `structure-input/output.yaml`; keep `solve-output.yaml`
- verify: glob contracts dir, assert symmetry
- commit: `skills/writing-plans/contracts/`

### Item 9 (SC-9): Fix holistic-dimensions cross-references

- RED: `holistic-dimensions.yaml` refs point to deleted monoliths and "Step 0 pre-flight gate"
- GREEN: point refs to role files (`spec-audit-investigator.md`, `plan-fidelity-investigator.md`); remove "Step 0 pre-flight gate" refs
- verify: read lines 98–114, assert role-file refs and no Step 0 refs
- commit: `reference/holistic-dimensions.yaml`

### Item 10 (SC-10): Align plan-fidelity-investigator example naming

- RED: example uses `plan-phase-1.md`
- GREEN: change to `plan-01-{slug}.md`
- verify: grep for `plan-phase-` returns zero; `plan-01-` used
- commit: `skills/audit/tasks/plan-fidelity-investigator.md`

### Item 11 (SC-11): Align completion.md lifecycle target

- RED: Purpose/Exit say "issue body"
- GREEN: change Purpose and Exit Criteria to "plan file at plan.md"
- verify: read lines 5, 42, assert "plan file at plan.md"
- commit: `skills/writing-plans/tasks/completion.md`

### Item 12 (SC-12): Align TDT field name

- RED: `audit/SKILL.md` TDT uses `plan_local_dir`
- GREEN: change to `spec_local_dir`
- verify: grep for `plan_local_dir` returns zero
- commit: `skills/audit/SKILL.md`

### Item 13 (SC-13): Rewrite plan-fidelity-evaluator to single-plan model

- RED: behavioral test asserts evaluator uses dual-plan model (currently fails)
- GREEN: rewrite `plan-fidelity-evaluator.md` to single-plan (plan-vs-spec) model; remove `clean-room`/`PLAN_INCOMPLETE`/`PLAN_OVERSCOPED`/`PLAN_DRIFT` verdicts and "Add phase from clean-room" auto-fix
- verify: `opencode run` behavior test + grep for removed terms returns zero
- commit: `skills/audit/tasks/plan-fidelity-evaluator.md`

### Item 14 (SC-14): Remove duplicate clause in plan description

- RED: `plan/SKILL.md` description has duplicated `writing-plans` clause
- GREEN: remove the duplicate clause
- verify: read line 3, assert single clause
- commit: `skills/plan/SKILL.md`

### Item 15 (SC-15): Remove dead executing-plans reference

- RED: `plan/SKILL.md` references `executing-plans`
- GREEN: delete the reference
- verify: grep for `executing-plans` returns zero
- commit: `skills/plan/SKILL.md`

### Item 16 (SC-16): Deprecate plan-artifact-format.md

- RED: `plan-artifact-format.md` present and referenced in File Structure
- GREEN: deprecate `plan-artifact-format.md` (delete or reduce to pointer to `reference/plan-structure-standards.md`); remove from `writing-plans/SKILL.md` File Structure
- verify: read File Structure, assert `plan-artifact-format.md` absent; file deleted or reduced to pointer
- commit: `skills/writing-plans/reference/plan-artifact-format.md`, `skills/writing-plans/SKILL.md`

### Item 17 (SC-17): Fix verify-plan-pipeline audit naming

- RED: `verify-plan-pipeline.md` checks for `audit-fidelity`/`audit-concern`
- GREEN: change to `plan-fidelity`/`concern-separation`
- verify: grep for `audit-fidelity`/`audit-concern` returns zero
- commit: `skills/writing-plans/tasks/verify-plan-pipeline.md`

### Item 18 (SC-18): Add discover.md task

- RED: `plan/tasks/discover.md` does not exist
- GREEN: create `skills/plan/tasks/discover.md` documenting the `discover` subcommand; reference it in `plan/SKILL.md` File Structure
- verify: `file-exists skills/plan/tasks/discover.md`; read it; assert File Structure lists it
- commit: `skills/plan/tasks/discover.md`, `skills/plan/SKILL.md`

### Item 19 (SC-19): Rewrite branch-cleanup audit dispatch

- RED: behavioral test asserts `branch-cleanup.md` dispatches `resolve-models`/`audit_phase`/separate `cross-validate` (currently fails)
- GREEN: rewrite the audit block to dispatch the closure-verification DiMo chain (Investigator→Validator→Evaluator→Arbiter) with 2-field contract `{spec_local_dir, artifact_evidence_dir}`, no `audit_phase`
- verify: `opencode run` behavior test + grep for `resolve-models`/`audit_phase`/`cross-validate` returns zero
- commit: `skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md`

## 6. Dependencies

- **Reference:** `reference/plan-structure-standards.md` — Relationship: adopted as the single canonical plan-structure source (SC-16); consumed by SC-3, SC-4 reference-path fixes. Status: satisfied (file exists, unchanged).
- **Reference:** `reference/cost-model-standards.md` — Relationship: read by `create.md` and plan-fidelity tasks; reference-path fixes (SC-3, SC-4) must preserve these targets. Status: satisfied.
- **Reference:** `reference/spec-structure-standards.md` — Relationship: read by spec-audit tasks; reference-path fixes (SC-4) must preserve these targets. Status: satisfied.
- **Reference:** `skills/audit/tasks/closure-verification/` — Relationship: the existing closure-verification DiMo chain that SC-19 aligns `branch-cleanup.md` to. Status: satisfied (implementation exists).
- **Reference:** `reference/holistic-dimensions.yaml` — Relationship: cross-reference targets corrected by SC-9. Status: satisfied.

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | Phase 1 |
| R-2 | SC-2 | Phase 1 |
| R-3 | SC-3, SC-4, SC-9 | Phase 2, Phase 1 |
| R-4 | SC-7 | Phase 2 |
| R-5 | SC-8 | Phase 2 |
| R-6 | SC-16 | Phase 2 |
| R-7 | SC-14, SC-15, SC-18 | Phase 3 |
| R-8 | SC-19 | Phase 1 |
| R-9 | SC-1 … SC-19 | Phase 1, Phase 2, Phase 3 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| `skills/audit/SKILL.md` | code | `.opencode/skills/audit/SKILL.md` | read/grep |
| `skills/audit/tasks/*` role files | code | `.opencode/skills/audit/tasks/` | read/grep |
| `skills/writing-plans/SKILL.md` | code | `.opencode/skills/writing-plans/SKILL.md` | read/grep |
| `skills/writing-plans/tasks/*` | code | `.opencode/skills/writing-plans/tasks/` | read/grep |
| `skills/writing-plans/contracts/` | code | `.opencode/skills/writing-plans/contracts/` | glob |
| `skills/writing-plans/reference/plan-artifact-format.md` | code | `.opencode/skills/writing-plans/reference/` | read |
| `skills/plan/SKILL.md` | code | `.opencode/skills/plan/SKILL.md` | read/grep |
| `skills/plan/tasks/discover.md` | code | `.opencode/skills/plan/tasks/` | file-exists/read |
| `skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md` | code | `.opencode/skills/git-workflow-cleanup/tasks/cleanup/` | read/grep |
| `reference/plan-structure-standards.md` | code | `.opencode/reference/plan-structure-standards.md` | read |
| `reference/holistic-dimensions.yaml` | code | `.opencode/reference/holistic-dimensions.yaml` | read |
| `reference/cost-model-standards.md` | code | `.opencode/reference/cost-model-standards.md` | read |
| `reference/spec-structure-standards.md` | code | `.opencode/reference/spec-structure-standards.md` | read |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1: Running the behavioral test costs minutes of execution time. Skipping means the nonexistent `cross-validate` dispatch ships and agents route blind to a task that does not exist.
- SC-2: Verifying the deleted-file references are gone costs one grep. Skipping means agents resolve cross-references to files deleted in `5c74146e`.
- SC-3: Verifying `create.md` reference targets resolve costs one grep. Skipping means the plan writer reads the wrong reference directory.
- SC-4: Verifying audit role reference targets resolve costs one grep. Skipping means audit role files read the wrong reference directory.
- SC-5: Verifying item 5 is conditional costs one read. Skipping means agents are mandated to produce artifacts no investigator implements.
- SC-6: Verifying the plan invocation form costs one read. Skipping means the plan writer invokes the CLI with nonexistent flags.
- SC-7: Verifying the task count costs one read. Skipping means the card advertises 7 tasks when 9 exist.
- SC-8: Verifying contract symmetry costs one glob. Skipping means the pipeline validates against orphan or missing contracts.
- SC-9: Verifying holistic-dimensions refs costs one read. Skipping means the holistic check points at deleted monoliths.
- SC-10: Verifying the example naming costs one grep. Skipping means the investigator produces non-canonical plan filenames.
- SC-11: Verifying the lifecycle target costs one read. Skipping means completion appends to the wrong artifact.
- SC-12: Verifying the TDT field name costs one grep. Skipping means the dispatch contract field mismatches the role files.
- SC-13: Running the behavioral test costs minutes of execution time. Skipping means the evaluator uses a stale dual-plan model that produces wrong verdicts.
- SC-14: Verifying the description clause costs one read. Skipping means the card description is duplicated and confusing.
- SC-15: Verifying the dead reference is gone costs one grep. Skipping means agents route to a nonexistent skill.
- SC-16: Verifying the schema deprecation costs one read. Skipping means two conflicting plan-schema sources remain.
- SC-17: Verifying the audit naming costs one grep. Skipping means the pipeline checks for nonexistent audit artifacts.
- SC-18: Verifying the discover task exists costs one file-exists. Skipping means the card advertises a subcommand with no task.
- SC-19: Running the behavioral test costs minutes of execution time. Skipping means the post-merge closure dispatches a nonexistent task with a forbidden field.

## 11. Edge Cases

- **Input boundaries:** Empty or missing reference files — Expected: `Read [Text](path)` targets must resolve to existing files; if a target file is absent, the fix must point to the correct existing canonical file. Resolution: SC-3, SC-4, SC-9 verify target resolution.
- **State transitions:** Schema source transition — Expected: after SC-16, `plan-structure-standards.md` is the single source; `plan-artifact-format.md` is deprecated. Resolution: SC-16 verification asserts the deprecation.
- **Failure modes:** A contract removal (SC-8) could break pipeline artifact validation if a consumer expects the orphan contract. Resolution: verify no task reads orphan contracts before removal; SC-8 verified by contract/task symmetry check.
- **Concurrency:** Phase 1 (audit) and Phase 2 (writing-plans) share canonical reference targets; Phase 3 (plan CLI) is independent. Resolution: phase ordering keeps Phase 1 and Phase 2 sequential; Phase 3 independent.
- **Recovery:** If a behavioral test (SC-1, SC-13, SC-19) cannot execute, the SC is FAIL per the functional/behavioral test substitution prohibition. Resolution: remediate and re-run; no structural substitute.

---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
