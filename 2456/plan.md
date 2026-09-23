---
plan_schema_version: "1.0"
issue: 2456
title: "tests-v2 semantic-determination gate for behavioral opencode run dispatches"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 6
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
| 6 | Semantic poll discipline + stall diagnosis | Full semantic check on every poll (SC-14), poll cadence ≤ 5 min (SC-15), diagnosis-before-retry on semantically classified non-progressing runs (SC-13), mechanical commit+push before isolated runs (SC-16), supervisor polling mandate enforcement (SC-17), mandate mirrored into AGENTS.md §14 (SC-18), async launch with attached supervision loop (SC-19), efficiency-defect marker at every poll (SC-20), defect marker = hard gate with orchestrator research/remediation/resumption (SC-21) | SC-13, SC-14, SC-15, SC-16, SC-17, SC-18, SC-19, SC-20, SC-21 | 4 | 92-140 | direct (92-93) + task-card (94-139) + direct (140) |
| 7 | Post-implementation pipeline | Audit, checks, PR | all | 1-6 | 141-148 | mixed — see post-implementation section |

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
- [ ] C13. Semantically classified non-progressing run + identifiable cause → decision=terminate-with-root-cause naming the cause; timer-escalation re-dispatch without diagnosis blocked (SC-13)
- [ ] C14. Every poll performs a full semantic check derived from message parts, reasoning parts, and tool calls; activity-only classification defective (SC-14)
- [ ] C15. Poll interval ≤ 300s on monitored runs (SC-15)
- [ ] C16. GREEN-phase behavioral dispatches commit+push test-needed changes mechanically before the isolated run; no commit deliberation (SC-16)
- [ ] C17. Supervisor polls runs at ≤5-min intervals with a full semantic check per poll; no-check retry loops prohibited (SC-17)
- [ ] C18. Supervisor mandate mirrored into AGENTS.md §14 — default deck behavior (SC-18)
- [ ] C19. Agent-supervised runs launched asynchronously with an attached ≤5-min supervision loop; blocking launches prohibited (SC-19)
- [ ] C20. Efficiency-defect marker evaluated at every supervision poll; excessive deliberation recorded + notified; latency not a marker (SC-20)
- [ ] C21. Recorded defect marker = hard gate: sub-agent halts + notifies orchestrator; orchestrator researches/remediates; only the orchestrator resumes (SC-21)

## Pre-Implementation

- [ ] 1. **Coherence gate (**direct**).** Confirm spec `.opencode/.issues/2456/spec.md` is current (21 SCs — SC-13..16 added 2026-09-21; SC-17..21 added 2026-09-22; SC-2 amended 2026-09-22) and every SC maps to exactly one phase item; confirm the phase DAG (1→2, 1→3, 3→4, 4→5, 4→6) is acyclic.
- [ ] 2. **Baseline check (**direct**).** Verify trunk-tip state per git-workflow pre-work: parent repo and `.opencode` submodule on `$DEFAULT_BRANCH`, zero pending changes, at remote tracking tip, submodule pointer matches committed SHA; create the feature branch; record the baseline test-enforcement.sh result for regression comparison.

## Pre-Implementation Steps (per-item TDD cycle — all phases)

Every phase item below enumerates the full per-task cycle from the implementation-workflow reference card: pre-regression → pre-regression-verify → RED → GREEN → post-regression → verify → commit-inline. Steps are daisy-chained — an item's commit is the precondition for the next item's RED.

## Post-Implementation

- [ ] 136. **Audit (**task-card**).** Dispatch adversarial audit: `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read 'audit/tasks/verification-audit-investigator.md' first")` — followed by validator, evaluator, arbiter in sequence. **→ all SCs**
- [ ] 137. **Z3 check (**direct**).** Run `.opencode/tools/solve check --state-path ... --contract-path ...` on the pipeline state and dependency contract. **→ all SCs**
- [ ] 138. **Structural checks (**task-card**).** `task(..., prompt: "execute checklist task from finishing-a-development-branch")` — shellcheck-style review of modified shell scripts, advisory markdown checks on AGENTS.md. **→ SC-11..SC-20**
- [ ] 139. **Pre-PR gate (**task-card**).** `task(..., prompt: "execute verify task from verification-before-completion")` — read all SC verdicts; BLOCK if any FAIL (DONE_WITH_CONCERNS coerces to FAIL). **→ all SCs**
- [ ] 140. **Regression check (**task-card**).** `task(..., prompt: "execute phase-4 task from test-driven-development")` — final regression run of existing scenarios against the modified harness. **→ all SCs**
- [ ] 141. **Review prep (**task-card**).** `task(..., prompt: "execute review-prep from git-workflow-pr. Read 'git-workflow-pr/tasks/review-prep.md' first")`. **→ all SCs**
- [ ] 142. **Create PR (**task-card**).** `task(..., prompt: "execute create task from git-workflow-pr")` — squash to one commit per issue; human-only merge; HALT after creation. **→ all SCs**
- [ ] 143. **Completion summary (**task-card**).** `task(..., prompt: "execute completion task from completion-core")` — executive summary with lifecycle closeout. **→ all SCs**

