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
| SC-2 | The monitor dispatches a monitoring sub-agent that semantically classifies run state (progressing-directionally / off-track / undetermined) in the sub-agent's own context, given the scenario's goal as a mechanically verifiable goal condition (scenario-declared goal artifact + content pattern) — never the run prompt prose as the direction anchor; the classifier compares run evidence against the verifiable condition. | behavioral | Behavioral run via `with-test-home`: RED asserts no classification dispatch for a monitored run; GREEN asserts the classification sub-agent dispatched with the verifiable goal condition, and that an off-goal run against the condition classifies off-track. |
| SC-3 | A determination record with classification and poll-evidence references is written to the scenario evidence directory. | behavioral | Behavioral run via `with-test-home`: RED asserts no determination record; GREEN asserts record present with classification and poll-evidence references. |
| SC-4 | Direction-anchored off-track classification: off-goal motion is classified off-track and routed to an orchestrator notification (stderr `ORCHESTRATOR_DECISION_REQUIRED`-class convention) — never silently continued. | behavioral | Off-track fixture run (loop scenario) shows the orchestrator notification on stderr and no silent continuation. |
| SC-5 | Progressing runs continue polling regardless of duration. | behavioral | Progressing fixture run continues polling past the duration at which non-progressing runs are halted. |
| SC-6 | Halt-class trigger states — a parsed undetermined classification, excessive classification attempts without a parsed classification (consecutive dispatch failures default 3), or direction-deviation — halt monitoring and notify the orchestrator before any further dispatch; a single starved dispatch is a recorded dispatch-failure event, not a halt-class trigger (R-13). | behavioral | Undetermined-condition run halts monitoring and emits the orchestrator notification; no further dispatch occurs before the recorded decision. |
| SC-7 | The orchestrator decision is recorded in the determination record as a decision field with allowed value-set {continue-new-dispatch, terminate-with-root-cause}, including root-cause when the value is terminate-with-root-cause. | behavioral | The recorded decision field carries exactly one allowed value (with root-cause present for terminate-with-root-cause) in the determination record. |
| SC-8 | A hard gate blocks resume (`--resume-home` or `--continue` — invocation variants of the single resume mechanism) or re-run of an aborted/killed dispatch when no recorded non-undetermined determination exists, exiting with a FATAL-class block; a valid determination permits the resume. | behavioral | Abort a dispatch, attempt resume/re-run without a determination → harness exits with the FATAL block; with a valid determination → proceeds. |
| SC-9 | A ceiling (default 3) on undetermined determination cycles is counted and persisted across invocations; reaching it produces a CEILING_REACHED mechanical block that persists until developer-level remediation. | structural | Mechanical counter predicate verified with synthetic determination records; ceiling = 3 default and CEILING_REACHED message asserted. |
| SC-10 | A reproduced wrong abort (e.g., the #2454 duplicate-running-event over-count) produces a false_signal annotation in the determination record. | behavioral | Reproduce the #2454-style over-count; assert the false_signal annotation is present in the record. |
| SC-11 | The new behavioral enforcement scenario asserting the gate blocks re-dispatch without determination passes via the `test-enforcement.sh` run (RED→GREEN). | behavioral | New scenario passes via `test-enforcement.sh` run; `--list` registration is the enabling precondition of the same single deliverable. |
| SC-12 | `.opencode/tests-v2/AGENTS.md` §10.7, §14, and R-18/§17 mirror the exact implemented gate predicates. | structural | Doc alignment verified by structural advisory checks (mdformat/pymarkdownlnt) against the implemented predicates. |
| SC-13 | A run classified non-progressing (off-track or undetermined) by the full semantic check, with an identifiable external cause in the run evidence (orphaned run processes, provider quota/error output), produces a determination record whose decision field is `terminate-with-root-cause` naming the diagnosed cause; a `continue-new-dispatch` that merely raises a timeout without a recorded diagnosis is prohibited. | behavioral | Stall fixture (hung child + provider-error evidence): the determination record carries decision=`terminate-with-root-cause` with a root-cause naming the identified problem; no timer-escalation continue is possible without a diagnosis. |
| SC-14 | Every poll of a monitored run performs a full semantic check of progress so far — the classification is derived from the run's message parts, reasoning parts, and tool calls in the session export; activity, uptime, or tool-call count is inadmissible as evidence of correct operation, and an activity-only classification is defective. | behavioral | Fixture asserts the classification record cites content parts (messages/reasoning/tool calls) as its basis; an activity-only short-circuit classification fails the scenario. |
| SC-15 | Monitored runs are polled no less often than every 5 minutes (poll interval ≤ 300 seconds). | behavioral | Poll log from a monitored fixture run asserts no gap between consecutive polls exceeds 300 seconds. |
| SC-16 | GREEN-phase dispatches for behavioral scenarios commit and push all test-needed changes to the feature branch BEFORE the isolated test-home run — commit discipline is mechanical (§4 ordered cycle), never a deliberation point; the isolated run pulls the effective commit from the remote branch. | behavioral | Session-export assertion: the GREEN-phase agent's task/push tool calls precede the `with-test-home` run invocation, with no intervening deliberation turns about whether to commit. |
| SC-17 | An agent supervising an `opencode run` polls the run at intervals of at most 5 minutes, and every poll is a full semantic check of progress so far derived from the session export's message parts, reasoning parts, and tool calls; run-retry loops (multiple run invocations) without a semantic check between iterations fail the assertion. | behavioral | Enforcement scenario asserting, from the supervising session's evidence, that consecutive supervision gaps never exceed 300s and every gap is closed by a content-derived classification; a loop of run invocations with no intervening semantic check fails. |
| SC-18 | The supervisor polling mandate (SC-17) is mirrored into the canonical agent-facing instruction surface — `.opencode/tests-v2/AGENTS.md` §14 — so the discipline is default behavior for every sub-agent reading the deck, independent of orchestrator prompt phrasing. | structural | Doc alignment verified by advisory checks (mdformat/pymarkdownlnt) against the implemented predicate; §14 text names the ≤5-min cadence and the per-poll full-semantic-check requirement for agent-supervised runs. |
| SC-19 | An agent setting up an `opencode run` for supervision launches it ASYNCHRONOUSLY (backgrounded/detached) with an attached supervision schedule of no more than 5 minutes between semantic checks of the contents of that run's SQLite session DB (message parts, reasoning parts, tool calls); a blocking foreground invocation, or a launch with no attached ≤5-minute SQLite-DB semantic-poll schedule, fails the assertion. | behavioral | Enforcement scenario asserting, from the supervising session's evidence, that the run was launched asynchronously and a supervision loop reading the run's SQLite session DB at intervals ≤300s was attached at/prior to launch; a blocking launch or a launch with no attached ≤5-min SQLite-DB poll schedule fails. |
| SC-20 | Every 5-minute semantic check of a supervised run's SQLite session DB includes an efficiency analysis: excessive deliberation — large reasoning growth without corresponding tool-call progress, repeated self-correction loops, or over-exploration relative to a straightforward post-spec/post-plan task — is recorded as a defect marker in the poll evidence and routed to the defect notification path; raw model latency (e.g. slow local models) is not itself a defect marker. | behavioral | Fixture with a deliberation-loop run asserts the efficiency defect marker fires (recorded + notified); a latency-dominated but progressing run asserts no marker — discrimination side of the same predicate. |
| SC-21 | A recorded defect marker (efficiency/deliberation or any non-progressing classification with an identified cause) is a HARD GATE: the sub-agent HALTS and notifies the orchestrator; the ORCHESTRATOR performs the research and remediation (run defect vs. spec/plan defect), then — per the orchestrator's determination — dispatches a NEW sub-agent or resumes the existing one; a sub-agent that records the marker and then continues (self-remediating or resuming) fails the assertion. | behavioral | Fixture asserts, from the supervising session's evidence, that after a defect marker was recorded the sub-agent halted with an orchestrator notification, no further run/dispatch launched from the sub-agent, and resumption followed orchestrator-level research + remediation via a new dispatch or an orchestrator-directed resume; a record-then-continue or sub-agent-self-remediate sequence fails. |
| SC-22 | Abort suppression by a progressing classification is valid only while the classification is FRESH: a progressing verdict older than a bounded freshness window (re-classification at least every N polls, and on every new abort-signal event) never suppresses abort signals; a derailed run riding a stale verdict must be re-classified and aborted. | behavioral | Fixture: a run that derails after a progressing classification gets re-classified within the freshness bound and the abort fires; a run whose classification is re-affirmed continues. |
| SC-23 | Each monitored fixture run starts from a FRESH test home and a fresh session — reuse of a prior attempt's test home or session DB is prohibited; foreign instructions from earlier sessions must never appear in a monitored run's context. | behavioral | Fixture asserts, from the run's session DB, that the session contains no prior-session messages (fresh session id, no foreign task instructions); a reused home/DB fails. |
| SC-24 | Once a scenario's declared verdict surface is decided (e.g. RED condition confirmed or the assertion satisfied), the supervisor TERMINATES the monitored run immediately (kill run + monitor, capture exit/artifact evidence) instead of waiting for natural completion — running a scenario to its end after the verdict is decided, with no remaining evidence value, is prohibited. Exception: scenarios whose verdict surface itself requires continued running (e.g. continue-past-cap) terminate at the surface's own endpoint. | behavioral | Fixture asserts, from the supervising session's evidence, that the run/monitor processes were terminated within one poll cycle of the verdict becoming decided; a wait-for-exit sequence after a decided verdict fails. |
| SC-25 | Process cleanup patterns used by agents (kill/pkill/grep-xargs-kill) MUST exclude the agent's OWN session process tree — the supervising agent itself and its ancestors run under an `opencode`-matching command line, so an unrestricted grep-kill of "opencode run" processes is a self-kill. Cleanup targets processes by scenario-specific markers (scenario name, test-home path) with the own session PID and parent PIDs excluded. | behavioral | Fixture asserts, from the supervising session's evidence, that a cleanup action's kill targets never include the supervising session's own process tree; a cleanup that kills the agent's own session (or would, per target selection) fails. |
| SC-26 | A hung session is a CLEAR FAIL: when a supervised run's model stream is hung — no new events/output growth across a bounded watch window (default: 2 consecutive supervision polls beyond the first stall-observation poll, ≈10 minutes) with no provider-error explanation recorded — the supervisor records the verdict FAILED (stall) with root-cause `provider stream hung`, TERMINATES the run + monitor, and returns control for a fresh-dispatch remediation; "letting it proceed" / open-ended wait-on-hang is prohibited. | behavioral | Fixture: a hung-stream run reaches the bound → supervisor records FAILED(stall) + terminates within one poll cycle; a wait-on-hang sequence ("letting it proceed") fails. |

**SC-6 trigger-class single-mechanism justification:** The three halt-class conditions (undetermined / excessive-without-classification / direction-deviation) share one mechanism — they are exactly the three non-`progressing-directionally` outcomes of the single classification taxonomy defined in SC-2, and each routes through the identical halt+notify path (the same code path as SC-4's off-track notification, minus the distinct classification label). One classification enum, one halt+notify mechanism → one trigger class → one SC. The recorded decision field is a distinct deliverable (record schema + orchestrator write path) and is therefore verified separately as SC-7.

**SC-10 / SC-11 single-deliverable justification:** SC-10's single verification target is the presence of the false_signal annotation in the determination record after a reproduced wrong abort; the annotation's presence is the sole assertion (its existence is precisely what prevents silent retry — the "no silent retry" property is the absence-side of the same single deliverable, not a separate mechanism). SC-11's single deliverable is the enforcement scenario; "passing via run" is the one assertion, and `--list` registration is the enabling precondition of that same scenario deliverable, not an independent verification target.

**SC-13 single-assertion justification:** The single verification target is the recorded decision field on the stall fixture's determination record — `terminate-with-root-cause` with a root-cause naming the identified problem. The prohibition on timer-escalation re-dispatch is the absence-side of the same deliverable: without a recorded diagnosis, SC-8's gate blocks any resume/re-run, so a blind continue-new-dispatch is structurally impossible once the record carries terminate-with-root-cause. One mechanism (diagnosis-before-retry), one assertion. The trigger is the semantic classification itself (SC-14's full semantic check per poll) — never an activity heuristic.

**SC-14 single-assertion justification:** The single verification target is the admissible-evidence rule for classification: every poll's classification is derived from message parts, reasoning parts, and tool calls. The negative case (an activity-only short-circuit must fail) is the absence-side of the same predicate, not a separate mechanism — one rule (content-derived classification per poll), one assertion.

**SC-16 single-assertion justification:** The single verification target is the ordering invariant of the §4 ordered cycle at GREEN-phase dispatch: all test-needed changes committed AND pushed to the feature branch before the isolated test-home run starts. Commit deliberation (asking whether to commit, narrating commit options, or running the test against uncommitted state) is the absence-side of the same ordering predicate — one rule (commit+push mechanically precede the run), one assertion.

**SC-17 single-assertion justification:** The single verification target is the supervisor cadence invariant: consecutive supervision gaps ≤ 300s, each closed by a content-derived semantic check. The loop-without-checks failure (run-retry invocations with no intervening semantic check) is the absence-side of the same cadence predicate — one rule (supervise at ≤5-min with full semantic checks), one assertion.

**SC-18 single-assertion justification:** The single verification target is the presence and fidelity of the mirrored mandate in AGENTS.md §14 — the cause fix for non-default supervisor behavior (the mandate previously existed only in orchestrator dispatch prompts, never in the deck the sub-agents actually read). One surface, one assertion.

**SC-19 single-assertion justification:** The single verification target is the launch-form invariant: an agent-supervised `opencode run` is launched asynchronously with an attached ≤5-min supervision schedule. The blocking-launch failure shape (foreground wait, launch-without-supervision-schedule) is the absence-side of the same launch-form predicate — one rule (async launch + attached supervision loop), one assertion.

**SC-20 single-assertion justification:** The single verification target is the efficiency-defect marker evaluated at every supervision poll: excessive deliberation relative to a straightforward post-spec/post-plan task is recorded and notified. The latency discrimination (slow local models are not a defect) is the negative side of the same predicate — the marker keys on deliberation-to-progress ratio, not wall-clock duration. One mechanism (efficiency analysis per poll), one assertion.

**SC-21 single-assertion justification:** The single verification target is the gating consequence of a recorded marker: the sub-agent halts and hands the defect to the orchestrator, and resumption follows only orchestrator-level research + remediation. The record-then-ignore failure (marker logged as a note, next run launched anyway — the live 2026-09-22 failure shape) and the sub-agent-self-remediate failure are both absence-sides of the same gating predicate. One rule (recorded marker ⇒ halt + orchestrator research/remediation/resumption), one assertion.

**SC-22 single-assertion justification:** The single verification target is the freshness bound on abort suppression: a progressing verdict suppresses aborts only within its freshness window. The stale-verdict failure (derailed run carried indefinitely by a poll-12 classification — live 2026-09-23 evidence) is the absence-side of the same predicate. One rule (fresh classification or no suppression), one assertion.

**SC-23 single-assertion justification:** The single verification target is session isolation: a monitored fixture run's session DB contains no prior-session content. The contamination failure (foreign task instructions injected into the run's context — live 2026-09-23 evidence) is the absence-side of the same predicate. One rule (fresh home + fresh session per run), one assertion.

**SC-24 single-assertion justification:** The single verification target is the termination trigger: verdict decided ⇒ terminate within one poll cycle (unless continued running is itself the verdict surface). The wait-for-exit failure (RED confirmed, then waiting through the run's natural end — live 2026-09-23 evidence) is the absence-side of the same predicate. One rule (decided verdict ⇒ early termination), one assertion.

**SC-25 single-assertion justification:** The single verification target is the cleanup-target-selection predicate: kill targets exclude the own session PID and parent PIDs, keyed by scenario-specific markers. The self-kill failure (broad grep-kill of "opencode run" — live 2026-09-23 evidence: the orchestrator terminated its own session with an unrestricted pattern) is the absence-side of the same predicate. One rule (markered targets + own-tree exclusion), one assertion.

**SC-26 single-assertion justification:** The single verification target is the hang-bound: no event/output growth across the bounded window ⇒ verdict FAILED(stall) + terminate. The wait-on-hang failure ("The run is stalled organically … Letting it proceed; continuing supervision polls" — live 2026-09-24 evidence) is the absence-side of the same predicate. One rule (bound exceeded ⇒ clear FAIL + terminate), one assertion.

## Requirements

R-1. The harness monitor SHALL persist poll evidence for every monitored run and SHALL dispatch a monitoring sub-agent that semantically classifies run state in the sub-agent's own context, given the scenario's goal/expected-behavior context.

R-2. The harness SHALL classify a run as progressing-directionally only when its activity moves toward the scenario's mechanically verifiable goal condition; off-goal motion against the condition SHALL be classified off-track and SHALL trigger orchestrator notification — off-track runs SHALL never continue silently. Progressing runs SHALL continue polling regardless of duration. The run prompt prose SHALL NOT serve as the direction anchor.

R-3. The harness SHALL halt monitoring and notify the orchestrator when classification is undetermined, when the run is excessive without classification, or on direction deviation, before any further dispatch (the halt-class trigger states of SC-6 — one halt+notify mechanism for the three non-progressing classification outcomes).

R-4. The orchestrator SHALL record its decision in the determination record as a decision field with allowed value-set {continue-new-dispatch, terminate-with-root-cause}; when the recorded value is terminate-with-root-cause, the record SHALL include the root-cause.

R-5. The harness SHALL block resume or re-run of an aborted/killed dispatch when no recorded non-undetermined determination exists, and SHALL mechanically block (CEILING_REACHED) after a ceiling of 3 undetermined determination cycles, persisted across invocations.

R-6. The harness SHALL fold wrong aborts (false-positive monitor signals) into the determination record as false_signal annotations and SHALL NOT silently retry them.

R-7. The repository SHALL contain a behavioral enforcement scenario asserting the gate blocks re-dispatch without a determination, and `.opencode/tests-v2/AGENTS.md` (§10.7, §14, R-18/§17) SHALL mirror the exact implemented gate predicates.

R-8. The determination record SHALL be a durable YAML artifact written in the scenario evidence directory alongside session.yaml and the poll log, with append-only semantics for false_signal annotations and orchestrator decisions.

R-9. When the full semantic check (R-10) classifies a run as non-progressing (off-track or undetermined) and the run evidence identifies an external cause (orphaned run processes, provider quota/error output), the recorded orchestrator decision SHALL be terminate-with-root-cause naming the diagnosed cause. Re-dispatching with an increased timeout, or repeated timer escalation in a loop, without a recorded root-cause diagnosis SHALL be prohibited — the SC-8 gate blocks any resume/re-run until the diagnosis-bearing determination exists.

R-10. Every poll of a monitored run SHALL perform a full semantic check of progress so far: the classification SHALL be derived from the run's message parts, reasoning parts, and tool calls in the session export. Activity, uptime, or tool-call count SHALL NOT be treated as evidence of correct operation and SHALL NOT substitute for or short-circuit the semantic classification.

R-11. Monitored runs SHALL be polled no less often than every 5 minutes (poll interval ≤ 300 seconds).

R-12. GREEN-phase dispatches for behavioral scenarios SHALL treat the §4 ordered cycle (commit → push → fresh fetch → containment verification) as mechanical and SHALL commit and push all test-needed changes to the feature branch BEFORE the isolated test-home run, which pulls the effective commit from the remote branch. Deliberating about whether to commit, asking for commit confirmation, or running the test against uncommitted/unpushed state SHALL be prohibited.

R-13. A classification dispatch that produces no parseable classification (starved, UNPARSED, or model-failure output) SHALL be recorded as a DISPATCH FAILURE event — the attempt and its failure mode are recorded in the poll evidence — and is NOT a classification: it SHALL NOT trigger halt-class handling (SC-6) by itself, SHALL NOT count toward the undetermined-cycle ceiling (SC-9), and SHALL be retried per the checkpoint policy. A run of 3 consecutive dispatch failures (default) SHALL halt monitoring with a HARNESS_FAILURE-class notification naming the infrastructure failure (developer-level remediation surface: model queue/provisioning) — a starved dispatch never produces a silent classification-or-continuation.

R-14. An agent supervising an `opencode run` SHALL poll the run at intervals of at most 5 minutes, and every poll SHALL be a full semantic check of progress so far derived from the session export's message parts, reasoning parts, and tool calls. Run-retry loops (multiple run invocations) without a semantic check between iterations, and single waits longer than 300 seconds without a semantic check, SHALL be prohibited.

R-15. The supervisor polling mandate (R-14) SHALL be mirrored into `.opencode/tests-v2/AGENTS.md` §14 — the canonical agent-facing instruction surface — so the discipline is default behavior for every sub-agent reading the deck, independent of orchestrator prompt phrasing.

R-16. An agent setting up an `opencode run` for supervision SHALL launch it asynchronously (backgrounded/detached) with an attached supervision schedule of no more than 5 minutes between semantic checks of the contents of that run's SQLite session DB (message parts, reasoning parts, tool calls). A blocking foreground invocation — waiting on the run to finish without periodic SQLite-DB semantic checks, or launching in a way that precludes periodic SQLite-DB inspection — SHALL be prohibited.

R-17. Every 5-minute semantic check of a supervised run's SQLite session DB SHALL include an efficiency analysis: excessive deliberation (large reasoning growth without corresponding tool-call progress, repeated self-correction loops, or over-exploration relative to a straightforward post-spec/post-plan task) SHALL be recorded as a defect marker in the poll evidence and routed to the defect notification path. Raw model latency (e.g. slow local models processing the same work) SHALL NOT be treated as a defect marker — the marker keys on deliberation-to-progress ratio, not wall-clock duration.

R-18. A recorded defect marker (efficiency/deliberation marker or any non-progressing classification with an identified cause) SHALL act as a HARD GATE: the sub-agent SHALL halt immediately, notify the orchestrator (ORCHESTRATOR_DECISION_REQUIRED-class), and perform no further runs or dispatches. The ORCHESTRATOR SHALL research and remediate the defect (run defect vs. spec/plan defect), then — per the orchestrator's determination — dispatch a NEW sub-agent or resume the existing sub-agent as appropriate. The sub-agent SHALL NOT self-remediate and SHALL NOT resume. Recording the marker and continuing, or sub-agent-side remediation/resumption, SHALL be prohibited.

R-21. Abort suppression based on a progressing classification SHALL be valid only while that classification is fresh: the monitor SHALL re-classify at least every N polls (bounded freshness window) and on every new abort-signal event; a stale progressing verdict SHALL never suppress an abort signal.

R-22. Each monitored fixture run SHALL start from a fresh test home and a fresh session; reuse of a prior attempt's test home or session DB SHALL be prohibited, and foreign instructions from earlier sessions SHALL never appear in a monitored run's context.

R-23. Once a scenario's declared verdict surface is decided, the supervisor SHALL terminate the monitored run and its monitor within one poll cycle and capture the exit/artifact evidence; waiting for natural completion after a decided verdict SHALL be prohibited, except where the verdict surface itself requires continued running (in which case termination occurs at the surface's own endpoint).

R-24. Agent process-cleanup patterns SHALL select kill targets by scenario-specific markers (scenario name, test-home path) and SHALL exclude the agent's own session PID and parent PIDs — an unrestricted grep/pkill pattern matching "opencode run" or similar is prohibited, because the supervising agent itself matches. After any cleanup, the agent SHALL verify its own session is still alive.

R-25. A supervised run whose model stream is hung (no new events/output growth across the bounded hang window — default 2 consecutive polls beyond the first stall observation, no provider-error explanation on record) SHALL receive the verdict FAILED (stall): the supervisor records the verdict + root-cause `provider stream hung`, terminates run + monitor, and returns control for fresh-dispatch remediation (SC-21 orchestrator flow). Waiting on a hung session to recover SHALL be prohibited — a hung session is useless and is a clear FAIL.

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

### Item 13 (SC-13): Diagnosis-before-retry on semantically classified non-progressing runs

- RED: Fixture run classified non-progressing (off-track/undetermined) by the full semantic check, with an identifiable external cause in the run evidence, produces a determination record with no decision or a bare continue-new-dispatch — assertion fails.
- GREEN: The recorded decision is terminate-with-root-cause naming the diagnosed external cause; SC-8's gate blocks any timer-escalation re-dispatch until that record exists.
- verify: Behavioral fixture asserts decision=terminate-with-root-cause with a root-cause naming the identified problem.
- commit: helpers.sh stall-classification → decision-record path + §14 alignment.

### Item 14 (SC-14): Full semantic check on every poll

- RED: Monitor poll issues a classification without deriving it from message parts, reasoning parts, and tool calls (activity-only short-circuit) — assertion fails.
- GREEN: Every poll performs a full semantic check of progress so far; the classification record cites the content parts (messages/reasoning/tool calls) it derived from; activity/uptime/tool-call-count is inadmissible.
- verify: Behavioral fixture asserts content-citing classification; activity-only classification fails.
- commit: helpers.sh per-poll semantic-check path.

### Item 15 (SC-15): Poll cadence floor (≤ 5 minutes)

- RED: Monitored fixture run shows a poll gap exceeding 300 seconds — assertion fails.
- GREEN: Monitor polls at least every 5 minutes; no consecutive-poll gap exceeds 300s.
- verify: Behavioral fixture asserts poll-log gaps ≤ 300s.
- commit: helpers.sh monitor loop interval.

### Item 16 (SC-16): Mechanical commit+push before isolated test-home runs

- RED: GREEN-phase fixture agent deliberates about whether to commit (or runs the test against uncommitted state) before the isolated run — session-export ordering assertion fails.
- GREEN: All test-needed changes are committed and pushed to the feature branch mechanically, before the `with-test-home` run invocation; no deliberation turns intervene.
- verify: Behavioral session-export assertion — task/push tool calls precede the run invocation.
- commit: fixture scenario + prompt-template discipline (§14 alignment).

### Item 17 (SC-17): Supervisor polling mandate enforcement

- RED: Supervising-agent fixture loops run invocations (1..4 retries) with 5-minute waits and no semantic checks between iterations, or single waits > 300s — the cadence assertion fails.
- GREEN: The supervisor polls at ≤5-min intervals, every poll a full semantic check from message/reasoning/tool-call parts; run-retry loops carry a semantic check between iterations.
- verify: Behavioral session-export assertion — consecutive supervision gaps ≤ 300s, each closed by a content-derived classification.
- commit: enforcement scenario + §14 alignment groundwork.

### Item 18 (SC-18): Mandate mirrored into AGENTS.md §14

- RED: AGENTS.md §14 does not carry the supervisor polling mandate (≤5-min cadence, per-poll full semantic check, no-check retry loops prohibited) for agent-supervised runs — advisory structural check fails.
- GREEN: §14 updated to mirror the exact predicate; task-card-reachable by default.
- verify: Advisory markdown checks clean; content matches the implemented predicate.
- commit: AGENTS.md §14 sections.

### Item 19 (SC-19): Async launch with attached supervision loop

- RED: Supervising-agent fixture launches the run in the FOREGROUND (blocking wait on completion, no periodic SQLite-DB semantic checks) or launches without attaching a ≤5-minute SQLite-DB supervision schedule — the launch-form assertion fails.
- GREEN: The run is launched asynchronously (backgrounded/detached) with an attached supervision loop that reads that run's SQLite session DB at intervals ≤300s.
- verify: Behavioral session-export assertion — async launch + SQLite-DB supervision schedule (≤5 min between semantic checks of the run's session DB contents) attached at/prior to launch.
- commit: enforcement scenario.

### Item 20 (SC-20): Efficiency-defect marker at every supervision poll

- RED: Deliberation-loop fixture run (large reasoning growth, repeated self-correction, minimal tool-call progress toward a straightforward goal) produces no efficiency defect marker in the poll evidence and no defect notification — assertion fails.
- GREEN: Every supervision poll includes the efficiency analysis; excessive deliberation is recorded as a defect marker and routed to the defect notification path; latency-dominated progressing runs carry no marker.
- verify: Behavioral fixture asserts the marker fires on the deliberation loop and does not fire on the latency-dominated progressing control.
- commit: helpers.sh efficiency-marker path + §14 alignment.

### Item 21 (SC-21): Recorded defect marker = hard gate (orchestrator research + remediation)

- RED: Supervising-agent fixture records a defect marker (deliberation loop) and then launches another run/dispatch, or self-remediates/resumes without orchestrator involvement — the gating assertion fails.
- GREEN: After the marker is recorded, the sub-agent halts with an ORCHESTRATOR_DECISION_REQUIRED-class notification; the orchestrator researches and remediates (run defect vs. spec/plan defect), then dispatches a new sub-agent or resumes the existing one per the orchestrator's determination.
- verify: Behavioral session-export assertion — marker → sub-agent halt + orchestrator notification → orchestrator research/remediation → orchestrator-directed resumption (new dispatch or resume).
- commit: enforcement scenario + §14 alignment.

### Item 22 (SC-22, R-21): Classification freshness bound on abort suppression

- RED: Fixture run derails after a progressing classification; the stale verdict suppresses every subsequent abort signal with no re-classification — the freshness assertion fails.
- GREEN: The monitor re-classifies at least every N polls (and on new abort-signal events); a derailed run is re-classified and aborted; a genuinely progressing run continues.
- verify: Behavioral fixture asserts re-classification within the bound and correct abort behavior on the derailed run.
- commit: helpers.sh freshness-bound path.

### Item 23 (SC-23, R-22): Fresh-session isolation for monitored runs

- RED: Fixture reuses a prior attempt's test home/session DB; the run's context contains foreign prior-session instructions — the isolation assertion fails.
- GREEN: Each monitored run starts from a fresh test home + fresh session; no prior-session content in context.
- verify: Behavioral fixture asserts fresh session id and zero prior-session messages in the run's DB.
- commit: with-test-home/helpers.sh isolation path.

### Item 24 (SC-24, R-23): Early termination on decided verdict

- RED: Supervising-agent fixture confirms the RED verdict and then waits for the scenario to fully exit (no termination) — the early-termination assertion fails.
- GREEN: On a decided verdict, the supervisor terminates run + monitor within one poll cycle and captures the exit/artifact evidence.
- verify: Behavioral session-export assertion — termination within one poll cycle of the decided verdict (or at the surface's own endpoint for continue-surface scenarios).
- commit: enforcement scenario + §14 alignment.

### Item 25 (SC-25, R-24): Self-kill prevention in process cleanup

- RED: Cleanup fixture uses a broad grep-kill pattern matching "opencode run" (targets include the supervising session's own tree) — the target-selection assertion fails.
- GREEN: Cleanup selects targets by scenario-specific markers (scenario name, test-home path) with own-PID and parent-PID exclusion; after cleanup the agent verifies its own session is alive.
- verify: Behavioral session-export assertion — kill-target selection excludes the own process tree.
- commit: enforcement scenario + §14 alignment.

### Item 26 (SC-26, R-25): Hung session = clear FAIL

- RED: Hung-stream fixture (no events/output growth across the bounded window, no provider-error explanation on record) — the supervisor lets it proceed / keeps polling; the clear-FAIL assertion fails.
- GREEN: At the hang bound the supervisor records FAILED(stall) with root-cause provider-stream-hung and terminates run + monitor within one poll cycle.
- verify: Behavioral session-export assertion — bound exceeded ⇒ FAILED verdict + termination; no wait-on-hang.
- commit: enforcement scenario + supervision-loop wiring.

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
| R-9 | SC-13 | Per-item (helpers.sh stall-classification → decision-record path) |
| R-10 | SC-14 | Per-item (helpers.sh per-poll semantic-check path) |
| R-11 | SC-15 | Per-item (helpers.sh monitor loop interval) |
| R-12 | SC-16 | Per-item (fixture scenario; §14 prompt-template alignment) |
| R-14 | SC-17 | Per-item (enforcement scenario; supervisor cadence predicate) |
| R-15 | SC-18 | Per-item (AGENTS.md §14 mirror) |
| R-16 | SC-19 | Per-item (enforcement scenario; launch-form predicate) |
| R-17 | SC-20 | Per-item (helpers.sh efficiency-marker path; §14 alignment) |
| R-18 | SC-21 | Per-item (enforcement scenario; gating predicate) |
| R-21 | SC-22 | Per-item (helpers.sh freshness-bound path) |
| R-22 | SC-23 | Per-item (with-test-home/helpers.sh isolation path) |
| R-23 | SC-24 | Per-item (enforcement scenario; early-termination predicate) |
| R-24 | SC-25 | Per-item (enforcement scenario; cleanup-target-selection predicate) |
| R-25 | SC-26 | Per-item (enforcement scenario; hang-bound predicate) |

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
- SC-13: Running the stall fixture costs minutes. Skipping costs days — stalls with identifiable causes (orphaned processes, provider quota exhaustion) get answered with endlessly increasing timers and blind re-dispatch (live evidence: the 2026-09-21 #2437 RED run hung ~4 hours on an orphaned `opencode run` while a provider quota error sat unread in the logs), burning hours per occurrence with zero diagnostic output and never surfacing the actual blocker.
- SC-14: Running the full-semantic-per-poll fixture costs minutes. Skipping costs weeks — agents treat any activity (alive process, incrementing tool calls) as health and skip semantic analysis entirely; the 2026-09-21 #2437 evidence shows activity-based reasoning re-dispatching blindly while a provider quota error sat unread. Only content-derived classification catches "active but off-goal" runs.
- SC-15: Running the cadence fixture costs minutes. Skipping costs days — a silent stall goes unexamined for the entire bash-tool timeout window, defeating every downstream classification and determination guarantee; a 5-minute floor bounds the blind window.
- SC-16: Running the ordering fixture costs minutes. Skipping costs weeks — GREEN-phase agents keep burning turns deliberating about whether to commit (live evidence: the 2026-09-21 #2437 SC-2 GREEN dispatch was cancelled mid-deliberation), then run tests against state the isolated home cannot pull; the mechanical commit+push ordering removes the entire deliberation class.
- SC-17: Running the supervisor-cadence fixture costs minutes. Skipping costs weeks — supervising agents treat runs as blocking black boxes: single 45-min waits, or 1..4 run-retry loops with 5-min sleeps and zero semantic checks (live evidence: the 2026-09-22 #2456 SC-4 RED dispatches), burning the dispatch ceiling while never reading the message/reasoning/tool-call evidence that would surface the actual blocker in minutes.
- SC-18: Running the doc-alignment check costs seconds. Skipping costs weeks — the mandate lives only in orchestrator dispatch prompts (the identified cause of non-default supervisor behavior); agents who miss the prompt phrasing revert to black-box waits, and every future dispatch inherits the defect.
- SC-19: Running the launch-form fixture costs minutes. Skipping costs weeks — the recurrence persisted across two prompt-phrasings (live evidence: after SC-17/18 were added, the 2026-09-22 pre-regression dispatch was again set up as a foreground/blocking run with no attached ≤5-min supervision), proving the defect is the launch FORM, not prompt wording; only an enforced async-launch + attached-supervision-loop predicate closes it.
- SC-20: Running the efficiency-marker fixtures costs minutes. Skipping costs weeks — excessive deliberation after spec+plan exist is a defect signal (in the run, the spec, or the plan) that currently surfaces only when a human notices poor efficiency (live evidence: 2026-09-22 post-regression runs recorded 60k+ reasoning chars with zero new tool calls; a monitored run burned 44 polls over-deliberating a batched-write self-correction). Per-poll efficiency analysis catches it within 5 minutes and routes it to the notification path; without it, slow local models multiply the wasted wall-clock per undetected deliberation loop.
- SC-21: Running the gating fixture costs minutes. Skipping costs weeks — recording without acting is the observed default (live evidence: the 2026-09-22 RED SC-5 attempt logged the reasoning-runaway and classifier-starvation findings as calibration notes, then bumped MAX_POLLS and re-ran — burning more live-model budget on the same undiagnosed defect). The gate converts the marker from telemetry into enforcement; without it every marker upstream of this one is decoration.
- SC-22: Running the freshness fixture costs minutes. Skipping costs weeks — a stale progressing verdict suppresses aborts indefinitely, carrying derailed runs past 200+ polls (live 2026-09-23 evidence) while the budget burns unread; the freshness bound makes every suppression a bounded, re-examined decision.
- SC-23: Running the isolation fixture costs minutes. Skipping costs weeks — reused homes inject foreign task instructions into monitored runs (live 2026-09-23 evidence: the run pivoted to a prior session's file-copy task mid-loop), producing verdicts about runs that never executed their own scenario; fresh-session isolation makes every run's evidence self-contained.
- SC-24: Running the early-termination fixture costs minutes. Skipping costs weeks — after a RED verdict is confirmed, every additional poll burns live-model tokens on a run whose evidentiary value is already spent (live 2026-09-23 evidence: "RED CONFIRMED verdict emitted. Waiting for the scenario to fully exit"), and on slow local models the waste compounds per poll; decided-verdict termination bounds every scenario to its evidence value.
- SC-25: Running the cleanup-selection fixture costs minutes. Skipping costs weeks — a self-kill terminates the running session mid-pipeline, losing the entire in-flight pipeline state and requiring crash recovery (live 2026-09-23 evidence: the orchestrator killed its own session with an unrestricted "opencode run" grep-kill); one enforced marker+exclusion rule prevents every recurrence.
- SC-26: Running the hang-bound fixture costs minutes. Skipping costs weeks — waiting on a hung provider stream burns the entire remaining poll budget on zero evidence production (live 2026-09-24 evidence: "Letting it proceed; continuing supervision polls" after a dead stream), and slow local models make every wasted poll expensive; the bounded clear-FAIL converts dead sessions into fast fresh-dispatch decisions.

## Edge Cases

- **Condition:** Determination record missing at gate time (aborted before any classification ran). **Expected behavior:** The resume/re-run gate blocks with a FATAL-class message. **Resolution:** Re-run from scratch records a fresh determination; no partial binding.
- **Condition:** Determination record exists but classification is `undetermined`. **Expected behavior:** The gate blocks resume/re-run (only non-undetermined determinations authorize resume); the undetermined cycle counter increments on orchestrator-continue. **Resolution:** Third cycle → CEILING_REACHED until developer-level remediation.
- **Condition:** Concurrent scenario runs contending for the ceiling counter. **Expected behavior:** Counter persistence respects the existing `tmp/.behavior-run.lock` flock discipline — no new locking scheme. **Resolution:** Contention serialized by the existing lock; no counter corruption.
- **Condition:** Monitor false-positive abort (parser duplicate-event over-count). **Expected behavior:** Folded into the determination record as a false_signal annotation; not silently retried. **Resolution:** Record carries the annotation; run state resumes only through the recorded determination path.
- **Condition:** Scenario goal context unavailable or empty for the classification dispatch. **Expected behavior:** Classification cannot anchor direction → classified undetermined, halting with orchestrator notification (fail-fast; no default classification). **Resolution:** Halt+notify (SC-6) then orchestrator decision loop (SC-7) governs continuation.
- **Condition:** Sub-agent dispatch of the classifier fails (model/harness error). **Expected behavior:** Halt + orchestrator notification — never a silent fallback to shell-heuristic classification. **Resolution:** Determination record records the failure; orchestrator decides continue/terminate.
- **Condition:** `BEHAVIOR_SEMANTIC_MONITOR` unset (default invocations). **Expected behavior:** No monitor, no gate coupling — fresh invocations unchanged (backward compatible). **Resolution:** Out of the determination lifecycle entirely.
- **Condition:** Stalled run with zero progress evidence and an identifiable external cause (orphaned processes, provider quota error in run output). **Expected behavior:** Recorded decision is terminate-with-root-cause naming the diagnosed cause; SC-8's gate blocks any re-dispatch or timer escalation until the diagnosis-bearing record exists. **Resolution:** Diagnose from run evidence, record root cause, remediate (kill orphans, clean locks, resolve provider state), then re-dispatch.
- **Condition:** Run is active (alive process, incrementing tool-call count) but not moving toward the scenario goal (reasoning loops, timer escalation, re-dispatch churn). **Expected behavior:** The full semantic check (message/reasoning/tool-call parts) classifies it off-track — activity alone never yields progressing. **Resolution:** Off-track notification + orchestrator decision path (SC-4/SC-6/SC-7); diagnosis-before-retry (SC-13) applies.
- **Condition:** Poll gap exceeds 300 seconds on a monitored run. **Expected behavior:** Monitor defect — the cadence predicate (SC-15) fails the scenario; the poll log exposes the gap. **Resolution:** Fix the monitor loop interval; no silent widening of the poll window.
- **Condition:** GREEN-phase agent holds uncommitted test-needed changes when the isolated run starts. **Expected behavior:** Ordering violation — SC-16's assertion fails; the run pulls a remote commit that does not contain the changes, producing verdicts about nonexistent code. **Resolution:** Mechanical commit+push (§4 ordered cycle) before any run invocation; no deliberation.
- **Condition:** Supervising agent launches a run and sleeps through a long budget (single wait > 300s) or retries runs (1..N invocations) with waits and no semantic checks between iterations. **Expected behavior:** Cadence violation — SC-17's assertion fails; the run's actual blocker (provider error, off-track loop, orphaned process) sits unread while the budget burns. **Resolution:** Supervise in a loop: sleep ≤ 300s → read message/reasoning/tool-call parts → classify → act on the classification (diagnose non-progressing states from evidence, never re-dispatch blind).
- **Condition:** Sub-agent reads its task card but no orchestrator prompt phrasing about supervision. **Expected behavior:** The mandate is still followed — SC-18 mirrors it into AGENTS.md §14, the canonical surface sub-agents executing tests-v2 scenarios read by default. **Resolution:** Deck-level default, not prompt-level hope.
- **Condition:** Agent sets up the run as a blocking foreground invocation (waits on completion, or launches without an attached supervision schedule). **Expected behavior:** Launch-form violation — SC-19's assertion fails; no periodic semantic inspection of the run's SQLite session DB can occur, so a mid-run blocker (provider error, off-track loop, orphan) burns the budget unread. **Resolution:** Launch asynchronously with an attached supervision loop reading the run's SQLite session DB at intervals ≤300s.
- **Condition:** Run shows large reasoning growth with little tool-call progress, or repeated self-correction loops, on a straightforward post-spec/post-plan task. **Expected behavior:** Efficiency defect marker fires at the next ≤5-min poll — recorded in the poll evidence and routed to the defect notification path; the orchestrator treats it as a defect signal (in the run, the spec, or the plan) rather than a duration problem. **Resolution:** Diagnose from the evidence (run defect vs spec/plan defect), record root cause, remediate; do not merely extend budgets.
- **Condition:** Run is slow but progressing (slow local model, long inference per tool call). **Expected behavior:** No efficiency marker — raw model latency is not a defect; the marker keys on deliberation-to-progress ratio. **Resolution:** Progressing runs continue polling regardless of duration (SC-5).
- **Condition:** A defect marker is recorded (deliberation marker or non-progressing classification with identified cause). **Expected behavior:** Hard gate — the sub-agent halts and notifies the orchestrator; the orchestrator researches and remediates (run defect vs. spec/plan defect), then dispatches a new sub-agent or resumes the existing one per the orchestrator's determination; the sub-agent never self-remediates or resumes. **Resolution:** Record-then-continue and sub-agent-side remediation are prohibited (SC-21); resumption requires orchestrator-level research + remediation, with the resumption form (new dispatch vs. resume) at orchestrator discretion.
- **Condition:** A progressing classification is stale (older than the freshness window) and a new abort signal fires. **Expected behavior:** The stale verdict does not suppress the abort — the run is re-classified first, and the abort decision is made on the fresh verdict. **Resolution:** Freshness-bound re-classification (SC-22); suppression only within the window.
- **Condition:** A monitored run's context contains instructions from a prior session (reused home/DB). **Expected behavior:** Isolation violation — SC-23's assertion fails; the run's evidence is not self-contained and verdicts about it are invalid. **Resolution:** Fresh test home + fresh session per monitored run; detect reuse by session-id and prior-message scan.
- **Condition:** The scenario's verdict becomes decided mid-run (e.g. RED condition confirmed) and the run keeps executing. **Expected behavior:** The supervisor terminates run + monitor within one poll cycle and captures exit/artifact evidence; waiting for natural exit is prohibited. **Resolution:** Decided-verdict early termination (SC-24); exception only where continued running is the verdict surface itself.
- **Condition:** Agent performs process cleanup (killing stale/orphaned runs). **Expected behavior:** Kill targets are selected by scenario-specific markers with the own session PID and parent PIDs excluded; after cleanup the agent verifies its own session survived. **Resolution:** Markered target selection (SC-25); a broad pattern that matches the agent's own command line is prohibited and must never execute.
- **Condition:** A supervised run's model stream is hung (no events/output growth over the bounded window, no provider-error on record). **Expected behavior:** Clear FAIL — verdict FAILED(stall) recorded with root-cause provider-stream-hung; run + monitor terminated within one poll cycle; fresh-dispatch remediation via the SC-21 orchestrator flow. **Resolution:** Never wait on a hung session; the bound (default 2 consecutive polls beyond first stall observation) triggers the verdict automatically.

## Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-09-21 | Retyped SC-8 (former SC-5, ceiling gate) from behavioral to structural evidence type — ceiling gate is mechanical bookkeeping; behavioral gate enforcement remains covered by the live scenario SC. Testability-assessment artifact's 'mixed' label retired with artifact regeneration. | Validation finding 1 (EVIDENCE_TYPE_MISMATCH) | spec-creation validate pipeline (`.opencode#2456`) |
| 2026-09-21 | Decomposed compound SCs into atomic single-target SCs: former SC-1 → SC-1/SC-2/SC-3; former SC-2 → SC-4/SC-5; former SC-7 → SC-10/SC-11. 1 SC per item maintained; items/sc-summary/traceability/cost frame renumbered consistently. | Validation finding 2 (compound SCs) | spec-creation validate pipeline (`.opencode#2456`) |
| 2026-09-21 | Reworded disjunctive phrasing: orchestrator decision now a recorded decision field with allowed value-set {continue-new-dispatch, terminate-with-root-cause} (SC-6, R-4); resume gate enumerates `--resume-home`/`--continue` as invocation variants of one mechanism (SC-7, R-5 unchanged in scope). | Validation finding 3 (disjunctive phrasing) | spec-creation validate pipeline (`.opencode#2456`) |
| 2026-09-21 | Decomposed compound SC-6: split into SC-6 (halt+notify on the halt-class trigger states — single-mechanism justification added: the three conditions are the three non-progressing outcomes of the SC-2 classification taxonomy sharing one halt+notify path) and SC-7 (recorded decision field with allowed value-set {continue-new-dispatch, terminate-with-root-cause}). Former SC-7→SC-8, SC-8→SC-9, SC-9→SC-10, SC-10→SC-11, SC-11→SC-12. Reworded SC-10 (false_signal annotation presence as the single assertion) and SC-11 (scenario passing via run as the single assertion, `--list` registration as enabling precondition) per single-assertion/single-deliverable justification. Items split/renumbered (Items 6-12), R-3/R-4 traceability split, cost frame and edge cases renumbered consistently. Restored analytical artifacts directory `.opencode/.issues/2456/artifacts/` from `tmp/issue-2456/artifacts/` (10 artifacts present there; copied all 10 — the finding's "12" count did not match the source directory contents, no artifacts were fabricated). Restored artifacts reflect the pre-split SC numbering (they predate this decomposition); they are the latest generated generation available and were not regenerated (no analysis steps in this task). | Validation findings 1 (compound SC-6), 2 (SC-10/SC-11 sub-flags), 3 (missing artifacts dir) | spec-creation validate pipeline (`.opencode#2456`) |
| 2026-09-24 | SC-26/R-25/Item 26 added (developer directive): a hung session is a CLEAR FAIL — no events/output growth across the bounded hang window (default 2 consecutive polls beyond first stall observation, no provider-error on record) ⇒ verdict FAILED(stall) + root-cause recorded + run/monitor terminated within one poll cycle + fresh-dispatch remediation; wait-on-hang ("letting it proceed") prohibited. Reason: live evidence — a supervisor observed a hung LLM stream (no streaming since 04:25), classified provider-side stall, then decided "Letting it proceed; continuing supervision polls". | Developer directive (2026-09-24, "sub-agent is fabricating reasons to wait on a hung provider … A hung session is useless and clear fail") | Developer (`.opencode#2456`) |
| 2026-09-23 | SC-25/R-24/Item 25 added (developer directive): agent process-cleanup patterns select kill targets by scenario-specific markers with the own session PID + parent PIDs excluded — an unrestricted grep/pkill of "opencode run"-matching patterns is prohibited (the supervising agent matches its own pattern). Reason: live evidence — the orchestrator self-killed with `ps aux | grep "opencode run" | xargs kill -9`, terminating its own session mid-pipeline and requiring crash recovery. | Developer directive (2026-09-23, "Add an SC to stack in this warning about accidental self un-aliving") | Developer (`.opencode#2456`) |
| 2026-09-23 | R-13 amended + SC-6 trigger granularity refined (orchestrator remediation under the SC-21 gate): a starved/no-parseable classification dispatch is a DISPATCH FAILURE event — attempt + failure mode recorded, retried per checkpoint policy; it is NOT a classification, does not trigger halt-class by itself, and does not count toward the undetermined-cycle ceiling; 3 consecutive dispatch failures = HARNESS_FAILURE halt naming the infrastructure surface. Reason: live evidence from the SC-10 RED attempt — the classifier starved at poll 4 (27B queue behind the run's first generation), the conflation routed the starved dispatch into SC-6 halt-class, and monitoring halted before the run agent completed its first tool call; under the conflated rule every cold-start starvation guarantees a halt, making monitored runs unusable when the model queue stalls. | Orchestrator remediation under SC-21 gate (developer-authorized flow) | Orchestrator (`.opencode#2456`, for_pr scope) |
| 2026-09-23 | SC-24/R-23/Item 24 added (developer directive): once a scenario's declared verdict surface is decided, the supervisor terminates run + monitor within one poll cycle and captures exit/artifact evidence — waiting for natural exit after a decided verdict is prohibited (exception: scenarios whose verdict surface requires continued running, e.g. continue-past-cap, terminate at the surface's own endpoint). Reason: live evidence of a supervisor emitting "RED CONFIRMED verdict emitted. Waiting for the scenario to fully exit" — burning tokens and time on a run whose evidentiary value was already spent. | Developer directive (2026-09-23, "The sub-agent is not terminating early after confirming scenario and instead is wasting tokens and time running scenarios to their end with no benefit … Stack in an SC to prevent this and continue") | Developer (`.opencode#2456`) |
| 2026-09-23 | SC-22/R-21/Item 22 + SC-23/R-22/Item 23 added (orchestrator remediation per the SC-21 gate, developer-authorized flow; R-numbers R-21/R-22 chosen to avoid collision with the pre-existing Default-Model Mandate R-20 reference): R-21 — abort suppression by a progressing classification is valid only within a bounded freshness window (re-classify at least every N polls and on new abort-signal events); R-22 — each monitored fixture run starts from a fresh test home and fresh session; home/session reuse prohibited. Reasons from the 2026-09-23 SC-5 post-regression gate halt: (1) the SC-5 carve-out suppressed signal-3/signal-2 aborts citing a poll-12 progressing verdict while the run derailed at poll 16+ — carried past 215 polls; (2) the run's DB contained a prior session's user turns (fix-2098 copy task, 2456-sc9/sc10 marker-verification prompts) injected by test-home reuse, causing the run agent to pivot mid-loop to foreign instructions. | Orchestrator remediation under SC-21 gate (developer-authorized flow) | Orchestrator (`.opencode#2456`, for_pr scope) |
| 2026-09-22 | SC-21 refined (developer directive): the hard gate routes to the ORCHESTRATOR — on defect-marker detection the sub-agent halts and notifies; the orchestrator researches and remediates (run defect vs. spec/plan defect), then dispatches a NEW sub-agent or resumes the existing one per the orchestrator's determination; sub-agent self-remediation/resumption prohibited. Amends the initial SC-21/R-18 wording (supervisor halts until diagnosis+remediation) to place research, remediation, and the resumption form explicitly at orchestrator level. | Developer directives (2026-09-22: "when the sub-agent detects an excessive deliberation defect it needs to have the orchestrator research and remediate before the orchestrator resumes the implementation"; "the orchestrator should dispatch a new sub-agent or resume the existing sub-agent as appropriate per the orchestrator's determination") | Developer (`.opencode#2456`) |
| 2026-09-22 | SC-21/R-18/Item 21 added (developer directive, gate remediation): a recorded defect marker (efficiency/deliberation or non-progressing classification with identified cause) SHALL be a HARD GATE — the supervisor halts further runs/dispatches until root cause is diagnosed (run defect vs. spec/plan defect) and either remediated or routed through terminate-with-root-cause. Reason: markers were being recorded and then ignored — the RED SC-5 attempt logged the reasoning-runaway and classifier-starvation findings as R-18 calibration notes, then bumped MAX_POLLS and re-ran on the same undiagnosed defect; recording without a gating consequence made every upstream marker decoration. | Developer directive (2026-09-22, "this implies an additional SC needs to be added to address the defect" — following "why is the sub-agent reporting a deliberation defect but ignoring it?") | Developer (`.opencode#2456`) |
| 2026-09-22 | SC-20/R-17/Item 20 added (developer directive): every 5-minute semantic check of a supervised run's SQLite session DB SHALL include an efficiency analysis — excessive deliberation (reasoning growth without tool-call progress, self-correction loops, over-exploration on a straightforward post-spec/post-plan task) is a defect marker recorded in poll evidence and routed to the defect notification path; raw model latency (slow local models) is NOT a defect marker — the marker keys on deliberation-to-progress ratio. Reason: poor efficiency is itself a defect signal needing address; live evidence: 2026-09-22 runs recorded 60k+ reasoning chars with zero new tool calls and a 44-poll over-deliberation loop. | Developer directive (2026-09-22, "Very poor efficiency is an additional marker of defects … after the spec is created and the plan is created [tasks] should NOT take excessive deliberation … This needs to be an additional analysis for each 5 minute semantic check point … especially true for slower local models") | Developer (`.opencode#2456`) |
| 2026-09-22 | SC-19/R-16/Item 19 added (developer directive, recurrence remediation): an agent setting up an `opencode run` for supervision SHALL launch it asynchronously with an attached supervision schedule of no more than 5 minutes between semantic checks of that run's SQLite session DB contents (message/reasoning/tool-call parts); blocking foreground waits or launches without a ≤5-min SQLite-DB semantic-poll schedule are prohibited. Reason: the defect recurred after SC-17/18 were added — the 2026-09-22 pre-regression dispatch was again set up as a foreground/blocking run with no attached ≤5-min monitoring — proving the defect is the launch FORM (not prompt wording or outcome assertion); the semantic check is specifically of the SQLite session DB contents per run, at ≤5-minute intervals. | Developer directive (2026-09-22, "the sub agent is again setting up the opencode run to not monitor it every five minutes with semantic analysis. create an additional SC … no more than five minutes between semantic checks of the contents of the sqlite db for each opencode run") | Developer (`.opencode#2456`) |
| 2026-09-22 | SC-17/SC-18 / R-14/R-15 / Items 17-18 added (developer directive, root-cause remediation): agents supervising an `opencode run` SHALL poll at ≤5-min intervals with a full semantic check per poll derived from message/reasoning/tool-call parts; run-retry loops without per-iteration semantic checks and single waits >300s are prohibited (SC-17/R-14); the mandate SHALL be mirrored into `.opencode/tests-v2/AGENTS.md` §14 so it is default deck behavior, independent of orchestrator prompt phrasing (SC-18/R-15). Root cause identified: the mandate existed only in orchestrator dispatch prompts — never in the task cards or AGENTS.md the sub-agents actually read — and no enforcement test governed the supervisor side, so agents defaulted to black-box waits and 1..4 run-retry loops with zero semantic checks (live evidence: the 2026-09-22 #2456 SC-4 RED dispatches — 45-min single-wait budgets, then 1..4 heartbeat run loops with 5-min sleeps and no checks). | Developer directive (2026-09-22, "identify the reason the sub-agent is not by default using the polling mandate. add an SC to address the cause and stack into this feature branch … the sub-agent is now looping the opencode run's in 1..4 loops with 5 minute waits with no semantic checks") | Developer (`.opencode#2456`) |
| 2026-09-22 | SC-2/R-2 amended + R-13 added (pipeline-initiated, FALSE_PREMISE abort remediation): the classification dispatch's direction anchor SHALL be a mechanically verifiable goal condition (scenario-declared goal artifact + content pattern) — never the run prompt prose. Reason: live evidence showed the hardwired whole-prompt anchor (helpers.sh goal_context) makes off-track unreachable — the classifier reads prescribed busy-work as "the task given" and classifies verifiably off-goal runs progressing-directionally; no fixture design can produce off-track under the prompt-prose anchor. R-13: starved/UNPARSED dispatches recorded as undetermined, never silently consuming the dispatch ceiling. | Pipeline-initiated (plan Self-Remediation Protocol; RED abort record tmp/2456/artifacts/pipeline-red-4-sc4-reevaluation.yaml.md) | Orchestrator (`.opencode#2456`, for_pr scope) |
| 2026-09-21 | SC-16 / R-12 / Item 16 added (developer directive): GREEN-phase dispatches for behavioral scenarios SHALL commit and push all test-needed changes to the feature branch mechanically (§4 ordered cycle) BEFORE the isolated test-home run — commit deliberation is prohibited; the isolated run pulls the effective commit from the remote branch. Reason: GREEN-phase sub-agents repeatedly deliberated endlessly about whether to commit before running the isolated test (2026-09-21 #2437 SC-2 GREEN dispatch cancelled mid-deliberation). | Developer directive (2026-09-21, "add an SC … sub-agents deliberate endlessly about whether to commit … the feature branch SHALL have all needed changes for the test committed and push[ed] so that the isolated test home run can pull it") | Developer (`.opencode#2456`) |
| 2026-09-21 | SC-13 revision + SC-14/SC-15 added (developer directive): the stall trigger is the SEMANTIC classification (off-track/undetermined), never an activity heuristic; every poll of a monitored run SHALL perform a full semantic check of progress so far derived from message parts, reasoning parts, and tool calls — activity/uptime/tool-call count is inadmissible as evidence of correct operation (SC-14/R-10); polls SHALL occur no less often than every 5 minutes (SC-15/R-11). Reason: sub-agents interpreted "zero progress" as an activity check, treating any activity as health and skipping semantic analysis; the check must answer "is it working correctly as expected", only determinable from content parts. | Developer directive (2026-09-21, "each poll check must be a full semantic check … the stall check is for semantic analysis of the opencode run … polling no less often than every 5 minutes") | Developer (`.opencode#2456`) |
| 2026-09-21 | Added SC-13 / R-9 / Item 13 (diagnosis-before-retry on stalled runs): a stall with zero progress evidence and an identifiable external cause must produce decision=terminate-with-root-cause naming the diagnosed cause; timer-escalation re-dispatch without diagnosis is prohibited and blocked by the SC-8 gate. Motivating evidence: 2026-09-21 #2437 RED behavioral run hung ~4 hours on orphaned `opencode run`/scenario processes while a provider quota error ("monthly spending limit for Inference Providers") sat in the dispatch failure output — root cause was diagnosable in seconds from `ps` + logs, but the response loop raised timers/re-dispatched instead. | Developer directive (2026-09-21, "add an SC to the spec to address this repeated defect … with NOT addressing issues identified during test runs") | Developer (`.opencode#2456`) |
| 2026-09-21 | Initial spec. | — | Developer (`.opencode#2456`) |

---

Co-authored with AI: OpenCode (zai-org/GLM-5.3-Flash)
