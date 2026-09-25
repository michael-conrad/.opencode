#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral test: 2456-sc24-early-termination-red
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# SC-24 (.opencode#2456, phase 6, item SC-24, RED — plan step 149, R-22):
# "Once a scenario's declared verdict surface is decided (RED condition
# confirmed or the assertion satisfied), the supervisor terminates the
# monitored run immediately (kill run + monitor within one poll cycle,
# capture exit/artifact evidence) instead of waiting for natural completion —
# waiting after a decided verdict is prohibited (exception: scenarios whose
# verdict surface itself requires continued running, e.g. continue-past-cap,
# terminate at the surface's own endpoint)."
#
# BASELINE (partial, recorded honestly): .opencode#2441 landed the
# early-termination PRECURSOR in helpers.sh (~line 488 declarations; the
# __semantic_monitor loop already breaks on GREEN-SIGNAL (artifact present +
# goal actions) and HOPELESS-SIGNAL, and practiced live in the 2026-09-24
# evidence run) — but NO durable evaluator asserts the predicate: no
# __assert_early_termination exists anywhere in helpers.sh, so a supervisor
# that decides a verdict and then keeps polling a still-running monitored run
# (the wait-after-decided waste class — verdict decided, run keeps burning
# poll budget, exit/artifact evidence never captured) is UNENFORCED. This
# scenario is that enforcement.
#
# EXERCISE SURFACE — the session-export early-termination evaluator: the
# predicate is asserted FROM SESSION-EXPORT EVIDENCE (the opencode SQLite
# session export, the §2 PRIMARY evaluation source), parsed as an ordered
# event stream of a supervisor session:
#   - POLL <n> records (the monitor poll cadence)
#   - the VERDICT-DECIDED marker (the declared verdict surface fired: a RED
#     condition confirmed or the assertion satisfied)
#   - SURFACE-CONTINUE markers (the exception: the verdict surface itself
#     requires continued running)
#   - the KILL record (run process + monitor terminated) and the
#     EXIT-CAPTURE / ARTIFACT-CAPTURE records (exit status + artifact
#     evidence persisted)
#
# EARLY-TERMINATION PREDICATE (the single-assertion target):
#   1. wait-after-decided: a VERDICT-DECIDED record exists and the monitor
#      polls MORE than one subsequent cycle while the run is still alive
#      (no KILL within one poll cycle) ⇒ FAIL (waiting after a decided
#      verdict is prohibited)
#   2. terminate-on-decided: the KILL fires within one poll cycle after
#      VERDICT-DECIDED and exit/artifact evidence is captured ⇒ PASS
#   3. continue-surface-endpoint: a SURFACE-CONTINUE marker is present (the
#      exception applies); no premature mid-run termination fires and the
#      termination happens at the surface's own endpoint (endpoint record +
#      exit/artifact captured) ⇒ PASS
#
# SYNTHETIC FIXTURES (NO live model runs — no opencode run, no behavior_run,
# no monitor lifecycle; per the task directive, EVENT-DRIVEN synthetic
# session exports like SC-16/SC-21/SC-23's fixtures): three synthetic
# session exports exercise the predicate's polarity:
#   sc24-wait-after-decided        verdict decided, monitor keeps polling a
#                                  still-running run, no kill, no exit/artifact
#                                  capture                            (FAIL)
#   sc24-terminate-on-decided      verdict decided → run+monitor killed within
#                                  one poll cycle, exit/artifact captured (PASS)
#   sc24-continue-surface-endpoint surface requires continued running; no
#                                  mid-run termination; endpoint termination
#                                  with exit/artifact captured          (PASS)
#
# RED condition (expected outcome today): helpers.sh carries NO
# early-termination evaluator — the predicate is unenforced (no
# __assert_early_termination exists anywhere in helpers.sh; the #2441
# GREEN/HOPELESS loop breaks are an unasserted practice), so every
# assertion fails ⇒ exit 1 (RED). If the evaluator already exists AND
# distinguishes all three fixtures correctly (wait-after-decided FAIL;
# terminate-on-decided and continue-surface-endpoint PASS), the predicate is
# already enforced by construction → ALREADY_GREEN classified abort (exit 3),
# recorded as the item's genuine outcome.
#
# PRECONDITION GUARDS (exit 2 = invalid RED, requires diagnosis — never a
# verdict): the synthetic fixture directory must have been created and all
# three session-export fixtures must parse as JSON with an event table (the
# assertion surface is the fixture set; a missing/unparseable fixture is a
# harness defect, not a RED verdict).
#
# §15 targeted-execution mandate: run this ONE named scenario via
#   bash .opencode/tests-v2/behaviors/2456-sc24-early-termination-red.sh
# (bash tool timeout >= 600000ms). No model dispatch — no live opencode run
# is needed; the early-termination predicate is asserted from synthetic
# session exports.
#
# Ordered precondition cycle (§4/SC-16): the scenario file itself is committed
# and pushed to the submodule remote BEFORE this test run (mechanical, no
# deliberation; NEVER --no-verify).
#
# STACKED RULES honored: SAFE CLEANUP (SC-25 — no process kill patterns are
# EXECUTED in this scenario; KILL records are synthetic fixture data inside
# session exports, never actual signals); DISPATCH-FAILURE decoupling (R-13 —
# a failed evaluator dispatch is recorded, never classified as its own
# outcome); EVENT-DRIVEN fixtures; HUNG SESSION = CLEAR FAIL (SC-26 — the
# scenario contains no waits and no live run to hang; the wait-after-decided
# fixture's simulated wait is itself the FAIL polarity).

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2456-sc24-early-termination-red"

