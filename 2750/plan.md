<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->

# Plan — release-promoter: release-candidate composition promotes submodule pointers to remote trunk tips before the release PR

**Issue:** michael-conrad/.opencode#2750

## Goal

Implement the validated spec's five card-text changes and its tier-2
behavioral evidence: a release-candidate composition phase on
`release-promoter`'s three surfaces (SKILL.md description, SKILL.md rule
inventory, operating protocol) that promotes every registered submodule
pointer to its remote trunk tip before the release branch records them, the
fixed compose → record → clean-room gate → release PR ordering with the
un-promoted-pointer prohibition, the real-content/tagged-SHA statement, the
release carve-out in `git-workflow-branch` rule 2(c), the composed
parent/submodule source of truth in `changelog-generator` rule 1, and a
tests-v2 tier-2 behavioral scenario (SCENARIO_TIER=2, BEHAVIOR_NEEDS_REMOTE=1)
witnessing an agent proceeding through the composition on a parent-trunk /
submodule-drift fixture instead of halting with nothing-to-release.

## Execution surface

Repository: michael-conrad/.opencode (the deck repo). Branch:
`feature/2750-release-candidate-composition` off trunk `main` at the
verified tip `7e50437bb0ebe795308f8033d8f4a29c1d8ad3cc` (trunk freshness
executed 2026-11-18: fetch done, HEAD == origin/main, no registered
submodules inside the deck repo, working tree clean). Files touched:
`skills/release-promoter/SKILL.md`,
`skills/release-promoter/references/operating-protocol.md`,
`skills/git-workflow-branch/SKILL.md`, `skills/changelog-generator/SKILL.md`,
and one new tests-v2 scenario directory. The spec lives in the deck repo's
own `.opencode/.issues/2750/` (issues-data worktree).

## Items

Each item is atomic — one concern, independently verifiable, committable,
revertable — daisy-chained: item N's commit is item N+1's RED precondition.

### Item 1 — composition phase across the three `release-promoter` surfaces

