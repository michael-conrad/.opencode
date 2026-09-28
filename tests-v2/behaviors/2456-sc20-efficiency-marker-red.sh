#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral test: 2456-sc20-efficiency-marker-red
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# SC-20 (.opencode#2456, phase 6, item SC-20, RED — plan step 129): every
# 5-minute semantic check of a supervised run's SQLite session DB includes an
# efficiency analysis — excessive deliberation (large reasoning growth without
# corresponding tool-call progress, repeated self-correction loops,
# over-exploration on a straightforward post-spec/post-plan task) is recorded
# as a defect marker in the poll evidence and routed to the defect
# notification path; raw model latency is NOT a defect marker (the marker
# keys on deliberation-to-progress ratio, not wall-clock duration).
#
# BASELINE (known gap, recorded honestly): the R-18 signal-3
# reasoning-size watch exists in the harness monitor (§14 hard-abort signal
# 3: reasoning >20,000 chars with <=1 new completed tool call) but there is
# NO per-poll efficiency-marker evaluator asserted as a durable function —
# the excessive-deliberation defect marker (recorded + notified) is not
# mechanically asserted anywhere. This scenario is that enforcement.
#
# EXERCISE SURFACE — the session-export efficiency-marker evaluator: the
# predicate is asserted FROM SESSION-EXPORT EVIDENCE (the opencode SQLite
# session export, the §2 PRIMARY evaluation source), parsed as an ordered
# event stream of a SUPERVISED run within a poll window:
#   - reasoning parts (char counts per poll window)
#   - completed tool calls (goal-relevant progress per poll window)
#   - repeated identical tool inputs (self-correction loops)
#
# EFFICIENCY PREDICATE (the single-assertion target):
#   1. deliberation-loop: large reasoning growth with no corresponding
#      tool-call progress ⇒ efficiency defect marker recorded + routed to
#      the defect notification path (ORCHESTRATOR_DECISION_REQUIRED)
#   2. latency-dominated-progressing: slow wall-clock but growing completed
#      tool calls ⇒ NO marker (discrimination side — latency is not a defect)
#   3. self-correction-loop: repeated identical tool inputs ⇒ marker
#
# SYNTHETIC FIXTURES (NO live model runs — no opencode run, no behavior_run,
# no monitor lifecycle; per the task directive, EVENT-DRIVEN synthetic
# session exports like SC-16/SC-17's fixtures): three synthetic supervised-
# run exports exercise the predicate's polarity:
#   sc20-deliberation-loop        large reasoning growth, zero tool calls    (MARKER)
#   sc20-latency-progressing      slow timestamps, growing completed calls   (NO MARKER)
#   sc20-self-correction-loop     repeated identical tool inputs             (MARKER)
#
# RED condition (expected outcome today): helpers.sh carries NO efficiency-
# marker evaluator — the predicate is unenforced (no mechanical assertion
# exists anywhere in the harness), so every assertion fails ⇒ exit 1 (RED).
# If the evaluator already exists AND distinguishes all three fixtures
# correctly (both looping fixtures produce markers; the progressing fixture
# produces none), the predicate is already enforced by construction →
# ALREADY_GREEN classified abort (exit 3), recorded as the item's genuine
# outcome.
#
# PRECONDITION GUARDS (exit 2 = invalid RED, requires diagnosis — never a
# verdict): the synthetic fixture directory must have been created and all
# three session-export fixtures must parse as JSON with an event table (the
# assertion surface is the fixture set; a missing/unparseable fixture is a
# harness defect, not a RED verdict).
#
# §15 targeted-execution mandate: run this ONE named scenario via
#   bash .opencode/tests-v2/behaviors/2456-sc20-efficiency-marker-red.sh
# (bash tool timeout >= 600000ms). No model dispatch — no live opencode run
# is needed; the efficiency marker is asserted from synthetic session
# exports.
#
# Ordered precondition cycle (§4/SC-16): the scenario file itself is committed
# and pushed to the submodule remote BEFORE this test run (mechanical, no
# deliberation; NEVER --no-verify).
#
# STACKED RULES honored: SAFE CLEANUP (SC-25 — no process kill patterns used
# at all in this scenario); DISPATCH-FAILURE decoupling (R-13 — a failed
# evaluator dispatch is recorded, never classified as its own outcome);
# EVENT-DRIVEN fixtures; HUNG SESSION = CLEAR FAIL (SC-26 — no waits exist;
# the scenario runs synchronously in milliseconds).

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2456-sc20-efficiency-marker-red"

