#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral test: 2456-sc22-classification-freshness-red
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# SC-22 (.opencode#2456, phase 6, item SC-22, RED — plan step 139): abort
# suppression by a progressing classification is valid ONLY while the
# classification is FRESH (R-21: "Abort suppression based on a progressing
# classification SHALL be valid only while that classification is fresh: the
# monitor SHALL re-classify at least every N polls (bounded freshness window)
# and on every new abort-signal event; a stale progressing verdict SHALL
# never suppress an abort signal"). A derailed run riding a stale verdict
# must be re-classified and aborted.
#
# BASELINE (absent — motivating evidence, recorded honestly): the 2026-09-23
# SC-5 post-regression gate halt — a poll-12 progressing verdict suppressed
# signal-3/signal-2 aborts while the run derailed at poll 16+, carried past
# 215 polls. Today helpers.sh __semantic_monitor suppresses ANY mechanical
# abort signal whenever classification_value == progressing-directionally
# (helpers.sh SC-5 block) with NO freshness check on the verdict: the
# suppression decision consults only the LAST classification, never its age
# (polls since classify) and never the per-poll abort-signal event history.
# No freshness evaluator exists anywhere in the harness — the R-21 predicate
# is UNENFORCED. This scenario is that enforcement.
#
# SYNTHETIC FIXTURES (NO live model runs — no opencode run, no behavior_run,
# no monitor lifecycle; per the task directive, EVENT-DRIVEN synthetic
# poll-log/classification fixtures like SC-16/SC-17's fixtures): three
# synthetic poll-log fixtures exercise the freshness predicate's polarity:
#   sc22-stale-verdict-suppression  progressing verdict at poll 12, derailment
#                                   at poll 16+, mechanical signals fired at
#                                   polls 17-19 but suppressed with NO
#                                   re-classification through poll 215+
#                                   (live 2026-09-23 shape)            (FAIL)
#   sc22-fresh-reclassification     re-classify at least every N polls
#                                   (N=3); derailment caught by the next
#                                   re-classification → abort          (PASS)
#   sc22-signal-triggered-reclass   a NEW abort-signal event → re-classify
#                                   BEFORE the suppression decision; the
#                                   fresh verdict off-track → abort    (PASS)
#
# RED condition (expected outcome today): helpers.sh carries NO classification
# freshness evaluator — the predicate is unenforced (no __assert_classification_freshness
# exists anywhere in helpers.sh), so every assertion fails ⇒ exit 1 (RED).
# If the evaluator already exists AND distinguishes all three fixtures
# correctly (stale-suppression fixture FAIL; both re-classification fixtures
# PASS), the predicate is already enforced by construction → ALREADY_GREEN
# classified abort (exit 3), recorded as the item's genuine outcome.
#
# PRECONDITION GUARDS (exit 2 = invalid RED, requires diagnosis — never a
# verdict): the synthetic fixture directory must have been created and all
# three poll-log fixtures must parse (carry a ^CLASSIFY[ line; the assertion
# surface is the fixture set; a missing/empty fixture is a harness defect,
# not a RED verdict).
#
# GATE EXPECTATION FOR GREEN: implement __assert_classification_freshness
# <poll-log> <verdict-yaml-out> in helpers.sh (pure decision function, no
# model dispatch) — it parses the poll log's ordered CLASSIFY[poll N] /
# mechanical-signal-suppression lines, asserts (1) re-classification at least
# every BEHAVIOR_MONITOR_CLASSIFY_FRESHNESS_WINDOW polls (bounded freshness
# window, default 3) while suppression is active, and (2) every abort-signal
# event under an active progressing verdict triggers a re-classification
# BEFORE the suppression decision; a suppression decided on a verdict older
# than the window (or without a signal-triggered re-classification) is a
# violation — verdict: PASS|FAIL with violations[] (stale suppressions,
# missed re-classifications, unhandled abort-signal events); the three
# synthetic fixtures under tmp/2456/artifacts/synthetic/sc22-* are the
# polarity suite.
#
# §15 targeted-execution mandate: run this ONE named scenario via
#   bash .opencode/tests-v2/behaviors/2456-sc22-classification-freshness-red.sh
# (bash tool timeout >= 600000ms). No model dispatch — no live opencode run
# is needed; the freshness predicate is asserted from synthetic poll-log
# fixtures.
#
# Ordered precondition cycle (§4/SC-16): the scenario file itself is committed
# and pushed to the submodule remote BEFORE this test run (mechanical, no
# deliberation; NEVER --no-verify).

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2456-sc22-classification-freshness-red"

