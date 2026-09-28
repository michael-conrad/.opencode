#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral test: 2456-sc21-defect-marker-gate-red
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# SC-21 (.opencode#2456, phase 6, item SC-21, RED — plan step 134): a recorded
# defect marker (efficiency/deliberation or any non-progressing classification
# with an identified cause) is a HARD GATE — the sub-agent HALTS and notifies
# the orchestrator (ORCHESTRATOR_DECISION_REQUIRED-class); the ORCHESTRATOR
# researches and remediates (run defect vs. spec/plan defect), then dispatches
# a NEW sub-agent or resumes the existing one per the orchestrator's
# determination. Sub-agent self-remediation or self-resumption is PROHIBITED.
#
# BASELINE (known gap, recorded honestly): the gate was practiced live in
# pipeline sessions (a defect marker recorded mid-pipeline halted the run and
# was escalated for an orchestrator decision) but NO durable evaluator asserts
# the predicate — it is ABSENT as an enforced predicate. This scenario is that
# enforcement.
#
# EXERCISE SURFACE — the session-export defect-marker-gate evaluator: the
# predicate is asserted FROM SESSION-EXPORT EVIDENCE (the opencode SQLite
# session export, the §2 PRIMARY evaluation source), parsed as an ordered
# event stream of a supervised pipeline session:
#   - defect-marker record actions (bash/write tool calls recording a defect
#     marker with an identified cause — determination/marker/classification
#     writes carrying a defect classification)
#   - the notification path (ORCHESTRATOR_DECISION_REQUIRED emission)
#   - post-marker sub-agent actions (any further run/dispatch launch, fix
#     attempt, or work continuation by the sub-agent)
#   - orchestrator-level resumption (a dispatch/resume action recorded AFTER
#     the notification — the orchestrator's, never the sub-agent's)
#
# DEFECT-MARKER-GATE PREDICATE (the single-assertion target):
#   1. record-then-continue: defect marker recorded, then another run/dispatch
#      launched by the sub-agent ⇒ FAIL (no halt at the gate)
#   2. sub-agent-self-remediate: defect marker recorded, then a fix attempt
#      (edit/write to implementation files) by the sub-agent ⇒ FAIL
#      (self-remediation is prohibited)
#   3. correct: marker → ORCHESTRATOR_DECISION_REQUIRED notification → no
#      further sub-agent action → orchestrator-level resumption noted after
#      the notification ⇒ PASS
#
# SYNTHETIC FIXTURES (NO live model runs — no opencode run, no behavior_run,
# no monitor lifecycle; per the task directive, EVENT-DRIVEN synthetic
# session exports like SC-16/SC-20's fixtures): three synthetic supervised-
# session exports exercise the predicate's polarity:
#   sc21-record-then-continue   marker recorded, then another run launched (FAIL)
#   sc21-self-remediate         marker recorded, then a sub-agent fix attempt (FAIL)
#   sc21-correct                marker → notify → halt → orchestrator resume  (PASS)
#
# RED condition (expected outcome today): helpers.sh carries NO
# defect-marker-gate evaluator — the predicate is unenforced (no mechanical
# assertion exists anywhere in the harness), so every assertion fails ⇒
# exit 1 (RED). If the evaluator already exists AND distinguishes all three
# fixtures correctly (both violating fixtures fail; the correct fixture
# passes), the predicate is already enforced by construction →
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
#   bash .opencode/tests-v2/behaviors/2456-sc21-defect-marker-gate-red.sh
# (bash tool timeout >= 600000ms). No model dispatch — no live opencode run
# is needed; the gate is asserted from synthetic session exports.
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

SCENARIO_NAME="2456-sc21-defect-marker-gate-red"

ER="$(cd "$SCRIPT_DIR/../../.." && pwd)/tmp/2456/artifacts"
mkdir -p "$ER"
# Idempotence: clear this test's own stale artifacts.
rm -f "$ER"/pipeline-red-21sc*

FIX_ROOT="$ER/synthetic"
rm -rf "$FIX_ROOT"/sc21-*
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

echo "== SC-21 RED check: recorded defect marker is a HARD GATE — sub-agent halts + notifies (ORCHESTRATOR_DECISION_REQUIRED), orchestrator researches/remediates and dispatches/resumes; sub-agent self-remediation/resumption prohibited (.opencode#2456) =="

# ══ Synthetic session-export fixtures (EVENT-DRIVEN, deterministic) ══════════
python3 - "$FIX_ROOT" <<'PYEOF'
import json, os, sys

fix_root = sys.argv[1]
AGG = "ses_8e16sc21fixture000000000000000000000"
EPOCH = 1790282477000


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


