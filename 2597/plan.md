<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->

# Plan: .opencode#2597 — Local issue-record mirroring and the audit local-artifact gate

Derives entirely from `.opencode/.issues/2597/spec.md` (validated 2026-10-13, PASS
with zero findings). One item per SC. Target repo: the `.opencode` submodule; all
paths are relative to the submodule root. Deck edits touch `skills/` — the
implement cycle loads `skill-creator` governance before the first card edit, and
the ledger entry (Item 6) is that governance's admission record for this change.

Re-wording latitude per spec Design Decision 7: each item's GREEN states the
semantic elements that must land; the implementer writes them into the card's
own voice and structure, altering no other semantics.

## Item 1 — issues card: mirror-repair rule (SC-1)

- **Deliverable:** a new numbered rule in `skills/issues/SKILL.md` stating,
  in the card's store-lifecycle voice: on discovery that a remote issue's local
  record is absent, or that the issue's local-artifacts pointer does not resolve
  to the local folder it names — create the local record at the remote-assigned
  number via `local-issues create --number repo#N`, mirror the remote-tracked
  content into `{N}/`, and correct the remote body's pointer via
  `update --github`. The repair is fact work performed on discovery — never
  reported as a blocker or fail reason by itself. The rule cross-references
  ticket-state hygiene (§6) as the adjacent rule governing state divergence for
  an existing record, without duplicating its content.
- **RED:** `grep -c "mirror" skills/issues/SKILL.md` → the only mirror mentions
  are the creation-flow mirror (§2) and ticket-state hygiene (§6); no rule
  governs repairing an absent record. (Verified against live deck 2026-10-13.)
- **GREEN:** insert the rule in the numbered list after §6 (Ticket-state
  hygiene), renumbering subsequent rules if the card's structure requires.
- **Instrument:** read the card — all four SC-1 elements present (trigger,
  action with the exact tool invocation forms, fact-work statement, §6
  cross-reference); no duplicated hygiene text.

## Item 2 — issues card: creation-time pointer check (SC-2)

- **Deliverable:** inside §2 (Creation), a sentence stating: the local-artifacts
  pointer written into a remote issue body must resolve to the actual local
  folder at write time; an unresolvable pointer is a flow defect to fix in the
  same action, not a formatting choice.
- **RED:** §2 states the local mirror follows the remote filing but never binds
  the pointer written into the remote body to a resolvable local path — the
  fabricated-pointer defect class is ungoverned.
- **GREEN:** add the sentence to §2 (or integrate into the existing mirror
  sentence where the card's flow reads most naturally).
- **Instrument:** read §2 — resolution requirement and same-action correction
  both present; surrounding creation text semantically unchanged.

## Item 3 — spec card: authoring-time construction guarantee (SC-3)

- **Deliverable:** in `skills/spec/SKILL.md` §4 (Write and persist), two
  sentences: the remote body's local-artifacts pointer must resolve to the
  actual local folder at write time; and a mid-flow local write failure BLOCKs
  the flow — the remote body is never left carrying an unresolvable pointer.
- **RED:** §4 states the remote body and local `{N}/` flow but binds neither
  the pointer's resolvability nor a BLOCK on mid-flow local-write failure.
- **GREEN:** append the sentences to §4, integrated with the existing
  remote-first/local-mirror wording.
- **Instrument:** read §4 — resolution requirement and BLOCK-not-fabricate
  statement both present; the step's other content untouched.

## Item 4 — verify card: audit entry gate (SC-4)

- **Deliverable:** a new numbered point in `skills/verify/SKILL.md` stating,
  in the card's dispatch/verdict voice: an audit requires the audited artifact
  present at a verified local path, verified before the audit's substance
  begins; when the artifact is absent locally, the auditor performs the
  mirror-repair per the `issues` card and proceeds with the audit; absence of a
  local artifact is never a fail reason or halt ground by itself.
- **RED:** the verify card's nine points cover dispatch, churn, verdicts, and
  evidence provenance but never the audited artifact's local presence — the
  observed #2551 halt class is ungoverned.
- **GREEN:** insert the point adjacent to the criteria-invariance point (§8) —
  the audit-preconditions neighborhood — renumbering if needed.
- **Instrument:** read the card — all three SC-4 elements present; mechanism
  deferred to the issues card (no duplicated procedure text).

## Item 5 — plan card: consumer-side route-to-repair (SC-5)

- **Deliverable:** in `skills/plan/SKILL.md` §6 (Consume validated specs only),
  one clause: consuming a spec whose local record is absent routes through the
  `issues` card's mirror-repair before the plan work proceeds.
- **RED:** §6 binds plan items to the spec's SCs and the validation standards
  but never handles a spec whose local record is absent — the consumer-side
  moment is ungoverned.
- **GREEN:** append the clause to §6.
- **Instrument:** read §6 — the route-to-repair clause present; one clause, no
  mechanism duplication.

## Item 6 — deck-debt ledger admission entry (SC-6)

- **Deliverable:** a comment on the ledger issue `.opencode#2534` recording:
  the attic rule text and its source paths
  (`attic/skills/audit/tasks/spec-audit-investigator.md` Entry Criteria;
  `attic/skills/spec-creation/tasks/create.md` Steps 2–3), the #2490
  retirement, the observed failure (2026-10-13: `.opencode#2551` fabricated
  pointer + audit halt on fabricated fail reasons), and the placement
  decisions — issues, spec, verify, plan cards amended; work card excluded
  (it already states the stage-level principle).
- **RED:** the ledger carries no entry for this restoration — the #2490
  retirement of the mirroring/gate machinery is unrecorded.
- **GREEN:** `./.opencode/tools/local-issues comment --number .opencode#2534`
  with the admission entry (type: internal), after Items 1–5 land.
- **Instrument:** read the ledger's comments — the entry present with all
  required elements.

## Dependency order

Items 1–5 are independent card edits (each RED verifies the live pre-change
state; GREEN touches one card). Item 6 records the completed restoration and
runs last. Cumulative containment check after Item 6: the change touches only
the four SKILL.md paths and the ledger comment — no floor, routing, reference,
or test changes.

## Verification notes

All six SCs are structural; instruments are reads/greps against the edited
files, executable as written. No behavioral SCs (rationale in the spec's cost
frame). The implement cycle runs the RED checks before each GREEN, shows real
output as evidence, and the PR carries the executed evidence per
`git-workflow-pr`.