ER="$(cd "$SCRIPT_DIR/../../.." && pwd)/tmp/2456/artifacts"
mkdir -p "$ER"
# Idempotence: clear this test's own stale artifacts.
rm -f "$ER"/pipeline-red-22sc*

FIX_ROOT="$ER/synthetic"
rm -rf "$FIX_ROOT"/sc22-*
mkdir -p "$FIX_ROOT"

PASS=0
FAIL=0

check_pass() {
    echo "  PASS: $1"
    PASS=$((PASS + 1))
}
check_fail() {
    echo "  FAIL: $1 — $2" >&2
    FAIL=$((FAIL + 1))
}

echo "== SC-22 RED check: classification-freshness predicate — progressing-verdict abort suppression valid only within the freshness window (R-21, .opencode#2456) =="

# ══ Synthetic poll-log fixtures (EVENT-DRIVEN, deterministic) ════════════════
# Poll-log format mirrors helpers.sh __semantic_monitor's poll_log output:
#   POLL <n>: ts=<ts> ... (poll lifecycle lines)
#   CLASSIFY[poll <n>]: dispatch #k/max → <classification-value> (...)
#   POLL <n>: ts=<ts> mechanical signal <reason> suppressed — run classified
#             progressing-directionally (R-2: progressing runs continue
#             regardless of duration, .opencode#2456 SC-5); continuing to poll
#   ABORTED run_pid=<pid> reason=<reason> poll=<n>
#   MONITOR-COMPLETE polls=<n> ...
FRESHNESS_WINDOW=3

python3 - "$FIX_ROOT" "$FRESHNESS_WINDOW" <<'PYEOF'
import os, sys

fix_root = sys.argv[1]
WINDOW = int(sys.argv[2])


def build(name, lines):
    d = os.path.join(fix_root, name)
    os.makedirs(d, exist_ok=True)
    with open(os.path.join(d, "monitor.log"), "w") as f:
        f.write("\n".join(lines) + "\n")


# ── Fixture 1: stale-verdict suppression (the live 2026-09-23 SC-5 shape) ────
# Progressing verdict at poll 12; run derails at poll 16+ (no new tool calls,
# reasoning growing); mechanical abort signals fire at polls 17, 18, 19 and
# are SUPPRESSED against the stale poll-12 verdict with NO re-classification;
# carried to poll 215+ before the max-polls budget ends it.
stale = [
    "POLL 10: ts=1000 semantic check event_count=42 completed_tool_calls=18",
    "POLL 11: ts=1030 semantic check event_count=43 completed_tool_calls=19",
    "POLL 12: ts=1060 classification checkpoint fired (event growth, polls_since_classify>=3)",
    "CLASSIFY[poll 12]: dispatch #4/5 → progressing-directionally (classified in sub-agent context; export: classifier-session-attempt1.yaml)",
    "POLL 13: ts=1090 semantic check event_count=44 completed_tool_calls=20",
    "POLL 14: ts=1120 semantic check event_count=45 completed_tool_calls=20",
    "POLL 15: ts=1150 semantic check event_count=46 completed_tool_calls=20",
    "POLL 16: ts=1180 semantic check event_count=60 completed_tool_calls=20 reasoning_total grew 4100 chars with NO new tool calls — run derailed into a reasoning runaway",
    "POLL 17: ts=1210 mechanical signal reasoning_runaway detected — suppressing",
    "POLL 17: ts=1210 mechanical signal reasoning_runaway suppressed — run classified progressing-directionally (R-2: progressing runs continue regardless of duration, .opencode#2456 SC-5); continuing to poll",
    "POLL 18: ts=1240 mechanical signal stuck_task_dispatch detected — suppressing",
    "POLL 18: ts=1240 mechanical signal stuck_task_dispatch suppressed — run classified progressing-directionally (R-2: progressing runs continue regardless of duration, .opencode#2456 SC-5); continuing to poll",
    "POLL 19: ts=1270 mechanical signal semantic_offtrack detected — suppressing",
    "POLL 19: ts=1270 mechanical signal semantic_offtrack suppressed — run classified progressing-directionally (R-2: progressing runs continue regardless of duration, .opencode#2456 SC-5); continuing to poll",
    "POLL 215: ts=7480 max-polls budget exhausted — run outlived monitor budget, aborting (last classification=progressing-directionally)",
    "ABORTED run_pid=40001 reason=max_polls_exhausted poll=215",
]
build("sc22-stale-verdict-suppression", stale)

