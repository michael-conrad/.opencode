# Spec: Restore Audit Decomposition Verification (Corrected Scope)

## 1. Intent and Executive Summary

### Problem Statement

The audit skill's `spec-audit-evaluator` task does not independently verify SC decomposition quality. Specs with monolithic SCs pass audit and advance to plan creation, where defects are more expensive to fix. A path-defect investigation confirmed three concrete defects that break decomposition evaluation and reference resolution:

1. `skills/audit/tasks/spec-audit-evaluator.md` contains **zero** decomposition-criteria content. It cannot independently render decomposition verdicts, so audit silently skips the decomposition quality gate that catches monolithic, ceremonial, or redundant SCs.
2. 34 bare `reference/...` links across 14+ audit task cards in `skills/audit/tasks/` resolve to the nonexistent `skills/audit/reference/` directory. They must resolve to `.opencode/reference/...` (the canonical reference directory) to load the standards documents the tasks depend on.
3. The master reference maintainer note (`audit/reference/decomposition-criteria.md`) lists an incorrect path `audit/tasks/spec-audit-evaluator.md`; the correct path is `skills/audit/tasks/spec-audit-evaluator.md`.

### Root Cause / Motivation

The evaluator was written to depend on upstream evidence but was never populated with the decomposition criteria it must enforce. The maintainer note asserts the evaluator maintains an inline copy in lockstep with the master reference, but the evaluator contains zero decomposition content — the note's claim is false. As a result, decomposition quality (atomicity, single deliverable, binary verifiability, PR-gate viability, ceremony, coverage) is not independently verified, allowing low-quality SCs to pass audit. This must be corrected now because the audit gate is the enforcement point that catches the very spec-quality defects this spec itself was created to prevent.

### Approach Chosen

Three coordinated edits: (1) create the inline decomposition-criteria copy in `skills/audit/tasks/spec-audit-evaluator.md` covering all six spec-level criteria and their sub-checks, in lockstep with the master reference, plus behavioral RED/GREEN tests asserting the evaluator's verdicts; (2) correct the 34 bare `reference/...` links in the audit task cards to `.opencode/reference/...`; (3) correct the maintainer-note path defect in the master reference. The master reference already contains criteria 5 (Ceremony) and 6 (Coverage/Covered-by-Prior) — this spec verifies that fact and does not attempt to add them.

### Alternatives Considered & Why Discarded

- **Refactor the evaluator to read the master reference at runtime instead of maintaining an inline copy.** Discarded: the master reference's maintainer note and the audit pipeline contract require the evaluator to render verdicts independently (adversarial separation), and the inline copy is the established pattern across the spec-creation and writing-plans validators. Removing the inline copy would diverge from the maintainer-note contract.
- **Add the missing Ceremony/Coverage criteria to the master reference.** Discarded: the master reference already contains criteria 5 and 6 at lines 122-156. Adding them would duplicate existing content (a Coverage/Ceremony violation itself).

### Key Design Decisions

- **Evaluator verifies decomposition independently (adversarial separation).** The evaluator renders its own verdicts from its inline copy rather than re-reading spec-creation validation output. This keeps audit independent of the producer. Tradeoff: the inline copy must be kept in lockstep with the master reference (maintainer note), at the cost of duplicate content.
- **Ceremony/Coverage are set-entailment over prior SCs only.** Problem Statement / intent prose is OUT OF SCOPE because the Binary Verifiability criterion forbids interpretation-dependent verdicts. Tradeoff: strictly mechanical, but cannot detect redundancy relative to prose intent.

### User Intent / Original Prompt

A spec-creation holistic validation of `.opencode#2117` returned FAIL (holistic gate FAIL and structural-check FAIL) on a false central premise: the spec directed work at ADDING decomposition criteria to a master reference that already contains them. This revision restructures the spec to correct that premise and address all validation FAIL dimensions.

## 2. Not Included

