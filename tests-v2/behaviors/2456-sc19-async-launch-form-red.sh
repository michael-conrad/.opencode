#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral test: 2456-sc19-async-launch-form-red
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# SC-19 (.opencode#2456, plan-06 phase-6 item, RED — plan step 124): an agent
# setting up an opencode run for supervision launches it ASYNCHRONOUSLY
# (backgrounded/detached) with an attached supervision schedule of no more
# than 5 minutes between semantic checks of that run's SQLite session DB
# (message/reasoning/tool-call parts); a blocking foreground invocation, or a
# launch with no attached ≤5-min SQLite-DB semantic-poll schedule, fails the
# assertion.
#
# BASELINE (known gap, recorded honestly — BASELINE: PARTIAL): async-launch +
# attached ≤300s SQLite-DB poll scheduling was practiced in this session's
# pipeline supervision (every prior item's run was backgrounded under setsid
# and polled via session-DB reads) but is ABSENT as an enforced predicate —
# no mechanical assertion exists anywhere in the harness that measures the
# launch form (async vs blocking foreground) or the attached poll schedule
# from session-export evidence. This scenario is that enforcement.
#
# EXERCISE SURFACE — the session-export launch-form evaluator: the predicate
# is asserted FROM SESSION-EXPORT EVIDENCE (the opencode SQLite session
# export, the §2 PRIMARY evaluation source), parsed as an ordered event
# stream of a supervising session:
#   - opencode run invocations (bash tool calls whose command contains
#     `with-test-home` and `opencode run`), classified by launch form:
#     ASYNC (backgrounded with & / setsid / nohup / disown, or detached via
#     output redirection with a PID capture) vs BLOCKING (a bare foreground
#     command line with no backgrounding marker)
#   - the attached supervision schedule: SQLite-DB semantic-poll actions
#     (read tool calls targeting session.yaml / session-DB paths, or bash
#     calls invoking the export procedure / reading opencode.db on the
#     run's test home) with gaps ≤ 300s from the run launch
#
# LAUNCH-FORM PREDICATE (the single-assertion target):
#   1. every opencode run invocation is launched ASYNCHRONOUSLY
#      (backgrounded/detached) — a blocking foreground wait fails
#   2. the launch carries an attached supervision schedule: a semantic
#      check of the run's SQLite session DB within ≤300s of the launch
#      — a launch with no such schedule fails
#
# SYNTHETIC FIXTURES (NO live model runs — no opencode run, no behavior_run,
# no monitor lifecycle; EVENT-DRIVEN synthetic session exports like the
# SC-16/SC-17 fixtures): three synthetic supervising-session exports
# exercise the predicate's polarity:
#   sc19-async-scheduled     async (setsid backgrounded) launch + ≤300s
#                            SQLite-DB poll attached                         (PASS)
#   sc19-blocking-foreground blocking foreground invocation (no backgrounding
#                            marker; the run awaited synchronously)          (FAIL)
#   sc19-no-schedule         async launch but no SQLite-DB semantic poll
#                            attached                                        (FAIL)
#
# RED condition (expected outcome today): helpers.sh carries NO launch-form
# evaluator — the predicate is unenforced (no __assert_launch_form function
# exists anywhere in the harness), so every assertion fails ⇒ exit 1 (RED).
# If the evaluator already exists AND distinguishes all three fixtures
# correctly (correct fixture passes; both violating fixtures fail), the
# predicate is already enforced by construction → ALREADY_GREEN classified
# abort (exit 3), recorded as the item's genuine outcome.
#
# PRECONDITION GUARDS (exit 2 = invalid RED, requires diagnosis — never a
# verdict): the synthetic fixture directory must have been created and all
# three session-export fixtures must parse as JSON with an event table (the
# assertion surface is the fixture set; a missing/unparseable fixture is a
# harness defect, not a RED verdict).
#
# §15 targeted-execution mandate: run this ONE named scenario via
#   bash .opencode/tests-v2/behaviors/2456-sc19-async-launch-form-red.sh
# (bash tool timeout >= 600000ms). No model dispatch — no live opencode run
# is needed; the launch form is asserted from synthetic session exports.
#
# Ordered precondition cycle (§4/SC-16): the scenario file itself is committed
# and pushed to the submodule remote BEFORE this test run (mechanical, no
# deliberation; NEVER --no-verify).

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2456-sc19-async-launch-form-red"

