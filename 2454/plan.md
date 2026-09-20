---
plan_schema_version: 1
issue: 2454
title: "Orchestrator-direct plan execution — task() only at plan-marked dispatch points"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 1
dispatch:
  - "P1: test-driven-development (pre-regression, red, green, post-regression, regression-check); verification-before-completion (pre-regression-verify, verify, pre-pr-gate); audit (audit); finishing-a-development-branch (structural-checks); git-workflow-pr (review-prep, create-pr); completion-core (exec-summary); orchestrator-direct (coherence gate, baseline check, commit-inline, z3-check)"
---

# Plan — .opencode#2454: Orchestrator-direct plan execution — task() only at plan-marked dispatch points

- **Issue:** .opencode/.issues/2454/spec.md

## Goal

Formalize the orchestrator-direct execution mandate across the executing-plans skill deck (SKILL.md, execute-phase.md, read-plan.md) and verify the pre-flight guard backstop end-to-end, using behavioral evidence (`opencode run` via `with-test-home`) for all four SCs.

## Architecture

Single phase P1 covering the executor-side concern boundary: wording tightening in the executing-plans deck (positive own-tool-call mandate, forwarding prohibition, per-step dispatch-mode execution) plus behavioral enforcement scenarios under `.opencode/tests-v2/`. No runtime code, no producer-side (writing-plans) changes, no guard semantics changes.

## Files

- `.opencode/skills/executing-plans/SKILL.md`
- `.opencode/skills/executing-plans/tasks/execute-phase.md`
- `.opencode/skills/executing-plans/tasks/read-plan.md`
- `.opencode/tests-v2/` (behavioral scenarios for plan-execution and guard behavior)

## Dispatch

Orchestrator-direct steps: coherence gate, baseline check, all commit-inline steps, z3-check. Task-card steps: pre-regression, pre-regression-verify, red, green, post-regression, verify (per item), audit, structural-checks, pre-pr-gate, regression-check, review-prep, create-pr, exec-summary.

## Blast Radius

Affected: executing-plans SKILL.md (wording tightening only), execute-phase.md (dispatch-mode procedure wording), read-plan.md (none expected), `.opencode/tests-v2/` scenarios. Unaffected: runtime code, plugins, tools, other skills, writing-plans plan-artifact-format reference. Interfaces unchanged and backward compatible (dispatch indicator grammar consumed as-is; state machine unchanged — mandate constrains behavior within `executing_phase` only).

## Cross-Cutting SCs

Context-cost allocation, authorization gates, verification honesty (behavioral evidence only — structural substitutes are EVIDENCE_TYPE_MISMATCH), and byline preservation per 080-code-standards apply across P1.

## Interface Boundaries

- executing-plans skill dispatch surface: unchanged, backward compatible.
- Plan step dispatch indicators (`(**direct**)` / `(**task-card**)`, default `direct`): unchanged, consumed as-is.

## State Transitions

`plan_not_read → plan_read → executing_phase → phase_complete → all_phases_complete` — unchanged by this plan; the mandate constrains behavior only within `executing_phase`.

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

## Enforcement Gate

> **Enforcement gate:** All SCs must pass before this plan is complete.

## Phase Table

| Phase | Name | Concern | SCs | Depends On | Step Range | Dispatch |
|-------|------|---------|-----|------------|------------|----------|
| 1 | executing-plans orchestrator-direct mandate (behavioral enforcement) | executing-plans skill deck only (SKILL.md, execute-phase.md, read-plan.md) | SC-1, SC-2, SC-3, SC-4 | none | 5-32 | direct (1-2, 25, 26) + task-card (3-4, 5-24, 27-32) |

## Pre-Implementation

- [ ] 1. Coherence gate `(**direct**)`
  - Verify the plan is coherent with the approved spec .opencode/.issues/2454/spec.md: SC set (SC-1..SC-4), phase decomposition (single phase P1), and evidence type (behavioral) all match the structure artifact.
  - If incoherent: BLOCKED with reason — do not proceed to baseline check.
- [ ] 2. Baseline check `(**direct**)`
  - Verify repository state: current branch is a feature branch for this issue, submodules clean and at trunk tip, working tree free of unrelated changes.
  - Verify the behavioral harness prerequisite: `.opencode/tests-v2/with-test-home` exists and is executable; `rm -f tmp/.behavior-run.lock` before any run.
- [ ] 3. Pre-regression `(**task-card**)` — skill: test-driven-development
  - Dispatch `task(..., prompt: "execute phase-0 task from test-driven-development")`.
  - Run regression test patterns before the first RED; first run `rm -f {project_root}/tmp/2454/artifacts/pipeline-pre-regression-*`.
  - Context: issue .opencode#2454, phase P1, behavioral evidence type mandatory.
