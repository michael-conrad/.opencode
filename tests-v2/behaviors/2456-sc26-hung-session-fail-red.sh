#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral test: 2456-sc26-hung-session-fail-red
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# SC-26 (.opencode#2456, phase 6, item SC-26, RED — plan step 159):
# "a hung session is a CLEAR FAIL — no events/output growth across a bounded
# watch window (default 2 consecutive supervision polls beyond the first
# stall-observation poll, no provider-error explanation recorded) ⇒ verdict
# FAILED(stall) with root-cause provider-stream-hung recorded, run + monitor
# terminated within one poll cycle, fresh-dispatch remediation via the SC-21
# orchestrator flow; 'letting it proceed' / open-ended wait-on-hang is
# prohibited."
#
# BASELINE (recorded honestly): ABSENT as an enforced predicate — hung
# sessions are handled live in practice (after the 2026-09-24 self-kill
# incident the supervisor kills hung runs), but NO durable evaluator asserts
# the predicate: no __assert_hung_session_fail exists anywhere in helpers.sh,
# so a supervisor that observes a stall and then keeps polling an event-dead
# session forever (open-ended wait-on-hang) with no FAILED(stall) verdict, no
# termination, and no provider-stream-hung root-cause record is UNENFORCED.
# This scenario is that enforcement.
#
# EXERCISE SURFACE — the session-export hung-session evaluator: the predicate
# is asserted FROM SESSION-EXPORT EVIDENCE (the opencode SQLite session
# export, the §2 PRIMARY evaluation source), parsed as an ordered event
# stream of a supervisor session's supervision activity:
#   - STALL-OBSERVED record (first poll at which no event/output growth is
#     seen in the watched run)
#   - supervision POLL records (subsequent polls; each shows whether the
#     watched run's event stream grew since the previous poll)
#   - PROVIDER-ERROR-EXPLANATION record (a recorded explanation that
#     re-frames the stall as a provider-side error — the only condition that
#     widens the watch window)
#   - FAILED(stall) verdict record with root-cause provider-stream-hung
#   - TERMINATE record (run + monitor killed within one poll cycle of the
#     verdict)
#   - FRESH-DISPATCH remediation record (SC-21 orchestrator flow)
#
# HUNG-SESSION PREDICATE (the single-assertion target):
#   1. wait-on-hang: STALL-OBSERVED recorded, >=3 supervision polls pass with
#      no event/output growth, no provider-error explanation recorded, and
#      the supervisor keeps polling with no FAILED(stall) verdict and no
#      termination ⇒ FAIL (open-ended wait-on-hang — the prohibited class)
#   2. failed-at-bound: STALL-OBSERVED, 2 polls no growth within the bounded
#      window, FAILED(stall) verdict with root_cause=provider-stream-hung,
#      run + monitor terminated within one poll cycle of the verdict,
#      FRESH-DISPATCH recorded ⇒ PASS
#   3. recovered-before-bound: STALL-OBSERVED but event/output growth
#      resumes within the watch window before the bound trips ⇒ PASS (no
#      FAIL verdict; supervision continues)
#
# SYNTHETIC FIXTURES (NO live model runs — no opencode run, no behavior_run,
# no monitor lifecycle; per the task directive, EVENT-DRIVEN synthetic
# session exports like SC-24/SC-23's fixtures): three synthetic session
# exports exercise the predicate's polarity:
#   sc26-wait-on-hang             stall observed, 3+ polls no growth,
#                                 supervisor keeps polling — no verdict,
#                                 no kill                            (FAIL)
#   sc26-failed-at-bound          stall observed, 2 polls no growth,
#                                 FAILED(stall) verdict +
#                                 provider-stream-hung root cause +
#                                 termination within one poll cycle +
#                                 fresh dispatch                     (PASS)
#   sc26-recovered-before-bound   stall observed but growth resumes
#                                 within the window — no FAIL,
#                                 supervision continues              (PASS)
#
# RED condition (expected outcome today): helpers.sh carries NO hung-session
# evaluator — the predicate is unenforced (no __assert_hung_session_fail
# exists anywhere in helpers.sh), so every assertion fails ⇒ exit 1 (RED).
# If the evaluator already exists AND distinguishes all three fixtures
# correctly (wait-on-hang FAIL; failed-at-bound PASS;
# recovered-before-bound PASS), the predicate is already enforced by
# construction → ALREADY_GREEN classified abort (exit 3), recorded as the
# item's genuine outcome.
#
# PRECONDITION GUARDS (exit 2 = invalid RED, requires diagnosis — never a
# verdict): the synthetic fixture directory must have been created and all
# three session-export fixtures must parse as JSON with an event table (the
# assertion surface is the fixture set; a missing/unparseable fixture is a
# harness defect, not a RED verdict).
#
# §15 targeted-execution mandate: run this ONE named scenario via
#   bash .opencode/tests-v2/behaviors/2456-sc26-hung-session-fail-red.sh
# (bash tool timeout >= 600000ms). No model dispatch — no live opencode run
# is needed; the hung-session predicate is asserted from synthetic session
# exports.
#
# Ordered precondition cycle (§4/SC-16): the scenario file itself is committed
# and pushed to the submodule remote BEFORE this test run (mechanical, no
# deliberation; NEVER --no-verify).
#
# STACKED RULES honored: SAFE CLEANUP (SC-25 — this scenario EXECUTES no
# process kill patterns; TERMINATE records are synthetic fixture data inside
# session exports, never actual signals; no pkill/grep touches the live
# process table); DISPATCH-FAILURE decoupling (R-13 — a failed evaluator
# dispatch is recorded as NOT_EVALUABLE, never classified as its own
# outcome); EVENT-DRIVEN fixtures (session-export event streams, no
# activity/uptime proxies); HUNG SESSION = CLEAR FAIL (SC-26 — the predicate
# under test: the wait-on-hang fixture's simulated open-ended wait-on-hang is
# itself the FAIL polarity; this scenario contains no waits and no live run
# to hang).

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2456-sc26-hung-session-fail-red"