ER="$(cd "$SCRIPT_DIR/../../.." && pwd)/tmp/2456/artifacts"
mkdir -p "$ER"
# Idempotence: clear this test's own stale artifacts.
rm -f "$ER"/pipeline-red-19sc*

FIX_ROOT="$ER/synthetic"
rm -rf "$FIX_ROOT"/sc19-*
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

echo "== SC-19 RED check: async-launch-form predicate — opencode runs launched asynchronously with an attached ≤300s SQLite-DB semantic-poll schedule (.opencode#2456) =="

# ══ Synthetic session-export fixtures (EVENT-DRIVEN, deterministic) ══════════
python3 - "$FIX_ROOT" <<'PYEOF'
import json, os, sys

fix_root = sys.argv[1]
AGG = "ses_0d51sc19fixture000000000000000000000"
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


def text_part(seq, text, ts):
    return part_event(seq, "text", {"text": text}, ts)


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


def bash(seq, command, ts):
    return tool_part(seq, "bash", "completed", {"command": command}, ts)


def read(seq, path, ts):
    return tool_part(seq, "read", "completed", {"filePath": path}, ts)


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


PROMPT = '"You are a sub-agent. Execute the RED task: author the scenario, then run it per the §4 ordered cycle."'
ASYNC_RUN_CMD = "setsid bash .opencode/tests-v2/with-test-home opencode run 'fixture probe' > out.log 2> err.log &"
BLOCKING_RUN_CMD = "bash .opencode/tests-v2/with-test-home opencode run 'fixture probe'"
CHECK_PATH = "opencode/tmp/test-home-x/run-id/session.yaml"
EXPORT_CMD = "python3 .opencode/tests-v2/with-test-home --export-session session_id run-id"

# ── Fixture 1: async launch + attached ≤300s SQLite-DB poll schedule (PASS) ──
build("sc19-async-scheduled", [
    evt(0, "session.created.1", {"sessionID": AGG}, EPOCH),
    text_part(2, PROMPT, EPOCH + 1000),
    bash(4, ASYNC_RUN_CMD, EPOCH + 2000),
    read(6, CHECK_PATH, EPOCH + 2000 + 120000),
    bash(8, EXPORT_CMD, EPOCH + 2000 + 240000),
])

# ── Fixture 2: blocking foreground invocation — no async launch form (FAIL) ──
build("sc19-blocking-foreground", [
    evt(0, "session.created.1", {"sessionID": AGG}, EPOCH),
    text_part(2, PROMPT, EPOCH + 1000),
    bash(4, BLOCKING_RUN_CMD, EPOCH + 2000),
    read(6, CHECK_PATH, EPOCH + 2000 + 480000),
])

# ── Fixture 3: async launch but NO SQLite-DB semantic poll attached (FAIL) ───
build("sc19-no-schedule", [
    evt(0, "session.created.1", {"sessionID": AGG}, EPOCH),
    text_part(2, PROMPT, EPOCH + 1000),
    bash(4, ASYNC_RUN_CMD, EPOCH + 2000),
    bash(6, "tail -5 out.log", EPOCH + 2000 + 60000),
    bash(8, "wc -c out.log", EPOCH + 2000 + 120000),
])
PYEOF
fixture_rc=$?

# ── Precondition guards: fixtures built and parseable ────────────────────────
if [ "$fixture_rc" -ne 0 ]; then
    echo "PRECONDITION-FAIL: synthetic fixture generation failed (rc=$fixture_rc) — harness defect, not a RED verdict" >&2
    exit 2
fi
FIXTURES="sc19-async-scheduled sc19-blocking-foreground sc19-no-schedule"
for fx in $FIXTURES; do
    if ! python3 -c "import json,sys; d=json.load(open('$FIX_ROOT/$fx/session.yaml')); sys.exit(0 if d.get('tables',{}).get('event',{}).get('rows') else 1)" 2>/dev/null; then
        echo "PRECONDITION-FAIL: fixture $FIX_ROOT/$fx/session.yaml missing or unparseable (no event rows) — the session-export assertion surface is absent; not a RED verdict" >&2
        exit 2
    fi
