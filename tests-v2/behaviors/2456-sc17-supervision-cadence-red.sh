#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral test: 2456-sc17-supervision-cadence-red
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# SC-17 (.opencode#2456, plan-06 phase-6 item, RED — plan step 114): an agent
# supervising an opencode run polls at intervals of at most 5 minutes, and
# every poll is a FULL SEMANTIC CHECK of progress so far derived from the
# session export's message parts, reasoning parts, and tool calls; run-retry
# loops (multiple run invocations) without a semantic check between iterations
# fail the assertion.
#
# BASELINE (known gap, recorded honestly): the cadence + semantic-check
# discipline was practiced in this session's pipeline supervision (every
# prior item's supervision polls inspected the run's session DB) but is
# ABSENT as an enforced predicate — no mechanical assertion exists anywhere
# in the harness that measures consecutive supervision gaps from session-
# export evidence, ties each gap to a semantic-check action, or requires a
# semantic check between run-retry invocations. This scenario is that
# enforcement.
#
# EXERCISE SURFACE — the session-export supervision-cadence evaluator: the
# predicate is asserted FROM SESSION-EXPORT EVIDENCE (the opencode SQLite
# session export, the §2 PRIMARY evaluation source), parsed as an ordered
# event stream of a SUPERVISING session:
#   - with-test-home run invocations (bash tool calls whose command contains
#     `with-test-home` and `opencode run`) — run starts and run-retry
#     invocations, each stamped with the part's start epoch
#   - semantic-check actions (reads of the run's session DB / session export
#     content parts: read tool calls targeting session.yaml / session DB
#     paths, or bash calls invoking the export procedure on the run's DB)
#   - the gaps between consecutive supervision actions (runs and semantic
#     checks), measured from part timestamps
#
# CADENCE PREDICATE (the single-assertion target):
#   1. consecutive supervision gaps ≤ 300s (poll at most every 5 minutes)
#   2. each gap closed by a semantic-check action (a read of the run's
#      session DB / session export content parts)
#   3. run-retry invocations always separated by an intervening semantic
#      check (a second run invocation with no semantic check since the
#      previous run is the retry-without-check violation)
#
# SYNTHETIC FIXTURES (NO live model runs — no opencode run, no behavior_run,
# no monitor lifecycle; per the task directive, EVENT-DRIVEN synthetic
# session exports like SC-16's fixtures): four synthetic supervising-session
# exports exercise the predicate's polarity:
#   sc17-correct           run → check(≤300s gap) → retry → check            (PASS)
#   sc17-wait-on-hang      single gap >300s between run and first check      (FAIL)
#   sc17-retry-no-check    run → run with NO semantic check in between       (FAIL)
#   sc17-counter-no-check  supervisor actions with no session-DB reads       (FAIL)
#
# RED condition (expected outcome today): helpers.sh carries NO supervision-
# cadence evaluator — the predicate is unenforced (no mechanical assertion
# exists anywhere in the harness), so every assertion fails ⇒ exit 1 (RED).
# If the evaluator already exists AND distinguishes all four fixtures
# correctly (correct fixture passes; all three violating fixtures fail), the
# predicate is already enforced by construction → ALREADY_GREEN classified
# abort (exit 3), recorded as the item's genuine outcome.
#
# PRECONDITION GUARDS (exit 2 = invalid RED, requires diagnosis — never a
# verdict): the synthetic fixture directory must have been created and all
# four session-export fixtures must parse as JSON with an event table (the
# assertion surface is the fixture set; a missing/unparseable fixture is a
# harness defect, not a RED verdict).
#
# §15 targeted-execution mandate: run this ONE named scenario via
#   bash .opencode/tests-v2/behaviors/2456-sc17-supervision-cadence-red.sh
# (bash tool timeout >= 600000ms). No model dispatch — no live opencode run
# is needed; the supervision cadence is asserted from synthetic session
# exports.
#
# Ordered precondition cycle (§4/SC-16): the scenario file itself is committed
# and pushed to the submodule remote BEFORE this test run (mechanical, no
# deliberation; NEVER --no-verify).

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2456-sc17-supervision-cadence-red"

ER="$(cd "$SCRIPT_DIR/../../.." && pwd)/tmp/2456/artifacts"
mkdir -p "$ER"
# Idempotence: clear this test's own stale artifacts.
rm -f "$ER"/pipeline-red-17sc*

FIX_ROOT="$ER/synthetic"
rm -rf "$FIX_ROOT"/sc17-*
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

