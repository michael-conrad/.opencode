<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->

# [PLAN] .opencode#2771 — sync's up_to_date claim self-scoping

## Goal

Implement the approved spec of `.opencode#2771`: scope the `local-issues sync`
`pull_result` claim on the tool's own help surfaces and align the two deck
reference docs that own the semantics, with tool behavior unchanged. Surfaces:
`.opencode/tools/local-issues` (help text only) and two reference docs under
`skills/issues/references/` (deck-governance surface, edits ride the deck
repo's PR).

## Execution surface

Work lands in the `.opencode` submodule (its own repository), on feature
branch `2771-sync-scoping` based at trunk tip `51e1be91a` (verified live at
branch creation, 2026-11-24). The composed workspace is the parent repo
checkout; the session-start `init`/`sync` sequence and `uv run pytest`
(parent's declared commands: `cd .opencode && uv sync` / `uv run pytest`) run
there.

The shared scoping statement (single source, feeding both subparsers):

> Store-branch scope: the reported pull_result (up_to_date) asserts only the
> issues-data store branch's git currency (commit/pull-rebase/push of the
> store worktree); record-to-tracker ticket-status parity is not verified
> here - reconciliation belongs to the closure/ticket-state-hygiene flow.

## Items

**Item 1 — SC-1, R-1: self-scoping subparser help**

- **Deliverable:** one shared scoping-statement constant in
  `.opencode/tools/local-issues`; `_add_init_parser` and `_add_sync_parser`
  each carry it in their help text.
- **RED:** run `./.opencode/tools/local-issues sync --help` and
  `init --help` — neither output carries the scoping statement (assertion
  written against current behavior, verified pre-edit).
- **GREEN:** add the constant and thread it into both subparsers' help
  strings; no behavior change.
- **Tier marks:** no authored test; instrument class = fact check (executed
  help runs).
- **Instrument:** run both help commands; match the statement text in each.

**Item 2 — SC-2, R-2: CLI reference `sync` row clause**

- **Deliverable:** the `sync` row in
  `skills/issues/references/local-issues-cli.md` extends in place with the
  workflow-locality clause: a record's `status` is workflow-local —
  `sync`/`init` do not read or map tracker ticket state — and the issues
  card's closure/ticket-state-hygiene flow owns reconciliation.
- **RED:** read the row at the store HEAD — the clause is absent.
- **GREEN:** edit the row in place, additive, existing row content preserved.
- **Tier marks:** no authored test; instrument class = fact check (row read).
- **Instrument:** read the row at the store HEAD; match the clause.

**Item 3 — SC-3 + SC-4, R-3: reconciliation section extension (guard preserved)**

- **Deliverable:** `skills/issues/references/sync-mirroring.md`
  §Remote-state reconciliation gains the tracker-closed/record-open direction:
  a tracker-side closure made outside the local workflow (e.g. a PR merge
  resolving `Closes #N`, `state_reason: completed`) is not mapped by
  `sync`/`init` and reconciles through the ticket-state-hygiene flow (issues
  card §6 remote-anchors-reality; `close --reason completed` records the
  completed merge).
- **RED:** read the section — only the local-closed/remote-OPEN direction
  appears.
- **GREEN:** extend the section in place; the existing `#2561` guard
  sentences stay byte-intact and uncontradicted.
- **Tier marks:** no authored test; instrument class = fact check (section
  read + grep).
- **Instrument:** read the extended section; grep for both guard sentences —
  "The local store is authoritative for issue status" and "store drift to
  investigate, not to propagate".

**Item 4 — SC-5, R-4: unchanged-behavior regression run**

- **Deliverable:** executed verification that init/sync behavior and the YAML
  vocabulary are unchanged after items 1–3.
- **RED:** the pre-edit baseline (established by running this instrument
  before item 1's edit): `init` + `sync` exit 0 with per-repo `status: ok` and
  `pull_result` values; the unit suite passes. Post-edit, the instrument must
  reproduce that baseline byte-stable in vocabulary (behavioral assertion
  against changed code).
- **GREEN:** none — verification-only item (behavior already guaranteed by
  unchanged mechanics; any discrepancy is a defect of items 1–3 to fix in
  place).
- **Tier marks:** no authored test; instrument class = executed run (real
  composed store + suite).
- **Instrument:** run the session-start sequence (`init` then `sync`; assert
  exit 0, per-repo `status: ok`, `pull_result` vocabulary unchanged), run
  `sync --help` (argparse renders), and run the root repo's declared suite
  (`cd .opencode && uv run pytest`) with all tests passing.

## Dependency order

1 → 2 → 3 → 4. Item 1 edits the tool surface items 2/3 document (docs name
what the help states, so the doc text is written against the landed help
wording). Item 4 runs last because it asserts the composed behavior of all
landed surfaces; no item's RED depends on a later item.

## Traceability

| Item | SC | Requirement |
|---|---|---|
| 1 | SC-1 | R-1 |
| 2 | SC-2 | R-2 |
| 3 | SC-3, SC-4 | R-3 |
| 4 | SC-5 | R-4 |

## Verification summary

No authored tests anywhere in the plan — the suite sweep (spec §7) found no
test asserts the touched surfaces, and the spec authors none. Verification is
fact checks (items 1–3) plus one executed behavioral run (item 4: real
session-start sequence, help render, and the root repo's declared `uv run
pytest` suite at cycle time; suite runs again at PR-check time via the PR's
verification evidence).

## Status boundary

Implementation state lives in the pipeline; no status fields in this plan.

<!-- SPDX-FileCopyrightText: footer per repo convention -->
🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
