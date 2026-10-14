<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2601; spin-bounded loop, .opencode#2606 -->

# Plan Validation Standards

Criteria set for the plan card's validation dispatch — one fresh-context
reviewer reads a plan against this page and returns PASS or FAIL. These are
defect descriptions for reviewer judgment, not patterns to scan for: no
keyword lists, no trigger-word tables, no scripted checks. A lexical check is
gamed by rephrasing; judgment is not.

## Defect classes

A plan is defective when it exhibits any of the following:

1. **Item coverage, either direction.** Every success criterion in the spec
   is covered by at least one plan item, and no plan item lacks a trace to a
   spec criterion. An SC with no item means the requirement silently goes
   unimplemented; an item with no SC is scope creep in plan form. Both are
   findings.
2. **Broken or implicit ordering.** The items' dependency order is not
   explicit, or the stated order contains a cycle — an item that depends on
   a later item for its RED or GREEN to run. Execution order must be
   followable from the plan alone.
3. **Unreal instrument.** A stated verification instrument is not runnable
   as written — it names a command that does not exist, a check the
   environment cannot perform, or a "verification" that is really prose
   recall. An instrument nobody can run verifies nothing.
4. **Scope discipline violation.** A plan item exceeds the spec's stated
   scope — it changes behavior the spec does not call for, or bundles work
   the spec explicitly excluded. The plan derives from the spec; it never
   enlarges it.
5. **Internal inconsistency.** Two parts of the plan disagree: an item's
   GREEN contradicts another item's assumption, the ordering section and
   the item bodies tell different stories, or the plan's stated approach
   conflicts with the spec's design decisions.
6. **Incomplete derivation.** The plan does not determine the implementation:
   an item states a deliverable but leaves how to build it undecided, or a
   decision the implementation needs is deferred to no stated owner.
7. **Untestable item.** An item's RED cannot fail against the current state
   as described — the assertion would pass before any change, so the cycle
   demonstrates nothing.
8. **Escape hatches.** Language that licenses the implementer to short-circuit
   an item: a qualifier that makes the deliverable evadable, or an item
   written so that any outcome satisfies it.
9. **Feasibility.** The plan references files, functions, libraries, or
   capabilities that do not exist, or sequences work against surfaces its
   own RED steps show are absent.
10. **Item atomicity.** Each plan item is one concern: an item that bundles
    multiple independently verifiable changes cannot be independently
    verified, committed, or reverted, and its RED demonstrates nothing
    about which bundled change fixed what. Bundled work decomposes into
    items, each with its own cycle.
11. **Broken grain.** An item is mis-sized in either direction: so small
    it is bookkeeping — a step that produces no verifiable change and only
    narrates work — or so large it hides decisions, bundling choice points
    that should have been resolved before the item was written. Grain is
    judged by whether each item can be completed, checked, and corrected
    without disturbing the plan around it.
12. **Instrument-nature mismatch.** The item's verification instrument is
    not merely runnable but of the right kind: a criterion whose failure
    exists only at runtime requires a runtime instrument, and a file-fact
    criterion is verified by a fact check. A plan whose verification
    instructions accept reading files where behavior is claimed verifies
    nothing, however runnable the check is.
13. **Approach divergence.** The plan implements the spec's chosen
    approach: no strategy substitution, no phase the spec requires
    silently omitted, no goal drift between what the spec decided and
    what the plan builds.
14. **Surface coverage.** The set of files and surfaces the plan touches
    matches the spec's affected set in both directions — a file the spec
    names that no item touches is an uncovered surface; a file an item
    modifies that the spec never accounts for is undeclared blast radius.
15. **Safety.** Failure modes that could cause irreversible harm are
    unaccounted for: an item performs destructive operations without a
    rollback step, or the plan's order creates a data-loss window the
    spec's safety criteria do not cover.

## Verdict contract

- **PASS** — the reviewer reports zero findings, and no caveat, concern, or
  note is attached to any item's verdict. A PASS with any disclosed
  observation is not a verdict.
- **FAIL** — any reported finding produces FAIL: an enumerated defect class
  above, or any other correction, imprecision, factual error, or gap
  affecting the plan's correctness or its stated requirements. The verdict
  names each finding and its ground. A FAIL without named findings is not a
  verdict.
- The reviewer reports only findings affecting correctness or the stated
  requirements — the same anti-churn binding as the verify card's reviewer.
  Style preferences, phrasing taste, and hypothetical improvements are not
  findings.

## Loop

FAIL → revise the named findings in the plan in place → re-validate. The
revise → re-validate cycle repeats until a verdict with zero findings.
Findings are never negotiated away — each revision genuinely fixes every
named finding.

Each cycle, the agent running the loop judges — never a script — whether the
loop is spinning: findings recurring or reshuffling without genuine resolution
relative to the remediation performed. On spin, the revision step moves up a
level: diagnose the cause and attempt higher-level fixing of it —
plan-level structural revision such as breaking up a composite item, splitting
an over-fat plan, resolving a spec conflict the plan inherited, restructuring
into atomic work units, or re-evaluating the approach — and the loop continues
on the revised plan. These cause classes are judgment examples — exemplary and
open, never a closed checklist.

Escalation to the developer fires when spin persists after genuine
higher-level fixing attempts, or when the validation cannot reach a
zero-finding verdict by revision. The escalation carries the specific
findings, the suspected cause class(es), the root cause, what was tried, and
what is needed to resolve them. Escalation and the clean PASS are the loop's
only exits.

## Criteria invariance

This page is the deck's single plan-validation criteria source. On-demand
audits of prior plans restate these criteria verbatim from this reference —
an audit never runs on a different or locally-authored bar. Changing the
criteria set is deck governance, never a dispatch-time edit.