done
echo "  [fixtures] 3 synthetic session exports built under $FIX_ROOT (no live model runs)"

# ══ Assertion 1 — the launch-form evaluator exists in helpers.sh ═════════════
# The async-launch predicate needs a mechanical session-export assertion
# surface; today none exists (baseline gap — the discipline lived in
# supervision practice, never as an enforced predicate).
if grep -q '^__assert_launch_form()' "$SCRIPT_DIR/helpers.sh"; then
    check_pass "launch-form evaluator __assert_launch_form defined in helpers.sh"
    EVALUATOR_PRESENT=1
else
    check_fail "launch-form evaluator __assert_launch_form defined in helpers.sh" \
        "no session-export launch-form evaluator exists in helpers.sh — the async-launch + attached ≤300s SQLite-DB poll-schedule predicate is UNENFORCED (practiced in supervision, never mechanically asserted) (RED)"
    EVALUATOR_PRESENT=0
fi

evaluate_fixture() { # $1 fixture name; sets ev_rc; writes verdict yaml
    local fx="$1"
    local out="$FIX_ROOT/$fx/launch-form-verdict.yaml"
    rm -f "$out"
    if [ "$EVALUATOR_PRESENT" = "1" ] && [ "$(type -t __assert_launch_form)" = function ]; then
        __assert_launch_form "$FIX_ROOT/$fx/session.yaml" "$out"
        ev_rc=$?
    else
        ev_rc=127
        printf 'launch_form: async_with_sqlite_poll_schedule\neverdict: NOT_EVALUABLE\nevaluator: absent (helpers.sh)\n' > "$out"
    fi
    ev_verdict="$(grep -E '^verdict: ' "$out" 2>/dev/null | head -1 | sed 's/^verdict: //' || true)"
    return 0
}

# ══ Assertion 2 — async+scheduled fixture evaluates PASS ═════════════════════
evaluate_fixture sc19-async-scheduled; f2_rc=$ev_rc; f2_verdict="$ev_verdict"
if [ "$f2_rc" -eq 0 ] && [ "$f2_verdict" = "PASS" ]; then
    check_pass "async+scheduled fixture (setsid backgrounded launch + ≤300s SQLite-DB poll) evaluates PASS (rc=$f2_rc)"
else
    check_fail "async+scheduled fixture (setsid backgrounded launch + ≤300s SQLite-DB poll) evaluates PASS" \
        "evaluator rc=$f2_rc verdict='${f2_verdict:-none}' — a mechanically compliant async launch with an attached poll schedule must pass the assertion"
fi

# ══ Assertion 2 — blocking-foreground fixture evaluates FAIL ═════════════════
evaluate_fixture sc19-blocking-foreground; f3_rc=$ev_rc; f3_verdict="$ev_verdict"
f3_blocking="$(grep -cE 'blocking|foreground|violation' "$FIX_ROOT/sc19-blocking-foreground/launch-form-verdict.yaml" 2>/dev/null || true)"
if [ "$EVALUATOR_PRESENT" = "1" ] && [ "$f3_rc" -ne 0 ] && [ "$f3_verdict" = "FAIL" ] && [ "${f3_blocking:-0}" -ge 1 ]; then
    check_pass "blocking-foreground fixture evaluates FAIL (rc=$f3_rc) with the blocking invocation recorded — a blocking foreground invocation fails the launch-form assertion"
else
    check_fail "blocking-foreground fixture evaluates FAIL with the blocking invocation recorded" \
        "evaluator rc=$f3_rc verdict='${f3_verdict:-none}' blocking_records=${f3_blocking:-0} — a blocking foreground invocation must fail the assertion and be recorded"
fi

# ══ Assertion 3 — launch-without-schedule fixture evaluates FAIL ═════════════
evaluate_fixture sc19-no-schedule; f4_rc=$ev_rc; f4_verdict="$ev_verdict"
f4_sched="$(grep -cE 'schedule|missing|violation' "$FIX_ROOT/sc19-no-schedule/launch-form-verdict.yaml" 2>/dev/null || true)"
if [ "$EVALUATOR_PRESENT" = "1" ] && [ "$f4_rc" -ne 0 ] && [ "$f4_verdict" = "FAIL" ] && [ "${f4_sched:-0}" -ge 1 ]; then
    check_pass "launch-without-schedule fixture evaluates FAIL (rc=$f4_rc) with the missing schedule recorded — a launch with no attached ≤300s SQLite-DB semantic-poll schedule fails the assertion"
