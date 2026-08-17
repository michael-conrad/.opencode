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
criterion is expressed as an imperative binary decision tree with explicit PASS/FAIL
branches, matching the format SC-2 mandates for the inline copy in validate.md.

### Atomicity

```
Is the SC a single, indivisible concern?
├── YES → Is it free of coordinating conjunctions (and, or) and comma-separated lists?
│   ├── YES → PASS — SC is atomic
│   └── NO → FAIL — SC contains trigger words indicating multiple concerns
└── NO → FAIL — SC bundles multiple concerns
```

### Single Deliverable

```
Does the SC produce exactly one deliverable?
├── YES → Is the deliverable a single file, function, or configuration change?
│   ├── YES → PASS — SC has a single deliverable
│   └── NO → FAIL — SC spans multiple deliverables
└── NO → FAIL — SC produces zero or multiple deliverables
```

### Binary Verifiability

```
Can the SC be verified as PASS or FAIL with no interpretation?
├── YES → Is the SC free of disjunctive patterns (either/or, alternatively, one of)?
│   ├── YES → Is the SC free of vague terms (should, could, ideally, as appropriate)?
│   │   ├── YES → PASS — SC is binary-verifiable
│   │   └── NO → FAIL — SC contains vague terms
│   └── NO → FAIL — SC contains disjunctive patterns
└── NO → FAIL — SC requires interpretation to verify
```

### PR-Gate Viability

```
Can the SC be delivered as a single, independently reviewable PR?
├── YES → Does the SC represent a single RED/GREEN cycle?
│   ├── YES → PASS — SC is PR-gate viable
│   └── NO → FAIL — SC spans multiple RED/GREEN cycles
└── NO → FAIL — SC requires unreviewed dependencies
```

### Meta RED/GREEN Principle

Each spec is a **RED** — it defines what must be true. Each PR merge is a **GREEN** —
it makes that truth permanent. An SC that requires multiple PR merges to satisfy is
not PR-gate viable and SHALL be decomposed into sub-SCs, each with its own RED/GREEN
cycle.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `spec-creation/tasks/validate.md` includes inline decomposition criteria checklist for 4 spec-level criteria: atomicity, single deliverable, binary verifiability, PR-gate viability | string | grep for each of the 4 exact criterion headings `### Atomicity`, `### Single Deliverable`, `### Binary Verifiability`, `### PR-Gate Viability` in validate.md — all 4 must match |
| SC-2 | Each criterion uses imperative binary decision tree format with explicit PASS/FAIL branches (not prose guidance) | string | grep for the exact branch tokens `PASS —` and `FAIL —` in validate.md — each of the 4 decision-tree blocks must contain at least one `PASS —` and one `FAIL —` line |
| SC-3 | Atomicity check includes trigger-word sub-check (and, or, comma-separated lists → FAIL) | string | grep for the exact strings `and`, `or`, and `comma-separated` within the Atomicity decision-tree block in validate.md — all 3 must match |
| SC-4 | Binary verifiability check includes disjunctive pattern sub-check (either/or, alternatively, one of → FAIL) | string | grep for the exact strings `either/or`, `alternatively`, and `one of` within the Binary Verifiability decision-tree block in validate.md — all 3 must match |
| SC-5 | Binary verifiability check includes vague term sub-check (should, could, ideally, as appropriate → FAIL) | string | grep for the exact strings `should`, `could`, `ideally`, and `as appropriate` within the Binary Verifiability decision-tree block in validate.md — all 4 must match |
| SC-6 | PR-gate viability check references meta RED/GREEN principle | string | grep for the exact strings `RED` and `GREEN` within the PR-Gate Viability decision-tree block in validate.md — both must match |
| SC-7 | Inline copy includes cross-reference comment: 'See audit/reference/decomposition-criteria.md for master definition' | string | grep for the exact string `See audit/reference/decomposition-criteria.md for master definition` in validate.md — must match |
| SC-8 | Decomposition check is skipped (not evaluated) when spec has exactly 1 SC AND 1 affected file | string | grep for the exact strings `1 SC` and `1 affected file` in validate.md — both must match within the skip-condition guard |
| SC-9 | Behavioral test: spec with monolithic SC containing 'and' submitted to validate returns FAIL with correct reason | behavioral | opencode run: submit a spec whose single SC is `The system validates email format AND sends confirmation email` and whose affected-files list contains MORE than 1 file (so the SC-8 skip-guard does not fire) to validate; assert stderr contains `FAIL` and the atomicity reason `SC contains trigger words indicating multiple concerns` |
| SC-10 | Behavioral test: spec with single atomic SC submitted to validate returns PASS for decomposition criteria | behavioral | opencode run: submit a spec whose single SC is `The system validates email format on registration` and whose affected-files list contains MORE than 1 file (so the SC-8 skip-guard does not fire) to validate; assert stderr contains `PASS` for the decomposition criteria check |

