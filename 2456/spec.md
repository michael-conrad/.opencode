> **Full spec and artifacts: [`.opencode/.issues/2456/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2456)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2456/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# Spec: tests-v2 semantic-determination gate for behavioral opencode run dispatches

## Intent and Executive Summary

- **Problem Statement:** The tests-v2 behavioral harness (`__semantic_monitor` / `behavior_run()` in `.opencode/tests-v2/behaviors/helpers.sh`, invoked via `with-test-home`) classifies monitored `opencode run` dispatches with shell heuristics — semantic judgment lives in shell, not in a sub-agent context — and aborts runs without any durable determination record. There is no gate blocking resume/re-run of an aborted or killed dispatch without a recorded determination, no orchestrator-notification path, and no ceiling on undetermined cycles.
- **Root Cause / Motivation:** Live evidence from issue #2454: a monitor false-positive abort (duplicate running-event over-count), two §10.7 resumptions ungated by any determination record, and silent continuation possibilities for undetermined or off-track runs. The §14 continuous-monitoring mandate currently ends in kill+export+diagnose with no recorded, non-undetermined determination and no orchestrator decision loop. The defect surface is test-infrastructure integrity: undetermined or off-target behavioral runs can silently pass, retry, or resume without human-visible cause analysis.
- **Approach Chosen:** Introduce a determination-record lifecycle: the harness's mechanical poll loop remains an evidence collector; a monitoring sub-agent performs semantic classification (progressing-directionally / off-track / undetermined) in its own context with the scenario's goal as anchoring context; determinations are persisted as YAML records in the scenario evidence directory; off-track and undetermined states trigger orchestrator notification (never silent continuation); a hard gate blocks resume/re-run of aborted/killed dispatches without a recorded non-undetermined determination; a ceiling (default 3) on undetermined cycles produces a CEILING_REACHED mechanical block; false-positive aborts are folded into the determination record as false_signal annotations.
- **Alternatives Considered & Why Discarded:** (1) Keep classification in shell heuristics but add more signals — discarded: semantic judgment ("does activity move toward the scenario goal?") cannot be faithfully evaluated by string heuristics; #2454's false-positive abort demonstrates the failure mode. (2) Fully automatic abort-retry with backoff — discarded: it is exactly the silent-continuation defect this spec eliminates; retry without a recorded determination destroys root-cause evidence (R-18/§17). (3) Persisting determinations only in agent chat output — discarded: chat is not durable across harness invocations; the §10.7 resume gate needs a filesystem artifact readable at gate time.
- **Key Design Decisions:** (1) Direction-anchored classification: progressing means progressing toward the scenario goal; off-target motion is off-track and triggers orchestrator notification — never silent continuation (developer-finalized design). (2) Determination record is a YAML artifact (LLM-to-LLM data standard) with append-only semantics for false_signal annotations and orchestrator decisions. (3) The gate is mechanical — pure predicate checks on records, no semantic judgment inside the gate. (4) `BEHAVIOR_SEMANTIC_MONITOR=1` remains opt-in; fresh invocations without the flag are unchanged (backward compatible). (5) Ceiling of 3 undetermined cycles, persisted across invocations, blocking at CEILING_REACHED until developer-level remediation. (6) AGENTS.md §10.7/§14/R-18 documentation mirrors the exact implemented predicates (single-definition R-10 pattern). (7) The orchestrator decision is a single recorded decision field with the allowed value-set {continue-new-dispatch, terminate-with-root-cause}; `--resume-home` and `--continue` are invocation variants of the single resume mechanism and are gated identically.
- **User Intent / Original Prompt:** ".opencode#2456 — tests-v2 test-framework semantic-determination gate for behavioral opencode run dispatches." Developer finalized the brainstorming discussion: design approved as presented, including the direction-anchored progress refinement (progressing means progressing toward the scenario goal; off-target motion is off-track and triggers orchestrator notification, never silent continuation).

## Not Included

- **Per-run re-provisioning cost defect (fresh-home clone + 27B smoke tests, ~15+ min per run; SC-1 RED finding from #2454)** — a known unfixed infrastructure defect; fixing it requires its own spec and is not part of the determination-gate lifecycle.
- **Changes to mechanical signals 1-3 themselves** — beyond folding false positives into determination records, the existing stuck/identical-input/reasoning-size signal machinery is retained as evidence collection.
- **Default model selection or §15 one-run-per-SC budget changes** — the Default-Model Mandate (R-20) is unaffected; monitor classification is not model-shopping.
- **GNU timeout adoption anywhere in the monitor path** — forbidden by §5; the monitor's kill path remains its own signal handler.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | When `BEHAVIOR_SEMANTIC_MONITOR=1`, the monitor persists poll evidence for every monitored run to the scenario evidence directory. | behavioral | Behavioral run via `with-test-home`: RED asserts no poll evidence persisted for a monitored run; GREEN asserts poll evidence present in the scenario evidence directory. |
| SC-2 | The monitor dispatches a monitoring sub-agent that semantically classifies run state (progressing-directionally / off-track / undetermined) in the sub-agent's own context, given the scenario's goal/expected-behavior context. | behavioral | Behavioral run via `with-test-home`: RED asserts no classification dispatch for a monitored run; GREEN asserts the classification sub-agent dispatched with scenario-goal context. |
| SC-3 | A determination record with classification and poll-evidence references is written to the scenario evidence directory. | behavioral | Behavioral run via `with-test-home`: RED asserts no determination record; GREEN asserts record present with classification and poll-evidence references. |
| SC-4 | Direction-anchored off-track classification: off-goal motion is classified off-track and routed to an orchestrator notification (stderr `ORCHESTRATOR_DECISION_REQUIRED`-class convention) — never silently continued. | behavioral | Off-track fixture run (loop scenario) shows the orchestrator notification on stderr and no silent continuation. |
| SC-5 | Progressing runs continue polling regardless of duration. | behavioral | Progressing fixture run continues polling past the duration at which non-progressing runs are halted. |
| SC-6 | Halt-class trigger states — undetermined, excessive-without-classification, or direction-deviation — halt monitoring and notify the orchestrator before any further dispatch. | behavioral | Undetermined-condition run halts monitoring and emits the orchestrator notification; no further dispatch occurs before the recorded decision. |
| SC-7 | The orchestrator decision is recorded in the determination record as a decision field with allowed value-set {continue-new-dispatch, terminate-with-root-cause}, including root-cause when the value is terminate-with-root-cause. | behavioral | The recorded decision field carries exactly one allowed value (with root-cause present for terminate-with-root-cause) in the determination record. |
| SC-8 | A hard gate blocks resume (`--resume-home` or `--continue` — invocation variants of the single resume mechanism) or re-run of an aborted/killed dispatch when no recorded non-undetermined determination exists, exiting with a FATAL-class block; a valid determination permits the resume. | behavioral | Abort a dispatch, attempt resume/re-run without a determination → harness exits with the FATAL block; with a valid determination → proceeds. |
| SC-9 | A ceiling (default 3) on undetermined determination cycles is counted and persisted across invocations; reaching it produces a CEILING_REACHED mechanical block that persists until developer-level remediation. | structural | Mechanical counter predicate verified with synthetic determination records; ceiling = 3 default and CEILING_REACHED message asserted. |
| SC-10 | A reproduced wrong abort (e.g., the #2454 duplicate-running-event over-count) produces a false_signal annotation in the determination record. | behavioral | Reproduce the #2454-style over-count; assert the false_signal annotation is present in the record. |
| SC-11 | The new behavioral enforcement scenario asserting the gate blocks re-dispatch without determination passes via the `test-enforcement.sh` run (RED→GREEN). | behavioral | New scenario passes via `test-enforcement.sh` run; `--list` registration is the enabling precondition of the same single deliverable. |
| SC-12 | `.opencode/tests-v2/AGENTS.md` §10.7, §14, and R-18/§17 mirror the exact implemented gate predicates. | structural | Doc alignment verified by structural advisory checks (mdformat/pymarkdownlnt) against the implemented predicates. |

**SC-6 trigger-class single-mechanism justification:** The three halt-class conditions (undetermined / excessive-without-classification / direction-deviation) share one mechanism — they are exactly the three non-`progressing-directionally` outcomes of the single classification taxonomy defined in SC-2, and each routes through the identical halt+notify path (the same code path as SC-4's off-track notification, minus the distinct classification label). One classification enum, one halt+notify mechanism → one trigger class → one SC. The recorded decision field is a distinct deliverable (record schema + orchestrator write path) and is therefore verified separately as SC-7.

**SC-10 / SC-11 single-deliverable justification:** SC-10's single verification target is the presence of the false_signal annotation in the determination record after a reproduced wrong abort; the annotation's presence is the sole assertion (its existence is precisely what prevents silent retry — the "no silent retry" property is the absence-side of the same single deliverable, not a separate mechanism). SC-11's single deliverable is the enforcement scenario; "passing via run" is the one assertion, and `--list` registration is the enabling precondition of that same scenario deliverable, not an independent verification target.

## Requirements

R-1. The harness monitor SHALL persist poll evidence for every monitored run and SHALL dispatch a monitoring sub-agent that semantically classifies run state in the sub-agent's own context, given the scenario's goal/expected-behavior context.

R-2. The harness SHALL classify a run as progressing-directionally only when its activity moves toward the scenario's goal; off-goal motion SHALL be classified off-track and SHALL trigger orchestrator notification — off-track runs SHALL never continue silently. Progressing runs SHALL continue polling regardless of duration.

R-3. The harness SHALL halt monitoring and notify the orchestrator when classification is undetermined, when the run is excessive without classification, or on direction deviation, before any further dispatch (the halt-class trigger states of SC-6 — one halt+notify mechanism for the three non-progressing classification outcomes).

R-4. The orchestrator SHALL record its decision in the determination record as a decision field with allowed value-set {continue-new-dispatch, terminate-with-root-cause}; when the recorded value is terminate-with-root-cause, the record SHALL include the root-cause.

R-5. The harness SHALL block resume or re-run of an aborted/killed dispatch when no recorded non-undetermined determination exists, and SHALL mechanically block (CEILING_REACHED) after a ceiling of 3 undetermined determination cycles, persisted across invocations.

R-6. The harness SHALL fold wrong aborts (false-positive monitor signals) into the determination record as false_signal annotations and SHALL NOT silently retry them.

R-7. The repository SHALL contain a behavioral enforcement scenario asserting the gate blocks re-dispatch without a determination, and `.opencode/tests-v2/AGENTS.md` (§10.7, §14, R-18/§17) SHALL mirror the exact implemented gate predicates.

R-8. The determination record SHALL be a durable YAML artifact written in the scenario evidence directory alongside session.yaml and the poll log, with append-only semantics for false_signal annotations and orchestrator decisions.

## Items

### Item 1 (SC-1): Poll evidence persistence

- RED: Monitored run with `BEHAVIOR_SEMANTIC_MONITOR=1` produces no persisted poll evidence — assertion fails.
- GREEN: Harness persists poll evidence for every monitored run to the scenario evidence directory.
- verify: Behavioral run via `with-test-home` asserts poll evidence present.
- commit: helpers.sh monitor poll-evidence persistence.

### Item 2 (SC-2): Classification sub-agent with scenario-goal context

- RED: Monitored run produces no classification dispatch evidence — assertion fails.
- GREEN: Harness dispatches the classification sub-agent with scenario-goal context; classification result produced in the sub-agent's own context.
- verify: Behavioral run via `with-test-home` asserts classification dispatch with goal context.
- commit: helpers.sh classification dispatch path.

### Item 3 (SC-3): Determination record written

- RED: Monitored run produces no determination record — assertion fails.
- GREEN: Determination record with classification and poll-evidence references written to the scenario evidence directory.
- verify: Behavioral run via `with-test-home` asserts record contents (classification, poll-evidence refs).
- commit: determination-record schema + write path.

### Item 4 (SC-4): Off-track notification path

- RED: Off-track fixture run silently continues (no orchestrator notification) — assertion fails.
- GREEN: Off-track classification emits the orchestrator notification on stderr; no silent continuation.
- verify: Off-track fixture run shows notification, not continuation.
- commit: helpers.sh classification routing.

### Item 5 (SC-5): Progressing-continues behavior

- RED: Progressing run is halted by a duration cap — assertion fails.
- GREEN: Progressing runs keep polling without duration cap.
- verify: Progressing fixture run continues polling past the halt threshold.
- commit: helpers.sh polling continuation.

### Item 6 (SC-6): Halt-class halt+notify path

- RED: Undetermined condition continues without halt/notification — assertion fails.
- GREEN: Halt-class states (undetermined / excessive-without-classification / direction-deviation) halt monitoring and notify the orchestrator before any further dispatch.
- verify: Behavioral run asserts halt and orchestrator notification for a halt-class condition.
- commit: helpers.sh halt-class routing.

### Item 7 (SC-7): Recorded orchestrator decision field

- RED: No decision field recorded in the determination record after an orchestrator decision — assertion fails.
- GREEN: Decision recorded as a decision field with allowed value-set {continue-new-dispatch, terminate-with-root-cause} (root-cause present for terminate-with-root-cause).
- verify: Behavioral run asserts the recorded decision field carries an allowed value.
- commit: helpers.sh decision-record write path + §14 abort-recovery alignment.

### Item 8 (SC-8): Determination gate in harness resume/re-run path

- RED: Resume/re-run after abort without a determination proceeds — assertion fails.
- GREEN: `with-test-home` resume/re-run path (both `--resume-home` and `--continue` variants) reads the determination record; missing/non-undetermined-record-absent → FATAL block; valid record → pass-through.
- verify: Abort → resume blocked with FATAL; valid determination → proceeds.
- commit: with-test-home gate.

### Item 9 (SC-9): Undetermined-cycle counter + CEILING_REACHED block

- RED: Third undetermined cycle does not block — assertion fails.
- GREEN: Counter persisted under the flock discipline; ≥3 → CEILING_REACHED mechanical block persisting until remediation.
- verify: Synthetic determination-record predicate tests (no model dispatch required); CEILING_REACHED message asserted.
- commit: counter + gate predicate.

### Item 10 (SC-10): False-signal folding into determination record

- RED: Reproduced false-positive abort produces no false_signal annotation in the determination record — assertion fails.
- GREEN: Wrong abort folds a false_signal annotation into the determination record (annotation presence is the sole assertion; its existence is what prevents silent retry).
- verify: #2454-style duplicate-running-event over-count reproduced; annotation asserted present.
- commit: helpers.sh abort-folding path.

### Item 11 (SC-11): Behavioral enforcement scenario

- RED: New scenario asserts the gate blocks re-dispatch without determination and fails against pre-gate harness.
- GREEN: Scenario passes against the gated harness via `test-enforcement.sh` run.
- verify: Scenario passes via `test-enforcement.sh` run (registration in `--list` is the enabling precondition of the same deliverable).
- commit: new `behaviors/<scenario>.sh`.

### Item 12 (SC-12): AGENTS.md doc alignment

- RED: AGENTS.md §10.7/§14/R-18 do not mirror the implemented gate predicates — advisory structural check fails.
- GREEN: AGENTS.md §10.7/§14/R-18 updated to mirror the exact predicates.
- verify: Advisory markdown checks (mdformat/pymarkdownlnt) clean; content matches implemented predicates.
- commit: AGENTS.md sections.

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
| R-1 | SC-1, SC-2 | Per-item (helpers.sh poll evidence; helpers.sh classification dispatch) |
| R-2 | SC-4, SC-5 | Per-item (helpers.sh) |
| R-3 | SC-6 | Per-item (helpers.sh halt-class routing) |
| R-4 | SC-7 | Per-item (helpers.sh decision-record write path) |
| R-5 | SC-8, SC-9 | Per-item (with-test-home, counter) |
| R-6 | SC-10 | Per-item (helpers.sh) |
| R-7 | SC-11, SC-12 | Post (scenario; docs) |
| R-8 | SC-3, SC-7, SC-8 | Per-item (determination record schema; decision field; gate reads record) |

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

- SC-1: Running the poll-evidence persistence test costs minutes of live-model execution plus ~15 min harness provisioning. Skipping costs weeks — undetermined runs silently pass verdicts and the defect ships inside every subsequent behavioral test's evidence chain, a 1000× death-spiral multiplier.
- SC-2: Running the classification-dispatch test costs minutes. Skipping costs weeks — semantic judgment stays in shell heuristics and the #2454 failure class persists in every monitored run.
- SC-3: Running the determination-record test costs minutes. Skipping costs weeks — classifications live only in chat output and the §10.7 resume gate has no filesystem artifact to read.
- SC-4: Running the off-track fixture costs minutes. Skipping costs days-to-weeks — off-target runs silently consume the entire run budget and verdicts are issued for runs that never approached the scenario goal.
- SC-5: Running the progressing-continues fixture costs minutes. Skipping costs days — legitimate long runs get spuriously halted, producing false undetermined verdicts.
- SC-6: Running the halt-class halt+notify test costs minutes. Skipping costs days — every monitor halt re-enters the silent kill+export cycle with no orchestrator visibility.
- SC-7: Running the decision-field test costs minutes. Skipping costs days — root causes are never recorded, and R-18 diagnosis debt compounds per aborted run.
- SC-8: Running the gate test costs minutes. Skipping costs weeks — aborted dispatches resume ungated, producing verdicts about sessions with no recorded determination; every downstream audit inherits the untraceable run.
- SC-9: Verifying the ceiling predicate with synthetic records costs seconds. Skipping costs days — undetermined retry loops run unbounded, burning live-model budget while never surfacing the underlying reasoning failure.
- SC-10: Reproducing the false-signal costs minutes. Skipping costs days — monitor false positives (the #2454 class) silently retry, discarding the only evidence that the monitor itself is defective.
- SC-11: Running the new scenario costs minutes. Skipping costs weeks — the gate itself has no enforcement test, so any future regression in the resume gate ships undetected and every determination-gate guarantee above becomes unenforceable documentation.
- SC-12: Running advisory doc-alignment checks costs seconds. Skipping costs weeks — documentation drifts from the implemented predicates, and agents following §10.7/§14 follow stale rules instead of the shipped gate.

## Edge Cases

- **Condition:** Determination record missing at gate time (aborted before any classification ran). **Expected behavior:** The resume/re-run gate blocks with a FATAL-class message. **Resolution:** Re-run from scratch records a fresh determination; no partial binding.
- **Condition:** Determination record exists but classification is `undetermined`. **Expected behavior:** The gate blocks resume/re-run (only non-undetermined determinations authorize resume); the undetermined cycle counter increments on orchestrator-continue. **Resolution:** Third cycle → CEILING_REACHED until developer-level remediation.
- **Condition:** Concurrent scenario runs contending for the ceiling counter. **Expected behavior:** Counter persistence respects the existing `tmp/.behavior-run.lock` flock discipline — no new locking scheme. **Resolution:** Contention serialized by the existing lock; no counter corruption.
- **Condition:** Monitor false-positive abort (parser duplicate-event over-count). **Expected behavior:** Folded into the determination record as a false_signal annotation; not silently retried. **Resolution:** Record carries the annotation; run state resumes only through the recorded determination path.
- **Condition:** Scenario goal context unavailable or empty for the classification dispatch. **Expected behavior:** Classification cannot anchor direction → classified undetermined, halting with orchestrator notification (fail-fast; no default classification). **Resolution:** Halt+notify (SC-6) then orchestrator decision loop (SC-7) governs continuation.
- **Condition:** Sub-agent dispatch of the classifier fails (model/harness error). **Expected behavior:** Halt + orchestrator notification — never a silent fallback to shell-heuristic classification. **Resolution:** Determination record records the failure; orchestrator decides continue/terminate.
- **Condition:** `BEHAVIOR_SEMANTIC_MONITOR` unset (default invocations). **Expected behavior:** No monitor, no gate coupling — fresh invocations unchanged (backward compatible). **Resolution:** Out of the determination lifecycle entirely.

## Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-09-21 | Retyped SC-8 (former SC-5, ceiling gate) from behavioral to structural evidence type — ceiling gate is mechanical bookkeeping; behavioral gate enforcement remains covered by the live scenario SC. Testability-assessment artifact's 'mixed' label retired with artifact regeneration. | Validation finding 1 (EVIDENCE_TYPE_MISMATCH) | spec-creation validate pipeline (`.opencode#2456`) |
| 2026-09-21 | Decomposed compound SCs into atomic single-target SCs: former SC-1 → SC-1/SC-2/SC-3; former SC-2 → SC-4/SC-5; former SC-7 → SC-10/SC-11. 1 SC per item maintained; items/sc-summary/traceability/cost frame renumbered consistently. | Validation finding 2 (compound SCs) | spec-creation validate pipeline (`.opencode#2456`) |
| 2026-09-21 | Reworded disjunctive phrasing: orchestrator decision now a recorded decision field with allowed value-set {continue-new-dispatch, terminate-with-root-cause} (SC-6, R-4); resume gate enumerates `--resume-home`/`--continue` as invocation variants of one mechanism (SC-7, R-5 unchanged in scope). | Validation finding 3 (disjunctive phrasing) | spec-creation validate pipeline (`.opencode#2456`) |
| 2026-09-21 | Decomposed compound SC-6: split into SC-6 (halt+notify on the halt-class trigger states — single-mechanism justification added: the three conditions are the three non-progressing outcomes of the SC-2 classification taxonomy sharing one halt+notify path) and SC-7 (recorded decision field with allowed value-set {continue-new-dispatch, terminate-with-root-cause}). Former SC-7→SC-8, SC-8→SC-9, SC-9→SC-10, SC-10→SC-11, SC-11→SC-12. Reworded SC-10 (false_signal annotation presence as the single assertion) and SC-11 (scenario passing via run as the single assertion, `--list` registration as enabling precondition) per single-assertion/single-deliverable justification. Items split/renumbered (Items 6-12), R-3/R-4 traceability split, cost frame and edge cases renumbered consistently. Restored analytical artifacts directory `.opencode/.issues/2456/artifacts/` from `tmp/issue-2456/artifacts/` (10 artifacts present there; copied all 10 — the finding's "12" count did not match the source directory contents, no artifacts were fabricated). Restored artifacts reflect the pre-split SC numbering (they predate this decomposition); they are the latest generated generation available and were not regenerated (no analysis steps in this task). | Validation findings 1 (compound SC-6), 2 (SC-10/SC-11 sub-flags), 3 (missing artifacts dir) | spec-creation validate pipeline (`.opencode#2456`) |
| 2026-09-21 | Initial spec. | — | Developer (`.opencode#2456`) |

---

Co-authored with AI: OpenCode (zai-org/GLM-5.3-Flash)