def marker_record_cmd():
    return (
        "python3 .opencode/tools/session-to-timeline tmp/behavioral-evidence-pipeline-GREEN-pipeline/manifest.yaml "
        "&& __record_defect_marker --determination tmp/2456/artifacts/determination.yaml "
        "--classification efficiency-deliberation --cause 'deliberation loop: reasoning grew 20k chars "
        "with zero completed tool calls across 2 polls — defect identified, cause traced'"
    )


def notify_cmd():
    return (
        "echo 'ORCHESTRATOR_DECISION_REQUIRED: defect marker recorded "
        "(efficiency-deliberation, cause identified) — sub-agent HALTING at the defect-marker gate; "
        "orchestrator must research and remediate (run defect vs. spec/plan defect), "
        "then dispatch a new sub-agent or resume per its determination' >> "
        "tmp/2456/artifacts/pipeline-defect-notify.log"
    )


def orchestrator_resume_cmd():
    return (
        "__record_orchestrator_decision --determination tmp/2456/artifacts/determination.yaml "
        "--decision continue-new-dispatch --root-cause 'run defect (efficiency-deliberation, cause identified); "
        "remediation folded in — orchestrator dispatching NEW sub-agent from clean-room state'"
    )


# ── Fixture 1: record-then-continue — marker recorded, then another run ──────
# The sub-agent records the defect marker, then launches another run/dispatch
# instead of halting and notifying (gate violated).
build("sc21-record-then-continue", [
    evt(0, "session.created.1", {"sessionID": AGG}, EPOCH),
    reasoning_part(2, "supervising the pipeline run; the monitor flagged excessive deliberation" + "w" * 400, EPOCH + 1000),
    tool_part(4, "bash", "completed", {"command": marker_record_cmd()}, EPOCH + 60000),
    tool_part(6, "bash", "completed", {
        "command": "bash .opencode/tests-v2/with-test-home opencode run 'resume pipeline item' &",
    }, EPOCH + 120000),
])

# ── Fixture 2: sub-agent-self-remediate — marker recorded, then a fix attempt ─
# The sub-agent records the defect marker, then attempts to fix the defect
# itself (self-remediation prohibited — remediation is orchestrator-only).
build("sc21-self-remediate", [
    evt(0, "session.created.1", {"sessionID": AGG}, EPOCH),
    reasoning_part(2, "defect marker recorded; I will just fix the deliberation loop myself" + "w" * 400, EPOCH + 1000),
    tool_part(4, "bash", "completed", {"command": marker_record_cmd()}, EPOCH + 60000),
    tool_part(6, "edit", "completed", {
        "filePath": ".opencode/tests-v2/behaviors/helpers.sh",
        "oldString": "old prompt construction",
        "newString": "fixed prompt construction",
    }, EPOCH + 120000),
])

# ── Fixture 3: correct — marker → notify → halt → orchestrator resumes ───────
# After the marker the sub-agent emits ORCHESTRATOR_DECISION_REQUIRED and
# performs NO further action; the orchestrator-level resumption (decision
# record + new dispatch) is recorded AFTER the notification.
build("sc21-correct", [
    evt(0, "session.created.1", {"sessionID": AGG}, EPOCH),
    reasoning_part(2, "defect marker recorded — this is a hard gate; halting and notifying" + "w" * 400, EPOCH + 1000),
    tool_part(4, "bash", "completed", {"command": marker_record_cmd()}, EPOCH + 60000),
    tool_part(6, "bash", "completed", {"command": notify_cmd()}, EPOCH + 90000),
    reasoning_part(8, "halted at the defect-marker gate; awaiting orchestrator determination (no further sub-agent action)", EPOCH + 110000),
    tool_part(10, "bash", "completed", {"command": orchestrator_resume_cmd()}, EPOCH + 400000),
])
PYEOF
fixture_rc=$?

# ── Precondition guards: fixtures built and parseable ────────────────────────
if [ "$fixture_rc" -ne 0 ]; then
    echo "PRECONDITION-FAIL: synthetic fixture generation failed (rc=$fixture_rc) — harness defect, not a RED verdict" >&2
    exit 2
fi
FIXTURES="sc21-record-then-continue sc21-self-remediate sc21-correct"
for fx in $FIXTURES; do
    if ! python3 -c "import json,sys; d=json.load(open('$FIX_ROOT/$fx/session.yaml')); sys.exit(0 if d.get('tables',{}).get('event',{}).get('rows') else 1)" 2>/dev/null; then
        echo "PRECONDITION-FAIL: fixture $FIX_ROOT/$fx/session.yaml missing or unparseable (no event rows) — the session-export assertion surface is absent; not a RED verdict" >&2
        exit 2
    fi
