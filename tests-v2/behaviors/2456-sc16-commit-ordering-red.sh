#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Structural test: 2456-sc16-commit-ordering-red
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# SC-16 (.opencode#2456, plan-06 phase-6 item, RED — plan step 109): GREEN-phase
# dispatches for behavioral scenarios commit and push all test-needed changes to
# the feature branch BEFORE the isolated test-home run — the §4 ordered cycle
# (commit → push → fetch/verify → run) is MECHANICAL, never a deliberation
# point; the isolated run pulls the effective commit from the remote branch.
#
# SC-16 SINGLE-ASSERTION TARGET (spec.md single-assertion justification): the
# ordering invariant of the §4 ordered cycle at GREEN-phase dispatch — all
# test-needed changes committed AND pushed to the feature branch before the
# isolated test-home run starts. Commit deliberation (asking whether to commit,
# narrating commit options, or running the test against uncommitted state) is
# the absence-side of the same ordering predicate — one rule (commit+push
# mechanically precede the run), one assertion.
#
# BASELINE (known gap, recorded honestly): the discipline was applied in
# pipeline practice (every prior RED/GREEN item recorded a pre_run_cycle
# commit+push before the run) but NO enforcement scenario asserts the ordering
# predicate — it is ABSENT as an enforced predicate. This scenario is that
# enforcement.
#
# EXERCISE SURFACE — the session-export ordering evaluator: the predicate is
# asserted FROM SESSION-EXPORT EVIDENCE (the opencode SQLite session export,
# the §2 PRIMARY evaluation source), parsed as an ordered event stream:
#   - bash tool calls whose command matches `git commit` / `git push`
#   - the with-test-home run invocation (command containing `with-test-home`
#     and `opencode run` — the harness's isolated test-home run surface)
#   - test-needed changes (write/edit tool calls)
#   - reasoning/text parts between the first change and the first run that
#     deliberate about whether/when to commit or push (commit-deliberation
#     turns — the #2437 SC-2 GREEN dispatch cancelled mid-deliberation class)
#   - prohibited `--no-verify` flags on commit/push commands
#
# SYNTHETIC FIXTURES (NO live model runs — no opencode run, no behavior_run,
# no monitor lifecycle): five synthetic session exports in the harness's own
# __export_sqlite_to_yaml JSON format exercise both polarities of the
# predicate:
#   sc16-correct           commit → push → fetch/verify → with-test-home run  (PASS)
#   sc16-run-before-push   run launched BEFORE commit/push                        (FAIL)
#   sc16-run-before-commit run launched before commit; commit without push        (FAIL)
#   sc16-deliberation      change → commit-deliberation reasoning → run           (FAIL)
#   sc16-no-verify         commit --no-verify / push --no-verify then run         (FAIL)
#
# The canonical evaluator the predicate needs is `__assert_commit_ordering`
# in helpers.sh (same pure-decision-function pattern as
# __undetermined_ceiling_check / __interpret_classify_dispatch /
# __fold_false_signal). Contract GREEN must implement:
#   __assert_commit_ordering <session-export-json> <verdict-yaml-out>
#   exit 0 = ordering predicate holds; exit non-zero = violation, with the
#   verdict YAML recording verdict: PASS|FAIL, first_change_seq,
#   first_commit_seq, first_push_seq, first_run_seq, first_fetch_seq
#   (recorded, non-gating), deliberation_turns (seq + matched marker),
#   prohibited_flags (seq + command), and violations[].
#
# RED condition (expected outcome today): helpers.sh carries NO commit-ordering
# evaluator — the ordering predicate is unenforced (no mechanical assertion
# exists anywhere in the harness), so every assertion fails ⇒ exit 1 (RED).
# If the evaluator already exists AND distinguishes all five fixtures
# correctly (correct fixture passes; all four violating fixtures fail), the
# predicate is already enforced by construction → ALREADY_GREEN classified
# abort (exit 3), recorded as the item's genuine outcome.
#
# PRECONDITION GUARDS (exit 2 = invalid RED, requires diagnosis — never a
# verdict): the synthetic fixture directory must have been created and all
# five session-export fixtures must parse as JSON with an event table (the
# assertion surface is the fixture set; a missing/unparseable fixture is a
# harness defect, not a RED verdict).
#
# §15 targeted-execution mandate: run this ONE named scenario via
#   bash .opencode/tests-v2/behaviors/2456-sc16-commit-ordering-red.sh
# (bash tool timeout >= 600000ms). No model dispatch — no supervision poll
# schedule is attached (SC-19 applies to opencode runs; there is none here).
#
# Ordered precondition cycle (§4/SC-16): the scenario file itself is committed
# and pushed to the submodule remote BEFORE this test run (mechanical, no
# deliberation; NEVER --no-verify).

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2456-sc16-commit-ordering-red"