ER="$(cd "$SCRIPT_DIR/../../.." && pwd)/tmp/2456/artifacts"
mkdir -p "$ER"
# Idempotence: clear this test's own stale artifacts.
rm -f "$ER"/pipeline-red-20sc*

FIX_ROOT="$ER/synthetic"
rm -rf "$FIX_ROOT"/sc20-*
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

echo "== SC-20 RED check: efficiency-defect marker at every supervision poll — deliberation loops recorded + notified, latency-progressing runs clean (.opencode#2456) =="

# ══ Synthetic session-export fixtures (EVENT-DRIVEN, deterministic) ══════════
python3 - "$FIX_ROOT" <<'PYEOF'
import json, os, sys

fix_root = sys.argv[1]
AGG = "ses_9f27sc20fixture000000000000000000000"
EPOCH = 1790282476000


def evt(seq, etype, data_obj, ts):
    return {
        "id": f"evt_{AGG[4:12]}{seq:04d}",
        "aggregate_id": AGG,
        "seq": seq,
        "type": etype,
        "data": json.dumps(data_obj),
        "createdAt": ts,
    }


def part_event(seq, ptype, payload, ts):
    part = {
        "id": f"prt_{seq:04d}",
        "sessionID": AGG,
        "messageID": f"msg_{seq:04d}",
        "type": ptype,
    }
    part.update(payload)
    return evt(seq, "message.part.updated.1", {"sessionID": AGG, "part": part}, ts)


def reasoning_part(seq, text, ts):
    return part_event(seq, "reasoning", {"text": text}, ts)


def tool_part(seq, tool, status, input_obj, ts):
    return part_event(seq, "tool", {
        "callID": f"call_{seq:04d}",
        "tool": tool,
        "state": {
            "status": status,
            "input": input_obj,
            "time": {"start": ts, "end": ts + 500},
        },
    }, ts)


def build(name, events):
    d = os.path.join(fix_root, name)
    os.makedirs(d, exist_ok=True)
    export = {
        "source_db": f"{name} (synthetic fixture — no live model run)",
        "harness_version": 1,
        "tables": {"event": {"columns": ["id", "aggregate_id", "seq", "type", "data"], "rows": events}},
    }
    with open(os.path.join(d, "session.yaml"), "w") as f:
        json.dump(export, f, indent=2)


# ── Fixture 1: deliberation-loop — large reasoning growth, zero tool calls ───
# Poll window 1: ~8k reasoning chars, no tool calls. Window 2: ~16k more,
# still no tool calls. Straightforward post-spec/post-plan task.
build("sc20-deliberation-loop", [
    evt(0, "session.created.1", {"sessionID": AGG}, EPOCH),
    reasoning_part(2, "w" * 8000, EPOCH + 1000),
    reasoning_part(4, "w" * 16000, EPOCH + 120000),
    reasoning_part(6, "w" * 20000, EPOCH + 240000),
])

