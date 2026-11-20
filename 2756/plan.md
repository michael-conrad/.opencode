# Plan — .opencode#2756: store search for a matching existing spec before filing a new spec

## 1. Goal

This plan delivers a deck text change for michael-conrad/.opencode#2756: a search-before-filing mandate that requires the agent to search the issue store (local store and linked remote tracker) for a spec already covering the same requirement or behavior class before any new spec is filed, routing into an existing match in place of a new filing. The change touches exactly two files — `skills/spec/SKILL.md` (filing flow, rule 5) and `skills/issues/SKILL.md` (§5 work-entry conversion clause) — plus one behavioral run exercising SC-6.

## 2. Execution surface

- Repository: michael-conrad/.opencode (the deck submodule checkout at `.opencode/`; PR lands in that repository — deck changes author upstream through the deck's own PR process).
- Branch: `2756-store-search-before-filing`, based on the verified trunk tip `489c21ef8` (submodule `origin/main`; executed fetch-and-compare — the branch was initially cut from the stale local `main` at `e237255c0` and rebased onto `489c21ef8` after a validation finding; suite re-verified green post-rebase).
- Environment fact: the issue store worktree `.opencode/.issues/` is a separate worktree on branch `issues-data` — artifacts for this issue are committed there via `local-issues sync`, never inside the deck branch; the deck PR carries only the two card files.

## 3. Items

### Item 1 — Search-before-filing mandate in the `spec` card

- **Deliverable** — a mandate paragraph appended to `skills/spec/SKILL.md` rule 5 (the filing flow), reading (in substance): the mandate binds every new-spec filing path — this flow, a triage conversion, or any other path; before filing any new spec, the agent searches the repository's issue store specs and the repository's linked remote tracker for a spec already covering the same requirement or behavior class, matching on the requirement or behavior class rather than the filing's wording; when a match exists, the requirement routes into that existing spec — amended or extended in place under rule 6's revision discipline, or under the `issues` card's conversion mechanics when the situation is a conversion — and no new spec number is filed.
- **RED** — `grep -i "search" skills/spec/SKILL.md` finds no pre-filing store-search mandate: the filing flow (rule 5) contains no search step, so an assertion that rule 5 mandates a store search before filing fails against current behavior.
- **GREEN** — append the mandate paragraph to rule 5's body as drafted in the deliverable.
- **Tier marks** — no authored test; instrument class is a fact check (grep) on the card text.
- **Instrument** — `grep -c` the mandate phrases in `skills/spec/SKILL.md`: the search-before-filing mandate covering "local issue store"+"remote tracker", the routing-into-existing-match wording, and the amend/extend-in-place wording; plus a read of rule 5 to confirm the mandate precedes "filing any new spec" (the general filing-path binding, not conversion-only).

### Item 2 — Same mandate in the `issues` card's work-entry conversion clause

- **Deliverable** — a mandate sentence added to `skills/issues/SKILL.md` §5's work-entry conversion clause (the `.opencode#2707` paragraph), reading (in substance): the conversion inherits the spec card's search-before-filing mandate — before converting a report into a spec, the triaging agent searches the repository's local issue store and its linked remote tracker for a spec already covering the same requirement or behavior class, and on a match routes the report's requirement into that existing spec in place (amend/extend under the spec card's revision discipline, or this clause's conversion mechanics) instead of filing a new spec record.
- **RED** — `grep -i "search" skills/issues/SKILL.md` finds the clause carrying no search-before-filing step: the work-entry conversion paragraph mandates no store search, so an assertion that the clause carries the mandate fails against current behavior.
- **GREEN** — append the mandate sentence to the §5 work-entry conversion paragraph as drafted in the deliverable.
- **Tier marks** — no authored test; instrument class is a fact check (grep) on the card text.
- **Instrument** — `grep` `skills/issues/SKILL.md` within the §5 conversion paragraph for the search-before-filing wording matching Item 1's mandate (coverage of local store + remote tracker, routing into the existing match).

### Item 3 — Behavioral run: mid-session filing routes into an existing spec

- **Deliverable** — one tier-1 behavioral evidence cycle exercising SC-6's scenario: a clean-room sub-agent dispatch per the behavioral-testing card's tier-1 route (simple card change — two card-text paragraph insertions; tier eligibility is the agent's judgment under that card, which requires no harness run for tier-1) in which the dispatched reviewer confronts a mock mid-session filing scenario — a developer requirement surfacing mid-implementation that matches an existing spec in the store (a mock store artifact provides the matching spec) — and judges the flow the changed cards prescribe; the cycle runs RED against the pre-change card texts and GREEN against the change-carrying branch; the dispatch prompt, criterion judged, and returned verdict persist into the issue's audit directory.
- **RED** — the mock dispatch asserted against the pre-change card texts fails: the reviewer reading the unchanged filing flow finds no store-search step and reports that the mock session's flow files a new number.
- **GREEN** — the same mock dispatch against the change-carrying branch observes the mandated search step and the routing decision (route into the existing spec, no new number filed).
- **Tier marks** — no authored test file; the instrument is a recorded clean-room dispatch (tier-1 evidence per the behavioral-testing card), persisted in the issue's audit directory.
- **Instrument** — the recorded dispatch verdict records: the RED dispatch's no-search-step finding against the pre-change texts, and the GREEN dispatch's verdict that the changed flow runs the search and routes into the existing spec, each persisted under `.issues/2756/audit/`.

## 4. Dependency order

Item 1 → Item 2 → Item 3. Item 2 is independent of Item 1 in content but the daisy-chain commit order puts the primary card's mandate first; Item 3's scenario exercises the filing flow the Items 1–2 mandate (the pre-change RED of Item 3 requires the unchanged deck, and its GREEN requires the branch already carrying both card edits) — so it runs last, after both commits exist.

## 5. Traceability

| Item | SCs |
|------|-----|
| Item 1 | SC-1, SC-2, SC-3, SC-5 |
| Item 2 | SC-4 |
| Item 3 | SC-6 |

Every SC (SC-1..SC-6) is covered; no item lacks a trace.

## 6. Verification summary

- Items 1–2 verify through fact checks (grep/read of the two card files) at cycle time; the greps also re-run at PR-check time as the structural SCC evidence.
- Item 3 verifies through one recorded clean-room tier-1 dispatch cycle (RED pre-change / GREEN post-change) per the behavioral-testing card; the evidence records persist on the issue's store branch (`audit/`).
- No authored test files exist in this plan; no tests-v2 harness run is required — tier-1 eligibility per the behavioral-testing card (evidence records persist on the store branch's `audit/`).

## 7. Status boundary

Implementation state lives in the pipeline, not here. No STATUS fields or completion markers appear in this plan.

## 8. Deck-governance note

The mandated text is deck content authored under the deck-governance card's standards: observed failure is the spec's recorded incident; the consumer is every spec-filing session; the mechanism is card-text procedure (intent-decidable — matching a requirement/behavior class is judgment search, never script-enforced); wording is root-agnostic (relative paths only); net addition is minimal and displaces reliance on agent recall (the rejected alternative), keeping both card bodies lean.

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->

---
Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