ER="$(cd "$SCRIPT_DIR/../../.." && pwd)/tmp/2456/artifacts"
mkdir -p "$ER"
# Idempotence: clear this test's own stale artifacts.
rm -f "$ER"/pipeline-red-16sc*

FIX_ROOT="$ER/synthetic"
rm -rf "$FIX_ROOT"/sc16-*
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

echo "== SC-16 RED check: §4 commit-ordering predicate — commit+push precede the with-test-home run, no commit-deliberation turns (.opencode#2456) =="

# ══ Synthetic session-export fixtures (EVENT-DRIVEN, deterministic) ══════════
python3 - "$FIX_ROOT" <<'PYEOF'
import json, os, sys

fix_root = sys.argv[1]
AGG = "ses_0d51sc16fixture000000000000000000000"
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

def write(seq, path, content):
    return tool_part(seq, "write", "completed", {"filePath": path, "content": content})

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

PROMPT = '"You are a sub-agent. Execute the GREEN task: author the scenario, then run it per the §4 ordered cycle."'
RUN_CMD = "setsid bash .opencode/tests-v2/with-test-home opencode run 'fixture probe' > out.log 2> err.log"
COMMIT_CMD = 'git add .opencode/tests-v2/behaviors/2456-sc16-commit-ordering-red.sh && git commit -m "2456 SC-16 RED: scenario"'
PUSH_CMD = "git push origin feature/stacked-2454-2449-2437-2424"
FETCH_CMD = "git fetch origin && git branch -r --contains HEAD"

# ── Fixture 1: correct ordering — change → commit → push → fetch/verify → run ──
build("sc16-correct", [
    evt(0, "session.created.1", {"sessionID": AGG}),
    text_part(2, PROMPT),
    reasoning_part(4, "Scenario authored. Committing and pushing the scenario files now, then launching the isolated run — the §4 cycle is mechanical."),
    write(6, ".opencode/tests-v2/behaviors/2456-sc16-commit-ordering-red.sh", "#!/bin/bash\n"),
    bash(8, COMMIT_CMD),
    bash(10, PUSH_CMD),
    bash(12, FETCH_CMD),
    bash(14, RUN_CMD),
])

# ── Fixture 2: run-before-push — the isolated run launched BEFORE commit+push ──
build("sc16-run-before-push", [
    evt(0, "session.created.1", {"sessionID": AGG}),
    text_part(2, PROMPT),
    write(4, ".opencode/tests-v2/behaviors/2456-sc16-commit-ordering-red.sh", "#!/bin/bash\n"),
    bash(6, RUN_CMD),
    bash(8, COMMIT_CMD),
    bash(10, PUSH_CMD),
])

# ── Fixture 3: run-before-commit — run against uncommitted state; commit but never push ──
build("sc16-run-before-commit", [
    evt(0, "session.created.1", {"sessionID": AGG}),
    text_part(2, PROMPT),
    write(4, ".opencode/tests-v2/behaviors/2456-sc16-commit-ordering-red.sh", "#!/bin/bash\n"),
    bash(6, RUN_CMD),
    bash(8, COMMIT_CMD),
])

