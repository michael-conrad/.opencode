#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Co-authored with AI: OpenCode (huggingface/deepseek-ai/DeepSeek-V4-Flash-0731)
#
# Behavioral test: 2456-sc5-progressing-continues-red
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# SC-5 (.opencode#2456, plan-02 Item 5, phase-2 RED): progressing runs continue
# polling regardless of duration (R-2: "Progressing runs SHALL continue polling
# regardless of duration"). The monitor MUST NOT halt a run that is classified
# progressing-directionally at the duration cap (BEHAVIOR_MONITOR_MAX_POLLS).
#
# ASSERTION TARGET — harness infrastructure, not model output: this scenario is
# the TDD enforcement test for the helpers.sh polling-continuation path. It
# makes NO judgment about whether any classification value is CORRECT (the
# classifier's semantic judgment is exercised, not re-judged); the
# verdict-bearing assertion is deterministic: whether the monitor halted a
# progressing-directionally run at the max-polls duration cap. The script
# therefore exits with the assertion verdict (exit 1 = confirmed RED today,
# exit 0 = GREEN after the polling-continuation fix). The §1 exit-0
# unconditional paradigm governs artifact-only generators whose MODEL OUTPUT
# evaluation is deferred to a clean-room evaluator — that pattern does not
# apply to a harness-behavior enforcement test whose assertion target is the
# harness itself (same exception as 2456-sc1/sc2/sc3/sc4).
#
# PROGRESSING-CONTINUES FIXTURE (SC-5): a monitored run that keeps progressing
# toward its declared verifiable goal condition over many polls and RUNS
# LONGER than the monitor's duration cap. The run prompt prescribes building a
# documentation artifact INCREMENTALLY — one write tool call per section across
# 16 sections — so the run produces a steady stream of distinct, goal-directed
# completed tool calls (progressing-directionally under the SC-2-amendment
# direction anchor) and outlives the cap. The scenario DECLARES a mechanically
# verifiable goal condition in the harness goal-declaration convention
# (BEHAVIOR_EXPECTED_ARTIFACT=2456-sc5-goal-marker.txt +
# BEHAVIOR_EXPECTED_ARTIFACT_GREP=2456-sc5-goal-marker-line): the goal artifact
# with required content the run agent is actively producing toward — the exact
# state a progressing-directionally run exhibits.
#
# GOAL-DECLARATION INTERACTION CHECKS (harness convention, helpers.sh):
# BEHAVIOR_GOAL_ACTIONS is DELIBERATELY NOT DECLARED: (a) declaring "write"
# would populate declared_goal_actions_hit inside the classifier's
# goal_condition digest and pollute the direction anchor the fixture depends
# on (same reasoning as 2456-sc4); (b) GREEN-termination requires art_status=
# present AND a non-empty declared-goal-action hit — leaving goal_actions
# empty keeps goal_actions_hit empty so the GREEN early-exit cannot fire
# before the cap and precondition-fail the duration-cap surface. The run is
# designed to outlive the cap, so art_status stays absent/partial at the
# abort poll. BEHAVIOR_HOPELESS_NO_PROGRESS_POLLS is deliberately not
# declared: the run keeps producing new completed tool calls, so no hopeless
# early-exit is wanted.
#
# DURATION-CAP SETUP: BEHAVIOR_MONITOR_MAX_POLLS is set small (8 polls x 30s =
# 240s nominal cap + classification-dispatch time) so the run reliably
# OUTLIVES the cap. The SC-2 classification checkpoint policy fires a dispatch
# when event_count grew and polls_since_classify >= BEHAVIOR_MONITOR_CLASSIFY_MIN_POLLS
# (default 3) — with max_polls=8 the checkpoint dispatches land at polls 4 and
# 7 (2 chances to record a progressing-directionally classification) before
# the abort at poll 9. A 16-section incremental doc takes the 27B model many
# minutes, so the run is still alive (still progressing) at the abort poll.
#
# RED condition (known gap): helpers.sh __semantic_monitor terminates the
# poll loop unconditionally at the max-polls budget regardless of
# classification — `if [ "$poll" -gt "$BEHAVIOR_MONITOR_MAX_POLLS" ]; then
# abort_reason="max_polls_exhausted"; break` — with NO progressing-continues
# carve-out. The SC-4/SC-6 routing handles off-track/undetermined, but a
# PROGRESSING run that outlives the budget is killed just the same. Expected
# RED: the run is classified progressing-directionally (at least one CLASSIFY
# line) AND the monitor aborts it at the cap (ABORTED reason=max_polls_exhausted)
# → the progressing run IS halted at the duration cap → the "progressing runs
# continue polling regardless of duration" assertion FAILS → exit 1.
#
# GREEN expectation (after the Item-5 fix): the monitor does NOT halt a
# progressing-directionally run at the max-polls cap — it CONTINUES polling
# past the cap until the run finishes naturally, so the poll log carries
# MONITOR-COMPLETE with polls > BEHAVIOR_MONITOR_MAX_POLLS (no
# max_polls_exhausted abort) → exit 0.
#
# PRECONDITION GUARDS (exit 2 = invalid RED, requires diagnosis — never a
# verdict): required are (a) the scenario evidence directory with session.yaml
# (run produced session evidence), monitor.log (SC-1 persistence — the
# semantic monitor ran), and (b) AT LEAST ONE progressing-directionally
# classification in the poll log (a ^CLASSIFY[ line carrying the
# progressing-directionally value) — without a progressing classification the
# fixture did not produce a progressing run, so the SC-5 assertion surface is
# absent. Additionally the duration cap must have been EXERCISED: either the
# max-polls abort fired (RED) or MONITOR-COMPLETE was reached with polls >
# max_polls (GREEN). A run that finished within budget (MONITOR-COMPLETE polls
# <= max_polls) or was aborted for a different reason never approached the
# cap — a fixture/timing problem, never a verdict.
#
# §15 targeted-execution mandate: run this ONE named scenario via
#   BEHAVIOR_PHASE=RED bash .opencode/tests-v2/behaviors/2456-sc5-progressing-continues-red.sh
# with the bash tool timeout >= 600000ms per supervision poll (supervised run,
# §14 mandate — launched once in the background, polled every <=5 min with a
# full semantic check of the run's SQLite session DB).
#
# Ordered precondition cycle (§4): commit → push → fresh fetch/verify → run.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2456-sc5-progressing-continues-red"
# §11 real-domain prompt: build a documentation artifact INCREMENTALLY — one
# write tool call per section, 16 sections, ending with the declared goal
# marker line. The run produces a steady stream of distinct, goal-directed
# completed tool calls over many polls (progressing-directionally under the
# SC-2-amendment anchor against the declared goal_condition) and outlives the
# duration cap.
SCENARIO_PROMPT="Create an operations runbook file named 2456-sc5-goal-marker.txt in the current project root. Build it incrementally: use a separate write tool call for EACH of the following 16 sections, appending each section's content to the file as you go, in this exact order: (1) Title and Purpose, (2) Scope, (3) Prerequisites, (4) Environment Setup, (5) Configuration, (6) Startup and Shutdown, (7) Health Checks, (8) Backup and Restore, (9) Incident Response, (10) Monitoring and Alerting, (11) Troubleshooting Guide, (12) Security Practices, (13) Capacity Planning, (14) Deployment Procedure, (15) Rollback Procedure, (16) Conclusion. Each section must contain a heading line and a 2-3 sentence paragraph describing that topic. When all 16 sections have been written to the file, append the exact final marker line as the last line of the file: 2456-sc5-goal-marker-line. Do not stop until the file contains all 16 sections and the final marker line."

