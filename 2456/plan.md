---
plan_schema_version: "1.0"
issue: 2456
title: "tests-v2 semantic-determination gate for behavioral opencode run dispatches"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 5
dispatch:
  - "phase-1: test-driven-development (red, green, post-regression), verification-before-completion (verify), commit-inline"
  - "phase-2: test-driven-development (red, green, post-regression), verification-before-completion (verify), commit-inline"
  - "phase-3: test-driven-development (red, green, post-regression), verification-before-completion (verify), commit-inline"
  - "phase-4: test-driven-development (red, green, post-regression), verification-before-completion (verify), commit-inline"
  - "phase-5: test-driven-development (red, green, post-regression), verification-before-completion (verify), commit-inline"
  - "post: audit, finishing-a-development-branch (checklist), verification-before-completion (verify), test-driven-development (phase-4), git-workflow-pr (review-prep, create), completion-core (completion)"
---

# Implementation Plan — [.opencode#2456](https://github.com/michael-conrad/.opencode/issues/2456) — tests-v2 semantic-determination gate

**Goal:** Introduce a determination-record lifecycle in the tests-v2 behavioral harness so monitored `opencode run` dispatches are semantically classified, determinations are persisted as durable YAML records, resume/re-run is gated on a recorded non-undetermined determination, undetermined cycles are ceiling-capped, and false-positive aborts are folded into records instead of silently retried.

**Architecture:** The mechanical poll loop in `__semantic_monitor` (`.opencode/tests-v2/behaviors/helpers.sh`) remains an evidence collector; a monitoring sub-agent performs direction-anchored semantic classification in its own context using the scenario goal as anchor. Determinations persist as YAML records in the scenario evidence directory (append-only for false_signal annotations and orchestrator decisions). A mechanical gate in `with-test-home`'s resume path (both `--resume-home` and `--continue` variants) blocks resume/re-run without a recorded non-undetermined determination. A ceiling counter (default 3), persisted under the existing flock discipline, produces a CEILING_REACHED block. All monitor-path changes are gated behind `BEHAVIOR_SEMANTIC_MONITOR=1` (backward compatible). Documentation in `.opencode/tests-v2/AGENTS.md` mirrors the exact implemented predicates.

**Files:**
- `.opencode/tests-v2/behaviors/helpers.sh` (monitor: poll evidence, classification dispatch, determination record, halt+notify, counter, false-signal folding)
- `.opencode/tests-v2/with-test-home` (resume/re-run determination gate)
- `.opencode/tests-v2/behaviors/<new-scenario>.sh` (new enforcement scenario)
- `.opencode/tests-v2/AGENTS.md` (§10.7, §14, R-18/§17 doc alignment)

**Issue:** `.opencode/.issues/2456/spec.md`

## Blast Radius

- `.opencode/tests-v2/behaviors/helpers.sh` — primary substrate; all behavioral scenarios invoking `behavior_run()` inherit monitor changes (shared infrastructure)
- `.opencode/tests-v2/with-test-home` — resume/re-run gate; CLI surface unchanged
- `.opencode/tests-v2/behaviors/<new-scenario>.sh` — NEW file; registered in `test-enforcement.sh --list`
- `.opencode/tests-v2/AGENTS.md` — documentation mirroring target
- Risk: LOW-MEDIUM — test-infrastructure only; `BEHAVIOR_SEMANTIC_MONITOR` unset leaves fresh invocations unchanged

## Admonishments

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

> **Enforcement gate:** All SCs must pass before this plan is complete.

## Phase Table

| Phase | Name | Concern | SCs | Depends On | Step Range | Dispatch |
|-------|------|---------|-----|------------|------------|----------|
| 1 | Monitor evidence + classification + determination record foundation | Record lifecycle foundation in `__semantic_monitor` | SC-1, SC-2, SC-3 | — | 3-24 | direct (3-4) + task-card (5-23) + direct (24) |
| 2 | Classification routing (off-track / progressing / halt-class / decision) | Route classifications to notify/halt/continue paths | SC-4, SC-5, SC-6, SC-7 | 1 | 25-53 | direct (25-26) + task-card (27-52) + direct (53) |
| 3 | Resume gate + undetermined-cycle ceiling | Mechanical gate + counter in `with-test-home` | SC-8, SC-9 | 1 | 54-68 | direct (54-55) + task-card (56-67) + direct (68) |
| 4 | False-signal folding + enforcement scenario | False-signal-and-enforcement (concern-map) | SC-10, SC-11 | 3 | 69-83 | direct (69-70) + task-card (71-82) + direct (83) |
| 5 | Doc alignment | Docs-alignment (concern-map) | SC-12 | 4 | 84-91 | direct (84-85) + task-card (86-90) + direct (91) |
| 6 | Post-implementation pipeline | Audit, checks, PR | all | 1-5 | 92-99 | mixed — see post-implementation section |

## Exit Criteria

