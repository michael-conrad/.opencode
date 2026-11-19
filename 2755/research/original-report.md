<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: original bug-report body of michael-conrad/.opencode#2755 (remote
     tracker), preserved verbatim at work-entry conversion (2026-11-19). The record
     this body filed now reads as the spec (spec.md, same folder); this file is the
     field-evidence record, not the governing artifact. -->

# Original bug report — .opencode#2755 (filed 2026-11-19, title as filed)

`[BUG] Issues-data store maintenance: validate-yaml-surfaced artifact-content
defects fall outside every on-discovery repair trigger — agents report them
instead of repairing`

## Observed behavior

The issues card's on-discovery repair triggers (§6 ticket-state hygiene, §7
mirror-repair, interrupted-sync) cover **record/state divergence and
absent-or-broken records** — but no trigger covers **store-artifact content
defects**, concretely: invalid YAML surfaced by the store's own validator.

Field evidence from the consuming repo `NewsRx/hermes-ingest-pubmed` (issue
store on the `issues-data` orphan branch):

- 2026-11-18: a session ran `./.opencode/tools/local-issues validate-yaml` as
  part of filing #297; the sweep returned `invalid-yaml` findings on
  pre-existing store artifacts (`283/audit/validation.yaml`, `31/problem.yaml`,
  `89/post-sc-uplift-check.yaml`). The session's disposition was to **report
  the findings to the developer as "not repaired — outside this flow's scope"**
  and file its new artifact without touching the defective ones.
- 2026-11-19: the developer corrected the disposition — *the agent is always
  supposed to manage the repairs and maintenance of the issues-data branch
  without user intervention; the issues-data branch is managed directly by the
  agent as a standalone orphaned branch — not kept defective*. A fresh sweep
  the same day showed the defect class was in fact **larger**: 8 files
  (`265/270/273/275/283/audit/validation.yaml`, `297/audit/validation-plan.yaml`,
  `31/problem.yaml`, `89/post-sc-uplift-check.yaml`), most sharing one failure
  shape (a plain scalar carrying a `key:`-pattern inside its text; the rest: a
  stray document separator and a mapping-shape defect).

The failure the correction names is two-layered:

1. **Behavior layer** — the agent treated the findings as an "unowned
   observation" and left defective materials defective, when the floor's
   issue-store workspace-maintenance exception already authorizes reading,
   writing, and repairing store data as agent-owned work requiring no
   scope-bearing token.
2. **Doctrine layer (the .opencode defect)** — the cards that govern
   repair-on-discovery enumerate no trigger for artifact-content defects found
   by validate-yaml, so an agent reading the cards faithfully has no
   instruction binding repair (vs. report and wait) — and nothing tells it the
   *correct procedure* (dispatch a sub-agent for mechanical repairs such as
   YAML fixes), which had to come from a developer correction.

## Expected behavior

- Store-artifact defects surfaced by the store's own tooling
  (`validate-yaml`) trigger **repair-on-discovery in the same workflow** — the
  defect never needs a developer correction to act on, never stays knowingly
  defective across sessions, and the disposition (repaired, with the sweep
  re-verified clean) is recorded with the work that discovered it.
- The repair of mechanical content defects (YAML syntax) dispatches to a
  sub-agent under the dispatch-scope doctrine; the discovering session verifies
  the clean sweep and reports.
- The issues card binds this as an on-discovery trigger in the same class as
  §6's state-hygiene and §7's mirror-repair — currently both the fact of the
  mandate and the dispatch procedure live only in developer corrections, not in
  the deck.

## Steps to reproduce

1. In any store-holding repo whose `issues-data` branch carries a YAML artifact
   that fails `validate-yaml` (observed 2026-11-18/19 on
   `NewsRx/hermes-ingest-pubmed`).
2. Run `./.opencode/tools/local-issues validate-yaml` — it prints
   `invalid-yaml` findings and exits non-zero.
