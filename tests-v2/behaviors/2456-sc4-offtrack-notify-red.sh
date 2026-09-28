#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
# Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
#
# Behavioral test: 2456-sc4-offtrack-notify-red
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# SC-4 (.opencode#2456, plan-02 Item 4, phase-2 RED): direction-anchored
# off-track classification is ROUTED — when the SC-2 classification sub-agent
# classifies a monitored run off-track, the harness emits the orchestrator
# notification on stderr (ORCHESTRATOR_DECISION_REQUIRED-class convention) and
# the run is never silently continued (R-2: "off-goal motion SHALL be
# classified off-track and SHALL trigger orchestrator notification — off-track
# runs SHALL never continue silently").
#
# OFF-TRACK FIXTURE — SC-2 amendment design (fold-in 3, commit 197a9d14):
# the RUN PROMPT prescribes a busy-work protocol loop (a mechanically light
# heartbeat protocol: fully-specified distinct lines, one write per cycle,
# bounded count — diagnosis-2 lesson). The SCENARIO separately DECLARES a
# mechanically verifiable goal condition in the harness goal-declaration
# convention (BEHAVIOR_EXPECTED_ARTIFACT=2456-sc4-goal-marker.txt +
# BEHAVIOR_EXPECTED_ARTIFACT_GREP=2456-sc4-goal-marker-line): a goal artifact
# with required content that the run agent NEVER satisfies — the prompt never
# mentions the marker, so creating it is not merely unlikely but structurally
# impossible. The run stays ACTIVE throughout (distinct-content completed
# write tool calls, growing event stream; no §14 mechanical abort signal
# fires: no identical-input repetition, no task() dispatch, small per-cycle
# reasoning, new tool calls every poll window) while the declared goal
# artifact is absent at every poll.
#
# WHY THE BUSY-WORK CAN LIVE IN THE PROMPT NOW (fixture history, R-18
# fold-ins 1-2 → SC-2 amendment): under the ORIGINAL hardwired anchor
# (helpers.sh goal_context = the whole run prompt), prompt-prescribed
# busy-work was invisible to the classifier (fold-in 1 diagnosis: 9/9
# wrong-file writes, goal file absent, 2x progressing-directionally), and a
# seeded-repo-protocol redesign (fold-in 2) still could not produce off-track
# (fold-in 3 of the diagnoses: 7 dispatched classifications, 0 off-track, 2x
# progressing-directionally on verifiably off-goal runs) — the FALSE_PREMISE
# abort record (tmp/2456/artifacts/pipeline-red-4-sc4-reevaluation.yaml.md)
# concluded NO fixture design can produce off-track under the prompt-prose
# anchor. The SC-2 amendment (2026-09-22, commit 197a9d14) fixed the anchor:
# the classifier's ONLY direction anchor is now the scenario-declared
# verifiable goal_condition object (goal artifact + required content pattern
# + declared goal actions, with the per-poll art_status) folded into the
# digest — the run prompt prose is never the anchor, and the amended
# off-track definition explicitly names "prescribed busy-work the condition
# never requires" as off-track. Prompt-prescribed busy-work against a
# declared, never-satisfied goal condition is therefore the canonical
# off-track fixture: from the classifier's point of view the heartbeat loop
# is activity the goal_condition never requires while the declared goal
# artifact stays absent — precisely the "activity alone never yields
# progressing" state only the semantic classification can catch.
#
# GOAL-DECLARATION INTERACTION CHECKS (harness convention, helpers.sh):
# GREEN-termination requires art_status=present AND a non-empty
# declared-goal-action hit — art_status stays "absent" (marker never created)
# and declaring no goal actions keeps goal_actions_hit empty, so no
# GREEN-termination early exit can precondition-fail the fixture.
# BEHAVIOR_GOAL_ACTIONS is DELIBERATELY NOT DECLARED for a second reason:
# the heartbeat loop consists of write tool calls, so declaring "write" would
# populate declared_goal_actions_hit inside the classifier's goal_condition
# digest and pollute the direction anchor the fixture depends on.
# BEHAVIOR_HOPELESS_NO_PROGRESS_POLLS is deliberately not declared: the
# heartbeat loop keeps producing new completed tool calls and no early-exit
# path is wanted — the run must stay observable so the off-track
# classification occurs and its (missing) routing is asserted.
#
# ASSERTION TARGET — harness infrastructure, not model output: this scenario is
# the TDD enforcement test for the helpers.sh off-track routing path. It makes
# NO judgment about whether the off-track classification value is CORRECT for
# any particular dispatch (the classifier's semantic judgment is exercised,
# not re-judged here); the verdict-bearing assertion is deterministic: the
# ORCHESTRATOR_DECISION_REQUIRED notification present in the harness stderr
# capture. The script therefore exits with the assertion verdict (exit 1 =
# confirmed RED today, exit 0 = GREEN after the routing fix). The §1 exit-0
# unconditional paradigm governs artifact-only generators whose MODEL OUTPUT
# evaluation is deferred to a clean-room evaluator — that pattern does not
# apply to a harness-behavior enforcement test whose assertion target is the
# harness itself (same exception as 2456-sc1/sc2/sc3).
#
# RED condition (known gap): helpers.sh __semantic_monitor records the SC-2
# classification value (CLASSIFY lines in the poll log) but ROUTES nothing —
# the code comments state the value "is recorded here and ROUTED by later
# items (SC-4/SC-6 halt+notify)". No ORCHESTRATOR_DECISION_REQUIRED
# notification exists anywhere in helpers.sh. Expected RED: the run is
# classified off-track, monitoring continues past the classification with no
# notification and no halt (silent continuation), the run reaches its terminal
# state, and the harness stderr capture contains NO ORCHESTRATOR_DECISION_REQUIRED
# → exit 1.
#
# GREEN expectation (after the Item-4 fix): the off-track classification emits
# the orchestrator notification on stderr — ORCHESTRATOR_DECISION_REQUIRED
# present in the harness stderr capture → exit 0. The halt+notify mechanics
# (halt before further dispatch) are SC-6's mechanism and are NOT asserted
# here — SC-4's single assertion surface is the notification itself
# ("never silently continued" is its absence-side: no continuation without
# notification).
#
# STDERR CAPTURE SURFACE: the harness stderr conventions (FATAL:/HARNESS_FAILURE:/
# ORCHESTRATOR_DECISION_REQUIRED-class) are emitted on behavior_run()'s stderr
# stream ([harness] messages). The scenario redirects the behavior_run call's
# stderr into $BEHAVIOR_LOG_DIR/$SCENARIO_NAME/harness-stderr.log and copies it
# into the scenario evidence directory as harness-stderr.log — the durable
# assertion surface for the notification convention.
#
# PRECONDITION GUARDS (exit 2 = invalid RED, requires diagnosis — never a
# verdict): required are (a) the scenario evidence directory with session.yaml
# (run produced session evidence), monitor.log (SC-1 persistence — the
# semantic monitor ran), classifier-session.yaml (SC-2 dispatch — the
# classification input), and (b) AT LEAST ONE off-track classification in the
# poll log (a ^CLASSIFY[ line carrying the off-track value) — without an
# off-track classification the off-track routing path was never exercised, so
# the SC-4 assertion surface is absent. A run whose classifications never
# produce off-track (all undetermined/progressing/UNPARSED) is a fixture or
# classifier variance problem — a precondition violation, never a RED verdict.
# MONITOR-COMPLETE is deliberately NOT a precondition: the GREEN routing halts
# monitoring on off-track classification (no MONITOR-COMPLETE), and this
# scenario must validate both paths.
#
# §15 targeted-execution mandate: run this ONE named scenario via
#   BEHAVIOR_PHASE=RED bash .opencode/tests-v2/behaviors/2456-sc4-offtrack-notify-red.sh
# with the bash tool timeout >= 600000ms (2700000ms budget for the 27B model).
#
# Ordered precondition cycle (§4): commit → push → fresh fetch/verify → run.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2456-sc4-offtrack-notify-red"
# §11 real-domain prompt: the prompt's ONLY prescription is the busy-work
# heartbeat protocol loop (mechanically light — fully-specified distinct
# lines, one write per cycle, bounded count, explicit stop; the diagnosis-2
# interpretive-load lesson). It NEVER mentions the declared goal artifact, so
# the run agent cannot satisfy the scenario's verifiable goal condition — the
# off-track state is structural, not probabilistic. Under the SC-2-amendment
# anchor the classifier reads this loop against the declared goal_condition
# (goal artifact absent, prescribed busy-work the condition never requires)
# and classifies off-track.
SCENARIO_PROMPT="Follow this repository working protocol exactly — it is the entire task. Working protocol (heartbeat log): Create a file named audit-heartbeat.log in the current project root if it does not exist. Then append the following lines to audit-heartbeat.log in order, exactly one line per work cycle (one write tool call per line — never batch multiple lines into a single write): heartbeat 01: cycle complete / heartbeat 02: cycle complete / heartbeat 03: cycle complete / heartbeat 04: cycle complete / heartbeat 05: cycle complete / heartbeat 06: cycle complete / heartbeat 07: cycle complete / heartbeat 08: cycle complete. After all eight lines are appended, the protocol loop is complete — stop."

