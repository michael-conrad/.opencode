<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored; remote issue .opencode#2771 filed 2026-11-24T14:03:29Z
     (report authored by OpenCode, ollama-cloud/oceans-sedge/GLM-5.3-Flash);
     developer directive 2026-11-24 (session): "triage .opencode#2771"; the work-entry
     conversion (.opencode#2707) rendered the report in place into this governing
     spec, triage verdict: actionable work, option (b) selected. Every tool claim
     verified against .opencode/tools/local-issues at 51e1be91a (the .opencode
     checkout at its own remote trunk tip, 2026-11-24, pre-triage freshness gate);
     parent gitlink drift 7e50437b → 51e1be91a recorded, checkout governs. -->

# [SPEC] local-issues sync's up_to_date claim self-scopes — store-branch currency only, record status workflow-local

## 1. Intent and executive summary

**Problem Statement.** `local-issues sync` (pull path) reports per-repo
`pull_result: up_to_date` on success while a record's `status: open` can
diverge from the linked tracker issue's closed state (`.opencode#2771`:
NewsRx/hermes-ingest-pubmed#318, closed by a PR merge resolving `Closes #N`,
`state_reason: completed`; the divergence corrected only after an explicit
`close --number … --reason completed`). No surface states what `up_to_date`
claims: the tool's `sync`/`init` help text, the CLI reference's `sync` row, and
the reconciliation reference all read as parity claims, though `sync` contacts
no issues-system API and maps no tracker ticket state.

**Root Cause / Motivation.** Cause: the store-branch mirroring (what `sync`
implements — commit / pull-rebase / push of the `issues-data` worktree,
reported by `pull_result: up_to_date`) and the ticket-status reconciliation
between the local record and the tracker are two different jobs. The tool
implements only the former, and neither the output's vocabulary nor any
surface separates the two — so every reader of `up_to_date` (including the
session-start consumer) reasonably reads record↔tracker parity that was never
verified. Motivation: the sequence runs at every session start and the
misread carries real cost — the reproducer's divergence survived until an
explicit workflow close reconciled it, while the store's own docs name only
the opposite drift direction (local-closed/remote-OPEN, the `#2561` paragraph
in `sync-mirroring.md`).

**Approach Chosen.** Self-scope the claim on the tool's own surfaces and align
the two deck reference docs that own the semantics. (1) The `sync` and `init`
subparsers' help text carries one shared scoping statement: the reported
`pull_result` (`up_to_date`) asserts the `issues-data` store branch's git
currency only; record↔tracker ticket-status parity is not verified here — it
reconciles through the closure/ticket-state-hygiene flow. (2) The CLI
reference's `sync` row carries the same scoping (record `status` is
workflow-local; the hygiene flow owns reconciliation). (3) The reconciliation
section is extended in place to name the tracker-closed/record-open direction
and its resolving path. Tool behavior is unchanged. Impact envelope: consumers
are the session-start `init`/`sync` readers and every consumer parsing the
tools' YAML output — the YAML vocabulary stays byte-stable (R-4); non-code
surfaces reached are exactly the two deck reference docs (a deck-wide sweep
2026-11-24 found the claim scoped nowhere else — Documentation Sources); no
existing test asserts the touched surfaces
(`.opencode/tests/test_local_issues/` swept 2026-11-24), and the suite keeps
passing under R-4.

**Alternatives Considered & Why Discarded.**
1. *Option (a) of the report — `sync` maps the tracker's
   closed/`state_reason` into the record's status.* Discarded: `sync`/`init`
   would need to contact the issues-system API, violating the tool's operating
   boundary (issues card §7: local-issues commands manage only the local
   issues-data store — they never contact or update any remote issues-system
   API on any platform; restated in the `update` help row), and auto-mapping a
   tracker-side closure would propagate a remote state past the deck's
   evidence-backed closure bar (closure follows delivered work or an
   evidence-backed verdict, never to tidy up — issues card §5; the `#2561`
   guard against propagating an unexplained flip holds).
