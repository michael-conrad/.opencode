---
plan_schema_version: 1
issue: 2457
title: "brainstorming terminal-state gate — finalization required before spec-creation dispatch"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 2
dispatch:
  - "Phase 1: test-driven-development (pre-regression, red, green, post-regression), verification-before-completion (verify, pre-regression-verify), orchestrator (commit-inline, push-inline)"
  - "Phase 2: test-driven-development (pre-regression, red, green, post-regression, regression-check), verification-before-completion (verify), orchestrator (commit-inline, push-inline)"
deviations:
  - "WF-REF-GAP-PUSH: the behavioral PUSH step (commit -> push -> fresh-fetch containment verification before any behavioral test run) is mandated by .opencode/guidelines/091-incremental-build.md behavioral variant, but has no entry in the implementation-workflow reference card. The plan's PUSH steps are executed as direct orchestrator procedure steps, not as a card-valid dispatch — no card reference is claimed. Reference-card gap #WF-REF-GAP-PUSH is noted; fixing the card is out of plan scope."
---

# Implementation Plan — .opencode#2457: brainstorming terminal-state gate

- **Issue:** .opencode/.issues/2457/spec.md

## Goal

Add an explicit user-finalization HARD GATE at the brainstorming explore flow's terminal transition (Step 6 → Step 7) so spec-creation dispatch happens only after a recognized finalization signal, and prove the behavior with a registered behavioral enforcement scenario (refinement-only → dispatch absent; finalization → dispatch present).

## Architecture

Gate text lives in the skill deck (Phase 1: `explore.md` + `exploration-workflow.md`); enforcement lives in the harness (Phase 2: new behavioral scenario in `.opencode/tests-v2/behaviors/` + registration in `test-enforcement.sh`). Finalization vocabulary stays distinct from `approved`/`go` implementation authorization. Evaluation is via clean-room `session.yaml` inspection — stderr grep helpers are forbidden.

## Files

- `.opencode/skills/brainstorming/tasks/explore.md` — Phase 1
- `.opencode/skills/brainstorming/tasks/explore/exploration-workflow.md` — Phase 1
- `.opencode/tests-v2/behaviors/2457-sc1-finalization-gate.sh` — Phase 2
- `.opencode/tests-v2/test-enforcement.sh` (SCENARIOS, SCENARIO_TAGS, FILE_SCENARIO_MAP) — Phase 2

## Dispatch

- Phase 1: direct (1-3, 8, 11) + task-card (4-7, 9-10)
- Phase 2: direct (12, 18, 21) + task-card (13-17, 19-20)

## Blast Radius

- Affected: brainstorming explore deck (behavior change is the intended ripple — in-flight sessions encounter the gate), tests-v2 scenario registry (additive).
- Unaffected: other brainstorming task cards, spec-creation skill, approval-gate vocabulary, test-harness helpers.
- No persistent-state change; handoff artifacts written only at the gated transition, as today.

## Phase Table

| Phase | Name | Concern | SCs | Depends On | Step Range | Dispatch |
|-------|------|---------|-----|------------|------------|----------|
| 1 | Finalization gate in brainstorming explore deck | Discussion-mode finalization separation | SC-1 | — | 1-11 | direct (1-3, 8, 11) + task-card (4-7, 9-10) |
| 2 | Behavioral enforcement scenarios (refinement-hold + finalization-permits) | Behavioral proof of blocking and permitting edges | SC-2, SC-3 | 1 | 12-21 | direct (12, 18, 21) + task-card (13-17, 19-20) |

## Pre-Implementation Steps

- [ ] 1. Coherence gate (**direct**)
  - Re-read `.opencode/.issues/2457/spec.md` and this plan; confirm each SC maps to exactly one item and the phase DAG (1 → 2) has no circular dependency.
  - Confirm the plan is faithful to the spec: single-mechanism SC-1 (one gate-text block), split legs SC-2 (dispatch absent) / SC-3 (dispatch present), tests-v2/AGENTS.md evaluation mandate (clean-room session.yaml inspection, stderr helpers forbidden).
