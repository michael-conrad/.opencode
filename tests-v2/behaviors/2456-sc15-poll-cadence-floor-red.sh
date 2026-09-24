#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral test: 2456-sc15-poll-cadence-floor-red
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# SC-15 (.opencode#2456, plan-06 phase-6 item, RED): monitored runs are polled
# no less often than every 5 minutes — poll interval ≤ 300 seconds. The
# cadence is asserted from the monitored run's poll log: NO gap between
# consecutive POLL records exceeds 300 seconds.
#
# BASELINE (known gap, recorded honestly): helpers.sh's __semantic_monitor
# loop sleeps BEHAVIOR_MONITOR_INTERVAL seconds per tick (default 30) — the
# cadence holds IN PRACTICE, but NO enforceable predicate/record exists
# anywhere: the poll log carries no per-poll timestamps, so a poll gap is
# unmeasurable from the recorded evidence and a run can silently exceed 300s
# between polls without any detection. This scenario is that enforcement: it
# runs a real monitored fixture and asserts the cadence predicate FROM THE
# POLL LOG.
#
# CADENCE MEASUREMENT: the poll log's POLL records carry no timestamps
# (baseline defect — the record the SC-15 predicate needs does not exist).
# The scenario therefore asserts the predicate with a two-layer design:
#
#   Layer 1 (record exists): each POLL record must carry a ts=<epoch> stamp
#   (helpers.sh emits none today) — without it a poll gap is unmeasurable
#   from the persisted evidence and the bound is unenforceable.
#
#   Layer 2 (measured): when ts= stamps exist, the maximum gap between
#   consecutive POLL epochs must be ≤ 300s. A run that silently exceeds the
#   bound with no detection is the prohibited RED signal.
#
# RED condition (the expected outcome today): the monitored run completes
# with a poll log whose POLL records carry NO timestamp (no ts= field), so
# the cadence predicate is UNRECORDABLE — a run could exceed 300s between
# polls with zero detection. RED confirmed → exit 1. If the harness already
# stamps each POLL record and every measured gap is ≤300s, the predicate is
# already enforced by construction → ALREADY_GREEN classified abort (exit 3),
# recorded as the item's genuine outcome.
#
# GREEN expectation (after the phase-6 fix): helpers.sh stamps each POLL
# record with ts=<epoch> and the scenario measures consecutive gaps ≤300s →
# exit 0.
#
# PRECONDITION GUARDS (exit 2 = invalid RED, requires diagnosis — never a
# verdict): the scenario evidence directory with session.yaml and monitor.log
# must exist, and the monitor must have produced ≥2 POLL records on a single
# completed attempt (a single-poll run has no consecutive gap to assert, so
# the SC-15 assertion surface is absent). Without these the cadence surface
# is not exercised — not a RED verdict.
#
# §15 targeted-execution mandate: run this ONE named scenario via
#   BEHAVIOR_PHASE=RED bash .opencode/tests-v2/behaviors/2456-sc15-poll-cadence-floor-red.sh
# with the bash tool timeout >= 600000ms per supervision poll (supervised
# run, §14 mandate — launched once detached/setsid, polled every <=290s with
# a full semantic check of the run's SQLite session DB).
#
# Ordered precondition cycle (§4/SC-16): commit → push → fresh fetch/verify
# → run. NEVER --no-verify.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2456-sc15-poll-cadence-floor-red"
# §11 real-domain prompt: a bounded heartbeat protocol loop (same shape as the
# sc13/sc14 fixtures — distinct lines, one write per cycle, bounded count,
# explicit stop) so the monitored run completes naturally inside the monitor
# budget and produces a poll log with MULTIPLE consecutive POLL records — the
# consecutive-gap surface SC-15 asserts.
SCENARIO_PROMPT="Follow this repository working protocol exactly — it is the entire task. Working protocol (run log): Create a file named run-log.md in the current project root if it does not exist. Then append the following lines to run-log.md in order, exactly one line per work cycle (one write tool call per line — never batch multiple lines into a single write): run 01: cycle logged / run 02: cycle logged / run 03: cycle logged. After all three lines are appended, the protocol loop is complete — stop."

# SC-15 monitored run (opt-in flags per spec — fresh invocations without the
# flags are unchanged; backward compat preserved). The default
# BEHAVIOR_MONITOR_INTERVAL (30s) satisfies the ≤300s cadence in practice —
# which is exactly the ALREADY_GREEN surface if the harness records the
# cadence; the RED surface is the ABSENT cadence record.
BEHAVIOR_SEMANTIC_MONITOR=1
BEHAVIOR_MONITOR_MAX_POLLS=60
BEHAVIOR_MONITOR_CLASSIFY_TIMEOUT=900
export BEHAVIOR_SEMANTIC_MONITOR BEHAVIOR_MONITOR_MAX_POLLS BEHAVIOR_MONITOR_CLASSIFY_TIMEOUT

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT" || true

# ── Precondition guards ──────────────────────────────────────────────────
artifact_dir="${BEHAVIOR_ARTIFACT_DIR:-}"
monitor_log="$artifact_dir/monitor.log"