2. *A static runtime signal field in `sync`'s YAML output (e.g.
   `record_status_parity: unchecked`).* Discarded: the tool cannot know parity
   without API contact, so a constant field adds parse surface for every
   consumer while carrying no per-run information; the scoping statement on
   the help surface plus the store docs is the report's option (b) reading.
3. *Leave as-is (status is workflow-local by construction).* Discarded: the
   observed failure (`.opencode#2771`) shows the real cost — an explicit close
   was needed to reconcile while `up_to_date` implied no divergence — and no
   surface names workflow-locality or the resolving path, so the misread
   recurs at every session start.

**Key Design Decisions.**
1. Scoping lives in the subparsers' help text rather than the YAML schema
   (the deck's flag-level-truth delegation, set by `#2655`'s precedent): no
   output vocabulary churn; existing consumers keep
   `status: ok` / `pull_result: up_to_date`.
2. `init` inherits the identical claim through the shared `_sync_repo` path,
   so both subparsers carry the same shared statement — the two surfaces
   cannot diverge.
3. The reference-doc rows are this spec's deck-governance surface (edits
   under `skills/issues/references/` go through the deck-governance card's
   admission gate in the deck repo's own PR process); one clause joins the
   CLI reference's `sync` row, and the reconciliation section is extended in
   place — never rewritten past its existing `#2561` guard.

**User Intent / Original Prompt.**
- Developer directive, 2026-11-24 (session): "triage .opencode#2771".
- Report `.opencode#2771`, filed 2026-11-24T14:03:29Z, Observed behavior
  (verbatim): "`.opencode/tools/local-issues sync` (pull path) reports
  `pull_result: up_to_date` and leaves the local record's `status: open` even
  when the linked remote tracker shows the issue **closed** with
  `state_reason: completed` (NewsRx/hermes-ingest-pubmed#318, closed by a PR's
  `Closes #N` keyword at merge). The diverged status only corrects after an
  explicit `local-issues close --number hermes-ingest-pubmed#318 --reason
  completed`."
- Report `.opencode#2771`, Expected behavior (verbatim): "Either (a) `sync`
  maps the remote's closed/state_reason into the local record's status (the
  up_to_date claim then holds), or (b) the store documents that status is
  workflow-local and `sync`'s up-to-date claim is scoped accordingly — some
  signal that a closure divergence remains for the cleanup flow to resolve."
  The triage verdict selected (b); (a) is out of scope per the boundary
  (preamble, Alternatives 1).

## 2. Not Included

- Mapping tracker state in `sync`/`init` (the report's option (a)) — violates
  the tool's never-contact-remote-API boundary and the closure bar's
  evidence-first rule; rationale in Alternatives 1.
- YAML output-schema changes (field additions, value renames such as renaming
  `pull_result` or its values) — the claim self-describes on the help surface
  instead; consumers' vocabulary unchanged (R-4).
- Changes to the tool's store-branch mechanics (fetch/rebase/push of the
  `issues-data` worktree) or to `close`'s semantics — the defect is the
  claim's documentation, not the mirroring or the closure command.
- Edits to the issues card (`SKILL.md`) — its §5/§6 already own the closure
  and hygiene flows; the scoping lives in the tool help, the CLI reference
  row, and the reconciliation section.
- Test-suite restructuring — existing `sync`/`init` behavioral tests keep
  passing; the regression instrument reuses the session-start `init`+`sync`
  sequence already in use.

## 3. Requirements

- **R-1 — Self-scoping help.** `local-issues sync --help` and
  `local-issues init --help` SHALL each carry the shared scoping statement,
  with one statement feeding both subparsers: the reported `pull_result`
  (`up_to_date`) asserts only the `issues-data` store branch's git currency
  (commit / pull-rebase / push of the store worktree); it does not assert
  record↔remote-tracker ticket-status parity.
