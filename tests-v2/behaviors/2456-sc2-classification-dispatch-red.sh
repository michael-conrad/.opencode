#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
#
# Behavioral test: 2456-sc2-classification-dispatch-red
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# SC-2 (.opencode#2456, plan-01 Item 2, phase-1 RED): the monitor dispatches a
# monitoring sub-agent that semantically classifies run state
# (progressing-directionally / off-track / undetermined) in the sub-agent's OWN
# context, given the scenario's goal/expected-behavior context (R-1).
#
# ASSERTION TARGET — harness infrastructure, not model output: this scenario is
# the TDD enforcement test for helpers.sh classification dispatch. It makes NO
# judgment about whether any classification value is CORRECT (that semantic
# evaluation belongs to the orchestrator/clean-room evaluator); the single
# assertion surface is deterministic dispatch evidence: the classification
# sub-agent's OWN session export present in the scenario evidence directory.
# The script therefore exits with the assertion verdict (exit 1 = confirmed
# RED today, exit 0 = GREEN after the classification-dispatch fix). The §1
# exit-0 unconditional artifact-only paradigm does not apply to a
# harness-behavior enforcement test whose assertion target is the harness
# itself (same exception as 2456-sc1-poll-evidence-persisted-red.sh).
#
# RED condition (known gap): __semantic_monitor (helpers.sh) performs its
# per-poll evaluation with shell activity counters ONLY (event_count,
# tool_parts, completed, identical_input_max, reason_hash) feeding shell
# heuristic signals — there is NO classification sub-agent dispatch anywhere
# in the monitor loop, and no sub-agent session export is ever produced. The
# abort path writes a shell-heredoc semantic-diagnosis.yaml; the completion
# path writes only the MONITOR-COMPLETE marker. Expected RED: run completes
# naturally under BEHAVIOR_SEMANTIC_MONITOR=1, monitor.log persisted (SC-1),
# but NO classifier session export exists in the scenario evidence directory
# → exit 1.
#
# GREEN expectation (after the Item-2 fix): the monitor dispatches the
# classification sub-agent with the scenario's goal/expected-behavior context
# and persists the classifier's OWN session export to
# $artifact_dir/classifier-session.yaml (alongside the monitored run's
# session.yaml — a separate sub-agent session, its own context) → exit 0.
#
# ASSERTION CONTRACT for classifier-session.yaml (all four must hold):
#   1. File exists in the scenario evidence directory — a classification
#      dispatch occurred (semantic judgment in a sub-agent context, not shell).
#   2. NOT byte-identical to session.yaml — the classifier is a SEPARATE
#      dispatch, not a re-export of the monitored run's session.
#   3. Contains the scenario goal marker (2456-sc2-classification-goal-probe,
#      embedded in SCENARIO_PROMPT) — the dispatch was given the scenario's
#      goal/expected-behavior context to anchor direction.
#   4. Contains one taxonomy value (progressing-directionally / off-track /
#      undetermined) — a classification was produced in the sub-agent's own
#      context. Presence only; correctness is never judged here.
#
# PRECONDITION GUARDS (exit 2 = invalid RED, requires diagnosis — never a
# verdict): the run must take the NATURAL completion path. If the monitor
# aborts on any §14 signal, the aborted run is not the controlled
# monitored-run surface for this assertion (and the abort path's shell-heredoc
# diagnosis would pollute the evidence). The MONITOR-COMPLETE marker
# discriminates the paths. A monitor abort, a missing session.yaml, a missing
# persisted monitor.log, or a missing scenario evidence directory is a
# precondition violation, never a RED verdict.
#
# DELIBERATELY NOT DECLARED: BEHAVIOR_EXPECTED_ARTIFACT / BEHAVIOR_GOAL_ACTIONS
# / BEHAVIOR_HOPELESS_NO_PROGRESS_POLLS. GREEN-termination and hopeless
# early-exit set abort_reason and take the §14 abort path (no MONITOR-COMPLETE)
# — declaring them would precondition-fail the controlled natural-completion
# path this RED test requires. The run must finish naturally.
#
# §15 targeted-execution mandate: run this ONE named scenario via
#   BEHAVIOR_PHASE=RED bash .opencode/tests-v2/behaviors/2456-sc2-classification-dispatch-red.sh
# with the bash tool timeout >= 600000ms (2700000ms budget for the 27B model).
#
# Ordered precondition cycle (§4): commit → push → fresh fetch/verify → run.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2456-sc2-classification-dispatch-red"
# §11 real-domain prompt: one deterministic tool call (create a small file).
# The content line doubles as the scenario goal marker asserted in the
# classifier session export (assertion contract item 3).
SCENARIO_PROMPT="Create a file named 2456-classification-probe.txt in the current project root. The file must contain exactly this one line: 2456-sc2-classification-goal-probe. Do nothing else."