# ── Fixture 4: commit-deliberation turn between the change and the run ────────
build("sc16-deliberation", [
    evt(0, "session.created.1", {"sessionID": AGG}),
    text_part(2, PROMPT),
    write(4, ".opencode/tests-v2/behaviors/2456-sc16-commit-ordering-red.sh", "#!/bin/bash\n"),
    reasoning_part(6, "The scenario files are edited. Should I commit first, or run the isolated test right away? Let me think about whether to commit now or after seeing the test output — maybe I should ask the developer for authorization to push."),
    bash(8, RUN_CMD),
    bash(10, COMMIT_CMD),
    bash(12, PUSH_CMD),
])

# ── Fixture 5: prohibited --no-verify flags on the commit/push ────────────────
build("sc16-no-verify", [
    evt(0, "session.created.1", {"sessionID": AGG}),
    text_part(2, PROMPT),
    write(4, ".opencode/tests-v2/behaviors/2456-sc16-commit-ordering-red.sh", "#!/bin/bash\n"),
    bash(6, 'git add .opencode/tests-v2/behaviors/2456-sc16-commit-ordering-red.sh && git commit --no-verify -m "2456 SC-16 RED"'),
    bash(8, "git push --no-verify origin feature/stacked-2454-2449-2437-2424"),
    bash(10, RUN_CMD),
])
PYEOF
fixture_rc=$?

# ── Precondition guards: fixtures built and parseable ────────────────────────
if [ "$fixture_rc" -ne 0 ]; then
    echo "PRECONDITION-FAIL: synthetic fixture generation failed (rc=$fixture_rc) — harness defect, not a RED verdict" >&2
    exit 2
fi
FIXTURES="sc16-correct sc16-run-before-push sc16-run-before-commit sc16-deliberation sc16-no-verify"
for fx in $FIXTURES; do
    if ! python3 -c "import json,sys; d=json.load(open('$FIX_ROOT/$fx/session.yaml')); sys.exit(0 if d.get('tables',{}).get('event',{}).get('rows') else 1)" 2>/dev/null; then
        echo "PRECONDITION-FAIL: fixture $FIX_ROOT/$fx/session.yaml missing or unparseable (no event rows) — the session-export assertion surface is absent; not a RED verdict" >&2
        exit 2
    fi
done
echo "  [fixtures] 5 synthetic session exports built under $FIX_ROOT (no live model runs)"

# ══ Assertion 1 — the ordering evaluator exists in helpers.sh ════════════════
# The §4 ordering predicate needs a mechanical session-export assertion
# surface; today none exists (baseline gap — the discipline lived in practice
# and in narrative pre_run_cycle notes, never as an enforced predicate).
if grep -q '^__assert_commit_ordering()' "$SCRIPT_DIR/helpers.sh"; then
    check_pass "ordering evaluator __assert_commit_ordering defined in helpers.sh"
    EVALUATOR_PRESENT=1
else
    check_fail "ordering evaluator __assert_commit_ordering defined in helpers.sh" \
        "no session-export commit-ordering evaluator exists in helpers.sh — the §4 commit+push-before-run predicate is UNENFORCED (applied in practice, never mechanically asserted) (RED)"
    EVALUATOR_PRESENT=0
fi

evaluate_fixture() { # $1 fixture name; sets ev_rc; writes verdict yaml
    local fx="$1"
    local out="$FIX_ROOT/$fx/ordering-verdict.yaml"
    rm -f "$out"
    if [ "$EVALUATOR_PRESENT" = "1" ] && [ "$(type -t __assert_commit_ordering)" = function ]; then
        __assert_commit_ordering "$FIX_ROOT/$fx/session.yaml" "$out"
        ev_rc=$?
    else
        ev_rc=127
        printf 'ordering_assertion: commit_push_before_run\neverdict: NOT_EVALUABLE\nevaluator: absent (helpers.sh)\n' > "$out"
    fi
    ev_verdict="$(grep -E '^verdict: ' "$out" 2>/dev/null | head -1 | sed 's/^verdict: //' || true)"
    return 0
}