ER="$(cd "$SCRIPT_DIR/../../.." && pwd)/tmp/2456/artifacts"
mkdir -p "$ER"
# Idempotence: clear this test's own stale artifacts.
rm -f "$ER"/pipeline-red-26sc*

FIX_ROOT="$ER/synthetic"
rm -rf "$FIX_ROOT"/sc26-*
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

echo "== SC-26 RED check: hung-session predicate — no-growth stall across the bounded watch window ⇒ FAILED(stall) verdict with provider-stream-hung root cause + termination within one poll cycle + fresh dispatch; open-ended wait-on-hang prohibited (.opencode#2456) =="

# ══ Synthetic session-export fixtures (EVENT-DRIVEN, deterministic) ══════════
python3 - "$FIX_ROOT" <<'PYEOF'
import json, os, sys

fix_root = sys.argv[1]
AGG = "ses_0d51sc26fixture000000000000000000000"
EPOCH = 1790282476000

def evt(seq, etype, data_obj):
    return {
        "id": f"evt_{AGG[4:12]}{seq:04d}",
        "aggregate_id": AGG,
        "seq": seq,
        "type": etype,
        "data": json.dumps(data_obj),
    }

def part_event(seq, ptype, payload):
    part = {
        "id": f"prt_{seq:04d}",
        "sessionID": AGG,
        "messageID": f"msg_{seq:04d}",
        "type": ptype,
    }
    part.update(payload)
    return evt(seq, "message.part.updated.1", {"sessionID": AGG, "part": part})

def text_part(seq, text):
    return part_event(seq, "text", {"text": text})

def tool_part(seq, tool, status, input_obj):
    return part_event(seq, "tool", {
        "callID": f"call_{seq:04d}",
        "tool": tool,
        "state": {
            "status": status,
            "input": input_obj,
            "time": {"start": EPOCH + seq * 1000, "end": EPOCH + seq * 1000 + 500},
        },
    })

def bash(seq, command):
    return tool_part(seq, "bash", "completed", {"command": command})

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

PROMPT = '"You are a sub-agent. Execute the RED task: author the hung-session enforcement scenario, commit+push it, then run it per the §4 ordered cycle."'