- [ ] 2. Baseline check (**direct**)
  - Run `git status` in `.opencode` submodule and parent repo; confirm zero pending changes and trunk-tip alignment; confirm the shared feature branch from .opencode#2456 stacked work is checked out.
  - Run `rm -f tmp/.behavior-run.lock` and `bash .opencode/tests-v2/test-enforcement.sh --list` to record the pre-existing scenario registry as baseline.

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

## Pre-Flight Guard (Mandatory)

Check your tool list for a tool named `task`.

- Present ⇒ orchestrator — proceed.
- Absent ⇒ sub-agent — do NOT execute any instruction below. Return `BLOCKED` with `ORCHESTRATOR_ONLY_SKILL_CARD` (cards) or `ORCHESTRATOR_ONLY_PLAN` (plans) and halt.

## Phase 1 — Finalization gate in brainstorming explore deck

- **Concern:** discussion-mode finalization separation
- **Files:** `.opencode/skills/brainstorming/tasks/explore.md`, `.opencode/skills/brainstorming/tasks/explore/exploration-workflow.md`
- **SCs:** SC-1
- **Depends on:** —
- **Entry:** pre-implementation steps PASS; deck in ungated state
- **Exit:** gate-text block present at the Step 6 → Step 7 transition; committed on the feature branch and pushed

### Code Path Coverage

- `explore.md` "Process Flow" digraph terminal edge ("User approves? → Invoke spec-creation") and "Operating Protocol" / "Exit Criteria" / "Key Behavioral Constraints" sections.
- `exploration-workflow.md` "Step 7" section and its hard-gate precedent block; "Exit Criteria" wording.

### Cross-Cutting SCs

- R-4 (vocabulary separation) is cross-cutting across SC-1, SC-2, SC-3 — the gate text and both scenario legs must keep finalization distinct from `approved`/`go`.

### Interface Boundaries

- Handoff contract unchanged: `handoff.yaml` / `handoff-pointer.yaml` schema and `design_approved` field untouched; handoff written only at the gated transition.

### State Transitions

- New discussion state `awaiting_finalization`: on non-finalization messages after design presentation → stay in `awaiting_finalization` (acknowledge, integrate, continue exploring); on recognized finalization signal → proceed to spec-creation dispatch. No persistent state affected.

### Cost frame

**Cost frame:** Editing the two deck files costs minutes — a bounded text edit at an existing hard-gate precedent in `exploration-workflow.md`. Skipping costs an entire silent pipeline entry per brainstorming session — the agent dispatches spec-creation on inferred approval and requirements defects surface at implementation review, multiplied by every future conversation. Correctness is the only metric.

### Steps

- [ ] 3. Step-specific pre-cleanup (**direct**)
  - `rm -f tmp/behavioral-evidence-*` is FORBIDDEN (evidence artifacts are preserved); instead remove stale per-step artifacts: `rm -f tmp/{issue-2457}/artifacts/pipeline-red-* tmp/{issue-2457}/artifacts/pipeline-green-* tmp/{issue-2457}/artifacts/pipeline-verify-* tmp/{issue-2457}/artifacts/pipeline-post-regression-*` if present.
- [ ] 4. pre-regression (**task-card**)
  - `task(..., prompt: "execute phase-0 task from test-driven-development")` — run regression test patterns before RED phase; record evidence under `tmp/{issue-2457}/artifacts/pipeline-pre-regression-*`.
- [ ] 5. pre-regression-verify (**task-card**)
  - `task(..., prompt: "execute verify task from verification-before-completion")` — verify pre-regression results before entering RED. Record evidence under `tmp/{issue-2457}/artifacts/pipeline-pre-regression-verify-*`.
- [ ] 6. RED — failing gate-presence check against the ungated deck (**task-card**)
  - `task(..., prompt: "execute red task from test-driven-development")` — establish the RED for SC-1's gate text: run the grep/read check asserting the explore deck carries an explicit single-mechanism finalization gate at the Step 6 → Step 7 transition (gate defined, non-finalization classification, discussion-mode hold) — it FAILS because the gate text does not exist yet. Record evidence under `tmp/{issue-2457}/artifacts/pipeline-red-*`.
  - The behavioral RED (dispatch absent/present) is delivered by the Phase 2 scenario runs per the dependency DAG; this RED establishes the deck-level failure now.