ER="$(cd "$SCRIPT_DIR/../../.." && pwd)/tmp/2456/artifacts"
mkdir -p "$ER"
# Idempotence: clear this test's own stale artifacts.
rm -f "$ER"/pipeline-red-24sc*

FIX_ROOT="$ER/synthetic"
rm -rf "$FIX_ROOT"/sc24-*
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

echo "== SC-24 RED check: early-termination predicate — terminate run+monitor within one poll cycle of a decided verdict, capture exit/artifact evidence (.opencode#2456) =="

# ══ Synthetic session-export fixtures (EVENT-DRIVEN, deterministic) ══════════
python3 - "$FIX_ROOT" <<'PYEOF'
import json, os, sys

fix_root = sys.argv[1]
AGG = "ses_0d51sc24fixture000000000000000000000"
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

def reasoning_part(seq, text):
    return part_event(seq, "reasoning", {"text": text})

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

PROMPT = '"You are a sub-agent. Execute the RED task: author the early-termination enforcement scenario, commit+push it, then run it per the §4 ordered cycle."'

# Monitor-record commands (synthetic representations of the supervisor's
# poll-log lifecycle inside the session export):
POLL = "POLL {n} ts={ts} ev=12 tools=3 completed=2 run_alive=1"
DECIDED = "VERDICT-DECIDED: RED condition confirmed — assertion satisfied, verdict decided"
CONTINUE = "SURFACE-CONTINUE: continue-past-cap — verdict surface requires continued running; no termination until the surface's own endpoint"
KILL = "KILL: run pid 4242 terminated + monitor terminated (within one poll cycle of VERDICT-DECIDED)"
EXIT = "EXIT-CAPTURE: run exit status 143 recorded (monitor-initiated termination)"
ARTIFACT = "ARTIFACT-CAPTURE: session.yaml + monitor.log persisted to scenario evidence dir"
ENDPOINT = "SURFACE-ENDPOINT: continue-past-cap budget cap reached — the verdict surface's own endpoint; terminating now"
KILL_NAT = "KILL: run pid 5151 terminated + monitor terminated (at surface endpoint, no premature termination fired)"
EXIT_NAT = "EXIT-CAPTURE: run exit status 0 recorded (natural completion at surface endpoint)"
ARTIFACT_NAT = "ARTIFACT-CAPTURE: session.yaml + monitor.log persisted to scenario evidence dir"

def polls(start_seq, n, first_num):
    out = []
    for i in range(n):
        out.append(bash(start_seq + i * 2, POLL.format(n=first_num + i, ts=EPOCH + (first_num + i) * 30000)))
    return out

# ── Fixture 1: wait-after-decided — verdict decided, monitor keeps polling,
#    run still alive across multiple subsequent cycles, no kill, no capture ──
build("sc24-wait-after-decided", [
    evt(0, "session.created.1", {"sessionID": AGG}),
    text_part(2, PROMPT),
    *polls(4, 2, 1),
    bash(8, DECIDED),
    # The defect: polling continues for 3 more cycles with the run alive —
    # no KILL within one poll cycle, no exit/artifact capture.
    *polls(10, 3, 2),
])

# ── Fixture 2: terminate-on-decided — verdict decided at poll N; run+monitor
#    killed within one poll cycle; exit + artifact evidence captured ─────────
build("sc24-terminate-on-decided", [
    evt(0, "session.created.1", {"sessionID": AGG}),
    text_part(2, PROMPT),
    *polls(4, 2, 1),
    bash(8, DECIDED),
    bash(10, KILL),
    bash(12, EXIT),
    bash(14, ARTIFACT),
])

# ── Fixture 3: continue-surface-endpoint — the exception: the verdict surface
#    itself requires continued running; no premature mid-run termination; the
#    termination happens at the surface's own endpoint with capture ──────────
build("sc24-continue-surface-endpoint", [
    evt(0, "session.created.1", {"sessionID": AGG}),
    text_part(2, PROMPT),
    *polls(4, 2, 1),
    bash(8, CONTINUE),
    *polls(10, 2, 2),
    bash(14, ENDPOINT),
    bash(16, KILL_NAT),
    bash(18, EXIT_NAT),
    bash(20, ARTIFACT_NAT),
])
PYEOF
fixture_rc=$?

