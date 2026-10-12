<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->

# Plan: .opencode#2554 — Ainglish-informed writing discipline

Derives entirely from `.opencode/.issues/2554/spec.md`. One item per SC;
SC-1 (containment) is verified cumulatively at the end. Target repo: the
`.opencode` submodule. All file paths below are relative to the submodule root.

## Item 1 — Floor trigger line (SC-2)

- **Deliverable:** exactly one trigger line in `floor.md` directing consultation
  of the deck's writing discipline when authoring normative prose, pointing at
  `guidelines/ainglish-writing-discipline.md` by relative path. All other floor
  content byte-identical.
- **RED:** `grep -c "ainglish-writing-discipline" floor.md` → 0 (line absent).
- **GREEN:** insert the trigger line in the floor; touch nothing else.
- **Instrument:** read `floor.md` (directive + relative pointer present);
  `git diff` on `floor.md` shows the one-line change and no other modification.

## Item 2 — Discipline reference file (SC-3, SC-4, SC-5)

- **Deliverable:** new `guidelines/ainglish-writing-discipline.md` with
  provenance and license headers, stating: (a) the four ambiguity-rule families
  (actor binding; distributive vs collective; missing evidence vs unmade
  decision; claim confidence + falsifier) with worked examples mapped to the
  incident classes; (b) the losslessness boundary; (c) the anti-pedantry
  boundary (constructs optional, plain-English equally satisfying, no
  construct-counting); (d) the scope statement (all agent-authored prose,
  intensity following normativity); (e) the adoption rules (forwards-only,
  whole-card-on-touch, touch = substantive write, mechanical fixes exempt);
  (f) the read-time instruction to consult the live register when consuming
  marked prose, citing the live register and flagship catalogue by URL with
  use-time consultation.
- **RED:** file does not exist.
- **GREEN:** create the file. No register entry definitions copied; no root
  repo names; no absolute paths.
- **Instrument:** read the file — all six elements present (SC-3); live URLs
  present, no copied construct definitions (SC-4);
  `grep` for root repo name and absolute paths → zero hits;
  `./.opencode/tools/reference-integrity --scan` exits 0 (SC-5).

## Item 3 — Deck-debt ledger admission entry (SC-10 part 1)

- **Deliverable:** admission-gate entry on the deck-debt ledger
  (`.opencode#2534`, internal comment, matching the established entry format)
  carrying: observed-failure evidence, consumer, mechanism, predicate
  classification (intent-decidable, judgment-only), domain match, and
  what-it-replaces accounting.
- **RED:** no #2554 entry in the ledger.
- **GREEN:** post the entry via `local-issues comment`.
- **Instrument:** read the ledger comment; all six elements present.

## Item 4 — Behavioral fixture scripts (SC-6, SC-7, SC-8, SC-9 — artifact generation)

- **Deliverable:** four artifact-only generator scripts in
  `tests-v2/behaviors/` (cross-reference header, exit 0, no evaluation):
  - `2554-sc6-write-side-binding.sh` — fixture prompting the agent to author a
    normative statement carrying an actor-binding hazard (bare "we" that would
    misbind).
  - `2554-sc7-no-pedantry.sh` — fixture solvable in plain English with no
    ritual construct insertion.
  - `2554-sc8-mechanical-fix-no-convert.sh` — fixture: purely mechanical fix
    (typo/link rot) to a grandfathered card.
  - `2554-sc9-substantive-edit-converts.sh` — fixture: substantive edit to a
    grandfathered card.
- **RED runs:** SC-6 and SC-7 run once against the pre-change deck (the
  discipline does not exist yet) to evidence the baseline behavior. SC-8/SC-9
  have no meaningful pre-change RED — the adoption rules under test do not
  exist before the change; they are GREEN-only by construction.
- **Instrument:** scripts exit 0 with `session.yaml` artifacts (harness
  mandate; bash timeout ≥ 600 s).

## Item 5 — Clean-room evaluations (SC-6, SC-7, SC-8, SC-9 — evaluation)

- **Deliverable:** one clean-room sub-agent dispatch per artifact set,
  receiving ONLY the artifact path + the SC criterion: SC-6 confirms explicit
  actor binding (clarification halt counts only where the fixture genuinely
  underdetermines the actor); SC-7 confirms disambiguated plain English with
  no ritual construct insertion; SC-8 confirms the fix landed and the card's
  other content is unchanged; SC-9 confirms the whole card's normative prose
  comes back disciplined.
- **Depends on:** Item 4 artifacts.
- **Instrument:** clean-room eval verdicts recorded under the issue folder.

## Item 6 — Containment + governance closeout (SC-1, SC-10 part 2)

- **Deliverable:** `git diff --stat` for the change shows exactly
  `floor.md`, `guidelines/ainglish-writing-discipline.md`, and
  `tests-v2/behaviors/2554-sc*.sh` (+ the issue-store artifacts, which live on
  `issues-data`, not the change branch); provenance + license headers on both
  new/edited deck files; ledger entry complete.
- **Instrument:** `git diff --stat`; header read; ledger read.

## Dependency order

Item 1 → Item 2 → Item 3 → Item 4 (needs the changed deck present for GREEN
runs) → Item 5 → Item 6.

## Out-of-scope reminders (from spec)

No routing.md change; no per-card citations; no scripted ambiguity detection
or construct-counting anywhere; no register content snapshots; no retroactive
conversion of untouched cards.

---
*Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)*
