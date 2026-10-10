---
number: 1228
title: "[PLAN] Forbid workflow-step skipping in the implement card"
parent_spec: 1228
created: 2026-10-09
---

# Plan: Forbid workflow-step skipping in the implement card

**Spec:** `.opencode#1228` (revised; validated PASS; developer-approved for PR)

## Item structure note

SC-1 through SC-4 are facets of one atomic deliverable — a single appended rule
in `.opencode/skills/implement/SKILL.md`. Splitting them into separate
RED/GREEN cycles would stage the same sentence four times, which the plan
card's needs-based sizing forbids. One item carries all four SCs; each SC's
verification instrument runs against the finished append.

## Item 1 — append workflow-fidelity rule to the implement card

**Traces to:** SC-1, SC-2, SC-3, SC-4

**Deliverable:** `.opencode/skills/implement/SKILL.md` gains rule 10 (workflow
fidelity) appended after rule 9, carrying the spec's four content elements and
following its recommended wording (final wording passes the `skill-creator`
admission gate).

**Preconditions:** feature branch exists in the `.opencode` submodule before
the first file modification; the admission gate runs before the edit.

**RED (failing assertions against current behavior):**

- `grep -c "redundant or unnecessary" .opencode/skills/implement/SKILL.md`
  returns 0 — no rule names the rationalization (SC-1 fails today)
- the card's numbered rules end at 9 — no rule carries the workflow-fidelity
  content (SC-1, SC-2, SC-3 have no carrier)

**GREEN:**

- Append rule 10 after rule 9 with the four content elements: (a) names the
  rationalization — a step appearing redundant or unnecessary is not grounds
  to skip, compress, reorder, or defer it; (b) names the pre-implementation
  checklist, the RED/GREEN chain, the post-implementation steps, and the
  implementation-workflow reference; (c) routes steps that cannot complete to
  the escalation path (stop the cycle / report) rather than silent omission;
  (d) states the cost rationale (an extra step is negligible against a skipped
  one). Rules 1–9 untouched.

**Verification instruments:**

- SC-1: the appended rule names "redundant"/"unnecessary" and forbids skip,
  compress, reorder, and defer (grep the rule block)
- SC-2: the rule names the pre-implementation checklist, the RED/GREEN chain,
  the post-implementation steps, and the implementation-workflow reference
  (grep the rule block)
- SC-3: the rule names the escalation path as the alternative to skipping
  (grep "escalation" in the rule block)
- SC-4: `git diff` shows exactly one appended numbered rule; no existing line
  modified or removed

**Commit:** one atomic commit on the feature branch, message per repo
convention, referencing `.opencode#1228`.
