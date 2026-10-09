# [SPEC] CI repo-boundary standard: checkout is consumption, CI execution is responsibility

**Repo**: michael-conrad/.opencode · **Remote**: .opencode#2496 (number authority) · **Discovered**: 2026-10-05

## Problem

Observed in a downstream project (snea-phonetics): an agent designed CI crossing repo boundaries into submodules and treated submodule checkout itself as a cross-repo CI issue. Developer correction (2026-10-05): submodules are mandatory for checkout — not a cross-repo CI issue; they must be checked out for root repo CI, but submodule CI is each submodule's responsibility. The deck has no dispatch surface for CI intent: no card's description routes CI design, so the defect recurs in every downstream project that grows CI.

## Success criteria

| SC | Requirement | Instrument |
|----|-------------|------------|
| SC-1 | New card `.opencode/skills/ci-boundary/SKILL.md`: frontmatter valid (name, description, license, provenance) and body states the boundary — checkout is consumption (mandatory, pinned, boundary-clean); CI execution is responsibility (a repo's CI runs its own verification machinery and no other repo's); submodule CI is the submodule's own runner/triggers/gates; parent may read the outcome, never run it; failure isolation (submodule red never blocks parent runs except via pointer non-advance); the one-pipeline-one-checkmark anti-pattern named | Read the card; skildeck lint 0 findings |
| SC-2 | Routing index carries the row so CI intent dispatches: creating/modifying CI — pipelines, runners, workflows, submodule checkout configuration → `ci-boundary` | Read routing.md; grep for the row |
| SC-3 | Card description is the router at both abstraction levels and deliberately pushy: "before creating or modifying CI for ANY repository — pipelines, runners, workflows — or configuring submodule checkout, in any repo, with or without submodules" | Read the description |
| SC-4 | Root-agnostic: no repo names, no platform names in card or routing row | grep for owner/repo/platform strings |
| SC-5 | No regression: skildeck lint 0 findings; reference-integrity PASS on the touched files | Executed checks |

All SCs structural (fact-decidable) — content and dispatch-surface checks.

## Governance admission (skill-creator gate)

1. **Observed failure**: the snea-phonetics instance; developer correction 2026-10-05.
2. **Consumer**: agents creating or modifying CI in any downstream repo.
3. **Mechanism**: routing-index entry + card — documentation dispatch surface.
4. **Predicate classification**: the boundary's violations are fact-decidable (does the CI config execute another repo's test framework? grep-able at review); compliance is judgment + review backstop.
5. **Domain match**: n/a — from direct observation in this workspace's projects.
6. **Root-agnostic**: no names.
7. **What it replaces**: nothing — net-add justified: CI intent routes nowhere today, with an observed cross-project failure the developer explicitly wants prevented in other downstream projects.

## Approach

File remote (this issue) → local spec → submodule feature branch → card + routing edits → skildeck/reference-integrity → PR → human merge.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
