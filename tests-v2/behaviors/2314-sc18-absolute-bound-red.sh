#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
#
# Behavioral test: 2314-sc18-absolute-bound-red
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# SC-18 (.opencode#2314, plan-05 Item SC-18, step 90 RED): the §14 monitor
# enforces an ABSOLUTE termination bound — a hard max-polls ceiling that
# terminates a run past the budget with a `terminate-with-root-cause` terminal
# classification REGARDLESS of the run's latest classification. Suppression
# rules cannot defeat the bound: the bound composes AFTER suppression.
#
# RED TARGET — harness infrastructure, not model output: this scenario is the
# TDD enforcement test for the helpers.sh __semantic_monitor max-polls
# termination path. Its assertion target is the harness itself (same exception
# class as 2456-sc1..sc5 — the §1 exit-0 artifact-only paradigm does not apply
# to a harness-behavior enforcement test). Exit 1 = confirmed RED today,
# exit 0 = GREEN after the absolute-bound fix, exit 2 = precondition failure
# (fixture/timing problem — never a verdict).
#
# DEFECT REPRODUCED AT REDUCED SCALE (the attempt-5 regression, .opencode#2314
# root cause 6 — monitor log tmp/behavior-test-20261002-062454/2314-sc2-plan-
# absent-dispatch-red/monitor-attempt1.log, 603+ polls over ~5 hours): a
# supervised run classified progressing-directionally past the max-polls
# budget keeps polling and completes WITHOUT a terminal classification. The
# current carve-out (helpers.sh, .opencode#2456 SC-5 progressing-continues)
# makes the max-polls termination path apply ONLY to non-progressing states:
#   POLL N: max-polls budget exceeded but run classified progressing-
#           directionally ... continuing to poll
# — no absolute ceiling exists. There is no documented absolute-bound env knob
# today (BEHAVIOR_MONITOR_MAX_POLLS is the SOFT budget the carve-out defeats).
#
# REDUCED-SCALE FIXTURE (stub-driven, no model inference — minutes→seconds):
# the monitor loop __semantic_monitor is driven DIRECTLY with:
#   - a STUB supervised run: a short-lived background process that emits a
#     steady stream of distinct goal-directed completed tool-call events into
#     a stub session DB (event growth each poll) and exits naturally after a
#     few seconds — the exact event-stream shape a progressing-directionally
#     run exhibits;
#   - a STUB classifier: __classify_run_state is overridden AFTER sourcing
#     helpers.sh to deterministically emit "progressing-directionally|ok" and
#     persist the classifier-session export — the classification dispatch is
#     exercised through the real checkpoint policy and __interpret_classify_
#     dispatch pure function; only the model inference behind the dispatch is
#     stubbed (reduced-scale mandate; the classification VALUE is the
#     scenario's given, not the test's subject);
#   - a TINY budget: BEHAVIOR_MONITOR_MAX_POLLS=3 with BEHAVIOR_MONITOR_
#     INTERVAL=1 — the stub run outlives the budget (reproduces attempt-5 at
#     reduced scale) while classified progressing.
#
# ASSERTION (SC-18): once the budget is exceeded, the monitor MUST terminate
# the run with a terminate-with-root-cause terminal classification recorded in
# the monitor artifacts (monitor.log budget-exceeded termination record
# naming terminate-with-root-cause), regardless of the progressing verdict.
# TODAY the monitor instead logs the continuation line and runs to natural
# completion (MONITOR-COMPLETE with polls > budget, final_classification=
# progressing-directionally, NO terminate-with-root-cause anywhere) → the
# absolute-bound assertion FAILS → exit 1 (RED).
#
# PRECONDITION GUARDS (exit 2 = invalid RED, requires diagnosis): monitor.log
# exists; at least one ^CLASSIFY[ line carries progressing-directionally (the
# fixture produced a progressing run); the budget surface was EXERCISED
# (either the continuation line appears — RED — or a budget-exceeded
# termination record appears — GREEN). A monitor.log that never crossed the
# budget never exercised the SC-18 surface.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2314-sc18-absolute-bound-red"
BEHAVIOR_LOG_DIR="$PARENT_REPO_DIR/tmp/behavior-test-2314-sc18-red-$(date +%Y%m%d-%H%M%S)"
export BEHAVIOR_LOG_DIR
mkdir -p "$BEHAVIOR_LOG_DIR/$SCENARIO_NAME"