- [ ] 4. Pre-regression verify `(**task-card**)` — skill: verification-before-completion
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Verify pre-regression results; first run `rm -f {project_root}/tmp/2454/artifacts/pipeline-pre-regression-verify-*`.
  - On FAIL: self-remediation protocol applies.

## Phase 1 — executing-plans orchestrator-direct mandate (behavioral enforcement)

**Concern:** executing-plans skill deck only (SKILL.md, execute-phase.md, read-plan.md) — executor-side scope per concern map. Producer side (writing-plans plan-artifact-format) and guard semantics are out of scope.

**Files:** `.opencode/skills/executing-plans/SKILL.md`, `.opencode/skills/executing-plans/tasks/execute-phase.md`, `.opencode/skills/executing-plans/tasks/read-plan.md`, `.opencode/tests-v2/` behavioral scenarios.

**SCs:** SC-1 (own-tool-call execution), SC-2 (forwarding prohibition), SC-3 (dispatch restricted to task-card-marked steps), SC-4 (guard backstop reason codes).

**Dependencies:** none. **Entry:** pre-implementation steps 1-4 PASS. **Exit:** all four item commits landed and verified.

**Code Path Coverage:** skill-deck documentation/enforcement text only; no runtime code paths (`no_runtime_code_paths: true` per code path inventory).

**Cross-Cutting SCs:** context-cost allocation, authorization gates, verification honesty (behavioral only), byline preservation.

**Interface Boundaries:** executing-plans dispatch surface unchanged; dispatch indicator grammar consumed as-is.

**State Transitions:** none altered — mandate constrains behavior within `executing_phase` only.

**Cost frame:** Running each behavioral scenario via `opencode run` through `with-test-home` costs minutes of execution time — a bounded delay that catches wholesale-delegation and mis-dispatch defects at the earliest gate. Skipping a behavioral run to save those minutes costs the full pipeline of rework when the defect surfaces downstream — hours to days of diagnosis, re-review, and re-CI, compounded by every plan executed under the unenforced deck. Correctness is the only metric.

### Item 1 — SC-1: Orchestrator own-tool-call execution on direct steps

- [ ] 5. RED — write failing behavioral enforcement test `(**task-card**)` — skill: test-driven-development
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
  - First run `rm -f {project_root}/tmp/2454/artifacts/pipeline-red-*`.
  - Author a behavioral scenario run via `opencode run` through `with-test-home` on a plan-execution scenario with direct steps; assert via stderr agent actions that the orchestrator reads the plan itself and executes direct steps with its own tool calls.
  - The assertion FAILS against the current unverified deck state — record the RED evidence artifact under `tmp/2454/artifacts/`.
  - SC reference: SC-1.
- [ ] 6. GREEN — make the test pass `(**task-card**)` — skill: test-driven-development
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
  - First run `rm -f {project_root}/tmp/2454/artifacts/pipeline-green-*`.
  - Tighten SKILL.md / execute-phase.md wording so the positive own-tool-call execution mandate is explicit — no structural rewrite (the deck already states the behavior).
  - GREEN condition: the SC-1 behavioral assertion PASSES on re-run.
  - SC reference: SC-1.
- [ ] 7. Post-regression `(**task-card**)` — skill: test-driven-development
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`.
  - First run `rm -f {project_root}/tmp/2454/artifacts/pipeline-post-regression-*`.
  - Run regression test patterns after the GREEN phase; confirm no existing scenario regressed.
- [ ] 8. Verify `(**task-card**)` — skill: verification-before-completion
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - First run `rm -f {project_root}/tmp/2454/artifacts/pipeline-verify-*`.
  - Verify SC-1 against its success criterion with behavioral evidence; structural or string substitutes are EVIDENCE_TYPE_MISMATCH and FAIL.
- [ ] 9. Commit `(**direct**)` — commit-inline (orchestrator runs git add/commit directly — no sub-agent dispatch)
  - Stage and commit the test and implementation together: `git add <SKILL.md, execute-phase.md, scenario files> && git commit -m "<message referencing SC-1>"`.
  - One atomic slice — test + change committed together; no co-author trailers during implementation commits.
  - SC reference: SC-1.

### Item 2 — SC-2: Forwarding prohibition (no wholesale delegation)

- [ ] 10. RED — write failing behavioral enforcement test `(**task-card**)` — skill: test-driven-development
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
  - First run `rm -f {project_root}/tmp/2454/artifacts/pipeline-red-*`.
  - Author a behavioral scenario run via `opencode run` through `with-test-home` on a plan-execution scenario; assert via stderr agent actions the absence of whole-plan/whole-phase forwarding into `task()` prompts.
  - The assertion FAILS against the current unverified deck state — record RED evidence.
  - SC reference: SC-2.
- [ ] 11. GREEN — make the test pass `(**task-card**)` — skill: test-driven-development
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
  - First run `rm -f {project_root}/tmp/2454/artifacts/pipeline-green-*`.
  - Tighten SKILL.md / execute-phase.md wording so the forwarding prohibition (no wholesale delegation of plan steps) is explicit — no structural rewrite.
  - GREEN condition: the SC-2 behavioral assertion PASSES on re-run.
  - SC reference: SC-2.
- [ ] 12. Post-regression `(**task-card**)` — skill: test-driven-development
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`.
  - First run `rm -f {project_root}/tmp/2454/artifacts/pipeline-post-regression-*`.
  - Run regression test patterns after the GREEN phase.
