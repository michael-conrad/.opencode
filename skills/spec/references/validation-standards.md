<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2550 -->

# Validation Standards

Criteria set for the spec card's validation dispatch — one fresh-context
reviewer reads a spec against this page and returns PASS or FAIL. These are
defect descriptions for reviewer judgment, not patterns to scan for: there are
no keyword lists, no trigger-word tables, and no scripted checks here. A
lexical check is gamed by rephrasing; judgment is not.

## Verdict contract

- **PASS** — the reviewer reports zero findings, and no caveat, concern, or
  note is attached to any criterion's verdict. A PASS with any disclosed
  observation is not a verdict.
- **FAIL** — any reported finding produces FAIL: an enumerated defect class
  below, or any other correction, imprecision, factual error, or gap affecting
  the artifact's correctness or its stated requirements. The verdict names
  each finding and its ground. A FAIL without named findings is not a verdict.
- **Findings are what the reviewer reports.** A substantive observation about
  the artifact is always reported as a finding — the non-finding-note
  disclosure path does not exist.
- The reviewer reports only findings affecting correctness or the stated
  requirements — the same anti-churn binding as the verify card's reviewer.
  Style preferences, phrasing taste, and hypothetical improvements are not
  findings.

## Defect classes

A criterion is defective when it exhibits any of the following:

1. **Invented requirement.** The criterion cannot be traced to a developer
   statement or an observed failure recorded in the spec's provenance — it
   encodes something nobody asked for. A criterion that is the direct
   remediation of the stated problem or observed failure is traceable; a
   property of the solution with no bearing on the stated problem is not.
   This is scope creep stated as a criterion.
2. **Untestable criterion.** No check exists that could show the criterion
   satisfied or violated: the criterion states a goal without any stated or
   derivable verification instrument, so completion would be asserted rather
   than demonstrated.
3. **Either/or criterion.** An alternative is presented as one requirement —
   the criterion is satisfied by A or by B, so a deliverable satisfying only
   one branch passes. A requirement that offers the implementer a choice
   between materially different outcomes is two criteria or an undecided
   design question, not one criterion.
4. **Ambiguous criterion.** Two reasonable readers produce two different
   understandings of what satisfies it, and the spec itself resolves neither.
5. **Misclassified evidence.** The criterion's verification instrument does
   not match its nature — a runtime effect verified by reading files, or a
   file fact verified only by a model run.
6. **Self-containment violation.** The spec does not read standalone:
   required content lives only in comments or discussion, superseded text
   survives alongside its replacement, or the body carries process or
   tracking content outside the footer allowlist.
7. **Trivially-true restatement.** The criterion restates existing behavior
   or a tautology, so it can never fail and verifies nothing.

## Bounded loop

FAIL → targeted revision of the named criteria → re-validate. One bounded
loop: a FAIL that persists after revision halts to the developer naming the
failing criteria — the validator does not negotiate criteria into passing,
and the loop is not retried indefinitely.

## Criteria invariance

This page is the deck's single validation criteria source. On-demand audits
of prior specs restate these criteria verbatim from this reference — an audit
never runs on a different or locally-authored bar. Changing the criteria set
is deck governance, never a dispatch-time edit.