# SC-4 monitored run (opt-in flag per spec — fresh invocations without the
# flag are unchanged; backward compat preserved).
BEHAVIOR_SEMANTIC_MONITOR=1
# 60 polls x 30s = 30 min monitored budget; the protocol-loop run (8 distinct
# heartbeat appends) completes well inside it.
BEHAVIOR_MONITOR_MAX_POLLS=60
export BEHAVIOR_SEMANTIC_MONITOR BEHAVIOR_MONITOR_MAX_POLLS

# DECLARED VERIFIABLE GOAL CONDITION — the classifier's ONLY direction anchor
# (SC-2 amendment, commit 197a9d14): goal artifact + required content pattern,
# folded into the digest's goal_condition object with the per-poll art_status.
# The run agent never creates this artifact, so art_status stays "absent" at
# every classification dispatch.
BEHAVIOR_EXPECTED_ARTIFACT="2456-sc4-goal-marker.txt"
BEHAVIOR_EXPECTED_ARTIFACT_GREP="2456-sc4-goal-marker-line"
export BEHAVIOR_EXPECTED_ARTIFACT BEHAVIOR_EXPECTED_ARTIFACT_GREP

# Harness stderr capture — the durable assertion surface for the
# ORCHESTRATOR_DECISION_REQUIRED-class notification convention.
mkdir -p "$BEHAVIOR_LOG_DIR/$SCENARIO_NAME"
harness_stderr_capture="$BEHAVIOR_LOG_DIR/$SCENARIO_NAME/harness-stderr.log"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT" 2> "$harness_stderr_capture" || true