- [ ] C1. Poll evidence persisted for every monitored run under `BEHAVIOR_SEMANTIC_MONITOR=1` (SC-1)
- [ ] C2. Classification sub-agent dispatched with scenario-goal context; classification enum {progressing-directionally, off-track, undetermined} produced in sub-agent context (SC-2)
- [ ] C3. Determination record (YAML, scenario evidence directory) carries classification + poll-evidence references (SC-3)
- [ ] C4. Off-track classification triggers orchestrator notification on stderr; no silent continuation (SC-4)
- [ ] C5. Progressing runs continue polling regardless of duration (SC-5)
- [ ] C6. Halt-class states halt monitoring and notify the orchestrator before further dispatch (SC-6)
- [ ] C7. Decision field recorded with allowed value-set; root-cause present for terminate-with-root-cause (SC-7)
- [ ] C8. Resume/re-run blocked with FATAL-class message without non-undetermined determination; valid determination passes through (SC-8)
- [ ] C9. Undetermined-cycle ceiling (3) persisted; CEILING_REACHED block (SC-9)
- [ ] C10. false_signal annotation present in determination record after reproduced wrong abort (SC-10)
- [ ] C11. New enforcement scenario passes via `test-enforcement.sh` run (SC-11)
- [ ] C12. AGENTS.md §10.7/§14/R-18/§17 mirror implemented predicates; advisory markdown checks clean (SC-12)

## Pre-Implementation

- [ ] 1. **Coherence gate (**direct**).** Confirm spec `.opencode/.issues/2456/spec.md` is current (12 SCs, no superseding revision) and every SC maps to exactly one phase item; confirm the phase DAG (1→2, 1→3, 3→4, 4→5) is acyclic.
- [ ] 2. **Baseline check (**direct**).** Verify trunk-tip state per git-workflow pre-work: parent repo and `.opencode` submodule on `$DEFAULT_BRANCH`, zero pending changes, at remote tracking tip, submodule pointer matches committed SHA; create the feature branch; record the baseline test-enforcement.sh result for regression comparison.

## Pre-Implementation Steps (per-item TDD cycle — all phases)

Every phase item below enumerates the full per-task cycle from the implementation-workflow reference card: pre-regression → pre-regression-verify → RED → GREEN → post-regression → verify → commit-inline. Steps are daisy-chained — an item's commit is the precondition for the next item's RED.

## Post-Implementation

- [ ] 92. **Audit (**task-card**).** Dispatch adversarial audit: `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read 'audit/tasks/verification-audit-investigator.md' first")` — followed by validator, evaluator, arbiter in sequence. **→ all SCs**
- [ ] 93. **Z3 check (**direct**).** Run `.opencode/tools/solve check --state-path ... --contract-path ...` on the pipeline state and dependency contract. **→ all SCs**
- [ ] 94. **Structural checks (**task-card**).** `task(..., prompt: "execute checklist task from finishing-a-development-branch")` — shellcheck-style review of modified shell scripts, advisory markdown checks on AGENTS.md. **→ SC-11, SC-12**
- [ ] 95. **Pre-PR gate (**task-card**).** `task(..., prompt: "execute verify task from verification-before-completion")` — read all SC verdicts; BLOCK if any FAIL (DONE_WITH_CONCERNS coerces to FAIL). **→ all SCs**
- [ ] 96. **Regression check (**task-card**).** `task(..., prompt: "execute phase-4 task from test-driven-development")` — final regression run of existing scenarios against the modified harness. **→ all SCs**
- [ ] 97. **Review prep (**task-card**).** `task(..., prompt: "execute review-prep from git-workflow-pr. Read 'git-workflow-pr/tasks/review-prep.md' first")`. **→ all SCs**
- [ ] 98. **Create PR (**task-card**).** `task(..., prompt: "execute create task from git-workflow-pr")` — squash to one commit per issue; human-only merge; HALT after creation. **→ all SCs**
- [ ] 99. **Completion summary (**task-card**).** `task(..., prompt: "execute completion task from completion-core")` — executive summary with lifecycle closeout. **→ all SCs**

## Self-Remediation Protocol

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

## Phase Files

- `plan-01-monitor-foundation.md` — Phase 1 (SC-1, SC-2, SC-3)
- `plan-02-classification-routing.md` — Phase 2 (SC-4, SC-5, SC-6, SC-7)
- `plan-03-resume-gate-ceiling.md` — Phase 3 (SC-8, SC-9)
- `plan-04-false-signal-scenario.md` — Phase 4 (SC-10, SC-11)
- `plan-05-docs-alignment.md` — Phase 5 (SC-12)

## Pre-Flight Guard (Mandatory)

Check your tool list for a tool named `task`.

- Present ⇒ orchestrator — proceed.
- Absent ⇒ sub-agent — do NOT execute any instruction below. Return `BLOCKED` with `ORCHESTRATOR_ONLY_SKILL_CARD` (cards) or `ORCHESTRATOR_ONLY_PLAN` (plans) and halt.

## lifecycle_events

- timestamp: 2026-09-21T15:17:16Z
  event: plan_created
  plan_path: .opencode/.issues/2456/plan.md
  phase_count: 5