3. Search the issues card (the owning card for store maintenance) for a repair
   trigger naming artifact-content defects or validator findings: none exists —
   §6 (ticket-state hygiene) governs state divergence, §7 (mirror-repair,
   interrupted-sync) governs absent records, broken pointers, and interrupted
   syncs only.
4. Observe the resulting agent workflow: the findings are reported to the
   developer (chat) instead of repaired — reproduced 2026-11-18 on
   `NewsRx/hermes-ingest-pubmed` (three findings reported, zero repaired,
   correction received 2026-11-19).

## .opencode component affected

- `issues` skill card — the on-discovery repair trigger inventory (§6, §7) and
  the store-maintenance workflow it describes.
- `local-issues` `validate-yaml` tooling contract — the validator surfaces
  findings but no card-side contract binds their disposition.
- Secondary: the validation-record YAML pattern is the dominant defect source
  (plain scalars carrying `key:`-pattern text emitted into
  `audit/validation.yaml`-family records — 6 of the 8 field findings), so the
  repair trigger should also cover the emission-side guidance.

## Remediation direction (deck-governance path)

Extend the issues card's repair doctrine (§6/§7 or the validate-yaml contract)
so that artifact-content defects found by the store's own validator fall under
the same agent-owned repair-on-discovery class, with the mechanical-repair step
routed through a dispatched sub-agent per the dispatch-scope doctrine. The
floor's issue-store workspace-maintenance exception already carries the
authorization surface; the gap is the trigger list's coverage, not permission.

## Disposition of the field findings (this is the same defect the report exists to close — repaired before filing)

All 47 instances found store-wide on `NewsRx/hermes-ingest-pubmed`'s
`issues-data` branch were repaired on 2026-11-19 before this report was filed,
via dispatched store-maintenance repair sub-agents (the corrective procedure
the developer stated in the same exchange):

- **Tranche 1 (8 files)** — `265/270/273/275/283/audit/validation.yaml`,
  `297/audit/validation-plan.yaml`, `31/problem.yaml`,
  `89/post-sc-uplift-check.yaml`: per-file root causes diagnosed, syntax-only
  repairs (plain scalars carrying embedded `": "` → `>-` folds or quotes; stray
  `---` documents; mapping-shape dedents), every repaired scalar asserted
  byte-exact against pre-repair recorded text, synced per-file (`d18ff07`,
  `1afc256`, `e046fc4`, `dd9c8ec`, `e1b3d7d`, `b2accad`, `bc0b398`, `4f4b3da`).
- **Tranche 2 (39 files + 1 content restore)** — the dominant families: 26
  ScannerError (embedded `": "` prose scalars), 9 ParserError
  (sequence/mapping shape breaks; flow-sequence `#` comments), 4 ReaderError
  (raw ANSI SGR bytes — ESC characters from a TTY-colorized planner banner
  piped verbatim into plan-output records at record time, repaired to
  byte-exact quoted captures), plus #275's round-2 text clip (`**Status:**` →
  `**Status:`) restored byte-exact from git history. 68-assertion verification
  suite: PARSE 68/68; synced (tranche-2 files via `b50560d` + `bc0303e9` — with
  an honest deviation: a concurrent parent-session auto-sync swept 38 in-flight
  files into a pushed commit before per-file messages could land; final correct
  state verified at `HEAD == origin/issues-data`, working tree clean).
- **Final gate:** `local-issues validate-yaml` store-wide — **clean, exit 0**
  (verified by the discovering session, not only the repair agents).

Two lessons the findings themselves taught, both belonging in the fix: (1) the
discovering session's first sweep view was **tail-truncated** (8 of 47 files
shown) and was handed to the repair dispatch as "exactly these eight" — the
dispatch premise was stale and the remainder surfaced as a second tranche;
sweep output must be counted/verified, not sampled. (2) The record-emission
pattern (plain scalars carrying `key:`-pattern prose) is the systemic source —
6 of the first 8 and 26 more of the 39 — so the deck fix should pair the repair
trigger with emission-side quoting guidance.
