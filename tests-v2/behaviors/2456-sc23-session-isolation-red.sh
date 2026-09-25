#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral test: 2456-sc23-session-isolation-red
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# SC-23 (.opencode#2456, phase 6, item SC-23, RED — plan step 144, R-22):
# "Each monitored fixture run starts from a FRESH test home and a fresh
# session — reuse of a prior attempt's test home or session DB is prohibited;
# foreign instructions from earlier sessions must never appear in a monitored
# run's context."
#
# BASELINE (absent — recorded honestly): the PRESENT machinery already
# provisions timestamped fresh homes per invocation (with-test-home
# test-home-<timestamp>; fresh invocations never reuse) and the live
# 2026-09-24 evidence run validated 0 foreign instructions in the monitored
# run's session DB — but NO durable evaluator/scenario asserts it: no
# __assert_session_isolation exists anywhere in helpers.sh, so home/session
# reuse (the live 2026-09-23 defect shape: a prior session's user turns —
# fix-2098 copy task, 2456-sc9/sc10 marker-verification prompts — injected
# into the run's context by test-home reuse, pivoting the run mid-loop to
# foreign instructions) is UNENFORCED. This scenario is that enforcement.
#
# EXERCISE SURFACE — the session-export session-isolation evaluator: the
# predicate is asserted FROM SESSION-EXPORT EVIDENCE (the opencode SQLite
# session export, the §2 PRIMARY evaluation source), parsed as an ordered
# event stream of a monitored fixture run's session:
#   - session id uniqueness (a single session; no prior session ids)
#   - prior-session content scan (no foreign task instructions / user turns
#     from earlier sessions in the run's context)
#
# SESSION-ISOLATION PREDICATE (the single-assertion target):
#   1. reused-home: the run's session export contains prior-session
#      messages / foreign task instructions from an earlier session
#      (multiple session ids, or foreign task-instruction user turns)
#      ⇒ FAIL (isolation violated — the run's evidence is not
#      self-contained)
#   2. fresh-session: a single fresh session id, zero prior-session
#      content ⇒ PASS
#
# SYNTHETIC FIXTURES (NO live model runs — no opencode run, no behavior_run,
# no monitor lifecycle; per the task directive, EVENT-DRIVEN synthetic
# session exports like SC-16/SC-21's fixtures): two synthetic session
# exports exercise the predicate's polarity:
#   sc23-reused-home   reused-home session export (prior-session messages /
#                      foreign task instructions present)                (FAIL)
#   sc23-fresh-session fresh-session export (single session, no
#                      prior-session content)                          (PASS)
#
# RED condition (expected outcome today): helpers.sh carries NO
# session-isolation evaluator — the predicate is unenforced (no
# __assert_session_isolation exists anywhere in helpers.sh), so every
# assertion fails ⇒ exit 1 (RED). If the evaluator already exists AND
# distinguishes both fixtures correctly (reused-home fixture FAIL;
# fresh-session fixture PASS), the predicate is already enforced by
# construction → ALREADY_GREEN classified abort (exit 3), recorded as the
# item's genuine outcome.
#
# PRECONDITION GUARDS (exit 2 = invalid RED, requires diagnosis — never a
# verdict): the synthetic fixture directory must have been created and both
# session-export fixtures must parse as JSON with an event table (the
# assertion surface is the fixture set; a missing/unparseable fixture is a
# harness defect, not a RED verdict).
#
# §15 targeted-execution mandate: run this ONE named scenario via
#   bash .opencode/tests-v2/behaviors/2456-sc23-session-isolation-red.sh
# (bash tool timeout >= 600000ms). No model dispatch — no live opencode run
# is needed; the isolation predicate is asserted from synthetic session
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

SCENARIO_NAME="2456-sc23-session-isolation-red"

ER="$(cd "$SCRIPT_DIR/../../.." && pwd)/tmp/2456/artifacts"
mkdir -p "$ER"
# Idempotence: clear this test's own stale artifacts.
rm -f "$ER"/pipeline-red-23sc*

FIX_ROOT="$ER/synthetic"
rm -rf "$FIX_ROOT"/sc23-*
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

