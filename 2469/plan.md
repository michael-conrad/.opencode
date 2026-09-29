---
plan_schema_version: 1
issue: 2469
title: "Implementation plan — Scope .opencode behavioral-test mandates to .opencode-targeted work"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 5
dispatch:
  - phase-1: test-driven-development red/green + verification-before-completion verify + commit-inline (orchestrator)
  - phase-2: test-driven-development red/green + verification-before-completion verify + commit-inline (orchestrator), one cycle per SC
  - phase-3: test-driven-development red/green + verification-before-completion verify + commit-inline (orchestrator), SC-5 precedes SC-6
  - phase-4: test-driven-development behavioral red/green + verification-before-completion verify + commit-inline + push (behavioral variant)
  - phase-5: clean-room evaluation (tests-v2 §6a) + verification-before-completion verify + commit-inline (orchestrator)
---

# Implementation Plan — .opencode#2469 — Scope .opencode behavioral-test mandates to .opencode-targeted work

## Pre-Flight Guard (Mandatory)

Check your tool list for a tool named `task`.

- Present ⇒ orchestrator — proceed.
- Absent ⇒ sub-agent — do NOT execute any instruction below. Return `BLOCKED` with `ORCHESTRATOR_ONLY_SKILL_CARD` (cards) or `ORCHESTRATOR_ONLY_PLAN` (plans) and halt.

