> **Full spec and artifacts: [`.opencode/.issues/2456/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2456)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2456/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# Spec: tests-v2 semantic-determination gate for behavioral opencode run dispatches

## Intent and Executive Summary

- **Problem Statement:** The tests-v2 behavioral harness (`__semantic_monitor` / `behavior_run()` in `.opencode/tests-v2/behaviors/helpers.sh`, invoked via `with-test-home`) classifies monitored `opencode run` dispatches with shell heuristics — semantic judgment lives in shell, not in a sub-agent context — and aborts runs without any durable determination record. There is no gate blocking resume/re-run of an aborted or killed dispatch without a recorded determination, no orchestrator-notification path, and no ceiling on undetermined cycles.
- **Root Cause / Motivation:** Live evidence from issue #2454: a monitor false-positive abort (duplicate running-event over-count), two §10.7 resumptions ungated by any determination record, and silent continuation possibilities for undetermined or off-track runs. The §14 continuous-monitoring mandate currently ends in kill+export+diagnose with no recorded, non-undetermined determination and no orchestrator decision loop. The defect surface is test-infrastructure integrity: undetermined or off-target behavioral runs can silently pass, retry, or resume without human-visible cause analysis.
- **Approach Chosen:** Introduce a determination-record lifecycle: the harness's mechanical poll loop remains an evidence collector; a monitoring sub-agent performs semantic classification (progressing-directionally / off-track / undetermined) in its own context with the scenario's goal as anchoring context; determinations are persisted as YAML records in the scenario evidence directory; off-track and undetermined states trigger orchestrator notification (never silent continuation); a hard gate blocks resume/re-run of aborted/killed dispatches without a recorded non-undetermined determination; a ceiling (default 3) on undetermined cycles produces a CEILING_REACHED mechanical block; false-positive aborts are folded into the determination record as false_signal annotations.
- **Alternatives Considered & Why Discarded:** (1) Keep classification in shell heuristics but add more signals — discarded: semantic judgment ("does activity move toward the scenario goal?") cannot be faithfully evaluated by string heuristics; #2454's false-positive abort demonstrates the failure mode. (2) Fully automatic abort-retry with backoff — discarded: it is exactly the silent-continuation defect this spec eliminates; retry without a recorded determination destroys root-cause evidence (R-18/§17). (3) Persisting determinations only in agent chat output — discarded: chat is not durable across harness invocations; the §10.7 resume gate needs a filesystem artifact readable at gate time.
- **Key Design Decisions:** (1) Direction-anchored classification: progressing means progressing toward the scenario goal; off-target motion is off-track and triggers orchestrator notification — never silent continuation (developer-finalized design). (2) Determination record is a YAML artifact (LLM-to-LLM data standard) with append-only semantics for false_signal annotations and orchestrator decisions. (3) The gate is mechanical — pure predicate checks on records, no semantic judgment inside the gate. (4) `BEHAVIOR_SEMANTIC_MONITOR=1` remains opt-in; fresh invocations without the flag are unchanged (backward compatible). (5) Ceiling of 3 undetermined cycles, persisted across invocations, blocking at CEILING_REACHED until developer-level remediation. (6) AGENTS.md §10.7/§14/R-18 documentation mirrors the exact implemented predicates (single-definition R-10 pattern).
- **User Intent / Original Prompt:** ".opencode#2456 — tests-v2 test-framework semantic-determination gate for behavioral opencode run dispatches." Developer finalized the brainstorming discussion: design approved as presented, including the direction-anchored progress refinement (progressing means progressing toward the scenario goal; off-target motion is off-track and triggers orchestrator notification, never silent continuation).

## Not Included

- **Per-run re-provisioning cost defect (fresh-home clone + 27B smoke tests, ~15+ min per run; SC-1 RED finding from #2454)** — a known unfixed infrastructure defect; fixing it requires its own spec and is not part of the determination-gate lifecycle.
- **Changes to mechanical signals 1-3 themselves** — beyond folding false positives into determination records, the existing stuck/identical-input/reasoning-size signal machinery is retained as evidence collection.
- **Default model selection or §15 one-run-per-SC budget changes** — the Default-Model Mandate (R-20) is unaffected; monitor classification is not model-shopping.
- **GNU timeout adoption anywhere in the monitor path** — forbidden by §5; the monitor's kill path remains its own signal handler.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | When `BEHAVIOR_SEMANTIC_MONITOR=1`, the monitor persists poll evidence and dispatches a monitoring sub-agent that semantically classifies run state (progressing-directionally / off-track / undetermined) in the sub-agent's own context, given the scenario's goal/expected-behavior context; a determination record with classification and poll-evidence references is written to the scenario evidence directory. | behavioral | Behavioral run via `with-test-home`: RED asserts no classification dispatch/record for a monitored run; GREEN asserts poll evidence plus classification result recorded in the determination record. |
| SC-2 | Direction-anchored classification: a run is classified progressing-directionally ONLY when activity moves toward the scenario goal; off-goal motion is classified off-track and routed to an orchestrator notification (stderr `ORCHESTRATOR_DECISION_REQUIRED`-class convention) — never silently continued; progressing runs continue polling regardless of duration. | behavioral | Off-track fixture run (loop scenario) shows the orchestrator notification on stderr and no silent continuation; a progressing run continues polling. |
| SC-3 | Undetermined / excessive-without-classification / direction-deviation states halt monitoring and notify the orchestrator before any further dispatch; the orchestrator decision — continue monitoring via a new sub-agent dispatch, or terminate with remediation — is recorded in the determination record with root-cause for termination. | behavioral | Undetermined-condition run halts and notifies; the recorded decision (continue vs terminate+root-cause) is present in the determination record. |
| SC-4 | A hard gate blocks resume (`--resume-home`/`--continue`) or re-run of an aborted/killed dispatch when no recorded non-undetermined determination exists, exiting with a FATAL-class block; a valid determination permits the resume. | behavioral | Abort a dispatch, attempt resume/re-run without a determination → harness exits with the FATAL block; with a valid determination → proceeds. |
| SC-5 | A ceiling (default 3) on undetermined determination cycles is counted and persisted across invocations; reaching it produces a CEILING_REACHED mechanical block that persists until developer-level remediation. | behavioral | Mechanical counter predicate verified with synthetic determination records; ceiling = 3 default and CEILING_REACHED message asserted. |
| SC-6 | Monitor false-signal guard: a wrong abort (e.g., the #2454 duplicate-running-event over-count) is folded into the determination record as a false_signal annotation — never silently retried. | behavioral | Reproduce the #2454-style over-count; false_signal annotation present in the record; no silent retry occurs. |
| SC-7 | A new behavioral enforcement scenario asserts the gate blocks re-dispatch without determination (RED→GREEN); `.opencode/tests-v2/AGENTS.md` §10.7, §14, and R-18/§17 mirror the exact implemented gate predicates. | behavioral | New scenario registered and passing via `test-enforcement.sh`; doc alignment verified by structural advisory checks (mdformat/pymarkdownlnt) against the implemented predicates. |

## Requirements

R-1. The harness monitor SHALL persist poll evidence for every monitored run and SHALL dispatch a monitoring sub-agent that semantically classifies run state in the sub-agent's own context, given the scenario's goal/expected-behavior context.

R-2. The harness SHALL classify a run as progressing-directionally only when its activity moves toward the scenario's goal; off-goal motion SHALL be classified off-track and SHALL trigger orchestrator notification — off-track runs SHALL never continue silently. Progressing runs SHALL continue polling regardless of duration.

R-3. The harness SHALL halt monitoring and notify the orchestrator when classification is undetermined, when the run is excessive without classification, or on direction deviation, before any further dispatch.

R-4. The orchestrator SHALL decide between continuing monitoring via a new sub-agent dispatch and terminating the run with remediation; the decision SHALL be recorded in the determination record, including root-cause for termination.

R-5. The harness SHALL block resume or re-run of an aborted/killed dispatch when no recorded non-undetermined determination exists, and SHALL mechanically block (CEILING_REACHED) after a ceiling of 3 undetermined determination cycles, persisted across invocations.

R-6. The harness SHALL fold wrong aborts (false-positive monitor signals) into the determination record as false_signal annotations and SHALL NOT silently retry them.

R-7. The repository SHALL contain a behavioral enforcement scenario asserting the gate blocks re-dispatch without a determination, and `.opencode/tests-v2/AGENTS.md` (§10.7, §14, R-18/§17) SHALL mirror the exact implemented gate predicates.

R-8. The determination record SHALL be a durable YAML artifact written in the scenario evidence directory alongside session.yaml and the poll log, with append-only semantics for false_signal annotations and orchestrator decisions.

## Items

### Item 1 (SC-1): Classification sub-agent with scenario-goal context

- RED: Monitored run with `BEHAVIOR_SEMANTIC_MONITOR=1` produces no classification dispatch evidence and no determination record — assertion fails.
- GREEN: Harness dispatches the classification sub-agent with scenario-goal context; poll evidence and the classification result are persisted in the determination record.
- verify: Behavioral run via `with-test-home` asserts record contents (classification, poll-evidence refs).
- commit: helpers.sh monitor path + determination-record schema.

### Item 2 (SC-2): Off-track notification path + progressing-continues behavior

- RED: Off-track fixture run silently continues (no orchestrator notification) — assertion fails.
- GREEN: Off-track classification emits the orchestrator notification on stderr; progressing runs keep polling without duration cap.
- verify: Off-track fixture run shows notification, not continuation; progressing run continues.
- commit: helpers.sh classification routing.

### Item 3 (SC-3): Orchestrator decision loop with recorded root-cause determination

- RED: Undetermined condition continues without halt/notification — assertion fails.
- GREEN: Undetermined/excessive/deviation halts monitor, notifies orchestrator; decision recorded (continue-new-dispatch vs terminate+root-cause).
- verify: Behavioral run asserts halt, notification, and recorded decision.
- commit: helpers.sh decision loop + §14 abort-recovery alignment.

### Item 4 (SC-4): Determination gate in harness resume/re-run path

- RED: Resume/re-run after abort without a determination proceeds — assertion fails.
- GREEN: `with-test-home` resume/re-run path reads the determination record; missing/non-undetermined-record-absent → FATAL block; valid record → pass-through.
- verify: Abort → resume blocked with FATAL; valid determination → proceeds.
- commit: with-test-home gate.

### Item 5 (SC-5): Undetermined-cycle counter + CEILING_REACHED block

- RED: Third undetermined cycle does not block — assertion fails.
- GREEN: Counter persisted under the flock discipline; ≥3 → CEILING_REACHED mechanical block persisting until remediation.
- verify: Synthetic determination-record predicate tests (no model dispatch required); CEILING_REACHED message asserted.
- commit: counter + gate predicate.

### Item 6 (SC-6): False-signal folding into determination record

- RED: Reproduced false-positive abort is retried silently with no record trace — assertion fails.
- GREEN: Wrong abort folds a false_signal annotation into the determination record; no silent retry.
- verify: #2454-style duplicate-running-event over-count reproduced; annotation asserted present.
- commit: helpers.sh abort-folding path.

### Item 7 (SC-7): Behavioral scenario + doc alignment

- RED: New scenario asserts the gate blocks re-dispatch without determination and fails against pre-gate harness.
- GREEN: Scenario passes against the gated harness; AGENTS.md §10.7/§14/R-18 updated to mirror the exact predicates.
- verify: Scenario passes via `test-enforcement.sh --list` registry and run; advisory markdown checks clean.
- commit: new `behaviors/<scenario>.sh` + AGENTS.md sections.

## Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| `.opencode/tests-v2/behaviors/helpers.sh` (`behavior_run`, `__semantic_monitor`) | Implementation substrate — monitor loop, abort paths, #2430 signal-2 hardening | Satisfied (existing) |
| `.opencode/tests-v2/with-test-home` | Implementation substrate — resume/clone gates, flock | Satisfied (existing) |
| `.opencode/tests-v2/AGENTS.md` §10.7/§14/§17 (R-18) | Documentation targets to align with implemented predicates | Satisfied (existing) |
| Issue #2454 (live evidence: false-positive abort, ungated resumptions) | Motivating evidence; false-signal reproduction basis | Satisfied (closed evidence) |
| `with-test-home` harness pre-flight gate (clean+pushed submodule) | Constraint on all behavioral verification runs | Satisfied (existing) |

## Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | Pre/Per-file (helpers.sh monitor) |
| R-2 | SC-2 | Per-file (helpers.sh) |
| R-3 | SC-3 | Per-file (helpers.sh) |
| R-4 | SC-3 | Per-file (helpers.sh) |
| R-5 | SC-4, SC-5 | Per-file (with-test-home, counter) |
| R-6 | SC-6 | Per-file (helpers.sh) |
| R-7 | SC-7 | Post (scenario + docs) |
| R-8 | SC-1, SC-4 | Pre (determination record schema) |

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| `__semantic_monitor` / `behavior_run()` | code | `.opencode/tests-v2/behaviors/helpers.sh` | Bounded read (pre-spec inspection, R-18) |
| `with-test-home` resume/clone gates | code | `.opencode/tests-v2/with-test-home` | Bounded read (pre-spec inspection) |
| §14 Semantic Continuous Monitoring Mandate; §10.7 Session Resumption; §17 R-18 | docs | `.opencode/tests-v2/AGENTS.md` | Read (lines 877-887 cited in requirements analysis) |
| #2430 signal-2 false-fire hardening | code | `.opencode/tests-v2/behaviors/helpers.sh` (signal-2 guard) | Read (requirements analysis REQ-6 verification) |
| #2454 run evidence (false-positive abort, §10.7 resumptions) | evidence | `.opencode` issue #2454 session exports | Reviewed during analysis |
| YAML standard for LLM-to-LLM data transfers | guideline | `.opencode/guidelines/080-code-standards.md` | Read |

## Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1: Running the behavioral classification test costs minutes of live-model execution plus ~15 min harness provisioning. Skipping costs weeks — undetermined runs silently pass verdicts and the defect ships inside every subsequent behavioral test's evidence chain, a 1000× death-spiral multiplier.
- SC-2: Running the off-track fixture costs minutes. Skipping costs days-to-weeks — off-target runs silently consume the entire run budget and verdicts are issued for runs that never approached the scenario goal.
- SC-3: Running the decision-loop test costs minutes. Skipping costs days — every monitor halt re-enters the silent kill+export cycle, root causes are never recorded, and R-18 diagnosis debt compounds per aborted run.
- SC-4: Running the gate test costs minutes. Skipping costs weeks — aborted dispatches resume ungated, producing verdicts about sessions with no recorded determination; every downstream audit inherits the untraceable run.
- SC-5: Verifying the ceiling predicate with synthetic records costs seconds. Skipping costs days — undetermined retry loops run unbounded, burning live-model budget while never surfacing the underlying reasoning failure.
- SC-6: Reproducing the false-signal costs minutes. Skipping costs days — monitor false positives (the #2454 class) silently retry, discarding the only evidence that the monitor itself is defective.
- SC-7: Running the new scenario costs minutes. Skipping costs weeks — the gate itself has no enforcement test, so any future regression in the resume gate ships undetected and every determination-gate guarantee above becomes unenforceable documentation.

## Edge Cases

- **Condition:** Determination record missing at gate time (aborted before any classification ran). **Expected behavior:** The resume/re-run gate blocks with a FATAL-class message. **Resolution:** Re-run from scratch records a fresh determination; no partial binding.
- **Condition:** Determination record exists but classification is `undetermined`. **Expected behavior:** The gate blocks resume/re-run (only non-undetermined determinations authorize resume); the undetermined cycle counter increments on orchestrator-continue. **Resolution:** Third cycle → CEILING_REACHED until developer-level remediation.
- **Condition:** Concurrent scenario runs contending for the ceiling counter. **Expected behavior:** Counter persistence respects the existing `tmp/.behavior-run.lock` flock discipline — no new locking scheme. **Resolution:** Contention serialized by the existing lock; no counter corruption.
- **Condition:** Monitor false-positive abort (parser duplicate-event over-count). **Expected behavior:** Folded into the determination record as a false_signal annotation; not silently retried. **Resolution:** Record carries the annotation; run state resumes only through the recorded determination path.
- **Condition:** Scenario goal context unavailable or empty for the classification dispatch. **Expected behavior:** Classification cannot anchor direction → classified undetermined, halting with orchestrator notification (fail-fast; no default classification). **Resolution:** Orchestrator decision loop (SC-3) governs continuation.
- **Condition:** Sub-agent dispatch of the classifier fails (model/harness error). **Expected behavior:** Halt + orchestrator notification — never a silent fallback to shell-heuristic classification. **Resolution:** Determination record records the failure; orchestrator decides continue/terminate.
- **Condition:** `BEHAVIOR_SEMANTIC_MONITOR` unset (default invocations). **Expected behavior:** No monitor, no gate coupling — fresh invocations unchanged (backward compatible). **Resolution:** Out of the determination lifecycle entirely.

---

Co-authored with AI: OpenCode (zai-org/GLM-5.3-Flash)

---

Co-authored with AI: OpenCode (zai-org/GLM-5.3-Flash)
