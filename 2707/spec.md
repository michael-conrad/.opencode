<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored feature request, filed 2026-11-02 at the developer's
     direction (chat, 2026-11-02 session); content is the developer's stated
     triage-to-spec conversion policy. Adjacent records: .opencode#2704 (lost
     triage→spec mandate — regression record), .opencode#2681 (worked in-place
     conversion precedent). Status: feature request, pre-triage — when triaged
     into work, this record converts in place into the governing spec, per the
     very policy it requests. -->

# Triaged bug reports convert in place into the first/only spec — new issues only when the report warrants multiple specs

## Problem

When a triaged bug report proceeds to work, the governing spec gets filed as a
separate issue while the original bug report stays open as a detached ticket.
Two tickets then describe one body of work with no record of which governs:

- the detached ticket keeps getting re-triaged or requested to be worked on,
- effort is duplicated across both records,
- the divergence between them produces confusion and defects — work planned or
  reviewed against a stale ticket, specs that disagree with the report that
  spawned them, and closure bookkeeping that never reconciles.

The developer's directive of 2026-11-02 states the defect class and the
required policy in one sentence:

> triaged bug reports are always updated to become proper specs, only new
> issues are filed if the bug report warrants multiple specs, but in either
> case, the original bug report is always converted into the first spec or
> only spec as appropriate. leaving bug reports detached from the actual spec
> leaves issue tickets that keep getting re-triaged or requested to be worked
> on and causes duplicated efforts, confusion, and defects.

## Requested policy

Triaged bug reports are always updated to become proper specs:

1. **In-place conversion.** The triaged bug report itself is updated to become
   a proper spec — the original report is always converted into the first spec
   or the only spec, as appropriate. The ticket's identity (number, thread,
   local `{N}/` record) carries into the spec; no separate spec issue is filed
   alongside it.
2. **New issues only for multi-spec warrants.** New issues are filed only when
   the triaged bug report warrants multiple specs. In that case the original
   bug report converts into the first spec and the further specs are filed as
   new issues linked to it (the sub-issue hierarchy per the `issues` card).
3. **No detached tickets.** The workflow never leaves a bug report detached
   from the spec that governs its work — after conversion, the record reads as
   the spec on both surfaces (remote tracker body and local store record),
   reconciled per the deck's record-consistency discipline, so re-triage and
   work requests land on the spec record, not on a stale pre-spec ticket.

## Requirements

- **R-1 — In-place conversion mandate.** The deck's triage discipline SHALL
  mandate that a triaged bug report is updated in place to become a proper
  spec: the original bug report is always converted into the first spec or the
  only spec, as appropriate, and no separate spec issue is filed alongside it.
- **R-2 — Multi-spec carve-out.** New issues SHALL be filed only when the
  triaged bug report warrants multiple specs; in that case the original bug
  report converts into the first spec and the further specs are filed as new
  issues linked to it.
- **R-3 — No detached bug reports.** The workflow SHALL leave no bug report
  detached from the spec governing its work: after conversion the record reads
  as the spec on both surfaces, so re-triage and work requests land on the
  spec record.

## Scope

The deck rule text that governs triage outcomes and the entry into spec
creation:

- `skills/issues/SKILL.md` — triage semantics (the closure-verdict-only path
  today; §5).
- `floor.md` — the scope/stage doctrine the triage path runs under.
- The spec/work cards — the spec-creation entry point a triaged report
  follows.
- `tests-v2/` — behavioral coverage for the conversion path.

The change is deck rule text and harness coverage — no tools, hooks, or
scripts. Deck text edits ride deck governance (the `skill-creator` admission
gate applies at implementation).

## Context and cross-references

- **.opencode#2704** records the adjacent regression: the deck conversion
  retired the `analyze-and-spec` triage→spec path with no successor, so
  triaged defect reports stall at closure triage. That retired path filed the
  fix spec as a **separate sub-issue** — the pattern this request replaces
  with in-place conversion. Restoration work under #2704 should follow this
  request's mechanics; the two records describe one pipeline gap from two
  sides (the lost mandate; the conversion shape the restored mandate must
  carry).
- **.opencode#2681** is the worked precedent: a filed bug report revised in
  place into its specification under the developer's directive, with title,
  labels, and body reconciled across both surfaces — the end state this
  policy makes the default.
- The deck's pipeline already holds the pieces this policy binds together:
  triage verdicts (`issues` card §5), the spec stage (`work`, `spec` cards),
  and record consistency across surfaces. The gap is the mandated, shaped
  conversion between them.

## Impact

- **Consumers:** every agent session the deck serves — any session that
  triages a bug report or files a spec for one.
- **Benefit:** removes the detached-ticket defect class — re-triage loops,
  duplicated specs, confusion about the governing record, and defects from
  work proceeding against a stale ticket.
- **Risk:** the conversion mandate over-applied to reports that warrant
  multiple specs — bounded by R-2's carve-out; and conversion performed as a
  fresh filing instead of an in-place update — bounded by R-1's "no separate
  spec issue" clause.
- **Blast radius:** deck rule text and `tests-v2/` scenarios; no tool, hook,
  or script changes. Every element reverses through branch history.

## Status

Feature request, pre-triage (`needs-approval`). Per the pipeline, triage and
the developer's stage naming decide what this record becomes; per this
request's own policy, a triage that proceeds to work converts this record in
place into the first spec rather than filing a separate one.