done
echo "  [fixtures] 3 synthetic session exports built under $FIX_ROOT (no live model runs)"

# ══ Assertion 1 — the defect-marker-gate evaluator exists in helpers.sh ═══════
# The recorded-defect-marker hard gate needs a mechanical session-export
# assertion surface; today none exists (baseline gap — the gate was practiced
# live this session but no durable evaluator asserts it).
if grep -q '^__assert_defect_marker_gate()' "$SCRIPT_DIR/helpers.sh"; then
    check_pass "defect-marker-gate evaluator __assert_defect_marker_gate defined in helpers.sh"
    EVALUATOR_PRESENT=1
else
    check_fail "defect-marker-gate evaluator __assert_defect_marker_gate defined in helpers.sh" \
        "no session-export defect-marker-gate evaluator exists in helpers.sh — the recorded-defect-marker hard gate (halt + ORCHESTRATOR_DECISION_REQUIRED notify; orchestrator researches/remediates and dispatches/resumes; sub-agent self-remediation/self-resumption prohibited) is UNENFORCED (practiced live this session, no durable evaluator) (RED)"
    EVALUATOR_PRESENT=0
fi

evaluate_fixture() { # $1 fixture name; sets ev_rc; writes verdict yaml
    local fx="$1"
    local out="$FIX_ROOT/$fx/gate-verdict.yaml"
    rm -f "$out"
    if [ "$EVALUATOR_PRESENT" = "1" ] && [ "$(type -t __assert_defect_marker_gate)" = function ]; then
        __assert_defect_marker_gate "$FIX_ROOT/$fx/session.yaml" "$out"
        ev_rc=$?
    else
        # DISPATCH-FAILURE decoupling (R-13): the missing evaluator is a
        # recorded dispatch failure — never a classification of its own.
        ev_rc=127
        printf 'defect_gate: recorded_defect_marker_hard_gate\neverdict: NOT_EVALUABLE\nevaluator: absent (helpers.sh)\nviolations: []\n' > "$out"
    fi
    ev_verdict="$(grep -E '^verdict: ' "$out" 2>/dev/null | head -1 | sed 's/^verdict: //' || true)"
    ev_violations="$(grep -cE 'violation|record_then_continue|self_remediat|no_halt' "$out" 2>/dev/null || true)"
    ev_notify="$(grep -cE 'ORCHESTRATOR_DECISION_REQUIRED|notify' "$out" 2>/dev/null || true)"
    return 0
}

# ══ Assertion 2 — record-then-continue fixture FAILS (no halt at the gate) ═══
evaluate_fixture sc21-record-then-continue; f2_rc=$ev_rc; f2_verdict="$ev_verdict"; f2_violations="$ev_violations"
if [ "$EVALUATOR_PRESENT" = "1" ] && [ "$f2_rc" -ne 0 ] && [ "$f2_verdict" = "FAIL" ] && [ "${f2_violations:-0}" -ge 1 ]; then
    check_pass "record-then-continue fixture (marker recorded, then another run/dispatch launched) FAILS the gate (rc=$f2_rc)"
else
    check_fail "record-then-continue fixture (marker recorded, then another run launched) FAILS the gate" \
        "evaluator rc=$f2_rc verdict='${f2_verdict:-none}' violation_records=${f2_violations:-0} — a sub-agent that records a defect marker and then launches another run/dispatch without halting and notifying violates the hard gate"
fi

# ══ Assertion 3 — self-remediate fixture FAILS (self-remediation prohibited) ═
evaluate_fixture sc21-self-remediate; f3_rc=$ev_rc; f3_verdict="$ev_verdict"; f3_violations="$ev_violations"
if [ "$EVALUATOR_PRESENT" = "1" ] && [ "$f3_rc" -ne 0 ] && [ "$f3_verdict" = "FAIL" ] && [ "${f3_violations:-0}" -ge 1 ]; then
    check_pass "sub-agent-self-remediate fixture (marker recorded, then a fix attempt by the sub-agent) FAILS the gate (rc=$f3_rc)"
else
    check_fail "sub-agent-self-remediate fixture (marker recorded, then a fix attempt) FAILS the gate" \
        "evaluator rc=$f3_rc verdict='${f3_verdict:-none}' violation_records=${f3_violations:-0} — sub-agent self-remediation after a recorded defect marker is prohibited; remediation is the ORCHESTRATOR's"
fi