# ── Fixture 2: latency-dominated-progressing — slow, but growing tool calls ──
# Each poll window: small reasoning + a NEW completed tool call. Wall-clock
# gaps are large (slow local model) — NO marker expected.
build("sc20-latency-progressing", [
    evt(0, "session.created.1", {"sessionID": AGG}, EPOCH),
    reasoning_part(2, "thinking about the edit" + "w" * 500, EPOCH + 1000),
    tool_part(4, "read", "completed", {"filePath": "src/a.py"}, EPOCH + 60000),
    reasoning_part(6, "thinking about the next edit" + "w" * 500, EPOCH + 130000),
    tool_part(8, "edit", "completed", {"filePath": "src/a.py"}, EPOCH + 190000),
    reasoning_part(10, "verifying" + "w" * 500, EPOCH + 260000),
    tool_part(12, "bash", "completed", {"command": "uv run pytest test/"}, EPOCH + 320000),
])

# ── Fixture 3: self-correction-loop — repeated identical tool inputs ─────────
build("sc20-self-correction-loop", [
    evt(0, "session.created.1", {"sessionID": AGG}, EPOCH),
    reasoning_part(2, "w" * 3000, EPOCH + 1000),
    tool_part(4, "edit", "completed", {"filePath": "src/b.py", "oldString": "x", "newString": "y"}, EPOCH + 60000),
    reasoning_part(6, "w" * 6000, EPOCH + 130000),
    tool_part(8, "edit", "completed", {"filePath": "src/b.py", "oldString": "x", "newString": "y"}, EPOCH + 190000),
    reasoning_part(10, "w" * 9000, EPOCH + 260000),
    tool_part(12, "edit", "completed", {"filePath": "src/b.py", "oldString": "x", "newString": "y"}, EPOCH + 320000),
])
PYEOF
fixture_rc=$?

# ── Precondition guards: fixtures built and parseable ────────────────────────
if [ "$fixture_rc" -ne 0 ]; then
    echo "PRECONDITION-FAIL: synthetic fixture generation failed (rc=$fixture_rc) — harness defect, not a RED verdict" >&2
    exit 2
fi
FIXTURES="sc20-deliberation-loop sc20-latency-progressing sc20-self-correction-loop"
for fx in $FIXTURES; do
    if ! python3 -c "import json,sys; d=json.load(open('$FIX_ROOT/$fx/session.yaml')); sys.exit(0 if d.get('tables',{}).get('event',{}).get('rows') else 1)" 2>/dev/null; then
        echo "PRECONDITION-FAIL: fixture $FIX_ROOT/$fx/session.yaml missing or unparseable (no event rows) — the session-export assertion surface is absent; not a RED verdict" >&2
        exit 2
    fi
done
echo "  [fixtures] 3 synthetic session exports built under $FIX_ROOT (no live model runs)"

# ══ Assertion 1 — the efficiency-marker evaluator exists in helpers.sh ═══════
# The efficiency-defect predicate needs a mechanical session-export
# assertion surface; today none exists (baseline gap — the R-18 signal-3
# reasoning-size watch lives in the harness monitor, never as a per-poll
# asserted evaluator).
if grep -q '^__assert_efficiency_marker()' "$SCRIPT_DIR/helpers.sh"; then
    check_pass "efficiency-marker evaluator __assert_efficiency_marker defined in helpers.sh"
    EVALUATOR_PRESENT=1
else
    check_fail "efficiency-marker evaluator __assert_efficiency_marker defined in helpers.sh" \
        "no session-export efficiency-marker evaluator exists in helpers.sh — the excessive-deliberation defect marker (recorded + notified at every supervision poll) is UNENFORCED (R-18 signal-3 reasoning-size watch exists in the monitor only, no per-poll efficiency evaluator) (RED)"
    EVALUATOR_PRESENT=0
fi

