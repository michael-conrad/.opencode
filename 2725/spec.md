# Align existing test-tier directives with the test-discipline card (implement, implementation-workflow, systematic-debugging, plan)

Source: developer direction (2026-11-06, filed this spec's session) — "there is already some directives for tests that will need to be rewritten as a part of this"; the SC-matching tests must carry tier markings from SPEC/PLAN creation onward (parent direction). Evidence basis: parent spec [`.opencode#2724`](../2724/spec.md) and its research artifact; directive texts verified by direct read this session (quotations below are verbatim).

## Problem

Existing deck test-tier directives predate the test-discipline vocabulary and contradict its classification discipline — each defect below is a direct read of trunk (2026-11-06):

1. `implement/SKILL.md` L32–35: "Test tiers: smoke + regression are the default for every cycle and PR — never the full suite (tier definitions in the implementation-workflow reference). Full-suite runs are for release boundaries or explicit developer request." No `pr-validation` or `ephemeral` class exists, so PR-only validation tests take the `regression` slot by default — they run in the red/green cycles AND at PR time AND beyond — which is precisely the researched accumulation failure (heavy PR-scoped tests surviving into every default build). Note the existing release-boundary rule for the FULL suite is correct and is preserved; what's missing is the on-demand classification for heavy tiers short of the full suite.
2. `implement/references/implementation-workflow.md` tier table: `smoke` / `regression` rows only ("smoke | fastest end-to-end signals…", "regression | tests covering the changed area and its direct dependents"), no `heavy-regression` (on-demand) row and no mark-at-creation step in the RED → GREEN → Verify chain (lines 15–76 read this session).
3. `systematic-debugging/SKILL.md` #5: "Add the failing case as a behavioral test; verify the [fix…]" — no tier or disposition requirement.
4. `plan/SKILL.md`: per-SC RED/GREEN items are defined without test-tier classification, so SC-matching tests are unclassified at the moment plans authorize authoring them — the developer's stated hook ("description indicates it should be referenced when creating SPECs and PLANs so that the SC matching tests can be properly marked") only fully binds if the plan-authoring stage has somewhere to put the marking; plans are the execution artifacts that name the tests.

## Scope

Rewrite of four directive surfaces to align with the test-discipline card (`.opencode/skills/test-discipline/`, filed by sibling `.opencode#2724`): `implement/SKILL.md` test-tier line, `implement/references/implementation-workflow.md` tier table and cycle chain, `systematic-debugging/SKILL.md` #5, `plan/SKILL.md` per-SC item guidance. No changes to the discipline card itself (sibling's scope); no changes to the spec card's validation-standards criteria set (excluded — deck-governance territory, and spec-stage marking is carried by the discipline card's description trigger, not a spec-card format change).

## Requirements

- R-1 (structural): `implement/SKILL.md` test-tier line and the `implementation-workflow.md` tier table SHALL use the five-class vocabulary (`ephemeral` / `pr-validation` / `smoke` / `regression` / `heavy-regression`); the tier table SHALL gain `pr-validation` (PR-check only) and `heavy-regression` (on-demand/scheduled only, never in the default run) rows stating their run placements; the smoke and regression rows' semantics (always-run light gate; changed-area default gate) SHALL match the discipline card; the existing full-suite release-boundary rule SHALL be preserved.
- R-2 (structural): the `implementation-workflow.md` RED → GREEN → Verify chain SHALL include the mark step at test creation — every test created in the cycle states its tier.
- R-3 (structural): `systematic-debugging/SKILL.md` #5 SHALL require the failing case's behavioral test to carry its tier and disposition (regression by default; `pr-validation` when the work scope is the ticket's PR).
- R-4 (structural): `plan/SKILL.md` SHALL require each RED/GREEN item that authors tests to state its test tier(s) per the vocabulary, citing the test-discipline card.
- R-5 (structural): the rewritten surfaces SHALL cite the discipline card by relative link and SHALL NOT duplicate its vocabulary definitions (single-sourcing: the card owns the definitions; surfaces own their run-specific rows).
- R-6 (behavioral): in a dispatched implementation-cycle probe under the rewritten `implement` card, the agent SHALL classify created tests per the vocabulary and SHALL route heavy-tier tests to on-demand, not the default run.

## Success criteria

| ID | Criterion | Class | Instrument |
|----|-----------|-------|------------|
| SC-1 | implement SKILL test-tier line and implementation-workflow tier table use the five classes; table gains pr-validation and heavy-regression rows with run placements | structural | read both files (fact-decidable content check) |
| SC-2 | RED → GREEN → Verify chain includes the mark-at-creation step | structural | read implementation-workflow.md |
| SC-3 | systematic-debugging #5 states the tier + disposition requirement | structural | read systematic-debugging/SKILL.md |
| SC-4 | plan card RED/GREEN guidance requires per-item tier statement, citing the discipline card | structural | read plan/SKILL.md |
| SC-5 | rewritten surfaces cite the card; class definitions not duplicated outside it | structural | read all four files |
| SC-6 | probe agent's cycle work classifies tests per vocabulary; heavy-tier items routed on-demand | behavioral | dispatched behavioral probe |

## Out of scope

- The test-discipline card's content (sibling `.opencode#2724`).
- The spec card's validation-standards criteria set; spec-stage format changes (spec-stage behavior is carried by the discipline card's description trigger).
- CI workflows, hooks, mechanical run-placement enforcement — the card classifies, workflows cite it, no script decides.
- Language cards (java, gradle, python) and their unit-test/DI guidance.

## Approach

Direct rewrite of each surface's owned section: (1) implement test-tier line gains the two new classes beside the existing release-boundary rule; (2) implementation-workflow tier table gains two rows and the cycle chain gains the mark step; (3) systematic-debugging #5 gains the tier/disposition clause; (4) plan per-SC item guidance gains the tier statement requirement. Each surface links the discipline card by relative pointer (`.opencode/skills/test-discipline/SKILL.md` — note submodule-relative link shape per deck practice). Implementation routes through the deck governance card (these are `skills/` edits) and the .opencode repo's PR process; order after the sibling card exists.

## Impact

- Consumers: implement sessions (cycle gains one marking step), plan authoring (per-SC items carry tiers), systematic-debugging users (#5 gains classification), deck governance (admission of the edits), and the discipline card's reference demand (these surfaces create it).
- Risk: low — text-only deck edits; the default gate's present behavior (smoke + changed-area regression, full suite at release boundaries only) is preserved and now paired with explicit on-demand heavy and PR-only classes.
- Blast radius: the four files enumerate every deck surface quoting the old two-tier line (grep-verified this session: no other card carries a competing tier taxonomy — `zola` smoke checks and validation-standards regression language are non-taxonomy uses and stay untouched).
