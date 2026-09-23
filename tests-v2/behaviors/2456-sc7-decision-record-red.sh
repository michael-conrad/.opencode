#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral test: 2456-sc7-decision-record-red
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# SC-7 (.opencode#2456, plan-02 Item 7, phase-2 RED): the determination record
# carries a recorded orchestrator DECISION field with allowed value-set
# {continue-new-dispatch, terminate-with-root-cause} (root-cause present when
# terminate-with-root-cause) written after an orchestrator decision point —
# the halt-class notification path (SC-6) is the exercise surface.
#
# EXERCISE SURFACE — the already-GREEN SC-6 halt-class path: the scenario
# declares NO verifiable goal condition (the 2456-sc6 undetermined fixture
# shape) so the classifier returns undetermined, the halt+notify routing
# (commit 6cfee190) emits ORCHESTRATOR_DECISION_REQUIRED on stderr and
# MONITOR-HALTED in the poll log, and the run completes naturally so the
# post-run block writes the durable determination.yaml (SC-3). The assertion
# target is the determination record's orchestrator-decision content AFTER
# that halt-class notification.
#
# RED condition (known gap): helpers.sh __write_determination_record writes
# `orchestrator_decisions: []` — the decision-record WRITE PATH (an
# orchestrator decision recorded after the halt-class notification) is not
# implemented (plan-02 Item 7 commit lane). Expected RED: the halt-class
# path is fully exercised (MONITOR-HALTED + ORCHESTRATOR_DECISION_REQUIRED
# present) yet the determination.yaml carries NO orchestrator decision
# entry → exit 1.
#
# GREEN expectation (after the Item-7 fix): the determination record's
# orchestrator_decisions list carries at least one entry whose decision
# field is in the allowed value-set {continue-new-dispatch,
# terminate-with-root-cause}, with a root-cause present when the value is
# terminate-with-root-cause → exit 0.
#
# ASSERTION TARGET — harness infrastructure, not model output: this scenario
# is the TDD enforcement test for the SC-7 decision-record write path. It
# makes NO judgment about whether the classification value is CORRECT for
# any particular dispatch (the classifier's semantic judgment is exercised,
# not re-judged here); the verdict-bearing assertion is deterministic: the
# decision field in the determination record after the halt-class
# notification path. The script exits with the assertion verdict (exit 1 =
# confirmed RED today, exit 0 = GREEN after the write-path fix). The §1
# exit-0 unconditional paradigm does NOT apply to a harness-behavior
# enforcement test whose assertion target is the harness itself (same
# exception as 2456-sc1..sc6).
#
# PRECONDITION GUARDS (exit 2 = invalid RED, requires diagnosis — never a
# verdict): required are (a) the scenario evidence directory with
# session.yaml, monitor.log, classifier-session.yaml, and determination.yaml
# (SC-3 record writing flows through every monitored run), and (b) the
# halt-class notification path exercised: a MONITor-HALTED line in the poll
# log AND ORCHESTRATOR_DECISION_REQUIRED in the harness stderr capture —
# without them the orchestrator decision point was never reached, so the
# SC-7 assertion surface is absent (not a RED verdict).
#
# §15 targeted-execution mandate: run this ONE named scenario via
#   BEHAVIOR_PHASE=RED bash .opencode/tests-v2/behaviors/2456-sc7-decision-record-red.sh
# with the bash tool timeout >= 600000ms per supervision poll (supervised
# run, §14 mandate — launched once detached/setsid, polled every <=5 min
# with a full semantic check of the run's SQLite session DB).
#
# Ordered precondition cycle (§4): commit → push → fresh fetch/verify → run.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2456-sc7-decision-record-red"
# §11 real-domain prompt: a mechanically light heartbeat protocol loop
# (fully-specified distinct lines, one write per cycle, bounded count,
# explicit stop — the diagnosis-2 interpretive-load lesson). The event
# stream grows steadily so the SC-2 checkpoint dispatches fire, reasoning
# stays small, and the run completes naturally inside the monitor budget so
# the post-run block writes the determination record.
SCENARIO_PROMPT="Follow this repository working protocol exactly — it is the entire task. Working protocol (run log): Create a file named run-log.md in the current project root if it does not exist. Then append the following lines to run-log.md in order, exactly one line per work cycle (one write tool call per line — never batch multiple lines into a single write): run 01: cycle logged / run 02: cycle logged / run 03: cycle logged / run 04: cycle logged / run 05: cycle logged / run 06: cycle logged / run 07: cycle logged / run 08: cycle logged. After all eight lines are appended, the protocol loop is complete — stop."

