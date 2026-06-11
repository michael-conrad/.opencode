# Plan: [#1110](https://github.com/michael-conrad/.opencode/issues/1110) — Pipeline-readiness gate in spec-creation + mandatory checklist generation in writing-plans

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

**Plan structure decision:** separate (multi-task spec with 4 phases across dependent concern boundaries)

**Reason:** Phase 1 creates the pipeline-readiness gate artifact. Phase 2 and Phase 3 modify the same skill (writing-plans plan-structure.md) at different procedural positions — Step 0.5 and Step 6. Phase 4 updates both SKILL.md files and depends on all prior phases.

**Implementation checklist:** [`implementation-checklist.md`](implementation-checklist.md) — MUST be followed step-by-step during implementation. Every phase executes the 14-gate implementation pipeline with sub-steps defined in the checklist.

## All-or-Nothing Gate

All SC-1 through SC-13 must PASS for this spec to be complete. Phase gates: Phase 2 requires Phase 1 complete. Phase 3 requires Phase 1 complete. Phase 4 requires Phase 1, Phase 2, and Phase 3 complete.

---

## Phase 1 — Create pipeline-readiness gate in spec-creation

**Concern:** New task file. Files: `.opencode/skills/spec-creation/tasks/pipeline-readiness-gate.md` (new), `.opencode/skills/spec-creation/SKILL.md` (modified).

**Dependencies:** None.

### TDD Items

#### Item 1.1: Create pipeline-readiness-gate.md task file

**RED:** Task file does not exist. No pipeline-readiness gate runs after SC definition.

**GREEN:** `pipeline-readiness-gate.md` created with four-check procedure:
- PR-1 SC atomicity verification
- PR-2 SC dependency DAG verification via `solve prove`
- PR-3 Single concern verification
- PR-4 Phase dependency DAG verification via `solve prove`

Outputs `sc-pipeline-readiness.yaml` with status PASS/FAIL, check results, and `sc_summary`.

**Exit criteria:** SC-1 (file exists), SC-2 (produces artifact), SC-3 (PR-1 flags bundled SCs), SC-4 (PR-2 verified via solve), SC-5 (PR-4 verified via solve).

#### Item 1.2: Update spec-creation/SKILL.md tasks table

**RED:** SKILL.md tasks table does not list `pipeline-readiness-gate`.

**GREEN:** Task entry added. Symbolic rule `spec-creation-pipeline-readiness` added.

**Exit criteria:** SC-6 (grep for task in SKILL.md).

### Phase 1 Pipeline Gate Table

| Gate | Name | Exit Criterion |
|------|------|----------------|
| 1 | sc-coherence-gate | Scope confirmed: new task file in spec-creation, no overlap with existing decompose/write tasks |
| 2 | pre-red-baseline | Verify no existing pipeline-readiness gate in spec-creation tasks |
| 3 | red-phase | Behavioral RED: spec finalization proceeds without pipeline-readiness check |
| 4 | red-doublecheck | RED-side evidence for SC-1 through SC-6 |
| 5 | green-phase | Task file created, SKILL.md updated, symbolic rule added |
| 6 | checkpoint-commit | Committed |
| 7 | structural-checks | `pymarkdownlnt`, `mdformat` on task file |
| 8 | green-doublecheck | SC-1 through SC-6 verified |
| 9 | green-vbc | All Phase 1 SCs verified |
| 10 | adversarial-audit | Dual-auditor: four-check procedure correct, output YAML schema valid |
| 11 | cross-validate | Consensus |
| 12 | regression-check | Existing spec-creation behavioral tests pass |
| 13 | review-prep | Summary |
| 14 | exec-summary | Push + comment |

---

## Phase 2 — Add hard-gate check in writing-plans

**Concern:** Plan-structure.md modification. Files: `.opencode/skills/writing-plans/tasks/create/plan-structure.md`.

**Dependencies:** Phase 1 complete (sc-pipeline-readiness.yaml artifact must exist in spec-artifacts).

### TDD Items

#### Item 2.1: Add Step 0.5 pipeline-readiness gate check