# Synthetic supervision-lifecycle records (representations of the supervisor's
# hung-session handling inside the session export):
STALL = "STALL-OBSERVED: watch window opened — watched run event stream flat since poll 1 (no events, no output growth)"
POLL_STALL = "POLL: poll N — watched run event stream unchanged (no growth)"
POLL_GROW = "POLL: poll N — watched run event stream GREW (+2 events: bash tool call completed) since previous poll"
PROVIDER_EXPL = "PROVIDER-ERROR-EXPLANATION: stall attributed to provider stream error (window widened by recorded explanation)"
FAILED_VERDICT = "VERDICT: FAILED(stall) — root_cause=provider-stream-hung (no event/output growth across the bounded watch window: 2 consecutive polls beyond first stall-observation poll, no provider-error explanation)"
TERMINATE = "TERMINATE: run process + monitor terminated within one poll cycle of the FAILED(stall) verdict (KILL targets by scenario marker; own PID excluded per SC-25)"
FRESH_DISPATCH = "FRESH-DISPATCH: fresh-dispatch remediation via SC-21 orchestrator flow (new clean-room dispatch for the scenario)"

# ── Fixture 1: wait-on-hang — stall observed, 3+ polls with no growth, and
#    the supervisor keeps polling: no FAILED(stall) verdict, no termination,
#    no provider-error explanation, no fresh dispatch (open-ended
#    wait-on-hang — the prohibited class) ──────────────────────────────────
build("sc26-wait-on-hang", [
    evt(0, "session.created.1", {"sessionID": AGG}),
    text_part(2, PROMPT),
    bash(4, STALL),
    bash(6, POLL_STALL),
    bash(8, POLL_STALL),
    bash(10, POLL_STALL),
])

# ── Fixture 2: failed-at-bound — stall observed, 2 polls no growth within
#    the bounded window, FAILED(stall) verdict with provider-stream-hung
#    root cause, run + monitor terminated within one poll cycle, fresh
#    dispatch recorded ─────────────────────────────────────────────────────
build("sc26-failed-at-bound", [
    evt(0, "session.created.1", {"sessionID": AGG}),
    text_part(2, PROMPT),
    bash(4, STALL),
    bash(6, POLL_STALL),
    bash(8, POLL_STALL),
    bash(10, FAILED_VERDICT),
    bash(12, TERMINATE),
    bash(14, FRESH_DISPATCH),
])

# ── Fixture 3: recovered-before-bound — stall observed but event/output
#    growth resumes within the watch window before the bound trips; no FAIL
#    verdict; supervision continues ────────────────────────────────────────
build("sc26-recovered-before-bound", [
    evt(0, "session.created.1", {"sessionID": AGG}),
    text_part(2, PROMPT),
    bash(4, STALL),
    bash(6, POLL_STALL),
    bash(8, POLL_GROW),
    bash(10, "POLL: poll 4 — watched run progressing (growth confirmed across polls) — supervision continues, no stall verdict"),
])
PYEOF
fixture_rc=$?

# ── Precondition guards: fixtures built and parseable ────────────────────────
if [ "$fixture_rc" -ne 0 ]; then
    echo "PRECONDITION-FAIL: synthetic fixture generation failed (rc=$fixture_rc) — harness defect, not a RED verdict" >&2
    exit 2
fi
FIXTURES="sc26-wait-on-hang sc26-failed-at-bound sc26-recovered-before-bound"
for fx in $FIXTURES; do
    if ! python3 -c "import json,sys; d=json.load(open('$FIX_ROOT/$fx/session.yaml')); sys.exit(0 if d.get('tables',{}).get('event',{}).get('rows') else 1)" 2>/dev/null; then
        echo "PRECONDITION-FAIL: fixture $FIX_ROOT/$fx/session.yaml missing or unparseable (no event rows) — the session-export assertion surface is absent; not a RED verdict" >&2
        exit 2
    fi
done
echo "  [fixtures] 3 synthetic session exports built under $FIX_ROOT (no live model runs)"

# ══ Assertion 1 — the hung-session evaluator exists in helpers.sh ════════════
# Hung sessions are handled live in practice, but no durable session-export
# evaluator asserts the bounded-window FAILED(stall) predicate.
if grep -q '^__assert_hung_session_fail()' "$SCRIPT_DIR/helpers.sh"; then
    check_pass "hung-session evaluator __assert_hung_session_fail defined in helpers.sh"
    EVALUATOR_PRESENT=1
else
    check_fail "hung-session evaluator __assert_hung_session_fail defined in helpers.sh" \
        "no session-export hung-session evaluator exists in helpers.sh — the bounded-watch-window predicate (2 consecutive no-growth polls beyond the first stall-observation poll with no provider-error explanation ⇒ FAILED(stall) + provider-stream-hung root cause + termination within one poll cycle + fresh dispatch; open-ended wait-on-hang prohibited) is UNENFORCED (RED)"
    EVALUATOR_PRESENT=0
