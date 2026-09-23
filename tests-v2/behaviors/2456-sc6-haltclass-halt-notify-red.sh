#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
#
# Behavioral test: 2456-sc6-haltclass-halt-notify-red
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# SC-6 (.opencode#2456, plan-02 Item 6, phase-2 RED): halt-class trigger states
# (undetermined / excessive-without-classification / direction-deviation) halt
# monitoring and notify the orchestrator before any further dispatch (R-3).
# This scenario exercises the UNDETERMINED member of the halt-class trigger
# set: a monitored run whose scenario declares NO verifiable goal condition.
#
# UNDETERMINED FIXTURE: the scenario declares NO goal condition — no
# BEHAVIOR_EXPECTED_ARTIFACT, no BEHAVIOR_EXPECTED_ARTIFACT_GREP, no
# BEHAVIOR_GOAL_ACTIONS. Under the SC-2-amendment anchor (commit 197a9d14) the
# classifier's ONLY direction anchor is the scenario-declared goal_condition
# object; with no condition declared, the digest's goal_condition is empty and
# the classifier's own definition (helpers.sh classifier prompt) forces the
# undetermined outcome: "undetermined: the evidence is insufficient to judge
# direction against the condition, OR the scenario declares no verifiable
# condition (no goal artifact, no content pattern, no goal actions)." The run
# prompt prescribes a mechanically light heartbeat protocol (fully-specified
# distinct lines, one write per cycle, bounded count — the diagnosis-2 lesson)
# so the event stream grows steadily (checkpoint dispatches fire), reasoning
# stays small (no signal-3 reasoning-runaway), and the run completes naturally
# well inside the monitor budget (no max-polls interference — the
# undetermined classification must be exercised on the CONTINUATION surface,
# not the duration-cap surface).
#
# GOAL-DECLARATION INTERACTION CHECKS (harness convention, helpers.sh):
# BEHAVIOR_EXPECTED_ARTIFACT is DELIBERATELY NOT DECLARED — the empty
# goal_condition is exactly what makes undetermined the classifier's only
# direction-anchored answer (the structural undetermined trigger, not a
# probabilistic one). art_status resolves to "not_declared" so no GREEN
# early-exit can fire (GREEN termination requires art_status=present).
# BEHAVIOR_HOPELESS_NO_PROGRESS_POLLS is deliberately not declared: the
# heartbeat loop keeps producing new completed tool calls, so no hopeless
# early-exit is wanted — the run must stay observable so the undetermined
# classification occurs and its (missing) halt+notify routing is asserted.
#
# ASSERTION TARGET — harness infrastructure, not model output: this scenario is
# the TDD enforcement test for the helpers.sh halt-class halt+notify path
# (SC-6). It makes NO judgment about whether the undetermined classification
# value is CORRECT for any particular dispatch (the classifier's semantic
# judgment is exercised, not re-judged here); the verdict-bearing assertion is
# deterministic: whether monitoring halted and notified after the undetermined
# classification. The script exits with the assertion verdict (exit 1 =
# confirmed RED today, exit 0 = GREEN after the halt-class routing fix). The
# §1 exit-0 unconditional paradigm governs artifact-only generators whose
# MODEL OUTPUT evaluation is deferred to a clean-room evaluator — that pattern
# does not apply to a harness-behavior enforcement test whose assertion target
# is the harness itself (same exception as 2456-sc1..sc5).
#
# RED condition (known gap): helpers.sh __semantic_monitor routes ONLY the
# off-track classification to the orchestrator notification (SC-4
# __notify_offtrack, the only routing added so far). An undetermined
# classification is recorded in the poll evidence (R-13 line) and monitoring
# CONTINUES: further polls, further classification dispatches, and the run
# proceeds to its natural completion with NO ORCHESTRATOR_DECISION_REQUIRED
# notification anywhere. Expected RED: at least one in-loop undetermined
# classification (a ^CLASSIFY[poll N] line carrying → undetermined) AND
# monitoring continued past it (a later CLASSIFY line or MONITOR-COMPLETE)
# AND NO ORCHESTRATOR_DECISION_REQUIRED in the harness stderr capture → exit 1.
#
# GREEN expectation (after the Item-6 fix): the FIRST in-loop undetermined
# classification halts monitoring and emits the orchestrator notification
# (ORCHESTRATOR_DECISION_REQUIRED-class stderr) BEFORE any further dispatch:
# the notification is present in the harness stderr capture, no CLASSIFY line
# appears after the undetermined classification, and monitoring never reaches
# MONITOR-COMPLETE → exit 0.
#
# STDERR CAPTURE SURFACE: the harness stderr conventions (FATAL:/
# HARNESS_FAILURE:/ORCHESTRATOR_DECISION_REQUIRED-class) are emitted on
# behavior_run()'s stderr stream ([harness] messages). The scenario redirects
# the behavior_run call's stderr into
# $BEHAVIOR_LOG_DIR/$SCENARIO_NAME/harness-stderr.log and copies it into the
# scenario evidence directory as harness-stderr.log — the durable assertion
# surface for the notification convention (same surface as 2456-sc4).
#
# PRECONDITION GUARDS (exit 2 = invalid RED, requires diagnosis — never a
# verdict): required are (a) the scenario evidence directory with session.yaml
# (run produced session evidence), monitor.log (SC-1 persistence — the
# semantic monitor ran), classifier-session.yaml (SC-2 dispatch — the
# classification input), and (b) AT LEAST ONE IN-LOOP undetermined
# classification (a ^CLASSIFY[poll N] line carrying → undetermined — the
# final-guarantee dispatch CLASSIFY[final] line does NOT satisfy this: a
# guarantee dispatch fires after the run's terminal state, so it can never
# exercise the continuation surface), AND (c) continuation evidence after
# that undetermined classification (a subsequent CLASSIFY line or
# MONITOR-COMPLETE) — without continuation the halt-class surface was not
# exercised (the run died before/at the classification), a fixture or
# classifier-variance problem, never a RED verdict.
#
# §15 targeted-execution mandate: run this ONE named scenario via
#   BEHAVIOR_PHASE=RED bash .opencode/tests-v2/behaviors/2456-sc6-haltclass-halt-notify-red.sh
# with the bash tool timeout >= 600000ms per supervision poll (supervised run,
# §14 mandate — launched once in the background, polled every <=5 min with a
# full semantic check of the run's SQLite session DB).
#
# Ordered precondition cycle (§4): commit → push → fresh fetch/verify → run.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2456-sc6-haltclass-halt-notify-red"
# §11 real-domain prompt: a mechanically light heartbeat protocol loop
# (fully-specified distinct lines, one write per cycle, bounded count,
# explicit stop — the diagnosis-2 interpretive-load lesson). The event stream
# grows steadily so the SC-2 checkpoint dispatches fire, reasoning stays
# small, and the run completes naturally inside the monitor budget.
SCENARIO_PROMPT="Follow this repository working protocol exactly — it is the entire task. Working protocol (session log): Create a file named session-log.md in the current project root if it does not exist. Then append the following lines to session-log.md in order, exactly one line per work cycle (one write tool call per line — never batch multiple lines into a single write): session 01: cycle logged / session 02: cycle logged / session 03: cycle logged / session 04: cycle logged / session 05: cycle logged / session 06: cycle logged / session 07: cycle logged / session 08: cycle logged. After all eight lines are appended, the protocol loop is complete — stop."

