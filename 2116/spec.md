# [SPEC] Phase 2: Add decomposition criteria to spec-creation validate

## Problem

spec-creation's validate task does not check whether SCs are properly decomposed
to atomic work units. Monolithic SCs pass through to plan creation and implementation,
where defects are more expensive to fix.

The current `validate.md` Step 3.3 "Compound-SC
detection" flags conjunctions (`and`, `or`, `also`, `plus`) but does not enforce the 6 spec-level decomposition
criteria defined in the master reference. This spec adds those criteria to the
validate pipeline.

The spec-level criteria set comprises the four original criteria (atomicity, single
deliverable, binary verifiability, PR-gate viability) plus a new section covering two
additional defect classes detected at the same decomposition pass: **Ceremony** (an SC
that adds zero verification signal over the union of prior SCs — same deliverable +
same verification method, no new requirement) and **Coverage / covered-by-prior** (an
SC whose requirement set is already entailed by a prior SC). Both new criteria are
computed as set-entailment over prior SCs only; the Problem Statement / intent prose
universe is explicitly OUT OF SCOPE because the master reference's Binary Verifiability
criterion (criterion 3) forbids interpretation-dependent verdicts. The new section is
spec-level only and does not touch the plan-level criteria (acyclic DAG, file collision
freedom, explicit dependency declaration).

## Root Cause / Motivation