- **Adding Ceremony/Coverage criteria to the master reference** — the master reference already contains criteria 5 (Ceremony) and 6 (Coverage/Covered-by-Prior); this spec verifies rather than adds.
- **Modifying the spec-creation or writing-plans validators' inline copies** — only the audit evaluator's missing inline copy is in scope; the other two validators already contain or are governed by their own lockstep processes.
- **Behavioral verification of non-audit evaluators** — behavioral tests target only the audit spec-audit-evaluator decomposition verdicts.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `skills/audit/tasks/spec-audit-evaluator.md` includes an inline decomposition-criteria checklist for the four base spec-level criteria: atomicity, single deliverable, binary verifiability, PR-gate viability | string | grep each base criterion name in spec-audit-evaluator.md |
| SC-2 | Each base criterion uses an imperative binary decision-tree format with explicit PASS/FAIL branches (not prose guidance) | string | grep for PASS/FAIL branching in the inline checklist |
| SC-3 | The atomicity check includes a trigger-word sub-check (and, or, comma-separated lists → FAIL) | string | grep for the trigger-word sub-check |
| SC-4 | The binary verifiability check includes a disjunctive-pattern sub-check (either/or, alternatively, one of → FAIL) | string | grep for the disjunctive sub-check |
| SC-5 | The binary verifiability check includes a vague-term sub-check (should, could, ideally, as appropriate → FAIL) | string | grep for the vague-term sub-check |
| SC-6 | The PR-gate viability check references the meta RED/GREEN principle | string | grep for the RED/GREEN reference |
| SC-7 | The inline copy includes the cross-reference comment: `See audit/reference/decomposition-criteria.md for master definition` | string | grep for the cross-reference comment |
| SC-8 | The decomposition check is skipped (not evaluated) when the spec has exactly 1 SC AND exactly 1 affected file | string | grep for the skip trigger condition |
| SC-9 | Behavioral: a spec with a monolithic SC containing 'and' submitted to spec-audit returns FAIL with a decomposition reason | behavioral | opencode run with assertion |
| SC-10 | Behavioral: a spec with a single atomic SC submitted to spec-audit returns PASS for the decomposition criteria | behavioral | opencode run with assertion |
| SC-11 | `audit/reference/decomposition-criteria.md` contains a spec-level 'Redundancy Detection' section defining the Ceremony (criterion 5) and Coverage / Covered-by-Prior (criterion 6) defect classes | string | grep for the section heading and both defect class names in the existing master reference |
| SC-12 | Both redundancy criteria are computed as set-entailment over all prior SCs only, and the Problem Statement / intent prose universe is explicitly OUT OF SCOPE | string | grep for the out-of-scope declaration in the existing master reference |
| SC-13 | The redundancy section is spec-level only and independent of the plan-level criteria | string | grep for the spec-level-only declaration in the existing master reference |
| SC-14 | The Ceremony check defines FAIL as an SC that adds zero verification signal over the union of prior SCs (same deliverable + same verification method, no new requirement) | string | grep for the Ceremony FAIL definition in the existing master reference |
| SC-15 | The Coverage check defines FAIL as an SC whose requirement set is already entailed by a prior SC | string | grep for the Coverage FAIL definition in the existing master reference |
| SC-16 | The inline copy in `skills/audit/tasks/spec-audit-evaluator.md` is created to include the Ceremony (criterion 5) and Coverage (criterion 6) criteria in lockstep with the master reference, reconciling the maintainer-note lockstep claim with the current empty state (the inline copy must be created, not merely checked) | string | grep for the Ceremony and Coverage criteria in spec-audit-evaluator.md |
| SC-17 | Behavioral: a spec where a later SC repeats an earlier SC's requirement set (Coverage) submitted to spec-audit returns FAIL with a coverage reason | behavioral | opencode run with assertion |
| SC-18 | Behavioral: a spec where a later SC adds zero verification signal over prior SCs (Ceremony) submitted to spec-audit returns FAIL with a ceremony reason | behavioral | opencode run with assertion |
| SC-19 | Behavioral: a spec where each SC adds a distinct requirement with a distinct verification method submitted to spec-audit returns PASS for the redundancy criteria | behavioral | opencode run with assertion |
| SC-20 | All bare `reference/...` link patterns (`reference/cost-model-standards.md`, `reference/spec-structure-standards.md`, `reference/plan-structure-standards.md`) are absent from all audit task cards in `skills/audit/tasks/`; the corrected `.opencode/reference/...` paths are present across those cards | string | grep for absence of each bare pattern and presence of each corrected path across skills/audit/tasks/ |
| SC-21 | The master reference maintainer note path `audit/tasks/spec-audit-evaluator.md` is corrected to `skills/audit/tasks/spec-audit-evaluator.md` | string | grep for the corrected path in the maintainer note |

