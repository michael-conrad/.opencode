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
     research/triage-2026-11-12.md. -->

# [SPEC] Relocate the work-record mechanism out of repository git directories to the cycle's issue record

## Problem

During a spec-stage work cycle in `NewsRx/hermes-ingest-pubmed` (2026-11-12),
the executing agent created `.git/work-record.md` inside the consuming
repository's own git directory — the path
`git rev-parse --git-path work-record.md` resolves to — exactly as the deck's
`work` card §4 prescribes. The developer (repo owner) discovered the file
during an owner audit and judged the mechanism itself a defect: an agent
writing an agent-authored file into a consuming repository's `.git/` directory
is an unwanted intrusion, independent of the file's content.

The developer's statement on record (2026-11-12): *"no such work-record file
was ever requested or authorized to be created or used by the developer."*

`.git/` is git's own operational state (refs, hooks, worktrees, internal
scratch). A developer auditing their repository does not expect agent-authored
files there; discovery of one reads as an intrusion. The file is invisible to
`git status` — invisible to the owner until they look inside `.git/` itself —
and the mechanism's only cleanup is a future session remembering a
cleanup-card step: a latent-residue failure mode.

Provenance of the mechanism (verified against live upstream history
2026-11-12, twice — the report's addendum and this triage's independent
re-check; see `research/triage-2026-11-12.md`):

- The mechanism is a pure addition: the work card immediately before the
  #2657 cycle carried no work record
  (`git show 10711d95^:skills/work/SKILL.md` — zero matches).
- The `.git` location was chosen inside the #2657 spec/plan cycle (plan
  revisions `10711d95`, `e32a070a`, 2026-10-23) and landed via commit
  `ac5c4407` (2026-10-31), carried by PR #2693, merged 2026-11-01T02:47:51Z
  on the `michael-conrad` account.
- The merged PR body does not disclose the write location (zero matches for
  "work record" / "git directory" / "git-path" / ".git").
- The driving issue `.opencode#2657` carries zero comments — no consultation
  trail.

## Root cause

The work record's `.git/` residency entered the deck through the #2657 cycle
without stakeholder consultation and without disclosure of its consuming-repo
side effect in the merged change summary. The cause-level surface is the
deck's own instruction text: as long as a card prescribes the
git-directory-resident path, every work cycle following the deck reproduces
the intrusion.

## Requirements

- **R-1** — The deck's agent-facing instruction surface (`skills/`,
  `floor.md`) SHALL prescribe no agent-authored file — including the work
  record — inside any repository's git directory: no
  `git rev-parse --git-path`-resolved record path, no `.git/`-resident record
  path, and no prose locating the record (or any agent-authored scratch file)
  in a repository's git directory.
- **R-2** — The work record's content — the provenance (verified trunk tip,
  branch, base tip, and issue) and the scope statement (path taken, criteria
  that selected it, what changes, what "done" is checked against, what is out
  of scope, order of work, recorded departure reasons) — SHALL be prescribed
  at a location the repository owner sanctions. The triage-weighed home is the
  cycle's issue record: the local store's issue folder on the `issues-data`
  branch where the repository holds a store; the remote tracker's record where
  it does not.
- **R-3** — Every card referencing the work record SHALL be revised in the
  same change, agreeing on the one relocated home: `work` (§4 and the
  short-path outgrowth passage), `git-workflow-branch` (trunk-freshness step
  and rule 5), `implement` (short-path inline default), `verify` (§1
  dispatch), `git-workflow-cleanup` (description and rule 5). No card is left
  referencing a git-directory-resident record or a divergent location.
- **R-4** — The record's consumers SHALL continue to function after
  relocation: the short-path outgrowth extension (`work`), the implement
  card's scoped-dispatch-reason recording, and the verify card's short-path
  primary artifact, which the dispatch can address by path.
- **R-5** — For work with no issue record, the deck SHALL prescribe no
  repository-side record file; the no-issue provenance (branch, base tip) is
  served by the PR-preparation surface and git's own evidence, preserving the
  existing boundary "never create an issue, or initialize an issue store, to
  satisfy provenance."

## Success criteria

All criteria are structural: the deliverable is the deck's instruction text,
and each criterion's satisfaction is decidable from the changed text. The
runtime effect — agents following the deck no longer write into `.git/` —
follows from the content criteria; the deck's text is the lever the change
owns. Instruments run over the deck checkout (the `.opencode` repository).