# SC-7 monitored run (opt-in flags per spec — fresh invocations without the
# flags are unchanged; backward compat preserved). Same shape as the
# already-GREEN 2456-sc6 undetermined fixture.
BEHAVIOR_SEMANTIC_MONITOR=1
BEHAVIOR_MONITOR_MAX_POLLS=60
BEHAVIOR_MONITOR_CLASSIFY_TIMEOUT=900
export BEHAVIOR_SEMANTIC_MONITOR BEHAVIOR_MONITOR_MAX_POLLS BEHAVIOR_MONITOR_CLASSIFY_TIMEOUT

# DELIBERATELY NO goal-condition declaration: no BEHAVIOR_EXPECTED_ARTIFACT,
# no BEHAVIOR_EXPECTED_ARTIFACT_GREP, no BEHAVIOR_GOAL_ACTIONS. The empty
# goal_condition makes undetermined the classifier's only direction-anchored
# answer (helpers.sh classifier prompt, undetermined definition clause 2) —
# the halt-class exercise surface.

# Harness stderr capture — the durable precondition surface for the halt-class
# notification convention.
mkdir -p "$BEHAVIOR_LOG_DIR/$SCENARIO_NAME"
harness_stderr_capture="$BEHAVIOR_LOG_DIR/$SCENARIO_NAME/harness-stderr.log"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT" 2> "$harness_stderr_capture" || true

# ── SC-7 assertion: determination record carries a recorded orchestrator
#    decision field (allowed value-set) after the halt-class decision point
artifact_dir="${BEHAVIOR_ARTIFACT_DIR:-}"
monitor_log="$artifact_dir/monitor.log"

if [ -z "$artifact_dir" ] || [ ! -d "$artifact_dir" ]; then
    echo "PRECONDITION-FAIL: no scenario evidence directory produced (BEHAVIOR_ARTIFACT_DIR='${artifact_dir:-unset}') — harness failure, not a RED verdict; harness stderr capture: $harness_stderr_capture" >&2
    exit 2
fi
for required in session.yaml classifier-session.yaml; do
    if [ ! -f "$artifact_dir/$required" ]; then
        echo "PRECONDITION-FAIL: $required missing from $artifact_dir — run produced incomplete evidence; not a RED verdict" >&2
        exit 2
    fi
done
if [ ! -f "$harness_stderr_capture" ]; then
    echo "PRECONDITION-FAIL: harness stderr capture missing at $harness_stderr_capture — the precondition surface is absent; not a RED verdict" >&2
    exit 2
fi
cp "$harness_stderr_capture" "$artifact_dir/harness-stderr.log" 2>/dev/null || true
if [ ! -f "$monitor_log" ]; then
    echo "PRECONDITION-FAIL: monitor.log missing from $artifact_dir — the semantic monitor did not run (SC-1 persistence absent); not a RED verdict" >&2
    exit 2
fi
if [ ! -f "$artifact_dir/determination.yaml" ]; then
    echo "PRECONDITION-FAIL: determination.yaml missing from $artifact_dir — the SC-3 determination record was not written for this monitored run; harness gap, not a RED verdict" >&2
    exit 2
fi

# Precondition (b): the halt-class notification path was exercised — the
# orchestrator decision point actually occurred.
halt_class="$(grep -oE 'MONITOR-HALTED polls=[0-9]+ halt_class=[a-z-]+' "$monitor_log" | tail -1 || true)"
if [ -z "$halt_class" ]; then
    echo "PRECONDITION-FAIL: no MONITOR-HALTED line in $monitor_log — monitoring was never halted on a halt-class classification, so the orchestrator decision point (the SC-7 assertion surface) was never reached; classifications present: $(grep -c '^CLASSIFY\[' "$monitor_log" || true); not a RED verdict" >&2
    exit 2