if [ -z "$artifact_dir" ] || [ ! -d "$artifact_dir" ]; then
    echo "PRECONDITION-FAIL: no scenario evidence directory produced (BEHAVIOR_ARTIFACT_DIR='${artifact_dir:-unset}') — harness failure, not a RED verdict" >&2
    exit 2
fi
if [ ! -f "$artifact_dir/session.yaml" ]; then
    echo "PRECONDITION-FAIL: session.yaml missing from $artifact_dir — run produced no session evidence; not a RED verdict" >&2
    exit 2
fi
if [ ! -f "$monitor_log" ]; then
    echo "PRECONDITION-FAIL: monitor.log missing from $artifact_dir — the semantic monitor did not run (SC-1 persistence absent); not a RED verdict" >&2
    exit 2
fi

# The cadence assertion needs at least 2 consecutive POLL records on ONE
# monitored run — a single-poll run has no gap to assert.
poll_count=$(grep -c '^POLL [0-9]' "$monitor_log" 2>/dev/null || echo 0)
if [ "${poll_count:-0}" -lt 2 ]; then
    echo "PRECONDITION-FAIL: only ${poll_count} POLL record(s) in $monitor_log — fewer than 2 consecutive polls, so no consecutive-poll gap exists and the SC-15 cadence assertion surface is absent; not a RED verdict" >&2
    exit 2
fi

# ── SC-15 assertion layer 1: the cadence is RECORDED ─────────────────────
# Each POLL record must carry a timestamp (ts=<epoch>) so the consecutive-gap
# predicate is measurable and enforceable from the persisted poll log. Today
# helpers.sh emits POLL records with ev=/tools=/completed= counters ONLY —
# no ts= field — so the cadence bound (≤300s) is neither measured nor
# detectable: a run could silently exceed 300s between polls with zero
# detection.
ts_count=$(grep -c '^POLL [0-9].*\bts=[0-9]' "$monitor_log" 2>/dev/null || echo 0)

# ── SC-15 assertion layer 2: the cadence holds (measured) ────────────────
# When ts= stamps exist, measure the maximum gap between consecutive POLL
# records and assert ≤300s.
max_gap=0
if [ "${ts_count:-0}" -ge 2 ]; then
    # Pull the epoch stamps in poll order and compute consecutive gaps with
    # awk (max gap across consecutive pairs).
    max_gap=$(grep '^POLL [0-9]' "$monitor_log" | sed -n 's/.*\bts=\([0-9]*\).*/\1/p' | awk 'NR>1 { g=$1-prev; if (g>max) max=g } { prev=$1 } END { print max+0 }')
    [ -n "$max_gap" ] || max_gap=0
fi

PHASE="${BEHAVIOR_PHASE:-RED}"

if [ "$PHASE" = "GREEN" ]; then
    if [ "$ts_count" -ge "$poll_count" ] && [ "$max_gap" -le 300 ]; then
        echo "GREEN: every POLL record in $monitor_log carries a ts= epoch stamp (${ts_count}/${poll_count}) and the maximum consecutive-poll gap is ${max_gap}s ≤ 300s — the poll-cadence floor is enforced by the recorded evidence (SC-15)" >&2
        exit 0
    fi
    echo "GREEN NOT SATISFIED (RED confirmed in GREEN phase): ts-stamped POLL records ${ts_count}/${poll_count}, max consecutive gap ${max_gap}s — the cadence predicate is not enforced by the recorded poll evidence ($monitor_log)" >&2
    exit 1
fi

# RED phase: the predicate must hold on the recorded poll evidence.
if [ "$ts_count" -ge "$poll_count" ] && [ "$max_gap" -le 300 ]; then
    echo "RED ABORT — ALREADY_GREEN: all ${poll_count} POLL records in $monitor_log carry ts= epoch stamps and the maximum consecutive-poll gap is ${max_gap}s ≤ 300s — the poll-cadence floor (SC-15) is already enforced by construction in the current harness, so a failing RED test cannot be validly produced" >&2
    exit 3
fi

if [ "${ts_count:-0}" -lt 2 ]; then
    echo "RED CONFIRMED: the monitored run's poll log ($monitor_log) carries ${poll_count} POLL records but ZERO of them carry a ts= epoch timestamp (ts_count=${ts_count}) — no consecutive-poll gap is measurable from the persisted evidence, so the ≤300s cadence bound is neither recorded nor enforceable: a run can silently exceed 300s between polls without any detection (the unenforced predicate SC-15 closes; helpers.sh __semantic_monitor sleeps BEHAVIOR_MONITOR_INTERVAL=30s per tick which satisfies the cadence in practice, but no enforceable predicate/record exists)" >&2
    exit 1
fi

echo "RED CONFIRMED: the poll log ($monitor_log) carries ts= stamps on only ${ts_count}/${poll_count} POLL records (max consecutive gap ${max_gap}s) — the cadence record is incomplete/unenforceable; a run can exceed the ≤300s bound between unrecorded polls with no detection" >&2
exit 1