- **SC-1 (structural).** The deck's agent-facing instruction surface
  prescribes no work record — and no other agent-authored file — located
  inside a repository's git directory.
  Instrument: executed `grep -rn "git-path work-record" skills/ floor.md` and
  `grep -rn "\.git/work-record" skills/ floor.md` → zero matches; plus a
  fresh-context content review of the five revised card sections confirming
  no prose form locates an agent-authored file in a git directory. (The grep
  covers the mechanical path forms; the review covers rephrasing.)
- **SC-2 (structural).** Every card that references the work record references
  the same relocated home, and no card references a git-directory-resident
  record or a divergent location.
  Instrument: executed `grep -rni "work.record" skills/ floor.md` — every
  match's surrounding text names the relocated home; content review of the
  five revised sections confirms one consistent mechanism.
- **SC-3 (structural).** The record function survives relocation for every
  existing consumer: the provenance parts (verified trunk tip, branch, base
  tip, issue) and the scope statement remain prescribed at the sanctioned
  home; the short-path outgrowth extension, the implement card's
  dispatch-reason requirement, and the verify card's short-path primary
  artifact each continue to operate against it.
  Instrument: content review of the revised `work` §4 and outgrowth passage,
  `git-workflow-branch` trunk-freshness step and rule 5, `implement`
  short-path rule, and `verify` §1 — each consumer's text names the relocated
  home with its function intact.
- **SC-4 (structural).** The no-issue case resolves without a repository-side
  record file: the revised `git-workflow-branch` rule 5 states where the
  no-issue provenance lives (the PR-preparation surface and git's own
  evidence) and preserves the no-new-machinery boundary in intent.
  Instrument: content review of the revised rule 5 text.

## Success-criteria table

| ID | Criterion | Class | Instrument |
|----|-----------|-------|------------|
| SC-1 | No deck text prescribes an agent-authored file in a repository's git directory | structural | executed grep sweep (zero matches) + fresh-context content review of the five revised sections |
| SC-2 | All work-record references agree on the one relocated home | structural | executed grep sweep over all work-record matches + content review |
| SC-3 | Record function survives for every existing consumer (provenance parts, scope statement, outgrowth extension, dispatch-reason recording, verify short-path artifact) | structural | content review of the five revised sections |
| SC-4 | No-issue case resolves without a repository-side record file, preserving the no-new-machinery boundary | structural | content review of revised `git-workflow-branch` rule 5 |

## Approach

Relocate the work record's content into the cycle's issue record (candidate 1
from the report, weighed in `research/triage-2026-11-12.md`): the provenance
and scope statement are issue-tracking metadata and belong with the cycle's
other artifacts on the `issues-data` branch. The store is agent-owned
workspace under the deck's own governance (the floor's issues-data exception);
writes go through the `local-issues` tool; nothing lands in the working tree
or `.git/`. Where no issue record exists, no record file is prescribed at all
(R-5). The `verify` dispatch names the relocated path; the cleanup card's
record-removal step becomes unnecessary for the record — store artifacts
follow the store's own lifecycle. Exact mechanics (the record's file naming
inside the issue folder versus fields of the record itself) are plan-stage
decisions bounded by R-1 and R-2.

## Out of scope

- Removal of the residue file `.git/work-record.md` in
  `NewsRx/hermes-ingest-pubmed` — a different repository, outside this spec's
  single-repo scope; the triage verdict classifies it as residue of an
  unauthorized mechanism, and it awaits the developer's explicit instruction
  naming that target.
- A general deck-governance process change requiring disclosure of
  consuming-repo side effects in merged deck-change summaries — the
  consultation gap the report's addendum records is context; any such process
  change is its own governance decision.
- Any change to the work card's path selection, authorization semantics, or
  pipeline stages — only the record's location and lifecycle move.

## Impact

- **Consumers:** every agent running the deck's work cycles in any repository
  — the work record is touched by all five cards on every cycle (branch
  creation, scope recording, implementation decisions, verification dispatch,
  cleanup).
- **Risk:** low — instruction-text revision; no code, no build. The functional
  risk is a silently broken record function (mitigated by SC-3's consumer
  enumeration) and a half-migrated deck (mitigated by SC-2's same-change
  rule).
- **Blast radius:** the five cards named in R-3; no other deck surface
  references the work record (verified by executed grep, 2026-11-12).

> Full spec and plan artifacts: https://github.com/michael-conrad/.opencode/tree/issues-data/2734/
> Local artifacts: `.opencode/.issues/2734/`

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