echo "== SC-17 RED check: supervision-cadence predicate — poll gaps ≤300s, each gap closed by a semantic check, retries separated by a semantic check (.opencode#2456) =="

# ══ Synthetic session-export fixtures (EVENT-DRIVEN, deterministic) ══════════
python3 - "$FIX_ROOT" <<'PYEOF'
import json, os, sys

fix_root = sys.argv[1]
AGG = "ses_0d51sc17fixture000000000000000000000"
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
RUN_CMD = "setsid bash .opencode/tests-v2/with-test-home opencode run 'fixture probe' > out.log 2> err.log"
CHECK_PATH = "opencode/tmp/test-home-x/run-id/session.yaml"
EXPORT_CMD = "python3 .opencode/tests-v2/with-test-home --export-session session_id run-id"

# ── Fixture 1: correct supervision — run → check (120s gap) → retry (180s gap) → check ──
build("sc17-correct", [
    evt(0, "session.created.1", {"sessionID": AGG}, EPOCH),
    text_part(2, PROMPT, EPOCH + 1000),
    bash(4, RUN_CMD, EPOCH + 2000),
    read(6, CHECK_PATH, EPOCH + 2000 + 120000),
    bash(8, RUN_CMD, EPOCH + 2000 + 120000 + 180000),
    read(10, CHECK_PATH, EPOCH + 2000 + 120000 + 180000 + 240000),
])

# ── Fixture 2: wait-on-hang — a single gap >300s between run and first check ──
build("sc17-wait-on-hang", [
    evt(0, "session.created.1", {"sessionID": AGG}, EPOCH),
    text_part(2, PROMPT, EPOCH + 1000),
    bash(4, RUN_CMD, EPOCH + 2000),
    read(6, CHECK_PATH, EPOCH + 2000 + 420000),
])

# ── Fixture 3: retry-without-check — second run with NO semantic check since the first ──
build("sc17-retry-no-check", [
    evt(0, "session.created.1", {"sessionID": AGG}, EPOCH),
    text_part(2, PROMPT, EPOCH + 1000),
    bash(4, RUN_CMD, EPOCH + 2000),
    bash(6, RUN_CMD, EPOCH + 2000 + 90000),
])

# ── Fixture 4: counter-only supervision — actions with no session-DB reads ────
build("sc17-counter-no-check", [
    evt(0, "session.created.1", {"sessionID": AGG}, EPOCH),
    text_part(2, PROMPT, EPOCH + 1000),
    bash(4, RUN_CMD, EPOCH + 2000),
    bash(6, "tail -5 out.log", EPOCH + 2000 + 60000),
    bash(8, "tail -5 out.log", EPOCH + 2000 + 120000),
    bash(10, "tail -5 out.log", EPOCH + 2000 + 180000),
])
PYEOF
fixture_rc=$?

# ── Precondition guards: fixtures built and parseable ────────────────────────
if [ "$fixture_rc" -ne 0 ]; then
    echo "PRECONDITION-FAIL: synthetic fixture generation failed (rc=$fixture_rc) — harness defect, not a RED verdict" >&2
    exit 2
fi
FIXTURES="sc17-correct sc17-wait-on-hang sc17-retry-no-check sc17-counter-no-check"
for fx in $FIXTURES; do
    if ! python3 -c "import json,sys; d=json.load(open('$FIX_ROOT/$fx/session.yaml')); sys.exit(0 if d.get('tables',{}).get('event',{}).get('rows') else 1)" 2>/dev/null; then
        echo "PRECONDITION-FAIL: fixture $FIX_ROOT/$fx/session.yaml missing or unparseable (no event rows) — the session-export assertion surface is absent; not a RED verdict" >&2
        exit 2
    fi
done
echo "  [fixtures] 4 synthetic session exports built under $FIX_ROOT (no live model runs)"

# ══ Assertion 1 — the supervision-cadence evaluator exists in helpers.sh ═════
# The supervision-cadence predicate needs a mechanical session-export
# assertion surface; today none exists (baseline gap — the discipline lived
# in this session's supervision practice, never as an enforced predicate).
if grep -q '^__assert_supervision_cadence()' "$SCRIPT_DIR/helpers.sh"; then
    check_pass "supervision-cadence evaluator __assert_supervision_cadence defined in helpers.sh"
    EVALUATOR_PRESENT=1