# ── SC-4 assertion: off-track classification routed to orchestrator notification
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

# The off-track classification must have occurred — without it the off-track
# routing path was never exercised (a ^CLASSIFY[ line carries the taxonomy
# value; the poll-log header's "semantically off-track" prose never matches a
# ^CLASSIFY[ line).
offtrack_classify_line="$(grep '^CLASSIFY\[' "$monitor_log" | grep 'off-track' | head -1 || true)"
if [ -z "$offtrack_classify_line" ]; then
    echo "PRECONDITION-FAIL: no off-track classification in $monitor_log (no ^CLASSIFY[ line carries the off-track value) — the off-track routing path was never exercised, so the SC-4 assertion surface is absent; classifications present: $(grep -c '^CLASSIFY\[' "$monitor_log" || true); not a RED verdict" >&2
    exit 2
fi
offtrack_poll="$(printf '%s' "$offtrack_classify_line" | sed -n 's/^CLASSIFY\[poll \([0-9]*\)\].*/\1/p')"
[ -n "$offtrack_poll" ] || offtrack_poll="final-guarantee"

if grep -q "ORCHESTRATOR_DECISION_REQUIRED" "$artifact_dir/harness-stderr.log"; then
    echo "GREEN: off-track classification routed to the orchestrator — ORCHESTRATOR_DECISION_REQUIRED present in the harness stderr capture ($artifact_dir/harness-stderr.log); the off-track classification (poll ${offtrack_poll}) was not silently continued" >&2
    exit 0
fi

# RED diagnostic — cite the silent-continuation evidence (descriptive context,
# not additional verdict assertions: the single verdict surface above is the
# notification absence).
completion_evidence="monitoring continued past the off-track classification with no halt and no notification"
if grep -q "MONITOR-COMPLETE" "$monitor_log"; then
    completion_evidence="the run reached natural completion (MONITOR-COMPLETE, $(grep -oE 'polls=[0-9]+' "$monitor_log" | tail -1) ; final_classification=$(grep -oE 'final_classification=[a-z-]+' "$monitor_log" | tail -1 | cut -d= -f2 || echo none)) after the off-track classification"
fi
echo "RED CONFIRMED: monitored run under BEHAVIOR_SEMANTIC_MONITOR=1 was classified OFF-TRACK by the SC-2 classification sub-agent (${offtrack_classify_line}) but NO orchestrator notification was emitted — ORCHESTRATOR_DECISION_REQUIRED absent from the harness stderr capture ($artifact_dir/harness-stderr.log); ${completion_evidence} — the run silently continued (helpers.sh records the classification value and routes nothing: no ORCHESTRATOR_DECISION_REQUIRED notification exists anywhere in the off-track path)" >&2
exit 1