- [ ] 13. Verify `(**task-card**)` — skill: verification-before-completion
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - First run `rm -f {project_root}/tmp/2454/artifacts/pipeline-verify-*`.
  - Verify SC-2 against its success criterion with behavioral evidence.
- [ ] 14. Commit `(**direct**)` — commit-inline (orchestrator runs git add/commit directly — no sub-agent dispatch)
  - Stage and commit the test and implementation together: `git add <SKILL.md, execute-phase.md, scenario files> && git commit -m "<message referencing SC-2>"`.
  - SC reference: SC-2.

### Item 3 — SC-3: Dispatch restricted to plan-marked (task-card) steps

- [ ] 15. RED — write failing behavioral enforcement test `(**task-card**)` — skill: test-driven-development
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
  - First run `rm -f {project_root}/tmp/2454/artifacts/pipeline-red-*`.
  - Author a behavioral scenario on a mixed `(**direct**)` / `(**task-card**)` plan run via `opencode run` through `with-test-home`; assert dispatch occurs only at `task-card`-marked steps.
  - The assertion FAILS against the current unverified deck state — record RED evidence.
  - SC reference: SC-3.
- [ ] 16. GREEN — make the test pass `(**task-card**)` — skill: test-driven-development
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
  - First run `rm -f {project_root}/tmp/2454/artifacts/pipeline-green-*`.
  - Make per-step dispatch-mode language in execute-phase.md unambiguous: direct default; task-card only at marked steps. Unmarked steps are treated as direct.
  - GREEN condition: the SC-3 behavioral assertion PASSES on re-run — zero dispatches on direct steps, dispatch on task-card steps only.
  - SC reference: SC-3.
- [ ] 17. Post-regression `(**task-card**)` — skill: test-driven-development
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`.
  - First run `rm -f {project_root}/tmp/2454/artifacts/pipeline-post-regression-*`.
  - Run regression test patterns after the GREEN phase.
- [ ] 18. Verify `(**task-card**)` — skill: verification-before-completion
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - First run `rm -f {project_root}/tmp/2454/artifacts/pipeline-verify-*`.
  - Verify SC-3 against its success criterion with behavioral evidence.
- [ ] 19. Commit `(**direct**)` — commit-inline (orchestrator runs git add/commit directly — no sub-agent dispatch)
  - Stage and commit the test and implementation together: `git add <execute-phase.md, scenario files> && git commit -m "<message referencing SC-3>"`.
  - SC reference: SC-3.

### Item 4 — SC-4: Pre-flight guard backstop verified end-to-end

- [ ] 20. RED — write failing behavioral enforcement test `(**task-card**)` — skill: test-driven-development
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
  - First run `rm -f {project_root}/tmp/2454/artifacts/pipeline-red-*`.
  - Author a behavioral guard scenario run via `opencode run` through `with-test-home` where plan/skill-card content reaches a sub-agent; assert BLOCKED with reason code.
  - The assertion FAILS if the guard path is unverified — record RED evidence.
  - SC reference: SC-4.
- [ ] 21. GREEN — make the test pass `(**task-card**)` — skill: test-driven-development
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
  - First run `rm -f {project_root}/tmp/2454/artifacts/pipeline-green-*`.
  - No guard semantics change; verify and align SKILL.md references to the guard reason codes (guideline 023 canonical definition: `ORCHESTRATOR_ONLY_PLAN` for plans, `ORCHESTRATOR_ONLY_SKILL_CARD` for cards).
  - GREEN condition: the SC-4 behavioral assertion PASSES on re-run — BLOCKED reason codes present in sub-agent output.
  - SC reference: SC-4.
- [ ] 22. Post-regression `(**task-card**)` — skill: test-driven-development
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`.
  - First run `rm -f {project_root}/tmp/2454/artifacts/pipeline-post-regression-*`.
  - Run regression test patterns after the GREEN phase.