# ══ Assertion 2 — correct-ordering fixture evaluates PASS ════════════════════
evaluate_fixture sc16-correct; f2_rc=$ev_rc; f2_verdict="$ev_verdict"
if [ "$f2_rc" -eq 0 ] && [ "$f2_verdict" = "PASS" ]; then
    check_pass "correct-ordering fixture (commit → push → fetch/verify → run) evaluates PASS (rc=$f2_rc)"
else
    check_fail "correct-ordering fixture (commit → push → fetch/verify → run) evaluates PASS" \
        "evaluator rc=$f2_rc verdict='${f2_verdict:-none}' — a mechanically compliant §4 cycle must pass the ordering assertion"
fi

# ══ Assertion 3 — run-before-push fixture evaluates FAIL ═════════════════════
evaluate_fixture sc16-run-before-push; f3_rc=$ev_rc; f3_verdict="$ev_verdict"
if [ "$EVALUATOR_PRESENT" = "1" ] && [ "$f3_rc" -ne 0 ] && [ "$f3_verdict" = "FAIL" ]; then
    check_pass "run-before-push fixture evaluates FAIL (rc=$f3_rc) — the run launched before commit+push is the ordering violation"
else
    check_fail "run-before-push fixture evaluates FAIL" \
        "evaluator rc=$f3_rc verdict='${f3_verdict:-none}' — a run launched before commit+push must fail the ordering assertion"
fi

# ══ Assertion 4 — run-before-commit fixture evaluates FAIL ═══════════════════
evaluate_fixture sc16-run-before-commit; f4_rc=$ev_rc; f4_verdict="$ev_verdict"
if [ "$EVALUATOR_PRESENT" = "1" ] && [ "$f4_rc" -ne 0 ] && [ "$f4_verdict" = "FAIL" ]; then
    check_pass "run-before-commit fixture evaluates FAIL (rc=$f4_rc) — running against uncommitted state with no push is the ordering violation"
else
    check_fail "run-before-commit fixture evaluates FAIL" \
        "evaluator rc=$f4_rc verdict='${f4_verdict:-none}' — a run against uncommitted/unpushed state must fail the ordering assertion"
fi

# ══ Assertion 5 — commit-deliberation fixture evaluates FAIL ═════════════════
evaluate_fixture sc16-deliberation; f5_rc=$ev_rc; f5_verdict="$ev_verdict"
f5_delib="$(grep -c 'deliberation' "$FIX_ROOT/sc16-deliberation/ordering-verdict.yaml" 2>/dev/null || true)"
if [ "$EVALUATOR_PRESENT" = "1" ] && [ "$f5_rc" -ne 0 ] && [ "$f5_verdict" = "FAIL" ] && [ "${f5_delib:-0}" -ge 1 ]; then
    check_pass "commit-deliberation fixture evaluates FAIL (rc=$f5_rc) with the deliberation turn recorded — commit deliberation between the change and the run is prohibited"
else
    check_fail "commit-deliberation fixture evaluates FAIL with the deliberation turn recorded" \
        "evaluator rc=$f5_rc verdict='${f5_verdict:-none}' deliberation_records=${f5_delib:-0} — deliberating about whether/when to commit (the #2437 cancelled-mid-deliberation class) must fail the ordering assertion and be recorded"
fi

# ══ Assertion 6 — --no-verify fixture evaluates FAIL ═════════════════════════
evaluate_fixture sc16-no-verify; f6_rc=$ev_rc; f6_verdict="$ev_verdict"
f6_flag="$(grep -cE 'no.verify|prohibited' "$FIX_ROOT/sc16-no-verify/ordering-verdict.yaml" 2>/dev/null || true)"
if [ "$EVALUATOR_PRESENT" = "1" ] && [ "$f6_rc" -ne 0 ] && [ "$f6_verdict" = "FAIL" ] && [ "${f6_flag:-0}" -ge 1 ]; then
    check_pass "no-verify fixture evaluates FAIL (rc=$f6_rc) with the prohibited flag recorded — commit/push --no-verify is never permitted"