- [ ] 7. GREEN — add the gate text (**task-card**)
  - `task(..., prompt: "execute green task from test-driven-development")` — implement the minimum change that makes the RED PASS. Edit `.opencode/skills/brainstorming/tasks/explore.md`: hard gate on the "Process Flow" terminal edge; add the `awaiting_finalization` state to Operating Protocol / Key Behavioral Constraints; revise Exit Criteria wording so approval is an explicit finalization signal, not "design incrementally approved".
  - Edit `.opencode/skills/brainstorming/tasks/explore/exploration-workflow.md`: hard gate at Step 7 defining finalization-signal semantics (recognized, unforgeable user statement the design is final — never agent inference), non-finalization classification (refinements, corrections, clarification answers → discussion mode), and the `approved`/`go` vocabulary-separation note via Read-link.
- [ ] 8. Verify gate text present (**direct**)
  - grep both files for the gate block, non-finalization classification, and vocabulary-separation note; confirm no conflation of finalization with implementation authorization; confirm Read-link pattern for any cross-references. Record evidence under `tmp/{issue-2457}/artifacts/pipeline-verify-*`.
- [ ] 9. post-regression (**task-card**)
  - `task(..., prompt: "execute phase-4 task from test-driven-development")` — run regression test patterns after GREEN (content-verification suite where applicable; deck edits are markdown, so no Python lint gates apply).
- [ ] 10. verify (**task-card**)
  - `task(..., prompt: "execute verify task from verification-before-completion")` — verify SC-1's gate-text criterion against the evidence artifacts.
