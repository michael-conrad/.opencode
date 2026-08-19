---
remote_issue: 2117
remote_url: "https://github.com/michael-conrad/.opencode/issues/2117"
last_sync: "2026-08-19T14:37:47Z"
source: github
---

> **Full spec and plan artifacts:** [`.opencode/.issues/2117/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2117) — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2117/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem

The audit skill's spec-audit evaluator does not independently verify SC decomposition quality. Specs with monolithic SCs pass audit and advance to plan creation, where defects are more expensive to fix. The decomposition criteria set also lacks checks for redundant or ceremonial SCs — SCs that add no verification signal over prior SCs, or whose requirements are already entailed by an earlier SC.

## Scope

- Add a new spec-level 'Redundancy Detection' section to the decomposition criteria set, applied in the same pass as the existing four criteria (atomicity, single deliverable, binary verifiability, PR-gate viability).
- Define two new defect classes: Ceremony (an SC that adds zero verification signal over the union of prior SCs) and Coverage / covered-by-prior (an SC whose requirement set is already entailed by a prior SC).
- Both are computed as set-entailment over prior SCs only, applied in both the master reference and the spec-audit evaluator's inline copy in lockstep.
- Add structural evidence-type SCs and behavioral enforcement tests for each defect class.

**Out of scope:** The Problem Statement / intent prose universe is explicitly OUT OF SCOPE for the new criteria (the master reference's Binary Verifiability criterion forbids interpretation-dependent verdicts). The new section is spec-level only and independent of the plan-level criteria.

## Approach

Edit `audit/reference/decomposition-criteria.md` to add a new spec-level 'Redundancy Detection' section defining Ceremony and Coverage, computed as set-entailment over prior SCs only. Edit `audit/tasks/spec-audit-evaluator.md` to add the same section to the inline copy in lockstep with the master reference per the maintainer note. The evaluator reads the spec independently and produces its own verdicts — adversarial separation, not a re-check of spec-creation validate.

## Impact

- Risk: interpretation-dependent verdicts if the intent prose universe is considered — mitigated by explicitly scoping both criteria to set-entailment over prior SCs only.
- Risk: divergence between master reference and inline copies — mitigated by the lockstep maintainer note and a structural SC asserting both copies stay in sync.
- Risk: false FAIL on non-redundant specs — mitigated by behavioral tests asserting PASS for distinct requirements with distinct verification methods.
- Dependency: Phase 1 PR must be merged (master reference file must exist). Parallel with Phase 2.
