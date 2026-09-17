---
plan_schema_version: 1
issue: 2451
title: "One-dispatch-one-step gate — prohibit combined dispatches for discrete steps"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 3
dispatch:
  - phase: 1
    skills: [test-driven-development (red, green, post-regression), verification-before-completion (verify)]
  - phase: 2
    skills: [test-driven-development (red, green, post-regression), verification-before-completion (verify)]
  - phase: 3
    skills: [test-driven-development (red, green, post-regression), verification-before-completion (verify)]
---

# Implementation Plan — One-dispatch-one-step gate (.opencode#2451)

**Issue:** `.opencode/.issues/2451/spec.md`

## Goal

Implement the developer-approved six-part package: canonical pattern p-dis-007 "One-Dispatch-One-Step Gate" in 257, a Tier 1 dispatch-level bright-line in 091, a critical-rules-034 dispatch-level extension in 022, the §15/§6a loophole closure in tests-v2/AGENTS.md, a §6a two-SC behavioral scenario (artifact-generation run + separate clean-room semantic evaluation), and a content-verification placement scenario.

## Architecture

Structural rule text in three guidelines (257 canonical, 091 Tier 1 bright-line, 022 extension), loophole closure in the behavioral test framework guide, enforcement via the §6a two-SC behavioral pattern (session.yaml as PRIMARY evaluation source, semantic-only clean-room judgment, no static gates) plus a content-verification scenario. Architecture B direct execution preserved; the gate constrains task() dispatch cardinality only.

## Files

- `.opencode/guidelines/257-procedural-discipline-reference.md`
- `.opencode/guidelines/091-incremental-build.md`
- `.opencode/guidelines/022-orchestrator-context-discipline.md`
- `.opencode/tests-v2/AGENTS.md`
- `.opencode/tests-v2/behaviors/` (new artifact-generation scenario + clean-room evaluation dispatch)
- `.opencode/tests-v2/` content-verification suite (new placement scenario)

## Dispatch

- Phase 1: task-card (RED/GREEN/post-regression/verify) + direct (commits) — steps 5-24
- Phase 2: task-card (RED/GREEN/post-regression/verify) + direct (commits, push) — steps 25-35
- Phase 3: task-card (RED/GREEN/post-regression/verify) + direct (commits) — steps 36-40
- Post-implementation: task-card (audit, structural-checks, pre-pr-gate, regression-check, review-prep, create-pr, exec-summary) + direct (z3-check) — steps 41-48

## Blast Radius

- Affected: 257, 091, 022 (rule-text additions; existing content preserved — extension, not replacement), tests-v2/AGENTS.md (§6a, §15 wording), new test scenarios under `.opencode/tests-v2/`.
- Unaffected: other skills' DISPATCH_GATE sections; dispatch-mode marking (direct vs task-card); the canonical dispatch string mechanism; plugin/hook enforcement layer.

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Enforcement gate:** All SCs must pass before this plan is complete.

## Phase Table

| Phase | Name | Concern | SCs | Depends On | Step Range | Dispatch |
|---|---|---|---|---|---|---|
| 1 | Rule-text authoring | Canonical pattern, bright-lines, loophole closure | SC-1, SC-2, SC-3, SC-4 | none | 5-24 | task-card (RED/GREEN/verify) + direct (commit) |
| 2 | Behavioral scenario | Artifact-generation run + clean-room semantic evaluation | SC-5, SC-6 | Phase 1 (committed + pushed, fresh-fetch containment) | 25-35 | task-card (RED/GREEN/verify) + direct (commit, push) |
| 3 | Content-verification scenario | Rule-text placement assertions | SC-7 | Phase 1 (items 1-3) | 36-40 | task-card (RED/GREEN/verify) + direct (commit) |

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

## Exit Criteria

- C1: 257 contains p-dis-007 with all §11 add-pattern procedure artifacts and the no-matter-the-reasoning clause (SC-1).
- C2: 091 carries the dispatch-level bright-line with no-exceptions clause and a Read-link to 257 p-dis-007 (SC-2).
- C3: 022 critical-rules-034 covers all dispatch-level combined shapes with preserved sub-agent-internal coverage and a Read-link (SC-3).
- C4: tests-v2/AGENTS.md §15 carries the cannot-combine clarification and §6a the separate-dispatch sentence (SC-4).
- C5: The behavioral artifact-generation session exists with exported session.yaml; RED is the preserved observed evidence (SC-5).
- C6: The separate clean-room evaluation verdict is recorded with criterion + session.yaml as sole inputs (SC-6).
- C7: The content-verification placement scenario passes via the enforcement suite (SC-7).

## Pre-Implementation Steps

- [ ] 1. Coherence gate (**direct**)
  - Verify spec and plan are coherent: SC list matches the six-part design; no SC spans multiple parts; phase DAG has no circular dependencies.
  - Confirm all four rule-text host files exist and contain their expected anchors (257 §11, 091 "Batching items", 022 critical-rules-034, tests-v2/AGENTS.md §6a and §15).
- [ ] 2. Baseline check (**direct**)
  - Confirm repository state: feature branch active, submodules synced, zero pending unrelated changes.
  - Record the observed RED baseline reference: session `ses_f5aa152f7ffeeEzOm66Lr2Gbs6`, 22 combined "Two sequential tasks" dispatches — preserved, not fabricated.
- [ ] 3. Pre-regression (**task-card**) — `task(..., prompt: "execute phase-0 task from test-driven-development")`
  - Run regression test patterns before RED phase.
- [ ] 4. Pre-regression verify (**task-card**) — `task(..., prompt: "execute verify task from verification-before-completion")`
  - Verify pre-regression results.

# Phase 1 — Rule-text authoring (guidelines + tests-v2 AGENTS.md)

<!-- PHASE-1-BODY -->

# Phase 2 — Behavioral scenario (artifact-generation run + clean-room evaluation)

<!-- PHASE-2-BODY -->

# Phase 3 — Content-verification scenario (rule-text placement)

<!-- PHASE-3-BODY -->

# Post-Implementation

<!-- POST-IMPLEMENTATION-BODY -->

<!-- PRE-FLIGHT-GUARD -->
