<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, derived from .issues/2551/spec.md (developer-filed upstream-fix scope) -->

# Plan: .opencode#2551 — consumable-framework effort bound, fabricated-tests gate, narration bound

Deck-content change (developer-directed carve-out, skill-creator): the spec's
observed-failure evidence is carried by the issue itself; content standards
(frontmatter, predicate classification, root-agnostic discipline) still bind.
Verification instruments are fact-decidable content checks against the live
deck copy.

## Item 1 — Consumable-framework effort bound (SC: spec fix 1)

- Deliverable: a "Consumables" gate item in
  `skills/implement/SKILL.md` — consumed frameworks (bundled/provided by the
  build tool) get documented-API implementation at the declared version, one
  docs pass, resolved-version recording; deeper internals verification
  (bytecode disassembly, source-JAR extraction, internals tracing) requires
  per-occurrence developer instruction.
- RED: current card carries no effort bound — grep for "Consumables" /
  "consumed" in the card body finds no effort-bound rule (fails today).
- GREEN: add the gate item; amend the card's frontmatter description so the
  router catches "verifying a consumed dependency / framework internals".
- Verify: grep the live deck copy for the rule text and description update.

## Item 2 — Fabricated-tests gate with offender classes (SC: spec fix 2)

- Deliverable: the "Test value" item in `skills/implement/SKILL.md` extended
  with concrete offender classes (source-content inspection of the agent's own
  files; environment/framework re-read tautologies such as re-reading a pinned
  property; assertion-shaped placeholders), enforced at RED/GREEN time.
- RED: item 6 states the principle with no offender classes; grep for
  "source-content"/"tautology" finds nothing (fails today).
- GREEN: extend item 6; add a test-value gate row to the RED-GREEN chain table
  in `skills/implement/references/implementation-workflow.md` so the gate
  fires at the RED step, not only as a principle.
- Verify: grep both files for the offender classes and the RED-step gate row.

## Item 3 — Narration-to-deliverable bound (SC: spec fix 3)

- Deliverable: a new item in `skills/implement/SKILL.md` — when
  methodology-only turns (visible scaffolding producing zero deliverable code)
  exceed a small threshold within a work cycle, surface the ratio and halt for
  direction with an open-ended clarification request per the floor's standing
  formula (never a constrained-choice prompt).
- RED: no reciprocal gate on unbounded self-directed exploration exists in the
  card (fails today).
- GREEN: add the item with the open-ended halt formula cross-reference.
- Verify: grep the card for the narration-bound item and the open-ended halt
  language.

## Sequencing

Items 1–3 are independent content edits to the same card; run as one
RED/GREEN cycle per item, commit per item. Card-level only — the always-loaded
floor surface is not touched (skill-creator admission gate #8). Provenance
lines and frontmatter updated in the same commits.