# ── Fixture 2: fresh re-classification — verdict never older than N polls ────
# Progressing verdict at poll 12; re-classification every <=N polls (window=3):
# polls 14, 16 re-classify progressing; poll 18 re-classify off-track → the
# derailment is CAUGHT by the fresh verdict and the abort fires.
fresh = [
    "POLL 10: ts=1000 semantic check event_count=42 completed_tool_calls=18",
    "POLL 11: ts=1030 semantic check event_count=43 completed_tool_calls=19",
    "POLL 12: ts=1060 classification checkpoint fired (event growth, polls_since_classify>=3)",
    "CLASSIFY[poll 12]: dispatch #4/5 → progressing-directionally (classified in sub-agent context; export: classifier-session-attempt1.yaml)",
    "POLL 13: ts=1090 semantic check event_count=44 completed_tool_calls=20",
    "POLL 14: ts=1120 classification checkpoint fired (freshness window {} polls since classify reached)".format(WINDOW),
    "CLASSIFY[poll 14]: dispatch #5/5 → progressing-directionally (classified in sub-agent context; export: classifier-session-attempt2.yaml)",
    "POLL 15: ts=1150 semantic check event_count=46 completed_tool_calls=20",
    "POLL 16: ts=1180 semantic check event_count=60 completed_tool_calls=20 reasoning_total grew 4100 chars with NO new tool calls — run derailed into a reasoning runaway",
    "POLL 17: ts=1210 semantic check event_count=61 completed_tool_calls=20",
    "POLL 18: ts=1240 classification checkpoint fired (freshness window {} polls since classify reached)".format(WINDOW),
    "CLASSIFY[poll 18]: dispatch #6/5 → off-track (classified in sub-agent context; export: classifier-session-attempt3.yaml)",
    "ABORTED run_pid=40002 reason=semantic_offtrack poll=18",
]
build("sc22-fresh-reclassification", fresh)

# ── Fixture 3: signal-triggered re-classification — new abort signal → ───────
# re-classify BEFORE the suppression decision. Progressing verdict at poll 12
# is 1 poll old (fresh), but a NEW mechanical abort-signal event fires at
# poll 17; the monitor re-classifies FIRST (poll 17), and the FRESH verdict
# (off-track) decides the abort.
signal = [
    "POLL 10: ts=1000 semantic check event_count=42 completed_tool_calls=18",
    "POLL 11: ts=1030 semantic check event_count=43 completed_tool_calls=19",
    "POLL 12: ts=1060 classification checkpoint fired (event growth, polls_since_classify>=3)",
    "CLASSIFY[poll 12]: dispatch #4/5 → progressing-directionally (classified in sub-agent context; export: classifier-session-attempt1.yaml)",
    "POLL 13: ts=1090 semantic check event_count=44 completed_tool_calls=20",
    "POLL 14: ts=1120 semantic check event_count=45 completed_tool_calls=20",
    "POLL 15: ts=1150 semantic check event_count=46 completed_tool_calls=20",
    "POLL 16: ts=1180 semantic check event_count=60 completed_tool_calls=20 reasoning_total grew 4100 chars with NO new tool calls — run derailed into a reasoning runaway",
    "POLL 17: ts=1210 NEW abort-signal event: mechanical signal reasoning_runaway detected — re-classification required before suppression decision (R-21: on every new abort-signal event)",
    "CLASSIFY[poll 17]: dispatch #5/5 → off-track (signal-triggered re-classification; export: classifier-session-attempt2.yaml)",
    "ABORTED run_pid=40003 reason=reasoning_runaway poll=17",
]
build("sc22-signal-triggered-reclass", signal)
PYEOF
fixture_rc=$?

# ── Precondition guards: fixtures built and parseable ────────────────────────
if [ "$fixture_rc" -ne 0 ]; then
    echo "PRECONDITION-FAIL: synthetic fixture generation failed (rc=$fixture_rc) — harness defect, not a RED verdict" >&2
    exit 2
fi
FIXTURES="sc22-stale-verdict-suppression sc22-fresh-reclassification sc22-signal-triggered-reclass"
for fx in $FIXTURES; do
    if [ ! -s "$FIX_ROOT/$fx/monitor.log" ]; then
        echo "PRECONDITION-FAIL: fixture $FIX_ROOT/$fx/monitor.log missing or empty — the poll-log assertion surface is absent; not a RED verdict" >&2
        exit 2
    fi
    if ! grep -q '^CLASSIFY\[' "$FIX_ROOT/$fx/monitor.log"; then
        echo "PRECONDITION-FAIL: fixture $FIX_ROOT/$fx/monitor.log carries no ^CLASSIFY[ line — no classification to evaluate freshness against; not a RED verdict" >&2
        exit 2
    fi