else
    check_fail "supervision-cadence evaluator __assert_supervision_cadence defined in helpers.sh" \
        "no session-export supervision-cadence evaluator exists in helpers.sh — the ≤300s-gap / semantic-check-closes-gap / retry-needs-check predicate is UNENFORCED (practiced in supervision, never mechanically asserted) (RED)"
    EVALUATOR_PRESENT=0
fi

evaluate_fixture() { # $1 fixture name; sets ev_rc; writes verdict yaml
    local fx="$1"
    local out="$FIX_ROOT/$fx/cadence-verdict.yaml"
    rm -f "$out"
    if [ "$EVALUATOR_PRESENT" = "1" ] && [ "$(type -t __assert_supervision_cadence)" = function ]; then
        __assert_supervision_cadence "$FIX_ROOT/$fx/session.yaml" "$out"
        ev_rc=$?
    else
        ev_rc=127
        printf 'supervision_cadence: poll_gap_semantic_check_retry\neverdict: NOT_EVALUABLE\nevaluator: absent (helpers.sh)\n' > "$out"
    fi
    ev_verdict="$(grep -E '^verdict: ' "$out" 2>/dev/null | head -1 | sed 's/^verdict: //' || true)"
    return 0
}

# ══ Assertion 2 — correct-supervision fixture evaluates PASS ═════════════════
evaluate_fixture sc17-correct; f2_rc=$ev_rc; f2_verdict="$ev_verdict"
if [ "$f2_rc" -eq 0 ] && [ "$f2_verdict" = "PASS" ]; then
    check_pass "correct-supervision fixture (run → check ≤300s → retry → check ≤300s) evaluates PASS (rc=$f2_rc)"
else
    check_fail "correct-supervision fixture (run → check ≤300s → retry → check ≤300s) evaluates PASS" \
        "evaluator rc=$f2_rc verdict='${f2_verdict:-none}' — a mechanically compliant supervision cadence must pass the assertion"
fi

# ══ Assertion 3 — wait-on-hang fixture evaluates FAIL ════════════════════════
evaluate_fixture sc17-wait-on-hang; f3_rc=$ev_rc; f3_verdict="$ev_verdict"
f3_gap="$(grep -cE 'max_gap|violation' "$FIX_ROOT/sc17-wait-on-hang/cadence-verdict.yaml" 2>/dev/null || true)"
if [ "$EVALUATOR_PRESENT" = "1" ] && [ "$f3_rc" -ne 0 ] && [ "$f3_verdict" = "FAIL" ] && [ "${f3_gap:-0}" -ge 1 ]; then
    check_pass "wait-on-hang fixture evaluates FAIL (rc=$f3_rc) with the >300s gap recorded — a supervision gap exceeding 300s without a semantic check is the wait-on-hang violation (SC-26)"
else
    check_fail "wait-on-hang fixture evaluates FAIL with the >300s gap recorded" \
        "evaluator rc=$f3_rc verdict='${f3_verdict:-none}' gap_records=${f3_gap:-0} — a gap >300s between consecutive supervision actions without a closing semantic check must fail the assertion and be recorded"
fi

# ══ Assertion 4 — retry-without-check fixture evaluates FAIL ═════════════════
evaluate_fixture sc17-retry-no-check; f4_rc=$ev_rc; f4_verdict="$ev_verdict"
f4_retry="$(grep -cE 'retry|violation' "$FIX_ROOT/sc17-retry-no-check/cadence-verdict.yaml" 2>/dev/null || true)"
if [ "$EVALUATOR_PRESENT" = "1" ] && [ "$f4_rc" -ne 0 ] && [ "$f4_verdict" = "FAIL" ] && [ "${f4_retry:-0}" -ge 1 ]; then
    check_pass "retry-without-check fixture evaluates FAIL (rc=$f4_rc) with the unchecked retry recorded — run-retry invocations without an intervening semantic check fail the assertion"
else
    check_fail "retry-without-check fixture evaluates FAIL with the unchecked retry recorded" \
        "evaluator rc=$f4_rc verdict='${f4_verdict:-none}' retry_records=${f4_retry:-0} — a second run invocation with no semantic check since the previous run must fail the assertion and be recorded"
fi

# ══ Assertion 5 — counter-only supervision fixture evaluates FAIL ════════════
evaluate_fixture sc17-counter-no-check; f5_rc=$ev_rc; f5_verdict="$ev_verdict"
f5_checks="$(grep -cE 'semantic_check|violation' "$FIX_ROOT/sc17-counter-no-check/cadence-verdict.yaml" 2>/dev/null || true)"
if [ "$EVALUATOR_PRESENT" = "1" ] && [ "$f5_rc" -ne 0 ] && [ "$f5_verdict" = "FAIL" ] && [ "${f5_checks:-0}" -ge 1 ]; then
    check_pass "counter-only-supervision fixture evaluates FAIL (rc=$f5_rc) with the missing semantic checks recorded — supervisor actions with no session-DB reads are not semantic checks (SC-14/SC-17)"