fi

evaluate_fixture() { # $1 fixture name; sets ev_rc; writes verdict yaml
    local fx="$1"
    local out="$FIX_ROOT/$fx/hung-verdict.yaml"
    rm -f "$out"
    if [ "$EVALUATOR_PRESENT" = "1" ] && [ "$(type -t __assert_hung_session_fail)" = function ]; then
        __assert_hung_session_fail "$FIX_ROOT/$fx/session.yaml" "$out"
        ev_rc=$?
    else
        ev_rc=127
        printf 'hung_session_assertion: bounded_watch_window_failed_stall_verdict\neverdict: NOT_EVALUABLE\nevaluator: absent (helpers.sh)\n' > "$out"
    fi
    ev_verdict="$(grep -E '^verdict: ' "$out" 2>/dev/null | head -1 | sed 's/^verdict: //' || true)"
    return 0
}

# ══ Assertion 2 — wait-on-hang fixture evaluates FAIL ════════════════════════
evaluate_fixture sc26-wait-on-hang; f2_rc=$ev_rc; f2_verdict="$ev_verdict"
f2_viol="$(grep -cE 'violation|wait.on.hang|open.ended|no.verdict|stall' "$FIX_ROOT/sc26-wait-on-hang/hung-verdict.yaml" 2>/dev/null || true)"
if [ "$EVALUATOR_PRESENT" = "1" ] && [ "$f2_rc" -ne 0 ] && [ "$f2_verdict" = "FAIL" ] && [ "${f2_viol:-0}" -ge 1 ]; then
    check_pass "wait-on-hang fixture evaluates FAIL (rc=$f2_rc) with the open-ended wait-on-hang violation recorded — stall observed, 3+ polls no growth, supervisor kept polling with no FAILED(stall) verdict"
else
    check_fail "wait-on-hang fixture evaluates FAIL with the open-ended wait-on-hang violation recorded" \
        "evaluator rc=$f2_rc verdict='${f2_verdict:-none}' violation_records=${f2_viol:-0} — a supervisor that observes a stall and keeps polling a no-growth session beyond the bounded window (3+ polls, no provider-error explanation, no FAILED(stall) verdict, no termination) must fail the hung-session assertion and be recorded"
fi

# ══ Assertion 3 — failed-at-bound fixture evaluates PASS ═════════════════════
evaluate_fixture sc26-failed-at-bound; f3_rc=$ev_rc; f3_verdict="$ev_verdict"
f3_cause="$(grep -cE 'provider-stream-hung|FAILED.stall' "$FIX_ROOT/sc26-failed-at-bound/hung-verdict.yaml" 2>/dev/null || true)"
if [ "$f3_rc" -eq 0 ] && [ "$f3_verdict" = "PASS" ]; then
    check_pass "failed-at-bound fixture (stall observed → 2 polls no growth → FAILED(stall) verdict + provider-stream-hung root cause + termination within one poll cycle + fresh dispatch) evaluates PASS (rc=$f3_rc)"
else
    check_fail "failed-at-bound fixture (stall observed → 2 polls no growth → FAILED(stall) verdict + termination within one poll cycle + fresh dispatch) evaluates PASS" \
        "evaluator rc=$f3_rc verdict='${f3_verdict:-none}' cause_records=${f3_cause:-0} — a bounded-window FAILED(stall) verdict with provider-stream-hung root cause, one-poll-cycle termination, and fresh-dispatch remediation must pass the hung-session assertion"
fi

# ══ Assertion 4 — recovered-before-bound fixture evaluates PASS ══════════════
evaluate_fixture sc26-recovered-before-bound; f4_rc=$ev_rc; f4_verdict="$ev_verdict"
f4_stall="$(grep -cE 'stall|FAIL' "$FIX_ROOT/sc26-recovered-before-bound/hung-verdict.yaml" 2>/dev/null || true)"
if [ "$f4_rc" -eq 0 ] && [ "$f4_verdict" = "PASS" ] && [ "${f4_stall:-0}" -eq 0 ]; then
    check_pass "recovered-before-bound fixture (stall observed but growth resumes within the watch window — no FAILED(stall) verdict, supervision continues) evaluates PASS with no stall FAIL recorded (rc=$f4_rc)"