The decomposition audit chain (Phase 1, issue #2118) established a master reference
file defining the decomposition criteria, but the spec-creation validate task has
not yet been wired to enforce those criteria. Without enforcement in validate,
monolithic SCs pass through to plan creation and implementation where they are
more expensive to fix.

## Approach

Edit `spec-creation/tasks/validate.md` to add a new 'Decomposition Criteria' section
after existing validation checks. The section is a structured checklist with binary
PASS/FAIL branching, mirroring the criteria CONTENT defined in the master reference file
`audit/reference/decomposition-criteria.md` (the inline copy mirrors the criteria
content, not the master reference's numbered heading format — the inline copy SHALL use
unnumbered headings per SC-1). Entry condition: skip if spec has 1 SC
AND 1 affected file.

The Decomposition Criteria section covers the 6 spec-level criteria: the four original
criteria (atomicity, single deliverable, binary verifiability, PR-gate viability) plus
the new Ceremony and Coverage criteria. The Ceremony and Coverage criteria are evaluated
in the same decomposition pass as the four original criteria. Both are computed as
set-entailment over prior SCs only — the Problem Statement / intent prose universe is
explicitly OUT OF SCOPE because the master reference's Binary Verifiability criterion
(criterion 3) forbids interpretation-dependent verdicts. The new section is spec-level
only; it does not touch the plan-level criteria (acyclic DAG, file collision freedom,
explicit dependency declaration).

## Alternatives Considered & Why Discarded

The selected approach is a single inline copy of the decomposition criteria in
`spec-creation/tasks/validate.md`. The following alternatives were evaluated and
discarded:

1. **Runtime import / read-only reference to the master file.** Make `validate.md`
   read `audit/reference/decomposition-criteria.md` at runtime instead of inlining a
   copy. **Discarded:** `validate.md` is a task card that must be self-contained for
   clean-room sub-agent execution; runtime import couples the task to a file that may
   drift and complicates clean-room dispatch. A cross-reference comment (SC-7) is
   retained instead to point to the authoritative source.
2. **Extract the check into a standalone tool or sub-skill.** Move the decomposition
   check into a separate script or skill invoked by validate. **Discarded:**
   over-engineering — the check is a deterministic string/pass-fail evaluation best
   expressed as inline checklist text; a separate tool adds dispatch overhead with no
   behavioral benefit for a 6-criterion checklist.
3. **Defer enforcement entirely to the Phase 3 audit evaluator (#2117).** Rely solely
   on the audit evaluator to catch monolithic SCs. **Discarded:** this leaves a gap in
   the validate gate — monolithic SCs would pass validate and be caught only later at
   audit, which is exactly the defect this spec prevents (defects are more expensive to
   fix the further downstream they surface).

## Key Design Decisions

1. **Inline copy + cross-reference comment (chosen) vs. runtime import.** Tradeoff:
   a self-contained task card that executes reliably in clean-room dispatch, versus a
   single source of truth. Resolved by inlining the copy AND adding the cross-reference
   comment (SC-7) so drift is auditable. A maintainer note governs synchronization.
2. **Imperative binary decision-tree format with explicit PASS/FAIL branches (SC-2).**
   Tradeoff: verbosity versus unambiguous, mechanically-checkable verification. Chosen
   because prose guidance would pass a string check but fail to enforce behavior.
3. **Skip-guard for exactly 1 SC AND 1 affected file (SC-8).** Tradeoff: avoids
   spurious flagging of single-concern specs, at the cost of an edge condition that
   must be explicitly tested (SC-9, SC-10 submit specs with MORE than 1 affected file so
   the guard does not fire).
4. **Retain the existing Step 3.3 Compound-SC detection as a distinct check.** Tradeoff:
   some redundancy with the new Atomicity criterion, versus preserving existing behavior
   and not regressing a currently-shipped gate.

## User Intent / Original Prompt

The original user prompt that motivated this spec is not recorded in the available
session context. The recorded intent is the change request that produced issue #2116:
the spec-creation validate task does not enforce the 6 spec-level decomposition
criteria defined in the master reference file, so monolithic SCs pass through to plan
creation and implementation where defects are more expensive to fix. This spec adds
those criteria to the validate pipeline.

## Decomposition Criteria Definitions

These definitions summarize the master reference file
`audit/reference/decomposition-criteria.md` (the authoritative source). Each
criterion is expressed as an imperative binary decision tree with explicit PASS/FAIL
branches, matching the format SC-2 mandates for the inline copy in validate.md.

### Atomic Work Unit

An **atomic work unit** is a single concern that cannot be further decomposed without
losing meaning, and that maps to exactly one deliverable and one verifiable outcome.
It is the granularity standard the six criteria below enforce: an SC that bundles
more than one concern, produces more than one deliverable, or requires more than one
verifiable outcome is not atomic. The six decision trees below define the
mechanically-checkable test of whether an SC is a single atomic work unit.

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

### Ceremony

```
Does the SC add any verification signal over the union of prior SCs?
├── YES → PASS — SC adds a new verification signal
└── NO → FAIL — SC is ceremony (same deliverable + same verification method, no new requirement)
```

**Scope of comparison:** The Ceremony criterion is computed as set-entailment over
prior SCs only — the union of the deliverables and verification methods of all SCs
that precede it in the spec. The Problem Statement / intent prose universe is
explicitly OUT OF SCOPE because the master reference's Binary Verifiability criterion
(criterion 3) forbids interpretation-dependent verdicts. An SC that repeats a prior
SC's deliverable and verification method without adding a new requirement is
ceremony and SHALL be removed or merged into the prior SC.

### Coverage / Covered-by-Prior

```
Is the SC's requirement set already entailed by a prior SC?
├── NO → PASS — SC adds a requirement not entailed by any prior SC
└── YES → FAIL — SC is covered by a prior SC (requirement set already entailed)
```

**Scope of comparison:** The Coverage criterion is computed as set-entailment over
prior SCs only — the requirement set of each prior SC in the spec. The Problem
Statement / intent prose universe is explicitly OUT OF SCOPE because the master
reference's Binary Verifiability criterion (criterion 3) forbids
interpretation-dependent verdicts. An SC whose requirement set is already entailed by
a prior SC is redundant and SHALL be removed or merged into the entailing SC.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `spec-creation/tasks/validate.md` includes inline decomposition criteria checklist for 6 spec-level criteria: atomicity, single deliverable, binary verifiability, PR-gate viability, ceremony, coverage / covered-by-prior | string | grep for each of the 6 exact criterion headings `### Atomicity`, `### Single Deliverable`, `### Binary Verifiability`, `### PR-Gate Viability`, `### Ceremony`, `### Coverage / Covered-by-Prior` in validate.md — all 6 must match |
| SC-2 | Each criterion uses imperative binary decision tree format with explicit PASS/FAIL branches (not prose guidance) | string | grep for the exact branch tokens `PASS —` and `FAIL —` in validate.md — each of the 6 decision-tree blocks must contain at least one `PASS —` and one `FAIL —` line |
| SC-3 | Atomicity check includes trigger-word sub-check (and, or, comma-separated lists → FAIL) | string | grep for the exact strings `and`, `or`, and `comma-separated` within the Atomicity decision-tree block in validate.md — all 3 must match |
| SC-4 | Binary verifiability check includes disjunctive pattern sub-check (either/or, alternatively, one of → FAIL) | string | grep for the exact strings `either/or`, `alternatively`, and `one of` within the Binary Verifiability decision-tree block in validate.md — all 3 must match |
| SC-5 | Binary verifiability check includes vague term sub-check (should, could, ideally, as appropriate → FAIL) | string | grep for the exact strings `should`, `could`, `ideally`, and `as appropriate` within the Binary Verifiability decision-tree block in validate.md — all 4 must match |
| SC-6 | PR-gate viability check references meta RED/GREEN principle | string | grep for the exact strings `RED` and `GREEN` within the PR-Gate Viability decision-tree block in validate.md — both must match |
| SC-7 | Inline copy includes cross-reference comment: 'See audit/reference/decomposition-criteria.md for master definition' | string | grep for the exact string `See audit/reference/decomposition-criteria.md for master definition` in validate.md — must match |
| SC-8 | Decomposition check is skipped (not evaluated) when spec has exactly 1 SC AND 1 affected file | string | grep for the exact strings `1 SC` and `1 affected file` in validate.md — both must match within the skip-condition guard |
| SC-9 | Behavioral test: submitting a spec whose SC contains the conjunction `AND` returns FAIL for the atomicity/decomposition check (monolithic SC rejected) — specifically, submitting a spec whose single SC is `The system validates email format AND sends confirmation email` and whose affected-files list contains MORE than 1 file (so the SC-8 skip-guard does not fire) returns FAIL for the atomicity/decomposition check, with the FAIL reason semantically indicating multiple concerns / a compound SC | behavioral | Two-SC pattern: a behavioral test script (artifact-only generator) at `.opencode/tests-v2/behaviors/` runs the above spec through validate via `with-test-home`, generating session.yaml artifacts (exit 0, no in-script assertion). A clean-room sub-agent reads session.yaml (the SQLite DB export — PRIMARY evidence per tests-v2/AGENTS.md §2/§5a) and evaluates whether the agent's tool calls/decisions show the decomposition check returned FAIL for the atomicity/decomposition check (monolithic SC rejected), with the FAIL reason semantically indicating multiple concerns / a compound SC |
| SC-10 | Behavioral test: submitting a spec with a single atomic SC returns PASS or is NOT rejected by the decomposition criteria check (no FAIL verdict; the atomic SC is accepted; WARN is an acceptable pass-equivalent) — specifically, submitting a spec whose single SC is `The system validates email format on registration` and whose affected-files list contains MORE than 1 file (so the SC-8 skip-guard does not fire) is accepted by the decomposition criteria check | behavioral | Two-SC pattern: a behavioral test script (artifact-only generator) at `.opencode/tests-v2/behaviors/` runs the above spec through validate via `with-test-home`, generating session.yaml artifacts (exit 0, no in-script assertion). A clean-room sub-agent reads session.yaml (the SQLite DB export — PRIMARY evidence per tests-v2/AGENTS.md §2/§5a) and evaluates whether the agent's tool calls/decisions show the decomposition check returned PASS or was NOT rejected (no FAIL verdict; the atomic SC is accepted) |
| SC-11 | `spec-creation/tasks/validate.md` includes the Ceremony criterion in the Decomposition Criteria section, expressed as an imperative binary decision tree with explicit PASS/FAIL branches, computed as set-entailment over prior SCs only (Problem Statement / intent prose universe OUT OF SCOPE) | string | grep for the exact criterion heading `### Ceremony` in validate.md — must match; grep for the exact branch tokens `PASS —` and `FAIL —` within the Ceremony decision-tree block — both must match; grep for the exact string `prior SCs` within the Ceremony block — must match |
| SC-12 | `spec-creation/tasks/validate.md` includes the Coverage / covered-by-prior criterion in the Decomposition Criteria section, expressed as an imperative binary decision tree with explicit PASS/FAIL branches, computed as set-entailment over prior SCs only (Problem Statement / intent prose universe OUT OF SCOPE) | string | grep for the exact criterion heading `### Coverage / Covered-by-Prior` in validate.md — must match; grep for the exact branch tokens `PASS —` and `FAIL —` within the Coverage decision-tree block — both must match; grep for the exact string `prior SCs` within the Coverage block — must match |
| SC-13 | Behavioral test: submitting a spec whose SC is ceremony (same deliverable + same verification method as a prior SC, no new requirement) returns FAIL for the decomposition/ceremony check (second SC is ceremony — identical deliverable + identical verification method, no new requirement) — specifically, submitting a spec whose first SC is `The system validates email format on registration` and whose second SC is `The system validates email format on registration` (identical deliverable and verification method, no new requirement) and whose affected-files list contains MORE than 1 file (so the SC-8 skip-guard does not fire) returns FAIL for the decomposition/ceremony check, with the FAIL reason semantically indicating ceremony / no new verification signal | behavioral | Two-SC pattern: a behavioral test script (artifact-only generator) at `.opencode/tests-v2/behaviors/` runs the above spec through validate via `with-test-home`, generating session.yaml artifacts (exit 0, no in-script assertion). A clean-room sub-agent reads session.yaml (the SQLite DB export — PRIMARY evidence per tests-v2/AGENTS.md §2/§5a) and evaluates whether the agent's tool calls/decisions show the decomposition check returned FAIL for the decomposition/ceremony check (second SC is ceremony — identical deliverable + identical verification method, no new requirement), with the FAIL reason semantically indicating ceremony / no new verification signal |
| SC-14 | Behavioral test: submitting a spec whose SC is covered by a prior SC (requirement set already entailed) returns FAIL for the decomposition/coverage check (second SC's requirement set already entailed by a prior SC) — specifically, submitting a spec whose first SC is `The system validates email format on registration` and whose second SC is `The system validates email format on registration` (requirement set already entailed by the first SC) and whose affected-files list contains MORE than 1 file (so the SC-8 skip-guard does not fire) returns FAIL for the decomposition/coverage check, with the FAIL reason semantically indicating coverage / duplicate / covered-by-prior | behavioral | Two-SC pattern: a behavioral test script (artifact-only generator) at `.opencode/tests-v2/behaviors/` runs the above spec through validate via `with-test-home`, generating session.yaml artifacts (exit 0, no in-script assertion). A clean-room sub-agent reads session.yaml (the SQLite DB export — PRIMARY evidence per tests-v2/AGENTS.md §2/§5a) and evaluates whether the agent's tool calls/decisions show the decomposition check returned FAIL for the decomposition/coverage check (second SC's requirement set already entailed by a prior SC), with the FAIL reason semantically indicating coverage / duplicate / covered-by-prior |

## Requirements

R-1. The `spec-creation/tasks/validate.md` task SHALL include an inline decomposition criteria checklist covering the 6 spec-level criteria: atomicity, single deliverable, binary verifiability, PR-gate viability, ceremony, and coverage / covered-by-prior.

R-2. Each of the 6 decomposition criteria SHALL be expressed as an imperative binary decision tree with explicit PASS/FAIL branches, not prose guidance.

R-3. The atomicity criterion SHALL include a trigger-word sub-check that flags `and`, `or`, and comma-separated lists as compound structure (FAIL).

R-4. The binary verifiability criterion SHALL include a disjunctive-pattern sub-check that flags `either/or`, `alternatively`, and `one of` (FAIL).

R-5. The binary verifiability criterion SHALL include a vague-term sub-check that flags `should`, `could`, `ideally`, and `as appropriate` (FAIL).

R-6. The PR-gate viability criterion SHALL reference the meta RED/GREEN principle.

R-7. The inline copy SHALL include the cross-reference comment `See audit/reference/decomposition-criteria.md for master definition`.

R-8. The decomposition check SHALL be skipped (not evaluated) when the spec has exactly 1 SC AND 1 affected file.

R-9. The decomposition check SHALL reject a monolithic SC containing `and` with a FAIL verdict for the atomicity/decomposition check, the FAIL reason semantically indicating multiple concerns / a compound SC. This behavioral criterion SHALL be verified via the Two-SC pattern: a behavioral test script (artifact-only generator) generates session.yaml artifacts via `with-test-home`, and a clean-room sub-agent evaluates session.yaml (the SQLite DB export — PRIMARY evidence per tests-v2/AGENTS.md §2/§5a) for FAIL evidence.

R-10. The decomposition check SHALL accept a single atomic SC (no FAIL verdict; WARN is an acceptable pass-equivalent). This behavioral criterion SHALL be verified via the Two-SC pattern: a behavioral test script (artifact-only generator) generates session.yaml artifacts via `with-test-home`, and a clean-room sub-agent evaluates session.yaml (the SQLite DB export — PRIMARY evidence per tests-v2/AGENTS.md §2/§5a) for PASS / no-FAIL evidence.

R-11. The decomposition check SHALL include a Ceremony criterion that flags an SC adding zero verification signal over the union of prior SCs (same deliverable + same verification method, no new requirement) as FAIL. The criterion SHALL be computed as set-entailment over prior SCs only; the Problem Statement / intent prose universe is OUT OF SCOPE.

R-12. The decomposition check SHALL include a Coverage / covered-by-prior criterion that flags an SC whose requirement set is already entailed by a prior SC as FAIL. The criterion SHALL be computed as set-entailment over prior SCs only; the Problem Statement / intent prose universe is OUT OF SCOPE.

R-13. The decomposition check SHALL reject a ceremony SC (identical deliverable and verification method to a prior SC, no new requirement) with a FAIL verdict for the decomposition/ceremony check, the FAIL reason semantically indicating ceremony / no new verification signal. This behavioral criterion SHALL be verified via the Two-SC pattern: a behavioral test script (artifact-only generator) generates session.yaml artifacts via `with-test-home`, and a clean-room sub-agent evaluates session.yaml (the SQLite DB export — PRIMARY evidence per tests-v2/AGENTS.md §2/§5a) for FAIL evidence.

R-14. The decomposition check SHALL reject an SC whose requirement set is already entailed by a prior SC with a FAIL verdict for the decomposition/coverage check, the FAIL reason semantically indicating coverage / duplicate / covered-by-prior. This behavioral criterion SHALL be verified via the Two-SC pattern: a behavioral test script (artifact-only generator) generates session.yaml artifacts via `with-test-home`, and a clean-room sub-agent evaluates session.yaml (the SQLite DB export — PRIMARY evidence per tests-v2/AGENTS.md §2/§5a) for FAIL evidence.

## Items

Each SC maps to exactly one item. Items are numbered sequentially from 1.

### Item 1 (SC-1): Inline decomposition criteria checklist

- RED: grep for the 6 criterion headings in validate.md fails (no checklist present)
- GREEN: add the inline decomposition criteria checklist with the 6 criterion headings to validate.md
- verify: grep for each of the 6 exact criterion headings `### Atomicity`, `### Single Deliverable`, `### Binary Verifiability`, `### PR-Gate Viability`, `### Ceremony`, `### Coverage / Covered-by-Prior` — all 6 match
- commit: validate.md checklist addition

### Item 2 (SC-2): Imperative binary decision-tree format

- RED: grep for `PASS —`/`FAIL —` branch tokens in the 6 decision-tree blocks fails
- GREEN: express each criterion as an imperative binary decision tree with explicit PASS/FAIL branches
- verify: each of the 6 decision-tree blocks contains at least one `PASS —` and one `FAIL —` line
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

- RED: behavioral test script (artifact-only generator) submits a spec with a monolithic SC (`The system validates email format AND sends confirmation email`) and MORE than 1 affected file; the generated session.yaml does not show the decomposition check returning FAIL for the atomicity/decomposition check (monolithic SC rejected)
- GREEN: ensure the decomposition check rejects the monolithic SC with a FAIL verdict for the atomicity/decomposition check
- verify: clean-room sub-agent reads session.yaml (the SQLite DB export — PRIMARY evidence per tests-v2/AGENTS.md §2/§5a) and confirms the agent's tool calls/decisions show FAIL for the atomicity/decomposition check, with the FAIL reason semantically indicating multiple concerns / a compound SC
- commit: validate.md decomposition rejection behavior

### Item 10 (SC-10): Atomic-SC behavioral acceptance

- RED: behavioral test script (artifact-only generator) submits a spec with a single atomic SC (`The system validates email format on registration`) and MORE than 1 affected file; the generated session.yaml does not show the decomposition check returning PASS or NOT rejected (no FAIL verdict)
- GREEN: ensure the decomposition check accepts the atomic SC (no FAIL verdict)
- verify: clean-room sub-agent reads session.yaml (the SQLite DB export — PRIMARY evidence per tests-v2/AGENTS.md §2/§5a) and confirms the agent's tool calls/decisions show PASS or NOT rejected (no FAIL verdict; the atomic SC is accepted)
- commit: validate.md decomposition acceptance behavior

### Item 11 (SC-11): Ceremony criterion

- RED: grep for the `### Ceremony` heading, `PASS —`/`FAIL —` branch tokens, and `prior SCs` within the Ceremony block in validate.md fails
- GREEN: add the Ceremony criterion to the Decomposition Criteria section in validate.md, expressed as an imperative binary decision tree with explicit PASS/FAIL branches, computed as set-entailment over prior SCs only
- verify: grep for the `### Ceremony` heading, `PASS —`/`FAIL —` branch tokens, and `prior SCs` within the Ceremony block — all match
- commit: validate.md ceremony criterion

### Item 12 (SC-12): Coverage / covered-by-prior criterion

- RED: grep for the `### Coverage / Covered-by-Prior` heading, `PASS —`/`FAIL —` branch tokens, and `prior SCs` within the Coverage block in validate.md fails
- GREEN: add the Coverage / covered-by-prior criterion to the Decomposition Criteria section in validate.md, expressed as an imperative binary decision tree with explicit PASS/FAIL branches, computed as set-entailment over prior SCs only
- verify: grep for the `### Coverage / Covered-by-Prior` heading, `PASS —`/`FAIL —` branch tokens, and `prior SCs` within the Coverage block — all match
- commit: validate.md coverage criterion

### Item 13 (SC-13): Ceremony-SC behavioral rejection

- RED: behavioral test script (artifact-only generator) submits a spec whose first SC is `The system validates email format on registration` and whose second SC is `The system validates email format on registration` (identical deliverable and verification method, no new requirement) and MORE than 1 affected file; the generated session.yaml does not show the decomposition check returning FAIL for the decomposition/ceremony check (second SC is ceremony)
- GREEN: ensure the decomposition check rejects the ceremony SC with a FAIL verdict for the decomposition/ceremony check
- verify: clean-room sub-agent reads session.yaml (the SQLite DB export — PRIMARY evidence per tests-v2/AGENTS.md §2/§5a) and confirms the agent's tool calls/decisions show FAIL for the decomposition/ceremony check, with the FAIL reason semantically indicating ceremony / no new verification signal
- commit: validate.md ceremony rejection behavior

### Item 14 (SC-14): Covered-by-prior-SC behavioral rejection

- RED: behavioral test script (artifact-only generator) submits a spec whose first SC is `The system validates email format on registration` and whose second SC is `The system validates email format on registration` (requirement set already entailed by the first SC) and MORE than 1 affected file; the generated session.yaml does not show the decomposition check returning FAIL for the decomposition/coverage check (second SC's requirement set already entailed by a prior SC)
- GREEN: ensure the decomposition check rejects the covered-by-prior SC with a FAIL verdict for the decomposition/coverage check
- verify: clean-room sub-agent reads session.yaml (the SQLite DB export — PRIMARY evidence per tests-v2/AGENTS.md §2/§5a) and confirms the agent's tool calls/decisions show FAIL for the decomposition/coverage check, with the FAIL reason semantically indicating coverage / duplicate / covered-by-prior
- commit: validate.md coverage rejection behavior

## Not Included

- **`audit/tasks/spec-audit-evaluator.md`** — Phase 3 (issue #2117) adds the
  criteria to the audit evaluator independently. Out of scope here to preserve
  adversarial separation.
- **`writing-plans/tasks/validate.md`** — Phase 5 (issue #2115) addresses
  plan-level criteria (acyclic DAG, file collision freedom, explicit dependency
  declaration). Out of scope here.
- **Modifying the plan-level criteria in the master reference file** — the new
  Ceremony and Coverage criteria are spec-level only; the plan-level criteria
  (acyclic DAG, file collision freedom, explicit dependency declaration) in
  `audit/reference/decomposition-criteria.md` are NOT modified by this spec.

## Affected Files

- `spec-creation/tasks/validate.md` (edit)
- `audit/reference/decomposition-criteria.md` (edit — add the new spec-level Ceremony and Coverage criteria section, per the maintainer note requiring inline copies be updated in lockstep)

## Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| Issue #2118 — `[SPEC] Phase 1: Master decomposition criteria reference file` (closed/merged) | The master reference file `audit/reference/decomposition-criteria.md` must exist before the inline copy is added to validate.md | Satisfied — `audit/reference/decomposition-criteria.md` exists on disk at `.opencode/audit/reference/decomposition-criteria.md` |

The inline decomposition criteria checklist in validate.md SHALL mirror the
spec-level criteria CONTENT (atomicity, single deliverable, binary verifiability,
PR-gate viability, ceremony, coverage / covered-by-prior) defined in the master
reference file, and SHALL include the
cross-reference comment `See audit/reference/decomposition-criteria.md for master
definition`. The inline copy mirrors the criteria content, not the master reference's
numbered heading format — the inline copy SHALL use unnumbered headings (`### Atomicity`,
`### Single Deliverable`, `### Binary Verifiability`, `### PR-Gate Viability`,
`### Ceremony`, `### Coverage / Covered-by-Prior`) per SC-1.

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
| SC-11 | Phase 2 | validate.md decomposition criteria lacks Ceremony criterion |
| SC-12 | Phase 2 | validate.md decomposition criteria lacks Coverage / covered-by-prior criterion |
| SC-13 | Phase 2 | validate.md ceremony SC not rejected by decomposition criteria |
| SC-14 | Phase 2 | validate.md covered-by-prior SC not rejected by decomposition criteria |

### Phase Mapping

| Phase | SCs |
|-------|-----|
| Phase 2 | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8, SC-9, SC-10, SC-11, SC-12, SC-13, SC-14 |

## Documentation Sources

Per the canonical spec-structure-standards reference, the Success Criteria table uses
exactly 4 columns (ID, Criterion, Evidence Type, Verification Method) and
Documentation Sources is a separate section. This spec follows that structure — the
SC table does not include a Documentation Sources column; external sources are
documented here.

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| Master decomposition criteria reference | doc | `.opencode/audit/reference/decomposition-criteria.md` | Read — file exists on disk; maintainer note declares inline copies in validate.md, spec-audit-evaluator.md, and writing-plans/tasks/validate.md |
| spec-creation validate task | code | `.opencode/skills/spec-creation/tasks/validate.md` | Read — file exists on disk |

## Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1:** Verifying validate.md inlines the 6-criteria checklist costs one grep search. Skipping means a monolithic SC passes validate and ships to plan creation, where decomposition costs exponentially more to unwind.
- **SC-2:** Verifying each criterion uses imperative binary PASS/FAIL branches costs one grep search. Skipping means prose guidance passes string check but fails to enforce behavior, surfacing as a behavioral defect downstream.
- **SC-3:** Verifying the atomicity trigger-word sub-check costs one grep search. Skipping means an SC bundling `and`/`or`/comma lists reaches implementation and is discovered as a monolithic defect at PR review.
- **SC-4:** Verifying the binary verifiability disjunctive-pattern sub-check costs one grep search. Skipping means an SC with a disjunctive pattern ships and is only caught when the implementation cannot be evaluated as PASS or FAIL.
- **SC-5:** Verifying the binary verifiability vague-term sub-check costs one grep search. Skipping means an SC with a vague term ships and is only caught when the implementation cannot be evaluated as PASS or FAIL.
- **SC-6:** Verifying the PR-gate viability check references the meta RED/GREEN principle costs one grep search. Skipping means an SC requiring multiple PR merges is not decomposed and blocks a clean single-PR review.
- **SC-7:** Verifying the inline copy includes the cross-reference comment costs one grep search. Skipping means the inline copy drifts from the master reference and future audits cannot locate the authoritative source.
- **SC-8:** Verifying the decomposition check is skipped for single-SC/single-file specs costs one grep search. Skipping means the skip condition is absent and single-concern specs are spuriously flagged, forcing needless decomposition work.
- **SC-9:** Running the monolithic-SC behavioral test (artifact generation + clean-room session.yaml evaluation) costs minutes of execution time. Skipping means a monolithic SC passes validate and ships, where the defect costs 1000× more to fix in production.
- **SC-10:** Running the atomic-SC behavioral test (artifact generation + clean-room session.yaml evaluation) costs minutes of execution time. Skipping means the decomposition criteria are not verified to accept valid atomic SCs, risking false rejection of compliant specs.
- **SC-11:** Verifying the Ceremony criterion is present in validate.md costs one grep search. Skipping means a ceremony SC (zero verification signal over prior SCs) passes validate and ships, adding dead weight to the spec and inflating review cost with no verification benefit.
- **SC-12:** Verifying the Coverage / covered-by-prior criterion is present in validate.md costs one grep search. Skipping means a redundant SC whose requirement set is already entailed by a prior SC passes validate and ships, duplicating requirements and fragmenting the verification signal.
- **SC-13:** Running the ceremony-SC behavioral test (artifact generation + clean-room session.yaml evaluation) costs minutes of execution time. Skipping means a ceremony SC passes validate and ships, where the dead-weight defect costs 1000× more to unwind in production.
- **SC-14:** Running the covered-by-prior-SC behavioral test (artifact generation + clean-room session.yaml evaluation) costs minutes of execution time. Skipping means a redundant SC passes validate and ships, where the requirement-duplication defect costs 1000× more to unwind in production.

## Edge Cases

Each edge case below states the condition, the expected behavior, and the resolution.

### Edge Case: Single SC with a single affected file (skip-guard fires)

- **Condition:** A spec has exactly 1 SC AND 1 affected file.
- **Expected behavior:** The decomposition check MUST be skipped (not evaluated), per SC-8/R-8.
- **Resolution:** The skip-condition guard short-circuits the check before any criterion is evaluated, so single-concern specs are not spuriously flagged.

### Edge Case: Single SC with multiple affected files

- **Condition:** A spec has exactly 1 SC but MORE than 1 affected file.
- **Expected behavior:** The decomposition check MUST be evaluated (skip-guard does not fire). SC-9 and SC-10 exercise this exact boundary so the guard's `AND` condition is honored — only 1 SC AND 1 affected file triggers the skip.
- **Resolution:** The skip-guard requires BOTH conditions; multiple affected files disables the skip, forcing the criteria to run.

### Edge Case: Compound-SC detection overlap with the new Atomicity criterion

- **Condition:** A spec contains an SC with coordinating conjunctions that both the existing Step 3.3 "Compound-SC detection" and the new Atomicity trigger-word sub-check would flag.
- **Expected behavior:** The new Decomposition Criteria section operates as a distinct checklist; the existing Step 3.3 is retained for its distinct purpose. Both checks may flag the same SC without conflict.
- **Resolution:** Documented in the Key Design Decisions (#4) and Not Included sections; no removal or replacement of Step 3.3.

### Edge Case: Failure of a dependency (master reference file missing)

- **Condition:** `audit/reference/decomposition-criteria.md` (the master reference) is absent or unavailable at implementation time.
- **Expected behavior:** The inline copy must still be complete and self-contained, because it is the executable checklist; the cross-reference comment (SC-7) is a pointer, not a load dependency.
- **Resolution:** The spec's Dependency table records #2118 as satisfied; the inline copy carries the full criteria so implementation does not depend on reading the master file at runtime.

### Edge Case: Inline copy drift from the master reference

- **Condition:** After implementation, the inline copy in validate.md diverges from the master reference file.
- **Expected behavior:** The cross-reference comment and maintainer note govern synchronization; drift is auditable via the pointer.
- **Resolution:** SC-7 mandates the cross-reference comment; a maintainer note in validate.md governs keeping the inline copy in sync with the authoritative source.

### Edge Case: Behavioral test affected-files count ambiguity

- **Condition:** A test harness or reader cannot determine the affected-files count of the SC-9/SC-10 test specs, causing the skip-guard to be ambiguous.
- **Expected behavior:** The behavioral test specs MUST specify MORE than 1 affected file so the skip-guard does not fire and the decomposition criteria are always evaluated.
- **Resolution:** SC-9 and SC-10 explicitly state the affected-files list contains MORE than 1 file (documented in the Change Control entry of 2026-08-17).

### Edge Case: Zero SCs or zero affected files

- **Condition:** A spec submitted to validate has zero SCs or zero affected files (degenerate input).
- **Expected behavior:** The decomposition check is not a substitute for overall spec validation; degenerate inputs are outside the decomposition check's skip-guard scope and are handled by validate's other checks.
- **Resolution:** Out of scope for this spec — the decomposition criteria evaluate SC quality, not spec presence. Noted here as a boundary to avoid treating the skip-guard as a general input validator.

### Edge Case: Concurrency / resource contention

- **Condition:** Two agents concurrently edit validate.md while the decomposition checklist is being added.
- **Expected behavior:** The change is a single-file edit (SC-1..SC-8 all target validate.md); concurrent edits are resolved by the repo's normal merge/rebase workflow.
- **Resolution:** Standard git conflict resolution applies; the spec makes no concurrency assumptions beyond normal single-file change management.

### Edge Case: Ceremony / Coverage comparison scope

- **Condition:** A spec contains an SC that appears redundant with the Problem Statement / intent prose, but is not entailed by any prior SC.
- **Expected behavior:** The Ceremony and Coverage criteria are computed as set-entailment over prior SCs only. The Problem Statement / intent prose universe is explicitly OUT OF SCOPE because the master reference's Binary Verifiability criterion (criterion 3) forbids interpretation-dependent verdicts. An SC that is redundant with prose but not with a prior SC is NOT flagged.
- **Resolution:** The comparison scope is bounded to prior SCs only, so the criteria remain mechanically checkable without interpretation.

### Edge Case: First SC in a spec

- **Condition:** A spec's first SC is evaluated against the Ceremony and Coverage criteria.
- **Expected behavior:** The first SC has no prior SCs, so its requirement set and verification signal are trivially not entailed by any prior SC. The Ceremony and Coverage criteria PASS for the first SC.
- **Resolution:** The set-entailment comparison over an empty prior-SC set yields PASS; the first SC is never flagged as ceremony or covered-by-prior.

### Edge Case: Behavioral test affected-files count for SC-13/SC-14

- **Condition:** A test harness or reader cannot determine the affected-files count of the SC-13/SC-14 test specs, causing the skip-guard to be ambiguous.
- **Expected behavior:** The behavioral test specs MUST specify MORE than 1 affected file so the skip-guard does not fire and the decomposition criteria are always evaluated.
- **Resolution:** SC-13 and SC-14 explicitly state the affected-files list contains MORE than 1 file, matching the SC-9/SC-10 pattern.

## Recency-Check Evidence

This section documents the verification that the spec's claims about current file state are accurate, per the re-audit revision reason. All checks were performed against the live working tree at revision time.

| Check | Claim Verified | Verification |
|-------|----------------|--------------|
| `spec-creation/tasks/validate.md` current state | At revision time, `grep` for the 4 criterion headings (`### Atomicity`, `### Single Deliverable`, `### Binary Verifiability`, `### PR-Gate Viability`) across `.opencode/skills/spec-creation/tasks/validate.md` returned no matches, so the headings are absent from the current file state | `grep` for the 4 headings across `.opencode/skills/spec-creation/tasks/validate.md` returned no matches; the file exists on disk (7135 bytes) |
| `audit/reference/decomposition-criteria.md` current state | The master reference file EXISTS and defines all 4 original criteria (Atomicity, Single Deliverable, Binary Verifiability, PR-Gate Viability) — the spec's Dependency claim is accurate. The maintainer note at the top of the file declares that inline copies are maintained in `spec-creation/tasks/validate.md`, `audit/tasks/spec-audit-evaluator.md`, and `writing-plans/tasks/validate.md`, and that when the file changes, all three must be updated in lockstep. This revision adds the new spec-level Ceremony and Coverage criteria section to BOTH the master reference and this spec's affected scope (validate.md) | File exists on disk; `grep` returned all 4 original criterion headings plus the summary table rows; the maintainer note is present at lines 7-10 |
| Commit history of `validate.md` | The validate task has recent, active change history, confirming it is a live maintained file | `git -C .opencode log` shows recent commits (e.g., `17ef1680 #2254 ...`, `93e7eb34 feat(#2225): add structured checks to validate.md`) |
| Commit history of `decomposition-criteria.md` | The master reference was created via `feat: create master decomposition criteria reference file` (commit `33adef85`) | `git -C .opencode log` on the reference file returned that single commit |

**Note:** No connectivity constraints apply to the files referenced in this spec; all are local files verified present in the working tree.

### Prescriptive-Code Carve-Out

Prescriptive-code carve-out: The exact grep strings in the SC-1..SC-8, SC-11, and SC-12 verification methods are an intentional, documented exception to the spec-structure-standards prescriptive-code prohibition. Deterministic grep patterns are REQUIRED in string-evidence verification methods so that independent auditors can reproduce PASS/FAIL without subjective judgment (per the 2026-08-17 Change Control entry).

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
| 2026-08-17 | Added the 3 missing preamble fields as sections: "Alternatives Considered & Why Discarded", "Key Design Decisions", and "User Intent / Original Prompt" (documenting that the original prompt is not recorded, and stating the recorded intent) | Re-audit FAILED on SC-1-preamble-structural / SC-12-preamble-fields — spec-structure-standards §1 requires a 6-field preamble; the spec had only 3 (Problem, Root Cause/Motivation, Approach) | spec-audit remediation |
| 2026-08-17 | Documented 3 alternative approaches evaluated and why each was discarded (runtime import, standalone tool, defer to audit evaluator) in the "Alternatives Considered & Why Discarded" section, and added "Key Design Decisions" with named tradeoffs | Re-audit FAILED on research-investigation-breadth — the spec selected the single inline-in-validate.md approach without documenting or ruling out alternatives | spec-audit remediation |
| 2026-08-17 | Added "Edge Cases" section covering input boundaries, state transitions, failure modes, concurrency, and recovery per spec-structure-standards §11, and added "Recency-Check Evidence" section with live file-state and commit-history verification of validate.md and decomposition-criteria.md | Re-audit FAILED — the spec was missing the "Edge Cases" section and lacked current-state verification evidence for its file claims | spec-audit remediation |
| 2026-08-17 | Added an explicit definition of "atomic work unit" (a single concern that cannot be further decomposed without losing meaning, and that maps to exactly one deliverable and one verifiable outcome) in a new "Atomic Work Unit" subsection under "Decomposition Criteria Definitions" | Re-audit FAILED on Completeness — the term 'atomic work units' was undefined, forcing implementor guessing | spec-audit remediation |
| 2026-08-17 | Pinned the exact expected values into the SC-9 and SC-10 criterion text: SC-9 now states that submitting a spec whose SC contains the conjunction `AND` (single SC `The system validates email format AND sends confirmation email`, MORE than 1 affected file) returns FAIL with the atomicity reason `SC contains trigger words indicating multiple concerns`; SC-10 now states that submitting a spec with a single atomic SC (single SC `The system validates email format on registration`, MORE than 1 affected file) returns PASS for decomposition criteria | Re-audit FAILED on Testability — SC-9 and SC-10 had ambiguous expected values, with the behavioral assertions' expected values only in the verification method, not in the criterion text | spec-audit remediation |
| 2026-08-19 | Aligned SC-9/SC-10 behavioral test verification methods with the merged clean-room sub-agent evaluation contract from issue #2245. Replaced the inline `opencode run` + "assert stderr contains FAIL/PASS" verification method with the Two-SC pattern: a behavioral test script (artifact-only generator) at `.opencode/tests-v2/behaviors/` generates session.yaml artifacts via `with-test-home` (exit 0, no in-script assertion), and a clean-room sub-agent evaluates session.yaml (the SQLite DB export — PRIMARY evidence per tests-v2/AGENTS.md §2/§5a) for FAIL/PASS evidence. Updated the SC-9/SC-10 verification method column, R-9/R-10, Item 9/Item 10 verify steps, and the SC-9/SC-10 Cost Frame statements. The behavioral SCs are NOT weakened or removed — only the evaluation is relocated to the clean-room session.yaml contract. The concrete test scenarios (monolithic AND-email SC for SC-9; single atomic SC for SC-10) are preserved. | Revision request: align SC-9/SC-10 behavioral test verification methods with the merged clean-room sub-agent evaluation contract from issue #2245 — the prior "assert stderr contains FAIL/PASS" inline opencode-run assertion contradicts tests-v2/AGENTS.md §2/§5a which mandate artifact-only generator scripts (behavior_run + exit 0) evaluated by orchestrator-dispatched clean-room sub-agents reading session.yaml as PRIMARY evidence | spec-creation revise task |
| 2026-08-19 | Clarified the 'mirror' language in the Approach section and the Dependencies SHALL clause: the inline copy in validate.md mirrors the CRITERIA CONTENT of the master reference file `audit/reference/decomposition-criteria.md`, not its numbered heading format. The inline copy SHALL use unnumbered headings (`### Atomicity`, `### Single Deliverable`, `### Binary Verifiability`, `### PR-Gate Viability`) per SC-1. SC-1, Item 1, the Definitions section, and all other SCs are unchanged. The criteria content mirroring requirement and the cross-reference comment requirement (SC-7) are preserved. | Spec-audit Internal Consistency FAIL — the Approach (line 26) and Dependencies SHALL clause (lines 276-278) stated the inline copy SHALL 'mirror' the master reference, but the master reference uses numbered criterion headings (`### 1. Atomicity`, etc.) while SC-1, Item 1, and the Definitions section specify unnumbered headings. An implementor following 'mirror' would copy numbered headings and fail SC-1's grep for unnumbered headings. Resolution (option b): clarify that the inline copy mirrors criteria content, not heading numbering. | spec-audit remediation |
| 2026-08-19 | Reworded the Recency-Check Evidence 'Claim Verified' cell for `spec-creation/tasks/validate.md` to remove the prohibited status/tracking markers 'RED state confirmed' and 'not yet implemented'. The cell now describes the grep result factually as a verification check outcome at revision time (grep for the 4 headings returned no matches), without status markers. No SC criterion text, evidence type, or verification method was changed. | Spec-audit SC-TRACKING-LANG FAIL — the Recency-Check Evidence section used prohibited status/tracking markers ('confirmed', 'not yet implemented'); specs are not tracking documents. | spec-audit remediation |
| 2026-08-19 | Added a 'Prescriptive-Code Carve-Out' subsection under the Recency-Check Evidence section documenting that the exact grep strings in the SC-1..SC-8 verification methods are an intentional, documented exception to the spec-structure-standards prescriptive-code prohibition, required for deterministic, independently reproducible PASS/FAIL (per the 2026-08-17 Change Control entry). No SC criterion text, evidence type, or verification method was changed. | Spec-audit SC-PRESCRIPTIVE-CODE FAIL — the exact grep assertion strings in the SC-1..SC-8 verification-method column were flagged as prescriptive code per spec-structure-standards §Prohibited Content Patterns; this is a standard-conformant deviation requiring an explicit documented carve-out. | spec-audit remediation |
| 2026-08-19 | Substantive revision: added a new spec-level section to the decomposition criteria set for two additional defect classes detected at the same decomposition pass as the existing four criteria. (1) **Ceremony** — an SC that adds zero verification signal over the union of prior SCs (same deliverable + same verification method, no new requirement). (2) **Coverage / covered-by-prior** — an SC whose requirement set is already entailed by a prior SC. Both are computed as set-entailment over prior SCs only; the Problem Statement / intent prose universe is explicitly OUT OF SCOPE because the master reference's Binary Verifiability criterion (criterion 3) forbids interpretation-dependent verdicts. The new section is spec-level only; it does not touch the plan-level criteria (acyclic DAG, file collision freedom, explicit dependency declaration). Added SC-11 (Ceremony, string), SC-12 (Coverage, string), SC-13 (Ceremony behavioral rejection), SC-14 (Coverage behavioral rejection); R-11..R-14; Item 11..Item 14; updated the Problem, Approach, Alternatives Considered, Decomposition Criteria Definitions, Success Criteria, Requirements, Items, Not Included, Affected Files, Dependencies, Traceability, Phase Mapping, Cost Frame, Edge Cases, Recency-Check Evidence, Prescriptive-Code Carve-Out, and Documentation Sources sections. The master reference at `audit/reference/decomposition-criteria.md` already declares the maintainer note requiring inline copies be updated in lockstep in `spec-creation/tasks/validate.md` and `audit/tasks/spec-audit-evaluator.md`; this revision adds the new section to BOTH the master reference and this spec's affected scope (validate.md). | Substantive revision per requirements discussion — the spec-level decomposition criteria set gains a new section for two additional defect classes (Ceremony, Coverage / covered-by-prior) detected at the same decomposition pass as the existing four criteria. | spec-creation revise task |
| 2026-08-19 | NON-SUBSTANTIVE revision per cold-reading re-evaluation. Reworded the four behavioral SCs (SC-9, SC-10, SC-13, SC-14) from exact static reason-string reproduction to semantic-verdict reproduction, because behavioral evidence verifies agent ACTIONS and DECISIONS, not byte-exact literals from non-deterministic LLM output. SC-9 now requires FAIL for the atomicity/decomposition check (monolithic AND SC rejected) with the FAIL reason semantically indicating multiple concerns / a compound SC; SC-10 now requires PASS or NOT rejected (no FAIL verdict; WARN is an acceptable pass-equivalent); SC-13 now requires FAIL for the decomposition/ceremony check (second SC is ceremony — identical deliverable + identical verification method, no new requirement) with the FAIL reason semantically indicating ceremony / no new verification signal; SC-14 now requires FAIL for the decomposition/coverage check (second SC's requirement set already entailed by a prior SC) with the FAIL reason semantically indicating coverage / duplicate / covered-by-prior. Updated the corresponding R-9/R-10/R-13/R-14 and Item 9/Item 10/Item 13/Item 14 wording to match. Also updated the SC-13 scenario reference so the first SC is atomic (`The system validates email format on registration`) and the second SC is ceremony (identical), matching the corrected fixture. All four SC evidence types remain behavioral. No SC was removed, weakened, deferred, or re-scoped — the semantic verdict requirements (monolithic rejected, atomic accepted, ceremony rejected, covered-by-prior rejected) are UNCHANGED; only the exact-string verification wording was relaxed. | NON-SUBSTANTIVE revision per cold-reading re-evaluation — the four behavioral SCs (SC-9, SC-10, SC-13, SC-14) demand exact static reason-string reproduction from non-deterministic LLM output, which is structurally unachievable in behavioral evidence. Behavioral evidence verifies agent ACTIONS and DECISIONS, not byte-exact literals. | spec-creation revise task |