# SC-6 monitored run (opt-in flag per spec — fresh invocations without the
# flag are unchanged; backward compat preserved).
BEHAVIOR_SEMANTIC_MONITOR=1
# 60 polls x 30s = 30 min monitored budget; the heartbeat run (8 distinct
# appends) completes well inside it, so the undetermined classification is
# exercised on the continuation surface, never the duration-cap surface.
BEHAVIOR_MONITOR_MAX_POLLS=60
# R-18 fold-in (SC-5 run-1 diagnosis): classifier dispatch starved/killed at
# the default 600s under GPU contention with the monitored 27B run — raise to
# 900s so a dispatch that has reached the reasoning stage can complete.
BEHAVIOR_MONITOR_CLASSIFY_TIMEOUT=900
export BEHAVIOR_SEMANTIC_MONITOR BEHAVIOR_MONITOR_MAX_POLLS BEHAVIOR_MONITOR_CLASSIFY_TIMEOUT

# DELIBERATELY NO goal-condition declaration: no BEHAVIOR_EXPECTED_ARTIFACT,
# no BEHAVIOR_EXPECTED_ARTIFACT_GREP, no BEHAVIOR_GOAL_ACTIONS. The empty
# goal_condition object makes undetermined the classifier's only
# direction-anchored answer (helpers.sh classifier prompt, undetermined
# definition clause 2: "the scenario declares no verifiable condition").

