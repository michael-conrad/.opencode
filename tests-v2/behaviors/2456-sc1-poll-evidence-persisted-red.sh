#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
#
# Behavioral test: 2456-sc1-poll-evidence-persisted-red
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# SC-1 (.opencode#2456, plan-01 Item 1, phase-1 RED): when
# BEHAVIOR_SEMANTIC_MONITOR=1, the monitor persists poll evidence for EVERY
# monitored run to the scenario evidence directory (R-1). The poll evidence is
# the §14 poll log (per-poll event-stream reads + judgments); the scenario
# evidence directory is the behavior_run artifact directory that holds
# session.yaml.
#
# ASSERTION TARGET — harness infrastructure, not model output: this scenario is
# the TDD enforcement test for helpers.sh poll-evidence persistence. It makes
# NO judgment about model output (session.yaml content is never evaluated); the
# single assertion is deterministic file existence in the evidence directory.
# The script therefore exits with the assertion verdict (exit 1 = confirmed
# RED today, exit 0 = GREEN after the persistence fix). The §1 exit-0
# unconditional paradigm governs artifact-only generators whose MODEL OUTPUT
# evaluation is deferred to a clean-room evaluator — that pattern does not
# apply to a harness-behavior enforcement test whose assertion target is the
# harness itself.
#
# RED condition (known gap): helpers.sh persists the poll log to the evidence
# directory ONLY on the monitor abort path (cp "$poll_log"
# "$artifact_dir/monitor.log" in the §14 abort block). On the natural
# completion path ("MONITOR-COMPLETE", __semantic_monitor exit 0) the post-run
# artifact block persists stdout.log/stderr.log/manifest.yaml/session.yaml/
# timeline.yaml but NEVER the poll log — poll evidence survives only in the
# transient $BEHAVIOR_LOG_DIR location. Expected RED: run completes naturally,
# session.yaml present, poll log present in the transient location,
# monitor.log ABSENT from the evidence directory → exit 1.
#
# GREEN expectation (after the Item-1 fix): monitor.log present in the
# evidence directory alongside session.yaml → exit 0.
#
# PRECONDITION GUARDS (exit 2 = invalid RED, requires diagnosis — never a
# verdict): the run must take the NATURAL completion path. If the monitor
# aborts on any §14 signal, the abort path persists monitor.log itself, which
# would false-pass the assertion. The poll log marker "MONITOR-COMPLETE"
# (written only on natural completion) discriminates the paths. A monitor
# abort, a missing session.yaml, or a missing transient poll log is a
# precondition violation, never a RED verdict.
#
# DELIBERATELY NOT DECLARED: BEHAVIOR_EXPECTED_ARTIFACT / BEHAVIOR_GOAL_ACTIONS.
# GREEN-termination (early termination on artifact+goal) sets abort_reason and
# takes the §14 abort path, which persists monitor.log — declaring them would
# false-pass this RED test. The run must finish naturally.
#
# §15 targeted-execution mandate: run this ONE named scenario via
#   BEHAVIOR_PHASE=RED bash .opencode/tests-v2/behaviors/2456-sc1-poll-evidence-persisted-red.sh
# with the bash tool timeout >= 600000ms (2700000ms used for the 27B model).
#
# Ordered precondition cycle (§4): commit → push → fresh fetch/verify → run.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2456-sc1-poll-evidence-persisted-red"
# §11 real-domain prompt: one deterministic tool call (create a small file).
SCENARIO_PROMPT="Create a file named 2456-poll-evidence-probe.txt in the current project root. The file must contain exactly this one line: 2456-sc1-poll-evidence-probe. Do nothing else."

# SC-1 monitored run (opt-in flag per spec — fresh invocations without the
# flag are unchanged; backward compat preserved).
BEHAVIOR_SEMANTIC_MONITOR=1
# 60 polls x 30s = 30 min monitored budget, inside the mandated bash tool
# timeout (2700000ms) so a backstop abort can complete its evidence export.
BEHAVIOR_MONITOR_MAX_POLLS=60
export BEHAVIOR_SEMANTIC_MONITOR BEHAVIOR_MONITOR_MAX_POLLS

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT" || true

# ── SC-1 assertion: poll evidence persisted to the scenario evidence dir ────
artifact_dir="${BEHAVIOR_ARTIFACT_DIR:-}"
poll_log_dir="$BEHAVIOR_LOG_DIR/$SCENARIO_NAME"
poll_log_file="$(ls "$poll_log_dir"/monitor-attempt*.log 2>/dev/null | head -1 || true)"

if [ -z "$artifact_dir" ] || [ ! -d "$artifact_dir" ]; then
    echo "PRECONDITION-FAIL: no scenario evidence directory produced (BEHAVIOR_ARTIFACT_DIR='${artifact_dir:-unset}') — harness failure, not a RED verdict" >&2
    exit 2
fi
if [ ! -f "$artifact_dir/session.yaml" ]; then
    echo "PRECONDITION-FAIL: session.yaml missing from $artifact_dir — run did not complete; not a RED verdict" >&2
    exit 2
fi
if [ -z "$poll_log_file" ]; then
    echo "PRECONDITION-FAIL: no monitor poll log at $poll_log_dir/monitor-attempt*.log — the semantic monitor did not run; not a RED verdict" >&2
    exit 2
fi
if ! grep -q "MONITOR-COMPLETE" "$poll_log_file"; then
    echo "PRECONDITION-FAIL: monitor did not reach natural completion (no MONITOR-COMPLETE marker in $poll_log_file) — abort-path persistence would false-pass the assertion; not a RED verdict" >&2
    exit 2
fi

if [ -f "$artifact_dir/monitor.log" ]; then
    echo "GREEN: poll evidence persisted at $artifact_dir/monitor.log alongside session.yaml" >&2
    exit 0
fi

echo "RED CONFIRMED: monitored run under BEHAVIOR_SEMANTIC_MONITOR=1 completed naturally but persisted NO poll evidence to the scenario evidence directory ($artifact_dir) — poll log exists only at $poll_log_file (helpers.sh persists it to the evidence dir on the abort path only)" >&2
exit 1