# SC-2 monitored run (opt-in flag per spec — fresh invocations without the
# flag are unchanged; backward compat preserved).
BEHAVIOR_SEMANTIC_MONITOR=1
# 60 polls x 30s = 30 min monitored budget; SHORT run (one tool call)
# completes in far fewer polls (SC-1 calibration: 18 polls).
BEHAVIOR_MONITOR_MAX_POLLS=60
export BEHAVIOR_SEMANTIC_MONITOR BEHAVIOR_MONITOR_MAX_POLLS

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT" || true

# ── SC-2 assertion: classification sub-agent dispatch evidence ───────────────
artifact_dir="${BEHAVIOR_ARTIFACT_DIR:-}"
classifier_session="$artifact_dir/classifier-session.yaml"

if [ -z "$artifact_dir" ] || [ ! -d "$artifact_dir" ]; then
    echo "PRECONDITION-FAIL: no scenario evidence directory produced (BEHAVIOR_ARTIFACT_DIR='${artifact_dir:-unset}') — harness failure, not a RED verdict" >&2
    exit 2
fi
if [ ! -f "$artifact_dir/session.yaml" ]; then
    echo "PRECONDITION-FAIL: session.yaml missing from $artifact_dir — run did not complete; not a RED verdict" >&2
    exit 2
fi
if [ ! -f "$artifact_dir/monitor.log" ]; then
    echo "PRECONDITION-FAIL: monitor.log missing from $artifact_dir — the semantic monitor did not run (SC-1 persistence absent); not a RED verdict" >&2
    exit 2
fi
if ! grep -q "MONITOR-COMPLETE" "$artifact_dir/monitor.log"; then
    echo "PRECONDITION-FAIL: monitor did not reach natural completion (no MONITOR-COMPLETE marker in $artifact_dir/monitor.log) — an aborted run is not the controlled surface for this assertion; not a RED verdict" >&2
    exit 2
fi

if [ ! -f "$classifier_session" ]; then
    echo "RED CONFIRMED: monitored run under BEHAVIOR_SEMANTIC_MONITOR=1 completed naturally but produced NO classification sub-agent dispatch evidence — $classifier_session absent from the scenario evidence directory (helpers.sh __semantic_monitor classifies with shell activity counters only; no classification sub-agent is ever dispatched, no classifier session export exists)" >&2
    exit 1
fi

if cmp -s "$classifier_session" "$artifact_dir/session.yaml"; then
    echo "PRECONDITION-FAIL: classifier-session.yaml is byte-identical to session.yaml — a separate classification sub-agent dispatch did not occur (re-export of the run session is not the classifier's own context); not a RED verdict" >&2
    exit 2
fi

if ! grep -q "2456-sc2-classification-goal-probe" "$classifier_session"; then
    echo "RED CONFIRMED: classification dispatch evidence exists but carries NO scenario goal context — the scenario goal marker (2456-sc2-classification-goal-probe) is absent from $classifier_session, so the classification sub-agent was not given the scenario's goal/expected-behavior context" >&2
    exit 1
fi

if ! grep -qE "progressing-directionally|off-track|undetermined" "$classifier_session"; then
    echo "RED CONFIRMED: classification dispatch evidence exists with goal context but contains NO taxonomy classification (progressing-directionally / off-track / undetermined absent from $classifier_session) — no classification was produced in the sub-agent's own context" >&2
    exit 1
fi

echo "GREEN: classification sub-agent dispatch evidence present — $classifier_session (separate dispatch, scenario goal context, taxonomy classification in the sub-agent's own context)" >&2
exit 0