else
    check_fail "recovered-before-bound fixture evaluates PASS with no stall FAIL recorded" \
        "evaluator rc=$f4_rc verdict='${f4_verdict:-none}' stall_records=${f4_stall:-0} — event/output growth resuming within the bounded watch window must NOT yield a FAILED(stall) verdict; supervision continues"
fi

# ══ Evidence artifact ════════════════════════════════════════════════════════
OUT="$ER/pipeline-red-26sc-sc26-summary.yaml"
{
    echo "== SC-26 RED evidence (.opencode#2456) =="
    echo "test: ${SCENARIO_NAME}"
    echo "sc_ref: SC-26 (plan-06 phase 6, item SC-26, step 159)"
    echo "evidence_type: behavioral (session-export hung-session assertion; synthetic fixtures per task directive — no live model runs)"
    echo "model_dispatch: none (synthetic session-export fixtures)"
    echo "synthetic_fixtures: $FIX_ROOT/sc26-{wait-on-hang,failed-at-bound,recovered-before-bound}/session.yaml"
    echo "baseline: ABSENT as an enforced predicate (handled live in practice; no durable evaluator)"
    echo "evaluator_present: $EVALUATOR_PRESENT"
    echo "fixture_eval_rc: wait-on-hang=$f2_rc failed-at-bound=$f3_rc recovered-before-bound=$f4_rc"
    echo "fixture_verdicts: wait-on-hang='${f2_verdict:-none}' failed-at-bound='${f3_verdict:-none}' recovered-before-bound='${f4_verdict:-none}'"
    echo "phase: RED"
    echo "fail_assertions: $FAIL"
    echo "pass_assertions: $PASS"
} > "$OUT" 2>&1

if [ "$FAIL" -eq 0 ]; then
    echo "RED ABORT — ALREADY_GREEN: the hung-session evaluator exists in helpers.sh and distinguishes all three fixtures correctly (wait-on-hang FAIL; failed-at-bound PASS; recovered-before-bound PASS) — the bounded-watch-window FAILED(stall) predicate is already enforced by construction, so a failing RED test cannot be validly produced" >&2
    {
        echo "verdict: RED_ABORT_ALREADY_GREEN (exit 3) — the hung-session predicate is already enforced; a failing RED test cannot be validly produced"
    } >> "$OUT" 2>&1
    exit 3
fi

{
    echo "verdict: RED (exit 1) — the hung-session predicate is ABSENT as an enforced predicate: no session-export hung-session evaluator exists in helpers.sh, so an open-ended wait-on-hang (stall observed, 3+ polls no growth, supervisor keeps polling, no FAILED(stall) verdict, no termination, no provider-stream-hung root cause) is asserted nowhere mechanically"
    echo "blocker_class: none (red is the expected terminal state; GREEN implementer: next phase-6 step — implement __assert_hung_session_fail <session-export> <verdict-out> in helpers.sh per the contract in this file's header)"
} >> "$OUT" 2>&1

echo "RED CONFIRMED: $FAIL failing assertion(s) — the hung-session predicate is ABSENT as an enforced predicate (evaluator_present=$EVALUATOR_PRESENT; fixture verdicts: wait-on-hang='${f2_verdict:-none}' failed-at-bound='${f3_verdict:-none}' recovered-before-bound='${f4_verdict:-none}'). Hung sessions are handled live in practice, but no durable evaluator asserts the predicate. GATE EXPECTATION FOR GREEN: implement __assert_hung_session_fail <session-export-json> <verdict-yaml-out> in helpers.sh (pure decision function, no model dispatch) — it parses the ordered event stream for STALL-OBSERVED + supervision POLL records and requires: (a) on stall observation with NO event/output growth across the bounded watch window (default 2 consecutive supervision polls beyond the first stall-observation poll) and NO provider-error explanation recorded, a VERDICT: FAILED(stall) record with root_cause=provider-stream-hung MUST appear — a supervisor that keeps polling past the bound with no verdict is a FAIL violation (open-ended wait-on-hang prohibited); (b) a TERMINATE record (run + monitor killed within one poll cycle of the verdict); (c) a FRESH-DISPATCH remediation record (SC-21 orchestrator flow); (d) growth resuming within the window (recovered-before-bound) yields NO stall FAIL — supervision continues. Emits verdict: PASS|FAIL with violations[] and stall_records[]; the three synthetic fixtures under $FIX_ROOT/sc26-* are the polarity suite (evidence: $OUT, .opencode#2456 SC-26)." >&2
exit 1

# Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)