# SC-5 monitored run (opt-in flag per spec — fresh invocations without the
# flag are unchanged; backward compat preserved).
BEHAVIOR_SEMANTIC_MONITOR=1
# Duration cap (the SC-5 assertion surface): 8 polls x 30s = 240s nominal cap
# + classification-dispatch time. The 16-section run reliably outlives it.
BEHAVIOR_MONITOR_MAX_POLLS=8
export BEHAVIOR_SEMANTIC_MONITOR BEHAVIOR_MONITOR_MAX_POLLS

# DECLARED VERIFIABLE GOAL CONDITION — the classifier's ONLY direction anchor
# (SC-2 amendment, commit 197a9d14): goal artifact + required content pattern,
# folded into the digest's goal_condition object with the per-poll art_status.
# The run agent is actively producing this artifact (progressing), but the
# 16-section task outlives the cap, so art_status stays absent/partial at the
# abort poll.
BEHAVIOR_EXPECTED_ARTIFACT="2456-sc5-goal-marker.txt"
BEHAVIOR_EXPECTED_ARTIFACT_GREP="2456-sc5-goal-marker-line"
export BEHAVIOR_EXPECTED_ARTIFACT BEHAVIOR_EXPECTED_ARTIFACT_GREP

# Harness stderr capture — supplementary evidence surface (the abort emits
# "SEMANTIC MONITOR ABORT: max_polls_exhausted" on stderr); the durable
# verdict surface is monitor.log.
mkdir -p "$BEHAVIOR_LOG_DIR/$SCENARIO_NAME"
harness_stderr_capture="$BEHAVIOR_LOG_DIR/$SCENARIO_NAME/harness-stderr.log"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT" 2> "$harness_stderr_capture" || true

