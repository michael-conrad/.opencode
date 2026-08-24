---
remote_issue: 2117
remote_url: "https://github.com/michael-conrad/.opencode/issues/2117"
last_sync: "2026-08-24T10:12:00Z"
source: github
---

> **Full spec and plan artifacts:** [`.opencode/.issues/2117/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2117) — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2117/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem

The audit skill's spec-audit evaluator does not independently verify SC decomposition quality. Specs with monolithic SCs pass audit and advance to plan creation, where defects are more expensive to fix. The decomposition criteria set also lacks checks for redundant or ceremonial SCs — SCs that add no verification signal over prior SCs, or whose requirements are already entailed by an earlier SC. A spec-audit returned DRAFT (holistic gate FAIL, 9/11 dimensions) and a path-defect investigation found the spec's own affected-files paths resolve incorrectly, 34 broken bare `reference/` links across 14+ audit task cards resolve to a nonexistent directory, the master reference maintainer note contains a path defect, and the master reference falsely claims the evaluator maintains an inline decomposition copy when it contains zero decomposition content.

## Scope

- Add a new spec-level 'Redundancy Detection' section to the decomposition criteria set, applied in the same pass as the existing four criteria (atomicity, single deliverable, binary verifiability, PR-gate viability).
- Define two new defect classes: Ceremony (an SC that adds zero verification signal over the union of prior SCs) and Coverage / covered-by-prior (an SC whose requirement set is already entailed by a prior SC).
- Both are computed as set-entailment over prior SCs only, applied in both the master reference and the spec-audit evaluator's inline copy in lockstep.
- Add structural evidence-type SCs and behavioral enforcement tests for each defect class.
- Correct the spec's own affected-files path defects (`audit/tasks/spec-audit-evaluator.md` → `skills/audit/tasks/spec-audit-evaluator.md`).
- Correct 34 broken bare `reference/` links across 14+ audit task cards to `.opencode/reference/` (cost-model-standards, spec-structure-standards, plan-structure-standards).
- Correct the master reference maintainer note path defect and create the evaluator's inline decomposition copy to reconcile SC-15's lockstep requirement with the actual current state.

**Out of scope:** The Problem Statement / intent prose universe is explicitly OUT OF SCOPE for the new criteria (the master reference's Binary Verifiability criterion forbids interpretation-dependent verdicts). The new section is spec-level only and independent of the plan-level criteria.

## Approach

Edit `audit/reference/decomposition-criteria.md` to add a new spec-level 'Redundancy Detection' section defining Ceremony and Coverage, computed as set-entailment over prior SCs only, and correct the maintainer note path defect. Edit `skills/audit/tasks/spec-audit-evaluator.md` to add the same section to the inline copy in lockstep with the master reference per the maintainer note, and create the full inline decomposition copy to match the master reference. Correct the 34 broken bare `reference/` links across the audit task cards to `.opencode/reference/`. The evaluator reads the spec independently and produces its own verdicts — adversarial separation, not a re-check of spec-creation validate.

## Impact

- Risk: interpretation-dependent verdicts if the intent prose universe is considered — mitigated by explicitly scoping both criteria to set-entailment over prior SCs only.
- Risk: divergence between master reference and inline copies — mitigated by the lockstep maintainer note and a structural SC asserting both copies stay in sync.
- Risk: false FAIL on non-redundant specs — mitigated by behavioral tests asserting PASS for distinct requirements with distinct verification methods.
- Risk: broken `reference/` links resolving to a nonexistent directory — mitigated by string-evidence SCs asserting the corrected `.opencode/reference/` paths are present and the bare patterns are absent.
- Dependency: Phase 1 PR must be merged (master reference file must exist). Parallel with Phase 2.