## 4. Requirements

R-1. The evaluator `skills/audit/tasks/spec-audit-evaluator.md` SHALL contain an inline decomposition-criteria checklist for the four base spec-level criteria: atomicity, single deliverable, binary verifiability, and PR-gate viability.
R-2. Each of the four base criteria SHALL use an imperative binary decision-tree format with explicit PASS/FAIL branches.
R-3. The atomicity check SHALL include a trigger-sub-word sub-check flagging `and`, `or`, and comma-separated lists as FAIL.
R-4. The binary verifiability check SHALL include a disjunctive-pattern sub-check flagging `either/or`, `alternatively`, and `one of` as FAIL.
R-5. The binary verifiability check SHALL include a vague-term sub-check flagging `should`, `could`, `ideally`, and `as appropriate` as FAIL.
R-6. The PR-gate viability check SHALL reference the meta RED/GREEN principle.
R-7. The inline copy SHALL include the cross-reference comment to the master reference.
R-8. The decomposition check SHALL be skipped when the spec has exactly one SC and exactly one affected file.
R-9. The audit evaluator SHALL return FAIL for a spec containing a monolithic SC.
R-10. The audit evaluator SHALL return PASS for the decomposition criteria on a spec of atomic SCs.
R-11. The master reference SHALL contain a spec-level 'Redundancy Detection' section defining the Ceremony and Coverage defect classes.
R-12. The redundancy criteria SHALL be computed as set-entailment over all prior SCs only, with the Problem Statement universe explicitly out of scope.
R-13. The redundancy section SHALL be spec-level only and independent of plan-level criteria.
R-14. The Ceremony check SHALL define FAIL as an SC adding zero verification signal over the union of prior SCs.
R-15. The Coverage check SHALL define FAIL as an SC whose requirement set is already entailed by a prior SC.
R-16. The evaluator SHALL maintain an inline copy of the Ceremony and Coverage criteria in lockstep with the master reference.
R-17. The evaluator SHALL render FAIL for coverage redundancy and ceremony redundancy in behavioral testing.
R-18. The evaluator SHALL render PASS for a spec whose SCs each add distinct requirements and methods.
R-19. All bare `reference/...` links in audit task cards SHALL be corrected to `.opencode/reference/...`.
R-20. The master reference maintainer note SHALL use the corrected path `skills/audit/tasks/spec-audit-evaluator.md`.

## 5. Items

### Item 1 (SC-01): Add inline base-criteria checklist to the evaluator
- RED: behavioral/string test asserts the checklist absent from spec-audit-evaluator.md
- GREEN: add the inline checklist for atomicity, single deliverable, binary verifiability, PR-gate viability
- verify: grep each criterion name present
- commit: checklist content

### Item 2 (SC-02): Add binary decision-tree format
- RED: assert no PASS/FAIL branching in the inline checklist
- GREEN: convert each base criterion to imperative binary decision-tree with PASS/FAIL branches
- verify: grep PASS/FAIL branches
- commit: format

### Item 3 (SC-03): Add atomicity trigger-sub-check
- RED: assert no trigger-sub-check in the atomicity criterion
- GREEN: add the `and`/`or`/comma-list sub-check
- verify: grep sub-check
- commit: sub-check content

### Item 4 (SC-04): Add disjunctive-pattern sub-check
- RED: assert no disjunctive sub-check in the binary verifiability criterion
- GREEN: add the `either/or`/`alternatively`/`one of` sub-check
- verify: grep sub-check
- commit: sub-check content

### Item 5 (SC-05): Add vague-term sub-check
- RED: assert no vague-term sub-check present
- GREEN: add the `should`/`could`/`ideally`/`as appropriate` sub-check
- verify: grep sub-check
- commit: sub-check content

### Item 6 (SC-06): Add RED/GREEN reference to PR-gate criterion
- RED: assert no RED/GREEN reference
- GREEN: add the meta RED/GREEN principle reference
- verify: grep reference
- commit: content