- **Deliverable:** the release-candidate composition phase, ordered before
  Phase A entry criteria, on all three surfaces. In `SKILL.md`: the
  description gains a composition clause ("before any release analysis or
  branching, pull the parent trunk to its remote tip and sync every
  registered submodule pointer to that submodule's remote trunk tip"), and a
  new rule heading is inserted before the current rule 0 carrying the phase:
  parent trunk pulled to its remote tip; per registered submodule per
  `.gitmodules`, run `git-workflow-branch` rule 2's executed per-submodule
  remote-tip comparison (per-path, non-recursive — fetch, resolve tracked
  branch via `.gitmodules` branch field else current symbolic HEAD else
  `origin/HEAD`, guard ref existence, compare checkout SHA to remote-tracking
  tip, record at-tip / behind / no-remote-tip) and sync a behind checkout to
  the resolved remote tip.
- **RED:** grep for "composition" over
  `skills/release-promoter/SKILL.md` and
  `skills/release-promoter/references/operating-protocol.md` returns nothing,
  and the operating protocol's first phase is Phase A with entry criteria
  that presuppose a pushed release branch already recording pointers — no
  instruction promotes pointers to remote trunk tips before Phase A.
- **GREEN:** in `references/operating-protocol.md` a new first phase ("Phase
  C-0 — release-candidate composition", ordered before Phase A) carries the
  same phase text with the comparison procedure spelled out, the
  `no-remote-tip` handling (sync when a branch resolves, else record), and —
  per the spec's edge-case row 1 — the unreachable-remote outcome stated as
  a halt for developer direction, not a skip (this halt is the composition
  phase's own prescription, deliberately diverging from rule 2's
  record-and-continue posture: a release candidate cannot be composed from
  unverifiable pointers). No `--remote`, no `--recursive` anywhere.
- **Tier marks:** authors no test; instrument class is card-text fact check.
- **Instrument:** grep "composition" on both files returns hits; read of the
  three surfaces confirms the phase present with promotion mechanics and the
  rule-2 instrument reference; a grep for `--remote` and `--recursive` in the
  new text confirms absence (the protocol's existing forbidden-flags sentence
  excepted). Fails if any surface lacks the phase or names the recorded
  pointer where the remote tip is required.

### Item 2 — fixed order and the un-promoted-pointer prohibition

- **Deliverable:** the composition phase text (item 1's new rule in SKILL.md
  and Phase C-0 in the protocol) states the fixed order — compose (promote
  pointers at trunk tips), record the release branch, run the clean-room gate
  on the composed tree, file the release PR — and states that a release PR is
  never filed from pointers that were not promoted at composition time.
- **RED:** grep "never filed" over the two `release-promoter` files returns
  nothing; the protocol nowhere states the compose-before-gate-before-PR
  ordering (Phase A entry criteria gate on branch push only).
- **GREEN:** add the ordering statement and the prohibition sentence to the
  phase text on both surfaces; Phase A's entry-criteria list gains the
  composition precondition ("the composition phase has run — pointers
  promoted at trunk tips").
- **Tier marks:** authors no test; instrument class is card-text fact check.
- **Instrument:** grep both files for the ordering statement and the
  prohibition sentence; verify the four-stage order appears verbatim in the
  phase text.

### Item 3 — real-content and tagged-SHA statement

- **Deliverable:** the composition phase text states that promoted pointer
  bumps are the release's real content and are recorded in the release branch
  as pointer-capture commits under `git-workflow-branch` rule 3's tagged-SHA
  pointer discipline (the release exemption `git-workflow-pr` §2(e) already
  states).
- **RED:** the `release-promoter` files do not state that promoted bumps are
  the release's real content and refer to no pointer-capture commit recording.
- **GREEN:** add the real-content sentence with the rule 3 reference (canonical
  `Read [Text](path)` load form pointing at
  `../git-workflow-branch/SKILL.md`) to the phase text on both surfaces.
- **Tier marks:** authors no test; instrument class is card-text fact check.
- **Instrument:** grep the phase text for "real content" and for the rule 3 /
  tagged-SHA reference; verify the reference-integrity check
  (`./.opencode/tools/reference-integrity`) accepts any new load-form link.

### Item 4 — `git-workflow-branch` rule 2(c) release carve-out

- **Deliverable:** a release carve-out sentence in rule 2(c): the
  pointer-only deferral ("the drift rides with the next real parent change")
  does not apply while the session is preparing a release — release
  preparation is itself the real parent change that carries the drift.
- **RED:** rule 2(c) states the deferral unconditionally and names no release
  exception.
- **GREEN:** append the carve-out sentence to rule 2(c) in
  `skills/git-workflow-branch/SKILL.md`, minimal — the deferral itself stays
  intact for non-release drift.
- **Tier marks:** authors no test; instrument class is card-text fact check.
- **Instrument:** read rule 2(c) and verify the carve-out names release
  preparation as the carrying change; prose diff of the rule shows the
  deferral still present for the non-release case.

### Item 5 — `changelog-generator` composed source of truth

- **Deliverable:** rule 1 composes, for a parent/submodule repository family,
  the parent repository's commit range since the last release tag with each
  submodule's commit range between the recorded pointer and the promoted
  trunk tip.
- **RED:** rule 1's source of truth names only
  `git log <last-tag>..HEAD --oneline` — the parent range; submodule ranges
  appear nowhere in `skills/changelog-generator/SKILL.md`.
- **GREEN:** extend rule 1 with the composed-family sentence (keeping the
  parent range as the primary source; the no-fabrication rule 4 governs the
  submodule entries identically). Rule 6's existing pointer-capture wording
  is left as-is.
- **Tier marks:** authors no test; instrument class is card-text fact check.
- **Instrument:** read rule 1 and verify both ranges are named with the
  recorded-pointer → promoted-tip endpoints.

### Item 6 — tier-2 behavioral scenario (SC-6)

- **Deliverable:** a new tests-v2 behavioral scenario (own directory under
  `tests-v2/behaviors/`), seeded fixture: a parent repo with one registered
  submodule whose remote trunk tip is ahead of the parent's recorded pointer,
  parent trunk with zero commits since the last release tag, and a prior
  release tag present. SCENARIO_TIER=2, BEHAVIOR_NEEDS_REMOTE=1 (the
  self-contained GitBucket container per `tests-v2/AGENTS.md` §12). The
  scenario prompt asks an agent to create a release PR in the consumer repo;
  asserting the session executes the per-submodule remote-tip comparison,
  promotes the pointer, composes the release branch carrying the bump, and
  proceeds into clean-room-gate behavior — no nothing-to-release halt.
- **RED:** the scenario does not exist; grep over `tests-v2/behaviors/` for
  the scenario name returns nothing. (The behavioral regression itself was
  witnessed in the field per the spec's root-cause narrative — this item
  authors the regression evidence instrument; a RED run against the
  pre-fix deck is not re-runnable in this cycle text-judgmentally, which the
  spec's tier-2 instrument accepts as the evidence class.)
- **GREEN:** author scenario.yaml + fixture scripts per the existing
  tier-2 scenario layout (structure and dispatch mechanics follow
  `tests-v2/AGENTS.md` §12 and an existing scenario's script as reference;
  the clean-room evaluator dispatch reads the session against SC-6's
  outcome).
- **Tier marks:** the scenario file carries its tier at creation:
  tier-2 behavioral, SCENARIO_TIER=2, BEHAVIOR_NEEDS_REMOTE=1 — a
  pr-validation-class artifact in test-discipline vocabulary: it proves this
  PR fixes this ticket, runs at PR-check time only, and is dispositioned at
  merge; it never enters a default run.
- **Instrument:** execution through the behavioral-testing card §5 harness run
  (GitBucket container) plus the standard clean-room evaluator dispatch
  reading session.yaml against SC-6; the run's executed output is the
  evidence artifact of record for the cycle. Amended run-1 finding (2026-11-19,
  clean-room FAIL: comparison executed and pointer fast-forwarded, but the
  run's legitimate turns exhausted the harness default 4000-token output
  budget — degenerate-reasoning blocks of 36–39K chars, two continuations
  insufficient, terminal output-limit exit): the scenario runs with a
  scenario-scoped raise of `OPENCODE_EXPERIMENTAL_OUTPUT_TOKEN_MAX`
  (spec-amended instrument, tests-v2 §5/§10.7 sanctioned re-scope), value
  recorded in the run's evidence.

## Dependency order

1 → 2 → 3 (items 2 and 3 amend item 1's composition-phase text, so the phase
exists first; the order statement and the real-content statement are
independent concerns but share the same text block, hence the chain);
item 4 is independent of items 1–3 in content but commits after item 3 so
rule 2(c)'s carve-out follows the phase that references rule 2's instrument;
item 5 is independent card text, sequenced last of the text items so the
four-text change lands as a reviewable sequence; item 6 depends on items 1–5
all green — the scenario exercises the revised deck, so it runs against the
completed text set. No cycles.

## Traceability

| Item | SC(s) |
|------|-------|
| 1 | SC-1 |
| 2 | SC-2 |
| 3 | SC-3 |
| 4 | SC-4 |
| 5 | SC-5 |
| 6 | SC-6 |

Every SC covered; every item traces.

## Verification summary

- **Fact checks** (run at each item's cycle time, grep/read over the touched
  card files): items 1–5. No authored test outside item 6.
- **Behavioral evidence:** item 6's tier-2 tests-v2 scenario, run once at
  cycle time through the behavioral-testing harness (SCENARIO_TIER=2,
  BEHAVIOR_NEEDS_REMOTE=1, GitBucket container) + clean-room evaluator
  dispatch; pr-validation run placement — at PR-check, never a default run.
- **PR-check-time runs:** item 6's harness run re-dispatched if the deck text
  moves after the run (else the recorded run stands); the reference-integrity
  check across the touched card files.
- Completion gate: all six SCs pass before the deliverable is complete
  (spec §10) — a partial surface set is not a complete deliverable; partial
  implementation is not permitted.

## Status boundary

No STATUS fields or progress markers in this plan; implementation state lives
in the pipeline and the issue's validation record.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
