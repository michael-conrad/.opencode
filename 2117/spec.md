## Problem

The audit skill's spec-audit evaluator does not independently verify SC decomposition quality. Specs with monolithic SCs pass audit and advance to plan creation, where defects are more expensive to fix. The decomposition criteria set also lacks checks for redundant or ceremonial SCs — SCs that add no verification signal over prior SCs, or whose requirements are already entailed by an earlier SC.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `audit/tasks/spec-audit-evaluator.md` includes inline decomposition criteria checklist for 4 spec-level criteria: atomicity, single deliverable, binary verifiability, PR-gate viability | string | grep for each criterion in spec-audit-evaluator.md |
| SC-2 | Each criterion uses imperative binary decision tree format with explicit PASS/FAIL branches (not prose guidance) | string | grep for PASS/FAIL branching |
| SC-3 | Atomicity check includes trigger-word sub-check (and, or, comma-separated lists → FAIL) | string | grep for trigger word sub-check |
| SC-4 | Binary verifiability check includes disjunctive pattern sub-check (either/or, alternatively, one of → FAIL) and vague term sub-check (should, could, ideally, as appropriate → FAIL) | string | grep for disjunctive and vague term sub-checks |
| SC-5 | PR-gate viability check references meta RED/GREEN principle | string | grep for RED/GREEN reference |
| SC-6 | Inline copy includes cross-reference comment: 'See audit/reference/decomposition-criteria.md for master definition' | string | grep for cross-reference |
| SC-7 | Decomposition check is skipped (not evaluated) when spec has exactly 1 SC AND 1 affected file | string | grep for trigger condition |
| SC-8 | Behavioral test: spec with monolithic SC containing 'and' submitted to spec-audit returns FAIL with correct reason | behavioral | opencode run with assertion |
| SC-9 | Behavioral test: spec with single atomic SC submitted to spec-audit returns PASS for decomposition criteria | behavioral | opencode run with assertion |
| SC-10 | `audit/reference/decomposition-criteria.md` (master reference) includes a new spec-level 'Redundancy Detection' section defining two additional defect classes: Ceremony and Coverage (covered-by-prior) | string | grep for section heading and both defect class names |
| SC-11 | Both new criteria are computed as set-entailment over prior SCs only; Problem Statement / intent prose universe is explicitly OUT OF SCOPE | string | grep for out-of-scope declaration |
| SC-12 | New section is spec-level only and independent of the plan-level criteria | string | grep for spec-level-only declaration |
| SC-13 | Ceremony check defined: an SC that adds zero verification signal over the union of prior SCs (same deliverable + same verification method, no new requirement) → FAIL | string | grep for Ceremony definition |
| SC-14 | Coverage check defined: an SC whose requirement set is already entailed by a prior SC → FAIL | string | grep for Coverage definition |
| SC-15 | `audit/tasks/spec-audit-evaluator.md` inline copy includes the new spec-level 'Redundancy Detection' section in lockstep with the master reference, and the maintainer note declares the lockstep update requirement | string | grep for section and maintainer note in spec-audit-evaluator.md |
| SC-16 | Behavioral test: spec where a later SC repeats an earlier SC's requirement set (Coverage) submitted to spec-audit returns FAIL with coverage reason | behavioral | opencode run with assertion |
| SC-17 | Behavioral test: spec where a later SC adds zero verification signal over prior SCs (Ceremony) submitted to spec-audit returns FAIL with ceremony reason | behavioral | opencode run with assertion |
| SC-18 | Behavioral test: spec where each SC adds a distinct requirement with a distinct verification method submitted to spec-audit returns PASS for the new redundancy criteria | behavioral | opencode run with assertion |

## Approach

Edit `audit/reference/decomposition-criteria.md` to add a new spec-level 'Redundancy Detection' section defining two defect classes — Ceremony and Coverage (covered-by-prior) — computed as set-entailment over prior SCs only. The Problem Statement / intent prose universe is explicitly OUT OF SCOPE because the master reference's Binary Verifiability criterion forbids interpretation-dependent verdicts. The section is spec-level only and independent of the plan-level criteria.

Edit `audit/tasks/spec-audit-evaluator.md` to add the same new spec-level section to the inline copy, in lockstep with the master reference per the maintainer note. Same criteria as Phase 2, independently applied. The evaluator reads the spec independently and produces its own verdicts — this is adversarial separation, not a re-check of spec-creation validate.

## Affected Files

- `audit/reference/decomposition-criteria.md` (edit) — add new spec-level 'Redundancy Detection' section (Ceremony, Coverage)
- `audit/tasks/spec-audit-evaluator.md` (edit) — add the new spec-level section to the inline copy in lockstep

## Dependencies

Depends on Phase 1 PR being merged (master reference file must exist). Can be implemented in parallel with Phase 2.

## Change Control

- 2026-08-19 — Substantive revision per requirements discussion: added a new spec-level 'Redundancy Detection' section (Ceremony, Coverage) to the decomposition criteria set, applied in the same pass as the existing four criteria. Both computed as set-entailment over prior SCs only; Problem Statement / intent prose explicitly OUT OF SCOPE per Binary Verifiability. Section is spec-level only, independent of plan-level criteria. Updated Success Criteria (SC-10..SC-18), Approach, and Affected Files to add the section to both the master reference and this spec's inline copy. Authorized by: developer requirements discussion.