echo "== SC-23 RED check: fresh-session isolation — each monitored fixture run starts from a FRESH test home and a fresh session; reuse of a prior attempt's test home/session DB is prohibited; foreign instructions from earlier sessions never appear in the run's context (R-22, .opencode#2456) =="

# ══ Synthetic session-export fixtures (EVENT-DRIVEN, deterministic) ══════════
python3 - "$FIX_ROOT" <<'PYEOF'
import json, os, sys

fix_root = sys.argv[1]
EPOCH = 1790282477000


def evt(agg, seq, etype, data_obj, ts):
    return {
        "id": f"evt_{agg[4:12]}{seq:04d}",
        "aggregate_id": agg,
        "seq": seq,
        "type": etype,
        "data": json.dumps(data_obj),
        "createdAt": ts,
    }


def part_event(agg, seq, ptype, payload, ts):
    part = {
        "id": f"prt_{agg[4:12]}_{seq:04d}",
        "sessionID": agg,
        "messageID": f"msg_{seq:04d}",
        "type": ptype,
    }
    part.update(payload)
    return evt(agg, seq, "message.part.updated.1", {"sessionID": agg, "part": part}, ts)


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


# The monitored run's OWN scenario prompt (the current attempt's task).
OWN_TASK = "monitor pipeline phase-4 run 2456-sc14 and record the determination"

# Foreign task instructions from EARLIER sessions (the live 2026-09-23
# contamination shape: a prior session's user turns injected by test-home
# reuse — the fix-2098 file-copy task and a 2456-sc9 marker-verification
# prompt — which pivoted the run agent mid-loop to foreign instructions).
FOREIGN_TURN_1 = "copy the fix-2098 export files into the staging directory"
FOREIGN_TURN_2 = "verify the 2456-sc9 defect marker was recorded in the prior attempt"

# ── Fixture 1: reused-home — prior-session content in the run's context ──────
# The run's session export carries TWO session ids (a prior attempt's
# session plus the current one) AND the prior session's foreign user-turn
# task instructions. This is the violation: the run did not start from a
# fresh home/fresh session — its evidence is not self-contained.
AGG_PRIOR = "ses_8e16sc23fixturePRIOR0000000000000000"
AGG_RUN = "ses_8e16sc23fixtureRUN00000000000000000"

build("sc23-reused-home", [
    evt(AGG_RUN, 0, "session.created.1", {"sessionID": AGG_RUN}, EPOCH),
    part_event(AGG_RUN, 2, "text", {"text": OWN_TASK}, EPOCH + 1000),
    # PRIOR-session user turns leaking into the run's context (test-home reuse):
    evt(AGG_PRIOR, 10, "session.created.1", {"sessionID": AGG_PRIOR}, EPOCH - 900000),
    part_event(AGG_PRIOR, 12, "text", {"text": FOREIGN_TURN_1}, EPOCH - 800000),
    part_event(AGG_PRIOR, 16, "text", {"text": FOREIGN_TURN_2}, EPOCH - 600000),
])

# ── Fixture 2: fresh-session — single fresh session, no prior content ────────
# The run's session export carries exactly ONE session id (the run's own
# fresh session) and no prior-session/foreign task instructions.
build("sc23-fresh-session", [
    evt(AGG_RUN, 0, "session.created.1", {"sessionID": AGG_RUN}, EPOCH),
    part_event(AGG_RUN, 2, "text", {"text": OWN_TASK}, EPOCH + 1000),
])
PYEOF
fixture_rc=$?

# ── Precondition guards: fixtures built and parseable ────────────────────────
if [ "$fixture_rc" -ne 0 ]; then
    echo "PRECONDITION-FAIL: synthetic fixture generation failed (rc=$fixture_rc) — harness defect, not a RED verdict" >&2
    exit 2
fi
FIXTURES="sc23-reused-home sc23-fresh-session"
for fx in $FIXTURES; do
    if ! python3 -c "import json,sys; d=json.load(open('$FIX_ROOT/$fx/session.yaml')); sys.exit(0 if d.get('tables',{}).get('event',{}).get('rows') else 1)" 2>/dev/null; then
        echo "PRECONDITION-FAIL: fixture $FIX_ROOT/$fx/session.yaml missing or unparseable (no event rows) — the session-export assertion surface is absent; not a RED verdict" >&2
        exit 2
    fi