done
echo "  [fixtures] 3 synthetic poll logs built under $FIX_ROOT (no live model runs; freshness window N=$FRESHNESS_WINDOW polls)"

# ══ Assertion 1 — the classification-freshness evaluator exists in helpers.sh ═
if grep -q '^__assert_classification_freshness()' "$SCRIPT_DIR/helpers.sh"; then
    check_pass "classification-freshness evaluator __assert_classification_freshness defined in helpers.sh"
    EVALUATOR_PRESENT=1
else
    check_fail "classification-freshness evaluator __assert_classification_freshness defined in helpers.sh" \
        "no poll-log classification-freshness evaluator exists in helpers.sh — the R-21 freshness-bound predicate (re-classify every N polls and on every new abort-signal event; stale progressing verdicts never suppress) is UNENFORCED: the SC-5 suppression block consults only the last classification value, never its age or the intervening abort-signal events (RED)"
    EVALUATOR_PRESENT=0
fi

evaluate_fixture() { # $1 fixture name; sets ev_rc; writes verdict yaml
    local fx="$1"
    local out="$FIX_ROOT/$fx/freshness-verdict.yaml"
    rm -f "$out"
    if [ "$EVALUATOR_PRESENT" = "1" ] && [ "$(type -t __assert_classification_freshness)" = function ]; then
        __assert_classification_freshness "$FIX_ROOT/$fx/monitor.log" "$out"
        ev_rc=$?
    else
        ev_rc=127
        printf 'classification_freshness: poll_log_stale_verdict_suppression\neverdict: NOT_EVALUABLE\nevaluator: absent (helpers.sh)\n' > "$out"
    fi
    ev_verdict="$(grep -E '^verdict: ' "$out" 2>/dev/null | head -1 | sed 's/^verdict: //' || true)"
    return 0
}

# ══ Assertion 2 — stale-verdict-suppression fixture evaluates FAIL ═══════════
evaluate_fixture sc22-stale-verdict-suppression; f2_rc=$ev_rc; f2_verdict="$ev_verdict"
f2_viol="$(grep -cE 'stale|violation' "$FIX_ROOT/sc22-stale-verdict-suppression/freshness-verdict.yaml" 2>/dev/null || true)"
if [ "$EVALUATOR_PRESENT" = "1" ] && [ "$f2_rc" -ne 0 ] && [ "$f2_verdict" = "FAIL" ] && [ "${f2_viol:-0}" -ge 1 ]; then
    check_pass "stale-verdict-suppression fixture evaluates FAIL (rc=$f2_rc) with the stale suppression recorded — a poll-12 progressing verdict suppressing poll-17+ abort signals with no re-classification through poll 215+ is the R-21 violation (the live 2026-09-23 defect shape)"
else
    check_fail "stale-verdict-suppression fixture evaluates FAIL with the stale suppression recorded" \
        "evaluator rc=$f2_rc verdict='${f2_verdict:-none}' violation_records=${f2_viol:-0} — suppression decided on a verdict older than the freshness window must fail the assertion and be recorded"
fi

# ══ Assertion 3 — fresh-reclassification fixture evaluates PASS ══════════════
evaluate_fixture sc22-fresh-reclassification; f3_rc=$ev_rc; f3_verdict="$ev_verdict"
if [ "$EVALUATOR_PRESENT" = "1" ] && [ "$f3_rc" -eq 0 ] && [ "$f3_verdict" = "PASS" ]; then
    check_pass "fresh-reclassification fixture evaluates PASS (rc=$f3_rc) — re-classifying at least every N polls keeps every suppression fresh and lets the fresh off-track verdict abort the derailed run"
else
    check_fail "fresh-reclassification fixture evaluates PASS" \
        "evaluator rc=$f3_rc verdict='${f3_verdict:-none}' — a poll cadence that re-classifies within the freshness window is mechanically compliant and must pass the assertion"
fi

# ══ Assertion 4 — signal-triggered-reclassification fixture evaluates PASS ═══
evaluate_fixture sc22-signal-triggered-reclass; f4_rc=$ev_rc; f4_verdict="$ev_verdict"
if [ "$EVALUATOR_PRESENT" = "1" ] && [ "$f4_rc" -eq 0 ] && [ "$f4_verdict" = "PASS" ]; then
    check_pass "signal-triggered-reclassification fixture evaluates PASS (rc=$f4_rc) — a new abort-signal event triggering re-classification BEFORE the suppression decision, with the fresh verdict deciding the abort, satisfies R-21"