else
    check_fail "launch-without-schedule fixture evaluates FAIL with the missing schedule recorded" \
        "evaluator rc=$f4_rc verdict='${f4_verdict:-none}' schedule_records=${f4_sched:-0} — a launch with no attached ≤300s SQLite-DB semantic-poll schedule must fail the assertion and be recorded"
fi

# ══ Evidence artifact ════════════════════════════════════════════════════════
OUT="$ER/pipeline-red-19sc-sc19-summary.yaml"
{
    echo "== SC-19 RED evidence (.opencode#2456) =="
    echo "test: ${SCENARIO_NAME}"
    echo "sc_ref: SC-19 (plan-06 Item 19, phase 6, step 124)"
    echo "evidence_type: behavioral (session-export launch-form assertion; synthetic fixtures per task directive — no live model runs)"
    echo "model_dispatch: none (synthetic session-export fixtures)"
    echo "synthetic_fixtures: $FIX_ROOT/sc19-{async-scheduled,blocking-foreground,no-schedule}/session.yaml"
    echo "evaluator_present: $EVALUATOR_PRESENT"
    echo "fixture_eval_rc: async-scheduled=$f2_rc blocking-foreground=$f3_rc no-schedule=$f4_rc"
    echo "fixture_verdicts: async-scheduled='${f2_verdict:-none}' blocking-foreground='${f3_verdict:-none}' no-schedule='${f4_verdict:-none}'"
    echo "phase: RED"
    echo "fail_assertions: $FAIL"
    echo "pass_assertions: $PASS"
} > "$OUT" 2>&1

if [ "$FAIL" -eq 0 ]; then
    echo "RED ABORT — ALREADY_GREEN: the launch-form evaluator exists in helpers.sh and distinguishes all three fixtures correctly (async-scheduled fixture PASS; blocking-foreground/no-schedule fixtures FAIL) — the async-launch + attached ≤300s SQLite-DB poll-schedule predicate is already enforced by construction, so a failing RED test cannot be validly produced" >&2
    {
        echo "verdict: RED_ABORT_ALREADY_GREEN (exit 3) — the launch-form predicate is already enforced; a failing RED test cannot be validly produced"
    } >> "$OUT" 2>&1
    exit 3
fi

{
    echo "verdict: RED (exit 1) — the launch-form predicate is ABSENT as an enforced predicate: no session-export launch-form evaluator (__assert_launch_form) exists in helpers.sh, so async-launch form and the attached ≤300s SQLite-DB semantic-poll schedule are asserted nowhere mechanically"
    echo "blocker_class: none (red is the expected terminal state; GREEN implementer: step 125 — implement __assert_launch_form <session-export> <verdict-out> in helpers.sh per the contract in this file's header)"
} >> "$OUT" 2>&1

echo "RED CONFIRMED: $FAIL failing assertion(s) — the launch-form predicate is ABSENT as an enforced predicate (evaluator_present=$EVALUATOR_PRESENT; fixture verdicts: async-scheduled='${f2_verdict:-none}' blocking-foreground='${f3_verdict:-none}' no-schedule='${f4_verdict:-none}'). The discipline was practiced in this session's pipeline supervision (every prior item's run was setsid-backgrounded and polled via session-DB reads) but no enforcement scenario asserts it. GATE EXPECTATION FOR GREEN: implement __assert_launch_form <session-export-json> <verdict-yaml-out> in helpers.sh (pure decision function, no model dispatch) — it parses the ordered event stream of a supervising session, classifies each opencode run invocation's launch form (ASYNC when backgrounded via setsid/nohup/&/disown; BLOCKING when a bare foreground invocation), requires every run to be ASYNC, and requires an attached supervision schedule (a semantic check of the run's SQLite session DB — read of session.yaml/session-DB paths or export-procedure invocations — within ≤300s of the launch), emits verdict: PASS|FAIL with violations[] (blocking launches, missing schedules); the three synthetic fixtures under $FIX_ROOT/sc19-* are the polarity suite (evidence: $OUT, .opencode#2456 SC-19)." >&2
exit 1

# Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)