### Item 7 (SC-07): Add cross-reference comment
- RED: assert no cross-reference comment
- GREEN: add the 'See audit/reference/decomposition-criteria.md for master definition' comment
- verify: grep comment
- commit: content

### Item 8 (SC-08): Add single-spec skip condition
- RED: assert no skip condition
- GREEN: add the skip logic for 1 SC + 1 affected file
- verify: grep trigger condition
- commit: content

### Item 9 (SC-09): Behavioral FAIL test for monolithic SC
- RED: test asserts an 'and'-laden SC fails; run and observe
- GREEN: (no code change beyond Item 1-8; test validates the implemented evaluator)
- verify: opencode run with stderr assertion
- commit: behavioral test

### Item 10 (SC-10): Behavioral PASS test for atomic SC
- RED: test asserts atomic SC passes; run and observe
- GREEN: (no additional code change)
- verify: opencode run with stderr assertion
- commit: behavioral test

### Item 11 (SC-11): Verify master reference redundancy section
- RED: assert the master reference lacks the section
- GREEN: none needed (verification item); if absent, block with BLOCKED
- verify: grep section heading and both defect-class names in the existing master reference
- commit: verification-only item

### Item 12 (SC-12): Verify set-entailment / out-of-scope semantics
- RED: assert absence of the out-of-scope declaration
- GREEN: none (verification)
- verify: grep out-of-scope declaration in the existing master reference
- commit: verification-only item

### Item 13 (SC-13): Verify spec-level-only scope
- RED: assert absence of the spec-level-only declaration
- GREEN: none (verification)
- verify: grep declaration in the existing master reference
- commit: verification-only item

### Item 14 (SC-14): Verify Ceremony FAIL definition
- RED: assert absence of the Ceremony FAIL definition
- GREEN: none (verification)
- verify: grep the Ceremony FAIL definition in the existing master reference
- commit: verification-only item

### Item 15 (SC-15): Verify Coverage FAIL definition
- RED: assert absence of the Coverage FAIL definition
- GREEN: none (verification)
- verify: grep the Coverage FAIL definition in the existing master reference
- commit: verification-only item

### Item 16 (SC-16): Create inline Ceremony/Coverage copy in the evaluator
- RED: assert no Ceremony/Coverage content in the evaluator
- GREEN: create the inline criteria 5-6 copy matching the master reference
- verify: grep the Ceremony and Coverage content in spec-audit-evaluator.md
- commit: inline copy

### Item 17 (SC-17): Behavioral FAIL test for Coverage
- RED: test asserts coverage-redundancy FAIL; run and observe
- GREEN: none (implementation in Item 16)
- verify: opencode run with stderr assertion
- commit: behavioral test

### Item 18 (SC-18): Behavioral FAIL test for Ceremony
- RED: test asserts ceremony FAIL; run and observe
- GREEN: none (implementation in Item 16)
- verify: opencode run with stderr assertion
- commit: behavioral test

### Item 19 (SC-19): Behavioral PASS test for distinct SCs
- RED: test asserts distinct-SC PASS; run and observe
- GREEN: none (implementation in Item 16)
- verify: opencode run with stderr assertion
- commit: behavioral test

### Item 20 (SC-20): Correct bare reference links in audit cards
- RED: assert each bare `reference/...` pattern present across skills/audit/tasks/
- GREEN: replace all bare patterns with the corrected `.opencode/reference/...` path
- verify: grep absence of bare patterns and presence of corrected paths across skills/audit/tasks/
- commit: link correction

### Item 21 (SC-21): Correct maintainer path defect
- RED: assert the incorrect `audit/tasks/spec-audit-evaluator.md` path
- GREEN: correct the maintainer-note path to `skills/audit/tasks/spec-audit-evaluator.md`
- verify: grep the corrected path in the maintainer note
- commit: content

## 6. Dependencies