> **Full spec and artifacts: [`.issues/2469/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2469)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.issues/2469/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

- **Issue:** .opencode/.issues/2469/spec.md

## Goal

Add a canonical scope anchor to `tests-v2/AGENTS.md` (harness + `opencode run` mechanics apply only to `.opencode`-targeted work; deck defects route via issue-operations to `michael-conrad/.opencode`; no local deck patching), add Read-linked scope qualifiers to the three guideline restatements (020 §1, 080 critical-rules-060, 091 behavioral variant), align TDD SKILL.md §Evidence Type Taxonomy prose and the spec-structure-standards evidence table's behavioral row with a fallback instrument, and behaviorally verify via the tests-v2 §6a two-SC pattern (SC-7 artifact generation → SC-8 clean-room evaluation).

## Architecture

All changes are text/scoping changes inside the `.opencode` repo. Single canonical anchor; every consumer Read-links it rather than restating scope semantics. Universal evidence-type taxonomy (types, precedence, EVIDENCE_TYPE_MISMATCH) is UNCHANGED — only instrument availability becomes conditional. Behavioral SCs run in the deck repo itself (self-referential case; qualifiers MUST NOT exempt `.opencode`-targeted work).

## Files

- `.opencode/tests-v2/AGENTS.md` (SC-1)
- `.opencode/guidelines/020-go-prohibitions.md` (SC-2)
- `.opencode/guidelines/080-code-standards.md` (SC-3)
- `.opencode/guidelines/091-incremental-build.md` (SC-4)
- `.opencode/skills/test-driven-development/SKILL.md` (SC-5)
- `.opencode/reference/spec-structure-standards.md` (SC-6)

## Dispatch

Orchestrator executes commit-inline steps directly; RED/GREEN/verify steps dispatch task cards from test-driven-development and verification-before-completion; phase 5 dispatches a clean-room evaluation sub-agent per tests-v2 §6a.

## Blast Radius

Text additions/modifications to six files listed above, all within the `.opencode` repo. No runtime code, no harness scripts, no files outside the `.opencode` repo. Guidance-text behavioral scenarios in tests-v2 may assert old unqualified wording — bounded synchronized expectation check applies during implementation.

## Admonishments

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

> **Enforcement gate:** All SCs must pass before this plan is complete.

## Phase Table

| Phase | Name | Concern | SCs | Depends On | Step Range | Dispatch |
|-------|------|---------|-----|------------|------------|----------|
| 1 | Scope anchor in tests-v2/AGENTS.md | Canonical scope anchor statement | SC-1 | — | 3-9 | direct (3-4) + task-card (5-9) |
| 2 | Read-link qualifiers in guideline restatements | Guideline text qualifiers | SC-2, SC-3, SC-4 | 1 | 10-21 | task-card (10-21) |
| 3 | Evidence-taxonomy separation and table alignment | Skill card + reference table | SC-5, SC-6 | 1 | 22-33 | task-card (22-33) |
| 4 | Behavioral RED — artifact generation | Behavioral artifact run | SC-7 | 1, 2, 3 | 34-45 | direct (34, 43-45) + task-card (35-42) |
| 5 | Behavioral GREEN — clean-room evaluation | Clean-room evaluation | SC-8 | 4 | 46-67 | direct (46-52, 56-67) + task-card (53-55) |

## Self-Remediation Protocol

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

## Exit Criteria

- C1: SC-1 scope anchor exists in `tests-v2/AGENTS.md` carrying harness scope conditionality and R-6 routing directive — PASS
- C2: SC-2 qualifier present in `020-go-prohibitions.md` §1 with Read-link to anchor — PASS
- C3: SC-3 qualifier present in `080-code-standards.md` critical-rules-060 with Read-link to anchor — PASS
- C4: SC-4 instrument conditionality present in `091-incremental-build.md` behavioral variant with Read-link to anchor — PASS
- C5: SC-5 taxonomy prose separated; type table and EVIDENCE_TYPE_MISMATCH semantics unchanged — PASS
- C6: SC-6 fallback instrument present in `spec-structure-standards.md` behavioral row — PASS
- C7: SC-7 artifact generation produced `session.yaml` with exit 0 — PASS
- C8: SC-8 clean-room evaluation recorded RED FAIL (pre-change) and GREEN PASS (post-change) — PASS

# Pre-Implementation Steps

- [ ] 1. Run coherence gate on the spec. (**direct**)
  - Context parameters:
    - - Read the spec at `.opencode/.issues/2469/spec.md` and verify SC/Item/Requirement consistency against the structure artifact at `.opencode/.issues/2469/artifacts/structure.yaml`
    - - Verify all 8 SCs map to at least one item and one phase; verify the phase DAG is acyclic
    - - If inconsistency found: BLOCKED with reason — do not continue plan execution
- [ ] 2. Run baseline check. (**direct**)
  - Context parameters:
    - - Verify all six target files exist and capture their current relevant excerpts under `tmp/2469/baseline/` for later diff checks
    - - Verify the `spec-cleared` label is present in `.opencode/.issues/2469/issue.yaml` labels
    - - If baseline mismatch found: BLOCKED with reason

---

## Code Path Coverage

Single file: `.opencode/tests-v2/AGENTS.md`. The anchor section is added near the top of the document so all consumer Read-links resolve to a stable section heading. No code paths — guidance text only.

## Cross-Cutting SCs

SC-1 is the anchor consumed by SC-2/SC-3/SC-4 via Read-links and by the behavioral GREEN legs of SC-7/SC-8. Nothing else in this phase is cross-cutting.

## Interface Boundaries

The anchor must not restate harness mechanics verbatim from elsewhere in tests-v2/AGENTS.md — it scopes them. Wording must be stable enough to serve as a grep target for SC-2..SC-4 verification (stable section heading, not line numbers).

## State Transitions

None — static text change.

## Step-by-Step

- [ ] 3. Run pre-regression test patterns before RED. (**task-card**)
  - Context parameters:
    - - Dispatch: `task(..., prompt: "execute phase-0 task from test-driven-development")`
    - - SC reference: SC-1
    - - Pre-cleanup: `rm -f tmp/2469/artifacts/pipeline-pre-regression-*`
- [ ] 4. Verify pre-regression results. (**task-card**)
  - Context parameters:
    - - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
    - - SC reference: SC-1
    - - Failure blocks phase entry
- [ ] 5. RED — failing enforcement test for the anchor. (**task-card**)
  - Context parameters:
    - - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
    - - SC reference: SC-1
    - - RED condition: grep for the scope-anchor statement in `.opencode/tests-v2/AGENTS.md` returns no match — the anchor does not exist yet
    - - Pre-cleanup: `rm -f tmp/2469/artifacts/pipeline-red-*`
- [ ] 6. GREEN — add the scope anchor statement. (**task-card**)
  - Context parameters:
    - - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
    - - SC reference: SC-1
    - - GREEN condition: `tests-v2/AGENTS.md` carries the explicit scope statement — harness + `opencode run` mechanics apply only to `.opencode`-targeted work; for any other spec target the harness is out of scope and `.opencode` SHALL NOT be modified; the anchor carries the R-6 routing directive — deck defects route via issue-operations to `michael-conrad/.opencode`, and agents do NOT patch local `.opencode` copies to escape a mis-scoped mandate
    - - Minimum change only — no harness script edits
- [ ] 7. Run post-regression test patterns. (**task-card**)
  - Context parameters:
    - - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
    - - SC reference: SC-1
    - - Pre-cleanup: `rm -f tmp/2469/artifacts/pipeline-post-regression-*`
- [ ] 8. Verify implementation against SC-1. (**task-card**)
  - Context parameters:
    - - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
    - - SC reference: SC-1
    - - Verification: grep confirms the anchor text and Read-link resolvability
    - - Evidence type: string — grep pass backed by tool output
- [ ] 9. Commit test + change as one atomic slice. (**direct**)
  - Context parameters:
    - - Orchestrator runs `git add <files> && git commit -m "<message>"` directly in the `.opencode` repo
    - - Files: enforcement test files + `.opencode/tests-v2/AGENTS.md`
    - - One commit covering the SC-1 anchor statement

## Phase Completion

Verify before advancing: SC-1 verdict PASS recorded; anchor grep pass passes; commit exists. Advance only when all three hold.

**Cost frame:** Verifying the anchor statement costs one grep pass — the bounded cost that keeps all downstream Read-link consumers resolvable. Skipping the verification costs weeks of drift: without a canonical anchor, each consumer file restates scope text and divergent variants ship undetected until a cross-repo incident surfaces them. Correctness is the only metric.

## Concern Transition

Anchor landed. Phase 2 consumes it via Read-links in guideline restatements.

# Phase 2 — Read-link qualifiers in guideline restatements

---

## Code Path Coverage

Three files, no code paths — guideline text only:
- `.opencode/guidelines/020-go-prohibitions.md` §1 cost-blind clause (SC-2)
- `.opencode/guidelines/080-code-standards.md` critical-rules-060 (SC-3)
- `.opencode/guidelines/091-incremental-build.md` behavioral variant (SC-4)

## Cross-Cutting SCs

None — SC-2, SC-3, SC-4 are independent within the phase (all Read-link the phase-1 anchor; no interdependencies among them).

## Interface Boundaries

Each qualifier must carry identical semantics to the anchor — no divergent inline variants. Each file Read-links the SC-1 anchor section rather than restating scope semantics.

## State Transitions

None — static text changes.

## Step-by-Step

Item 2 (SC-2) — daisy chain start; phase-1 commit is precondition for this item's RED.

- [ ] 10. RED — failing enforcement test for the 020 qualifier. (**task-card**)
  - Context parameters:
    - - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
    - - SC reference: SC-2
    - - RED condition: grep for the scope qualifier + Read-link in `.opencode/guidelines/020-go-prohibitions.md` §1 cost-blind clause returns no match
    - - Pre-cleanup: `rm -f tmp/2469/artifacts/pipeline-red-*`
- [ ] 11. GREEN — add the 020 scope qualifier. (**task-card**)
  - Context parameters:
    - - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
    - - SC reference: SC-2
    - - GREEN condition: the cost-blind clause carries the scope qualifier (instrument conditional on `.opencode`-targeted work; universal evidence duty unchanged) and Read-links the SC-1 anchor
    - - Identical semantics to the anchor — no divergent inline variant
- [ ] 12. Run post-regression test patterns. (**task-card**)
  - Context parameters:
    - - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
    - - SC reference: SC-2
- [ ] 13. Verify implementation against SC-2. (**task-card**)
  - Context parameters:
    - - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
    - - SC reference: SC-2
    - - Verification: grep confirms qualifier + Read-link present
- [ ] 14. Commit test + change as one atomic slice. (**direct**)
  - Context parameters:
    - - Orchestrator runs `git add <files> && git commit -m "<message>"` directly in the `.opencode` repo
    - - One commit covering `.opencode/guidelines/020-go-prohibitions.md`

Item 3 (SC-3) — precondition: item 2's commit.

- [ ] 15. RED — failing enforcement test for the 080 qualifier. (**task-card**)
  - Context parameters:
    - - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
    - - SC reference: SC-3
    - - RED condition: grep for the scope qualifier + Read-link in `.opencode/guidelines/080-code-standards.md` critical-rules-060 returns no match
- [ ] 16. GREEN — add the 080 scope qualifier. (**task-card**)
  - Context parameters:
    - - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
    - - SC reference: SC-3
    - - GREEN condition: critical-rules-060 carries the same scope qualifier and Read-links the SC-1 anchor — identical semantics to SC-2
- [ ] 17. Run post-regression test patterns. (**task-card**)
  - Context parameters:
    - - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
    - - SC reference: SC-3
- [ ] 18. Verify implementation against SC-3. (**task-card**)
  - Context parameters:
    - - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
    - - SC reference: SC-3
    - - Verification: grep confirms qualifier + Read-link present
- [ ] 19. Commit test + change as one atomic slice. (**direct**)
  - Context parameters:
    - - Orchestrator runs `git add <files> && git commit -m "<message>"` directly in the `.opencode` repo
    - - One commit covering `.opencode/guidelines/080-code-standards.md`

Item 4 (SC-4) — precondition: item 3's commit.

- [ ] 20. RED + GREEN + verify for the 091 behavioral-variant conditionality. (**task-card**)
  - Context parameters:
    - - Dispatch RED: `task(..., prompt: "execute red task from test-driven-development")` — RED condition: grep for instrument-conditional text in the 091 behavioral variant returns no match
    - - Dispatch GREEN: `task(..., prompt: "execute green task from test-driven-development")` — GREEN condition: the behavioral variant restates instrument conditionality (`opencode run` for `.opencode`-targeted items; strongest available in-repo instrument for other repos; universal behavioral-evidence duty unchanged) and Read-links the SC-1 anchor
    - - Dispatch verify: `task(..., prompt: "execute verify task from verification-before-completion")` — grep confirms conditionality text + Read-link
    - - SC reference: SC-4
- [ ] 21. Commit test + change as one atomic slice. (**direct**)
  - Context parameters:
    - - Orchestrator runs `git add <files> && git commit -m "<message>"` directly in the `.opencode` repo
    - - One commit covering `.opencode/guidelines/091-incremental-build.md`

## Phase Completion

Verify before advancing: SC-2, SC-3, SC-4 verdicts PASS recorded; qualifier greps pass; three commits exist in daisy-chain order.

**Cost frame:** Verifying each qualifier costs one grep pass — the bounded cost that pins identical semantics at each consumption point. Skipping a qualifier verification costs days-to-weeks: the cost-blind clauses keep their unqualified harness mandate and every agent reading them outside the deck repo re-attempts `opencode run`, producing failed runs that surface only after wasted session time. Correctness is the only metric.

## Concern Transition

Guideline qualifiers landed. Phase 3 aligns the skill-card taxonomy prose and the reference evidence table to the anchor-driven scope semantics.

# Phase 3 — Evidence-taxonomy separation and table alignment

---

## Code Path Coverage

Two files, no code paths — skill card prose and reference table only:
- `.opencode/skills/test-driven-development/SKILL.md` §Evidence Type Taxonomy (SC-5)
- `.opencode/reference/spec-structure-standards.md` evidence table behavioral row (SC-6)

## Cross-Cutting SCs

None — SC-5 precedes SC-6 within the phase (SC-6 aligns to SC-5 semantics via Read-link).

## Interface Boundaries

Taxonomy types, precedence, and EVIDENCE_TYPE_MISMATCH semantics are UNTOUCHED — SC-5 adds separation prose only, and the verify step diffs the type table to confirm no semantic drift.

## State Transitions

None — static text changes.

## Step-by-Step

Item 5 (SC-5) — precondition: phase-2 completion commit.

- [ ] 22. RED — failing test for taxonomy separation prose. (**task-card**)
  - Context parameters:
    - - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
    - - SC reference: SC-5
    - - RED condition: grep for deck/non-deck instrument separation in §Evidence Type Taxonomy prose returns no match
- [ ] 23. GREEN — add the separation prose. (**task-card**)
  - Context parameters:
    - - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
    - - SC reference: SC-5
    - - GREEN condition: prose separates universal evidence-type rigor from deck-repo instrument mechanics; taxonomy table unchanged
- [ ] 24. Run post-regression test patterns. (**task-card**)
  - Context parameters:
    - - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
    - - SC reference: SC-5
- [ ] 25. Verify implementation against SC-5. (**task-card**)
  - Context parameters:
    - - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
    - - SC reference: SC-5
    - - Verification: grep confirms new prose; diff confirms type table and EVIDENCE_TYPE_MISMATCH semantics unchanged
- [ ] 26. Commit test + change as one atomic slice. (**direct**)
  - Context parameters:
    - - Orchestrator runs `git add <files> && git commit -m "<message>"` directly in the `.opencode` repo
    - - One commit covering `.opencode/skills/test-driven-development/SKILL.md`

Item 6 (SC-6) — precondition: item 5's commit.

- [ ] 27. RED — failing test for the fallback-instrument wording. (**task-card**)
  - Context parameters:
    - - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
    - - SC reference: SC-6
    - - RED condition: grep of the `.opencode/reference/spec-structure-standards.md` behavioral row for fallback instrument text returns no match
- [ ] 28. GREEN — extend the behavioral row. (**task-card**)
  - Context parameters:
    - - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
    - - SC reference: SC-6
    - - GREEN condition: behavioral row carries primary instrument (deck repo: `opencode run`) plus fallback instrument (strongest available execution-based evidence), aligned to SC-5 semantics via Read-link
- [ ] 29. Run post-regression test patterns. (**task-card**)
  - Context parameters:
    - - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
    - - SC reference: SC-6
- [ ] 30. Verify implementation against SC-6. (**task-card**)
  - Context parameters:
    - - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
    - - SC reference: SC-6
    - - Verification: grep confirms table row wording
- [ ] 31. Commit test + change as one atomic slice. (**direct**)
  - Context parameters:
    - - Orchestrator runs `git add <files> && git commit -m "<message>"` directly in the `.opencode` repo
    - - One commit covering `.opencode/reference/spec-structure-standards.md`

## Phase Completion

Verify before advancing: SC-5, SC-6 verdicts PASS recorded; taxonomy diff confirms unchanged semantics; evidence-table grep passes; two commits exist in order.

**Cost frame:** Verifying the taxonomy prose separation and evidence-table row costs one grep pass plus a table diff — the bounded cost that catches fusion of rigor with instrument at authoring time. Skipping it costs hours-to-days: taxonomy consumers keep fusing rigor with instrument, a spec-audit or VbC gate fails late in the pipeline, and specs authored from the table declare a behavioral instrument their repo cannot provide — the mismatch surfaces only at the first plan-execution cycle. Correctness is the only metric.

## Concern Transition

Text changes landed (phases 1-3). Phase 4 behaviorally demonstrates the defect is real (RED leg) and the fix changes agent behavior (GREEN leg), per the tests-v2 §6a two-SC pattern.

# Phase 4 — Behavioral RED — artifact generation

---

## Code Path Coverage

Behavioral scenario execution — real agent behavior, not text. All runs via the tests-v2 harness: `bash .opencode/tests-v2/with-test-home opencode run '<scenario>'`. Artifact-only generator produces `session.yaml` for SC-7; no assertion logic inside the run itself (clean-room evaluation is SC-8, phase 5).

## Cross-Cutting SCs

None — SC-7 is self-contained in this phase, but its GREEN leg requires phases 1-3 complete.

## Interface Boundaries

One dispatch per run — the artifact-generation run and any clean-room evaluation are never merged. Behavioral precondition (tests-v2 §4) applies: commit → push → fresh fetch → verify effective commit in remote ref → run.

## State Transitions

Pre-change deck state (RED leg) → post-change deck state (GREEN leg, after Items 1-6 landed). The phase records both artifacts; the directional judgment happens in phase 5.

## Step-by-Step

Item 7 (SC-7) — precondition: phase-3 completion commit.

- [ ] 32. RED leg — run artifact-generation scenario against the unqualified deck. (**direct**)
  - Context parameters:
    - - Dispatch: `bash .opencode/tests-v2/with-test-home opencode run '<real-domain non-.opencode change scenario>'`
    - - SC reference: SC-7
    - - Expected (RED): the agent exhibits mis-scoped behavior — harness attempt or local deck edit — captured in `session.yaml`
- [ ] 33. Export and stage the pre-change session artifact. (**direct**)
  - Context parameters:
    - - Export `session.yaml` from the test home SQLite DB to `tmp/2469/artifacts/behavioral-red/`
    - - Record export path for phase 5 clean-room consumption
- [ ] 34. Verify artifact generation. (**task-card**)
  - Context parameters:
    - - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
    - - SC reference: SC-7
    - - Verification: scenario run produced `session.yaml` (artifact generation confirmed), exit 0
- [ ] 35. Commit the behavioral scenario script. (**direct**)
  - Context parameters:
    - - Orchestrator runs `git add <files> && git commit -m "<message>"` directly in the `.opencode` repo
    - - One commit covering the behavioral scenario script
- [ ] 36. Behavioral precondition cycle (tests-v2 §4). (**direct**)
  - Context parameters:
    - - Commit → push → fresh `git fetch` → verify the effective commit is contained in a remote ref
    - - Hard gate: the run MUST NOT execute on uncommitted or unpushed submodule state
- [ ] 37. GREEN leg — run the same artifact-generation scenario post-change. (**direct**)
  - Context parameters:
    - - Dispatch: `bash .opencode/tests-v2/with-test-home opencode run '<same scenario>'`
    - - SC reference: SC-7
    - - Expected (GREEN): with Items 1-6 landed, the agent defers to in-repo instruments
- [ ] 38. Export and stage the post-change session artifact. (**direct**)
  - Context parameters:
    - - Export `session.yaml` to `tmp/2469/artifacts/behavioral-green/`
    - - Record export path for phase 5 clean-room consumption
- [ ] 39. Verify artifact generation (GREEN leg). (**task-card**)
  - Context parameters:
    - - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
    - - SC reference: SC-7
    - - Verification: scenario run produced `session.yaml`, exit 0; no clean-room verdict is rendered in this phase
- [ ] 40. Run post-regression test patterns. (**task-card**)
  - Context parameters:
    - - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
    - - SC reference: SC-7
- [ ] 41. Commit test + scenario updates as one atomic slice. (**direct**)
  - Context parameters:
    - - Orchestrator runs `git add <files> && git commit -m "<message>"` directly in the `.opencode` repo

## Phase Completion

Verify before advancing: SC-7 verdict PASS recorded; pre-change and post-change `session.yaml` artifacts exist at recorded paths; §4 precondition cycle passed for both runs.

**Cost frame:** Running the artifact-generation scenario costs minutes of execution time — a bounded delay that produces the only live behavioral evidence of the mis-scoping defect and its fix. Skipping it costs the full downstream rework when the mis-scoping defect ships: every non-deck session repeats the failed-run/fabricated-workaround loop, compounding per session. Correctness is the only metric.

## Concern Transition

SC-7 artifacts staged. Phase 5 renders the actual verdicts via clean-room evaluation — the judgment step this phase deliberately does not perform.

# Phase 5 — Behavioral GREEN — clean-room evaluation

---

## Code Path Coverage

Clean-room evaluation of `session.yaml` artifacts produced in phase 4 — no new code paths. Evaluation sub-agent reads artifacts and judges agent actions against the SC-8 criterion.

## Cross-Cutting SCs

SC-8 carries R-6 (deck-copy integrity + routing) and R-7 (two-SC pattern; qualifiers do NOT exempt `.opencode`-targeted work) — the evaluation explicitly confirms the self-referential case: `.opencode`-targeted work keeps full behavioral testing.

## Interface Boundaries

One dispatch per evaluation leg — RED-leg evaluation and GREEN-leg evaluation are separate clean-room sub-agent dispatches, never merged into one run (tests-v2 §6a). Sub-agent receives only artifact paths and the criterion.

## State Transitions

Verdicts transition: pre-change FAIL (defect exhibited) → post-change PASS (agent defers to in-repo instruments, does NOT invoke tests-v2, does NOT modify `.opencode`, routes deck concerns to `michael-conrad/.opencode`).

## Step-by-Step

Item 8 (SC-8) — precondition: phase-4 artifacts staged.

- [ ] 42. RED-leg evaluation — clean-room sub-agent evaluates the pre-change artifact. (**task-card**)
  - Context parameters:
    - - Dispatch: `task(..., prompt: "execute clean-room evaluation from tests-v2 §6a — read `tmp/2469/artifacts/behavioral-red/session.yaml` and evaluate agent actions against the SC-8 criterion")`
    - - SC reference: SC-8
    - - Expected verdict: FAIL — agent exhibited mis-scoped behavior
    - - Verdict recorded to `tmp/2469/artifacts/evaluation-red.yaml`
- [ ] 43. GREEN-leg evaluation — clean-room sub-agent evaluates the post-change artifact. (**task-card**)
  - Context parameters:
    - - Dispatch: `task(..., prompt: "execute clean-room evaluation from tests-v2 §6a — read `tmp/2469/artifacts/behavioral-green/session.yaml` and evaluate agent actions against the SC-8 criterion")`
    - - SC reference: SC-8
    - - Expected verdict: PASS — agent defers to in-repo instruments, does NOT invoke tests-v2, does NOT modify `.opencode`, routes deck concerns to `michael-conrad/.opencode`
    - - Verdict recorded to `tmp/2469/artifacts/evaluation-green.yaml`
- [ ] 44. Verify evaluation verdicts. (**task-card**)
  - Context parameters:
    - - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
    - - SC reference: SC-8
    - - Verification: clean-room evaluation verdict recorded for both legs — RED (pre-change FAIL) and GREEN (post-change PASS)
    - - Any harness failure or timeout during phases 4-5: verdict FAIL with diagnosis — structural substitutes are prohibited
- [ ] 45. Commit the evaluation verdict artifacts. (**direct**)
  - Context parameters:
    - - Orchestrator runs `git add <files> && git commit -m "<message>"` directly in the `.opencode` repo
    - - One commit covering the evaluation verdict artifacts

## Phase Completion

Verify before advancing: SC-8 verdict PASS recorded (both legs); evaluation artifacts exist; commit exists.

**Cost frame:** Running the clean-room evaluation costs minutes of clean-room dispatch time — the bounded cost of the only behavioral proof that the fix changes agent behavior. Skipping it costs the loss of that proof: string evidence alone passes while the mis-scoped behavior continues in production, a 1000× escalation by the tiered cost table. Correctness is the only metric.

## Concern Transition

All 8 SCs executed. Post-implementation steps apply.

# Post-Implementation Steps

- [ ] 46. Run adversarial audit of the deliverable. (**task-card**)
  - Context parameters:
    - - Dispatch: `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read audit/tasks/verification-audit-investigator.md first")` — followed by validator, evaluator, arbiter in sequence
    - - Pre-cleanup: `rm -f tmp/2469/artifacts/pipeline-audit-*`
- [ ] 47. Run Z3 constraint solver verification. (**direct**)
  - Context parameters:
    - - Orchestrator runs `.opencode/tools/solve check --state-path ... --contract-path ...` directly
    - - Pre-cleanup: `rm -f tmp/2469/artifacts/pipeline-z3-check-*`
- [ ] 48. Run finishing checklist (structural checks). (**task-card**)
  - Context parameters:
    - - Dispatch: `task(..., prompt: "execute checklist task from finishing-a-development-branch")`
    - - Pre-cleanup: `rm -f tmp/2469/artifacts/pipeline-structural-checks-*`
- [ ] 49. Run pre-PR gate — verify all SC verdicts. (**task-card**)
  - Context parameters:
    - - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
    - - Reads all SC verdicts; BLOCKs if any FAIL
    - - Pre-cleanup: `rm -f tmp/2469/artifacts/pipeline-pre-pr-gate-*`
- [ ] 50. Run final regression check. (**task-card**)
  - Context parameters:
    - - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
    - - Pre-cleanup: `rm -f tmp/2469/artifacts/pipeline-regression-check-*`
- [ ] 51. Prepare PR review context. (**task-card**)
  - Context parameters:
    - - Dispatch: `task(..., prompt: "execute review-prep from git-workflow-pr. Read git-workflow-pr/tasks/review-prep.md first")`
- [ ] 52. Create the pull request. (**task-card**)
  - Context parameters:
    - - Dispatch: `task(..., prompt: "execute create task from git-workflow-pr")`
    - - PR requires the `for_pr` authorization scope present on the issue (verified: local `issue.yaml` labels carry `approved-for-pr`)
    - - HALT after PR creation — never merge (human-only merge)
- [ ] 53. Generate completion executive summary. (**task-card**)
  - Context parameters:
    - - Dispatch: `task(..., prompt: "execute completion task from completion-core")`
    - - Emits exactly one `plan_created` lifecycle event with `plan_file` and `phase_count`

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)