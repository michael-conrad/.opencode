# Spec: Early-termination semantic monitoring for behavioral runs (GREEN/HOPELESS signals + artifact checks)

> **Full spec and artifacts: [`.opencode/.issues/2441/`](https://github.com/michael-conrad/.opencode/tree/issues-data/.opencode/.issues/2441/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2441/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## 1. Intent and Executive Summary

### Problem Statement

The behavioral-test orchestrator launches an `opencode run` and does not act on the run while it executes. The §14 semantic monitor (`tests-v2/AGENTS.md` §14, `behaviors/helpers.sh` `__semantic_monitor()`) polls the live session DB and aborts on stall signals, but it (a) never inspects on-disk output artifacts in the test home (e.g., the scenario-expected plan.md), and (b) never terminates early when the evidence needed for a verdict has already landed — GREEN-capable runs and hopeless runs both burn the full 600-900s timeout.

### Root Cause / Motivation

`__semantic_monitor()` reads only the session DB event stream; the poll loop contains no artifact/file check and no success-shaped termination condition. The run can only end by natural exit or mechanical abort, so wasted-ceremony runtime is structural, not incidental. Wasted runs also delay behavioral feedback (DDL) and inflate CI wall-clock — solving this now directly shortens the inner loop the whole enforcement-test pipeline depends on.

### Approach Chosen

Extend each monitor poll into a three-signal semantic read: (a) latest tool calls from the session DB, (b) latest text/reasoning content, and (c) on-disk expected artifacts in the test home (scenario-declared via a new optional `BEHAVIOR_EXPECTED_ARTIFACT` variable). GREEN-signal termination fires when the expected artifact exists on disk AND the event stream shows goal-relevant actions; HOPELESS-signal termination fires on a cited-evidence judgment that the run can never achieve the scenario goal. Both reuse the existing kill + §10.5 export + diagnosis-record path; `behavior_run()` treats GREEN and HOPELESS terminations as loop-exiting (no blind retry), and early-terminated evidence is valid verdict input.

### Alternatives Considered & Why Discarded

- **Wait for natural run completion only (status quo)** — discarded: burns the full timeout for runs that already produced their evidence or can never succeed; directly contradicts the cost model (defect-discovery-latency discipline applies to harness runtime too).
- **External watchdog process outside `__semantic_monitor()`** — discarded: duplicates poll infrastructure, fragments the evidence trail across two loggers, and would bypass the established abort path contract (kill + §10.5 export + diagnosis YAML) that all existing signals reuse.
- **Tool-based success detection only (no on-disk artifact check)** — discarded: tool calls prove action, not deliverable; the artifact check anchors GREEN termination in a verifiable output.

### Key Design Decisions

1. **GREEN requires BOTH artifact existence AND goal-relevant session actions** — tradeoff: slightly later termination vs. elimination of false-positive GREEN from artifact-only side effects.
2. **HOPELESS requires a cited-evidence judgment recorded in the poll log** — tradeoff: judgment overhead per poll vs. auditable protection against cutting off slow-but-viable runs.
3. **Reuse the existing abort path (kill + §10.5 export + diagnosis YAML) for all new terminations** — tradeoff: constrains the new signals to the current evidence schema (extended additively) vs. not duplicating kill/export logic.
4. **`BEHAVIOR_EXPECTED_ARTIFACT` is optional per scenario; unset means the artifact signal is skipped gracefully** — tradeoff: no coverage of artifact intent in undeclared scenarios vs. zero behavioral change for all existing scenarios.
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
| SC-1 | A monitored behavioral run whose scenario-declared expected artifact (`BEHAVIOR_EXPECTED_ARTIFACT`) is produced mid-run terminates early via the GREEN signal: the poll log records both artifact-existence and goal-relevant-action evidence, session.yaml is exported per §10.5, a termination judgment is written, the retry loop exits without blind retry, and the verdict is evaluated from the captured evidence. Runs with `BEHAVIOR_EXPECTED_ARTIFACT` unset see no behavior change. | behavioral | Run a monitored scenario via `bash .opencode/tests-v2/with-test-home opencode run` (>=600s timeout; `rm -f tmp/.behavior-run.lock` first) where the expected artifact is produced mid-run; assert poll-log GREEN-termination evidence, exported session.yaml, judgment YAML, and loop exit. | `.opencode/tests-v2/AGENTS.md` §14, §10.5; `.opencode/tests-v2/behaviors/helpers.sh` `__semantic_monitor()` |
| SC-2 | A monitored behavioral run judged (with cited evidence) unable to achieve the scenario goal terminates early via the HOPELESS signal: the diagnosis YAML cites concrete event-stream evidence, the poll log records the judgment, the run is killed and exported per §10.5, and the termination is recorded as a valid FAIL/behavior-diagnosis verdict. | behavioral | Run a monitored off-track scenario via `with-test-home opencode run`; assert HOPELESS termination fires before mechanical threshold/timeout, diagnosis YAML cites concrete evidence, and verdict records a behavior-diagnosis FAIL. | `.opencode/tests-v2/AGENTS.md` §14; `.opencode/tests-v2/behaviors/helpers.sh` abort path |
| SC-3 | The parent-repo `AGENTS.md` contains a one-line pointer to the §14 early-termination mandate in the Testing Lessons Learned area, and the `.opencode` submodule pointer update rides alongside in the same parent commit. | structural | grep parent `AGENTS.md` for the pointer line; verify the submodule pointer is staged in the same commit via `git status`/`git diff --cached`. | `AGENTS.md` (parent repo) Testing Lessons Learned area |

## 4. Requirements

- R-1. `__semantic_monitor()` SHALL read three signals per poll: session-DB tool calls, text/reasoning content, and on-disk expected artifacts resolved against the run's test home.
- R-2. The harness SHALL support an optional per-scenario `BEHAVIOR_EXPECTED_ARTIFACT` declaration; when unset, the artifact signal SHALL be skipped gracefully with no change to existing behavior.
- R-3. `__semantic_monitor()` SHALL fire GREEN termination only when the expected artifact exists on disk AND the session event stream shows goal-relevant actions.
- R-4. On GREEN termination, the monitor SHALL kill the run, export session.yaml per §10.5, and write a termination judgment; `behavior_run()` SHALL exit the retry loop without blind retry.
- R-5. `__semantic_monitor()` SHALL fire HOPELESS termination on a cited-evidence judgment that the run can never accomplish the scenario goal; the judgment SHALL cite concrete event-stream evidence and be recorded in the poll log.
- R-6. On HOPELESS termination, the monitor SHALL kill the run, export session.yaml per §10.5, write a behavior-diagnosis judgment, and the harness SHALL treat the termination as a valid FAIL/behavior-diagnosis verdict input.
- R-7. All new terminations SHALL reuse the existing abort path contract (kill + §10.5 export + diagnosis YAML + stderr banner) and SHALL NOT duplicate kill/export logic.
- R-8. `tests-v2/AGENTS.md` §14 SHALL document the early-termination mandate: three-signal polling, GREEN/HOPELESS conditions, evidence contract (session.yaml + poll log + judgment), and the no-blind-retry rule.
- R-9. Terminal states SHALL be exclusive — at most one termination kind per run.
- R-10. The parent repo `AGENTS.md` SHALL carry a one-line pointer to the §14 early-termination mandate, with the submodule pointer update committed alongside.

## 5. Items

### Item 1 (SC-1): §14 early-termination mandate documentation

- RED: grep §14 of `.opencode/tests-v2/AGENTS.md` for absence of GREEN/HOPELESS/early-termination mandate — grep shows nothing (fails to find the mandate).
- GREEN: add the early-termination subsections (three-signal polling, GREEN/HOPELESS conditions, evidence contract, no-blind-retry rule) to §14; grep shows the mandate present.
- verify: content verification (grep) — no behavioral run required.
- commit: `.opencode/tests-v2/AGENTS.md` change committed in the submodule.

### Item 2 (SC-1): GREEN-signal early termination

- RED: run a monitored scenario (via `with-test-home opencode run`) where the scenario-declared expected artifact is produced mid-run; assert the poll log shows no GREEN termination and the run burns the full budget.
- GREEN: implement artifact-signal read + GREEN condition + GREEN termination branch in `__semantic_monitor()`, and GREEN-exit handling in the `behavior_run()` retry loop; the same scenario terminates early with full evidence recorded.
- verify: behavioral run asserting poll-log evidence, §10.5 export, judgment YAML, and loop exit.
- commit: `helpers.sh` change committed + pushed in the submodule (PUSH precedes the behavioral run per 091-incremental-build).

### Item 3 (SC-2): HOPELESS-signal early termination

- RED: run a monitored off-track scenario; assert no HOPELESS termination (waits for mechanical threshold/timeout).
- GREEN: implement the HOPELESS judgment branch on the abort path with concrete-evidence citation; the scenario terminates early with a cited behavior-diagnosis FAIL.
- verify: behavioral run asserting cited diagnosis YAML and poll-log judgment record.
- commit: `helpers.sh` change committed + pushed in the submodule.

### Item 4 (SC-3): Parent-repo discoverability pointer

- RED: grep parent `AGENTS.md` Testing Lessons Learned area — pointer line absent.
- GREEN: add the one-line §14/early-termination pointer; stage the submodule pointer update in the same parent commit.
- verify: grep parent `AGENTS.md` for the pointer line; verify submodule pointer staged in same commit.
- commit: parent repo commit containing pointer + submodule pointer ride-along.

## 6. Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| `.opencode/tests-v2/AGENTS.md` §14 Monitoring Protocol | Must be read before implementation — the mandate defines the poll protocol and hard-abort signals being extended | Satisfied |
| `.opencode/tests-v2/behaviors/helpers.sh` `__semantic_monitor()` / `behavior_run()` | Implementation base — extended, not replaced | Satisfied |
| `.opencode/tests-v2/AGENTS.md` §10.5 export procedure | Reused as-is by all new terminations | Satisfied |
| 091-incremental-build (behavioral PUSH step) | Items 2-3 must commit+push before their behavioral runs | Satisfied (process rule) |

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1, R-2, R-3, R-4, R-7, R-8, R-9 | SC-1 | 1, 2 |
| R-1, R-5, R-6, R-7, R-8, R-9 | SC-2 | 1, 3 |
| R-10 | SC-3 | 4 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| §14 Semantic Continuous Monitoring Mandate | doc | `.opencode/tests-v2/AGENTS.md` §14 | read (pre-spec inspection) |
| `__semantic_monitor()` / `behavior_run()` | code | `.opencode/tests-v2/behaviors/helpers.sh` | read + grep (pre-spec inspection; artifact check confirmed absent, 0 hits) |
| §10.5 export procedure | doc | `.opencode/tests-v2/AGENTS.md` §10.5 | read (pre-spec inspection) |
| `BEHAVIOR_EXPECTED_ARTIFACT` | code (not yet existing) | `.opencode/tests-v2/` | grep — 0 hits, declared as new convention by this spec |
| Parent repo `AGENTS.md` Testing Lessons Learned | doc | `AGENTS.md` (root repo) | read (pre-spec inspection) |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1: Running the GREEN-termination behavioral test costs minutes of execution time — a bounded delay that surfaces false-positive GREEN conditions before they silently hand unverifiable verdicts to every downstream consumer. Skipping costs hours-to-days of diagnosis when early-terminated evidence is later found invalid at review time — the harness's core trust property erodes across every scenario.
- SC-2: Running the HOPELESS-termination behavioral test costs minutes of execution time. Skipping costs hours-to-days when un-cited hopeless judgments cut off viable runs or let hopeless runs burn the full timeout — and the poll log cannot explain why, destroying the audit trail.
- SC-3: Verifying the pointer line and submodule-pointer staging costs one grep and one `git diff --cached`. Skipping costs weeks of drift where the parent-repo agent deck never learns the early-termination mandate exists and implementations proceed from stale guidance.

## 11. Edge Cases

- **Condition:** `BEHAVIOR_EXPECTED_ARTIFACT` unset in a scenario. **Expected behavior:** artifact signal skipped gracefully; existing behavior unchanged. **Resolution:** per-item guard on the artifact read (R-2).
- **Condition:** Expected artifact exists but session evidence shows no goal-relevant actions. **Expected behavior:** GREEN MUST NOT fire; polling continues. **Resolution:** AND-condition (R-3).
- **Condition:** Slow-but-viable run judged HOPELESS incorrectly. **Expected behavior:** judgment MUST cite concrete evidence and be recorded in the poll log for audit. **Resolution:** cited-evidence constraint (R-5).
- **Condition:** GREEN and an existing abort signal both become eligible in the same poll. **Expected behavior:** at most one termination kind per run (exclusive terminal states). **Resolution:** precedence in the poll-loop state machine (R-9).
- **Condition:** Retry loop after early termination. **Expected behavior:** GREEN and HOPELESS terminations both exit the loop without blind retry; verdict evaluation consumes the captured evidence. **Resolution:** loop-control distinction (R-4, R-6).
- **Condition:** DB not yet provisioned (run just launched). **Expected behavior:** monitor remains IDLE until the DB appears, as today. **Resolution:** existing IDLE→POLLING transition unchanged.
- **Condition:** Concurrent runs sharing the test home. **Expected behavior:** artifact paths resolve against the run's own test home (same DB-discovery pattern as existing code). **Resolution:** per-run test-home resolution.

---

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
