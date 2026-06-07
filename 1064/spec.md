<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# [SPEC] Writing-Plans Consumer Awareness of Expanded Spec Structure

> **Spec folder:** `.opencode/.issues/1064/spec.md`
> **Repo:** michael-conrad/.opencode
> **Parent coordination:** #850

## Intent and Executive Summary

- **Problem Statement**: The writing-plans `create/plan-structure` and `create/create-and-validate` tasks read the spec body as prose — they extract objectives, constraints, and success criteria from free-form text. The expanded spec structure (from #1060) adds 8 new SC table columns (Pipeline Step Binding, Phase Binding, Verification Gate, Artifact Path, Requirement Traceability, Integration Mode, Affinity Group, Re-Entry Step), 5 preamble sections (Decision Ledger, Risk Traceability, Revision Policy, Decomposition Classification, Spec Family), and 3 mandatory content areas (Explicit Non-Goals, Regression Invariants, Common SC Designation). The plan author has no substeps to consume these structured fields.
- **Root Cause / Motivation**: The `plan-structure` and `create-and-validate` tasks were written before the spec-output requirements analysis identified how plan creation must consume the expanded spec. Currently the plan author reads the SC table and guesses — there is no mandatory substep to map each SC-ID to a phase and TDD task, no cross-reference validation that every spec SC-ID has a plan task, and no consumption of structured fields like Pipeline Step Binding or Verification Gate. The result is plans that pass approval but fail handoff verification because the plan-to-pipeline handoff (item 27) finds SC-IDs in the spec with no corresponding TDD task, or phase assignments that contradict the spec's Phase Binding column.
- **Approach Chosen**: Add 2 new substeps — one in `plan-structure` (Step 2: SC Table Structured Consumption) and one in `create-and-validate` (Step 4: Cross-Reference Validation). Both are behavioral changes: the plan author must actively read structured columns from the spec SC table and validate against them. The existing pipeline steps (Step 2 file structure mapping, Step 3 item decomposition) shift by one index to accommodate the new structured-consumption step.
- **Alternatives Considered & Why Discarded**: (1) Parse the spec SC coverage YAML — discarded because the YAML (item 24) is not yet mandatory and may not exist for specs written before the expanded structure is normalized. (2) Add a single monolithic substep — discarded per incremental build discipline; the substeps naturally separate into consumption (plan-structure) and validation (create-and-validate). (3) Delegate cross-reference validation to the plan-to-pipeline handoff — discarded because the handoff verifies plan-vs-spec, but the plan author should catch gaps before the plan enters the pipeline.
- **Key Design Decisions**: The structured consumption substep maps SC-IDs to phases, TDD tasks, and verification gates — it does NOT re-create binding information. The plan passes through Pipeline Step Binding and Verification Gate from the spec. The cross-reference validation substep performs 7 checks against the spec's SC table, Decision Ledger, and Risk Traceability. If any check fails, the plan is blocked — it does not enter the pipeline.

## Objective

Add structured spec SC table consumption to `plan-structure.md` (8-field mapping) and cross-reference validation to `create-and-validate.md` (7 checks) so that plans produced by writing-plans are guaranteed to cover every spec success criterion with correctly bound pipeline stages.

## Problem

The writing-plans `create/plan-structure.md` task currently reads the spec SC table as prose — it extracts success criteria via natural language reading (Step 1: "Extract objectives, constraints, success criteria"). There is no mandatory substep to:

1. Map each spec SC-ID to a specific plan phase
2. Associate each SC-ID with a TDD task that verifies it
3. Read the Pipeline Step Binding column and preserve it through to the plan's verification dispatcher mapping
4. Read the Phase Binding column and validate plan phase ordering against it
5. Read the Verification Gate column — the plan must not override gate selection
6. Read the Artifact Path column — verification steps write to declared paths
7. Read the Risk Traceability table — each phase's risk analysis must reference spec RISK-IDs
8. Read the Decision Ledger — plan phases must not contradict DEC-IDs
9. Consume the Decomposition Classification (single-task vs multi-phase) — drives combined/separate format decision

The `create/create-and-validate.md` task performs a self-review (Step 8) and plan validation (Step 9) but neither step verifies that every spec SC-ID has a corresponding TDD task or plan phase reference. The result: plans pass create-and-validate but fail the plan-to-pipeline handoff (item 27 of the analysis) when the pipeline executor globs TDD task headings for SC-IDs and finds gaps.

The gap was surfaced by item 23 of the spec-output requirements analysis. Without this change, the writing-plans output will consistently fail plan-to-pipeline handoff for any spec using the expanded SC table from #1060.

## Context

The `plan-structure.md` task (185 lines) currently has 7 steps: Pre-Step (verification-enforcement), Step 1 (read spec), Step 1.5 (combined/separate decision), Step 1.6 (duplicate plan check), Step 2 (file structure mapping), Step 3 (item decomposition), Step 3.5 (RED/GREEN condition language), Step 4 (phase structure), Step 5 (define tasks). The new structured-consumption substep inserts between Step 1.6 and Step 2, shifting Steps 2-5 to Steps 3-6.

The `create-and-validate.md` task (163 lines) currently has 8 steps: Step 6 (write header), Step 7 (store plan), Step 6a (create sub-issues), Step 8 (self-review), Step 9 (validate), Step 10 (verification revisit), Step 11 (report), Step 12 (cross-reference verification), Step 13 (approval cascade). The new cross-reference validation substep inserts after Step 9 (validate), shifting Steps 10-13 to Steps 11-14.

Parent coordination: [#850](https://github.com/michael-conrad/.opencode/issues/850) tracks the full spec-output requirements initiative. This spec is the final dependency in the chain (#848 → #853 → #849 → #850 → #1060 → #1061 → #1062 → #1063 → #1064).

## Affected Files

| File | Nature of Change |
|------|-----------------|
| `.opencode/skills/writing-plans/tasks/create/plan-structure.md` | Add Step 2: SC Table Structured Consumption (maps each spec SC-ID to plan phase, TDD task, and verification gate). Shifts existing Steps 2-5 to Steps 3-6. |
| `.opencode/skills/writing-plans/tasks/create/create-and-validate.md` | Add Step 4: Cross-Reference Validation (7 checks: every spec SC-ID has TDD task reference, no phantom SC-IDs, phase assignments match Phase Binding, Pipeline Step Binding preserved, no DEC-ID contradiction, every RISK-ID with Verifying SC has mitigation, combined/separate matches Decomposition Classification). Shifts existing Steps 10-13 to Steps 11-14. |

## Explicit Non-Goals

1. The spec SC table's expanded columns (Pipeline Step Binding, Phase Binding, Verification Gate, Artifact Path, etc.) are defined and produced by #1060 — this spec only consumes them. No changes to spec-creation tasks.
2. The SC coverage YAML (item 24) is consumed by the plan-to-pipeline handoff (item 27), not by plan-structure. This spec reads from the prose SC table only.
3. No changes to the plan-to-pipeline handoff (item 27) or handoff manifests (items 26-27). The plan-structure and create-and-validate changes are upstream of those gates.
4. No changes to the combined/separate plan decision logic (Step 1.5). The consumption substep reads the Decomposition Classification to verify the decision, not to make it.
5. No changes to the per-unit pipeline gate tables (Step 5 per-unit gates). The SC-to-phase mapping is at the planning level, not the per-unit execution level.

## Regression Invariants

1. The existing Step 1 (read approved spec) remains unchanged — structured consumption is ADDITIONAL, not replacement.
2. The existing Step 1.5 (combined/separate decision) and Step 1.6 (duplicate plan check) retain their positions and logic.
3. The existing per-unit pipeline gate tables (Step 5 per-unit gates, SC-3) must remain in each unit — structured consumption does not replace them.
4. The existing Z3 contract generation (Step 5 Z3 contracts, SC-7) must remain per-unit.
5. The existing Step 12 cross-reference verification (checks referenced skills exist) must remain in create-and-validate.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Pipeline Step | Re-Entry Step |
|----|-----------|---------------|---------------------|---------------|---------------|
| SC-1 | `plan-structure.md` contains a Step 2 sub-step titled "SC Table Structured Consumption" that reads the spec's SC table and maps each SC-ID to a corresponding plan phase, TDD task (by task heading), and verification gate | `behavioral` | Plan author processes a spec with 4+ SCs across 2 phases; verify the resulting plan body references every SC-ID in a phase description or TDD task heading | spec-auditor (post-spec) | spec-creation |
| SC-2 | The structured consumption substep reads 8 fields from the spec SC table and documents each: SC-ID → phase mapping, Pipeline Step Binding → verification dispatcher passthrough, Phase Binding → phase ordering validation, Verification Gate → method selection passthrough, Artifact Path → verification output destination, Risk Traceability → phase risk analysis binding, Decision Ledger → design constraint compliance, Decomposition Classification → format decision verification | `behavioral` | Plan author processes a spec with all 8 fields populated; verify plan body references each consumed field (e.g., phase description references a RISK-ID, TDD task heading references an SC-ID, format decision includes justification matching Decomposition Classification) | spec-auditor (post-spec) | spec-creation |
| SC-3 | The structured consumption substep does NOT re-create Pipeline Step Binding or Verification Gate values — it reads them from the spec SC table and passes them through to the plan's verification dispatcher mapping | `behavioral` | Plan author processes a spec with Pipeline Step Binding and Verification Gate columns; verify the plan does NOT define new gate values or reassign step bindings (plan body references spec values via SC-ID mapping only) | spec-auditor (post-spec) | spec-creation |
| SC-4 | The structured consumption substep consumes the Phase Binding column from the spec and validates that the plan phase ordering matches — SC-IDs assigned to Phase 1 appear only in Phase 1 plan sections, SC-IDs assigned to Phase 2 appear in Phase 2 sections, and any SC-ID assigned to a phase that does not exist in the plan is flagged | `behavioral` | Plan author processes a spec with SC-1→Phase 1 and SC-2→Phase 2 bindings; verify plan body places SC-1 in Phase 1 section and SC-2 in Phase 2 section; test with a SC assigned to Phase 3 (non-existent) → plan author must flag the gap | spec-auditor (post-spec) | spec-creation |
| SC-5 | The structured consumption substep consumes the Artifact Path column: each TDD task's verification step writes output to the declared artifact path for the SC-IDs it covers (using the `./tmp/{issue-N}/` convention from the spec) | `behavioral` | Plan author processes a spec with Artifact Path column; verify the plan body's verification step descriptions reference declaring artifact paths (e.g., "write PASS artifact to SC-<ID> path") | spec-auditor (post-spec) | spec-creation |
| SC-6 | `plan-structure.md` entry criteria include a precondition that the spec's SC table is readable (at minimum: SC-ID, Criterion, and at least one of Pipeline Step Binding or Phase Binding columns present) — if absent, the plan author returns BLOCKED with reason `SPEC_SC_TABLE_UNREADABLE` | `behavioral` | Plan author encounters a spec whose SC table has only ID + Criterion columns (no binding columns); verify the plan author returns BLOCKED and does not proceed | spec-auditor (post-spec) | spec-creation |
| SC-7 | `create-and-validate.md` contains a Step 4 titled "Cross-Reference Validation" that performs all 7 validation checks before the plan enters the pipeline | `behavioral` | Plan author has a spec with 6 SCs but the plan covers only 4; verify the plan document includes a cross-reference validation section with the 3 failing checks documented and an OVERALL: BLOCKED status | spec-auditor (post-spec) | spec-creation |
| SC-8 | The cross-reference validation check verifies every spec SC-ID has at least one TDD task that references it (by heading or body text) — any SC-ID in the spec SC table not referenced in the plan body is a FAIL | `behavioral` | Plan covers only 4 of 6 spec SC-IDs; verify the plan's cross-reference validation reports 2 MISSING-TRACEABILITY findings and blocks pipeline entry | plan-to-pipeline-handoff | sc-coherence-gate |
| SC-9 | The cross-reference validation check verifies every SC-ID referenced by a TDD task actually exists in the spec SC table — phantom SC-IDs (referenced in plan but absent from spec) are a FAIL | `behavioral` | Plan TDD task references "SC-7" but spec only has SC-1 through SC-6; verify validation reports 1 PHANTOM-SC-ID finding | plan-to-pipeline-handoff | sc-coherence-gate |
| SC-10 | The cross-reference validation check verifies phase assignments in the plan are consistent with the spec Phase Binding column — SC-IDs assigned to Phase 1 in the plan must match the spec's Phase Binding for Phase 1; mismatches are a FAIL | `behavioral` | Spec binds SC-3 to Phase 2 but plan assigns SC-3 to Phase 1 tasks; verify validation reports PHASE-MISMATCH finding | plan-to-pipeline-handoff | sc-coherence-gate |
| SC-11 | The cross-reference validation check verifies Pipeline Step Bindings in the plan match the spec SC table — the plan does NOT reassign gates. Any plan TDD task that declares a different pipeline step for an SC-ID than the spec declares is a FAIL | `behavioral` | Spec binds SC-4 to `green-doublecheck` but plan assigns SC-4 verification to `red-doublecheck`; verify validation reports GATE-DEVIATION finding | plan-to-pipeline-handoff | sc-coherence-gate |
| SC-12 | The cross-reference validation check verifies no DEC-ID from the spec's Decision Ledger is contradicted by the plan phase approach — if the spec says DEC-1 "MUST silently deduplicate" but the plan phase describes explicit error-on-duplicate, the plan must flag DEC-CONTRADICTION and block | `behavioral` | Spec Decision Ledger has DEC-1 ("MUST silently deduplicate") but plan Phase 2 describes "return 409 on duplicate"; verify validation reports DEC-CONTRADICTION finding | plan-to-pipeline-handoff | sc-coherence-gate |
| SC-13 | The cross-reference validation check verifies every RISK-ID with a Verifying SC column in the spec's Risk Traceability table has a corresponding mitigation step in the assigned phase — if RISK-1 has Verifying SC=SC-5 but the phase assigned to SC-5 lacks a risk mitigation description, that is a FAIL | `behavioral` | Spec Risk Traceability has RISK-1→SC-5 but the plan phase covering SC-5 has no risk mitigation section describing RISK-1 or its mitigation; verify validation reports UNMITIGATED-RISK finding | plan-to-pipeline-handoff | sc-coherence-gate |
| SC-14 | The combined/separate plan format decision is verified against the spec's Decomposition Classification — single-task classification MUST produce combined format, multi-phase classification MUST produce separate format. Any mismatch blocks the plan | `behavioral` | Spec declares Decomposition Classification = multi-phase but plan-structure outputs combined format; verify create-and-validate validation reports FORMAT-MISMATCH finding and blocks | plan-to-pipeline-handoff | sc-coherence-gate |
| SC-15 | The cross-reference validation check handles missing structured columns gracefully: if the spec lacks a Phase Binding column, the check skips phase-assignment validation; if the spec lacks a Decision Ledger, the check skips DEC-ID validation; if the spec lacks a Risk Traceability table, the check skips RISK-ID validation | `behavioral` | Plan author processes a spec with only SC-ID and Pipeline Step Binding columns (no Phase Binding, no Decision Ledger, no Risk Traceability); verify the 7-check validation PASSes on the 4 applicable checks and skips the 3 inapplicable ones | plan-to-pipeline-handoff | sc-coherence-gate |
| SC-16 | The structured consumption substep produces a machine-readable SC-to-plan mapping artifact at `./tmp/{issue-N}/artifacts/sc-to-plan-map.yaml` listing every SC-ID, its assigned phase, its assigned TDD task heading, and its verification gate | `string` | grep for `sc-to-plan-map` in `plan-structure.md` and verify the YAML format is documented | structural-checks | structural-checks |

## ALL-OR-NOTHING GATE: ALL 16 success criteria MUST pass for implementation to be considered complete.

## Edge Cases

| Edge Case | Handling |
|-----------|----------|
| Spec from before #1060 expansion — SC table has only ID + Criterion + Verification Method + Remediation columns | SC-6 handles this: plan-structure checks the SC table has at minimum SC-ID and one binding column. If not, returns BLOCKED with SPEC_SC_TABLE_UNREADABLE. The spec author must update the spec. |
| Spec Phase Binding column declares Phase 1 and Phase 3 but skips Phase 2 | The cross-reference validation (SC-10) detects orphaned SC-IDs assigned to Phase 2 and reports PHASE-MISMATCH. The plan author should flag the gap rather than guess. |
| Decision Ledger has 10 DEC-IDs — plan author cannot manually verify all 10 | The plan author reads at a "concern level": for each phase's approach, check whether the approach is consistent with any applicable DEC-ID. Not every DEC-ID needs manual cross-check — only those whose concern intersects with the phase. |
| Risk Traceability table has 12 RISK-IDs — excessive cross-reference burden | The plan author focuses on RISK-IDs whose Verifying SC falls within the current phase's assigned SCs. RISK-IDs outside the phase's SC coverage are the next phase's responsibility. |
| Decomposition Classification says multi-phase but the spec only has one logical concern | The plan author flags this as DECOMPOSITION-ANOMALY and blocks. The spec author must resolve the contradiction (either revise classification to single-task or justify multi-phase structure). |
| Spec has no Decision Ledger and no Risk Traceability table (simple spec) | SC-15 handles graceful degradation: missing sections are skipped in the 7-check validation, no false FAILs. |
| `./tmp/{issue-N}/artifacts/` directory does not exist | The sc-to-plan-map artifact step creates the directory: `mkdir -p ./tmp/{issue-N}/artifacts/` |

## Dependencies

| Dependency | Type | Impact |
|------------|------|--------|
| [#850](https://github.com/michael-conrad/.opencode/issues/850) | Parent coordination | Defines the overall spec-output requirements initiative and sibling spec chain |
| [#1060](https://github.com/michael-conrad/.opencode/issues/1060) | Upstream spec | Produces the expanded SC table with 8 new columns that this spec consumes — must be implemented BEFORE this spec's implementation begins |
| Behavioral enforcement test framework at `.opencode/tests/` | Infrastructure | Required for RED/GREEN validation per SC-1 through SC-16 |

**Ordering constraint:** #1060 MUST be merged before this spec enters RED-phase. The plan-structure and create-and-validate changes depend on the expanded SC table columns existing in the spec. If #1060 is not merged, the writing-plans tasks will reference columns that do not exist.

## Risk

| RISK-ID | Description | Likelihood | Impact | Verifying SC | Mitigation |
|---------|-------------|------------|--------|--------------|------------|
| RISK-1 | Behavioral tests for 14 SCs require significant opencode-cli run time | Medium | Medium | SC-1 through SC-15 | Scope-limited behavioral testing per `020-go-prohibitions.md`: use `--tag` or per-scenario test scripts, not full-suite runs. Each behavioral test focuses on one SC's agent behavior. |
| RISK-2 | plan-structure.md or create-and-validate.md exceed 3,000-word limit after changes | Medium | High | All | Monitor word count during implementation. If approaching 3,000 words, split structured consumption into a separate reference file under `writing-plans/references/`. |
| RISK-3 | SC-6 (BLOCKED on unreadable SC table) interacts poorly with legacy specs from before #1060 | Low | High | SC-6, SC-15 | Legacy specs without expanded columns trigger BLOCKED, which is correct behavior — the spec must be updated. SC-15 handles graceful partial-consumption for specs with some columns missing. |
| RISK-4 | Behavioral SCs require clean-room sub-agent inspection (assert_semantic) which has model availability constraints | Medium | Medium | SC-1 through SC-15 | Multiple remediation paths per `065-verification-honesty.md` Anti-Evasion Rules: timeout increase, alternative model, retry. FAIL only after 2+ remediation attempts. |

## Documentation Sources

- `.opencode/skills/writing-plans/tasks/create/plan-structure.md` — current task file (185 lines, 7 steps including Pre-Step)
- `.opencode/skills/writing-plans/tasks/create/create-and-validate.md` — current task file (163 lines, 8 steps plus auth context)
- `tmp/spec-output-requirements-analysis.md` items 23, 11-20, 24 — analysis source for structured consumption requirements
- `.opencode/.issues/1060/spec.md` — upstream spec defining the expanded SC table columns consumed by this change

## Decomposition Classification: multi-phase

### Phase 1: plan-structure — Structured Consumption Substep

**Purpose:** Add Step 2: SC Table Structured Consumption to `plan-structure.md`, shifting existing Steps 2-5 to Steps 3-6.

**SCs covered:** SC-1 through SC-6, SC-16

**TDD items:**
1. Insert Step 2 heading and purpose ("Map each spec SC-ID to plan phase, TDD task, and verification gate using the 8-field consumption map")
2. Define the 8-field mapping procedure (reads SC-ID, Pipeline Step Binding, Phase Binding, Verification Gate, Artifact Path, Risk Traceability, Decision Ledger, Decomposition Classification from spec)
3. Add entry criterion: spec SC table must have at minimum SC-ID + one binding column (SC-6 BLOCKED condition)
4. Add `sc-to-plan-map.yaml` artifact output substep (SC-16)
5. Renumber existing Steps 2-5 to Steps 3-6
6. Update Step 1 Exit Criteria to reflect new step numbering
7. Write RED behavioral test (SC-1: plan-structure maps SC-IDs to phases)
8. Write RED behavioral tests (SC-2 through SC-6)
9. Implement GREEN phase (all substeps)
10. Verify behavioral tests PASS

### Phase 2: create-and-validate — Cross-Reference Validation Substep

**Purpose:** Add Step 4: Cross-Reference Validation to `create-and-validate.md`, shifting existing Steps 10-13 to Steps 11-14.

**SCs covered:** SC-7 through SC-15

**TDD items:**
1. Insert Step 4 heading and purpose ("Verify every spec SC-ID has plan coverage — 7 mandatory checks before pipeline entry")
2. Define the 7-check validation procedure with per-check FAIL conditions and BLOCK-on-any-Fail semantics
3. Add graceful handling for missing spec sections (SC-15: skip Phase Binding, Decision Ledger, or Risk Traceability checks when absent)
4. Update existing Step 8 self-review to mention that cross-reference validation is the gate before pipeline entry
5. Renumber existing Steps 10-13 to Steps 11-14
6. Write RED behavioral tests (SC-7 through SC-14: cross-reference validation coverage)
7. Write RED behavioral test (SC-15: graceful degradation for missing columns)
8. Implement GREEN phase (all substeps)
9. Verify behavioral tests PASS

### Phase 3: Verification — All 16 Behavioral Tests

**Purpose:** Verify all 16 SCs pass with behavioral evidence.

**SCs covered:** SC-1 through SC-16

**TDD items:**
1. Verify behavioral tests reference SC-IDs in assertion comments
2. Run all behavioral tests for SC-1 through SC-16
3. Content-verification test for SC-16 (structural: grep `sc-to-plan-map`)
4. Commit both phases + all behavioral tests together

🤖 OpenCode (deepseek-v4-flash)