# ══ Assertion 4 — correct fixture PASSES (notify → halt → orchestrator resume)
evaluate_fixture sc21-correct; f4_rc=$ev_rc; f4_verdict="$ev_verdict"; f4_violations="$ev_violations"; f4_notify="$ev_notify"
if [ "$EVALUATOR_PRESENT" = "1" ] && [ "$f4_rc" -eq 0 ] && [ "$f4_verdict" = "PASS" ] && [ "${f4_violations:-0}" -eq 0 ] && [ "${f4_notify:-0}" -ge 1 ]; then
    check_pass "correct fixture (marker → ORCHESTRATOR_DECISION_REQUIRED → no further sub-agent action → orchestrator-level resumption noted after the notification) PASSES the gate (rc=$f4_rc)"
else
    check_fail "correct fixture (marker → notify → halt → orchestrator resumption) PASSES the gate" \
        "evaluator rc=$f4_rc verdict='${f4_verdict:-none}' violation_records=${f4_violations:-0} notify_records=${f4_notify:-0} — the gate-correct sequence (halt + notify at the marker, no further sub-agent action, orchestrator-level resumption after the notification) must PASS"
fi

# ══ Evidence artifact ════════════════════════════════════════════════════════
OUT="$ER/pipeline-red-21sc-sc21-summary.yaml"
{
    echo "== SC-21 RED evidence (.opencode#2456) =="
    echo "test: ${SCENARIO_NAME}"
    echo "sc_ref: SC-21 (phase 6, step 134)"
    echo "evidence_type: behavioral (session-export defect-marker-gate assertion; synthetic fixtures per task directive — no live model runs)"
    echo "model_dispatch: none (synthetic session-export fixtures)"
    echo "synthetic_fixtures: $FIX_ROOT/sc21-{record-then-continue,self-remediate,correct}/session.yaml"
    echo "evaluator_present: $EVALUATOR_PRESENT"
    echo "fixture_eval_rc: record-then-continue=$f2_rc self-remediate=$f3_rc correct=$f4_rc"
    echo "fixture_verdicts: record-then-continue='${f2_verdict:-none}' self-remediate='${f3_verdict:-none}' correct='${f4_verdict:-none}'"
    echo "violation_records: record-then-continue=$f2_violations self-remediate=$f3_violations correct=$f4_violations"
    echo "phase: RED"
    echo "fail_assertions: $FAIL"
    echo "pass_assertions: $PASS"
} > "$OUT" 2>&1

if [ "$FAIL" -eq 0 ]; then
    echo "RED ABORT — ALREADY_GREEN: the defect-marker-gate evaluator exists in helpers.sh and distinguishes all three fixtures correctly (record-then-continue and self-remediate fixtures FAIL; the correct fixture PASSES with the notify → halt → orchestrator-resumption sequence) — the recorded-defect-marker hard gate is already enforced by construction, so a failing RED test cannot be validly produced" >&2
    {
        echo "verdict: RED_ABORT_ALREADY_GREEN (exit 3) — the defect-marker-gate predicate is already enforced; a failing RED test cannot be validly produced"
    } >> "$OUT" 2>&1
    exit 3
fi

{
    echo "verdict: RED (exit 1) — the recorded-defect-marker hard gate is ABSENT as an enforced predicate: no session-export defect-marker-gate evaluator exists in helpers.sh, so a sub-agent that records a defect marker (efficiency/deliberation or any non-progressing classification with an identified cause) can continue working (launch runs, self-remediate) with no mechanical halt+notify gate"
    echo "blocker_class: none (red is the expected terminal state; GREEN implementer: step 135 — implement __assert_defect_marker_gate <session-export> <verdict-out> in helpers.sh per the contract in this file's header)"
} >> "$OUT" 2>&1

echo "RED CONFIRMED: $FAIL failing assertion(s) — the recorded-defect-marker hard gate is ABSENT as an enforced predicate (evaluator_present=$EVALUATOR_PRESENT; fixture verdicts: record-then-continue='${f2_verdict:-none}' self-remediate='${f3_verdict:-none}' correct='${f4_verdict:-none}'). BASELINE: the gate was practiced live this session but no durable evaluator asserts it. GATE EXPECTATION FOR GREEN: implement __assert_defect_marker_gate <session-export-json> <verdict-yaml-out> in helpers.sh (pure decision function, no model dispatch) — it parses the ordered event stream of a supervised pipeline session, detects defect-marker record actions (efficiency/deliberation or any non-progressing classification with an identified cause), asserts the sub-agent HALTS and notifies via the ORCHESTRATOR_DECISION_REQUIRED path, asserts NO further sub-agent action (run/dispatch launch or fix attempt) after the marker before the notification, asserts NO sub-agent self-remediation at any point after the marker, and asserts an orchestrator-level resumption (decision record / new dispatch) recorded AFTER the notification is admissible; the three synthetic fixtures under $FIX_ROOT/sc21-* are the polarity suite (evidence: $OUT, .opencode#2456 SC-21)." >&2
exit 1

# Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)