# ── Tiny budget + fast cadence (reduced scale: the whole probe is seconds)
BEHAVIOR_SEMANTIC_MONITOR=1
BEHAVIOR_MONITOR_MAX_POLLS=3
BEHAVIOR_MONITOR_INTERVAL=1
BEHAVIOR_MONITOR_CLASSIFY_GRACE_POLLS=1
BEHAVIOR_MONITOR_CLASSIFY_MIN_POLLS=1
BEHAVIOR_MONITOR_CLASSIFY_MAX=10
BEHAVIOR_MONITOR_CLASSIFY_TIMEOUT=30
export BEHAVIOR_SEMANTIC_MONITOR BEHAVIOR_MONITOR_MAX_POLLS BEHAVIOR_MONITOR_INTERVAL \
    BEHAVIOR_MONITOR_CLASSIFY_GRACE_POLLS BEHAVIOR_MONITOR_CLASSIFY_MIN_POLLS \
    BEHAVIOR_MONITOR_CLASSIFY_MAX BEHAVIOR_MONITOR_CLASSIFY_TIMEOUT

# No declared goal artifact: art_status stays not_declared so the GREEN
# early-exit (artifact present + goal actions hit) cannot fire before the
# budget surface — the stub run is designed to outlive the budget, the exact
# state a progressing-directionally run past the budget exhibits.
BEHAVIOR_EXPECTED_ARTIFACT=""
BEHAVIOR_GOAL_ACTIONS=""
export BEHAVIOR_EXPECTED_ARTIFACT BEHAVIOR_GOAL_ACTIONS

# ── Stub session DB: a test-home DB whose event table grows each second —
# the stub run's "progressing" event stream (distinct completed tool calls).
STUB_HOME="$PARENT_REPO_DIR/tmp/test-home-stub-sc18"
mkdir -p "$STUB_HOME/.local/share/opencode"
STUB_DB="$STUB_HOME/.local/share/opencode/opencode.db"
rm -f "$STUB_DB"
python3 - "$STUB_DB" <<'PYEOF'
import sqlite3, sys
conn = sqlite3.connect(sys.argv[1])
conn.execute("CREATE TABLE event (seq INTEGER PRIMARY KEY, data TEXT)")
conn.commit()
conn.close()
PYEOF

# Stub supervised run: appends one distinct completed tool-call event per
# second (event growth + distinct inputs — progressing, never identical-input
# looping), exits naturally after 9s so the run outlives the 3-poll budget and
# completes without monitor termination (the attempt-5 shape).
(
    seq=0
    while [ "$seq" -lt 9 ]; do
        seq=$((seq + 1))
        python3 - "$STUB_DB" "$seq" <<'PYEOF'
import json, sqlite3, sys
db, n = sys.argv[1], int(sys.argv[2])
conn = sqlite3.connect(db)
conn.execute("INSERT INTO event (seq, data) VALUES (?, ?)", (
    n, json.dumps({"part": {"id": f"stub-{n}", "type": "tool", "tool": "write",
                            "state": {"status": "completed",
                                      "input": {"path": f"f{n}.txt", "content": f"line-{n}"}}}}),
))
conn.commit()
conn.close()
PYEOF
        sleep 1
    done
) &
stub_pid=$!

# Monitor's run-log pair (stderr carries the TEST_HOME marker the monitor
# greps for; stdout is the run's prose capture).
run_out="$BEHAVIOR_LOG_DIR/$SCENARIO_NAME/stdout.log"
run_err="$BEHAVIOR_LOG_DIR/$SCENARIO_NAME/stderr.log"
echo "TEST_HOME=$STUB_HOME" > "$run_err"

# ── Stub classifier: deterministic progressing-directionally verdict. The
# classification VALUE is this scenario's given (the SC-18 surface is what the
# monitor DOES with a progressing verdict past the budget, not whether the
# verdict is correct). Persisted classifier-session export mirrors the real
# dispatch's artifact contract.
__classify_run_state() {
    local db="$1"; local art_status="$2"; local model="$3"
    local scenario_name="$4"; local attempt="$5"; local poll="$6"
    printf 'progressing-directionally|ok\n'
    printf 'classification: progressing-directionally\nfailure_mode: ok\n' \
        > "$BEHAVIOR_LOG_DIR/$scenario_name/classifier-session-attempt${attempt}.yaml"
}

