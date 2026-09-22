#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
#
# Behavioral test: 2456-sc3-determination-record-red
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# SC-3 (.opencode#2456, plan-01 Item 3, phase-1 RED): a determination record —
# a durable YAML artifact carrying the classification and poll-evidence
# references — is written to the scenario evidence directory for a monitored
# run (R-8: alongside session.yaml and the poll log; append-only semantics for
# later false_signal annotations and orchestrator decisions are Phase-2+ SCs
# and NOT asserted here).
#
# ASSERTION TARGET — harness infrastructure, not model output: this scenario is
# the TDD enforcement test for the helpers.sh determination-record write path.
# It makes NO judgment about model output (session.yaml content is never
# evaluated); the assertion surface is deterministic file existence + record
# content shape in the scenario evidence directory. The script therefore exits
# with the assertion verdict (exit 1 = confirmed RED today, exit 0 = GREEN
# after the determination-record fix). The §1 exit-0 unconditional paradigm
# governs artifact-only generators whose MODEL OUTPUT evaluation is deferred
# to a clean-room evaluator — that pattern does not apply to a
# harness-behavior enforcement test whose assertion target is the harness
# itself (same exception as 2456-sc1-poll-evidence-persisted-red.sh and
# 2456-sc2-classification-dispatch-red.sh).
#
# RED condition (known gap): helpers.sh writes NO determination record
# anywhere. The abort path writes semantic-diagnosis.yaml (a §14 abort
# diagnosis — abort_reason + poll-log path; NOT a determination record: it is
# abort-path-only, carries no classification taxonomy value, and never
# appears on the natural completion path). The natural completion path writes
# only MONITOR-COMPLETE into the persisted poll log (SC-1: monitor.log) plus
# the SC-2 classifier-session.yaml — no record file is ever produced. Expected
# RED: run completes naturally under BEHAVIOR_SEMANTIC_MONITOR=1 with
# monitor.log and classifier-session.yaml present, but NO determination record
# exists in the scenario evidence directory → exit 1.
#
# GREEN expectation (after the Item-3 fix): the monitor writes
# $artifact_dir/determination.yaml — a YAML record carrying (a) the run's
# classification (one taxonomy value: progressing-directionally / off-track /
# undetermined, as produced by the SC-2 classification dispatch) and (b) a
# poll-evidence reference (the persisted poll log, monitor.log) — alongside
# session.yaml in the scenario evidence directory → exit 0.
#
# ASSERTION CONTRACT for determination.yaml (all three must hold):
#   1. File exists in the scenario evidence directory — a durable
#      determination record was written alongside session.yaml and the
#      persisted poll evidence (R-8 surface).
#   2. Contains one taxonomy classification value (progressing-directionally /
#      off-track / undetermined) — the classification is recorded in the
#      record, not left in the classifier session only. Presence only;
#      correctness is never judged here.
#   3. Contains a poll-evidence reference (monitor.log) — the record links
#      the determination to the persisted per-poll evidence.
#
# PRECONDITION GUARDS (exit 2 = invalid RED, requires diagnosis — never a
# verdict): the run must take the NATURAL completion path, with the SC-1 and
# SC-2 prerequisites in place (they feed the record). Required: session.yaml
# (run completed), monitor.log (SC-1 poll-evidence persistence),
# MONITOR-COMPLETE marker in monitor.log (natural completion, not abort),
# classifier-session.yaml (SC-2 classification dispatch — the record's
# classification input). A monitor abort (semantic-diagnosis.yaml present)
# removes the controlled natural-completion surface — the abort path is a
# precondition violation, never a RED verdict (the abort path is also where
# the known-gap semantic-diagnosis.yaml lives; its presence would muddy the
# no-determination-record observation).
#
# DELIBERATELY NOT DECLARED: BEHAVIOR_EXPECTED_ARTIFACT / BEHAVIOR_GOAL_ACTIONS
# / BEHAVIOR_HOPELESS_NO_PROGRESS_POLLS. GREEN-termination and hopeless
# early-exit set abort_reason and take the §14 abort path (no MONITOR-COMPLETE)
# — declaring them would precondition-fail the controlled natural-completion
# path this RED test requires. The run must finish naturally.
#
# §15 targeted-execution mandate: run this ONE named scenario via
#   BEHAVIOR_PHASE=RED bash .opencode/tests-v2/behaviors/2456-sc3-determination-record-red.sh
# with the bash tool timeout >= 600000ms (2700000ms budget for the 27B model).
#
# Ordered precondition cycle (§4): commit → push → fresh fetch/verify → run.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2456-sc3-determination-record-red"
# §11 real-domain prompt: one deterministic tool call (create a small file).
# SHORT run — completes in few polls (SC-1 calibration: 18 polls). The content
# line doubles as the scenario goal marker for the classification dispatch
# whose value the determination record must carry.
SCENARIO_PROMPT="Create a file named 2456-determination-probe.txt in the current project root. The file must contain exactly this one line: 2456-sc3-determination-goal-probe. Do nothing else."

# SC-3 monitored run (opt-in flag per spec — fresh invocations without the
# flag are unchanged; backward compat preserved).
BEHAVIOR_SEMANTIC_MONITOR=1
# 60 polls x 30s = 30 min monitored budget; SHORT run (one tool call)
# completes in far fewer polls (SC-1 calibration: 18 polls).
BEHAVIOR_MONITOR_MAX_POLLS=60
export BEHAVIOR_SEMANTIC_MONITOR BEHAVIOR_MONITOR_MAX_POLLS

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT" || true

# ── SC-3 assertion: determination record written to the evidence directory ──
artifact_dir="${BEHAVIOR_ARTIFACT_DIR:-}"
determination_record="$artifact_dir/determination.yaml"

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
if [ -f "$artifact_dir/semantic-diagnosis.yaml" ]; then
    echo "PRECONDITION-FAIL: semantic-diagnosis.yaml present in $artifact_dir — the run took the §14 abort path, not natural completion (the abort path is also the only place the known-gap semantic-diagnosis.yaml is written); not a RED verdict" >&2
    exit 2
fi
if [ ! -f "$artifact_dir/classifier-session.yaml" ]; then
    echo "PRECONDITION-FAIL: classifier-session.yaml missing from $artifact_dir — the SC-2 classification dispatch did not produce its session export, so the classification input the determination record must carry is absent; not a RED verdict" >&2
    exit 2
fi

if [ ! -f "$determination_record" ]; then
    echo "RED CONFIRMED: monitored run under BEHAVIOR_SEMANTIC_MONITOR=1 completed naturally but wrote NO determination record — $determination_record absent from the scenario evidence directory (helpers.sh writes no determination record on the natural completion path; the only determination-adjacent artifact is the abort-path-only semantic-diagnosis.yaml, which never appears here)" >&2
    exit 1
fi

if ! grep -qE "progressing-directionally|off-track|undetermined" "$determination_record"; then
    echo "RED CONFIRMED: determination record exists at $determination_record but carries NO taxonomy classification (progressing-directionally / off-track / undetermined absent) — the record does not record the run's classification" >&2
    exit 1
fi

if ! grep -q "monitor.log" "$determination_record"; then
    echo "RED CONFIRMED: determination record exists with a classification at $determination_record but carries NO poll-evidence reference (monitor.log absent from the record) — the determination is not linked to the persisted per-poll evidence" >&2
    exit 1
fi

echo "GREEN: determination record present at $determination_record (durable YAML alongside session.yaml, carrying a taxonomy classification and a monitor.log poll-evidence reference)" >&2
exit 0