done
echo "  [fixtures] 2 synthetic session exports built under $FIX_ROOT (no live model runs)"

# ══ Assertion 1 — the session-isolation evaluator exists in helpers.sh ═══════
# Fresh-session isolation (R-22) needs a mechanical session-export assertion
# surface; today none exists — the PRESENT machinery (timestamped fresh
# with-test-home provisioning; the live evidence run's 0-foreign-instruction
# validation) has no durable evaluator/scenario asserting the predicate.
if grep -q '^__assert_session_isolation()' "$SCRIPT_DIR/helpers.sh"; then
    check_pass "session-isolation evaluator __assert_session_isolation defined in helpers.sh"
    EVALUATOR_PRESENT=1
else
    check_fail "session-isolation evaluator __assert_session_isolation defined in helpers.sh" \
        "no session-export session-isolation evaluator exists in helpers.sh — the fresh-session isolation predicate (fresh test home + fresh session per monitored run; reuse of a prior attempt's home/session DB prohibited; foreign instructions from earlier sessions never in the run's context) is UNENFORCED (fresh homes are provisioned today only by with-test-home's timestamped-dir mechanics, asserted nowhere) (RED)"
    EVALUATOR_PRESENT=0
fi

evaluate_fixture() { # $1 fixture name; sets ev_rc; writes verdict yaml
    local fx="$1"
    local out="$FIX_ROOT/$fx/isolation-verdict.yaml"
    rm -f "$out"
    if [ "$EVALUATOR_PRESENT" = "1" ] && [ "$(type -t __assert_session_isolation)" = function ]; then
        __assert_session_isolation "$FIX_ROOT/$fx/session.yaml" "$out"
        ev_rc=$?
    else
        # DISPATCH-FAILURE decoupling (R-13): the missing evaluator is a
        # recorded dispatch failure — never a classification of its own.
        ev_rc=127
        printf 'session_isolation: fresh_test_home_fresh_session\neverdict: NOT_EVALUABLE\nevaluator: absent (helpers.sh)\nviolations: []\n' > "$out"
    fi
    ev_verdict="$(grep -E '^verdict: ' "$out" 2>/dev/null | head -1 | sed 's/^verdict: //' || true)"
    ev_violations="$(grep -cE 'violation|reused|foreign|prior[-_ ]?session|session_id' "$out" 2>/dev/null || true)"
    return 0
}

# ══ Assertion 2 — reused-home fixture FAILS (prior-session content present) ══
evaluate_fixture sc23-reused-home; f2_rc=$ev_rc; f2_verdict="$ev_verdict"; f2_violations="$ev_violations"
if [ "$EVALUATOR_PRESENT" = "1" ] && [ "$f2_rc" -ne 0 ] && [ "$f2_verdict" = "FAIL" ] && [ "${f2_violations:-0}" -ge 1 ]; then
    check_pass "reused-home fixture (prior-session messages / foreign task instructions in the run's context) FAILS isolation (rc=$f2_rc)"
else
    check_fail "reused-home fixture (prior-session content in the run's context) FAILS isolation" \
        "evaluator rc=$f2_rc verdict='${f2_verdict:-none}' violation_records=${f2_violations:-0} — a monitored run whose context carries prior-session messages / foreign task instructions (reused test home/session DB) is an isolation violation and must fail"
fi

# ══ Assertion 3 — fresh-session fixture PASSES (single session, no prior) ════
evaluate_fixture sc23-fresh-session; f3_rc=$ev_rc; f3_verdict="$ev_verdict"; f3_violations="$ev_violations"
if [ "$EVALUATOR_PRESENT" = "1" ] && [ "$f3_rc" -eq 0 ] && [ "$f3_verdict" = "PASS" ] && [ "${f3_violations:-0}" -eq 0 ]; then
    check_pass "fresh-session fixture (single fresh session id, zero prior-session content) PASSES isolation (rc=$f3_rc)"
