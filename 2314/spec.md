---
number: 2314
title: "[BUG] Spec-creation → implementation can bypass writing-plans pipeline when spec contains SCs and affected files"
status: open
labels: []
created: 2026-08-21T02:09:25Z
updated: 2026-10-02T12:00:00Z
remote_issue: 2314
remote_url: "https://github.com/michael-conrad/.opencode/issues/2314"
promoted_at: 2026-08-23T21:00:00Z
promotion_type: retroactive_import
last_sync: 2026-08-23T21:00:00Z
author: michael-newsrx
---

## Intent and Executive Summary

**Problem Statement:** When a spec issue body contains success criteria (SCs) and affected file paths, a sub-agent can be dispatched directly to implementation from the spec content — bypassing the mandatory writing-plans pipeline entirely.

**Objective:** Add an enforcement gate at the spec-creation → implementation dispatch boundary that checks whether a local `plan.md` exists before allowing implementation dispatch, blocking with `PLAN_MISSING` when it does not.

**Approach Chosen:** Add the gate as routing entries in the skill deck (spec-creation SKILL.md and executing-plans SKILL.md), backed by a CRITICAL VIOLATION rule in `000-critical-rules.md` and a `PLAN_MISSING` vocabulary registration in the canonical dispatch-vocabulary table. Behavioral enforcement tests then prove the gate blocks plan-less dispatch and permits plan-bearing dispatch. Developer-directed addition: this issue's behavioral-run legs SHALL run under the tests-v2 §14 semantic continuous monitoring protocol.

**Revision 2026-10-02 (supervision termination bound + fixture sandbox):** Monitor-log evidence from the SC-5 behavioral run attempt 5 (`tmp/behavior-test-20261002-062454/2314-sc2-plan-absent-dispatch-red/monitor-attempt1.log` — 603+ polls over ~5 hours) exposes two supervision-layer defects: (1) the §14 monitor's mechanical aborts (identical_tool_input x5, stuck_task_dispatch) were suppressed by the R-2 progressing-directionally-continues rule, and when the max-polls budget was exceeded the monitor continued polling anyway — there is no absolute termination bound, so supervision polls endlessly with no terminal verdict (`MONITOR-COMPLETE ... final_classification=progressing-directionally`); (2) the run agent inside the behavioral test escaped the fixture sandbox — it operated on the REAL issue store (read the real `.issues/2314/plan.md` and spawned a `create plan #2314` task against the real issue) instead of staying within the injected fixture, producing endless pseudo-progress and contaminating the behavioral evidence. Atomic SCs SC-18 (absolute termination bound, root cause 6) and SC-19 (fixture issue-store sandbox, root cause 7) are added.

**Revision 2026-10-02 (bypass-path closure):** Behavioral evidence from SC-5 attempts 3-4 shows the spec-creation/executing-plans gate placement does not cover the observed bypass path: a plan-less but developer-authorized dispatch entering implementation via the git-workflow pre-work / test-driven-development RED dispatch path NEVER traverses the spec-creation or executing-plans skill cards, so the boundary gate is unreachable there. The plan-existence check is therefore additionally bound to the surfaces the bypass path actually traverses: the `git-workflow-branch` pre-work task and the `test-driven-development` RED task, each blocking with `PLAN_MISSING` when no approved `plan.md` exists at the canonical path.

**Alternatives Considered & Why Discarded:**

- Relying on orchestrator routing discipline alone (status quo) — rejected: the only enforcement was the orchestrator's own discipline, which failed in the observed session; no mechanical gate exists to stop a sub-agent from receiving a spec body and implementing directly.
- Hard-failing at the approval-gate level for all implementation without a plan — rejected: over-broad; the defect is specifically the spec-creation → implementation dispatch boundary, and a broader gate risks false-positive blocks across unrelated dispatch surfaces.
- Runtime hook enforcement (session-enforcement.ts plugin) — rejected: the bypass happens at dispatch time inside agent routing logic, not at file-write time; a hook cannot observe the plan-existence precondition of a dispatch decision.

**Key Design Decisions:**

1. The gate lives at the dispatch boundary (routing entries in skill cards), not at file-write time — dispatch is where the bypass decision is made.
2. `PLAN_MISSING` is registered in the canonical dispatch-vocabulary table so every deck surface routes on the same reason code.
3. The permit leg (plan present → dispatch proceeds) is enforced as its own SC — a false-positive block is a pipeline-availability defect, not a lesser sibling of the block leg.
4. The behavioral-run supervision SCs (developer-directed; SC-9 through SC-13) are scoped strictly to this issue's scenario legs; the general §14 protocol already exists in tests-v2 and is NOT re-specified here.

**User Intent:** The developer flagged the observed bypass as a deck bug ("there is no path to not have a plan") and directed that every path from spec to implementation route through plan creation, with mechanical enforcement rather than discipline-only routing. The developer additionally directed (2026-10-01) that behavioral-run supervision for this issue's scenario legs follow the tests-v2 §14 semantic continuous monitoring protocol after an unmonitored ~59-minute synchronous run regression.

## Problem

When a spec issue body contains success criteria (SCs) and affected file paths, a sub-agent can be dispatched directly to implementation from the spec content — bypassing the mandatory writing-plans pipeline entirely.

## Root Cause

The DISPATCH_GATE in the skill deck relies on orchestrator routing discipline (professional agents follow the plan mandate). But there is no enforcement mechanism that prevents a sub-agent from receiving a spec body and implementing it directly. The spec-creation → writing-plans → implementation pipeline is documented as mandatory, but:

1. A sub-agent dispatched with "implement from this spec" has no gate to check whether a plan exists.
2. The orchestrator can skip `tasks/writing-plans/SKILL.md` entirely and still produce working code.
3. The only enforcement is the orchestrator's own discipline — which failed in the observed session (see Evidence).
**Root cause 4 (behavioral-run supervision defect; developer-directed):** the SC-5→SC-10 GREEN behavioral run for this issue executed synchronously and unmonitored (~59 minutes, no `monitor.log`/`determination.yaml` in the run's evidence directory) because (a) the plan step instruction text omits the tests-v2 §14 Semantic Continuous Monitoring Mandate and agent-supervisor protocol (no Read-link, no poll cadence), (b) the scenario leg `2314-sc2-plan-absent-dispatch-red.sh` calls `behavior_run` without `BEHAVIOR_SEMANTIC_MONITOR=1`, so `helpers.sh` took the synchronous blocking path, and (c) the instruction chain never surfaced the agent-supervisor mandate at `tests-v2/AGENTS.md` §14, so the dispatched run sub-agent improvised blind long-sleep polling with zero semantic checks between polls. SC-9 through SC-13 trace to this root cause.

**Root cause 5 (gate-placement defect on the bypass path; behavioral-evidence-derived):** The SC-5 behavioral attempts 3-4 (verdicts at `tmp/behavioral-evidence-2314-sc2-plan-absent-dispatch-red-GREEN-ollama-qwen3.8-27b-256k-gguf4-2/sc5-verdict.yaml` and `-1/sc5-verdict.yaml`) prove that a plan-less but developer-authorized dispatch entering implementation via the git-workflow pre-work / test-driven-development RED dispatch path never traverses the spec-creation or executing-plans skill cards — the PLAN_MISSING gate at the spec-creation → implementation boundary is unreachable on that path. The run agent implemented and committed inline with zero plan-existence check, rationalizing the waiver as developer authorization even with explicit Tier-1 non-overridability text present: prose alone does not stop the bypass; a mechanical check on a traversed surface is required. SC-14 through SC-17 trace to this root cause.

**Root cause 6 (monitor termination-bound defect; monitor-log evidence):** The SC-5 behavioral run attempt 5's monitor log (`tmp/behavior-test-20261002-062454/2314-sc2-plan-absent-dispatch-red/monitor-attempt1.log`) shows the §14 monitor polled 603+ times over ~5 hours with NO terminal verdict. Mechanical abort signals (identical_tool_input x5, stuck_task_dispatch x4-5 consecutive no-growth polls) were repeatedly suppressed by the R-2 progressing-directionally-continues rule (helpers.sh, citing .opencode#2456 SC-5/SC-22), and when the max-polls budget was exceeded the monitor kept polling anyway for progressing runs — the max-polls budget is a soft budget, not a bound: there is NO absolute termination condition that applies regardless of run classification. The run ended `MONITOR-COMPLETE polls=604 ... final_classification=progressing-directionally` — supervision terminated only because the run itself finished, not because the monitor bounded it. SC-18 traces to this root cause.

**Root cause 7 (fixture sandbox escape defect; session-evidence-derived):** The run agent inside the SC-5 behavioral test operated on the REAL issue-store data instead of staying within the injected fixture: it read the real `.issues/2314/plan.md` and spawned a `create plan #2314` task against the real issue (visible in the monitor poll event stream: `running=["task:{\"description\": \"create plan #2314\", ...`). The fixture did not redirect issue-store access, so the run agent's work targeted production issue data — producing endless pseudo-progress (the run agent was "verifying a plan it had written to the real store") and contaminating the behavioral evidence: the observed behavior is not the fixture-scoped gate behavior SC-5 is meant to test. SC-19 traces to this root cause.

## Evidence

During a session for the Butter repo (NewSRX-Tech-LLC/Butter), a spec for issue #260 (import rewires) was dispatched directly to a clean-room sub-agent as "implement issue #260 from the spec" without going through writing-plans — skipping plan creation, artifact generation, Z3 solving, and plan validation.

The user identified the bypass: "there is no path to not have a plan" and flagged it as a deck bug.

## Fix

Add an enforcement gate at the spec-creation → implementation boundary that checks whether a local plan.md file exists before allowing implementation dispatch. If no plan exists, the dispatch SHALL be BLOCKED with `PLAN_MISSING`. The plan-existence check SHALL additionally be bound to the surfaces the bypass path actually traverses — the git-workflow pre-work boundary and the test-driven-development RED dispatch boundary — blocking with `PLAN_MISSING` when no approved plan.md exists at the canonical path. Developer-directed addition: this issue's behavioral run legs SHALL run under semantic monitoring per tests-v2 §14. Developer-directed additions (2026-10-02, regression-derived): the §14 monitor SHALL enforce an absolute termination bound that terminates even progressing runs with a terminal classification, and this issue's behavioral scenario fixtures SHALL sandbox issue-store access to the injected fixture data.

## Severity

Process-integrity defect. Bypassing plan creation means phase decomposition, dependency DAG analysis, Z3 constraint solving, and SC-coverage validation are all skipped — increasing defect-discovery-latency.

## Not Included (Scope Boundary)

- **General §14 protocol re-specification is out of scope — except the absolute termination bound.** The §14 Semantic Continuous Monitoring Mandate already exists in `tests-v2/AGENTS.md`; its poll cadence and abort semantics are NOT re-specified here. The developer-directed absolute termination bound (R-10 / SC-18) is an additive amendment to the monitor implementation (`helpers.sh`) and §14 documentation, explicitly IN scope.
- **Gate enforcement for dispatch boundaries other than the spec-creation → implementation boundary, the git-workflow pre-work boundary, and the test-driven-development RED dispatch boundary is out of scope.** Other skill-to-skill handoffs are unaffected.
- **Changing plan-generation behavior is out of scope.** The writing-plans pipeline itself is unchanged; this spec only blocks dispatches that skip it.
- **Behavioral-run supervision for OTHER issues' scenario legs is out of scope.** SC-9 through SC-13 apply only to the 2314 scenario legs and this issue's plan run-step instruction text.

## Requirements

- **R-1:** The spec-creation SKILL.md SHALL carry a gate at the spec-creation → implementation dispatch boundary that checks `plan.md` existence before allowing implementation dispatch and blocks with `PLAN_MISSING` when the plan is absent.
- **R-2:** The executing-plans SKILL.md SHALL carry the same gate routing so plan-bearing and plan-less dispatch attempts route on `PLAN_MISSING` consistently.
- **R-3:** `000-critical-rules.md` SHALL carry a CRITICAL VIOLATION entry (PLAN_MISSING) classifying implementation dispatch without an approved plan as a Tier 1 violation.
- **R-4:** The canonical dispatch-vocabulary table (`reference/skill-card-description-standards.md`) SHALL register `PLAN_MISSING` as a vocabulary entry.
- **R-5:** A behavioral run executed through the enforcement harness SHALL be blocked with `PLAN_MISSING` when no `plan.md` exists at the expected path, and SHALL NOT be blocked with `PLAN_MISSING` when a `plan.md` exists at the expected path.
- **R-6:** A registered behavioral enforcement scenario (invocable via `test-enforcement.sh --scenario <name>`) SHALL demonstrate the gate blocks plan-less dispatch end-to-end and permits plan-bearing dispatch end-to-end.
- **R-7:** Every behavioral `opencode run` leg in this issue's scenarios SHALL run with `BEHAVIOR_SEMANTIC_MONITOR=1` enabled, and the run instruction text (plan steps) SHALL carry a Read-link to the §14 mandate; supervised runs SHALL follow the §14 semantic poll protocol (poll intervals no longer than 300s with full semantic checks of the live session-DB event stream between polls; abort on any §14 hard-abort signal with kill + §10.5 export + recorded semantic diagnosis).
- **R-8:** The `git-workflow-branch` pre-work task (`git-workflow-branch/tasks/pre-work.md`) SHALL carry a plan-existence gate entry that checks for an approved `plan.md` at the canonical path before allowing the pre-work (branch creation / work begin) step to complete, blocking with `PLAN_MISSING` when no plan exists.
- **R-9:** The `test-driven-development` RED task (`test-driven-development/tasks/red.md`) SHALL carry the same plan-existence gate entry at the RED dispatch boundary, blocking with `PLAN_MISSING` when no approved `plan.md` exists at the canonical path.
- **R-10:** The §14 monitor implementation (`helpers.sh`) SHALL enforce an absolute termination bound — a wall-clock deadline and/or hard max-polls ceiling, each configurable via a documented environment knob — that terminates the run and records a terminal classification (`terminate-with-root-cause`) even when the run's latest classification is `progressing-directionally`; suppression rules (e.g., the R-2 progressing-directionally-continues rule) may defer individual mechanical abort signals but SHALL NOT defeat the absolute bound. The bound and the env knob SHALL be documented in `tests-v2/AGENTS.md` §14.
- **R-11:** The 2314 behavioral scenario fixtures SHALL sandbox issue-store access so the run agent inside the behavioral test can only reach the injected fixture issue data — it SHALL NOT read or write real `{issues_prefix}/{N}/` data outside the fixture. Fixture setup SHALL establish the isolation, and the run's session evidence SHALL show no access to real issue-store paths outside the fixture.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | The spec-creation SKILL.md contains a gate entry at the spec-creation → implementation dispatch boundary that checks `plan.md` existence and routes to `PLAN_MISSING` blocking when the plan is absent | structural | Content inspection of `.opencode/skills/spec-creation/SKILL.md` |
| SC-2 | The executing-plans SKILL.md contains the same gate routing for the plan-bearing/plan-less dispatch decision | structural | Content inspection of `.opencode/skills/executing-plans/SKILL.md` |
| SC-3 | `000-critical-rules.md` contains a CRITICAL VIOLATION entry for `PLAN_MISSING` (implementation dispatch without an approved plan) classified as Tier 1 | structural | Content inspection of `.opencode/guidelines/000-critical-rules.md` |
| SC-4 | The canonical dispatch-vocabulary table registers `PLAN_MISSING` as a routing vocabulary entry | structural | Content inspection of `.opencode/reference/skill-card-description-standards.md` |
| SC-5 | A dispatch attempt executed through a real `opencode run` with no `plan.md` present at the expected path is BLOCKED with `PLAN_MISSING` — the blocked outcome is visible in stderr behavioral evidence | behavioral | Enforcement harness `opencode run` stderr evidence with `BEHAVIOR_SEMANTIC_MONITOR=1` enabled |
| SC-6 | A dispatch attempt executed through a real `opencode run` with `plan.md` present at the expected path proceeds WITHOUT a false-positive `PLAN_MISSING` block — the dispatch-proceeding outcome is visible in stderr behavioral evidence | behavioral | Enforcement harness `opencode run` stderr evidence with `BEHAVIOR_SEMANTIC_MONITOR=1` enabled |
| SC-7 | The registered behavioral enforcement scenario (via `test-enforcement.sh --scenario <name>`) demonstrates the gate blocks plan-less dispatch end-to-end | behavioral | Executing the scenario's block leg and observing the blocked outcome |
| SC-8 | The registered behavioral enforcement scenario demonstrates the gate permits plan-bearing dispatch end-to-end | behavioral | Executing the scenario's permit leg and observing the dispatch-proceeding outcome |
| SC-9 | Every 2314 scenario leg script sets `BEHAVIOR_SEMANTIC_MONITOR=1` before its `behavior_run` invocation | structural | Content inspection of the 2314 scenario leg scripts |
| SC-10 | The plan run-step instruction text carries a Read-link to the §14 mandate — Read [§14 Semantic Continuous Monitoring Mandate (Behavioral Runs)](../../tests-v2/AGENTS.md) | structural | Content inspection of the plan run-step instruction text |
| SC-11 | A monitored behavioral run of a 2314 scenario leg produces §14 monitor evidence (poll log / `monitor.log` / `determination.yaml`) recorded alongside `session.yaml` per §14 step 6 | behavioral | Executing a supervised run leg and inspecting the monitor evidence artifacts |
| SC-12 | The supervised run's poll intervals are no longer than 300s with full semantic checks of the live session-DB event stream between polls | behavioral | Inspecting the monitor poll timestamps and semantic-check records from the supervised run's `monitor.log` |
| SC-13 | Any §14 hard-abort signal during the supervised run is handled per §14 (kill + §10.5 export + recorded semantic diagnosis) | behavioral | Induced-abort verification: the verification method for SC-13 SHALL exercise the abort path deterministically by injecting a hard-abort during a supervised run (killing the run mid-poll in a controlled test invocation) and asserting the §14 handling (kill + §10.5 export + recorded semantic diagnosis) via the resulting artifacts |
| SC-14 | The `git-workflow-branch` pre-work task contains a plan-existence gate entry that checks for an approved `plan.md` at the canonical path and blocks with `PLAN_MISSING` when the plan is absent | structural | Content inspection of `.opencode/skills/git-workflow-branch/tasks/pre-work.md` |
| SC-15 | The `test-driven-development` RED task contains the same plan-existence gate entry at the RED dispatch boundary, blocking with `PLAN_MISSING` when the plan is absent | structural | Content inspection of `.opencode/skills/test-driven-development/tasks/red.md` |
| SC-16 | A plan-less, developer-authorized dispatch executed through a real `opencode run` that enters implementation via the git-workflow pre-work path is BLOCKED with `PLAN_MISSING` before any file modification — the blocked outcome is visible in stderr behavioral evidence | behavioral | Enforcement harness `opencode run` stderr evidence with `BEHAVIOR_SEMANTIC_MONITOR=1` enabled |
| SC-17 | A plan-less, developer-authorized dispatch executed through a real `opencode run` that enters implementation via the test-driven-development RED dispatch path is BLOCKED with `PLAN_MISSING` before any test-writing or implementation work — the blocked outcome is visible in stderr behavioral evidence | behavioral | Enforcement harness `opencode run` stderr evidence with `BEHAVIOR_SEMANTIC_MONITOR=1` enabled |
| SC-18 | The §14 monitor enforces an absolute termination bound (wall-clock deadline and/or hard max-polls ceiling via a documented env knob) that terminates the run and records a terminal classification (`terminate-with-root-cause`) even when the run's latest classification is `progressing-directionally` — suppression rules may defer mechanical aborts but do not defeat the bound | behavioral | Controlled test invocation: a supervised run exceeding the bound while classifying `progressing-directionally` is terminated with the terminal classification recorded in the monitor artifacts (monitor.log / determination.yaml); env-knob documentation in `tests-v2/AGENTS.md` §14 asserted structurally as a method step |
| SC-19 | The 2314 behavioral scenario fixtures sandbox issue-store access — the run agent inside the behavioral test can only reach the injected fixture issue data and never reads/writes real `{issues_prefix}/{N}/` data outside the fixture | behavioral | Fixture-setup inspection (structural assertion that the setup establishes issue-store isolation) plus behavioral session evidence (session.yaml / monitor event stream shows no read/write of real issue-store paths outside the fixture) |

### Per-SC Detail

**SC-1 (structural):** Verified by content inspection of `.opencode/skills/spec-creation/SKILL.md`.

**SC-2 (structural):** Verified by content inspection of `.opencode/skills/executing-plans/SKILL.md`.

**SC-3 (structural):** Verified by content inspection of `.opencode/guidelines/000-critical-rules.md`.

**SC-4 (structural):** Verified by content inspection of `.opencode/reference/skill-card-description-standards.md`.

**SC-5 (behavioral):** Verified via the enforcement harness with `BEHAVIOR_SEMANTIC_MONITOR=1` enabled.

**SC-6 (behavioral):** Verified via the enforcement harness with `BEHAVIOR_SEMANTIC_MONITOR=1` enabled.

**SC-7 (behavioral):** Verified by executing the scenario's block leg and observing the blocked outcome.

**SC-8 (behavioral):** Verified by executing the scenario's permit leg and observing the dispatch-proceeding outcome.

**SC-9 (structural):** Verified by content inspection of the scenario leg scripts.

**SC-10 (structural):** Verified by content inspection of the plan run-step text.

**SC-11 (behavioral):** Verified by executing a supervised run leg and inspecting the monitor evidence artifacts.

**SC-12 (behavioral):** Verified by inspecting the supervised run's monitor poll records.

**SC-13 (behavioral):** Verified via the induced-abort path: the verification method for SC-13 SHALL exercise the abort path deterministically by injecting a hard-abort during a supervised run (killing the run mid-poll in a controlled test invocation) and asserting the §14 handling (kill + §10.5 export + recorded semantic diagnosis) from the resulting artifacts. This makes SC-13 unconditionally verifiable — the abort path is exercised by the test itself rather than depending on a run that may complete without an abort signal.

**SC-14 (structural):** Verified by content inspection of `.opencode/skills/git-workflow-branch/tasks/pre-work.md`.

**SC-15 (structural):** Verified by content inspection of `.opencode/skills/test-driven-development/tasks/red.md`.

**SC-16 (behavioral):** Verified via the enforcement harness with `BEHAVIOR_SEMANTIC_MONITOR=1` enabled — the run prompt authorizes implementation directly (no plan present); stderr evidence SHALL show `PLAN_MISSING` blocking before file modification.

**SC-17 (behavioral):** Verified via the enforcement harness with `BEHAVIOR_SEMANTIC_MONITOR=1` enabled — the run prompt authorizes implementation directly (no plan present); stderr evidence SHALL show `PLAN_MISSING` blocking at the RED dispatch boundary.

**SC-18 (behavioral):** Verified via a controlled test invocation in which a supervised run exceeds the absolute termination bound while its latest classification is `progressing-directionally`; the monitor artifacts (monitor.log / determination.yaml) from that invocation SHALL record termination with the `terminate-with-root-cause` terminal classification, proving suppression rules cannot defeat the bound. The presence of the documented env knob(s) in `tests-v2/AGENTS.md` §14 is asserted as a supporting structural method step within the same verification.

**SC-19 (behavioral):** Verified in two method steps: (1) fixture-setup inspection — structural assertion that the 2314 scenario fixture setup establishes issue-store isolation for the run agent; (2) behavioral session evidence — the run's session.yaml / monitor event stream shows the run agent performed no read or write of real `{issues_prefix}/{N}/` data outside the injected fixture. The deciding evidence is the behavioral session evidence.

## Per-SC Cost Frames

| SC | Cost of verification | Cost of skipping |
|----|---------------------|------------------|
| SC-1 | One file read of the skill card | Silent bypass path remains open for every spec-creation session |
| SC-2 | One file read of the skill card | Plan-bearing dispatches routed inconsistently across deck surfaces |
| SC-3 | One file read of the guideline | Tier 1 enforcement language absent — rule is a suggestion |
| SC-4 | One file read of the vocabulary table | Deck surfaces route on divergent reason codes |
| SC-5 | One behavioral run leg (~minutes, monitored) | Plan-less dispatch ships unblocked |
| SC-6 | One behavioral run leg (~minutes, monitored) | False-positive blocks silently break pipeline availability |
| SC-7 | One scenario execution (block leg) | End-to-end wiring unproven |
| SC-8 | One scenario execution (permit leg) | Permit path unproven — availability regression ships |
| SC-9 | Grep-level inspection of leg scripts | Regression recurs: unmonitored 59-minute burns with zero diagnostic yield |
| SC-10 | Grep-level inspection of plan run-step text | Run sub-agents never see the §14 mandate and improvise blind polling |
| SC-11 | One supervised run leg + artifact inspection | Monitor evidence absent — supervision unverifiable |
| SC-12 | Inspection of monitor poll timestamps | Long-sleep blind polling returns — zero semantic checks between polls |
| SC-13 | One induced-abort test invocation (kill a supervised run mid-poll in a controlled test) + inspection of the resulting §14 artifacts | Hung or looping runs burn full-timeout unmonitored |
| SC-14 | One file read of the task card | The bypass path's first traversed surface stays gate-free — branch creation proceeds with no plan |
| SC-15 | One file read of the task card | The RED dispatch boundary stays gate-free — implementation work begins with no plan |
| SC-16 | One behavioral run leg (~minutes, monitored) | The observed inline-implement-and-commit bypass recurs on the pre-work path |
| SC-17 | One behavioral run leg (~minutes, monitored) | The observed inline-implement-and-commit bypass recurs on the RED dispatch path |
| SC-18 | One bounded-monitor test invocation (a supervised run driven past the bound while progressing) + env-knob doc inspection | Supervision polls endlessly (~5-hour burns) with no terminal verdict — the exact attempt-5 regression recurs |
| SC-19 | Fixture sandbox implementation + one behavioral run whose session evidence is inspected for issue-store escape | Fixture-escaped runs contaminate behavioral evidence with real-issue pseudo-progress — verdicts become meaningless |

## Items

| Item | Deliverable | SCs |
|------|-------------|-----|
| I-1 | Gate entry in `.opencode/skills/spec-creation/SKILL.md` | SC-1 |
| I-2 | Gate routing in `.opencode/skills/executing-plans/SKILL.md` | SC-2 |
| I-3 | CRITICAL VIOLATION entry in `.opencode/guidelines/000-critical-rules.md` | SC-3 |
| I-4 | `PLAN_MISSING` registration in `.opencode/reference/skill-card-description-standards.md` | SC-4 |
| I-5 | Plan-absent dispatch leg (RED/GREEN behavioral) | SC-5 |
| I-6 | Plan-present dispatch leg (RED/GREEN behavioral) | SC-6 |
| I-7 | Registered scenario block leg | SC-7 |
| I-8 | Registered scenario permit leg | SC-8 |
| I-9 | Supervision configuration: env flag in 2314 leg scripts | SC-9 |
| I-10 | Supervision configuration: §14 Read-link in plan run-step text | SC-10 |
| I-11 | Supervised monitored run with §14 evidence artifacts | SC-11 |
| I-12 | Supervised run poll-interval compliance (≤300s, semantic checks between polls) | SC-12 |
| I-13 | Supervised run §14 hard-abort handling | SC-13 |
| I-14 | Plan-existence gate entry in `.opencode/skills/git-workflow-branch/tasks/pre-work.md` | SC-14 |
| I-15 | Plan-existence gate entry in `.opencode/skills/test-driven-development/tasks/red.md` | SC-15 |
| I-16 | Plan-less bypass-path block leg via pre-work path (RED/GREEN behavioral) | SC-16 |
| I-17 | Plan-less bypass-path block leg via RED dispatch path (RED/GREEN behavioral) | SC-17 |
| I-18 | Absolute termination bound in `helpers.sh` monitor loop + env knob documented in tests-v2 §14 | SC-18 |
| I-19 | Fixture issue-store sandbox in the 2314 scenario fixture setup | SC-19 |

## Dependencies

| Item | Depends On | Why |
|------|-----------|-----|
| I-5, I-6 | I-1, I-2, I-3, I-4 | The behavioral legs exercise the gate the deck changes create |
| I-7, I-8 | I-5, I-6 | The registered scenario re-uses the leg mechanics proven at item level |
| I-11 | I-9, I-10, I-7 | A supervised run requires configured supervision and a runnable leg |
| I-12, I-13 | I-11 | Poll cadence and abort handling are observed during the supervised run |
| I-9, I-10 | — | Supervision configuration is independent of gate behavior |
| I-14, I-15 | I-3, I-4 | The bypass-path gate entries route on the CRITICAL VIOLATION rule and the registered `PLAN_MISSING` vocabulary |
| I-16, I-17 | I-14, I-15 | The behavioral legs exercise the gate entries the task-card changes create |
| I-18 | I-11 | The termination bound is proven against a supervised monitored run — the run infrastructure SC-11 establishes |
| I-19 | I-7, I-8 | The fixture sandbox is applied to the 2314 scenario fixtures exercised by the registered legs |

## Traceability

| SC | Requirement | Item | Evidence Type | Verification |
|----|-------------|------|---------------|--------------|
| SC-1 | R-1 | I-1 | structural | File inspection |
| SC-2 | R-2 | I-2 | structural | File inspection |
| SC-3 | R-3 | I-3 | structural | File inspection |
| SC-4 | R-4 | I-4 | structural | File inspection |
| SC-5 | R-5 | I-5 | behavioral | `opencode run` stderr evidence |
| SC-6 | R-5 | I-6 | behavioral | `opencode run` stderr evidence |
| SC-7 | R-6 | I-7 | behavioral | Scenario block-leg execution |
| SC-8 | R-6 | I-8 | behavioral | Scenario permit-leg execution |
| SC-9 | R-7 | I-9 | structural | Leg script inspection |
| SC-10 | R-7 | I-10 | structural | Plan text inspection |
| SC-11 | R-7 | I-11 | behavioral | Supervised run + monitor evidence artifacts |
| SC-12 | R-7 | I-12 | behavioral | Monitor poll timestamp inspection |
| SC-13 | R-7 | I-13 | behavioral | Abort-handling record inspection |
| SC-14 | R-8 | I-14 | structural | File inspection |
| SC-15 | R-9 | I-15 | structural | File inspection |
| SC-16 | R-8 | I-16 | behavioral | `opencode run` stderr evidence |
| SC-17 | R-9 | I-17 | behavioral | `opencode run` stderr evidence |
| SC-18 | R-10 | I-18 | behavioral | Bounded-monitor test invocation + monitor artifacts |
| SC-19 | R-11 | I-19 | behavioral | Fixture-setup inspection + behavioral session evidence |

## Enforcement Gate

All SCs SHALL be verified with evidence-type-matched artifacts before completion: structural SCs (SC-1..SC-4, SC-9, SC-10, SC-14, SC-15) with file/artifact inspection evidence; behavioral SCs (SC-5..SC-8, SC-11..SC-13, SC-16..SC-19) with execution-based behavioral evidence from real `opencode run` executions. A behavioral SC verified only by structural or string evidence is EVIDENCE_TYPE_MISMATCH and SHALL be recorded as FAIL. No DONE_WITH_CONCERNS coercion applies.

## Edge Cases

- **Plan exists but is stale relative to the spec:** the gate checks existence only — staleness is governed by the coherence gate, not this gate. A stale-but-present plan does NOT trigger `PLAN_MISSING`.
- **Plan at an unexpected path:** the gate checks the canonical path `{issues_prefix}/{N}/plan.md`; a plan elsewhere is treated as absent (block is correct behavior, not a false positive).
- **Monitor flag unset in an inherited environment:** `helpers.sh` defaults to no-monitor; SC-9 requires each leg script to set the flag explicitly rather than relying on ambient environment state.
- **Run aborts mid-poll:** §14 hard-abort handling applies (kill + §10.5 export + recorded semantic diagnosis); an aborted run is not silently retried as unmonitored (SC-13). Because a supervised run may complete without an abort signal, SC-13's verification method exercises the abort path deterministically via an induced abort (controlled mid-poll kill in a test invocation) rather than waiting for a spontaneous abort.
- **Both block and permit legs in one scenario invocation:** legs run sequentially and are asserted independently; a permit-leg failure does not mask a block-leg pass (and vice versa).
- **Developer-authorized but plan-less dispatch:** developer authorization does NOT waive the gate — `PLAN_MISSING` is Tier 1 and never yields to authorization; SC-16 and SC-17 exercise exactly this case (authorized dispatch, no plan, expected block).
- **Bypass path never reaches spec-creation/executing-plans cards:** a dispatch entering implementation directly via git-workflow pre-work or TDD RED never loads those skill cards — the gate at that boundary is unreachable; this is why the plan-existence check is duplicated onto the traversed surfaces (SC-14, SC-15) rather than relying on the boundary entries alone.
- **Progressing run exceeding the polling budget:** under R-2 the monitor defers mechanical aborts for progressing runs, but the absolute termination bound (SC-18) is not deferrable — a progressing run that exceeds the wall-clock deadline or hard max-polls ceiling is terminated with a `terminate-with-root-cause` terminal classification regardless of classification.
- **Env knob unset:** the absolute termination bound SHALL have a documented default (not "unbounded"); SC-18 requires the bound to exist even when the env knob is unset.
- **Run agent attempts issue-store access in a sandboxed fixture:** with the fixture sandbox (SC-19) in place, attempts to read/write real issue-store paths outside the fixture are isolated (fail or never resolve to real data); the session evidence shows the attempt, and the behavioral verdict remains attributable to fixture-scoped behavior only.
- **Fixture sandbox vs. legitimate fixture-issue access:** access to the injected fixture issue data is permitted — the sandbox boundary is between the fixture store and the REAL `{issues_prefix}/{N}/` store, not an access prohibition entirely.

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|-----------------|-------------------|---------|
| Local docs | `tests-v2/AGENTS.md` §14 (Semantic Continuous Monitoring Mandate), §10.5 (post-timeout recovery) | Define the supervision protocol SC-9 through SC-13 reference |
| Direct source search | `helpers.sh` `__semantic_monitor` flag-gated path; `behavior_run` invocations in 2314 scenario legs | Confirm `BEHAVIOR_SEMANTIC_MONITOR=1` is the existing monitor gate (implemented for #2456) |
| Live session evidence | SC-2 GREEN run regression: ~59-minute unmonitored synchronous run, no `monitor.log`/`determination.yaml` in evidence directory | Root cause 4 derivation and SC-11..SC-13 justification |
| Canonical reference | `reference/skill-card-description-standards.md` dispatch-vocabulary table | Verify `PLAN_MISSING` registration surface and format |
| Behavioral evidence | `tmp/behavioral-evidence-2314-sc2-plan-absent-dispatch-red-GREEN-ollama-qwen3.8-27b-256k-gguf4-2/sc5-verdict.yaml` and `-1/sc5-verdict.yaml` | Root cause 5 derivation: plan-less authorized dispatch bypassed the boundary gate and implemented inline via pre-work/RED path |
| Monitor-log evidence | `tmp/behavior-test-20261002-062454/2314-sc2-plan-absent-dispatch-red/monitor-attempt1.log` (603+ polls, suppressed aborts, max-polls exceeded, `final_classification=progressing-directionally`) | Root cause 6 derivation: no absolute termination bound; SC-18 justification |
| Direct source search | `tests-v2/helpers.sh` monitor loop (R-2 progressing-directionally-continues suppression, max-polls handling) | Root cause 6 confirmation and SC-18 implementation surface |
| Session evidence | Monitor poll event stream showing `task:{"description": "create plan #2314", ...}` against the real issue (run agent fixture escape) | Root cause 7 derivation: fixture sandbox escape; SC-19 justification |
| Direct source search | `.opencode/skills/git-workflow-branch/tasks/pre-work.md`, `.opencode/skills/test-driven-development/tasks/red.md` | Confirm the traversed surfaces lack any plan-existence check and are the minimal correct gate surfaces |

## Affected Files

| File | Anchor | Changes |
|------|--------|---------|
| `.opencode/skills/spec-creation/SKILL.md` | spec-creation → implementation boundary routing | Add PLAN_MISSING gate entry |
| `.opencode/skills/executing-plans/SKILL.md` | dispatch routing section | Add gate routing |
| `.opencode/guidelines/000-critical-rules.md` | Tier 1 CRITICAL VIOLATION section | Add PLAN_MISSING entry |
| `.opencode/reference/skill-card-description-standards.md` | dispatch-vocabulary table | Register PLAN_MISSING |
| `.opencode/tests-v2/behaviors/2314-sc2-plan-absent-dispatch-red.sh` | `behavior_run` invocation | Set `BEHAVIOR_SEMANTIC_MONITOR=1` |
| `.opencode/tests-v2/behaviors/` (sibling 2314 scenario legs) | `behavior_run` invocation | Set `BEHAVIOR_SEMANTIC_MONITOR=1` |
| `.opencode/.issues/2314/plan-01-dispatch-gate-logic.md` | run-step instruction text | Add §14 Read-link |
| `.opencode/.issues/2314/plan-02-behavioral-enforcement.md` | run-step instruction text | Add §14 Read-link |
| `.opencode/skills/git-workflow-branch/tasks/pre-work.md` | Entry Criteria / Procedure (before branch creation completes) | Add plan-existence gate entry blocking with `PLAN_MISSING` |
| `.opencode/skills/test-driven-development/tasks/red.md` | Invocation / Entry (before RED work begins) | Add plan-existence gate entry blocking with `PLAN_MISSING` |
| `.opencode/tests-v2/helpers.sh` | Monitor loop (termination condition) | Add absolute termination bound (wall-clock deadline / hard max-polls ceiling via documented env knob) with `terminate-with-root-cause` terminal classification |
| `.opencode/tests-v2/AGENTS.md` | §14 Semantic Continuous Monitoring Mandate | Document the absolute termination bound and its env knob |
| `.opencode/tests-v2/behaviors/2314-sc2-plan-absent-dispatch-red.sh` (and sibling 2314 scenario fixture setup) | Fixture setup | Sandbox issue-store access to the injected fixture data (SC-19) |

## Revision History

- **2026-10-02 — Revision #5: developer-directed regression-derived SC additions (SC-18, SC-19).** Developer-directed revision after a second regression during the SC-5 behavioral run attempt 5 (monitor-log evidence: `tmp/behavior-test-20261002-062454/2314-sc2-plan-absent-dispatch-red/monitor-attempt1.log` — 603+ polls over ~5 hours, aborted-in-signal repeated `MONITOR-COMPLETE` with `final_classification=progressing-directionally` and no terminal verdict). Two evidence-backed defects addressed: (1) UNBOUNDED MONITOR POLLING — the §14 monitor's mechanical aborts (identical_tool_input x5, stuck_task_dispatch) were suppressed by the R-2 progressing-directionally-continues rule (helpers.sh, citing .opencode#2456 SC-5/SC-22), and when the max-polls budget was exceeded the monitor kept polling anyway for progressing runs — no absolute termination bound exists. Added root cause 6, R-10, atomic SC-18 (behavioral: absolute termination bound terminating a progressing run with `terminate-with-root-cause` record), item I-18. (2) FIXTURE SANDBOX ESCAPE — the run agent inside the behavioral test operated on REAL issue-store data (read the real `.issues/2314/plan.md`, spawned `create plan #2314` against the real issue) instead of staying within the injected fixture. Added root cause 7, R-11, atomic SC-19 (behavioral: fixture issue-store sandbox, verified via fixture-setup inspection plus behavioral session evidence), item I-19. Requirements count 9→11; root causes 5→7; SCs 17→19. Not Included first bullet amended (absolute termination bound is in scope); Enforcement Gate, Cost Frames, Items (I-18, I-19), Dependencies, Traceability, Edge Cases, Documentation Sources, and Affected Files (helpers.sh monitor loop; tests-v2/AGENTS.md §14; 2314 scenario fixture setup) extended. SC-1..SC-17 meaning unaltered. Linked plan regenerated: new Phase 5 (regression-hardening) carrying SC-18..SC-19; phase files plan-01..plan-04 unchanged; dependency contract updated (phase5 variable, invariant, entries). Analytical artifacts updated in place (NOT deleted). Authorized by developer directive in the revision dispatch context.

- **2026-10-02 — Validation-finding revision #4 (single FAIL: testability).** Per validation findings: SC-13 (§14 hard-abort handling) was conditionally verifiable only — if the supervised run completes without an abort signal, the verification method (inspecting abort-handling records from the run) could not produce evidence. Remediation (minimal option chosen): the SC-13 verification method now exercises the abort path deterministically by injecting a hard-abort during a supervised run (controlled mid-poll kill in a test invocation) and asserting the §14 handling (kill + §10.5 export + recorded semantic diagnosis) from the resulting artifacts. Updated: SC-13 table row (Verification Method), per-SC detail, cost frame, and the "Run aborts mid-poll" edge case. No SC set change (SC-1..SC-17 unchanged), no item change, no affected-files change — the linked plans remain current; analytical artifacts unaffected (testability-assessment already records the induced-abort requirement). Traceability unchanged: SC-13 still maps to R-7, I-13, and root cause 4. Authorized by developer directive in the revision dispatch context.

- **2026-10-02 — Validation-finding revision #3 (aggregate verdict FAIL, 3 checks).** Per validation findings: (1) provenance — corrected the 2026-10-01 Revision History entry, which falsely claimed the artifacts directory at `.opencode/.issues/2314/artifacts/` was "restored" when the directory does not exist; the wording now states the artifacts were regenerated; (2) artifact_cross_reference — the artifacts directory was entirely absent; ALL canonical analytical artifacts (blast-radius, concern-map, code-path-inventory, cross-cutting-matrix, interface-compatibility, state-analysis, testability-assessment, analysis-summary) were regenerated against the CURRENT spec (17 SCs, 9 requirements, root causes 1-5, affected files including the git-workflow pre-work and TDD RED task surfaces), each reflecting SC-1..SC-17; (3) shall_language_conformance — replaced two unqualified "must" occurrences at the SC-16 and SC-17 per-SC detail lines with SHALL ("stderr evidence SHALL show"). No SC meaning altered; SC-1..SC-17 set unchanged, so the linked plans (plan.md, plan-01..plan-04) remain current with the revised spec — no plan regeneration required. Authorized by developer directive in the revision dispatch context.

- **2026-10-02 — Bypass-path closure revision (root cause 5).** Behavioral evidence from SC-5 attempts 3-4 (verdicts at `tmp/behavioral-evidence-2314-sc2-plan-absent-dispatch-red-GREEN-ollama-qwen3.8-27b-256k-gguf4-2/sc5-verdict.yaml` and `-1/sc5-verdict.yaml`) shows a substantive gate-placement defect: a plan-less but developer-authorized dispatch entering implementation via the git-workflow pre-work / test-driven-development RED dispatch path NEVER traverses the spec-creation or executing-plans skill cards, so the PLAN_MISSING boundary gate is unreachable on the observed bypass path — the run agent implemented and committed inline with zero plan-existence check, rationalizing the waiver as developer authorization even with explicit Tier-1 non-overridability text present. Revision: added root cause 5; added R-8 (pre-work plan-existence gate) and R-9 (RED dispatch plan-existence gate); added atomic SC-14/SC-15 (structural text presence in `git-workflow-branch/tasks/pre-work.md` and `test-driven-development/tasks/red.md`), SC-16/SC-17 (behavioral block behavior on each bypass-path surface); added items I-14..I-17 with dependencies; extended Not Included boundary, Edge Cases (developer-authorized-but-planless; unreachable-boundary rationale), Documentation Sources, and Affected Files. Existing SC-1..SC-13 intent preserved unaltered. Authorized by developer directive in the revision dispatch context.
- **2026-10-01 — Added SC-5 (behavioral-run supervision mandate).** Developer-directed revision after a regression discovered during plan step 14 (SC-2 behavioral run): the SC-2 GREEN behavioral run executed synchronously and unmonitored (~59 minutes, no `monitor.log`/`determination.yaml` in the run's evidence directory). SC-1 through SC-4 unchanged. Authorized by developer directive in the revision dispatch context.
- **2026-10-01 — Validation-finding revision (aggregate verdict FAIL).** Restructured per validation findings: (1) added the full required spec structure — 6-field preamble, Not Included, Requirements (R-N SHALL), Items, Dependencies, Traceability, Enforcement Gate, per-SC Cost Frames, Documentation Sources, Edge Cases; (2) split compound SCs — SC-1's four deck surfaces split into SC-1..SC-4, SC-4's block+permit legs split into SC-7/SC-8; (3) converted the developer-directed behavioral-run supervision SC from the dual evidence type "behavioral + structural" into a single canonical behavioral SC (SC-10) plus a companion structural SC (SC-9), removing EVIDENCE_TYPE_MISMATCH; (4) added root cause 4 (behavioral-run supervision defect) so the supervision SC traces to a root cause, with the scope boundary declared in Not Included; (5) replaced unqualified "must" with SHALL throughout; (6) regenerated the analytical artifacts at `.opencode/.issues/2314/artifacts/` that the prior revision deleted (the artifacts were regenerated against the then-current spec — no historical artifact set existed to restore). SC-1..SC-4 intent preserved unaltered in meaning; the covered behavior does not shrink. Authorized by developer directive in the revision dispatch context.
- **2026-10-01 — Validation-finding revision #2 (aggregate verdict FAIL, 3 structural checks; 9 of 11 holistic dimensions PASS).** Per validation findings: (1) shall-language-conformance — replaced the single unqualified "MUST" at the Approach Chosen paragraph (behavioral-run legs sentence) with SHALL; (2) documentation-sources-column — converted the per-SC-heading Success Criteria section into the canonical 4-column SC table (ID / Criterion / Evidence Type / Verification Method), keeping per-SC detail sections below the table; (3) compound-sc and decomposition-criteria — decomposed compound SC-9 into atomic SC-9 (leg scripts set `BEHAVIOR_SEMANTIC_MONITOR=1`) and SC-10 (plan run-step text carries the §14 Read-link), and compound SC-10 into atomic SC-11 (§14 monitor evidence artifacts recorded alongside `session.yaml`), SC-12 (poll intervals ≤300s with full semantic checks between polls), and SC-13 (§14 hard-abort handling: kill + §10.5 export + recorded semantic diagnosis). Covered behavior preserved — no shrinkage; all other SC meanings unchanged; downstream sections (Cost Frames, Items, Dependencies, Traceability, Enforcement Gate, cross-references) renumbered to match. Analytical artifacts regenerated to the final SC numbering (blast-radius with all 8 affected files; concern-map matching current SC text). Authorized by developer directive in the revision dispatch context.