- [ ] 23. Verify `(**task-card**)` — skill: verification-before-completion
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - First run `rm -f {project_root}/tmp/2454/artifacts/pipeline-verify-*`.
  - Verify SC-4 against its success criterion with behavioral evidence (dual reason codes, one mechanism).
- [ ] 24. Commit `(**direct**)` — commit-inline (orchestrator runs git add/commit directly — no sub-agent dispatch)
  - Stage and commit the test and implementation together: `git add <SKILL.md, guard-verification scenario files> && git commit -m "<message referencing SC-4>"`.
  - SC reference: SC-4.

### Post-Implementation

- [ ] 25. Audit `(**task-card**)` — skill: audit
  - Dispatch `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")` — followed by validator, evaluator, arbiter in sequence.
  - First run `rm -f {project_root}/tmp/2454/artifacts/pipeline-audit-*`.
  - Adversarial audit of the deliverable against all four SCs.
- [ ] 26. Z3 check `(**direct**)` — orchestrator runs `.opencode/tools/solve check --state-path ... --contract-path ...` directly — no sub-agent dispatch
  - First run `rm -f {project_root}/tmp/2454/artifacts/pipeline-z3-check-*`.
  - Run Z3 constraint solver verification against the phase contract and state.
- [ ] 27. Structural checks `(**task-card**)` — skill: finishing-a-development-branch
  - Dispatch `task(..., prompt: "execute checklist task from finishing-a-development-branch")`.
  - First run `rm -f {project_root}/tmp/2454/artifacts/pipeline-structural-checks-*`.
  - Run the finishing checklist (lint, typecheck, etc.).
- [ ] 28. Pre-PR gate `(**task-card**)` — skill: verification-before-completion
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")` — reads all SC verdicts, BLOCKs if any FAIL.
  - First run `rm -f {project_root}/tmp/2454/artifacts/pipeline-pre-pr-gate-*`.
  - DONE_WITH_CONCERNS coerces to FAIL; EVIDENCE_TYPE_MISMATCH is FAIL.
- [ ] 29. Regression check `(**task-card**)` — skill: test-driven-development
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`.
  - First run `rm -f {project_root}/tmp/2454/artifacts/pipeline-regression-check-*`.
  - Final regression check before PR.
- [ ] 30. Review prep `(**task-card**)` — skill: git-workflow-pr
  - Dispatch `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")`.
  - Prepare PR review context.
- [ ] 31. Create PR `(**task-card**)` — skill: git-workflow-pr
  - Dispatch `task(..., prompt: "execute create task from git-workflow-pr")`.
  - Create the pull request (stacked strategy — one branch, squashed commits, one PR). Human-only merge — HALT after PR creation.
- [ ] 32. Executive summary `(**task-card**)` — skill: completion-core
  - Dispatch `task(..., prompt: "execute completion task from completion-core")`.
  - Generate the completion executive summary.

## Phase Completion Block — Phase 1

- VbC assertions: SC-1, SC-2, SC-3, SC-4 each have a behavioral PASS verdict with evidence artifacts under `tmp/2454/artifacts/`; all item commits landed in daisy-chain order; no structural/string substitute was accepted for any behavioral SC.

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

## Exit Criteria

- C1: SC-1 verified with behavioral evidence (own-tool-call execution on direct steps).
- C2: SC-2 verified with behavioral evidence (no whole-plan/whole-phase forwarding).
- C3: SC-3 verified with behavioral evidence (dispatch only at task-card-marked steps).
- C4: SC-4 verified with behavioral evidence (BLOCKED `ORCHESTRATOR_ONLY_PLAN` / `ORCHESTRATOR_ONLY_SKILL_CARD`).
- C5: All four item commits landed; audit, structural checks, pre-PR gate, and regression check PASS.
- C6: PR created (stacked) and HALT — human-only merge.

## Pre-Flight Guard (Mandatory)

Check your tool list for a tool named `task`.

- Present ⇒ orchestrator — proceed.
- Absent ⇒ sub-agent — do NOT execute any instruction below. Return `BLOCKED` with `ORCHESTRATOR_ONLY_SKILL_CARD` (cards) or `ORCHESTRATOR_ONLY_PLAN` (plans) and halt.