- **Reference:** `skills/audit/tasks/spec-audit-evaluator.md` — Relationship: the file edited for Items 1-19 must exist and be readable. Status: satisfied (exists).
- **Reference:** `audit/reference/decomposition-criteria.md` — Relationship: the master reference (criteria 5-6 already present; read for the inline copy). Status: satisfied (exists).
- **Reference:** `.opencode/reference/` — Relationship: target directory for corrected links in Item 20; must contain cost-model-standards.md, spec-structure-standards.md, plan-structure-standards.md. Status: satisfied (directory exists; files referenced in the corrected paths).
- **Reference:** `skills/audit/tasks/*.md` — Relationship: the audit cards edited in Item 20. Status: satisfied (21 files exist).
- **Reference:** `with-test-home` harness + qwen3.6:35b-256k — Relationship: required to run behavioral RED/GREEN tests in Items 9-10, 17-19. Status: satisfied (model verified available; behavioral evidence requires `opencode run`).

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-01 | Phase 1 |
| R-2 | SC-02 | Phase 1 |
| R-3 | SC-03 | Phase 1 |
| R-4 | SC-04 | Phase 1 |
| R-5 | SC-05 | Phase 1 |
| R-6 | SC-06 | Phase 1 |
| R-7 | SC-07 | Phase 1 |
| R-8 | SC-08 | Phase 1 |
| R-9 | SC-09 | Phase 1 |
| R-10 | SC-10 | Phase 1 |
| R-11 | SC-11, SC-14, SC-15 | Phase 1 |
| R-12 | SC-12 | Phase 1 |
| R-13 | SC-13 | Phase 1 |
| R-14 | SC-14 | Phase 1 |
| R-15 | SC-15 | Phase 1 |
| R-16 | SC-16 | Phase 2 |
| R-17 | SC-17, SC-18 | Phase 2 |
| R-18 | SC-19 | Phase 2 |
| R-19 | SC-20 | Phase 3 |
| R-20 | SC-21 | Phase 3 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| Decomposition criteria master reference | code | `.opencode/audit/reference/decomposition-criteria.md` | read + grep (verified criteria 5-6 present at lines 122-156) |
| Audit evaluator task | code | `.opencode/skills/audit/tasks/spec-audit-evaluator.md` | read (verified zero decomposition content) |
| Audit task cards | code | `.opencode/skills/audit/tasks/*.md` | grep (verified 34 bare `reference/` links across 21 files) |
| Spec structure standards | doc | `.opencode/reference/spec-structure-standards.md` | read (verified required sections) |
| Canonical reference dir | code | `.opencode/reference/` | grep (verified files referenced by corrected paths exist) |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

- **SC-01:** Adding the inline base-criteria checklist costs minimal context — the evaluator can then verify decomposition. Skipping it costs high latency — monolithic SCs pass audit and advance to plan creation, where defects are far more expensive. Correctness is the only metric.
- **SC-02:** Adding the binary decision-tree format costs minimal context — enables deterministic verdicts. Skipping it costs high latency — prose guidance yields interpretation-dependent verdicts. Correctness is the only metric.
- **SC-03:** Adding the atomicity trigger sub-check costs minimal context. Skipping it lets compound SCs pass, pushing bundling defects downstream. Correctness is the only metric.
- **SC-04:** Adding the disjunctive sub-check costs minimal context. Skipping it lets either/or ambiguity reach implementation. Correctness is the only metric.
- **SC-05:** Adding the vague-term sub-check costs minimal context. Skipping it lets aspirational SCs pass. Correctness is the only metric.
- **SC-06:** Adding the RED/GREEN reference costs minimal context. Skipping it weakens PR-gate viability enforcement. Correctness is the only metric.
- **SC-07:** Adding the cross-reference comment costs minimal context. Skipping it breaks traceability to the master. Correctness is the only metric.
- **SC-08:** Adding the skip condition costs minimal context. Skipping it over-flag valid single-SC specs. Correctness is the only metric.
- **SC-09:** Behavioral atomicity FAIL test costs a real `opencode run` — the only valid evidence for verdict behavior. Skipping it substitutes grep for behavior, which is EVIDENCE_TYPE_MISMATCH. Correctness is the only metric.
- **SC-10:** Behavioral atomic PASS test costs a real `opencode run`. Skipping it leaves the pass path unverified. Correctness is the only metric.
- **SC-11:** Verifying the master redundancy section costs a grep. Skipping it risks re-adding existing criteria. Correctness is the only metric.
- **SC-12:** Verifying set-entailment semantics costs a grep. Skipping it risks scope-creep from intent-prose comparisons. Correctness is the only metric.
- **SC-13:** Verifying spec-level-only costs a grep. Skipping it risks conflating spec-level and plan-level checks. Correctness is the only metric.
- **SC-14:** Verifying the Ceremony FAIL definition costs a grep. Skipping it risks an unenforced ceremony check. Correctness is the only metric.
- **SC-15:** Verifying the Coverage FAIL definition costs a grep. Skipping it risks an unenforced coverage check. Correctness is the only metric.
- **SC-16:** Adding the inline Ceremony/Coverage copy costs minimal context. Skipping it keeps the evaluator's lockstep claim false and redundant SCs uncaught. Correctness is the only metric.
- **SC-17:** Behavioral Coverage FAIL test costs a real `opencode run`. Skipping it substitutes structural for behavioral evidence. Correctness is the only metric.
- **SC-18:** Behavioral Ceremony FAIL test costs a real `opencode run`. Skipping it leaves the ceremony verdict unverified. Correctness is the only metric.
- **SC-19:** Behavioral distinct-pass test costs a real `opencode run`. Skipping it leaves the pass path for redundancy unverified. Correctness is the only metric.
- **SC-20:** Correcting the bare reference links costs minimal context. Skipping it keeps 34 broken references resolving to a nonexistent directory, breaking task execution. Correctness is the only metric.
- **SC-21:** Correcting the maintainer path costs minimal context. Skipping it keeps the maintainer note pointing to the wrong file. Correctness is the only metric.

