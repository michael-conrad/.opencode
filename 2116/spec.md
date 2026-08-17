# [SPEC] Phase 2: Add decomposition criteria to spec-creation validate

## Problem

spec-creation's validate task does not check whether SCs are properly decomposed
to atomic work units. Monolithic SCs pass through to plan creation and implementation,
where defects are more expensive to fix.

The current `validate.md` Step 3.3 "Compound-SC detection" flags conjunctions
(`and`, `or`, `also`, `plus`) but does not enforce the 4 spec-level decomposition
criteria defined in the master reference. This spec adds those criteria to the
validate pipeline.

## Root Cause / Motivation

The decomposition audit chain (Phase 1, issue #2118) established a master reference
file defining the decomposition criteria, but the spec-creation validate task has
not yet been wired to enforce those criteria. Without enforcement in validate,
monolithic SCs pass through to plan creation and implementation where they are
more expensive to fix.

## Approach

Edit `spec-creation/tasks/validate.md` to add a new 'Decomposition Criteria' section
after existing validation checks. The section is a structured checklist with binary
PASS/FAIL branching, mirroring the criteria defined in the master reference file
`audit/reference/decomposition-criteria.md`. Entry condition: skip if spec has 1 SC
AND 1 affected file.

## Decomposition Criteria Definitions

These definitions summarize the master reference file
`audit/reference/decomposition-criteria.md` (the authoritative source). Each
criterion uses an imperative binary decision tree with explicit PASS/FAIL branches.

- **Atomicity:** Each SC MUST represent exactly one atomic concern. A non-atomic SC
  bundles multiple concerns and cannot be verified independently. FAIL if the SC
  contains coordinating conjunctions (`and`, `or`) or comma-separated lists.
- **Single deliverable:** Each SC MUST produce exactly one deliverable (file,
  function, config change). FAIL if the SC spans multiple files or multiple
  independent deliverables.
- **Binary verifiability:** Each SC MUST be verifiable as PASS or FAIL with no gray
  area. FAIL if the SC contains disjunctive patterns (`either/or`, `alternatively`,
  `one of`) or vague terms (`should`, `could`, `ideally`, `as appropriate`).
- **PR-gate viability:** Each SC MUST be deliverable as a single, independently
  reviewable PR. FAIL if the SC requires unreviewed dependencies or spans multiple
  RED/GREEN cycles.
- **Meta RED/GREEN principle:** Each spec is a **RED** — it defines what must be
  true. Each PR merge is a **GREEN** — it makes that truth permanent. An SC that
  requires multiple PR merges to satisfy is not PR-gate viable and MUST be
  decomposed into sub-SCs.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `spec-creation/tasks/validate.md` includes inline decomposition criteria checklist for 4 spec-level criteria: atomicity, single deliverable, binary verifiability, PR-gate viability | string | grep for each criterion in validate.md |
| SC-2 | Each criterion uses imperative binary decision tree format with explicit PASS/FAIL branches (not prose guidance) | string | grep for PASS/FAIL branching |
| SC-3 | Atomicity check includes trigger-word sub-check (and, or, comma-separated lists → FAIL) | string | grep for trigger word sub-check |
| SC-4 | Binary verifiability check includes disjunctive pattern sub-check (either/or, alternatively, one of → FAIL) and vague term sub-check (should, could, ideally, as appropriate → FAIL) | string | grep for disjunctive and vague term sub-checks |
| SC-5 | PR-gate viability check references meta RED/GREEN principle | string | grep for RED/GREEN reference |
| SC-6 | Inline copy includes cross-reference comment: 'See audit/reference/decomposition-criteria.md for master definition' | string | grep for cross-reference |
| SC-7 | Decomposition check is skipped (not evaluated) when spec has exactly 1 SC AND 1 affected file | string | grep for trigger condition |
| SC-8 | Behavioral test: spec with monolithic SC containing 'and' submitted to validate returns FAIL with correct reason | behavioral | opencode run with assertion |
| SC-9 | Behavioral test: spec with single atomic SC submitted to validate returns PASS for decomposition criteria | behavioral | opencode run with assertion |

## Not Included

- **`audit/tasks/spec-audit-evaluator.md`** — Phase 3 (issue #2117) adds the
  criteria to the audit evaluator independently. Out of scope here to preserve
  adversarial separation.
- **`writing-plans/tasks/validate.md`** — Phase 5 (issue #2115) addresses
  plan-level criteria (acyclic DAG, file collision freedom, explicit dependency
  declaration). Out of scope here.
- **Modifying the master reference file** — `audit/reference/decomposition-criteria.md`
  is the authoritative source; validate.md only inlines a copy with a cross-reference.

## Affected Files

- `spec-creation/tasks/validate.md` (edit)

## Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| Issue #2118 — `[SPEC] Phase 1: Master decomposition criteria reference file` (closed/merged) | The master reference file `audit/reference/decomposition-criteria.md` must exist before the inline copy is added to validate.md | Satisfied — `audit/reference/decomposition-criteria.md` exists on disk at `.opencode/audit/reference/decomposition-criteria.md` |

The inline decomposition criteria checklist in validate.md SHALL mirror the
spec-level criteria (atomicity, single deliverable, binary verifiability, PR-gate
viability) defined in the master reference file, and SHALL include the cross-reference
comment `See audit/reference/decomposition-criteria.md for master definition`.

## Traceability

Every SC maps to the single edit target `spec-creation/tasks/validate.md` and to the
root cause: the spec-creation validate task lacks decomposition criteria enforcement.

| SC | Phase | Root Cause |
|----|-------|------------|
| SC-1 | Phase 2 | validate.md lacks decomposition criteria checklist |
| SC-2 | Phase 2 | validate.md lacks binary PASS/FAIL decision-tree format |
| SC-3 | Phase 2 | validate.md atomicity check lacks trigger-word sub-check |
| SC-4 | Phase 2 | validate.md binary verifiability check lacks disjunctive/vague-term sub-checks |
| SC-5 | Phase 2 | validate.md PR-gate viability check lacks meta RED/GREEN reference |
| SC-6 | Phase 2 | validate.md inline copy lacks cross-reference to master reference |
| SC-7 | Phase 2 | validate.md decomposition check lacks skip condition for single-SC/single-file specs |
| SC-8 | Phase 2 | validate.md monolithic SC not rejected by decomposition criteria |
| SC-9 | Phase 2 | validate.md atomic SC not accepted by decomposition criteria |

### Phase Mapping

| Phase | SCs |
|-------|-----|
| Phase 2 | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8, SC-9 |

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| Master decomposition criteria reference | doc | `.opencode/audit/reference/decomposition-criteria.md` | Read — file exists on disk |
| spec-creation validate task | code | `.opencode/skills/spec-creation/tasks/validate.md` | Read — file exists on disk |

## Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1:** Verifying validate.md inlines the 4-criteria checklist costs one grep search. Skipping means a monolithic SC passes validate and ships to plan creation, where decomposition costs exponentially more to unwind.
- **SC-2:** Verifying each criterion uses imperative binary PASS/FAIL branches costs one grep search. Skipping means prose guidance passes string check but fails to enforce behavior, surfacing as a behavioral defect downstream.
- **SC-3:** Verifying the atomicity trigger-word sub-check costs one grep search. Skipping means an SC bundling `and`/`or`/comma lists reaches implementation and is discovered as a monolithic defect at PR review.
- **SC-4:** Verifying the binary verifiability disjunctive and vague-term sub-checks costs one grep search. Skipping means an SC with gray-area verifiability ships and is only caught when the implementation cannot be evaluated as PASS or FAIL.
- **SC-5:** Verifying the PR-gate viability check references the meta RED/GREEN principle costs one grep search. Skipping means an SC requiring multiple PR merges is not decomposed and blocks a clean single-PR review.
- **SC-6:** Verifying the inline copy includes the cross-reference comment costs one grep search. Skipping means the inline copy drifts from the master reference and future audits cannot locate the authoritative source.
- **SC-7:** Verifying the decomposition check is skipped for single-SC/single-file specs costs one grep search. Skipping means the skip condition is absent and single-concern specs are spuriously flagged, forcing needless decomposition work.
- **SC-8:** Running the monolithic-SC behavioral test costs minutes of execution time. Skipping means a monolithic SC passes validate and ships, where the defect costs 1000× more to fix in production.
- **SC-9:** Running the atomic-SC behavioral test costs minutes of execution time. Skipping means the decomposition criteria are not verified to accept valid atomic SCs, risking false rejection of compliant specs.

## Change Control

| Date | What Changed | Why | Authorized By |
|------|--------------|-----|---------------|
| 2026-08-16 | Added "Decomposition Criteria Definitions" section summarizing the master reference file and defining the 5 previously undefined terms (atomic work units, single deliverable, binary verifiability, PR-gate viability, meta RED/GREEN principle) | Spec-audit finding (1) Completeness — undefined terms forced implementor guessing | spec-audit remediation |
| 2026-08-16 | Replaced deferral-language Dependencies section with concrete dependency table naming issue #2118, the relationship, and satisfied status | Spec-audit finding (2) Escape Hatches — deferral language permitted short-circuiting decomposition work | spec-audit remediation |
| 2026-08-16 | Added Traceability section mapping each SC to Phase 2 and its root cause, plus a phase mapping table | Spec-audit finding (3) Traceability — all 9 SCs were orphan SCs with no phase mapping | spec-audit remediation |
| 2026-08-16 | Added Not Included, Documentation Sources, and Enforcement Gate sections | Verify spec against spec-structure-standards and current code base | spec-audit remediation |
| 2026-08-16 | Added "Cost Frame" section with per-SC cost-frame statements for all 9 SCs following the dark-prose-007 pattern | Validation FAILED on dark-prose-007 cost-frame conformance and Completeness — spec lacked the required "## Cost Frame" section (spec-structure-standards §10) | spec-audit remediation |
