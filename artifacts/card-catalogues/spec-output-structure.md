# Spec Output Structure Expansion — Master Card Catalogue

Coordination parent: [#850](https://github.com/michael-conrad/.opencode/issues/850)
Foundation plan: [#854](https://github.com/michael-conrad/.opencode/issues/854)

**Dependency order:** #848 → #853 → #849 → #850 → #1060 → #1061 → #1062 → #1063 → #1064

---

## Issue #850 — [SPEC-COORD] Spec/Plan Writer Enforcement Style and Output Structure — Parent Coordination
**Status:** spec | **Scope:** Enforcement-text-style injection only (narrowed from original scope); coordination parent for 5 sibling specs
**Dependencies:** [#849](https://github.com/michael-conrad/.opencode/issues/849) (co-application policy)
**Items Covered:** 1, 5, 6

| Item | Description | Skill Affected | File |
|------|-------------|----------------|------|
| 1 | Enforcement text style gate (pre-pipeline, between approval-gate and sc-coherence-gate) | spec-creation, approval-gate | `skills/spec-creation/tasks/write.md` |
| 5 | Pre-pipeline enforcement text style scan in spec-auditor (per-section pattern compliance) | adversarial-audit | `skills/adversarial-audit/tasks/spec-audit.md` |
| 6 | Distribution-shifting reference card integration (#848) | spec-creation | `skills/spec-creation/SKILL.md` |

---

## Issue #1060 — [SPEC] Spec Structure Expansion — SC Table Columns, Preamble Sections, Self-Review Checks
**Status:** spec | **Scope:** Expands spec-creation `write.md` with new SC table columns, preamble sections, mandatory content areas, and self-review checks
**Dependencies:** [#850](https://github.com/michael-conrad/.opencode/issues/850)
**Items Covered:** 3, 8, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 31, 32, 34, 40, 41, 42

| Item | Description | Skill Affected | File |
|------|-------------|----------------|------|
| 3 | Explicit Non-Goals section (mandatory content area) | spec-creation | `skills/spec-creation/tasks/write.md` |
| 8 | Regression Invariants subsection (mandatory content area) | spec-creation | `skills/spec-creation/tasks/write.md` |
| 11 | Pipeline Step Binding column (new SC table column) | spec-creation | `skills/spec-creation/tasks/write.md` |
| 12 | Artifact Path column (new SC table column) | spec-creation | `skills/spec-creation/tasks/write.md` |
| 13 | Requirement Traceability column (new SC table column, mandatory all tiers) | spec-creation | `skills/spec-creation/tasks/write.md` |
| 14 | Decision Ledger preamble section (stable DEC-IDs with RFC 2119 keys) | spec-creation | `skills/spec-creation/tasks/write.md` |
| 15 | Risk Traceability Table preamble section (RISK-IDs with Verifying SC binding) | spec-creation | `skills/spec-creation/tasks/write.md` |
| 16 | SC-to-SC coherence check (self-review substep) | spec-creation | `skills/spec-creation/tasks/write.md` |
| 17 | Revision Policy preamble section (artifact cascade declarations) | spec-creation | `skills/spec-creation/tasks/write.md` |
| 18 | Decomposition Classification preamble section (single-task/multi-phase) | spec-creation | `skills/spec-creation/tasks/write.md` |
| 19 | Phase Binding column (new SC table column, multi-phase only) | spec-creation | `skills/spec-creation/tasks/write.md` |
| 20 | Verification Gate column (new SC table column, 3 tiers) | spec-creation | `skills/spec-creation/tasks/write.md` |
| 31 | Integration Mode column (new SC table column, required when Gate=ci) | spec-creation | `skills/spec-creation/tasks/write.md` |
| 32 | Spec Family Annotation preamble section (optional punch list selector) | spec-creation | `skills/spec-creation/tasks/write.md` |
| 34 | Common/Cross-Cutting SC designation (mandatory content area) | spec-creation | `skills/spec-creation/tasks/write.md` |
| 40 | Affinity Group column (new SC table column, optional) | spec-creation | `skills/spec-creation/tasks/write.md` |
| 41 | Verification-Method-to-Artifact-Path consistency (self-review substep) | spec-creation | `skills/spec-creation/tasks/write.md` |
| 42 | Re-Entry Step column (new SC table column, all tiers) | spec-creation | `skills/spec-creation/tasks/write.md` |

---

## Issue #1061 — [SPEC] Artifact Infrastructure — SC Coverage YAML, Solve/Plan Integration, Contracts, Manifest, Retention
**Status:** spec | **Scope:** Adds structured artifact layer: machine-parseable SC coverage YAML, solve/plan utility invocations, pre-approval gate contract, dependency-ordering contracts, lifecycle manifest, blocker documentation, retention policy
**Dependencies:** [#1060](https://github.com/michael-conrad/.opencode/issues/1060)
**Items Covered:** 10, 21, 22, 24, 29, 30, 33, 35, 37

| Item | Description | Skill Affected | File |
|------|-------------|----------------|------|
| 10 | Dependency-ordering solve contracts (phase ordering as Z3 inequality constraints) | spec-creation, writing-plans | `skills/spec-creation/tasks/write.md`, `skills/writing-plans/tasks/create.md` |
| 21 | Pre-approval gate solve contract (expanded for new columns) | spec-creation | `skills/spec-creation/tasks/write.md` |
| 22 | Solve contract for constraints ledger / plan for decomposition validation | spec-creation | `skills/spec-creation/tasks/write.md` |
| 24 | SC coverage summary YAML (machine-parseable, schema-validated via solve) | spec-creation | `skills/spec-creation/tasks/write.md` |
| 29 | Revision re-entry protocol (solve contract at spec-artifacts/revision-re-entry-contract.yaml) | spec-creation | `skills/spec-creation/tasks/write.md` |
| 30 | Retention policy (`./tmp/{issue-N}/` → PR merge; `.issues/.../spec-artifacts/` → permanent) | spec-creation, writing-plans | Both tasks |
| 33 | Lifecycle manifest (append-only `.issues/{N}/spec-artifacts/lifecycle.yaml`) | spec-creation | `skills/spec-creation/tasks/write.md` |
| 35 | Blocker documentation (blocker events appended to lifecycle manifest) | spec-creation | `skills/spec-creation/tasks/write.md` |
| 37 | Verification consistency solve contract (Evidence Type × Verification Gate compliance matrix) | spec-creation | `skills/spec-creation/tasks/write.md` |

---

## Issue #1062 — [SPEC] Handoff Gates — Spec-to-Plan, Plan-to-Pipeline, SC Close-Out, Revision Re-Entry
**Status:** spec | **Scope:** Adds boundary verification gates between spec-creation → writing-plans → pipeline with formal handoff manifests, consistency checks, SC close-out verification, spec revision re-entry protocol
**Dependencies:** [#1061](https://github.com/michael-conrad/.opencode/issues/1061)
**Items Covered:** 26, 27, 28, 38

| Item | Description | Skill Affected | File |
|------|-------------|----------------|------|
| 26 | Spec-to-Plan Handoff — plan author verifies all spec artifacts before creating plan | writing-plans | `skills/writing-plans/tasks/create.md` |
| 27 | Plan-to-Pipeline Handoff — pipeline verifies plan structurally complete before RED-phase | implementation-pipeline | `skills/implementation-pipeline/SKILL.md` |
| 28 | SC Close-Out Verification — exec-summary confirms every SC-ID received PASS | verification-before-completion | `skills/verification-before-completion/tasks/completion.md` |
| 38 | Handoff Consistency Check — compares spec-to-plan vs plan-to-pipeline manifests (SC count, phase count, decomposition) | implementation-pipeline | `skills/implementation-pipeline/SKILL.md` |

---

## Issue #1063 — [SPEC] Pipeline Enforcement — Evidence Uplift, Doc-Source Check, SC Traceability, Anti-Merge, SC-ID Format
**Status:** spec | **Scope:** Adds 6 enforcement gates to the 14-step implementation pipeline and TDD task definitions. Structural checks only — no new model calls.
**Dependencies:** [#1062](https://github.com/michael-conrad/.opencode/issues/1062)
**Items Covered:** 2, 4, 7, 9, 36, 39

| Item | Description | Skill Affected | File |
|------|-------------|----------------|------|
| 2 | Evidence-Type Uplift Scan — sc-coherence-gate validates SC evidence type vs substrate classification | implementation-pipeline | `skills/implementation-pipeline/SKILL.md` |
| 4 | Doc-Source-Currency Check — pre-red-baseline re-verifies spec documentation sources | implementation-pipeline | `skills/implementation-pipeline/SKILL.md` |
| 7 | SC-ID Traceability — pre-red-baseline verifies all spec SC-IDs have plan references | implementation-pipeline | `skills/implementation-pipeline/SKILL.md` |
| 9 | Semantic-Intent Verification — green-doublecheck confirms PASS satisfies semantic intent | implementation-pipeline | `skills/implementation-pipeline/SKILL.md` |
| 36 | RED/GREEN Anti-Merge — post-red `git diff --name-only -- src/` FAIL; post-green `git diff --name-only -- test/` FAIL | implementation-pipeline | `skills/implementation-pipeline/SKILL.md` |
| 39 | SC-ID Referencing Format — `### TDD-<N>: <description> (SC-1, SC-2)` mandatory format | implementation-pipeline | `skills/implementation-pipeline/SKILL.md` |

---

## Issue #1064 — [SPEC] Writing-Plans Consumer Awareness of Expanded Spec Structure
**Status:** spec | **Scope:** Updates writing-plans tasks to consume expanded spec SC table columns, preamble sections, and spec-artifacts directory. Plan author reads structured fields instead of parsing spec body prose.
**Dependencies:** [#1060](https://github.com/michael-conrad/.opencode/issues/1060), [#1061](https://github.com/michael-conrad/.opencode/issues/1061), [#1063](https://github.com/michael-conrad/.opencode/issues/1063)
**Items Covered:** 25 (item 23 in original 42-item list)

| Item | Description | Skill Affected | File |
|------|-------------|----------------|------|
| 25 | Structured consumption of 8 expanded fields + 7 cross-reference validation checks | writing-plans | `skills/writing-plans/tasks/create/plan-structure.md`, `skills/writing-plans/tasks/create/create-and-validate.md` |

---

## Issue #854 — [PLAN] Reference Card Architecture + Spec Output Structure — Updated Coordination
**Status:** plan | **Scope:** Foundation coordination plan — defines the 5-layer architecture (0: Reference Cards, 1: Policy, 2: Enforcement Style + Spec Output, 3: Artifact Infrastructure, 4: Boundary Gates, 5: Pipeline + Plan Enforcement)
**Dependencies:** None (foundation plan)
**Items Covered:** Foundation coordination — no 42-item analysis items directly

| Item | Description | Skill Affected | File |
|------|-------------|----------------|------|
| — | Layer architecture definition and dependency graph | All affected skills | Cross-cutting coordination |
| — | Full dependency graph with ordering constraints | N/A | `.issues/854/spec-artifacts/cards.md` |