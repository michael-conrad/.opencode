# Plan — .opencode#2702 (evidence-backed same-workflow ticket reconciliation)

Source spec: `.opencode/.issues/2702/spec.md` (R-1, R-2). Scope: deck content only.

## Item 1 (R-1) — issues §5 triage path: agent-discovered evidence trigger

- **Deliverable:** `.opencode/skills/issues/SKILL.md` §5 gains a sentence stating
  the self-triggering path fires not only when the developer names the
  state: when an agent-run validation or audit cycle's executed evidence
  independently verifiably shows the owning ticket's deliverables complete on
  trunk (no pending work), the agent running that session reconciles the
  ticket — evidence-backed triage verdict, local closure/state update,
  remote-tracker reconciliation — in the same workflow, recording the verdict
  grounds, without waiting for the developer. Closure-to-tidy-up prohibition
  and the executed-evidence bar remain untouched.
- **RED:** the loop's only exits (validation-standards §Loop) and issue §5's
  triage trigger carry no rule mapping session-discovered evidence to a
  status transition — grep for "developer names that state" in
  `issues/SKILL.md` confirms the conjunctive-only trigger.
- **GREEN:** the added sentence.
- **Instrument:** grep the edited file for the new trigger sentence;
  `reference-integrity` tool run stays green; re-read §5 in full to confirm
  the closure bar sentence is unmodified.

## Item 2 (R-1 routing) — validation loop exit names the reconciliation obligation

- **Deliverable:** `.opencode/skills/spec/references/validation-standards.md`
  §Loop gains one short paragraph: a validation cycle whose executed evidence
  shows the owning ticket's deliverables already delivered on trunk does not
  merely exit — the cycle triggers the issues card's §5 reconciliation
  obligation for the owning issue in the same workflow (route to that rule,
  no restatement of its mechanics).
- **RED:** §Loop's exits list (clean PASS, escalation) passes beside the
  ticket-status field entirely — grep confirms no mention of the owning
  ticket's state in the exit path.
- **GREEN:** the added paragraph, in `Read [the issues skill](../issues/SKILL.md)`
  canonical link form.
- **Instrument:** grep for the new paragraph; reference-integrity run green
  (the link resolves).

## Item 3 (R-2) — ticket-status semantics in the issues card

- **Deliverable:** `.opencode/skills/issues/SKILL.md` gains a status-semantics
  sentence (in §5 or its own short §5 preamble): `open` ⇒ the ticket has
  pending work; `closed` ⇒ no pending work. Plus a `needs-approval` lifecycle
  sentence (SHOULD per spec): the label marks a ticket whose content awaits
  developer approval and is removed when that content is approved or
  superseded — it never marks a completed deliverable.
- **RED:** `grep -i "needs-approval"` and "pending work" across live deck
  content returns definitions nowhere (store-only/attic-only).
- **GREEN:** the two sentences.
- **Instrument:** grep on the edited card for both sentences.

## Ordering

Items run in the listed order: Item 1 is the primary rule change; Item 2's
routing paragraph points at the §5 rule Item 1 creates (its GREEN reads the
amended §5); Item 3 is independent of 1–2.

## Subject-ticket note

R-1's own instrument against #2702 is N/A before merge (the deliverables land
only with the merged PR); the store record states this N/A line.

## Validation

- **Deck-governance admission gate (skill-creator)** runs for Items 1–3
  before any deck file edit — the gate's standards bind the content written.
- Plan validation standards self-pass + fresh-context dispatch before implement.
- Post-implement: reference-integrity tool; grep instruments above; verify
  dispatch — verdict PASS or remediation loop.