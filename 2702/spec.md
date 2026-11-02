# 2702 — validation/audit sessions discovering deliverable-already-on-trunk leave the ticket falsely open — no status-transition obligation

## Problem

A validation/audit session that discovers dated evidence that the owning
ticket's deliverable is already delivered on trunk records its verdict in
`{N}/audit/validation.yaml` and exits with the ticket left `open` — no
status transition, no reconciliation obligation anywhere in the deck.

Observed instance: .opencode#2648 (2026-11-02). Three fresh-context
spec-validation rounds verified the spec's delivery claims true (the R-1 fix
already on trunk via b71a8c1c4), yet #2648 stayed `open` until the developer
encountered the false-open state and asked about a PR.

Developer status semantics (stated 2026-11-02): `open` ⇒ pending work;
`closed` ⇒ no pending work. The deck never states these semantics — the
false-open state violates them silently.

## Research findings (2026-11-02, dispatched fresh-context research agent, high confidence)

1. Validation loop (verify SKILL.md §3–§4; spec validation-standards §Loop):
   records rounds in `{N}/audit/validation.yaml`; only exits are clean PASS
   and escalation. No rule maps a PASS-with-deliverable-on-trunk to a
   ticket-state transition. Obligation: absent.
2. Verified-resolved reconciliation exception (floor, added .opencode#2699):
   fires only on the developer naming the state or asking why the ticket
   remains open. Obligation: conditional only.
3. issues SKILL.md §5 Closure / triage path: same conjunctive
   developer-naming trigger ("self-triggering" label notwithstanding, the
   text retains the developer-naming condition). §6 Ticket-state hygiene
   fires only on local/remote divergence — an internally consistent
   false-open state is not divergence. Obligation: conditional/absent.
4. Tooling: capability exists unexercised — `local-issues update --status`
   and `local-issues close --reason completed`. The gap is rule-level, not
   tooling-level.
5. Status semantics + `needs-approval` label lifecycle: defined nowhere in
   live deck content; only definitions live in `attic/` (pre-rip content:
   attic/skills/issue-operations-core/tasks/creation.md,
   attic/skills/issue-review/tasks/triage.md,
   attic/skills/gh-cli/tasks/project-management.md — and there only GitHub
   project-board statuses).

## GAP statement

Missing rule (essence): "When a validation/audit cycle's executed evidence
independently verifiably shows the owning ticket's deliverables complete on
trunk (no pending work), the agent running the session reconciles the ticket
— `local-issues close --reason completed` or `update --status <triage
state>` plus remote-tracker reconciliation per the issues card — in the same
workflow, without waiting for the developer to name the state." Without it,
the loop's exits pass beside the status field, no hygiene rule fires, and
the developer-facing trigger never arrives because the developer was never
told anything obligates the agent to tell them.

## Requirements (summary; remote body is fuller)

- R-1: evidence-backed deliverable-on-trunk from a validation/audit cycle
  SHALL trigger same-workflow ticket reconciliation (closure with
  completed-reason verdict, or equivalent triage status) + remote
  reconciliation + recorded verdict grounds.
  - Instrument: a validation/audit run against a trunk-delivered ticket
    ends with the local record closed/triage-updated and remote state
    matching.
- R-2: the deck SHALL state ticket-status semantics (`open` ⇒ pending work,
  `closed` ⇒ no pending work) and SHOULD define `needs-approval` lifecycle.

## Impact

- Consumers: every validation loop and audit/triage session.
- Near-miss rules that do not fire: floor verified-resolved exception
  (developer naming), issues §6 (divergence).
- Blast radius: deck content only (verify card, validation-standards,
  issues card, and/or floor.md); deck-governance card governs admission.

## Disposition of this filing's own subject ticket

.opencode#2648 was reconciled to the verdict in this session (2026-11-02):
triage-verdict comment recorded, closed locally (`completed`) and remotely,
`needs-approval` removed there.