## Self-Remediation Protocol

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

## Phase Files

- `plan-01-monitor-foundation.md` — Phase 1 (SC-1, SC-2, SC-3)
- `plan-02-classification-routing.md` — Phase 2 (SC-4, SC-5, SC-6, SC-7)
- `plan-03-resume-gate-ceiling.md` — Phase 3 (SC-8, SC-9)
- `plan-04-false-signal-scenario.md` — Phase 4 (SC-10, SC-11)
- `plan-05-docs-alignment.md` — Phase 5 (SC-12)
- `plan-06-stall-diagnosis.md` — Phase 6 (SC-13, SC-14, SC-15)

## Pre-Flight Guard (Mandatory)

Check your tool list for a tool named `task`.

- Present ⇒ orchestrator — proceed.
- Absent ⇒ sub-agent — do NOT execute any instruction below. Return `BLOCKED` with `ORCHESTRATOR_ONLY_SKILL_CARD` (cards) or `ORCHESTRATOR_ONLY_PLAN` (plans) and halt.

## lifecycle_events

- timestamp: 2026-09-22T21:05:00Z
  event: plan_revised
  plan_path: .opencode/.issues/2456/plan.md
  phase_count: 6
  note: Developer directive 2026-09-22 (fifth revision) — SC-20/R-17/Item 20 added (efficiency-defect marker at every supervision poll: excessive deliberation on a straightforward post-spec/post-plan task is a defect signal recorded + notified; raw model latency is not a marker). Phase 6 now SC-13..21 (steps 92-140); post-implementation renumbered 141-148; SC-21 refined: gate routes to orchestrator (sub-agent halts+notifies; orchestrator researches/remediates/resumes). Prior plan approval revoked by spec revision and re-authorized by the same developer directive.
- timestamp: 2026-09-22T20:10:00Z
  event: plan_revised
  plan_path: .opencode/.issues/2456/plan.md
  phase_count: 6
  note: Developer directive 2026-09-22 (fourth revision) — SC-17/R-14/Item 17 (supervisor polling mandate enforcement) and SC-18/R-15/Item 18 (mandate mirrored into AGENTS.md §14) added after root-cause analysis: the mandate existed only in orchestrator dispatch prompts, never in the deck sub-agents read by default, and no enforcement test governed the supervisor side. Phase 6 now SC-13..18 (steps 92-126); post-implementation renumbered 127-134. Prior plan approval revoked by spec revision and re-authorized by the same developer directive.
- timestamp: 2026-09-21T19:30:00Z
  event: plan_revised
  plan_path: .opencode/.issues/2456/plan.md
  phase_count: 6
  note: Developer directive 2026-09-21 (third revision) — SC-16/R-12/Item 16 added (mechanical commit+push before isolated test-home runs; commit deliberation prohibited); Phase 6 now SC-13/14/15/16 (steps 92-115); post-implementation renumbered 116-123. Prior plan approval revoked by spec revision and re-authorized by the same developer directive.
- timestamp: 2026-09-21T18:55:00Z
  event: plan_revised
  plan_path: .opencode/.issues/2456/plan.md
  phase_count: 6
  note: Developer directive 2026-09-21 (second revision) — SC-13 trigger reworded to semantic classification; SC-14 (full semantic check on every poll; activity inadmissible) and SC-15 (poll cadence ≤ 300s) added with R-10/R-11; Phase 6 expanded to SC-13/14/15 (steps 92-109); post-implementation renumbered 110-117. Prior plan approval revoked by spec revision and re-authorized by the same developer directive.
- timestamp: 2026-09-21T18:05:00Z
  event: plan_revised
  plan_path: .opencode/.issues/2456/plan.md
  phase_count: 6
  note: Developer directive 2026-09-21 — SC-13/R-9/Item 13 (diagnosis-before-retry on stalled runs) added to spec; Phase 6 (steps 92-100) inserted; post-implementation renumbered 101-108. Prior plan approval revoked by spec revision and re-authorized by the same developer directive.
- timestamp: 2026-09-21T15:17:16Z
  event: plan_created
  plan_path: .opencode/.issues/2456/plan.md
  phase_count: 6