## Requirements

R-1. The `spec-creation/tasks/validate.md` task SHALL include an inline decomposition criteria checklist covering the 4 spec-level criteria: atomicity, single deliverable, binary verifiability, and PR-gate viability.

R-2. Each of the 4 decomposition criteria SHALL be expressed as an imperative binary decision tree with explicit PASS/FAIL branches, not prose guidance.

R-3. The atomicity criterion SHALL include a trigger-word sub-check that flags `and`, `or`, and comma-separated lists as compound structure (FAIL).

R-4. The binary verifiability criterion SHALL include a disjunctive-pattern sub-check that flags `either/or`, `alternatively`, and `one of` (FAIL).

R-5. The binary verifiability criterion SHALL include a vague-term sub-check that flags `should`, `could`, `ideally`, and `as appropriate` (FAIL).

R-6. The PR-gate viability criterion SHALL reference the meta RED/GREEN principle.

R-7. The inline copy SHALL include the cross-reference comment `See audit/reference/decomposition-criteria.md for master definition`.

R-8. The decomposition check SHALL be skipped (not evaluated) when the spec has exactly 1 SC AND 1 affected file.

R-9. The decomposition check SHALL reject a monolithic SC containing `and` with the atomicity reason `SC contains trigger words indicating multiple concerns`.

R-10. The decomposition check SHALL accept a single atomic SC.

## Items

Each SC maps to exactly one item. Items are numbered sequentially from 1.

### Item 1 (SC-1): Inline decomposition criteria checklist

- RED: grep for the 4 criterion headings in validate.md fails (no checklist present)
- GREEN: add the inline decomposition criteria checklist with the 4 criterion headings to validate.md
- verify: grep for each of the 4 exact criterion headings `### Atomicity`, `### Single Deliverable`, `### Binary Verifiability`, `### PR-Gate Viability` — all 4 match
- commit: validate.md checklist addition

### Item 2 (SC-2): Imperative binary decision-tree format

- RED: grep for `PASS —`/`FAIL —` branch tokens in the 4 decision-tree blocks fails
- GREEN: express each criterion as an imperative binary decision tree with explicit PASS/FAIL branches
- verify: each of the 4 decision-tree blocks contains at least one `PASS —` and one `FAIL —` line
- commit: validate.md decision-tree format

### Item 3 (SC-3): Atomicity trigger-word sub-check

- RED: grep for `and`, `or`, `comma-separated` within the Atomicity block fails
- GREEN: add the trigger-word sub-check to the Atomicity decision tree
- verify: all 3 strings match within the Atomicity block
- commit: validate.md atomicity sub-check

### Item 4 (SC-4): Binary verifiability disjunctive-pattern sub-check

- RED: grep for `either/or`, `alternatively`, `one of` within the Binary Verifiability block fails
- GREEN: add the disjunctive-pattern sub-check to the Binary Verifiability decision tree
- verify: all 3 strings match within the Binary Verifiability block
- commit: validate.md disjunctive-pattern sub-check

### Item 5 (SC-5): Binary verifiability vague-term sub-check

- RED: grep for `should`, `could`, `ideally`, `as appropriate` within the Binary Verifiability block fails
- GREEN: add the vague-term sub-check to the Binary Verifiability decision tree
- verify: all 4 strings match within the Binary Verifiability block
- commit: validate.md vague-term sub-check

### Item 6 (SC-6): PR-gate viability meta RED/GREEN reference