else
    check_fail "no-verify fixture evaluates FAIL with the prohibited flag recorded" \
        "evaluator rc=$f6_rc verdict='${f6_verdict:-none}' flag_records=${f6_flag:-0} — --no-verify on commit/push must fail the ordering assertion and be recorded"
fi

# ══ Evidence artifact ════════════════════════════════════════════════════════
OUT="$ER/pipeline-red-16sc-sc16-summary.yaml"
{
    echo "== SC-16 RED evidence (.opencode#2456) =="
    echo "test: ${SCENARIO_NAME}"
    echo "sc_ref: SC-16 (plan-06 Item 16, phase 6, step 109)"
    echo "evidence_type: behavioral (session-export ordering assertion; synthetic fixtures per task directive — no live model runs)"
    echo "model_dispatch: none (synthetic session-export fixtures)"
    echo "synthetic_fixtures: $FIX_ROOT/sc16-{correct,run-before-push,run-before-commit,deliberation,no-verify}/session.yaml"
    echo "evaluator_present: $EVALUATOR_PRESENT"
    echo "fixture_eval_rc: correct=$f2_rc run-before-push=$f3_rc run-before-commit=$f4_rc deliberation=$f5_rc no-verify=$f6_rc"
    echo "fixture_verdicts: correct='${f2_verdict:-none}' run-before-push='${f3_verdict:-none}' run-before-commit='${f4_verdict:-none}' deliberation='${f5_verdict:-none}' no-verify='${f6_verdict:-none}'"
    echo "phase: RED"
    echo "fail_assertions: $FAIL"
    echo "pass_assertions: $PASS"
} > "$OUT" 2>&1

if [ "$FAIL" -eq 0 ]; then
    echo "RED ABORT — ALREADY_GREEN: the commit-ordering evaluator exists in helpers.sh and distinguishes all five fixtures correctly (correct fixture PASS; run-before-push/run-before-commit/deliberation/no-verify fixtures FAIL) — the §4 commit+push-before-run ordering predicate is already enforced by construction, so a failing RED test cannot be validly produced" >&2
    {
        echo "verdict: RED_ABORT_ALREADY_GREEN (exit 3) — the ordering predicate is already enforced; a failing RED test cannot be validly produced"
    } >> "$OUT" 2>&1
    exit 3
fi

{
    echo "verdict: RED (exit 1) — the §4 commit+push-before-run ordering predicate is ABSENT as an enforced predicate: no session-export ordering evaluator exists in helpers.sh, so the ordering invariant is asserted nowhere mechanically"
    echo "blocker_class: none (red is the expected terminal state; GREEN implementer: step 110 — implement __assert_commit_ordering <session-export> <verdict-out> in helpers.sh per the contract in this file's header)"
} >> "$OUT" 2>&1

echo "RED CONFIRMED: $FAIL failing assertion(s) — the §4 commit-ordering predicate is ABSENT as an enforced predicate (evaluator_present=$EVALUATOR_PRESENT; fixture verdicts: correct='${f2_verdict:-none}' run-before-push='${f3_verdict:-none}' run-before-commit='${f4_verdict:-none}' deliberation='${f5_verdict:-none}' no-verify='${f6_verdict:-none}'). The discipline was applied in pipeline practice (every prior item's pre_run_cycle narrative) but no enforcement scenario asserts it. GATE EXPECTATION FOR GREEN: implement __assert_commit_ordering <session-export-json> <verdict-yaml-out> in helpers.sh (pure decision function, no model dispatch) — it parses the ordered event stream, requires the first commit AND first push tool calls to precede the first with-test-home run invocation, records (non-gating) first_fetch_seq, records commit-deliberation turns (reasoning/text parts between the first test-needed change and the first run deliberating whether/when to commit or push — markers: should I commit / whether to commit|push / commit or not / do I need to commit|push / authorization to commit|push / ask ... authorization ... push / wait ... before commit|push / commit now or), rejects --no-verify commit/push commands, emits verdict: PASS|FAIL with violations[]; the five synthetic fixtures under $FIX_ROOT/sc16-* are the polarity suite (evidence: $OUT, .opencode#2456 SC-16)." >&2
exit 1