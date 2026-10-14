<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2550; criteria-depth restoration, .opencode#2601 -->

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
5. **Incapable instrument.** The criterion's verification instrument could
   not in principle detect the criterion's failure: an instrument that
   answers a weaker question than the criterion asks produces no evidence
   for it. Checking that a thing exists cannot verify what the thing says;
   matching a pattern cannot verify that meaning was conveyed; reading an
   artifact cannot verify behavior that only exists at runtime. The
   instrument must be able to observe the failure the criterion guards
   against, or the criterion is unverified regardless of how the check
   comes out.
6. **Self-containment violation.** The spec does not read standalone:
   required content lives only in comments or discussion, superseded text
   survives alongside its replacement, or the body carries process or
   tracking content outside the footer allowlist.
7. **Trivially-true restatement.** The criterion restates existing behavior
   or a tautology, so it can never fail and verifies nothing.

## Analysis families

Beyond the per-criterion classes above, the reviewer judges the spec as a
whole against these failure shapes. A spec can satisfy every criterion
individually and still be defective at one of these levels; each family is a
judgment call about the artifact's substance, not a pattern to scan for.

- **Traceability, both directions.** Every success criterion traces to a
  stated requirement or an observed failure, and every stated root cause is
  covered by at least one criterion. An orphan criterion — one answering to
  nothing the developer said — is a finding; so is a root cause the criteria
  never test.
- **Causal sufficiency of the solution.** The spec's chosen approach follows
  from its stated root causes: every element of the fix answers to at least
  one cause the spec states, and the stated causes collectively call for
  the approach taken. A solution element no stated cause accounts for is
  scope creep arriving by another route; a stated cause the approach
  silently ignores breaks the chain between problem and fix.
- **Problem fit.** The spec solves the problem it states: the intent
  statement and the criteria describe the same defect, the stated root
  cause and the chosen fix aim at the same thing, and a reader who
  implemented every criterion as written would find the stated problem
  actually solved. An intent section that promises one thing while the
  criteria deliver another, or a diagnosis and a fix that point in
  different directions, is a finding even when every individual criterion
  is well-formed. The same family bounds what evidence can show: a
  deliverable that passes every criterion demonstrates code-matches-spec,
  never spec-matches-problem — spec correctness is judged by review
  against the problem, not by implementation success.
- **Fabricated claims.** A claim asserted without source evidence behind it:
  a current-state assertion never checked against the artifact or code it
  describes, or a negation claim ("nothing does X") whose exhaustiveness was
  never verified. A claim the writer could not have verified at write time
  is a finding regardless of whether it happens to be true.
- **Internal contradiction.** Two sections of the spec disagree — explicitly
  stated requirements that conflict, requirements that contradict each other
  in effect though not in words, or a scope statement that excludes what the
  criteria include (or the reverse).
- **Escape hatches.** Language that licenses the implementer to short-circuit
  the requirements: a qualifier that makes a hard requirement evadable, an
  "as appropriate" that hands the decision to the party being constrained,
  or a criterion written so that any outcome satisfies it.
- **Feasibility.** The spec references files, functions, libraries, or
  capabilities that do not exist in the codebase or environment it targets,
  or states a set of criteria that are each satisfiable alone but jointly
  impossible. A requirement built on a nonexistent surface cannot be
  implemented as written; a criterion set with no satisfying assignment
  cannot be satisfied at all.
- **Gap analysis.** Implicit preconditions the spec relies on without
  stating, and boundary conditions the criteria never exercise. The change
  may be correct on the stated path and still fail on the unstated one the
  spec silently assumes. The same family covers absence: prohibitions the
  stated problem implies but no criterion states — a requirement of
  "must not happen" is as verifiable as a requirement of behavior — and
  unchanged behavior the change puts at risk but no criterion preserves,
  which is how a fix ships with a silent regression.
- **Scope narrowness.** The spec fixes a symptom where its own analysis
  points at a cause, demands more than the minimum viable fix for the stated
  problem, or leaves a systemic implication of the change unaddressed when
  the problem statement covers it.
- **Research adequacy.** Alternatives bearing on the design were not ruled
  out — the spec commits to an approach without evidence the obvious
  alternatives were weighed — or claims about the current state of the code
  were made without verifying them against the code as it stands now.
- **Blast radius.** The change's impact enumeration is incomplete: affected
  consumers or dependents of what the change touches are unaccounted for,
  or non-code surfaces the change reaches — cross-references, tests,
  documentation — are missing from the plan of record.
- **Cross-reference sufficiency.** A claim cites a source the source does
  not actually support, or a load-bearing claim — one the spec's conclusions
  depend on — is left uncited.
- **Decomposition.** Judged at the criteria-set level: each criterion is
  atomic (one requirement, not several bundled so partial satisfaction
  passes), delivers a single deliverable, is binary verifiable (its
  satisfaction or violation is decidable from a check's outcome, not a
  reader's interpretation), is viable as a PR-gate item, carries no more
  ceremony than the change needs, and is not already covered by a prior
  criterion.
- **Safety.** Failure modes that could cause irreversible harm are
  accounted for: destructive operations without rollback paths, data-loss
  scenarios, irreversible operations without safeguards. A spec whose
  change can destroy state and says nothing about recovering from that
  destruction is defective here.

## Loop

FAIL → revise the named findings in the artifact in place → re-validate. The
revise → re-validate cycle repeats until a verdict with zero findings.
Findings are never negotiated away — each revision genuinely fixes every
named finding. Escalation to the developer fires only when the audit cannot
reach a zero-finding verdict by revision: a finding persists after genuine
remediation, or findings continue to surface across iterations without
converging. The escalation carries the specific findings, their root cause,
and what is needed to resolve them. Escalation and the clean PASS are the
loop's only exits.

## Criteria invariance

This page is the deck's single validation criteria source. On-demand audits
of prior specs restate these criteria verbatim from this reference — an audit
never runs on a different or locally-authored bar. Changing the criteria set
is deck governance, never a dispatch-time edit.
