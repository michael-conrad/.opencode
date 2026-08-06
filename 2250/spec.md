> **Full spec and artifacts: [`.opencode/.issues/2250/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2250)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2250/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# SPEC — Plan Writer and Plan Audit Skill Card Internal-Consistency Audit Remediation

## 1. Intent and Executive Summary

### Problem Statement

A history-grounded read-only audit of the plan-writer and plan-audit skill card sets (`writing-plans`, `plan`, `audit`) and the consolidated reference standards (`.opencode/reference/`) identified 19 internal-consistency findings (F1–F19). Each finding is a drift between what a skill card or task card declares (its task count, reference paths, dispatch contracts, result-contract schema, evaluation model, and file structure) and the actual on-disk reality of its task files, contracts, and reference documents. These drifts cause agents to resolve cross-references to non-existent files, dispatch nonexistent tasks, invoke the plan CLI with unsupported flags, evaluate plans against a stale dual-plan model, and read conflicting schema sources — producing defective plans and audits.

### Root Cause / Motivation

The skill cards accumulated stale content as the underlying task files, contracts, and reference documents were migrated to a consolidated `.opencode/reference/` location, a flat Workflows-style SKILL.md structure, and a role-split DiMo 4-role audit dispatch. The cards were not kept in sync with those migrations. Because agent-facing text is consumed as routing instructions, each drift is a defect vector: a card that points at a deleted file, advertises a nonexistent task, or mandates an unimplemented artifact causes agents to route blind. These defects must be resolved now because they compound — every plan written or audited through the affected cards inherits the inconsistency.

### Approach Chosen

Apply exactly ONE prescriptive resolution per finding, each mapped one-to-one to a success criterion (SC-1–SC-19). The changes are confined to agent-facing skill/reference files (markdown/yaml) in `.opencode/` — no `src/` code changes. The work is decomposed into three concern-coherent phases: (1) audit skill card consistency, (2) plan-writer (`writing-plans`) consistency, (3) plan CLI card consistency.

### Alternatives Considered & Why Discarded

- **Full rewrite of the skill cards** — discarded: the cards are largely correct; only 19 discrete drifts exist. A rewrite risks introducing new inconsistencies and loses the audit's precision.
- **Deferring to a future consolidation** — discarded: the drifts actively misroute agents today; deferral compounds the defect cost.
- **Single monolithic fix commit** — discarded: violates per-SC TDD decomposition; each finding is independently verifiable and must be implemented as its own RED/GREEN/commit cycle.

### Key Design Decisions

- **Consolidated `.opencode/reference/` as single source of truth:** all agent-facing `Read [Text](path)` targets resolve to existing canonical files under `.opencode/reference/`, not skill-local `reference/` dirs. This eliminates the broken relative-path defects (SC-3, SC-4).
- **`reference/plan-structure-standards.md` as the single plan-schema source:** the conflicting `writing-plans/reference/plan-artifact-format.md` is deleted so one canonical schema (integer `plan_schema_version`) governs plan structure (SC-16).
- **DiMo 4-role chain as the sole audit dispatch mechanism:** no `cross-validate` task exists and the Arbiter role performs consensus; stale `cross-validate` references are removed (SC-1) and the post-merge closure audit aligns to the closure-verification DiMo chain (SC-19).
- **Dispatch contract 2-field invariant:** audit dispatch contracts carry exactly `{spec_local_dir, artifact_evidence_dir}` and no `audit_phase` field (SC-12, SC-19).
- **Single-plan fidelity model:** the plan-fidelity evaluator evaluates one plan against the spec, not a stale clean-room-vs-existing dual-plan comparison (SC-13).
- **Task/contract symmetry:** every `writing-plans` task file has a corresponding contract and vice versa (SC-7, SC-8a, SC-8b, SC-8c).
- **Skill card description accuracy:** skill card descriptions/overviews accurately reflect available tasks (SC-14, SC-15, SC-18).

### User Intent / Original Prompt

The user requested execution of the `revise` task from `spec-creation`, correcting a SEVERE SCOPE DEFECT: the existing spec #2250 was created with the WRONG scope (8 success criteria about spec-writer/spec-audit skill card sets). The intended spec is about the PLAN WRITER (`writing-plans`, `plan`) and PLAN AUDIT (`audit`) skill card sets, covering 19 internal-consistency audit findings (F1–F19). The authoritative source of correct content is the analysis artifacts produced by the completed `analyze` step, which carry all 19 findings with one prescriptive resolution each.

## 2. Not Included

- **Runtime code changes** — Rationale: all findings concern agent-facing skill/reference files; no `src/` code is modified.
- **Change to the writing-plans pipeline execution order** — Rationale: the HANDOFF → ANALYZE → RESEARCH → CREATE → VALIDATE → revise loop → COMPLETION order is unchanged.
- **Re-creation of monolithic audit task files** — Rationale: `plan-fidelity.md`, `spec-audit.md`, `verification-audit.md` were deleted in favor of role files; they are not re-created.
- **Change to the DiMo 4-role chain dispatch mechanism** — Rationale: the Investigator → Validator → Evaluator → Arbiter chain is preserved; only stale references to it are corrected.
- **Change to the canonical `reference/plan-structure-standards.md` schema** — Rationale: it is the single source of truth and is unchanged; only the conflicting `plan-artifact-format.md` is deleted.
- **Change to the plan CLI `discover` subcommand implementation** — Rationale: only the missing task documentation is added, not the CLI behavior.
- **Behavioral-enforcement-test work beyond the three behavioral SCs** — Rationale: most SCs are string-level consistency checks; only SC-1, SC-13, SC-19 affect runtime behavior and require behavioral tests.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `audit/SKILL.md` contains no `cross-validate` references in the Trigger Dispatch Table, Tasks table, or Mandatory Task Discipline item 5; the Arbiter role remains the sole consensus authority | behavioral | grep `skills/audit/SKILL.md` for `cross-validate` returns zero matches; `opencode run` behavior test dispatches a plan-fidelity audit and asserts stderr shows the Investigator→Validator→Evaluator→Arbiter chain with no cross-validate dispatch and Arbiter consensus |
| SC-2 | audit role files contain no stale cross-references to deleted monolithic task files (`tasks/plan-fidelity.md`, `tasks/spec-audit.md`, `tasks/verification-audit.md`, `tasks/test-quality-audit.md`) | string | grep `skills/audit/tasks/` for the four deleted monolithic file paths returns zero matches |
| SC-3 | `writing-plans/tasks/create.md` resolves all relative `Read [Text](reference/...)` targets to existing canonical `.opencode/reference/` files | string | grep `skills/writing-plans/tasks/create.md` for `Read [.*](reference/` returns only `.opencode/reference/` targets that resolve to existing files |
| SC-4 | audit role files (`plan-fidelity-*`, `spec-audit-*`) resolve all relative `Read [Text](reference/...)` targets to existing canonical `.opencode/reference/` files | string | grep `skills/audit/tasks/{plan-fidelity,spec-audit}-{investigator,evaluator}.md` for `Read [.*](reference/` returns only `.opencode/reference/` targets that resolve to existing files |
| SC-5 | `audit/SKILL.md` Mandatory Task Discipline item 5 uses conditional evidence-collection language ("if provided, collect evidence") with no hard artifact mandate | string | read `skills/audit/SKILL.md` item 5; assert no hard "requires X artifact" mandate remains and conditional evidence-collection language is used |
| SC-6 | `writing-plans/tasks/research.md` step 12 invokes the plan CLI with `--problem` and stdout redirect, not `--contract-path`/`--output` | string | read `skills/writing-plans/tasks/research.md` step 12; assert it matches the canonical form `./.opencode/tools/plan plan --problem <path> > plan-output.yaml` |
| SC-7 | `writing-plans/SKILL.md` claims "9 task files" and its File Structure lists 9 task files | string | read `skills/writing-plans/SKILL.md` Overview; assert "9 task files" and count 9 task entries in the File Structure |
| SC-8a | `writing-plans/contracts/` contains the handoff, research, and verify-plan-pipeline contracts | string | glob `skills/writing-plans/contracts/`; assert `handoff-*`, `research-*`, `verify-plan-pipeline-*` present |
| SC-8b | `writing-plans/contracts/` contains no orphan self-review or structure contracts | string | glob `skills/writing-plans/contracts/`; assert `self-review-*`, `structure-*` absent |
| SC-8c | `writing-plans/contracts/` keeps `solve-output.yaml` | string | glob `skills/writing-plans/contracts/`; assert `solve-output.yaml` present |
| SC-9 | `reference/holistic-dimensions.yaml` cross-references point to role files (`spec-audit-investigator.md`, `plan-fidelity-investigator.md`) and contain no references to deleted monolithic files or nonexistent "Step 0 pre-flight gate" sections | string | read `reference/holistic-dimensions.yaml` cross-reference entries; assert no refs to deleted monolithic files and no "Step 0 pre-flight gate" refs; role-file paths resolve to existing files |
| SC-10 | `plan-fidelity-investigator.md` evidence example uses canonical `plan-01-{slug}.md` naming, not `plan-phase-1.md` | string | grep `skills/audit/tasks/plan-fidelity-investigator.md` for `plan-phase-` returns zero matches; `plan-01-` is used |
| SC-11 | `writing-plans/tasks/completion.md` Purpose and Exit Criteria reference the plan file at `plan.md`, not the issue body | string | read `skills/writing-plans/tasks/completion.md` Purpose and Exit Criteria; assert both reference "plan file at plan.md", not "issue body" |
| SC-12 | `audit/SKILL.md` plan-fidelity TDT context uses `spec_local_dir`, not `plan_local_dir`, consistent with role files | string | grep `skills/audit/SKILL.md` for `plan_local_dir` returns zero matches; plan-fidelity TDT uses `spec_local_dir` |
| SC-13 | `plan-fidelity-evaluator.md` uses a single-plan (plan-vs-spec) evaluation model with no stale dual-plan (clean-room vs existing) constructs | behavioral | grep `skills/audit/tasks/plan-fidelity-evaluator.md` for `clean-room`, `PLAN_INCOMPLETE`, `PLAN_OVERSCOPED`, `PLAN_DRIFT` returns zero matches; `opencode run` behavior test runs a plan-fidelity audit on a single plan and asserts the evaluator produces a verdict from single-plan evidence |
| SC-14 | `plan/SKILL.md` description contains a single `writing-plans` clause with no duplication | string | read `skills/plan/SKILL.md` description; assert a single `writing-plans` clause, no duplicated clause |
| SC-15 | `plan/SKILL.md` contains no reference to the nonexistent `executing-plans` skill | string | grep `skills/plan/SKILL.md` for `executing-plans` returns zero matches |
| SC-16 | `writing-plans/reference/plan-artifact-format.md` is deleted (removed from `writing-plans/SKILL.md` File Structure and the file itself deleted); `reference/plan-structure-standards.md` is the single plan-schema source | string | read `skills/writing-plans/SKILL.md` File Structure; assert `plan-artifact-format.md` absent; assert the file `skills/writing-plans/reference/plan-artifact-format.md` does not exist |
| SC-17 | `writing-plans/tasks/verify-plan-pipeline.md` checks for `plan-fidelity` and `concern-separation` output naming, not `audit-fidelity` and `audit-concern` | string | grep `skills/writing-plans/tasks/verify-plan-pipeline.md` for `audit-fidelity` and `audit-concern` returns zero matches; `plan-fidelity` and `concern-separation` are used |
| SC-18 | `skills/plan/tasks/discover.md` exists, documents the `discover` subcommand, and is referenced in `plan/SKILL.md` File Structure | string | file-exists `skills/plan/tasks/discover.md`; read it and assert it documents the discover subcommand; `plan/SKILL.md` File Structure lists `discover.md` |
| SC-19 | `git-workflow-cleanup/tasks/cleanup/branch-cleanup.md` audit block dispatches the closure-verification DiMo chain (Investigator→Validator→Evaluator→Arbiter) with a 2-field contract `{spec_local_dir, artifact_evidence_dir}` and no `resolve-models`, `audit_phase`, or separate `cross-validate` dispatch | behavioral | grep `skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md` for `resolve-models`, `audit_phase`, `cross-validate` returns zero matches; assert the closure-verification DiMo chain with 2-field contract; `opencode run` behavior test triggers post-merge closure and asserts the correct chain is dispatched |

## 4. Requirements

- R-1. All agent-facing `Read [Text](path)` cross-references in the affected skill cards SHALL resolve to existing canonical files under `.opencode/reference/`.
- R-2. The `audit` skill card SHALL contain no references to the nonexistent `cross-validate` task; the Arbiter role SHALL remain the sole consensus authority.
- R-3. Audit role files SHALL contain no stale cross-references to deleted monolithic task files.
- R-4. The plan-fidelity evaluator SHALL use a single-plan (plan-vs-spec) evaluation model.
- R-5. Audit dispatch contracts SHALL carry exactly the 2 fields `{spec_local_dir, artifact_evidence_dir}` and SHALL NOT carry an `audit_phase` field.
- R-6. `reference/plan-structure-standards.md` SHALL be the single plan-schema source; `writing-plans/reference/plan-artifact-format.md` SHALL be deleted.
- R-7. The `writing-plans` skill card SHALL accurately claim its task count and SHALL maintain task/contract symmetry.
- R-8. The `plan` skill card SHALL accurately describe its tasks and SHALL have a task file for every advertised CLI subcommand.
- R-9. Each finding SHALL be resolved by exactly one prescriptive change mapped to exactly one SC.
- R-10. The `audit` skill card Mandatory Task Discipline item 5 SHALL use conditional evidence-collection language ("if provided, collect evidence") and SHALL NOT mandate a hard artifact requirement.
- R-11. `writing-plans/tasks/research.md` step 12 SHALL invoke the plan CLI with `--problem` and stdout redirect, and SHALL NOT use `--contract-path`/`--output`.
- R-12. `reference/holistic-dimensions.yaml` cross-references SHALL point to role files and SHALL NOT reference deleted monolithic files or nonexistent "Step 0 pre-flight gate" sections.
- R-13. `plan-fidelity-investigator.md` evidence examples SHALL use canonical `plan-01-{slug}.md` naming and SHALL NOT use `plan-phase-1.md`.
- R-14. `writing-plans/tasks/completion.md` Purpose and Exit Criteria SHALL reference the plan file at `plan.md`, not the issue body.
- R-15. `writing-plans/tasks/verify-plan-pipeline.md` SHALL check for `plan-fidelity` and `concern-separation` output naming, and SHALL NOT check for `audit-fidelity`/`audit-concern`.

## 5. Items

### Item 1 (SC-1): Remove cross-validate references from audit/SKILL.md

- RED: `audit/SKILL.md` references `cross-validate` in the TDT, Tasks table, and Mandatory Task Discipline item 5
- GREEN: delete all `cross-validate` references from `skills/audit/SKILL.md`; the Arbiter role remains the sole consensus authority
- verify: grep for `cross-validate` returns zero; behavior test confirms no cross-validate dispatch
- commit: `skills/audit/SKILL.md`

### Item 2 (SC-2): Delete stale monolithic task-file cross-references in audit role files

- RED: audit role files reference deleted `tasks/plan-fidelity.md`, `tasks/spec-audit.md`, `tasks/verification-audit.md`, `tasks/test-quality-audit.md`
- GREEN: delete the stale "Main task file" / "Evaluator role" cross-reference lines across the affected audit role files
- verify: grep for the four deleted monolithic file paths returns zero
- commit: affected `skills/audit/tasks/*` role files

### Item 3 (SC-3): Fix writing-plans create.md reference paths

- RED: `create.md` `Read [Text](reference/...)` targets resolve to the wrong directory
- GREEN: fix `Read [Text](reference/...)` targets in `skills/writing-plans/tasks/create.md` to `.opencode/reference/`
- verify: grep returns only `.opencode/reference/` targets that resolve
- commit: `skills/writing-plans/tasks/create.md`

### Item 4 (SC-4): Fix audit role-file reference paths

- RED: audit role files `Read [Text](reference/...)` targets resolve to the wrong directory
- GREEN: fix `Read [Text](reference/...)` targets in `plan-fidelity-*` and `spec-audit-*` role files to `.opencode/reference/`
- verify: grep returns only `.opencode/reference/` targets that resolve
- commit: affected `skills/audit/tasks/{plan-fidelity,spec-audit}-{investigator,evaluator}.md`

### Item 5 (SC-5): Soften audit/SKILL.md item 5 artifact mandates

- RED: Mandatory Task Discipline item 5 claims hard artifact requirements no investigator implements
- GREEN: soften item 5 to conditional "if provided, collect evidence" form in `skills/audit/SKILL.md`
- verify: read item 5; assert conditional evidence-collection language, no hard mandate
- commit: `skills/audit/SKILL.md`

### Item 6 (SC-6): Fix research.md plan invocation

- RED: `research.md` step 12 uses `--contract-path`/`--output`; the plan CLI takes only `--problem`
- GREEN: fix step 12 in `skills/writing-plans/tasks/research.md` to `./.opencode/tools/plan plan --problem <path> > plan-output.yaml`
- verify: read step 12; assert canonical form
- commit: `skills/writing-plans/tasks/research.md`

### Item 7 (SC-7): Correct writing-plans task count

- RED: `writing-plans/SKILL.md` claims "7 task files" but File Structure lists 9
- GREEN: change the Overview claim to "9 task files" in `skills/writing-plans/SKILL.md`
- verify: read Overview; assert "9 task files" and count 9 File Structure entries
- commit: `skills/writing-plans/SKILL.md`

### Item 8 (SC-8a, SC-8b, SC-8c): Align writing-plans contracts with tasks

- RED: `writing-plans/contracts/` has orphan self-review/structure contracts and is missing handoff/research/verify-plan-pipeline contracts
- GREEN: add handoff, research, verify-plan-pipeline contracts (SC-8a); remove orphan self-review and structure contracts (SC-8b); keep solve-output.yaml (SC-8c)
- verify: glob contracts; assert each of the three atomic SCs independently
- commit: affected `skills/writing-plans/contracts/*` files

### Item 9 (SC-9): Fix holistic-dimensions.yaml cross-references

- RED: `reference/holistic-dimensions.yaml` cross-references deleted monolithic files and nonexistent "Step 0 pre-flight gate" sections
- GREEN: point cross-references to role files (`spec-audit-investigator.md`, `plan-fidelity-investigator.md`); remove "Step 0 pre-flight gate" refs
- verify: read cross-reference entries; assert role-file refs and no Step 0 refs
- commit: `reference/holistic-dimensions.yaml`

### Item 10 (SC-10): Align plan-fidelity-investigator example naming

- RED: `plan-fidelity-investigator.md` example uses `plan-phase-1.md` (non-canonical)
- GREEN: align the example to `plan-01-{slug}.md` in `skills/audit/tasks/plan-fidelity-investigator.md`
- verify: grep for `plan-phase-` returns zero; `plan-01-` used
- commit: `skills/audit/tasks/plan-fidelity-investigator.md`

### Item 11 (SC-11): Align completion.md lifecycle target

- RED: `completion.md` Purpose and Exit Criteria say "issue body" but Step 4 appends to the plan file at `plan.md`
- GREEN: align Purpose and Exit Criteria to "plan file at plan.md" in `skills/writing-plans/tasks/completion.md`
- verify: read Purpose and Exit Criteria; assert "plan file at plan.md"
- commit: `skills/writing-plans/tasks/completion.md`

### Item 12 (SC-12): Align audit TDT field name

- RED: `audit/SKILL.md` TDT plan-fidelity context uses `plan_local_dir`; role files use `spec_local_dir`
- GREEN: change the TDT plan-fidelity context to `spec_local_dir` in `skills/audit/SKILL.md`
- verify: grep for `plan_local_dir` returns zero; TDT uses `spec_local_dir`
- commit: `skills/audit/SKILL.md`

### Item 13 (SC-13): Rewrite plan-fidelity-evaluator to single-plan model

- RED: `plan-fidelity-evaluator.md` uses a stale dual-plan (clean-room vs existing) model
- GREEN: rewrite to a single-plan (plan-vs-spec) model in `skills/audit/tasks/plan-fidelity-evaluator.md`, removing PF-1, PLAN_INCOMPLETE/PLAN_OVERSCOPED/PLAN_DRIFT verdicts, and the "Add phase from clean-room" auto-fix
- verify: grep for clean-room/PLAN_INCOMPLETE/PLAN_OVERSCOPED/PLAN_DRIFT returns zero; behavior test confirms single-plan verdict
- commit: `skills/audit/tasks/plan-fidelity-evaluator.md`

### Item 14 (SC-14): Remove duplicated plan/SKILL.md description clause

- RED: `plan/SKILL.md` description has a duplicated `writing-plans` clause
- GREEN: delete the duplicate clause in `skills/plan/SKILL.md` description
- verify: read description; assert single clause
- commit: `skills/plan/SKILL.md`

### Item 15 (SC-15): Remove executing-plans reference

- RED: `plan/SKILL.md` references the nonexistent `executing-plans` skill
- GREEN: delete the `executing-plans` cross-reference in `skills/plan/SKILL.md`
- verify: grep for `executing-plans` returns zero
- commit: `skills/plan/SKILL.md`

### Item 16 (SC-16): Delete plan-artifact-format.md

- RED: conflicting plan-schema sources exist (`plan-artifact-format.md` string `'1.0'` vs `plan-structure-standards.md` integer `1`)
- GREEN: remove `plan-artifact-format.md` from `writing-plans/SKILL.md` File Structure and delete the file `skills/writing-plans/reference/plan-artifact-format.md`
- verify: read File Structure; assert `plan-artifact-format.md` absent and the file does not exist
- commit: `skills/writing-plans/SKILL.md`, `skills/writing-plans/reference/plan-artifact-format.md`

### Item 17 (SC-17): Fix verify-plan-pipeline audit naming

- RED: `verify-plan-pipeline.md` checks for `audit-fidelity` and `audit-concern` output naming
- GREEN: update to `plan-fidelity` and `concern-separation` in `skills/writing-plans/tasks/verify-plan-pipeline.md`
- verify: grep for `audit-fidelity`/`audit-concern` returns zero; `plan-fidelity`/`concern-separation` used
- commit: `skills/writing-plans/tasks/verify-plan-pipeline.md`

### Item 18 (SC-18): Add discover.md task to plan skill

- RED: `plan/SKILL.md` advertises the `discover` subcommand but no `discover.md` task exists
- GREEN: add `skills/plan/tasks/discover.md` documenting the discover subcommand and reference it in `plan/SKILL.md` File Structure
- verify: file-exists `discover.md`; read it; assert File Structure lists it
- commit: `skills/plan/tasks/discover.md`, `skills/plan/SKILL.md`

### Item 19 (SC-19): Rewrite branch-cleanup.md audit block

- RED: `branch-cleanup.md` dispatches `resolve-models` (no such task), passes `audit_phase: post_merge` (forbidden), and calls `cross-validate` as a separate dispatch
- GREEN: rewrite the audit block in `skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md` to dispatch the closure-verification DiMo chain (Investigator→Validator→Evaluator→Arbiter) with a 2-field contract `{spec_local_dir, artifact_evidence_dir}` and no `audit_phase`
- verify: grep for `resolve-models`/`audit_phase`/`cross-validate` returns zero; behavior test confirms the closure-verification chain
- commit: `skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md`

## 6. Dependencies

- **Reference:** `reference/plan-structure-standards.md` — Relationship: canonical plan-schema source; consumed by SC-3/SC-4 reference-path fixes and SC-16 single-source adoption. Status: satisfied (file exists, unchanged).
- **Reference:** `reference/spec-structure-standards.md` — Relationship: canonical spec structure; consumed by SC-4 audit role-file reference-path fixes. Status: satisfied.
- **Reference:** `reference/cost-model-standards.md` — Relationship: read by `create.md` and plan-fidelity tasks; reference-path fixes (SC-3, SC-4) must preserve these targets. Status: satisfied.
- **Reference:** `reference/holistic-dimensions.yaml` — Relationship: cross-reference target corrected by SC-9. Status: satisfied.
- **Reference:** `skills/audit/tasks/closure-verification/` — Relationship: the closure-verification DiMo chain that SC-19 aligns `branch-cleanup.md` to. Status: satisfied (implementation exists).
- **Reference:** `skills/plan/tasks/` — Relationship: existing plan CLI subcommand task files (ground, pddl, validate, state, plan) that SC-18 extends with `discover.md`. Status: satisfied.

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-3, SC-4 | Phase 2, Phase 1 |
| R-2 | SC-1 | Phase 1 |
| R-3 | SC-2 | Phase 1 |
| R-4 | SC-13 | Phase 1 |
| R-5 | SC-12, SC-19 | Phase 1 |
| R-6 | SC-16 | Phase 2 |
| R-7 | SC-7, SC-8a, SC-8b, SC-8c | Phase 2 |
| R-8 | SC-14, SC-15, SC-18 | Phase 3 |
| R-9 | SC-1 … SC-19 | Phase 1, Phase 2, Phase 3 |
| R-10 | SC-5 | Phase 1 |
| R-11 | SC-6 | Phase 2 |
| R-12 | SC-9 | Phase 1 |
| R-13 | SC-10 | Phase 1 |
| R-14 | SC-11 | Phase 2 |
| R-15 | SC-17 | Phase 2 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| `skills/audit/SKILL.md` | code | `.opencode/skills/audit/SKILL.md` | read/grep |
| `skills/audit/tasks/plan-fidelity-*.md` | code | `.opencode/skills/audit/tasks/` | read/grep |
| `skills/audit/tasks/spec-audit-*.md` | code | `.opencode/skills/audit/tasks/` | read/grep |
| `skills/audit/tasks/verification-audit-*.md` | code | `.opencode/skills/audit/tasks/` | read/grep |
| `skills/audit/tasks/test-quality-audit-arbiter.md` | code | `.opencode/skills/audit/tasks/` | read/grep |
| `skills/writing-plans/SKILL.md` | code | `.opencode/skills/writing-plans/SKILL.md` | read/grep |
| `skills/writing-plans/tasks/create.md` | code | `.opencode/skills/writing-plans/tasks/create.md` | read/grep |
| `skills/writing-plans/tasks/research.md` | code | `.opencode/skills/writing-plans/tasks/research.md` | read/grep |
| `skills/writing-plans/tasks/completion.md` | code | `.opencode/skills/writing-plans/tasks/completion.md` | read/grep |
| `skills/writing-plans/tasks/verify-plan-pipeline.md` | code | `.opencode/skills/writing-plans/tasks/verify-plan-pipeline.md` | read/grep |
| `skills/writing-plans/contracts/` | code | `.opencode/skills/writing-plans/contracts/` | glob |
| `skills/writing-plans/reference/plan-artifact-format.md` | code | `.opencode/skills/writing-plans/reference/` | read |
| `skills/plan/SKILL.md` | code | `.opencode/skills/plan/SKILL.md` | read/grep |
| `skills/plan/tasks/discover.md` | code | `.opencode/skills/plan/tasks/discover.md` | file-exists/read |
| `skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md` | code | `.opencode/skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md` | read/grep |
| `reference/plan-structure-standards.md` | code | `.opencode/reference/plan-structure-standards.md` | read |
| `reference/spec-structure-standards.md` | code | `.opencode/reference/spec-structure-standards.md` | read |
| `reference/cost-model-standards.md` | code | `.opencode/reference/cost-model-standards.md` | read |
| `reference/holistic-dimensions.yaml` | code | `.opencode/reference/holistic-dimensions.yaml` | read |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1: Verifying the cross-validate removal costs one grep plus a behavior test. Skipping means agents dispatch a nonexistent task and the Arbiter consensus authority is undermined.
- SC-2: Verifying the stale monolithic refs are gone costs one grep. Skipping means agents resolve cross-references to deleted files and route blind.
- SC-3: Verifying the reference targets resolve costs one grep. Skipping means the plan writer reads the wrong reference directory and produces structurally wrong plans.
- SC-4: Verifying the reference targets resolve costs one grep. Skipping means the plan auditor reads the wrong reference directory and produces wrong verdicts.
- SC-5: Verifying the artifact mandate is softened costs one read. Skipping means investigators are told to produce artifacts they do not implement.
- SC-6: Verifying the plan invocation costs one read. Skipping means the plan CLI is invoked with unsupported flags and fails.
- SC-7: Verifying the task count costs one read. Skipping means the card claims 7 tasks when 9 exist, misrouting dispatch.
- SC-8a/SC-8b/SC-8c: Verifying contract symmetry costs one glob per atomic SC. Skipping means pipeline artifact validation reads missing contracts or orphan contracts.
- SC-9: Verifying the holistic-dimensions refs costs one read. Skipping means cross-references point to deleted files.
- SC-10: Verifying the example naming costs one grep. Skipping means agents produce non-canonical plan filenames.
- SC-11: Verifying the completion target costs one read. Skipping means the completion lifecycle appends to the wrong artifact.
- SC-12: Verifying the TDT field costs one grep. Skipping means the TDT and role files disagree on the dispatch contract field.
- SC-13: Verifying the single-plan model costs one grep plus a behavior test. Skipping means the evaluator compares against a stale clean-room plan that no longer exists.
- SC-14: Verifying the description clause costs one read. Skipping means the card description is duplicated and confusing.
- SC-15: Verifying the dead reference removal costs one grep. Skipping means agents resolve to a nonexistent skill.
- SC-16: Verifying the schema single-source costs one read plus a file-exists check. Skipping means two conflicting plan-schema sources remain and producers/auditors disagree.
- SC-17: Verifying the audit naming costs one grep. Skipping means the pipeline validator checks for the wrong artifact names.
- SC-18: Verifying the discover task costs one file-exists plus a read. Skipping means the card advertises a subcommand with no task documentation.
- SC-19: Verifying the closure-verification dispatch costs one grep plus a behavior test. Skipping means the post-merge audit dispatches a nonexistent task with a forbidden field.

## 11. Edge Cases

- **Input boundaries:** Empty or missing reference files — Expected: `Read [Text](path)` targets must resolve to existing files; if a target file is absent, the fix must point to the correct existing canonical file. Resolution: SC-3, SC-4 verify target resolution.
- **State transitions:** Reference-source transition — Expected: after SC-3/SC-4, all reference targets point to consolidated `.opencode/reference/`; skill-local `reference/` dirs no longer hold canonical content. Resolution: SC-3, SC-4 verification asserts the transition.
- **Failure modes:** A reference-doc removal (SC-16) could break a consumer if a task reads the deprecated file. Resolution: verify no task reads the deprecated file before removal; SC-16 verified by File Structure and file-exists check.
- **Concurrency:** Phase 1 (audit) and Phase 2 (writing-plans) share canonical reference targets; Phase 3 (plan CLI) is independent. Resolution: phase ordering keeps Phase 1 and Phase 2 sequential; Phase 3 depends on nothing.
- **Recovery:** If a behavioral verification (SC-1, SC-13, SC-19) cannot execute, the SC is FAIL per the functional/behavioral test substitution prohibition. Resolution: remediate and re-run; no structural substitute.

---

## 12. Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-08-05 | Initial spec creation from analysis artifacts | Assemble remediation spec for 8 skill-card-set consistency defects | spec-creation create gate |
| 2026-08-05 | Scope-correction revision: rebuilt spec body, analytical artifacts, and remote issue to the correct Plan Writer and Plan Audit scope (19 findings F1–F19) | SEVERE SCOPE DEFECT — the prior spec #2250 carried the wrong scope (spec-writer/spec-audit, 8 SCs); the intended scope is plan-writer/plan-audit with 19 internal-consistency findings | spec-creation revise gate |
| 2026-08-05 | Validation-findings revision: decomposed SC-8 into atomic SC-8a/SC-8b/SC-8c (one verification target each); made SC-16 single-valued (delete, not "deleted OR reduced to a pointer"); added dedicated requirements R-10–R-15 for SC-5/6/9/10/11/17 to resolve umbrella-only traceability | spec-creation validate gate findings (atomicity, determinism, traceability) | spec-creation revise gate |

---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