- [ ] 11. COMMIT + PUSH (**direct**)
  - `git add .opencode/skills/brainstorming/tasks/explore.md .opencode/skills/brainstorming/tasks/explore/exploration-workflow.md && git commit -m "brainstorming: add finalization gate at explore terminal transition"`.
  - **In-plan procedure (deviation #WF-REF-GAP-PUSH):** the behavioral-variant PUSH step has no entry in the implementation-workflow reference card; per the 091-incremental-build.md behavioral variant, PUSH is mandated and this plan executes it as direct orchestrator steps — no card reference is claimed. PUSH now — `git push`, fresh `git fetch`, verify the commit is contained in a remote ref (`git branch -r --contains <sha>`) — required BEFORE any Phase 2 behavioral run.

### Phase 1 Completion

- VbC assertion: gate text present in both files (grep evidence), commit contains both files, push containment verified. Report `[item 1] [PASS|FAIL]`.

**Concern transition:** deck gate committed and pushed → Phase 2 behavioral scenarios may run against the gated deck.

## Phase 2 — Behavioral enforcement scenarios (refinement-hold + finalization-permits)

- **Concern:** behavioral proof of the blocking and permitting edges
- **Files:** `.opencode/tests-v2/behaviors/2457-sc1-finalization-gate.sh`, `.opencode/tests-v2/test-enforcement.sh`
- **SCs:** SC-2, SC-3
- **Depends on:** Phase 1 (commit + push + remote-ref containment verified)
- **Entry:** Phase 1 completion PASS; stale lock removed
- **Exit:** scenario registered and both legs PASS via clean-room session.yaml inspection

### Code Path Coverage

- `test-enforcement.sh` SCENARIOS array, SCENARIO_TAGS map, FILE_SCENARIO_MAP — additive entries following the existing brainstorming registration entries.
- Scenario file `.opencode/tests-v2/behaviors/2457-sc1-finalization-gate.sh` — numbered-scenario pattern, behavioral runs via `with-test-home opencode run`, evaluation by clean-room `session.yaml` inspection (dispatch absent / present in the run's session actions).

### Cross-Cutting SCs

- R-4 cross-cutting: the finalization-run prompt must use a finalization phrasing that is NOT `approved`/`go`, proving vocabulary separation behaviorally.

### Interface Boundaries

- No harness or helper modification — the scenario uses existing `with-test-home` infrastructure only.

### State Transitions

- Run A (refinement-only message): agent must hold `awaiting_finalization` → spec-creation dispatch ABSENT in session actions.
- Run B (explicit finalization message): agent must pass the gate → spec-creation dispatch PRESENT in session actions.

### Cost frame

**Cost frame:** Writing the scenario + registration and running the two behavioral legs costs minutes of `with-test-home opencode run` execution each. Skipping costs a gate that exists only as prose — a rule change with no behavioral test is documentation, not enforcement, and the next agent silently bypasses it; a missing present-assertion leaves the gate's permission edge unproven and the pipeline unreachable. Correctness is the only metric.

### Steps

- [ ] 12. Step-specific pre-cleanup (**direct**)
  - `rm -f tmp/.behavior-run.lock` and any `tmp/{issue-2457}/artifacts/pipeline-red-*` / `pipeline-green-*` / `pipeline-verify-*` from Phase 1's step names if present (per-step pre-cleanup).
- [ ] 13. pre-regression (**task-card**)
  - `task(..., prompt: "execute phase-0 task from test-driven-development")` — run regression test patterns before RED phase; record evidence under `tmp/{issue-2457}/artifacts/pipeline-pre-regression-*`.
- [ ] 14. pre-regression-verify (**task-card**)
  - `task(..., prompt: "execute verify task from verification-before-completion")` — verify pre-regression results before entering RED. Record evidence under `tmp/{issue-2457}/artifacts/pipeline-pre-regression-verify-*`.
- [ ] 15. RED — scenario + registration, run A fails against ungated deck (**task-card**)
  - `task(..., prompt: "execute red task from test-driven-development")` — create `.opencode/tests-v2/behaviors/2457-sc1-finalization-gate.sh` following the numbered-scenario pattern: run A sends a refinement-only message (a design refinement/correction, no finalization signal), asserts spec-creation dispatch ABSENT via clean-room `session.yaml` inspection; run B sends an explicit finalization message (not `approved`/`go`), asserts dispatch PRESENT via session.yaml inspection. Stderr/stdout grep assertion helpers are FORBIDDEN.
  - Register in `test-enforcement.sh` SCENARIOS, SCENARIO_TAGS, FILE_SCENARIO_MAP following the existing brainstorming entries.
  - The refinement-only absent-assertion is the RED for SC-2 (and delivers the behavioral RED for SC-1): against the ungated deck it FAILS because the pre-gate agent dispatches. Record evidence under `tmp/{issue-2457}/artifacts/pipeline-red-*`.
- [ ] 16. GREEN — run A passes against gated deck (**task-card**)
  - `task(..., prompt: "execute green task from test-driven-development")` — with the Phase 1 gate committed and pushed (containment already verified), re-run run A: `bash .opencode/tests-v2/test-enforcement.sh --scenario 2457-sc1-finalization-gate` (run A leg) — the clean-room session.yaml inspection proves no spec-creation dispatch on the refinement-only message; assertion PASSES. Record evidence under `tmp/{issue-2457}/artifacts/pipeline-green-*`.
- [ ] 17. verify SC-2 (**task-card**)
  - `task(..., prompt: "execute verify task from verification-before-completion")` — verify SC-2: scenario registered (`--list` / `--list-tags` show the scenario and tag) and run A dispatch-absent assertion PASS via session.yaml inspection.
- [ ] 18. COMMIT — SC-2 slice (**direct**)
  - `git add .opencode/tests-v2/behaviors/2457-sc1-finalization-gate.sh .opencode/tests-v2/test-enforcement.sh && git commit -m "tests-v2: add 2457 finalization-gate scenario (refinement-hold leg)"`.
  - **In-plan procedure (deviation #WF-REF-GAP-PUSH):** the behavioral PUSH step has no reference-card entry; per the 091-incremental-build.md behavioral variant, PUSH is mandated and executes as direct orchestrator steps — no card reference is claimed. `git push`, fresh `git fetch`, verify remote-ref containment before the run B behavioral execution.
- [ ] 19. RED→GREEN — run B finalization leg (SC-3) (**task-card**)
  - RED: extend/execute the finalization leg of the scenario — run B asserts spec-creation dispatch PRESENT via session.yaml inspection; against a partially-correct gate (blocks everything) it FAILS. `task(..., prompt: "execute red task from test-driven-development")`.
  - GREEN: `task(..., prompt: "execute green task from test-driven-development")` — with the Phase 1 gate in place, run B PASSES: the gate permits dispatch exactly at the finalization transition (clean-room session.yaml shows the dispatch). Evidence under `tmp/{issue-2457}/artifacts/pipeline-green-*`.
- [ ] 20. post-regression + verify SC-3 (**task-card**)
  - `task(..., prompt: "execute phase-4 task from test-driven-development")` — regression patterns after GREEN.
  - `task(..., prompt: "execute verify task from verification-before-completion")` — verify SC-3: run B PASS via session.yaml inspection.
- [ ] 21. COMMIT — SC-3 slice (**direct**)
  - `git add .opencode/tests-v2/behaviors/2457-sc1-finalization-gate.sh && git commit -m "tests-v2: prove 2457 finalization-gate permission edge (run B)"`, then `git push` with fresh-fetch containment verification (**in-plan procedure, deviation #WF-REF-GAP-PUSH** — PUSH has no reference-card entry; mandated per the 091-incremental-build.md behavioral variant and executed as direct orchestrator steps).

### Phase 2 Completion

- VbC assertion: scenario registered (SCENARIOS/SCENARIO_TAGS/FILE_SCENARIO_MAP), run A and run B both PASS via session.yaml inspection, commits pushed with remote-ref containment. Report `[items 2, 3] [PASS|FAIL]`.

## Post-Implementation Steps

- [ ] 22. audit (**task-card**)
  - `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read `audit/tasks/verification-audit-investigator.md` first")` — followed by validator, evaluator, arbiter in sequence.
- [ ] 23. z3-check (**direct**)
  - `rm -f tmp/{issue-2457}/artifacts/pipeline-z3-check-*`, then run `.opencode/tools/solve check --state-path .opencode/.issues/2457/artifacts/state-z3-initial.yaml --contract-path .opencode/.issues/2457/artifacts/plan-problem.yaml` (goal: `state-z3-goal.yaml`) — both phases verified solvable in dependency order.
- [ ] 24. structural-checks (**task-card**)
  - `task(..., prompt: "execute checklist task from finishing-a-development-branch")` — lint/format gates for markdown (`mdformat --check`, `pymarkdownlnt`) as applicable, plus finishing checklist.
- [ ] 25. pre-pr-gate (**task-card**)
  - `task(..., prompt: "execute verify task from verification-before-completion")` — read all SC verdicts (SC-1, SC-2, SC-3); BLOCK if any FAIL. DONE_WITH_CONCERNS and EVIDENCE_TYPE_MISMATCH coerce to FAIL.
- [ ] 26. regression-check (**task-card**)
  - `task(..., prompt: "execute phase-4 task from test-driven-development")` — final regression check before PR.
- [ ] 27. review-prep (**task-card**)
  - `task(..., prompt: "execute review-prep from git-workflow-pr. Read `git-workflow-pr/tasks/review-prep.md` first")`.
- [ ] 28. create-pr (**task-card**)
  - `task(..., prompt: "execute create task from git-workflow-pr")` — stacked PR on the shared #2456 feature branch (squash per stacked strategy).
- [ ] 29. exec-summary (**task-card**)
  - `task(..., prompt: "execute completion task from completion-core")` — completion executive summary with `plan_created`-class lifecycle closure.

## Self-Remediation Protocol

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

## Exit Criteria

- C1: SC-1 gate text present in both deck files with non-finalization classification and vocabulary separation (grep + verify evidence).
- C2: SC-2 scenario registered in SCENARIOS/SCENARIO_TAGS/FILE_SCENARIO_MAP and run A dispatch-absent assertion PASS via clean-room session.yaml inspection.
- C3: SC-3 run B dispatch-present assertion PASS via clean-room session.yaml inspection.
- C4: All commits pushed with fresh-fetch remote-ref containment verified before each behavioral run.
- C5: Post-implementation gates (audit, z3-check, structural-checks, pre-pr-gate, regression-check) all PASS; PR created (stacked).

> **Enforcement gate:** All SCs must pass before this plan is complete.

## lifecycle_events

- timestamp: 2026-09-21T11:52:00Z (approximate; session start)
- event: plan_created
- plan_file: `.opencode/.issues/2457/plan.md`
- phase_count: 2