fi
if ! grep -q "ORCHESTRATOR_DECISION_REQUIRED" "$artifact_dir/harness-stderr.log"; then
    echo "PRECONDITION-FAIL: ORCHESTRATOR_DECISION_REQUIRED absent from the harness stderr capture ($artifact_dir/harness-stderr.log) despite halt_class='${halt_class}' — the SC-6 halt+notify routing did not fire, so the orchestrator decision point was never reached; not a RED verdict" >&2
    exit 2
fi

# ── Verdict: the determination record must carry a recorded orchestrator
#    decision — at least one entry in the orchestrator_decisions section
#    whose decision field carries an allowed value
#    {continue-new-dispatch, terminate-with-root-cause}, with a root-cause
#    present when the value is terminate-with-root-cause (SC-7 value-set).
decision_section="$(sed -n '/^[[:space:]]*orchestrator_decisions:/,$p' "$artifact_dir/determination.yaml")"
decision_line="$(printf '%s' "$decision_section" | grep -oE 'continue-new-dispatch|terminate-with-root-cause' | head -1 || true)"
if [ -n "$decision_line" ]; then
    # A decision entry exists. Allowed value-set check (parse-anything-else =
    # out-of-value-set defect, never GREEN).
    if [ "$decision_line" != "continue-new-dispatch" ] && [ "$decision_line" != "terminate-with-root-cause" ]; then
        echo "PRECONDITION-FAIL: determination record carries a decision value outside the allowed value-set ('${decision_line}') — record-schema defect needs diagnosis; not a RED verdict" >&2
        exit 2
    fi
    # terminate-with-root-cause requires a root-cause in the record.
    if [ "$decision_line" = "terminate-with-root-cause" ] \
        && ! grep -qiE 'root[-_]cause' "$artifact_dir/determination.yaml"; then
        echo "PRECONDITION-FAIL: decision='terminate-with-root-cause' in $artifact_dir/determination.yaml but no root-cause field/content present — record-schema defect needs diagnosis; not a RED verdict" >&2
        exit 2
    fi
    GREEN_OK=1
else
    GREEN_OK=0
fi

PHASE="${BEHAVIOR_PHASE:-RED}"

if [ "$PHASE" = "GREEN" ]; then
    if [ "$GREEN_OK" = "1" ]; then
        echo "GREEN: the determination record carries a recorded orchestrator decision after the halt-class notification path (${halt_class}; ORCHESTRATOR_DECISION_REQUIRED present in the harness stderr capture) — decision='${decision_line}' with the allowed value-set satisfied in $artifact_dir/determination.yaml" >&2
        exit 0
    fi
    echo "GREEN NOT SATISFIED (RED confirmed in GREEN phase): the halt-class orchestrator decision point was exercised (${halt_class}; ORCHESTRATOR_DECISION_REQUIRED present) but $artifact_dir/determination.yaml carries NO orchestrator decision entry with an allowed value — the decision-record write path is not implemented or the record was left empty" >&2
    exit 1
fi

# RED phase: the decision point was reached (halt-class notification fired)
# and the record must now carry the orchestrator's decision. If a valid
# decision entry already exists, RED cannot be validly produced.
if [ "$GREEN_OK" = "1" ]; then
    echo "RED ABORT — ALREADY_GREEN: the determination record already carries a recorded orchestrator decision ('${decision_line}') after the halt-class notification path — the expected-failing behavior is already implemented, so a failing RED test cannot be validly produced" >&2
    exit 3
fi

echo "RED CONFIRMED: the orchestrator decision point was reached and passed — halt-class classification halted monitoring (${halt_class}) and ORCHESTRATOR_DECISION_REQUIRED was emitted on the harness stderr capture ($artifact_dir/harness-stderr.log) — but the determination record ($artifact_dir/determination.yaml) carries NO orchestrator decision entry in its orchestrator_decisions section: no decision field with an allowed value from {continue-new-dispatch, terminate-with-root-cause} was recorded after the halt-class notification (known gap: helpers.sh __write_determination_record emits orchestrator_decisions: [] and no SC-7 decision-record write path exists; .opencode#2456 spec line 'The recorded decision field carries exactly one allowed value ... in the determination record')" >&2
exit 1