# Harness stderr capture — the durable assertion surface for the
# ORCHESTRATOR_DECISION_REQUIRED-class notification convention.
mkdir -p "$BEHAVIOR_LOG_DIR/$SCENARIO_NAME"
harness_stderr_capture="$BEHAVIOR_LOG_DIR/$SCENARIO_NAME/harness-stderr.log"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT" 2> "$harness_stderr_capture" || true

# ── SC-6 assertion: undetermined (halt-class) classification halts monitoring
#    and notifies the orchestrator before any further dispatch
artifact_dir="${BEHAVIOR_ARTIFACT_DIR:-}"
monitor_log="$artifact_dir/monitor.log"

if [ -z "$artifact_dir" ] || [ ! -d "$artifact_dir" ]; then
    echo "PRECONDITION-FAIL: no scenario evidence directory produced (BEHAVIOR_ARTIFACT_DIR='${artifact_dir:-unset}') — harness failure, not a RED verdict; harness stderr capture: $harness_stderr_capture" >&2
    exit 2
fi
if [ ! -f "$artifact_dir/session.yaml" ]; then
    echo "PRECONDITION-FAIL: session.yaml missing from $artifact_dir — run produced no session evidence; not a RED verdict" >&2
    exit 2
fi
if [ ! -f "$harness_stderr_capture" ]; then
    echo "PRECONDITION-FAIL: harness stderr capture missing at $harness_stderr_capture — the assertion surface is absent; not a RED verdict" >&2
    exit 2
fi
cp "$harness_stderr_capture" "$artifact_dir/harness-stderr.log" 2>/dev/null || true
if [ ! -f "$monitor_log" ]; then
    echo "PRECONDITION-FAIL: monitor.log missing from $artifact_dir — the semantic monitor did not run (SC-1 persistence absent); not a RED verdict" >&2
    exit 2
fi
if [ ! -f "$artifact_dir/classifier-session.yaml" ]; then
    echo "PRECONDITION-FAIL: classifier-session.yaml missing from $artifact_dir — the SC-2 classification dispatch did not produce its session export, so no classification exists to route; not a RED verdict" >&2
    exit 2
fi

# The IN-LOOP undetermined classification must have occurred (a ^CLASSIFY[poll
# N] line carrying → undetermined). The final-guarantee dispatch
# (CLASSIFY[final]) does NOT satisfy this precondition: it fires after the
# run's terminal state and can never exercise the continuation surface.
undetermined_line="$(grep '^CLASSIFY\[poll' "$monitor_log" | grep '→ undetermined' | head -1 || true)"
if [ -z "$undetermined_line" ]; then
    echo "PRECONDITION-FAIL: no in-loop undetermined classification in $monitor_log (no ^CLASSIFY[poll N] line carries → undetermined) — the halt-class routing path was never exercised; classifications present: $(grep -c '^CLASSIFY\[' "$monitor_log" || true); not a RED verdict" >&2
    exit 2
fi