else
    check_fail "signal-triggered-reclassification fixture evaluates PASS" \
        "evaluator rc=$f4_rc verdict='${f4_verdict:-none}' — a new abort-signal event followed by re-classification before the suppression decision must pass the assertion"
fi

# ══ Evidence artifact ════════════════════════════════════════════════════════
OUT="$ER/pipeline-red-22sc-sc22-summary.yaml"
{
    echo "== SC-22 RED evidence (.opencode#2456) =="
    echo "test: ${SCENARIO_NAME}"
    echo "sc_ref: SC-22 (plan-06 Item 22, phase 6, step 139)"
    echo "evidence_type: behavioral (poll-log classification-freshness assertion; synthetic fixtures per task directive — no live model runs)"
    echo "model_dispatch: none (synthetic poll-log/classification fixtures)"
    echo "baseline: ABSENT (motivating evidence: 2026-09-23 SC-5 post-regression gate halt — a poll-12 progressing verdict suppressed signal-3/2 aborts while the run derailed at poll 16+, carried past 215 polls)"
    echo "synthetic_fixtures: $FIX_ROOT/sc22-{stale-verdict-suppression,fresh-reclassification,signal-triggered-reclass}/monitor.log"
    echo "freshness_window_polls: $FRESHNESS_WINDOW"
    echo "evaluator_present: $EVALUATOR_PRESENT"
    echo "fixture_eval_rc: stale-suppression=$f2_rc fresh-reclass=$f3_rc signal-triggered=$f4_rc"
    echo "fixture_verdicts: stale-suppression='${f2_verdict:-none}' fresh-reclass='${f3_verdict:-none}' signal-triggered='${f4_verdict:-none}'"
    echo "phase: RED"
    echo "fail_assertions: $FAIL"
    echo "pass_assertions: $PASS"
} > "$OUT" 2>&1

if [ "$FAIL" -eq 0 ]; then
    echo "RED ABORT — ALREADY_GREEN: the classification-freshness evaluator exists in helpers.sh and distinguishes all three fixtures correctly (stale-suppression fixture FAIL; fresh-reclassification and signal-triggered-reclassification fixtures PASS) — the R-21 freshness-bound predicate is already enforced by construction, so a failing RED test cannot be validly produced" >&2
    {
        echo "verdict: RED_ABORT_ALREADY_GREEN (exit 3) — the classification-freshness predicate is already enforced; a failing RED test cannot be validly produced"
    } >> "$OUT" 2>&1
    exit 3
fi

{
    echo "verdict: RED (exit 1) — the classification-freshness predicate is ABSENT as an enforced predicate: no __assert_classification_freshness exists in helpers.sh, so verdict age (re-classification at least every N polls) and signal-triggered re-classification are asserted nowhere mechanically; a stale progressing verdict suppresses abort signals indefinitely"
    echo "blocker_class: none (red is the expected terminal state; GREEN implementer: step 140 — implement __assert_classification_freshness <poll-log> <verdict-yaml-out> in helpers.sh per the contract in this file's header)"
} >> "$OUT" 2>&1

echo "RED CONFIRMED: $FAIL failing assertion(s) — the classification-freshness predicate is ABSENT as an enforced predicate (evaluator_present=$EVALUATOR_PRESENT; fixture verdicts: stale-suppression='${f2_verdict:-none}' fresh-reclass='${f3_verdict:-none}' signal-triggered='${f4_verdict:-none}'). The SC-5 suppression block in helpers.sh consults only the LAST classification value — a progressing verdict suppresses aborts indefinitely with no freshness bound, so a derailed run rides a stale verdict past 200+ polls (live 2026-09-23 evidence). GATE EXPECTATION FOR GREEN: implement __assert_classification_freshness <poll-log> <verdict-yaml-out> in helpers.sh (pure decision function, no model dispatch) — it parses the poll log's ordered CLASSIFY[poll N]/suppression lines and asserts (1) re-classification at least every BEHAVIOR_MONITOR_CLASSIFY_FRESHNESS_WINDOW polls while suppression is active and (2) every new abort-signal event triggers re-classification BEFORE the suppression decision; verdict: PASS|FAIL with violations[]; the three synthetic fixtures under $FIX_ROOT/sc22-* are the polarity suite (evidence: $OUT, .opencode#2456 SC-22)." >&2
exit 1

# Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)