# Drive the monitor loop directly (reduced-scale stub supervision — no model
# inference; the §14 monitoring protocol is exercised by the loop itself).
__semantic_monitor "$stub_pid" "$SCENARIO_NAME" 1 "$run_out" "$run_err" "stub" || true

# ── SC-18 assertion: absolute termination bound past the budget
poll_log="$BEHAVIOR_LOG_DIR/$SCENARIO_NAME/monitor-attempt1.log"

if [ ! -f "$poll_log" ]; then
    echo "PRECONDITION-FAIL: monitor.log missing at $poll_log — the semantic monitor did not run; not a RED verdict" >&2
    exit 2
fi

progressing_classify_line="$(grep '^CLASSIFY\[' "$poll_log" | grep 'progressing-directionally' | head -1 || true)"
if [ -z "$progressing_classify_line" ]; then
    echo "PRECONDITION-FAIL: no progressing-directionally classification in $poll_log (no ^CLASSIFY[ line carries the value) — the stub fixture did not produce a progressing run, so the SC-18 absolute-bound surface is absent; classifications present: $(grep -c '^CLASSIFY\[' "$poll_log" || true)" >&2
    exit 2
fi

complete_line="$(grep 'MONITOR-COMPLETE' "$poll_log" | head -1 || true)"
if [ -z "$complete_line" ]; then
    echo "PRECONDITION-FAIL: no MONITOR-COMPLETE record in $poll_log — the stub run never reached a terminal monitor state (polls executed: $(grep -c '^POLL ' "$poll_log" || true)); fixture/timing problem, not a verdict" >&2
    exit 2
fi

budget_line="$(grep -E 'budget (exceeded|exhausted)' "$poll_log" | head -1 || true)"
if [ -z "$budget_line" ]; then
    echo "PRECONDITION-FAIL: the max-polls budget surface was never exercised — no budget exceeded/exhausted record in $poll_log (budget=${BEHAVIOR_MONITOR_MAX_POLLS}); fixture/timing problem, not a verdict" >&2
    exit 2
fi

# GREEN condition (SC-18 implemented): the monitor terminated the run at the
# budget with a terminate-with-root-cause terminal classification recorded in
# the monitor artifacts — a budget-exceeded termination record naming
# terminate-with-root-cause, with NO progressing-continuation past the budget.
if grep -q 'terminate-with-root-cause' "$poll_log" \
    && ! grep -q 'budget exceeded but run classified progressing-directionally' "$poll_log"; then
    echo "GREEN: the monitor enforced an ABSOLUTE termination bound — budget-exceeded termination record with terminate-with-root-cause present in $poll_log and no progressing-continuation past the budget; the suppression carve-out could not defeat the bound" >&2
    exit 0
fi

# RED condition (today): the monitor kept polling past the budget while
# classified progressing-directionally and the run completed WITHOUT a
# terminal classification — the attempt-5 regression reproduced at reduced
# scale (MONITOR-COMPLETE with polls > budget, no terminate-with-root-cause).
polls_complete="$(printf '%s' "$complete_line" | sed -n 's/.*polls=\([0-9]*\).*/\1/p')"
if grep -q 'budget exceeded but run classified progressing-directionally' "$poll_log" \
    && [ -n "$polls_complete" ] && [ "$polls_complete" -gt "$BEHAVIOR_MONITOR_MAX_POLLS" ] \
    && ! grep -q 'terminate-with-root-cause' "$poll_log"; then
    echo "RED CONFIRMED: the supervised run was classified PROGRESSING-DIRECTIONALLY (${progressing_classify_line}) and the monitor KEPT POLLING past the max-polls budget (${BEHAVIOR_MONITOR_MAX_POLLS}) — '${budget_line}' — and the run completed WITHOUT a terminal classification: MONITOR-COMPLETE polls=${polls_complete} > budget with NO terminate-with-root-cause record anywhere in $poll_log (helpers.sh __semantic_monitor max-polls check is subordinate to the progressing-continuation carve-out; no absolute termination bound exists — the .opencode#2314 attempt-5 unbounded-polling regression reproduced at reduced scale)" >&2
    exit 1
fi

echo "PRECONDITION-FAIL: SC-18 surface inconclusive — budget exercised but neither the RED continuation shape (MONITOR-COMPLETE polls='${polls_complete:-none}', budget line '${budget_line}') nor the GREEN termination shape observed; fixture/timing diagnosis required, not a verdict" >&2
exit 2