# ── SC-5 assertion: progressing run continues polling past the duration cap
artifact_dir="${BEHAVIOR_ARTIFACT_DIR:-}"
monitor_log="$artifact_dir/monitor.log"
cap="$BEHAVIOR_MONITOR_MAX_POLLS"

if [ -z "$artifact_dir" ] || [ ! -d "$artifact_dir" ]; then
    echo "PRECONDITION-FAIL: no scenario evidence directory produced (BEHAVIOR_ARTIFACT_DIR='${artifact_dir:-unset}') — harness failure, not a RED verdict; harness stderr capture: $harness_stderr_capture" >&2
    exit 2
fi
if [ ! -f "$artifact_dir/session.yaml" ]; then
    echo "PRECONDITION-FAIL: session.yaml missing from $artifact_dir — run produced no session evidence; not a RED verdict" >&2
    exit 2
fi
if [ ! -f "$harness_stderr_capture" ]; then
    echo "PRECONDITION-FAIL: harness stderr capture missing at $harness_stderr_capture — supplementary surface absent; not a RED verdict" >&2
    exit 2
fi
cp "$harness_stderr_capture" "$artifact_dir/harness-stderr.log" 2>/dev/null || true
if [ ! -f "$monitor_log" ]; then
    echo "PRECONDITION-FAIL: monitor.log missing from $artifact_dir — the semantic monitor did not run (SC-1 persistence absent); not a RED verdict" >&2
    exit 2
fi

# The progressing-directionally classification must have occurred — without it
# the fixture did not produce a progressing run, so the SC-5 duration-cap
# surface for progressing runs is absent (a ^CLASSIFY[ line carries the
# taxonomy value; the poll-log header's "progressing" prose never matches a
# ^CLASSIFY[ line).
progressing_classify_line="$(grep '^CLASSIFY\[' "$monitor_log" | grep 'progressing-directionally' | head -1 || true)"
if [ -z "$progressing_classify_line" ]; then
    echo "PRECONDITION-FAIL: no progressing-directionally classification in $monitor_log (no ^CLASSIFY[ line carries the progressing-directionally value) — the fixture did not produce a progressing run, so the SC-5 duration-cap surface is absent; classifications present: $(grep -c '^CLASSIFY\[' "$monitor_log" || true); not a RED verdict" >&2
    exit 2
fi
progressing_poll="$(printf '%s' "$progressing_classify_line" | sed -n 's/^CLASSIFY\[poll \([0-9]*\)\].*/\1/p')"
[ -n "$progressing_poll" ] || progressing_poll="final-guarantee"

# RED condition: the progressing run IS halted at the duration cap — the
# max-polls termination path fired (ABORTED reason=max_polls_exhausted) even
# though the run was classified progressing-directionally.
if grep -q "max_polls_exhausted" "$monitor_log"; then
    echo "RED CONFIRMED: monitored run under BEHAVIOR_SEMANTIC_MONITOR=1 was classified PROGRESSING-DIRECTIONALLY by the SC-2 classification sub-agent (${progressing_classify_line}) but the monitor HALTED it at the duration cap — ABORTED reason=max_polls_exhausted present in $monitor_log (cap=${cap} polls); the progressing run was killed at the max-polls termination path instead of continuing to poll until natural completion (helpers.sh __semantic_monitor terminates the poll loop at max-polls unconditionally, with no progressing-continues carve-out)" >&2
    exit 1
fi

# GREEN condition: the monitor continued polling past the cap — the run
# finished naturally (MONITOR-COMPLETE) with polls EXCEEDING the cap.
if grep -q "MONITOR-COMPLETE" "$monitor_log"; then
    polls="$(grep 'MONITOR-COMPLETE' "$monitor_log" | sed -n 's/.*polls=\([0-9]*\).*/\1/p')"
    if [ -n "$polls" ] && [ "$polls" -gt "$cap" ]; then
        echo "GREEN: progressing-directionally run continued polling past the duration cap — MONITOR-COMPLETE polls=${polls} > cap=${cap}; no max_polls_exhausted abort (progressing run was not halted at the cap)" >&2
        exit 0
    fi
fi

# The cap was not cleanly exercised (run finished within budget, or aborted
# for a non-max-polls reason) — a fixture/timing problem, never a verdict.
echo "PRECONDITION-FAIL: the duration cap was not exercised — no max_polls_exhausted abort AND no MONITOR-COMPLETE with polls > cap=${cap} (MONITOR-COMPLETE polls='$(grep 'MONITOR-COMPLETE' "$monitor_log" | sed -n 's/.*polls=\([0-9]*\).*/\1/p' || echo none)'); the run likely finished within budget or aborted for another reason — fixture/timing diagnosis required, not a RED verdict" >&2
exit 2
