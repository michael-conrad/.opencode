<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->

# Plan — Purge deck-debt ledger mechanism (.opencode#2610)

Execution context: all items operate in the `.opencode` submodule repo on
branch `feature/2610-purge-deck-ledger` (created per `git-workflow-branch`
before the first file modification; trunk-based — no direct commits to
`main`). Items 1 and 2 are independent; item 3 follows both; item 4 follows
item 3 (its post-purge run requires the purged tree).

## Item 1 — floor.md ledger reference (SC-1)

- **Deliverable:** the deck-governance line in `floor.md` enumerates only the
  admission gate, the retirement gate, and the vendor-card boundary; the
  paragraph's governance-routing and evidence sentences are otherwise
  unchanged.
- **RED:** `rg -n "ledger" .opencode/floor.md` returns a match (line ~107,
  "deck-debt ledger" inside the enumeration) — the assertion "zero matches"
  fails against the current tree.
- **GREEN:** edit the line to drop "deck-debt ledger" from the enumeration,
  leaving the sentence grammatical with the three surviving items.
- **Instrument:** `rg -in "ledger" .opencode/floor.md` returns zero matches;
  a read of the amended line confirms the three surviving enumerated items and
  the intact surrounding paragraph.

## Item 2 — skill-creator ledger mandate (SC-2)

- **Deliverable:** `skills/skill-creator/SKILL.md` carries no ledger mandate:
  (a) frontmatter `description` lists "admission gate, retirement gate,
  predicate classification, and vendor-card boundary" — ledger removed;
  (b) the "## Deck-debt ledger" section is deleted entirely; (c) the
  retirement-gate sentence reads that verdicts use deep history (git history)
  — the "or the cross-deployment ledger" clause removed — while preserving
  "absence in a live database is NOT evidence" and "resurrection via git
  history is cheap".
- **RED:** `rg -in "ledger|deck-debt" .opencode/skills/skill-creator/SKILL.md`
  returns four matches (frontmatter line 3; retirement-gate sentence lines
  68–69; "## Deck-debt ledger" heading and body lines 72–75) — the zero-match
  assertion fails now.
- **GREEN:** three edits — description trim, section deletion, retirement-gate
  sentence revision.
- **Instrument:** `rg -in "ledger|deck-debt" .opencode/skills/skill-creator/SKILL.md`
  returns zero matches; a read confirms the retirement-gate section retains
  the deep-history bar and both preserved claims verbatim.

## Item 3 — active-deck sweep (SC-3)

- **Deliverable:** zero occurrences of `ledger` or `deck-debt` (case-
  insensitive) across `floor.md`, `routing.md`, `skills/**`, `guidelines/**`.
- **RED:** after items 1–2 land, run
  `rg -in "ledger|deck-debt" .opencode/floor.md .opencode/routing.md .opencode/skills .opencode/guidelines`.
  A non-empty result means strays exist outside the two targeted files — the
  assertion "zero matches" fails and this item remediates each stray (same
  purge discipline; strays beyond the spec's named surfaces are reported and
  the spec revised before extending scope — never silently swept). An empty
  result at this point means items 1–2 covered all references and the sweep
  confirms completeness.
- **GREEN:** zero matches stand; any discovered stray is removed under this
  item with its own re-run.
- **Instrument:** the sweep command itself, re-run to zero after any
  remediation.

## Item 4 — clean-room behavioral evaluation (SC-4)

- **Deliverable:** two clean-room behavioral runs, per the `behavioral-testing`
  card and the tests-v2 harness (harness mechanics — provisioning, scenario
  authoring, session-evidence extraction — resolve at implementation per that
  card):
  - **Run A (pre-purge, base checkout):** a deck-edit dispatch whose loaded
    instruction surface includes `skills/skill-creator/SKILL.md`. Expected
    evidence: the ledger mandate reaches the agent's context (the loaded card
    text carries the "Deck-debt ledger" section). This run supplies the
    failing-side observation — the surface the purge removes, demonstrated at
    runtime.
  - **Run B (post-purge, purge branch):** the identical dispatch. Expected
    evidence: the loaded card carries no ledger mandate and the session
    performs no ledger actions — no ledger issue created, no ledger entry
    recorded, no ledger mandate cited.
- **RED:** Run A's recorded evidence shows the mandate present in the agent's
  loaded instruction surface on the base tree — the behavioral precondition
  the purge eliminates; without Run A, Run B's clean verdict has no
  demonstrated contrast.
- **GREEN:** Run B evaluated SATISFIED — zero ledger actions in session
  evidence, mandate absent from the loaded surface.
- **Instrument:** the tests-v2 harness's clean-room evaluation of session
  evidence for both runs (runtime instrument — file reads cannot verify
  behavior). Verdict recorded per the harness's evaluation format.

## Dependency order

Item 1 → (independent) Item 2 → Item 3 (needs 1+2) → Item 4 Run A (base
tree) may execute before or after Items 1–3 (it checks out base
independently); Item 4 Run B strictly after Item 3. No cycles.

## Traceability

| Item | SC |
|------|----|
| 1 | SC-1 |
| 2 | SC-2 |
| 3 | SC-3 |
| 4 | SC-4 |

Every spec SC covered; every item traces to exactly one SC. Surface coverage
matches the spec's affected set (`floor.md`, `skills/skill-creator/SKILL.md`)
— no undeclared blast radius.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