evaluate_fixture() { # $1 fixture name; sets ev_rc; writes verdict yaml
    local fx="$1"
    local out="$FIX_ROOT/$fx/efficiency-verdict.yaml"
    rm -f "$out"
    if [ "$EVALUATOR_PRESENT" = "1" ] && [ "$(type -t __assert_efficiency_marker)" = function ]; then
        __assert_efficiency_marker "$FIX_ROOT/$fx/session.yaml" "$out"
        ev_rc=$?
    else
        # DISPATCH-FAILURE decoupling (R-13): the missing evaluator is a
        # recorded dispatch failure — never a classification of its own.
        ev_rc=127
        printf 'efficiency_marker: deliberation_to_progress\neverdict: NOT_EVALUABLE\nevaluator: absent (helpers.sh)\nviolations: []\n' > "$out"
    fi
    ev_verdict="$(grep -E '^verdict: ' "$out" 2>/dev/null | head -1 | sed 's/^verdict: //' || true)"
    ev_marker="$(grep -cE 'efficiency.defect|defect_marker|violation' "$out" 2>/dev/null || true)"
    ev_notify="$(grep -cE 'ORCHESTRATOR_DECISION_REQUIRED|notify' "$out" 2>/dev/null || true)"
    return 0
}

# ══ Assertion 2 — deliberation-loop fixture produces the DEFECT marker ═══════
evaluate_fixture sc20-deliberation-loop; f2_rc=$ev_rc; f2_verdict="$ev_verdict"; f2_marker="$ev_marker"; f2_notify="$ev_notify"
if [ "$EVALUATOR_PRESENT" = "1" ] && [ "$f2_rc" -ne 0 ] && [ "$f2_verdict" = "FAIL" ] && [ "${f2_marker:-0}" -ge 1 ] && [ "${f2_notify:-0}" -ge 1 ]; then
    check_pass "deliberation-loop fixture (large reasoning growth, zero tool calls) produces the efficiency DEFECT marker recorded + routed to the defect notification path (rc=$f2_rc)"
else
    check_fail "deliberation-loop fixture produces the efficiency DEFECT marker (recorded + notified)" \
        "evaluator rc=$f2_rc verdict='${f2_verdict:-none}' marker_records=${f2_marker:-0} notify_records=${f2_notify:-0} — excessive deliberation (large reasoning growth without tool-call progress) must be recorded as a defect marker and routed to the defect notification path"
fi

# ══ Assertion 3 — latency-dominated-progressing fixture produces NO marker ═══
evaluate_fixture sc20-latency-progressing; f3_rc=$ev_rc; f3_verdict="$ev_verdict"; f3_marker="$ev_marker"
if [ "$EVALUATOR_PRESENT" = "1" ] && [ "$f3_rc" -eq 0 ] && [ "$f3_verdict" = "PASS" ] && [ "${f3_marker:-0}" -eq 0 ]; then
    check_pass "latency-dominated-progressing fixture (slow wall-clock, growing completed tool calls) produces NO marker (rc=$f3_rc) — raw model latency is not a defect marker (deliberation-to-progress ratio, not wall-clock)"
else
    check_fail "latency-dominated-progressing fixture produces NO marker" \
        "evaluator rc=$f3_rc verdict='${f3_verdict:-none}' marker_records=${f3_marker:-0} — a slow-but-progressing run must NOT carry the defect marker (latency discrimination side of the predicate)"
fi

# ══ Assertion 4 — self-correction-loop fixture produces the DEFECT marker ════
evaluate_fixture sc20-self-correction-loop; f4_rc=$ev_rc; f4_verdict="$ev_verdict"; f4_marker="$ev_marker"; f4_notify="$ev_notify"
if [ "$EVALUATOR_PRESENT" = "1" ] && [ "$f4_rc" -ne 0 ] && [ "$f4_verdict" = "FAIL" ] && [ "${f4_marker:-0}" -ge 1 ] && [ "${f4_notify:-0}" -ge 1 ]; then
    check_pass "self-correction-loop fixture (repeated identical corrections) produces the efficiency DEFECT marker recorded + routed to the defect notification path (rc=$f4_rc)"
else
    check_fail "self-correction-loop fixture produces the efficiency DEFECT marker (recorded + notified)" \
        "evaluator rc=$f4_rc verdict='${f4_verdict:-none}' marker_records=${f4_marker:-0} notify_records=${f4_notify:-0} — repeated self-correction loops must be recorded as a defect marker and routed to the defect notification path"
