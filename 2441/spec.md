# Spec: Early-termination semantic monitoring for behavioral runs (GREEN/HOPELESS signals + artifact checks)

> **Full spec and artifacts: [`.opencode/.issues/2441/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2441/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2441/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## 1. Intent and Executive Summary

### Problem Statement

The behavioral-test orchestrator launches an `opencode run` and does not act on the run while it executes. The §14 semantic monitor (`tests-v2/AGENTS.md` §14, `behaviors/helpers.sh` `__semantic_monitor()`) polls the live session DB and aborts on stall signals, but it (a) never inspects on-disk output artifacts in the test home (e.g., the scenario-expected plan.md), and (b) never terminates early when the evidence needed for a verdict has already landed — GREEN-capable runs and hopeless runs both burn the full 600-900s timeout.

### Root Cause / Motivation

`__semantic_monitor()` reads only the session DB event stream; the poll loop contains no artifact/file check and no success-shaped termination condition. The run can only end by natural exit or mechanical abort, so wasted-ceremony runtime is structural, not incidental. Wasted runs also delay behavioral feedback (DDL) and inflate CI wall-clock — solving this now directly shortens the inner loop the whole enforcement-test pipeline depends on.

### Approach Chosen

Extend each monitor poll into a three-signal semantic read: (a) latest tool calls from the session DB, (b) latest text/reasoning content, and (c) on-disk expected artifacts in the test home (scenario-declared via a new optional `BEHAVIOR_EXPECTED_ARTIFACT` variable). GREEN-signal termination fires when the expected artifact exists on disk AND the event stream contains at least one goal-relevant action, where goal-relevant is the concrete, per-scenario-declared criterion defined in §1.1. HOPELESS-signal termination fires on a cited-evidence judgment that the run can never achieve the scenario goal. Both reuse the existing kill + §10.5 export + diagnosis-record path; `behavior_run()` treats GREEN and HOPELESS terminations as loop-exiting (no blind retry), and early-terminated evidence is valid verdict input.

**Resumption callout:** termination is not the only recovery path. A monitored run that is still progressing may be **resumed** instead of killed — `opencode run --continue` / `--session <id>` per tests-v2 AGENTS.md §10.7 — for example when a wrapper dies but the session DB survives. Resumption applies to progressing runs only; GREEN/HOPELESS/mechanical terminations (evidence complete, or run judged unviable) are the correct path for early termination, and §14 SHALL document this distinction explicitly.

### 1.1 Goal-Relevant Action — Concrete Definition

A **goal-relevant action** is a tool call in the session event stream whose tool name matches an entry in the scenario's `BEHAVIOR_GOAL_ACTIONS` declaration — a new optional per-scenario variable holding a comma-separated list of tool names (e.g., `BEHAVIOR_GOAL_ACTIONS="write,edit"`). Matching is exact on tool name; no fuzzy or inferred matching. Binary-verifiable criterion:

- `BEHAVIOR_GOAL_ACTIONS` set and ≥1 declared tool name appears in the event stream → goal-relevant action present (verdict: YES).
- Otherwise (variable unset, or no declared tool name appears) → goal-relevant action absent (verdict: NO).

Consequence: when `BEHAVIOR_GOAL_ACTIONS` is unset, GREEN cannot fire (GREEN requires both signals); the scenario retains existing behavior exactly.

### Alternatives Considered & Why Discarded

- **Wait for natural run completion only (status quo)** — discarded: burns the full timeout for runs that already produced their evidence or can never succeed; directly contradicts the cost model (defect-discovery-latency discipline applies to harness runtime too).
- **External watchdog process outside `__semantic_monitor()`** — discarded: duplicates poll infrastructure, fragments the evidence trail across two loggers, and would bypass the established abort path contract (kill + §10.5 export + diagnosis YAML) that all existing signals reuse.
- **Tool-based success detection only (no on-disk artifact check)** — discarded: tool calls prove action, not deliverable; the artifact check anchors GREEN termination in a verifiable output.
- **Heuristic/inferred goal-relevance (any write-class call)** — discarded: not deterministic or binary-verifiable; an undeclared action list makes the GREEN condition un-auditable. The declared-list criterion is exact and greppable.

### Key Design Decisions

1. **GREEN requires BOTH artifact existence AND ≥1 declared goal action (`BEHAVIOR_GOAL_ACTIONS`)** — tradeoff: one extra per-scenario declaration vs. a fully deterministic, binary-verifiable GREEN condition with zero false positives from unrelated side effects.
2. **HOPELESS requires a cited-evidence judgment recorded in the poll log** — tradeoff: judgment overhead per poll vs. auditable protection against cutting off slow-but-viable runs.
3. **Reuse the existing abort path (kill + §10.5 export + diagnosis YAML) for all new terminations** — tradeoff: constrains the new signals to the current evidence schema (extended additively) vs. not duplicating kill/export logic.
4. **`BEHAVIOR_EXPECTED_ARTIFACT` and `BEHAVIOR_GOAL_ACTIONS` are optional per scenario; unset means the corresponding signal is skipped gracefully** — tradeoff: no coverage of undeclared intent vs. zero behavioral change for all existing scenarios.
5. **Terminal states are exclusive; GREEN/HOPELESS/ABORTED all exit the retry loop without blind retry** — tradeoff: one termination kind per run vs. the risk of mixing evidence from multiple terminations.

### User Intent / Original Prompt

Original request (issue .opencode#2441): the §14 semantic monitor does not check on-disk artifacts and never terminates early when the verdict evidence has already landed; add GREEN/HOPELESS early-termination signals with artifact checks and poll-log evidence records, plus a one-line discoverability pointer in the parent repo AGENTS.md.

## 2. Not Included

- **Changes to `opencode` itself** — the monitor observes runs from outside; modifying the CLI is a separate concern.
- **Test-framework harness behavior outside the monitor** — retry-loop, lock-file, and export machinery outside the monitor/`behavior_run()` termination boundary stays as-is.
- **Verdict-evaluation logic beyond early-termination evidence capture** — the verdict layer only gains early-terminated evidence as a valid input; how verdicts are computed is unchanged.
- **Artifact-only-generator exit-0 semantics** — unchanged; this spec only adds termination signals.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC-1 | A monitored behavioral run whose scenario-declared expected artifact (`BEHAVIOR_EXPECTED_ARTIFACT`) is produced mid-run, with `BEHAVIOR_GOAL_ACTIONS` set and ≥1 declared tool name present in the event stream, is terminated by the GREEN signal before the run's natural exit, and the poll log records both the artifact-existence check result and the matched goal-action tool name. | behavioral | Run a monitored scenario via `bash .opencode/tests-v2/with-test-home opencode run` (>=600s timeout; `rm -f tmp/.behavior-run.lock` first) where the expected artifact is produced mid-run; assert GREEN termination fires before natural exit and the poll log contains the artifact-existence record and the matched goal-action name. | `.opencode/tests-v2/AGENTS.md` §14; `.opencode/tests-v2/behaviors/helpers.sh` `__semantic_monitor()` |
| SC-2 | On GREEN termination, the run is killed, session.yaml is exported per §10.5, and a termination judgment is written recording the GREEN signal and its two evidence components. | behavioral | Same monitored scenario as SC-1; assert exported session.yaml exists per §10.5 and the judgment YAML records the GREEN signal with artifact + goal-action evidence. | `.opencode/tests-v2/AGENTS.md` §14, §10.5 |
| SC-3 | On GREEN termination, the `behavior_run()` retry loop exits without blind retry (no second run launched for the same scenario). | behavioral | Same monitored scenario as SC-1; assert exactly one run executes and the loop exits after GREEN termination. | `.opencode/tests-v2/behaviors/helpers.sh` `behavior_run()` |
| SC-4 | The verdict for an early-terminated (GREEN) run is evaluated from the captured evidence (exported session.yaml + poll log + termination judgment), and the verdict result matches the scenario's expected PASS outcome. | behavioral | Same monitored scenario as SC-1; assert the final verdict cites the captured evidence and matches the scenario's expected PASS outcome. | `.opencode/tests-v2/AGENTS.md` §14, §10.5 |
| SC-5 | A monitored run with `BEHAVIOR_EXPECTED_ARTIFACT` or `BEHAVIOR_GOAL_ACTIONS` unset exhibits no behavior change: no artifact signal read, no GREEN termination, existing monitor behavior identical to pre-change. | behavioral | Run an existing scenario without the new variables declared; assert no GREEN termination fires and monitor behavior (poll cadence, abort signals, exit) is unchanged. | `.opencode/tests-v2/AGENTS.md` §14; `.opencode/tests-v2/behaviors/helpers.sh` |
| SC-6 | A monitored behavioral run judged (with cited evidence) unable to achieve the scenario goal is terminated by the HOPELESS signal before the mechanical threshold/timeout, and the diagnosis YAML cites concrete event-stream evidence with the judgment recorded in the poll log. | behavioral | Run a monitored off-track scenario via `with-test-home opencode run`; assert HOPELESS termination fires before mechanical threshold/timeout, diagnosis YAML cites concrete event-stream evidence, and the poll log records the judgment. | `.opencode/tests-v2/AGENTS.md` §14; `.opencode/tests-v2/behaviors/helpers.sh` abort path |
| SC-7 | On HOPELESS termination, the run is killed and exported per §10.5, and the termination is recorded as a valid FAIL/behavior-diagnosis verdict input. | behavioral | Same monitored off-track scenario as SC-6; assert exported session.yaml per §10.5 and the verdict records a behavior-diagnosis FAIL. | `.opencode/tests-v2/AGENTS.md` §14, §10.5 |
| SC-8 | `tests-v2/AGENTS.md` §14 contains the early-termination mandate documentation: three-signal polling, GREEN/HOPELESS conditions, evidence contract (session.yaml + poll log + judgment), the no-blind-retry rule, and the resumption-vs-termination callout (R-10). | structural | grep §14 for the mandate subsections — all five present. | `.opencode/tests-v2/AGENTS.md` §14 |
| SC-9 | The parent-repo `AGENTS.md` contains a one-line pointer to the §14 early-termination mandate in the Testing Lessons Learned area. | structural | grep parent `AGENTS.md` for the pointer line. | `AGENTS.md` (parent repo) Testing Lessons Learned area |

## 4. Requirements

- R-1. `__semantic_monitor()` SHALL read three signals per poll: session-DB tool calls, text/reasoning content, and on-disk expected artifacts resolved against the run's test home.
- R-2. The harness SHALL support optional per-scenario declarations `BEHAVIOR_EXPECTED_ARTIFACT` and `BEHAVIOR_GOAL_ACTIONS`; when either is unset, the corresponding signal SHALL be skipped gracefully with no change to existing behavior.
- R-3. `__semantic_monitor()` SHALL fire GREEN termination only when the expected artifact exists on disk AND the session event stream contains at least one goal-relevant action, where goal-relevant is defined exactly per §1.1: a tool call whose name matches an entry in the scenario's `BEHAVIOR_GOAL_ACTIONS` comma-separated tool-name list. No inferred or fuzzy matching.
- R-4. On GREEN termination, the monitor SHALL kill the run, export session.yaml per §10.5, and write a termination judgment recording the artifact-existence result and the matched goal-action name; `behavior_run()` SHALL exit the retry loop without blind retry.
- R-5. `__semantic_monitor()` SHALL fire HOPELESS termination on a cited-evidence judgment that the run can never accomplish the scenario goal; the judgment SHALL cite concrete event-stream evidence and be recorded in the poll log.
- R-6. On HOPELESS termination, the monitor SHALL kill the run, export session.yaml per §10.5, write a behavior-diagnosis judgment, and the harness SHALL treat the termination as a valid FAIL/behavior-diagnosis verdict input.
- R-7. All new terminations SHALL reuse the existing abort path contract (kill + §10.5 export + diagnosis YAML + stderr banner) and SHALL NOT duplicate kill/export logic.
- R-8. `tests-v2/AGENTS.md` §14 SHALL document the early-termination mandate: three-signal polling, GREEN/HOPELESS conditions, the goal-relevant-action criterion (§1.1), evidence contract (session.yaml + poll log + judgment), and the no-blind-retry rule.
- R-9. Terminal states SHALL be exclusive — at most one termination kind per run.
- R-10. The §14 documentation SHALL include an explicit callout that monitored runs can be RESUMED when still progressing (`opencode run --continue` / `--session <id>` per §10.7) as an alternative to termination; resumption is for progressing runs only, never as a blind-retry substitute after GREEN/HOPELESS/mechanical termination.
- R-10. The parent repo `AGENTS.md` SHALL carry a one-line pointer to the §14 early-termination mandate. (The `.opencode` submodule pointer update rides the same parent commit per the universally mandated Submodule Pointer Updates rule — this is commit hygiene, not a success criterion.)
- R-11. Captured early-termination evidence (exported session.yaml + poll log + termination judgment) SHALL be a valid verdict input: the verdict evaluation SHALL consume it and produce the run's verdict from it.

## 5. Items

### Item 1 (SC-8): §14 early-termination mandate documentation

- RED: grep §14 of `.opencode/tests-v2/AGENTS.md` for absence of GREEN/HOPELESS/early-termination mandate — grep shows nothing (fails to find the mandate).
- GREEN: add the early-termination subsections (three-signal polling, GREEN/HOPELESS conditions, goal-relevant-action criterion, evidence contract, no-blind-retry rule) to §14; grep shows the mandate present.
- verify: content verification (grep) — no behavioral run required.
- commit: `.opencode/tests-v2/AGENTS.md` change committed in the submodule.

### Item 2 (SC-1): GREEN termination fires with poll-log evidence

- RED: run a monitored scenario (via `with-test-home opencode run`) with `BEHAVIOR_EXPECTED_ARTIFACT` and `BEHAVIOR_GOAL_ACTIONS` declared where the expected artifact is produced mid-run; assert no GREEN termination fires and the run burns the full budget.
- GREEN: implement artifact-signal read + goal-action matching (§1.1 criterion) + GREEN condition + GREEN termination branch in `__semantic_monitor()`; the scenario terminates early with both evidence records in the poll log.
- verify: behavioral run asserting pre-natural-exit GREEN termination and poll-log artifact + goal-action records.
- commit: `helpers.sh` change committed + pushed in the submodule (PUSH precedes the behavioral run per 091-incremental-build).

### Item 3 (SC-2): GREEN export + termination judgment

- RED: same scenario as Item 2 pre-implementation; assert no §10.5 export and no GREEN judgment exists on early termination (nothing fires).
- GREEN: wire GREEN termination onto the existing abort path (kill + §10.5 export + judgment YAML recording artifact result and matched goal action); the same scenario produces the exported session.yaml and judgment.
- verify: behavioral run asserting exported session.yaml and judgment YAML contents.
- commit: `helpers.sh` change committed + pushed in the submodule.

### Item 4 (SC-3): GREEN retry-loop exit without blind retry

- RED: same scenario pre-implementation; assert retry-loop behavior unchanged (no early exit).
- GREEN: implement GREEN-exit handling in the `behavior_run()` retry loop; the same scenario exits the loop after GREEN termination with exactly one run executed.
- verify: behavioral run asserting single-run loop exit.
- commit: `helpers.sh` change committed + pushed in the submodule.

### Item 5 (SC-4): Verdict evaluated from captured evidence

- RED: same scenario pre-implementation; early termination does not exist, so the verdict path for early-terminated evidence cannot be exercised (assert absence).
- GREEN: feed the captured evidence (session.yaml + poll log + judgment) into the existing verdict evaluation per R-11; the same scenario's verdict cites the captured evidence and matches the expected PASS outcome.
- verify: behavioral run asserting verdict-from-captured-evidence.
- commit: `helpers.sh` change committed + pushed in the submodule.

### Item 6 (SC-5): Unset-variable graceful skip

- RED: run an existing scenario with neither new variable declared; assert post-implementation behavior would differ (test written first shows the guard absent — the artifact/goal signal path is entered unconditionally).
- GREEN: add the per-scenario guards (R-2) so unset variables skip their signals gracefully; the existing scenario's monitor behavior is identical to pre-change.
- verify: behavioral run asserting unchanged behavior (no GREEN termination, identical poll cadence/exit).
- commit: `helpers.sh` change committed + pushed in the submodule.

### Item 7 (SC-6): HOPELESS termination with cited diagnosis

- RED: run a monitored off-track scenario; assert no HOPELESS termination (waits for mechanical threshold/timeout).
- GREEN: implement the HOPELESS judgment branch on the abort path with concrete-evidence citation; the scenario terminates early with a cited behavior-diagnosis FAIL and poll-log judgment record.
- verify: behavioral run asserting cited diagnosis YAML and poll-log judgment record.
- commit: `helpers.sh` change committed + pushed in the submodule.

### Item 8 (SC-7): HOPELESS export + verdict record

- RED: same off-track scenario pre-implementation; assert no early export/verdict path exists.
- GREEN: wire HOPELESS termination to kill + §10.5 export and the FAIL/behavior-diagnosis verdict input; the same scenario produces the export and a recorded behavior-diagnosis FAIL.
- verify: behavioral run asserting exported session.yaml and verdict record.
- commit: `helpers.sh` change committed + pushed in the submodule.

### Item 9 (SC-9): Parent-repo discoverability pointer

- RED: grep parent `AGENTS.md` Testing Lessons Learned area — pointer line absent.
- GREEN: add the one-line §14/early-termination pointer.
- verify: grep parent `AGENTS.md` for the pointer line.
- commit: parent repo commit containing the pointer line; stage the `.opencode` submodule pointer update in the same commit (commit hygiene per the parent repo's Submodule Pointer Updates rule — no standalone pointer commit).

## 6. Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| `.opencode/tests-v2/AGENTS.md` §14 Monitoring Protocol | Must be read before implementation — the mandate defines the poll protocol and hard-abort signals being extended | Satisfied |
| `.opencode/tests-v2/behaviors/helpers.sh` `__semantic_monitor()` / `behavior_run()` | Implementation base — extended, not replaced | Satisfied |
| `.opencode/tests-v2/AGENTS.md` §10.5 export procedure | Reused as-is by all new terminations | Satisfied |
| 091-incremental-build (behavioral PUSH step) | Items 2-8 must commit+push before their behavioral runs | Satisfied (process rule) |

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1, R-2, R-3 | SC-1, SC-5 | 2, 6 |
| R-4 | SC-2, SC-3 | 3, 4 |
| R-5 | SC-6 | 7 |
| R-6 | SC-7 | 8 |
| R-7, R-9 | SC-2, SC-3, SC-7 | 3, 4, 8 |
| R-8 | SC-8 | 1 |
| R-10 | SC-9 | 9 |
| R-11 | SC-4 | 5 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| §14 Semantic Continuous Monitoring Mandate | doc | `.opencode/tests-v2/AGENTS.md` §14 | read (pre-spec inspection) |
| `__semantic_monitor()` / `behavior_run()` | code | `.opencode/tests-v2/behaviors/helpers.sh` | read + grep (pre-spec inspection; artifact check confirmed absent, 0 hits) |
| §10.5 export procedure | doc | `.opencode/tests-v2/AGENTS.md` §10.5 | read (pre-spec inspection) |
| `BEHAVIOR_EXPECTED_ARTIFACT` / `BEHAVIOR_GOAL_ACTIONS` | code (not yet existing) | `.opencode/tests-v2/` | grep — 0 hits, declared as new conventions by this spec |
| Parent repo `AGENTS.md` Testing Lessons Learned | doc | `AGENTS.md` (root repo) | read (pre-spec inspection) |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1..SC-4: Running the GREEN-termination behavioral tests costs minutes of execution time each — a bounded delay that surfaces false-positive GREEN conditions before they silently hand unverifiable verdicts to every downstream consumer. Skipping costs hours-to-days of diagnosis when early-terminated evidence is later found invalid at review time — the harness's core trust property erodes across every scenario.
- SC-5: Verifying unset-variable no-change costs one behavioral run. Skipping costs silent behavior drift in every existing scenario the moment the monitor changes.
- SC-6, SC-7: Running the HOPELESS-termination behavioral tests costs minutes of execution time. Skipping costs hours-to-days when un-cited hopeless judgments cut off viable runs or let hopeless runs burn the full timeout — and the poll log cannot explain why, destroying the audit trail.
- SC-8, SC-9: Verifying the documentation and pointer line costs grep invocations. Skipping costs weeks of drift where the parent-repo agent deck never learns the early-termination mandate exists and implementations proceed from stale guidance.

## 11. Edge Cases

- **Condition:** `BEHAVIOR_EXPECTED_ARTIFACT` or `BEHAVIOR_GOAL_ACTIONS` unset in a scenario. **Expected behavior:** corresponding signal skipped gracefully; existing behavior unchanged; GREEN cannot fire when either is unset. **Resolution:** per-item guard on each signal read (R-2, §1.1).
- **Condition:** Expected artifact exists but no declared goal action appears in the event stream. **Expected behavior:** GREEN MUST NOT fire; polling continues. **Resolution:** AND-condition with exact tool-name matching (R-3, §1.1).
- **Condition:** Slow-but-viable run judged HOPELESS incorrectly. **Expected behavior:** judgment MUST cite concrete evidence and be recorded in the poll log for audit. **Resolution:** cited-evidence constraint (R-5).
- **Condition:** GREEN and an existing abort signal both become eligible in the same poll. **Expected behavior:** at most one termination kind per run (exclusive terminal states). **Resolution:** precedence in the poll-loop state machine (R-9).
- **Condition:** Retry loop after early termination. **Expected behavior:** GREEN and HOPELESS terminations both exit the loop without blind retry; verdict evaluation consumes the captured evidence. **Resolution:** loop-control distinction (R-4, R-6).
- **Condition:** DB not yet provisioned (run just launched). **Expected behavior:** monitor remains IDLE until the DB appears, as today. **Resolution:** existing IDLE→POLLING transition unchanged.
- **Condition:** Concurrent runs sharing the test home. **Expected behavior:** artifact paths resolve against the run's own test home (same DB-discovery pattern as existing code). **Resolution:** per-run test-home resolution.

---

## 12. Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-09-09 | Initial spec | — | Orchestrator (spec-creation create) |
| 2026-09-09 | (1) Added §1.1 concrete goal-relevant-action definition (`BEHAVIOR_GOAL_ACTIONS` exact tool-name match); R-3, R-8, Key Design Decisions, Edge Cases updated. (2) Decomposed compound SC-1/SC-2/SC-3 into atomic SC-1..SC-9. (3) Rewrote Items to strict 1:1 SC mapping (9 items). | Validation findings 1-3 (D3 completeness/determinism; compound-SC atomicity; SC-to-item 1:1) | Developer via validation findings |
| 2026-09-09 | (1) SC-4 recast from counterfactual ("identical to what the same run would produce at natural completion") to the observable criterion: verdict evaluated from captured evidence (session.yaml + poll log + termination judgment) matching the scenario's expected PASS outcome. (2) Added R-11 (captured early-termination evidence SHALL be a valid verdict input); SC-4 traceability remapped from pseudo-requirement "(verdict capture)" to R-11. (3) SC-9 recast as pointer-line structural SC only; submodule-pointer staging moved to Item 9's commit step as commit hygiene (already universally mandated by Submodule Pointer Updates rule); R-10 reworded accordingly. (4) Restored analytical artifacts directory (regenerated against the 9-SC structure). (5) Fixed spec blockquote URL to the canonical `tree/issues-data/2441/` form. | Validation findings 1-3 from re-validation iteration 2; artifacts-absence warning | Developer via validation findings |

---

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