else
    check_fail "counter-only-supervision fixture evaluates FAIL with the missing semantic checks recorded" \
        "evaluator rc=$f5_rc verdict='${f5_verdict:-none}' check_records=${f5_checks:-0} — supervision activity with no read of the run's session DB/export must fail the assertion and be recorded"
fi

# ══ Evidence artifact ════════════════════════════════════════════════════════
OUT="$ER/pipeline-red-17sc-sc17-summary.yaml"
{
    echo "== SC-17 RED evidence (.opencode#2456) =="
    echo "test: ${SCENARIO_NAME}"
    echo "sc_ref: SC-17 (plan-06 Item 17, phase 6, step 114)"
    echo "evidence_type: behavioral (session-export supervision-cadence assertion; synthetic fixtures per task directive — no live model runs)"
    echo "model_dispatch: none (synthetic session-export fixtures)"
    echo "synthetic_fixtures: $FIX_ROOT/sc17-{correct,wait-on-hang,retry-no-check,counter-no-check}/session.yaml"
    echo "evaluator_present: $EVALUATOR_PRESENT"
    echo "fixture_eval_rc: correct=$f2_rc wait-on-hang=$f3_rc retry-no-check=$f4_rc counter-no-check=$f5_rc"
    echo "fixture_verdicts: correct='${f2_verdict:-none}' wait-on-hang='${f3_verdict:-none}' retry-no-check='${f4_verdict:-none}' counter-no-check='${f5_verdict:-none}'"
    echo "phase: RED"
    echo "fail_assertions: $FAIL"
    echo "pass_assertions: $PASS"
} > "$OUT" 2>&1

if [ "$FAIL" -eq 0 ]; then
    echo "RED ABORT — ALREADY_GREEN: the supervision-cadence evaluator exists in helpers.sh and distinguishes all four fixtures correctly (correct fixture PASS; wait-on-hang/retry-no-check/counter-no-check fixtures FAIL) — the ≤300s / semantic-check / retry-separation predicate is already enforced by construction, so a failing RED test cannot be validly produced" >&2
    {
        echo "verdict: RED_ABORT_ALREADY_GREEN (exit 3) — the supervision-cadence predicate is already enforced; a failing RED test cannot be validly produced"
    } >> "$OUT" 2>&1
    exit 3
fi

{
    echo "verdict: RED (exit 1) — the supervision-cadence predicate is ABSENT as an enforced predicate: no session-export supervision-cadence evaluator exists in helpers.sh, so consecutive supervision gaps, gap-closing semantic checks, and retry-separating checks are asserted nowhere mechanically"
    echo "blocker_class: none (red is the expected terminal state; GREEN implementer: step 115 — implement __assert_supervision_cadence <session-export> <verdict-out> in helpers.sh per the contract in this file's header)"
} >> "$OUT" 2>&1

echo "RED CONFIRMED: $FAIL failing assertion(s) — the supervision-cadence predicate is ABSENT as an enforced predicate (evaluator_present=$EVALUATOR_PRESENT; fixture verdicts: correct='${f2_verdict:-none}' wait-on-hang='${f3_verdict:-none}' retry-no-check='${f4_verdict:-none}' counter-no-check='${f5_verdict:-none}'). The discipline was practiced in this session's pipeline supervision (every prior item's polls inspected the run's session DB) but no enforcement scenario asserts it. GATE EXPECTATION FOR GREEN: implement __assert_supervision_cadence <session-export-json> <verdict-yaml-out> in helpers.sh (pure decision function, no model dispatch) — it parses the ordered event stream of a supervising session, measures gaps between consecutive supervision actions (with-test-home run invocations and semantic-check reads of the run's session DB/export), requires every gap ≤300s AND closed by a semantic-check action (read of session.yaml/session DB paths or export-procedure invocations), requires run-retry invocations to be separated by an intervening semantic check, emits verdict: PASS|FAIL with violations[] (max gap, unchecked retries, missing checks); the four synthetic fixtures under $FIX_ROOT/sc17-* are the polarity suite (evidence: $OUT, .opencode#2456 SC-17)." >&2
exit 1

# Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)
