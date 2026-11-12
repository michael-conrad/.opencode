# Validation record — .opencode#2734 revised spec (2026-11-12)

Revision: developer directive 2026-11-12 — tracking files of this class are a
defect category (stale state → unauthorized work from bit-rotted items);
remedy is elimination, not relocation. Spec revised in place: record-file
mechanism eliminated on all surfaces; content carried on stateless carriers
(live verification + PR body for provenance, dispatch prompts / session
state for scope, act-time surfaces for recorded reasons); R-5 necessity gate
added.

- Round 1 — FAIL, 1 finding: SC-1's "no other agent-authored file" prong
  exceeded its instrument (review scoped to six sections; greps
  work-record-specific only). Remediated: SC-1 instrument extended to a
  fresh-context content review over the full agent-facing surface
  (`skills/`, `guidelines/`, `agents/`, `floor.md`) for git-directory-
  residency prescriptions; SC table row updated.
- Round 2 — **PASS, zero findings** (fresh-context, session ses_e2ef84a83ffew8tCUdSspmHvob).
  Standards sweep clean: consistency, testability, SC subject matter,
  self-containment, traceability both directions, scope/home containment,
  current-state claims verified against the live checkout, blast radius,
  causal sufficiency.

Awaiting developer approval gate before plan.