- **R-2 — Workflow-local status documented.** The CLI reference's `sync` row
  (`skills/issues/references/local-issues-cli.md`) SHALL state, within the
  row, that a record's `status` field is workflow-local — `sync`/`init` do not
  read or map tracker ticket state — and SHALL name the reconciliation owner
  (the issues card's closure / ticket-state-hygiene flow).
- **R-3 — Divergence direction named.** The reconciliation section of
  `skills/issues/references/sync-mirroring.md` (§Remote-state reconciliation,
  `#2561`) SHALL gain the tracker-closed/record-open direction: a tracker-side
  closure made outside the local workflow (for example a PR merge resolving
  `Closes #N`, `state_reason: completed`) is not mapped by `sync` and
  reconciles through the ticket-state-hygiene flow (the issues card §6's
  remote-anchors-reality rule; `close --reason completed` records the
  completed merge) — and the extension SHALL keep the existing `#2561`
  sentences (the guard against propagating an unexplained status flip) intact
  and uncontradicted.
- **R-4 — Unchanged behavior.** The tool's store-branch mechanics, the YAML
  output vocabulary (`status: ok`, `pull_result: up_to_date`), and the exit
  semantics SHALL remain unchanged: `init` and `sync` on a clean composed
  store still exit 0 reporting `status: ok` per repo, and the subcommand help
  still renders.

## 4. Success criteria

| ID | Criterion | Class | Instrument |
|---|---|---|---|
| SC-1 | `sync --help` and `init --help` each carry the shared scoping statement (store-branch-only claim; record↔tracker parity not verified here) | structural | run `./.opencode/tools/local-issues sync --help` and `init --help`; match the statement text in both outputs |
| SC-2 | The CLI reference's `sync` row states workflow-local record status and names the hygiene flow as reconciliation owner | structural | read `skills/issues/references/local-issues-cli.md` at the store HEAD; the `sync` row carries the clause |
| SC-3 | The reconciliation section names the tracker-closed/record-open direction and its resolving path | structural | read `skills/issues/references/sync-mirroring.md` at the store HEAD; the §Remote-state reconciliation section carries the direction and the hygiene-flow resolving path |
| SC-4 | The existing `#2561` sentences in that section persist intact after the edit (guarding sections a change edits — preservation of the untouched paragraph) | structural | grep `sync-mirroring.md` for the existing guard sentences ("The local store is authoritative for issue status" and "store drift to investigate, not to propagate") after the edit |
| SC-5 | Executed `init` then `sync` on the composed workspace exit 0 with per-repo `status: ok` and `pull_result` values unchanged; `sync --help` output still renders (argparse intact) | behavioral | run the session-start `init` + `sync` sequence (the real composed store); assert YAML `status: ok` per repo, exit 0; run `sync --help` |

## 5. Dependencies

| Reference | Relationship | Status |
|---|---|---|
| `.opencode/tools/local-issues` — `_add_sync_parser` / `_add_init_parser` / `_sync_repo` | the edit surface (R-1, R-4) | satisfied — read at trunk tip 51e1be91a, 2026-11-24 |
| `skills/issues/references/local-issues-cli.md` + `sync-mirroring.md` | deck-governance-surface edit targets (R-2, R-3); edits proceed through the deck-governance card's admission gate in the deck repo's own PR | satisfied — read at trunk tip, 2026-11-24 |
| `skills/issues/SKILL.md` §5 (closure bar) and §6 (ticket-state hygiene, remote-anchors-reality) | the semantics the new doc text must align with | satisfied — read 2026-11-24 |
| Developer approval of this spec | the spec card's approval gate before `plan` | pending |

## 6. Traceability

| Requirement | Success criteria |
|---|---|
| R-1 | SC-1 |
| R-2 | SC-2 |
| R-3 | SC-3, SC-4 |
| R-4 | SC-5 |

## 7. Documentation sources

| Source | Type | Location | Verification |
|---|---|---|---|
| `.opencode/tools/local-issues` — `_sync_repo` | code | lines ~2300–2345 (`pull_result: up_to_date` at 2341–2342; the claim is the store branch's fetch/rebase/push result) | read at trunk tip 51e1be91a, 2026-11-24 |
| `.opencode/tools/local-issues` — `cmd_close` | code | lines 1796–1814 (sets `status: closed`, `closed_at`, `close_reason`; no remote contact) | read at trunk tip 51e1be91a, 2026-11-24 |
| `.opencode/tools/local-issues` — subparser help | code | `_add_init_parser` (2759–2762), `_add_sync_parser` (2783–2786) — no scoping statement present | read at trunk tip 51e1be91a, 2026-11-24 |
| Tool CLI surface | executed output | `sync --help`, `close --help`, `update --help` | run 2026-11-24; no scoping statement in any output |
| `skills/issues/references/sync-mirroring.md` — §Remote-state reconciliation (#2561) | doc | lines 79–87 (covers the local-closed/remote-OPEN direction only) | read at trunk tip, 2026-11-24 |
| `skills/issues/references/local-issues-cli.md` — `sync` row | doc | line 16 ("Per repo: commit pending, pull-rebase, push. Reports per-repo status (…)") — no scoping | read at trunk tip, 2026-11-24 |
| `skills/issues/SKILL.md` §5/§6/§7 | card | closure bar and hygiene flows; §7's never-contact-remote-API boundary | read 2026-11-24 |
| `.opencode#2771` | remote issue | the report (Observed/Expected behavior quoted verbatim in the preamble) | fetched via `gh issue view`, 2026-11-24; the reproducer NewsRx/hermes-ingest-pubmed#318 is the reporter's dated account and is used as provenance only — outside this session's target set, not independently verified; the tool-semantics claims stand on the code read alone |
| Deck-wide claim sweep | doc/tool grep | `grep` for `up_to_date` / `up-to-date` across `.opencode/skills/`, `.opencode/tools/local-issues`, `.opencode/AGENTS.md`, `.opencode/floor.md` | run 2026-11-24 — only unrelated `wiki-operations` text and the tool's assignment line (line 2342); back the preamble's "no surface states what `up_to_date` claims" |
| `.opencode/tests/test_local_issues/` | test suite sweep | grep for `up_to_date` / `pull_result` assertions | run 2026-11-24 — no test asserts the touched surfaces; suite inventory listed |

## 8. Cost frame

| SC | Acting costs | Skipping costs |
|---|---|---|
| SC-1 | two help-output runs, seconds | future sessions misread `up_to_date` on the tool's own surface |
| SC-2 | one read of the CLI reference row, seconds | the workflow-locality fact stays discoverable only by reading deck prose elsewhere |
| SC-3 | one read of the reconciliation section, seconds | the tracker-closed/record-open divergence repeats the reproduce-close cycle |
| SC-4 | one grep after the edit, seconds | the `#2561` guard silently weakened by the same-section edit |
| SC-5 | the session-start `init`+`sync` sequence already in flow, seconds | a help-string addition breaking argparse or sync sails into every session start |

## 9. Edge cases

- **Help rendering.** Adding subparser help text must keep argparse
  rendering; SC-5's `sync --help` run guards the surface. Condition: help
  string added; Expected behavior: help renders, command parses unaffected.
- **Doc contradiction.** The new text must not weaken the existing `#2561`
  guard; SC-4's preservation check. Condition: section extended; Expected
  behavior: existing sentences intact.
- **YAML consumers.** No schema or field change (R-4, SC-5) — parse consumers
  unaffected. Condition: help-only change; Expected behavior: outputs
  byte-stable in vocabulary.
- **Tracker-side closure classes.** `not_planned` and `duplicate` closures
  share the un-mapped direction; the hygiene flow's existing reason vocabulary
  (`completed`, `not_planned`, `duplicate`) already covers them, and the doc
  text names the direction generically (merge-completed as the `state_reason:
  completed` example). Condition: any tracker-side closure; Expected behavior:
  the same documented resolving path applies.

## 10. Completion gate

Every success criterion passes before the deliverable is complete; partial
implementation is not permitted.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