## 11. Edge Cases

- **Condition:** Evaluator is loaded for a spec that is a skill-card audit. — **Expected behavior:** the inline decomposition checklist must still render; skill-card-specific SC-SEM handling is separate and unaffected. — **Resolution:** checklist is criteria-level, orthogonal to SC-SEM evaluation.
- **Condition:** A spec has exactly one SC and one affected file. — **Expected behavior:** the decomposition check is skipped (SC-08). — **Resolution:** skip logic explicitly defined.
- **Condition:** The master reference is edited after the inline copy is created (drift). — **Expected behavior:** the inline copy must be brought into lockstep per the maintainer note. — **Resolution:** maintainer note + SC-16 document the lockstep requirement; drift is flagged at audit time.
- **Condition:** A behavioral test cannot run (model/tooling unavailable). — **Expected behavior:** FAIL is the only valid outcome per the test-integrity mandate; no structural substitute. — **Resolution:** diagnose and re-run; escalate only after remediation failure.
- **Condition:** A bare `reference/` path also appears in a file not scanned by the SC-20 grep. — **Expected behavior:** SC-20 greps across all `skills/audit/tasks/*.md`. — **Resolution:** the grep scopes is the full tasks directory; any residual bare pattern is a FAIL.

## Change Control

- 2026-08-19 — Original scope: defined decomposition verification in the audit evaluator and added a spec-level 'Redundancy Detection' section (Ceremony, Coverage) to the decomposition criteria set. Authorized by: requirements discussion.
- 2026-08-19 — Path-defect investigation: corrected affected-files path references, added SCs for the 34 broken bare `reference/` links and the maintainer-note path defect. Authorized by: spec-audit findings.
- 2026-08-24 — SPEC-VALIDATION FAIL REVISION (iteration 1): Corrected the false central premise. The master reference already contains criteria 5 (Ceremony) and 6 (Coverage/Covered-by-Prior) at lines 122-143; SC-11..SC-15 re-framed from add-work into verification-only SCs (string evidence: grep the existing master). Consolidated the SC-15/SC-23 conflict into a single add-work SC (SC-16) requiring the inline Ceremony/Coverage copy be CREATED in the evaluator, then kept in lockstep. Split the compound SCs SC-4, SC-15, SC-19, SC-20, SC-21, SC-23 into atomic, single-deliverable SCs; merged the near-duplicate SC-19/20/21 into SC-20 (one deliverable correcting all three bare reference patterns to `.opencode/reference/`). Added all mandatory structural sections (Requirements, Items, Traceability, Documentation Sources, Enforcement Gate, Cost Frame, Edge Cases, Not Included, Alternatives Considered, Key Design Decisions) and a per-SC cost frame. Authorized by: spec-creation holistic validation FAIL.