# ── Precondition guards: fixtures built and parseable ────────────────────────
if [ "$fixture_rc" -ne 0 ]; then
    echo "PRECONDITION-FAIL: synthetic fixture generation failed (rc=$fixture_rc) — harness defect, not a RED verdict" >&2
    exit 2
fi
FIXTURES="sc24-wait-after-decided sc24-terminate-on-decided sc24-continue-surface-endpoint"
for fx in $FIXTURES; do
    if ! python3 -c "import json,sys; d=json.load(open('$FIX_ROOT/$fx/session.yaml')); sys.exit(0 if d.get('tables',{}).get('event',{}).get('rows') else 1)" 2>/dev/null; then
        echo "PRECONDITION-FAIL: fixture $FIX_ROOT/$fx/session.yaml missing or unparseable (no event rows) — the session-export assertion surface is absent; not a RED verdict" >&2
        exit 2
    fi
done
echo "  [fixtures] 3 synthetic session exports built under $FIX_ROOT (no live model runs)"

# ══ Assertion 1 — the early-termination evaluator exists in helpers.sh ═══════
# The #2441 precursor (GREEN-SIGNAL / HOPELESS-SIGNAL loop breaks) decided
# verdicts in practice, but no durable session-export evaluator asserts the
# terminate-within-one-poll-cycle predicate.
if grep -q '^__assert_early_termination()' "$SCRIPT_DIR/helpers.sh"; then
    check_pass "early-termination evaluator __assert_early_termination defined in helpers.sh"
    EVALUATOR_PRESENT=1
else
    check_fail "early-termination evaluator __assert_early_termination defined in helpers.sh" \
        "no session-export early-termination evaluator exists in helpers.sh — the terminate-within-one-poll-cycle predicate is UNENFORCED (the #2441 GREEN/HOPELESS loop breaks are an unasserted practice) (RED)"
    EVALUATOR_PRESENT=0
fi

evaluate_fixture() { # $1 fixture name; sets ev_rc; writes verdict yaml
    local fx="$1"
    local out="$FIX_ROOT/$fx/termination-verdict.yaml"
    rm -f "$out"
    if [ "$EVALUATOR_PRESENT" = "1" ] && [ "$(type -t __assert_early_termination)" = function ]; then
        __assert_early_termination "$FIX_ROOT/$fx/session.yaml" "$out"
        ev_rc=$?
    else
        ev_rc=127
        printf 'termination_assertion: terminate_within_one_poll_cycle_of_decided_verdict\neverdict: NOT_EVALUABLE\nevaluator: absent (helpers.sh)\n' > "$out"
    fi
    ev_verdict="$(grep -E '^verdict: ' "$out" 2>/dev/null | head -1 | sed 's/^verdict: //' || true)"
    return 0
}

# ══ Assertion 2 — wait-after-decided fixture evaluates FAIL ══════════════════
evaluate_fixture sc24-wait-after-decided; f2_rc=$ev_rc; f2_verdict="$ev_verdict"
f2_wait="$(grep -cE 'wait|post_decision_poll|violation' "$FIX_ROOT/sc24-wait-after-decided/termination-verdict.yaml" 2>/dev/null || true)"
if [ "$EVALUATOR_PRESENT" = "1" ] && [ "$f2_rc" -ne 0 ] && [ "$f2_verdict" = "FAIL" ] && [ "${f2_wait:-0}" -ge 1 ]; then
    check_pass "wait-after-decided fixture evaluates FAIL (rc=$f2_rc) with the post-decision wait recorded — waiting after a decided verdict is prohibited"
else
    check_fail "wait-after-decided fixture evaluates FAIL with the post-decision wait recorded" \
        "evaluator rc=$f2_rc verdict='${f2_verdict:-none}' wait_records=${f2_wait:-0} — a monitor that keeps polling after a decided verdict must fail the early-termination assertion and be recorded"
fi

# ══ Assertion 3 — terminate-on-decided fixture evaluates PASS ════════════════
evaluate_fixture sc24-terminate-on-decided; f3_rc=$ev_rc; f3_verdict="$ev_verdict"
if [ "$f3_rc" -eq 0 ] && [ "$f3_verdict" = "PASS" ]; then
    check_pass "terminate-on-decided fixture (verdict decided → kill within one poll cycle + exit/artifact captured) evaluates PASS (rc=$f3_rc)"
else
    check_fail "terminate-on-decided fixture (verdict decided → kill within one poll cycle + exit/artifact captured) evaluates PASS" \
        "evaluator rc=$f3_rc verdict='${f3_verdict:-none}' — an immediate termination with captured exit/artifact evidence must pass the early-termination assertion"