- RED: grep for `RED` and `GREEN` within the PR-Gate Viability block fails
- GREEN: add the meta RED/GREEN principle reference to the PR-Gate Viability decision tree
- verify: both strings match within the PR-Gate Viability block
- commit: validate.md PR-gate viability reference

### Item 7 (SC-7): Cross-reference comment

- RED: grep for `See audit/reference/decomposition-criteria.md for master definition` in validate.md fails
- GREEN: add the cross-reference comment to the inline copy
- verify: the exact string matches in validate.md
- commit: validate.md cross-reference comment

### Item 8 (SC-8): Skip condition for single-SC/single-file specs

- RED: grep for `1 SC` and `1 affected file` within the skip-condition guard fails
- GREEN: add the skip-condition guard that short-circuits the check when the spec has exactly 1 SC AND 1 affected file
- verify: both strings match within the skip-condition guard
- commit: validate.md skip-condition guard

### Item 9 (SC-9): Monolithic-SC behavioral rejection

- RED: opencode run submits a spec with a monolithic SC (`The system validates email format AND sends confirmation email`) and MORE than 1 affected file; stderr does not contain `FAIL` with the atomicity reason
- GREEN: ensure the decomposition check rejects the monolithic SC with the atomicity reason
- verify: opencode run asserts stderr contains `FAIL` and `SC contains trigger words indicating multiple concerns`
- commit: validate.md decomposition rejection behavior

### Item 10 (SC-10): Atomic-SC behavioral acceptance

- RED: opencode run submits a spec with a single atomic SC (`The system validates email format on registration`) and MORE than 1 affected file; stderr does not contain `PASS` for the decomposition criteria check
- GREEN: ensure the decomposition check accepts the atomic SC
- verify: opencode run asserts stderr contains `PASS` for the decomposition criteria check
- commit: validate.md decomposition acceptance behavior

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
| SC-4 | Phase 2 | validate.md binary verifiability check lacks disjunctive-pattern sub-check |
| SC-5 | Phase 2 | validate.md binary verifiability check lacks vague-term sub-check |
| SC-6 | Phase 2 | validate.md PR-gate viability check lacks meta RED/GREEN reference |
| SC-7 | Phase 2 | validate.md inline copy lacks cross-reference to master reference |
| SC-8 | Phase 2 | validate.md decomposition check lacks skip condition for single-SC/single-file specs |
| SC-9 | Phase 2 | validate.md monolithic SC not rejected by decomposition criteria |
| SC-10 | Phase 2 | validate.md atomic SC not accepted by decomposition criteria |

### Phase Mapping

| Phase | SCs |
|-------|-----|
| Phase 2 | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8, SC-9, SC-10 |

## Documentation Sources

Per the canonical spec-structure-standards reference, the Success Criteria table uses
exactly 4 columns (ID, Criterion, Evidence Type, Verification Method) and
Documentation Sources is a separate section. This spec follows that structure — the
SC table does not include a Documentation Sources column; external sources are
documented here.

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
- **SC-4:** Verifying the binary verifiability disjunctive-pattern sub-check costs one grep search. Skipping means an SC with a disjunctive pattern ships and is only caught when the implementation cannot be evaluated as PASS or FAIL.
- **SC-5:** Verifying the binary verifiability vague-term sub-check costs one grep search. Skipping means an SC with a vague term ships and is only caught when the implementation cannot be evaluated as PASS or FAIL.
- **SC-6:** Verifying the PR-gate viability check references the meta RED/GREEN principle costs one grep search. Skipping means an SC requiring multiple PR merges is not decomposed and blocks a clean single-PR review.
- **SC-7:** Verifying the inline copy includes the cross-reference comment costs one grep search. Skipping means the inline copy drifts from the master reference and future audits cannot locate the authoritative source.
- **SC-8:** Verifying the decomposition check is skipped for single-SC/single-file specs costs one grep search. Skipping means the skip condition is absent and single-concern specs are spuriously flagged, forcing needless decomposition work.
- **SC-9:** Running the monolithic-SC behavioral test costs minutes of execution time. Skipping means a monolithic SC passes validate and ships, where the defect costs 1000× more to fix in production.
- **SC-10:** Running the atomic-SC behavioral test costs minutes of execution time. Skipping means the decomposition criteria are not verified to accept valid atomic SCs, risking false rejection of compliant specs.

