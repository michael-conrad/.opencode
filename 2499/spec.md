# [SPEC] Routing references in plans/specs track the live deck

**Repo**: michael-conrad/.opencode · **Remote**: .opencode#2499 (number authority) · **Discovered**: 2026-10-05

## Problem

Plans and specs embed routing metadata — task-card dispatch strings and
skill-path references into the deck (e.g. `.issues/2155/plan.md` hard-codes
`skills/implementation-pipeline/pipeline-state-machine.yaml`). Deck-change
operations have no access to repos outside the deck's own tree, so when the
deck is reorganized, every consuming repo's plans/specs go stale: dispatched
sub-agents hit dead paths, silently resolve from unauthoritative copies
(attic, `.issues`-sourced), or improvise inconsistently. Observed in the
snea-phonetics #116 execution (2026-10-05): plan-authored dispatch strings
for test-driven-development, verification-before-completion, and
spec-creation hit dead active-deck paths; recovery was per-dispatch
improvisation. The deck has no dispatch surface for this intent: no card
routes "stale routing references," so the defect recurs in every downstream
project that holds deck-referencing plans/specs across a deck reorganization.

## Requirement (from the ticket, verbatim in effect)

Routing references in plans and specs must track the deck copy available to
the repo that holds them. The consuming side owns keeping them current:
stale references are remediated — re-conformed to the live deck or its
preserved governing copies — before the work that depends on them continues;
remediation is never silent. Fail-loud is reserved for the case where
remediation is impossible (no live or preserved copy exists).

## Success criteria

| SC | Requirement | Instrument |
|----|-------------|------------|
| SC-1 | New card `.opencode/skills/reference-currency/SKILL.md`: frontmatter valid (name, description, license, provenance) and body states the obligation — routing references in plans/specs track the deck copy available to the holding repo; the consuming side owns currency; detection happens at authoring time (references conformed to the live deck when the plan/spec is written) and at use time (an embedded reference is existence-checked before the dispatch or load that relies on it); a dead reference is remediated — re-conformed to the live deck path or its preserved governing copy — before dependent work continues; the remediation is reported, never silent; fail-loud halt is reserved for the unremediable case (no live or preserved copy exists) | Read the card; skildeck lint 0 findings |
| SC-2 | Routing index carries the row so the intent dispatches: discovering stale/dead deck references in plans or specs, or dispatching on routing metadata that may be stale → `reference-currency` | Read routing.md; grep for the row |
| SC-3 | Card description is the router and deliberately pushy: "before authoring any plan or spec that references deck paths or task-card dispatch strings, and before dispatching on any embedded routing reference, in any repo" | Read the description |
| SC-4 | Root-agnostic: no repo names, no platform names in card or routing row | grep for owner/repo/platform strings |
| SC-5 | No regression: skildeck lint 0 findings; reference-integrity PASS on the touched files | Executed checks |

All SCs structural (fact-decidable) — content and dispatch-surface checks.
The behavioral core (remediation-before-continuation, never-silent,
fail-loud-only-unremediable) is enforced by the card's wording as judgment
guidance; its violation detection is fact-decidable (does the referenced
path exist in the holding repo's deck copy?) and surfaces at review and at
dispatch time.

## Governance admission (skill-creator gate)

1. **Observed failure**: snea-phonetics #116 execution, 2026-10-05 — dead
   dispatch paths after a deck reorganization, recovered by improvisation.
2. **Consumer**: agents authoring plans/specs and dispatching sub-agents on
   embedded routing references, in any downstream repo.
3. **Mechanism**: routing-index entry + card — documentation dispatch
   surface; detection is existence-checking, remediation is judgment.
4. **Predicate classification**: staleness is fact-decidable (path exists or
   not); the choice of remediation target (live deck vs preserved governing
   copy) and the never-silent reporting are intent-decidable — judgment
   decides, mechanisms verify facts only.
5. **Domain match**: n/a — from direct observation in this workspace's
   projects.
6. **Root-agnostic**: no names.
7. **What it replaces**: nothing — net-add justified: this intent routes
   nowhere today, with an observed cross-project failure the developer
   explicitly wants prevented.

## Approach

File remote (this issue, exists) → local spec (this file) → submodule
feature branch → card + routing edits → skildeck/reference-integrity → PR →
human merge.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
