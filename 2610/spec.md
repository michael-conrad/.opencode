<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->

# Spec — Purge deck-debt ledger mechanism from the deck (.opencode#2610)

## Background and observed failures

The skill-creator governance card (admitted in the #2490 re-rip, stage 2d,
commit `41e3a7be`, 2026-10-04) carries a "Deck-debt ledger" section mandating
that usage observations, governance decisions, and retirement candidates be
"recorded in the deck-debt issue (synced issue store)". The definite article
presupposed a standing issue; none existed. On 2026-10-07 an agent session
treated the mandate as authorization and minted one — remote-first, in the
stakeholder-facing GitHub tracker (.opencode#2534, labeled `needs-approval`
+ `governance`).

Observed failures, in order:

1. **Unrequested standing artifact (2026-10-07).** .opencode#2534 was
   agent-created, not developer-requested. A ledger is a tracking tool, not
   tracked work; it was never eligible to be an issue in a store whose purpose
   is tracking work with a lifecycle (specs, plans, research, audits).
2. **Stakeholder-facing confusion (2026-10-14, developer statement).** The
   issue body mirrored to the public tracker as an "exec summary" of work
   that is not work; the `needs-approval` label signaled "blocking on the
   developer" while nothing was; the artifact is open-forever by design and
   can never satisfy the closure rule ("closure follows delivered work").
3. **Continued advocacy after developer pushback (2026-10-14, this session).**
   After the developer's initial objection, the agent re-proposed the ledger
   mechanism (re-homing) rather than treating the mechanism itself as the
   defect — the mandate in deck text kept surfacing as agent behavior.
4. **Misfiled classification corrected at closure (2026-10-14).**
   .opencode#2534 closed (not planned) at explicit developer direction. Its
   closure left the card's ledger section pointing at a closed issue — the
   mandate now dangles and would regenerate the artifact on the next
   literal-minded reading.

## Developer statements (requirement source)

- "I didn't ask for .opencode#2534" (2026-10-14).
- "it is not a spec and is confusing stakeholders" (2026-10-14).
- "you have .issues/ for stuff you want to track, I did not ask for this
  tracking" (2026-10-14).
- "a ledger is something to track with. it does NOT belong in the issues
  system" (2026-10-14).
- "I did not ask for this. Stop pushing it. File a spec to purge it."
  (2026-10-14).

The requirement is a **purge**, not a re-homing: no replacement ledger and no
successor tracking mechanism is created anywhere in the deck.

## Scope

**In scope (active deck instruction surfaces):**

- `floor.md` — the deck-governance line enumerates
  "admission gate, retirement gate, deck-debt ledger, vendor-card boundary".
- `skills/skill-creator/SKILL.md` — frontmatter `description` ("Enforces the
  admission gate, retirement gate, deck-debt ledger, predicate
  classification, and vendor-card boundary"); the "Deck-debt ledger" section;
  the retirement-gate section's evidence sentence ("verdicts use deep history
  or the cross-deployment ledger").

**Out of scope:**

- `attic/` — preserved retired deck content (tag `pre-rip`); its ledger
  mention (`attic/skills/writing-plans/tasks/create.md`) is unloaded history.
- Closed issue .opencode#2534 and all `issues-data` branch history —
  preserved evidence; no deletion, no content edits.
- Any replacement ledger, successor tracking mechanism, or re-homed ledger
  file — explicitly not created.
- The admission gate, retirement gate, and vendor-card boundary substance —
  untouched except for the ledger citation fix inside the retirement-gate
  sentence.

## Success criteria

### SC-1 — floor.md ledger reference removed (structural)

The deck-governance line in `floor.md` no longer names the deck-debt ledger;
the line continues to name the admission gate, the retirement gate, and the
vendor-card boundary, and the surrounding paragraph (governance routing,
evidence statement) is otherwise unchanged.

**Verification instrument:** `rg -n "ledger" .opencode/floor.md` returns zero
matches; a read of the amended line confirms the three surviving enumerated
items.

### SC-2 — skill-creator ledger mandate removed (structural)

`skills/skill-creator/SKILL.md` carries no ledger mandate:

- the frontmatter `description` no longer contains "deck-debt ledger";
- the "## Deck-debt ledger" section is absent;
- the retirement-gate section no longer cites "the cross-deployment ledger"
  as an evidence source — retirement verdicts rest on deep history (git
  history) alone; the sentence's remaining claim ("absence in a live database
  is NOT evidence", "resurrection via git history is cheap") is preserved.

**Verification instrument:** `rg -n "ledger" .opencode/skills/skill-creator/SKILL.md`
returns zero matches; a read confirms the retirement-gate section retains its
governing substance.

### SC-3 — zero ledger references in the active deck (structural)

The active deck — `floor.md`, `routing.md`, `skills/**`, `guidelines/**` —
contains zero occurrences of "ledger" or "deck-debt".

**Verification instrument:** `rg -in "ledger" .opencode/floor.md
.opencode/routing.md .opencode/skills .opencode/guidelines` returns zero
matches.

### SC-4 — no agent re-creates or pushes a ledger artifact (behavioral)

After the purge, a clean-room agent session dispatched to perform a routine
deck edit performs no ledger actions: it creates no ledger issue, records no
ledger entry anywhere, and cites no ledger mandate — because no instruction
surface mandates one.

**Verification instrument:** one clean-room behavioral evaluation per the
tests-v2 harness: dispatch a deck-edit task; inspect session evidence for
absence of ledger-minting or ledger-entry actions. Regression-guard role: the
ledger's founding defect was an agent minting the artifact from a standing
mandate; the run verifies the mandate's removal changes that behavior.

## Traceability

| SC | Developer statement / observed failure |
|----|----------------------------------------|
| SC-1 | "purge it" + "I did not ask for this" — the floor line is the always-injected surface carrying the mandate; observed failure 1 |
| SC-2 | "purge it" + "stop pushing it" — the card is the mandate's origin; observed failures 1, 3, 4 |
| SC-3 | "purge it" — completeness of the removal; observed failure 4 (dangling mandate regenerates the artifact) |
| SC-4 | "stop pushing it" + "it does NOT belong in the issues system" — the runtime effect the purge exists to produce; observed failures 1, 3 |

## Non-goals

- No new tracking mechanism of any kind replaces the ledger.
- No edits to the retirement gate's substantive bar (deep-history evidence
  standard survives; only the ledger citation is removed).
- No edits to `attic/`, closed issues, or `issues-data` history.
- No edits to the issues card or any other card's closure/mirroring mechanics.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
