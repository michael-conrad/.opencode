<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: Bug report filed 2026-11-12 at the developer's explicit
     instruction during the NewsRx/hermes-ingest-pubmed session ("this is an
     unwanted intrusion by an agent into the deck. file a bug report upstream
     with .opencode/ to have it triaged."), with addendum verifying the
     mechanism's upstream provenance against live history (2026-11-12).
     Converted in place into this governing spec on 2026-11-12 under the
     developer's triage dispatch; the developer's statement on record:
     "no such work-record file was ever requested or authorized to be created
     or used by the developer." Triage evidence:
     research/triage-2026-11-12.md. Revised 2026-11-12 on the developer's
     revision directive: tracking files of this class are a defect category —
     state that goes stale and causes agents doing unauthorized work from
     bit-rotted items — the remedy is elimination, not relocation. -->

# [SPEC] Eliminate the deck's work-record file mechanism — carry provenance and scope on surfaces whose lifecycle cannot go stale

## Problem

During a spec-stage work cycle in `NewsRx/hermes-ingest-pubmed` (2026-11-12),
the executing agent created `.git/work-record.md` inside the consuming
repository's own git directory — the path
`git rev-parse --git-path work-record.md` resolves to — exactly as the deck's
`work` card §4 prescribes. The developer (repo owner) discovered the file
during an owner audit and judged the mechanism itself a defect.

The developer's statements on record (2026-11-12):

- *"no such work-record file was ever requested or authorized to be created
  or used by the developer."*
- Tracking files of this class are a defect category: they "generally refer
  to state that is quickly stale and cause issues with agents doing
  unauthorized work and incorporating bit-rotted items intentionally." The
  remedy is elimination unless absolutely necessary — not relocation.

Two defects stack. The proximate one: `.git/` is git's own operational state;
an agent-authored file there is invisible to `git status`, reads as an
intrusion on owner audit, and its only cleanup is a future session
remembering a cleanup-card step — a latent-residue failure mode. The
categorical one: the deck prescribes a persistent agent-authored state file
as mid-cycle infrastructure at all. A file that exists to carry state across
card boundaries necessarily outlives its currency — the cycle moves on, the
file stays — and any later reader (a later card step, a fresh-context
reviewer, a subsequent session after a missed cleanup) encounters
bit-rotted content standing where current state should be, with no way to
distinguish the two. That is the mechanism behind the failure modes the
developer names: stale provenance read as verified, stale scope read as
authorized, residue read as in-scope work.

Provenance of the mechanism (verified against live upstream history
2026-11-12 — the report's addendum, the triage's re-check, and the
validation round's independent re-check; see
`research/triage-2026-11-12.md`):

- The work record as a mechanism concept predates the #2657 cycle: informal
  two-word references existed without any deck-prescribed location —
  `skills/git-workflow-branch/SKILL.md` ("state the verified tip in the work
  record", from #2490 stage 2b, 2026-10-04) and `skills/work/SKILL.md`
  ("reason visible in the work record", from #2584, 2026-10-12). At
  `ac5c4407^` the deck carries zero hyphenated `work-record` forms and zero
  `git-path` prescriptions (executed `git grep` at that revision).
- The `.git`-directory residency definition is the #2657 cycle's addition:
  the path was chosen in the plan revisions `10711d95`, `e32a070a`
  (2026-10-23) and landed in `skills/work/SKILL.md` §4 via commit
  `ac5c4407` (2026-10-31) — its diff adds "The work record is one file in
  the repository's own git directory — the path
  `git rev-parse --git-path work-record.md` reports" — carried by PR #2693,
  merged 2026-11-01T02:47:51Z on the `michael-conrad` account.
- The merged PR body does not disclose the write location (zero matches for
  "work record" / "git directory" / "git-path" / ".git").
- The driving issue `.opencode#2657` carries zero comments — no consultation
  trail.

What is on trial is the record-file mechanism itself — both the `.git`
residency the #2657 cycle introduced and the persistent-state-file design it
prescribes. The record *function* (provenance and scope must exist somewhere)
is not on trial; where it lives is.

## Root cause

The work record entered the deck through the #2657 cycle as a persistent
agent-authored state file, sited in the consuming repository's git directory,
without stakeholder consultation and without disclosure of its
consuming-repo side effect in the merged change summary. The cause-level
surface is the deck's own instruction text: as long as a card prescribes a
record file at any repository-side path, every work cycle following the deck
creates state that outlives its currency, and every cycle reproduces both
the intrusion and the staleness failure mode.

## Requirements

- **R-1** — The deck's agent-facing instruction surface (`skills/`,
  `guidelines/`, `agents/`, `floor.md`) SHALL prescribe no agent-authored
  file — including the work record — inside any repository's git directory:
  no `git rev-parse --git-path`-resolved record path, no `.git/`-resident
  record path, and no prose locating the record (or any agent-authored
  scratch file) in a repository's git directory.
- **R-2** — The deck SHALL prescribe no dedicated work-record file on any
  surface: not the git directory (R-1), not the repository's working tree,
  and not the cycle's issue folder (no record file is added to the issue
  store; the store holds only the artifacts the pipeline already produces).
  The record's content — the provenance (verified trunk tip, branch, base
  tip, and issue) and the scope statement (path taken, criteria that selected
  it, what changes, what "done" is checked against, what is out of scope,
  order of work) — SHALL be carried only by surfaces whose lifecycle already
  exists in the cycle and whose currency is guaranteed by how they are
  produced, so staleness cannot arise:
  - **Provenance** is verified live at the moment it is acted on — the
    branch card's trunk-freshness check verifies the tip at execution time
    and states the result in its own output and the PR body's Provenance
    section; nothing is written down for a later step to read back.
  - **The scope statement** is carried by the dispatch prompts and the
    session's own state: the session that holds the scope supplies it
    verbatim to each consumer (the verify dispatch, an implement
    sub-dispatch) at dispatch time. Where a full-path cycle runs, the spec
    artifact the pipeline already produces carries the scope — no separate
    record is created alongside it.
  - **Recorded reasons** (the implement card's scoped-dispatch reason, the
    version-manager card's numbering justification) are recorded in the
    same surface that acts on them, at the moment of acting — the dispatch
    prompt that carries the reason to its executor; the PR body for what
    must persist past the cycle. A reason is never parked in a file for a
    later step to discover.
- **R-3** — Every card referencing the work record SHALL be revised in the
  same change, replacing each record-file reference with the stateless
  disposition R-2 states for it: `work` (§4 and the short-path outgrowth
  passage), `git-workflow-branch` (trunk-freshness step, its per-submodule
  recording clause, and rule 5), `implement` (short-path inline default),
  `version-manager` (rule 7 numbering authority), `verify` (§1 dispatch),
  `git-workflow-cleanup` (description and rule 5 — the record-removal step
  is deleted; there is nothing left to remove). No card is left referencing
  a record file on any surface, and no card invents a divergent carrier.
- **R-4** — The record's consumers SHALL continue to function without any
  record file: the short-path outgrowth extension (`work`) re-derives scope
  from the session's own state and the developer's request, extending it in
  the dispatch prompts it issues; the implement card's scoped-dispatch-reason
  requirement is satisfied by the reason traveling in the dispatch prompt
  that needs it; the version-manager card's numbering justification is
  stated in the PR body at version-bump time; the verify card's short-path
  primary artifact is the scope statement as supplied in the dispatch
  prompt itself, which the dispatched reviewer reads directly — the
  dispatching session includes it verbatim.
- **R-5** — Necessity gate: the deck SHALL prescribe a persistent
  agent-authored file for mid-cycle state only where a demonstrated failure
  shows no existing surface can carry the content, and any such prescription
  enters the deck only through the governance process with the developer's
  explicit approval of that specific file mechanism — absence of a carrier
  is reported to the developer, never solved by inventing a file. The
  preserved boundary stands: "never create an issue, or initialize an issue
  store, to satisfy provenance."

## Success criteria

All criteria are structural: the deliverable is the deck's instruction text,
and each criterion's satisfaction is decidable from the changed text. The
runtime effect — agents following the deck create no record file and read no
stale one — follows from the content criteria; the deck's text is the lever
the change owns. Instruments run over the deck checkout (the `.opencode`
repository).

- **SC-1 (structural).** The deck's agent-facing instruction surface
  prescribes no work record — and no other agent-authored file — located
  inside a repository's git directory.
  Instrument: executed
  `grep -rn "git-path work-record" skills/ guidelines/ agents/ floor.md` and
  `grep -rn "\.git/work-record" skills/ guidelines/ agents/ floor.md` → zero
  matches; plus a fresh-context content review of the six revised card
  sections confirming no prose form locates an agent-authored file in a git
  directory. (The grep covers the mechanical path forms; the review covers
  rephrasing.)
- **SC-2 (structural).** The deck prescribes no dedicated work-record file
  on any surface: every true work-record reference in the agent-facing
  instruction surface names a stateless carrier per R-2, and zero
  references direct a file into a git directory, a working tree, or an
  issue folder.
  Instrument: executed
  `grep -rni "work.record" skills/ guidelines/ agents/ floor.md` enumerates
  the match set; the content review classifies every match — true
  work-record references (each must name its stateless carrier), historical
  provenance comments (they state history, not prescriptions), and
  non-reference lexical coincidences (e.g. the verb phrase "work recorded"
  at `git-workflow-cleanup` rule 2) — and requires one consistent
  stateless mechanism across the six revised sections.
- **SC-3 (structural).** The record function survives elimination for every
  existing consumer, with staleness prevented by construction: the
  provenance parts are verified and stated at the moment of acting; the
  scope statement travels in dispatch prompts supplied verbatim at dispatch
  time; recorded reasons are stated in the surface that acts on them; the
  verify dispatch's primary artifact is the supplied scope statement. Each
  of the six revised sections names its carrier and the content it carries.
  Instrument: content review of the revised `work` §4 and outgrowth passage,
  `git-workflow-branch` trunk-freshness step (including its per-submodule
  clause) and rule 5, `implement` short-path rule, `version-manager` rule 7,
  `verify` §1, and `git-workflow-cleanup` description and rule 5 — each
  names its carrier; none directs a file.
- **SC-4 (structural).** The no-issue case resolves identically to the
  issue case — no repository-side record file in either branch, every
  consumer naming its carrier — and the no-new-machinery boundary ("never
  create an issue, or initialize an issue store, to satisfy provenance") is
  preserved in intent, as is the R-5 necessity gate.
  Instrument: content review of the revised consumer passages — no
  issue/no-issue split remains in any record prescription, every consumer
  names its carrier, and the boundary and gate statements are present in
  the revised deck text.

## Success-criteria table

| ID | Criterion | Class | Instrument |
|----|-----------|-------|------------|
| SC-1 | No deck text prescribes an agent-authored file in a repository's git directory | structural | executed grep sweep (zero matches) + fresh-context content review of the six revised sections |
| SC-2 | No deck text prescribes a dedicated work-record file on any surface; every reference names a stateless carrier | structural | executed grep sweep enumerating the match set + content review classifying every match |
| SC-3 | Record function survives for every existing consumer on stateless carriers, staleness prevented by construction | structural | content review of the six revised sections |
| SC-4 | Issue/no-issue cases resolve identically with no repository-side file; no-new-machinery boundary and R-5 necessity gate preserved | structural | content review of the revised consumer passages and boundary statements |

## Approach

Delete the work-record definition from `work` §4 and re-point every consumer
at its stateless carrier per R-2, in one change across all six cards. The
prior remedy candidate — relocating the record into the cycle's issue
record — is superseded: it moves the staleness failure mode rather than
removing it (a record file inside an issue folder is the same
persistent-state cruft class, one directory over), and the developer's
revision directive eliminates the file class, not one path form. The issue
store receives nothing new; on full-path cycles the spec artifact the
pipeline already produces carries scope, and the PR body already exists as
the cycle's persistent surface. The cleanup card loses its record-removal
step — nothing is left to remove, and the latent-residue failure mode
disappears with the mechanism. Where a card step genuinely lacks a carrier
for content it must hand forward, the gap is reported to the developer under
R-5 rather than papered over with a file.

## Out of scope

- Removal of the residue file `.git/work-record.md` in
  `NewsRx/hermes-ingest-pubmed` — a different repository, outside this spec's
  single-repo scope; the triage verdict classifies it as residue of an
  unauthorized mechanism, and it awaits the developer's explicit instruction
  naming that target.
- A general deck-governance process change requiring disclosure of
  consuming-repo side effects in merged deck-change summaries — the
  consultation gap the report's addendum records is context; any such
  process change is its own governance decision.
- Any change to the work card's path selection, authorization semantics, or
  pipeline stages — only the record mechanism's existence and its consumers'
  carriers move.

## Impact

- **Consumers:** every agent running the deck's work cycles in any
  repository — all six cards touch the record mechanism on every cycle that
  reaches them (branch creation, scope carrying, implementation decisions,
  version justification, verification dispatch, cleanup).
- **Risk:** low — instruction-text revision; no code, no build. The
  functional risk is a silently broken record function (mitigated by SC-3's
  consumer enumeration and the staleness-by-construction property each
  carrier carries) and a half-migrated deck (mitigated by SC-2's same-change
  rule). The residual behavioral risk — a dispatched reviewer losing the
  scope statement a file would have held — is bounded by R-2's supply-at-
  dispatch-time rule: the dispatching session holds the scope and includes
  it verbatim, so the reviewer receives current state, not a stored copy.
- **Blast radius:** the six cards named in R-3. No other agent-facing card
  references the work record (executed grep over the checkout's agent-facing
  instruction surfaces that exist — `skills/`, `guidelines/`, `agents/`, and
  `floor.md` — 2026-11-12; `commands/` no longer exists in the checkout,
  removed by #2490 stage 4d); one non-load-bearing descriptive comment in
  `tests-v2/behaviors/2557-sc17-supervised-polling.sh` mentions the work
  record and is not instruction text — it follows the revision only if its
  scenario text needs updating for accuracy. The cards' historical
  provenance comments state history, not prescriptions, and move only where
  the revision touches them.

> Full spec and plan artifacts: https://github.com/michael-conrad/.opencode/tree/issues-data/2734/
> Local artifacts: `.opencode/.issues/2734/`

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