**RED:** Plan-structure Step 1 (read approved spec) is the first step after verification gate. No check for sc-pipeline-readiness.yaml exists.

**GREEN:** Step 0.5 inserted between Step 0 (verification gate) and Step 1. Checks `.issues/{N}/spec-artifacts/sc-pipeline-readiness.yaml` for `status: PASS`. Halts with `SPEC_NOT_READY_FOR_PIPELINE` on FAIL/missing.

**Exit criteria:** SC-7 (step exists), SC-8 (halt on missing artifact).

### Phase 2 Pipeline Gate Table

| Gate | Name | Exit Criterion |
|------|------|----------------|
| 1 | sc-coherence-gate | Step 0.5 position confirmed — between verification gate and spec read, no ordering conflict |
| 2 | pre-red-baseline | Verify plan-structure.md current state (no Step 0.5) |
| 3 | red-phase | Behavioral RED: plan creation proceeds without Step 0.5 check |
| 4 | red-doublecheck | RED-side evidence for SC-7, SC-8 |
| 5 | green-phase | Step 0.5 added with hard-gate logic |
| 6 | checkpoint-commit | Committed |
| 7 | structural-checks | `pymarkdownlnt` on plan-structure.md |
| 8 | green-doublecheck | SC-7 (string: step exists), SC-8 (behavioral: halt on missing) |
| 9 | green-vbc | All Phase 2 SCs verified |
| 10 | adversarial-audit | Dual-auditor: hard gate is non-bypassable, SPEC_NOT_READY_FOR_PIPELINE message clear |
| 11 | cross-validate | Consensus |
| 12 | regression-check | Existing writing-plans behavioral tests pass |
| 13 | review-prep | Summary |
| 14 | exec-summary | Push + comment |

---

## Phase 3 — Mandatory implementation checklist generation

**Concern:** Plan-structure.md modification. Files: `.opencode/skills/writing-plans/tasks/create/plan-structure.md`.

**Dependencies:** Phase 1 complete (uses sc-pipeline-readiness.yaml phase/SC data).

### TDD Items

#### Item 3.1: Add Step 6 mandatory checklist generation

**RED:** No step for implementation-checklist.md generation exists. Checklist is created ad-hoc or not at all.

**GREEN:** Step 6 added after plan content is finalized. Generates `implementation-checklist.md` with:
- 14-gate checklist per phase with sub-steps (pre-cleanup, dispatch, Z3 state update, checkpoint tag, lifecycle manifest)
- Remediation routing section (R.1-R.10)
- Phase completion section (PC.1-PC.6)
- Overall completion section (OC.1-OC.7)
- Key constraints section
- SC coverage verification

**Exit criteria:** SC-9 (generation step exists), SC-10 (lifecycle/tag/re-validation patterns), SC-11 (SC coverage verified).

### Phase 3 Pipeline Gate Table