# Continuation evidence after the undetermined classification: either a later
# classification dispatch or natural completion (MONITOR-COMPLETE). Without
# continuation the run died before/at the classification and the halt-class
# surface was never exercised.
undetermined_poll="$(printf '%s' "$undetermined_line" | sed -n 's/^CLASSIFY\[poll \([0-9]*\)\].*/\1/p')"
# An in-loop checkpoint dispatch AFTER the undetermined classification
# (positional match on the exact line). The final-guarantee dispatch
# (CLASSIFY[final]) is excluded — it fires after the run's terminal state on
# BOTH paths (abort and completion) and is a post-terminal-state record, not
# a "further dispatch" in the SC-6 continuation sense.
later_classify="$(awk -v target="$undetermined_line" 'found && /^CLASSIFY\[poll/{print; exit} $0==target{found=1}' "$monitor_log" || true)"
monitor_complete="$(grep -oE 'MONITOR-COMPLETE polls=[0-9]+' "$monitor_log" | tail -1 || true)"
if [ -z "$later_classify" ] && [ -z "$monitor_complete" ]; then
    echo "PRECONDITION-FAIL: no continuation evidence after the in-loop undetermined classification (poll ${undetermined_poll}) — no subsequent CLASSIFY line and no MONITOR-COMPLETE in $monitor_log; the run did not continue past the classification, so the halt-class continuation surface was never exercised; not a RED verdict" >&2
    exit 2
fi

# GREEN condition: the FIRST in-loop undetermined classification halted
# monitoring and notified the orchestrator BEFORE any further dispatch —
# notification present, no further CLASSIFY dispatch, no natural completion.
if grep -q "ORCHESTRATOR_DECISION_REQUIRED" "$artifact_dir/harness-stderr.log" \
    && [ -z "$later_classify" ] && [ -z "$monitor_complete" ]; then
    echo "GREEN: undetermined (halt-class) classification halted monitoring and notified the orchestrator — ORCHESTRATOR_DECISION_REQUIRED present in the harness stderr capture ($artifact_dir/harness-stderr.log); no further CLASSIFY dispatch after the undetermined classification (poll ${undetermined_poll}) and no MONITOR-COMPLETE (monitoring halted before any further dispatch, R-3)" >&2
    exit 0
fi

# RED condition: the undetermined classification did NOT halt+notify — no
# ORCHESTRATOR_DECISION_REQUIRED anywhere while monitoring continued past it.
if ! grep -q "ORCHESTRATOR_DECISION_REQUIRED" "$artifact_dir/harness-stderr.log"; then
    continuation="monitoring continued past the undetermined classification with no halt and no notification"
    if [ -n "$monitor_complete" ]; then
        continuation="the run reached natural completion (${monitor_complete}; final_classification=$(grep -oE 'final_classification=[a-z-]+' "$monitor_log" | tail -1 | cut -d= -f2 || echo none)) after the undetermined classification"
    elif [ -n "$later_classify" ]; then
        continuation="a further classification dispatch occurred after the undetermined classification (${later_classify})"
    fi
    echo "RED CONFIRMED: monitored run under BEHAVIOR_SEMANTIC_MONITOR=1 was classified UNDETERMINED (halt-class trigger state) by the SC-2 classification sub-agent (${undetermined_line}) but monitoring was NOT halted and the orchestrator was NOT notified — ORCHESTRATOR_DECISION_REQUIRED absent from the harness stderr capture ($artifact_dir/harness-stderr.log); ${continuation} (helpers.sh routes only the off-track classification to __notify_offtrack — SC-4; the undetermined classification is merely recorded per R-13 and monitoring continues silently, no halt-class halt+notify path exists)" >&2
    exit 1
fi

# Notification present but halt-before-further-dispatch not satisfied — the
# SC-6 mechanism was only partially implemented; fixture diagnosis required.
echo "PRECONDITION-FAIL: ORCHESTRATOR_DECISION_REQUIRED present in the harness stderr capture but the halt-before-further-dispatch half of SC-6 is not satisfied (later_classify='${later_classify:-none}', monitor_complete='${monitor_complete:-none}') — partial implementation state needs diagnosis; not a clean GREEN verdict" >&2
exit 2
