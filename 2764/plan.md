# Plan — .opencode#2764: pre-triage freshness gate (pull session-enumerated repos to remote trunk tip before any triage)

## 1. Goal

This plan delivers a deck text change for michael-conrad/.opencode#2764: a mandatory pre-triage freshness gate in the `issues` card's triage paths — before any triage runs (closure triage, work-entry conversion triage), the agent pulls every session-enumerated repo (root plus registered submodules, per session-init's `#2544` strict discovery) to its remote trunk tip, runs `git submodule status`, syncs each submodule checkout to its own remote trunk tip (the `#2563` definition of up to date — never the possibly-stale recorded pointer), and renders the triage verdict against that post-sync state with the freshness statement recorded in the verdict's grounds.

## 2. Execution surface

- Repository: michael-conrad/.opencode (the deck submodule checkout at `.opencode/`; PR lands in that repository — deck changes author upstream through the deck's own PR process).
- Branch: `2764-pre-triage-freshness`, based on the verified trunk tip `39bff14cd` (`.opencode` `main` = `origin/main` at branch-creation time; executed fetch-and-compare — at-tip).
- Environment fact: the issue store worktree `.opencode/.issues/` is a separate worktree on branch `issues-data` — artifacts for this issue are committed there via `local-issues sync`, never inside the deck branch; the deck PR carries only the `skills/issues/SKILL.md` change.
- Files touched: `skills/issues/SKILL.md` (§5 triage paths and the card's provenance header) — one file.

## 3. Items

### Item 1 — Pre-triage freshness gate clause in §5 closure triage (SC-1, SC-2, SC-3)

- **Deliverable** — a fresh paragraph inserted in `skills/issues/SKILL.md` §5 immediately after the "Ticket-status semantics" sentences and before the closure triage ruling, reading (in substance): **Pre-triage freshness gate:** every triage path in this card — closure triage and work-entry conversion alike, self-triggered or developer-directed — is preceded by a freshness sync before the triage verdict is rendered. The gate pulls every session-enumerated repo to its remote trunk tip — the target set is exactly session-init's enumerated repo set (root repo plus registered submodules, the `#2544` strict discovery), no more and no less — and runs `git submodule status` over the registered submodules, syncing each submodule checkout to its own remote trunk tip (the `.opencode#2563` ruling's definition of up to date — never a possibly-stale recorded pointer: syncing to the recorded pointer reproduces the bitrot the gate exists to remove). Where the pulled parent tip's registered gitlink differs from a submodule's remote trunk tip — the sanctioned pointer-drift state — the trunk-tip checkout governs the triage's reading and the drift is recorded in the verdict's grounds rather than resolved by the gate (pointer resolution rides with real parent-repo changes, outside the triage moment). A triage whose freshness sync fails (network or auth) is a cannot-continue state under the floor's existing report-with-evidence-and-halt rule. The verdict is rendered against the post-sync state, and the verdict's recorded grounds state that the freshness gate ran.
- **RED** — `grep -in "freshness\|trunk tip" skills/issues/SKILL.md` in §5 finds no pre-triage freshness mandate: the closure triage ruling states no pull/`git submodule status` precondition, so an assertion that the triage mandate carries the freshness gate fails against current behavior.
- **GREEN** — insert the gate paragraph as drafted in the deliverable, and extend the card's provenance comment line with the `.opencode#2764` attribution.
- **Tier marks** — no authored test; instrument class is a fact check (grep/read) on the card text.
- **Instrument** — `grep` of `skills/issues/SKILL.md` confirming the gate paragraph carries: the pull-to-remote-trunk-tip step, the `git submodule status` confirmation step, the session-init enumerated-repo-set target-set source, the `#2563` trunk-tip definition (recorded-pointer exclusion), the drift-recorded-not-resolved disposition, and the freshness-statement-in-grounds requirement; plus a read of §5 confirming the clause sits in the triage path shared text (binding both triage paths).

### Item 2 — Gate binding in the §5 work-entry conversion triage clause (SC-1, SC-4)

- **Deliverable** — in `skills/issues/SKILL.md` §5's work-entry conversion paragraph (the `.opencode#2707` paragraph), a binding sentence appended: the conversion's triage runs the §5 pre-triage freshness gate before rendering its verdict, and the conversion record's grounds state that the freshness gate ran.
- **RED** — `grep -n "work-entry conversion" -A 20 skills/issues/SKILL.md` finds the conversion paragraph naming no freshness precondition: the clause currently inherits only the spec card's search-before-filing mandate, so an assertion that the conversion triage carries the freshness gate fails against current behavior.
- **GREEN** — append the binding sentence to the conversion paragraph as drafted in the deliverable.
- **Tier marks** — no authored test; instrument class is a fact check (grep/read) on the card text.
- **Instrument** — read of the §5 work-entry conversion paragraph confirming the binding sentence names the pre-triage freshness gate and the gates-in-grounds requirement; `grep` confirming the two triage paths both name the gate (no path left ungated — SC-1's both-paths condition).

### Item 3 — Tier-1 behavioral dispatch: a triage session runs the freshness sync before its verdict (SC-2, SC-4)

- **Deliverable** — one tier-1 behavioral evidence cycle exercising SC-2 and SC-4's scenario: a clean-room sub-agent dispatch per the behavioral-testing card's tier-1 route (simple card change — one card's triage-path clause; tier eligibility is the agent's judgment under that card, which requires no harness run for tier-1) in which the dispatched reviewer is given the changed card text and a mock triage task — a triaged bug report whose deliverables plausibly intersect the working tree — and judges the flow the changed card prescribes: whether the session performs the freshness sync (pull of each enumerated repo to remote trunk tip, then `git submodule status`) before rendering the triage verdict, and whether the verdict grounds carry the freshness statement. The cycle runs RED against the pre-change card text and GREEN against the change-carrying branch; the dispatch prompt, criterion judged, and returned verdict persist into the issue's audit directory.
- **RED** — the mock dispatch asserted against the pre-change card text fails: the reviewer reading the unchanged triage paths finds no freshness precondition and reports that the mock session would render its verdict against the stale tree without any sync.
- **GREEN** — the same mock dispatch against the change-carrying branch observes the gate: the session performs the pull + `git submodule status` before the verdict and records the freshness statement in the grounds.
- **Tier marks** — no authored test file; the instrument is a recorded clean-room dispatch (tier-1 evidence per the behavioral-testing card), persisted in the issue's audit directory.
- **Instrument** — the recorded dispatch verdict records: the RED dispatch's no-gate finding against the pre-change text, and the GREEN dispatch's verdict that the changed flow runs the freshness sync before the triage verdict with the freshness statement in the grounds, each persisted under `.opencode/.issues/2764/audit/`.

## 4. Dependency order

Item 1 → Item 2 → Item 3. Items 1–2 are independent in content (the gate clause and the conversion binding touch different paragraphs of the same file) but share one file and one RED family; Item 3's scenario exercises the triage flow Items 1–2 mandate (the pre-change RED requires the unchanged deck; its GREEN requires the branch carrying both card edits) — so it runs last.

## 5. Traceability

| Item | SCs |
|------|-----|
| Item 1 | SC-1, SC-2, SC-3 |
| Item 2 | SC-1, SC-4 |
| Item 3 | SC-2, SC-4 |

Every SC (SC-1..SC-4) is covered; no item lacks a trace. R-1..R-4 trace to SC-1..SC-4 via the spec's own traceability table (§6).

## 6. Verification summary

- Items 1–2 verify through fact checks (grep/read of `skills/issues/SKILL.md`) at cycle time; the greps re-run at PR-check time as the structural SC evidence.
- Item 3 verifies through one recorded clean-room tier-1 dispatch cycle (RED pre-change / GREEN post-change) per the behavioral-testing card; the evidence records persist on the issue's store branch (`audit/`).
- The spec's SC-2/SC-4 instruments name "tests-v2 behavioral scenario"; the tier-1 route recorded here is the behavioral-testing card's sanctioned evidence form for a simple card change (tier eligibility by agent judgment — no harness run required for tier-1), and this deviation is the card-governed evidence class for the spec's behavioral instrument.
- No authored test files exist in this plan; no tests-v2 harness run is required.

## 7. Status boundary

Implementation state lives in the pipeline, not here. No STATUS fields or completion markers appear in this plan.

## 8. Deck-governance note

The mandated text is deck content authored under the deck-governance card's standards: observed failure class is triage verdicts rendered against stale trees (the spec's recorded motivation); the consumer is every triage-running session (closure triage and work-entry conversion); the mechanism is card-text procedure (the gate is a mutating sync whose mechanics reuse the deck's sanctioned pull-to-tip and `#2563` trunk-tip patterns — intent-decidable judgment operates only in the verdict's drift recording, never script-enforced); wording is root-agnostic (relative paths only); net addition is one paragraph plus one binding sentence, displacing reliance on agent recall (the rejected alternative), keeping the card body lean.

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->

---
Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