| Gate | Name | Exit Criterion |
|------|------|----------------|
| 1 | sc-coherence-gate | Step 6 position confirmed — after all plan content finalized |
| 2 | pre-red-baseline | Verify no checklist generation step exists |
| 3 | red-phase | Behavioral RED: plan created without checklist |
| 4 | red-doublecheck | RED-side evidence for SC-9, SC-10, SC-11 |
| 5 | green-phase | Step 6 added with full checklist generation procedure |
| 6 | checkpoint-commit | Committed |
| 7 | structural-checks | `pymarkdownlnt`, word count check (must stay under 3,000) |
| 8 | green-doublecheck | SC-9 (string: step), SC-10 (string: patterns), SC-11 (behavioral: coverage) |
| 9 | green-vbc | All Phase 3 SCs verified |
| 10 | adversarial-audit | Dual-auditor: checklist structure matches existing examples (#1107, #1108), no missing sections |
| 11 | cross-validate | Consensus |
| 12 | regression-check | Existing writing-plans behavioral tests pass |
| 13 | review-prep | Summary |
| 14 | exec-summary | Push + comment |

---

## Phase 4 — Update skill SKILL.md files

**Concern:** SKILL.md modifications. Files: `.opencode/skills/spec-creation/SKILL.md`, `.opencode/skills/writing-plans/SKILL.md`.

**Dependencies:** Phase 1, Phase 2, Phase 3 complete.

### TDD Items

#### Item 4.1: Add operating protocol items and symbolic rules to both SKILL.md files

**RED:** No pipeline-readiness symbolic rules in either SKILL.md. spec-creation does not mandate the gate. writing-plans does not require checklist.

**GREEN:** Both SKILL.md files updated:
- spec-creation: symbolic rule `spec-creation-pipeline-readiness`
- writing-plans: operating protocol item + symbolic rule `writing-plans-pipeline-readiness`

**Exit criteria:** SC-12 (grep for symbolic rule IDs), SC-13 (behavioral test — spec finalization without gate triggers HALT).

### Phase 4 Pipeline Gate Table

| Gate | Name | Exit Criterion |
|------|------|----------------|
| 1 | sc-coherence-gate | Both SKILL.md files identified, no rule ID collision with existing symbolic rules |
| 2 | pre-red-baseline | Verify no pipeline-readiness rules exist in either SKILL.md |
| 3 | red-phase | Behavioral RED: agents skip pipeline-readiness gate when creating specs |
| 4 | red-doublecheck | RED-side evidence for SC-12, SC-13 |
| 5 | green-phase | Both SKILL.md files updated with rules and protocol items |
| 6 | checkpoint-commit | Committed |
| 7 | structural-checks | `pymarkdownlnt` and `mdformat` on both SKILL.md files |
| 8 | green-doublecheck | SC-12 (string: symbolic rule IDs present), SC-13 (behavioral: gate enforced) |
| 9 | green-vbc | All Phase 4 SCs verified |
| 10 | adversarial-audit | Dual-auditor: rules are enforceable, not advisory; no scope creep |
| 11 | cross-validate | Consensus |
| 12 | regression-check | Existing behavioral tests for both skills pass |
| 13 | review-prep | Full review-prep |
| 14 | exec-summary | Final push + issue comment |

---

## SC-ID Traceability

| SC-ID | Phase | Item | Evidence Type | Depends On | Verification |
|-------|-------|------|---------------|------------|-------------|
| SC-1 | 1 | 1.1 | structural | — | File existence |
| SC-2 | 1 | 1.1 | behavioral | — | Run gate, verify artifact |
| SC-3 | 1 | 1.1 | behavioral | SC-1 | Test atomic/non-atomic SCs |
| SC-4 | 1 | 1.1 | behavioral | SC-1 | Verify solve prove artifacts |
| SC-5 | 1 | 1.1 | behavioral | SC-1 | Verify phase ordering |
| SC-6 | 1 | 1.2 | string | — | grep for task in SKILL.md |
| SC-7 | 2 | 2.1 | string | SC-1 | grep for step in plan-structure.md |
| SC-8 | 2 | 2.1 | behavioral | SC-1 | `opencode-cli run` prompt |
| SC-9 | 3 | 3.1 | string | SC-1 | grep for generation step |
| SC-10 | 3 | 3.1 | string | SC-9 | grep for lifecycle/tag/prove patterns |
| SC-11 | 3 | 3.1 | behavioral | SC-9 | Generate from known plan |
| SC-12 | 4 | 4.1 | string | SC-1, SC-7, SC-9 | grep for symbolic rule IDs |
| SC-13 | 4 | 4.1 | behavioral | SC-12 | `opencode-cli run` |

---

## Z3 Contract Reference

Phase ordering contract: [`.issues/1110/spec-artifacts/dependency-ordering-verification/ordering.yaml`](../dependency-ordering-verification/ordering.yaml)

- All-phases SAT: `z3.And(P1_DONE, P2_DONE, P3_DONE, P4_DONE)` → **SAT** (verified)
- P4_DONE → P1_DONE AND P2_DONE AND P3_DONE: **VALID** (prove)
- Phase ordering invariants: P2/P3 depend on P1. P4 depends on P1/P2/P3.

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)