## Change Control

| Date | What Changed | Why | Authorized By |
|------|--------------|-----|---------------|
| 2026-08-16 | Added "Decomposition Criteria Definitions" section summarizing the master reference file and defining the 5 previously undefined terms (atomic work units, single deliverable, binary verifiability, PR-gate viability, meta RED/GREEN principle) | Spec-audit finding (1) Completeness — undefined terms forced implementor guessing | spec-audit remediation |
| 2026-08-16 | Replaced deferral-language Dependencies section with concrete dependency table naming issue #2118, the relationship, and satisfied status | Spec-audit finding (2) Escape Hatches — deferral language permitted short-circuiting decomposition work | spec-audit remediation |
| 2026-08-16 | Added Traceability section mapping each SC to Phase 2 and its root cause, plus a phase mapping table | Spec-audit finding (3) Traceability — all 9 SCs were orphan SCs with no phase mapping | spec-audit remediation |
| 2026-08-16 | Added Not Included, Documentation Sources, and Enforcement Gate sections | Verify spec against spec-structure-standards and current code base | spec-audit remediation |
| 2026-08-16 | Added "Cost Frame" section with per-SC cost-frame statements for all 9 SCs following the dark-prose-007 pattern | Validation FAILED on dark-prose-007 cost-frame conformance and Completeness — spec lacked the required "## Cost Frame" section (spec-structure-standards §10) | spec-audit remediation |
| 2026-08-16 | Converted normative MUST to SHALL in the Decomposition Criteria Definitions section (5 occurrences) | Validation FAILED on SHALL language conformance — definitions section used MUST as normative language instead of SHALL | spec-audit remediation |
| 2026-08-16 | Documented Documentation Sources resolution: SC table keeps exactly 4 columns (ID, Criterion, Evidence Type, Verification Method); external sources documented in the separate Documentation Sources section per canonical spec-structure-standards | Validation FAILED on Documentation Sources conformance — SC table lacked a Documentation Sources column; resolved in favor of the canonical reference | spec-audit remediation |
| 2026-08-16 | Split SC-4 into two SCs (SC-4 disjunctive pattern sub-check, SC-5 vague term sub-check); renumbered subsequent SCs (SC-5→SC-6, SC-6→SC-7, SC-7→SC-8, SC-8→SC-9, SC-9→SC-10); updated Traceability table, Cost Frame section, and Phase Mapping to match | Validation FAILED on Compound-SC detection — SC-4 bundled two independently verifiable claims | spec-audit remediation |
| 2026-08-17 | Tightened all 10 SCs to precise, independently-reproducible expected values: string SCs (SC-1..SC-8) now specify the exact grep pattern/string to match; behavioral SCs (SC-9, SC-10) now specify the exact assertion procedure and expected output | Re-audit FAILED on Implementability — all 10 SCs carried determinism fail-patterns; two auditors could not independently reproduce PASS/FAIL | spec-audit remediation |
| 2026-08-17 | Reconciled the Decomposition Criteria Definitions section from prose bullets to imperative binary decision-tree format with explicit PASS/FAIL branches, matching the format SC-2 mandates for the inline copy | Re-audit FAILED on Internal Consistency — SC-2 mandated imperative binary decision-tree format but the Definitions section used prose bullets | spec-audit remediation |
| 2026-08-17 | Added the 'Requirements' (§4) and 'Items' (§5) sections required by spec-structure-standards: R-1..R-10 mapping to SC-1..SC-10, and Item 1..Item 10 with per-SC RED/GREEN/verify/commit cycles | Re-audit FAILED on SC-1 (structural completeness) — spec was missing the 'Requirements' and 'Items' sections required by spec-structure-standards | spec-audit remediation |
| 2026-08-17 | Explicitly specified the affected-files count (MORE than 1 file) for the SC-9 and SC-10 behavioral test specs so the SC-8 skip-guard (1 SC AND 1 affected file) does not fire and the decomposition criteria are always evaluated in the tests | Re-audit FAILED on A1-contradictions and A5-gap_analysis — SC-8's skip condition conflicted with the single-SC behavioral assertions in SC-9/SC-10 because the test specs' affected-files count was unspecified | spec-audit remediation |
