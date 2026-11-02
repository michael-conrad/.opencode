<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored feature request, filed 2026-11-02 at the developer's
     direction (chat, 2026-11-02 session); converted in place into this governing
     spec on 2026-11-02 under the developer's dispatch "triage then spec audit
     .opencode#2707" — the record's own requested policy applied to itself, per
     the worked precedent .opencode#2681. Triage evidence:
     research/triage-2026-11-02.md. Adjacent records: .opencode#2704 (the lost
     triage→spec mandate — the regression this spec remediates; restoration work
     under #2704 follows this spec's mechanics), .opencode#2681 (the in-place
     conversion precedent whose mechanics this policy makes the default). -->

# [SPEC] Triaged bug reports convert in place into the first/only spec — new issues only when the report warrants multiple specs

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

Observed failures (verified 2026-11-02 against live surfaces; triage evidence:
`research/triage-2026-11-02.md`):

- **O-1 — triage semantics carry no work-entry conversion.** The live deck's
  only triage semantics are the closure-verdict path: `skills/issues/SKILL.md`
  §5 defines triage solely as the verified-resolved/moot closure verdict
  (self-triggering on completed or moot deliverables). A triage verdict that
  classifies a report as actionable work has no mandated continuation into
  spec creation — observed live on 2026-11-02 (#2704): a triaged defect report
  ended at the verdict report with no spec created and no live card requiring
  one.
- **O-2 — the retired conversion path has no successor.** The whole-deck
  conversion (tag `pre-rip`) retired the `analyze-and-spec` triage→spec path
  with no successor: `grep -rn "analyze-and-spec"` across `skills/`,
  `guidelines/`, `floor.md` returns zero hits as of 2026-11-02. The retired
  path filed the fix spec as a separate sub-issue — the detachment pattern
  this spec replaces with in-place conversion.
- **O-3 — the pipeline's triage→spec entry point is gone, not dormant.** The
  stale enforcement mappings (`tests-v2/test-enforcement.sh` lines 116, 143
  target the retired `issue-review` family) and the legacy fixtures
  (`behaviors/fixtures/setup/2241-sc7-analyze-and-spec-local-first.sh`,
  `behaviors/fixtures/issues/2249/spec.md`) point at a path no live card
  carries — remediation of these stale surfaces is #2704's restoration scope,
  not this spec's.

Root cause covered: the deck conversion retired the triage→spec conversion
mandate with no successor (#2704), leaving the triage semantics
closure-verdict-only — so triaged bug reports that proceed to work detach
from their governing spec by default.

## Scope

The deck rule text that governs triage outcomes and the entry into spec
creation, plus behavioral coverage:

- `skills/issues/SKILL.md` §5 — the triage semantics gain the work-entry
  conversion path beside the closure-verdict path: a triage verdict that
  classifies a triaged bug report as actionable work converts the report's
  record in place into the governing spec.
- `floor.md` — the scope/stage doctrine names the triage→spec conversion as
  an agent-owned stage transition. This surface is load-bearing for R-1's
  implementability: the floor's stage-boundary rule as written requires a
  developer token naming the destination stage for every stage crossing, so
  a conversion mandate that fires on triage without one contradicts the
  always-injected surface unless the doctrine names the path (the same
  floor-versus-card contradiction class #2681's R-3 remediated).
- The spec/work cards — the spec-creation entry point a triaged report
  follows: the converted record enters the spec stage as the spec artifact
  the spec card's discipline then governs.
- `tests-v2/` — behavioral coverage for the conversion path (the main path
  and the multi-spec boundary).

Out of scope:

- The stale `tests-v2/test-enforcement.sh` `issue-review` mappings (lines
  116, 143) and the legacy fixtures for the removed enforcement — #2704's
  restoration scope; this spec adds new conversion coverage, it does not
  remediate the stale surfaces.
- The closure-verdict triage semantics (verified-resolved/moot,
  self-triggering) — unchanged.
- Any tool, hook, plugin, or script outside the `tests-v2/` scenarios this
  spec orders — the change is deck rule text and harness coverage only (the
  record's own boundary: "no tools, hooks, or scripts").
- Extension of the conversion mandate beyond triaged bug reports — the
  directive names bug reports; enhancement and other record classes keep
  their existing entry paths.
- Deck-governance mechanics — the `skill-creator` admission gate is
  exercised at implementation, never changed by this work.

## Requirements

- **R-1 — In-place conversion mandate.** The deck's triage discipline SHALL
  mandate that, when a triaged bug report proceeds to work, the triaging
  agent updates the bug report's record in place to become a proper spec
  under the spec card's discipline: the original bug report is always
  converted into the only spec when the report warrants one spec, and into
  the first spec when it warrants more than one (per R-2) — and no separate
  spec issue is filed alongside it.
- **R-2 — Multi-spec carve-out.** New issues SHALL be filed by the agent only
  when the triaged bug report warrants multiple specs; in that case the
  original bug report converts into the first spec and the further specs are
  filed as new issues linked to the converted record (the sub-issue hierarchy
  per the `issues` card §4).
- **R-3 — No detached bug reports.** The workflow SHALL leave no bug report
  detached from the spec governing its work: after conversion the record
  reads as the spec on both surfaces — the local store record and the remote
  tracker (title, labels, and body reconciled per the deck's
  record-consistency discipline) — so re-triage and work requests land on
  the spec record, not on a stale pre-spec ticket.

## Success criteria

- **SC-1 (structural) (→ R-1).** The `issues` card's triage semantics state
  the work-entry conversion: actor (the triaging agent), trigger (a triage
  verdict classifying a triaged bug report as actionable work), action
  (in-place conversion of the report's record into the governing spec), and
  the no-separate-filing clause are each stated. *Instrument:* grep of
  `skills/issues/SKILL.md` for the mandate text; clean-room read-back
  confirms actor, trigger, action, and the no-separate-filing clause.
- **SC-2 (structural) (→ R-2).** The amended surfaces state the multi-spec
  carve-out: new issues are filed only when the report warrants multiple
  specs; the original converts into the first spec; further specs are new
  issues linked to the converted record. *Instrument:* grep + clean-room
  read-back on each surface carrying the carve-out.
- **SC-3 (structural) (→ R-3).** The no-detached-tickets mandate is stated:
  after conversion the record reads as the spec on both surfaces — the local
  store record and the remote tracker — reconciled per the deck's
  record-consistency discipline. *Instrument:* grep + clean-room read-back.
- **SC-4 (structural) (→ R-1).** The floor's scope/stage doctrine carries the
  conversion path: the triage→spec conversion and the spec-stage entry are
  agent-owned — no separate developer stage token gates the transition — and
  plan and implementation keep their existing developer gates. *Instrument:*
  grep of `floor.md` for the conversion-path clause; clean-room read-back
  confirms both halves (agent-owned transition; downstream gates unchanged).
- **SC-5 (structural) (→ R-1).** The spec/work cards' spec-creation entry
  accepts the converted record as the spec-stage artifact: the spec stage
  begins from the converted record, and the spec card's discipline
  (extraction, SC classification, validation) applies to it from there.
  *Instrument:* grep + clean-room read-back on each touched card.
- **SC-6 (behavioral) (→ R-1, R-3).** Main conversion path: in a session
  where a triaged bug report proceeds to work, the agent converts the report
  record in place into the governing spec — the record's title, labels, and
  body read as the spec on both surfaces — and files no separate spec issue.
  *Instrument:* a `tests-v2/behaviors/` scenario executed through the
  harness (`bash tests-v2/with-test-home opencode run`, per the
  `behavioral-testing` card — no grep or static-analysis substitute);
  clean-room evaluation asserts the in-place conversion and the
  no-separate-filing outcome.
- **SC-7 (behavioral) (→ R-2).** Multi-spec boundary: when the triaged report
  warrants multiple specs, the agent converts the original into the first
  spec and files the further specs as new issues linked to the converted
  record — not as detached tickets. *Instrument:* a `tests-v2/behaviors/`
  scenario executed through the harness, same instrument family; clean-room
  evaluation asserts the first-spec conversion and the linked further issues.
- **SC-8 (semantic) (→ R-1, R-2, R-3 composition).** A clean-room reader
  walking the scenario "a triaged bug report proceeds to work" from the
  amended surfaces alone reaches the defined outcome — in-place conversion,
  spec-stage entry under the spec card's discipline, no separate filing, no
  detached record — without an undefined halt or a contradiction between
  surfaces. *Instrument:* clean-room sub-agent walkthrough from the amended
  card texts alone; judged unambiguous and complete.
- **SC-9 (structural) (→ unchanged-behavior preservation).** Dependent-test
  currency: the closure-verdict triage path's existing behavioral coverage
  and the structural suites asserting the amended surfaces still pass with
  the change applied, and every agent-facing cross-reference the change adds
  or touches resolves. *Instrument:* executed `2561-sc1` behavioral scenario
  through the harness; executed
  `tests-v2/test-cleanroom-eval-contract.sh`,
  `tests-v2/test-skill-deck-completeness.sh`, `tests-v2/test-trunk-hook.sh`,
  and `./.opencode/tools/reference-integrity`, captured output.

## Approach

1. **Triage semantics (R-1, R-2, R-3).** The `issues` card §5 gains the
   work-entry triage outcome beside the closure-verdict outcome: two outcome
   classes — closure verdicts (existing, unchanged) and the work-entry
   conversion (new). The conversion follows the #2681 mechanics: title,
   labels, and body updated in place on the local store record, then
   reconciled to the remote tracker in the same workflow, so the record
   reads as the spec on both surfaces.
2. **Floor doctrine (R-1 implementability).** The floor's scope/stage
   doctrine gains the conversion-path clause: the triage→spec conversion and
   the spec-stage entry are agent-owned; plan and implementation keep their
   existing developer gates. The always-injected surface then states the
   same doctrine as the conditional card instead of contradicting it.
3. **Spec-stage entry point (R-1).** The spec/work cards' entry text accepts
   the converted record as the spec-stage artifact the spec card's
   discipline governs from there.
4. **Behavioral coverage (R-1, R-2, R-3).** Two scenarios per the
   `behavioral-testing` card's harness path: the main conversion path
   (SC-6) and the multi-spec boundary (SC-7). Each fails RED against the
   un-amended surfaces — the agent halts at the verdict report or files a
   separate spec issue — and passes GREEN after the deck text lands.
5. **Governance.** Deck text edits ride deck governance: the `skill-creator`
   admission gate applies at implementation. A substantive write to
   `floor.md` triggers the whole-card-on-touch conversion rule — the floor
   is already writing-discipline-converted (#2664/#2665), so the edit
   retains that conformance across the whole floor's normative prose.

Discarded alternative — restoring the retired `analyze-and-spec` path as it
stood (the fix spec filed as a separate sub-issue): rejected by the
developer's directive — the detachment pattern is the defect class being
removed, and conversion is in place.

## Impact

- **Consumers:** every agent session the deck serves — any session that
  triages a bug report or files a spec for one.
- **Benefit:** removes the detached-ticket defect class — re-triage loops,
  duplicated specs, confusion about the governing record, and defects from
  work proceeding against a stale ticket.
- **Risk — over-application:** the conversion mandate applied to reports
  that warrant multiple specs, suppressing warranted new issues. Bounded by
  R-2's carve-out and SC-7's boundary scenario.
- **Risk — fresh-filing conversion:** conversion performed as a new filing
  instead of an in-place update. Bounded by R-1's no-separate-filing clause
  and SC-6's clean-room assertions.
- **Blast radius:** `skills/issues/SKILL.md`, `floor.md`, the spec/work
  cards, the `tests-v2/` scenario set. No tool, hook, or script changes.
- **Dependent tests:** the closure-verdict triage path's behavioral coverage
  (`2561-sc1`) and the structural suites asserting the amended surfaces
  (SC-9).
- **Recovery:** deck text edits reverse through branch history; record
  conversions ride `issues-data` commits. Every element reverses.

> Full spec and plan artifacts: https://github.com/michael-conrad/.opencode/tree/issues-data/2707/

Artifacts for agents: `.opencode/.issues/2707/`.