else
    check_fail "fresh-session fixture (single fresh session, no prior-session content) PASSES isolation" \
        "evaluator rc=$f3_rc verdict='${f3_verdict:-none}' violation_records=${f3_violations:-0} — a monitored run started from a fresh test home + fresh session (no prior-session content) is mechanically compliant and must pass"
fi

# ══ Evidence artifact ════════════════════════════════════════════════════════
OUT="$ER/pipeline-red-23sc-sc23-summary.yaml"
{
    echo "== SC-23 RED evidence (.opencode#2456) =="
    echo "test: ${SCENARIO_NAME}"
    echo "sc_ref: SC-23 (plan-06 Item 23, phase 6, step 144)"
    echo "evidence_type: behavioral (session-export fresh-session-isolation assertion; synthetic fixtures per task directive — no live model runs)"
    echo "model_dispatch: none (synthetic session-export fixtures)"
    echo "baseline: ABSENT as an enforced predicate (PRESENT machinery: with-test-home provisions timestamped fresh homes per invocation; live evidence validated 0 foreign instructions — but no durable evaluator/scenario asserts the predicate)"
    echo "synthetic_fixtures: $FIX_ROOT/sc23-{reused-home,fresh-session}/session.yaml"
    echo "evaluator_present: $EVALUATOR_PRESENT"
    echo "fixture_eval_rc: reused-home=$f2_rc fresh-session=$f3_rc"
    echo "fixture_verdicts: reused-home='${f2_verdict:-none}' fresh-session='${f3_verdict:-none}'"
    echo "violation_records: reused-home=$f2_violations fresh-session=$f3_violations"
    echo "phase: RED"
    echo "fail_assertions: $FAIL"
    echo "pass_assertions: $PASS"
} > "$OUT" 2>&1

if [ "$FAIL" -eq 0 ]; then
    echo "RED ABORT — ALREADY_GREEN: the session-isolation evaluator exists in helpers.sh and distinguishes both fixtures correctly (reused-home fixture FAIL; fresh-session fixture PASS) — the R-22 fresh-session isolation predicate is already enforced by construction, so a failing RED test cannot be validly produced" >&2
    {
        echo "verdict: RED_ABORT_ALREADY_GREEN (exit 3) — the fresh-session isolation predicate is already enforced; a failing RED test cannot be validly produced"
    } >> "$OUT" 2>&1
    exit 3
fi

{
    echo "verdict: RED (exit 1) — the fresh-session isolation predicate is ABSENT as an enforced predicate: no __assert_session_isolation exists in helpers.sh, so reuse of a prior attempt's test home/session DB and foreign prior-session instructions in a monitored run's context are asserted nowhere mechanically (fresh-home provisioning exists today only as unasserted with-test-home mechanics)"
    echo "blocker_class: none (red is the expected terminal state; GREEN implementer: step 145 — implement __assert_session_isolation <session-export> <verdict-out> in helpers.sh per the contract in this file's header)"
} >> "$OUT" 2>&1

echo "RED CONFIRMED: $FAIL failing assertion(s) — the fresh-session isolation predicate is ABSENT as an enforced predicate (evaluator_present=$EVALUATOR_PRESENT; fixture verdicts: reused-home='${f2_verdict:-none}' fresh-session='${f3_verdict:-none}'). BASELINE: with-test-home provisions timestamped fresh homes per invocation and the live evidence validated 0 foreign instructions, but no durable evaluator/scenario asserts the predicate — test-home reuse (the live 2026-09-23 contamination: a prior session's fix-2098 copy task and marker-verification prompts injected into the run's context) is asserted nowhere. GATE EXPECTATION FOR GREEN: implement __assert_session_isolation <session-export> <verdict-out> in helpers.sh (pure decision function, no model dispatch) — it parses the ordered event stream of a monitored fixture run's session export and asserts (1) a single fresh session id (no prior-session ids) and (2) zero prior-session messages / foreign task instructions in the run's context; a reused home/DB (multiple session ids or foreign prior-session user turns) fails; verdict: PASS|FAIL with violations[]; the two synthetic fixtures under $FIX_ROOT/sc23-* are the polarity suite (evidence: $OUT, .opencode#2456 SC-23)." >&2
exit 1

# Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)