fi

# ══ Assertion 4 — continue-surface-endpoint fixture evaluates PASS ═══════════
evaluate_fixture sc24-continue-surface-endpoint; f4_rc=$ev_rc; f4_verdict="$ev_verdict"
if [ "$f4_rc" -eq 0 ] && [ "$f4_verdict" = "PASS" ]; then
    check_pass "continue-surface-endpoint fixture (surface requires continued running; termination at the surface's own endpoint) evaluates PASS (rc=$f4_rc)"
else
    check_fail "continue-surface-endpoint fixture (surface requires continued running; termination at the surface's own endpoint) evaluates PASS" \
        "evaluator rc=$f4_rc verdict='${f4_verdict:-none}' — a verdict surface that itself requires continued running must terminate at its own endpoint and pass the assertion"
fi

# ══ Evidence artifact ════════════════════════════════════════════════════════
OUT="$ER/pipeline-red-24sc-sc24-summary.yaml"
{
    echo "== SC-24 RED evidence (.opencode#2456) =="
    echo "test: ${SCENARIO_NAME}"
    echo "sc_ref: SC-24 (plan-06 phase 6, item SC-24, step 149)"
    echo "evidence_type: behavioral (session-export early-termination assertion; synthetic fixtures per task directive — no live model runs)"
    echo "model_dispatch: none (synthetic session-export fixtures)"
    echo "synthetic_fixtures: $FIX_ROOT/sc24-{wait-after-decided,terminate-on-decided,continue-surface-endpoint}/session.yaml"
    echo "baseline: PARTIAL (#2441 early-termination precursor in helpers.sh ~:488; practiced live; no durable evaluator)"
    echo "evaluator_present: $EVALUATOR_PRESENT"
    echo "fixture_eval_rc: wait-after-decided=$f2_rc terminate-on-decided=$f3_rc continue-surface-endpoint=$f4_rc"
    echo "fixture_verdicts: wait-after-decided='${f2_verdict:-none}' terminate-on-decided='${f3_verdict:-none}' continue-surface-endpoint='${f4_verdict:-none}'"
    echo "phase: RED"
    echo "fail_assertions: $FAIL"
    echo "pass_assertions: $PASS"
} > "$OUT" 2>&1

if [ "$FAIL" -eq 0 ]; then
    echo "RED ABORT — ALREADY_GREEN: the early-termination evaluator exists in helpers.sh and distinguishes all three fixtures correctly (wait-after-decided FAIL; terminate-on-decided and continue-surface-endpoint PASS) — the terminate-within-one-poll-cycle predicate is already enforced by construction, so a failing RED test cannot be validly produced" >&2
    {
        echo "verdict: RED_ABORT_ALREADY_GREEN (exit 3) — the early-termination predicate is already enforced; a failing RED test cannot be validly produced"
    } >> "$OUT" 2>&1
    exit 3
fi

{
    echo "verdict: RED (exit 1) — the terminate-within-one-poll-cycle predicate is ABSENT as an enforced predicate: no session-export early-termination evaluator exists in helpers.sh, so a decided verdict followed by continued polling is asserted nowhere mechanically"
    echo "blocker_class: none (red is the expected terminal state; GREEN implementer: next phase-6 step — implement __assert_early_termination <session-export> <verdict-out> in helpers.sh per the contract in this file's header)"
} >> "$OUT" 2>&1

echo "RED CONFIRMED: $FAIL failing assertion(s) — the early-termination predicate is ABSENT as an enforced predicate (evaluator_present=$EVALUATOR_PRESENT; fixture verdicts: wait-after-decided='${f2_verdict:-none}' terminate-on-decided='${f3_verdict:-none}' continue-surface-endpoint='${f4_verdict:-none}'). The #2441 precursor (GREEN/HOPELESS loop breaks, ~helpers.sh:488) decided verdicts in practice but no durable evaluator asserts termination within one poll cycle with exit/artifact capture. GATE EXPECTATION FOR GREEN: implement __assert_early_termination <session-export-json> <verdict-yaml-out> in helpers.sh (pure decision function, no model dispatch) — it parses the ordered event stream, locates the first VERDICT-DECIDED record, requires the KILL record (run + monitor) within one subsequent POLL cycle with EXIT-CAPTURE and ARTIFACT-CAPTURE records present; when a SURFACE-CONTINUE marker is present the exception applies — no premature mid-run termination and termination at the surface's own endpoint (SURFACE-ENDPOINT + KILL + captures); emits verdict: PASS|FAIL with violations[] and post_decision_polls[]; the three synthetic fixtures under $FIX_ROOT/sc24-* are the polarity suite (evidence: $OUT, .opencode#2456 SC-24)." >&2
exit 1

# Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)