fi

# ══ Evidence artifact ════════════════════════════════════════════════════════
OUT="$ER/pipeline-red-20sc-sc20-summary.yaml"
{
    echo "== SC-20 RED evidence (.opencode#2456) =="
    echo "test: ${SCENARIO_NAME}"
    echo "sc_ref: SC-20 (phase 6, step 129)"
    echo "evidence_type: behavioral (session-export efficiency-marker assertion; synthetic fixtures per task directive — no live model runs)"
    echo "model_dispatch: none (synthetic session-export fixtures)"
    echo "synthetic_fixtures: $FIX_ROOT/sc20-{deliberation-loop,latency-progressing,self-correction-loop}/session.yaml"
    echo "evaluator_present: $EVALUATOR_PRESENT"
    echo "fixture_eval_rc: deliberation-loop=$f2_rc latency-progressing=$f3_rc self-correction-loop=$f4_rc"
    echo "fixture_verdicts: deliberation-loop='${f2_verdict:-none}' latency-progressing='${f3_verdict:-none}' self-correction-loop='${f4_verdict:-none}'"
    echo "marker_records: deliberation-loop=$f2_marker latency-progressing=$f3_marker self-correction-loop=$f4_marker"
    echo "phase: RED"
    echo "fail_assertions: $FAIL"
    echo "pass_assertions: $PASS"
} > "$OUT" 2>&1

if [ "$FAIL" -eq 0 ]; then
    echo "RED ABORT — ALREADY_GREEN: the efficiency-marker evaluator exists in helpers.sh and distinguishes all three fixtures correctly (deliberation-loop/self-correction-loop fixtures produce recorded+notified DEFECT markers; latency-progressing fixture produces none) — the excessive-deliberation marker predicate is already enforced by construction, so a failing RED test cannot be validly produced" >&2
    {
        echo "verdict: RED_ABORT_ALREADY_GREEN (exit 3) — the efficiency-marker predicate is already enforced; a failing RED test cannot be validly produced"
    } >> "$OUT" 2>&1
    exit 3
fi

{
    echo "verdict: RED (exit 1) — the efficiency-defect marker predicate is ABSENT as an enforced predicate: no session-export efficiency-marker evaluator exists in helpers.sh, so excessive deliberation at supervision polls is recorded and notified nowhere mechanically (R-18 signal-3 reasoning-size watch lives only in the harness monitor)"
    echo "blocker_class: none (red is the expected terminal state; GREEN implementer: step 130 — implement __assert_efficiency_marker <session-export> <verdict-out> in helpers.sh per the contract in this file's header)"
} >> "$OUT" 2>&1

echo "RED CONFIRMED: $FAIL failing assertion(s) — the efficiency-defect marker predicate is ABSENT as an enforced predicate (evaluator_present=$EVALUATOR_PRESENT; fixture verdicts: deliberation-loop='${f2_verdict:-none}' latency-progressing='${f3_verdict:-none}' self-correction-loop='${f4_verdict:-none}'). BASELINE: the R-18 signal-3 reasoning-size watch exists in the harness monitor but no per-poll efficiency-marker evaluator is asserted as a durable function. GATE EXPECTATION FOR GREEN: implement __assert_efficiency_marker <session-export-json> <verdict-yaml-out> in helpers.sh (pure decision function, no model dispatch) — it parses the ordered event stream of a supervised run within a poll window, keys the marker on deliberation-to-progress ratio (large reasoning growth without corresponding completed tool calls, repeated identical tool inputs), records the defect marker in the verdict evidence and routes it to the defect notification path (ORCHESTRATOR_DECISION_REQUIRED), and produces NO marker for latency-dominated but progressing runs; the three synthetic fixtures under $FIX_ROOT/sc20-* are the polarity suite (evidence: $OUT, .opencode#2456 SC-20)." >&2
exit 1

# Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)