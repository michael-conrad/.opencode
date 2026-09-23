#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
#
# Behavioral test: 2456-sc10-false-signal-annotation-red
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# SC-10 (.opencode#2456, plan-03 Item 10, phase-4 RED): a reproduced wrong abort
# — the #2454-style duplicate-event over-count (a monitor false positive that
# aborts a healthy run) — produces a false_signal annotation in the
# determination record.
#
# Exercise surface — the FULL monitored-run path (behavior_run under
# BEHAVIOR_SEMANTIC_MONITOR=1 with a FRESH test home provisioned by
# with-test-home): a real SHORT heartbeat run is launched, and a fixture
# watcher injects duplicate event rows into the run's live session event DB
# (duplicating a COMPLETED tool part under fresh part ids once a completed
# tool call exists). The duplicate-event over-count makes the mechanical
# identical-input signal fire against a run that was progressing normally —
# the exact #2454 false-positive class (a healthy run aborted by over-counted
# events). The monitor then takes the §14 abort path, behavior_run's post-run
# block writes determination.yaml with run_path: monitor-abort, and the wrong
# abort must be folded into the record as a false_signal annotation (R-6).
#
# RED condition (known gap): false_signal_annotations is a DECLARED-EMPTY
# field in __write_determination_record (false_signal_annotations: []) with
# NO appender anywhere in helpers.sh/with-test-home — after a wrong abort the
# record still carries the empty list, so the annotation is never folded in.
# The assertion (annotation present) FAILS ⇒ the scenario exits 1 (red).
#
# GREEN expectation (recorded here for the Item-10 GREEN task): after a
# reproduced wrong abort, determination.yaml carries a false_signal annotation
# — a NON-EMPTY false_signal_annotations list (or an equivalent annotation
# entry) naming the over-count wrong abort (abort_reason + wrong-abort
# classification), appended under the append-only semantics of R-8/R-6.
#
# PRECONDITION GUARDS (exit 2 = invalid RED, requires diagnosis — never a
# verdict): (a) a scenario evidence directory + monitor.log exist (the
# monitored run took a path through behavior_run's post-run block); (b) the
# WRONG ABORT was actually reproduced — run_path: monitor-abort in the
# determination record AND the monitor poll log shows the identical-input
# signal firing (ABORT: signal 1) — without a reproduced wrong abort the
# annotation contract was never exercised; (c) the injected duplicate events
# were written (injection marker present). Without these, NOT a RED verdict.
#
# Isolation mandates honored: FRESH test home provisioned by behavior_run via
# with-test-home (NO manual home construction); the whole run block is
# launched DETACHED (setsid) per SC-19 and supervised with SQLite-DB semantic
# polls ≤5 min apart; the own kill is the abort signal (GNU `timeout`
# FORBIDDEN per §5; this script needs no process kills beyond the monitor's
# own); the fixture writes only under tmp/ (no production state touched); the
# injected rows are test-home-scoped (the freshest tmp/test-home-* DB).
#
# §15 targeted-execution mandate: run this ONE named scenario via
#   BEHAVIOR_PHASE=RED bash .opencode/tests-v2/behaviors/2456-sc10-false-signal-annotation-red.sh
# launched DETACHED and polled with the bash tool timeout >= 600000 ms.
#
# Ordered precondition cycle (§4): the scenario file is committed and pushed
# to the submodule remote BEFORE the isolated run (SC-16 commit discipline;
# NEVER --no-verify).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2456-sc10-false-signal-annotation-red"

ER="$(cd "$SCRIPT_DIR/../../.." && pwd)/tmp/2456/artifacts"
mkdir -p "$ER"
EV_ROOT="$ER/${SCENARIO_NAME}"
rm -rf "$EV_ROOT"
mkdir -p "$EV_ROOT"

# §11 real-domain heartbeat prompt: deterministic multi-cycle run with DISTINCT
# appends. Each cycle appends its own line via a separate write tool call —
# distinct inputs, so the run is steadily progressing; the over-count false
# positive comes from the injected duplicate events, not the agent's work.
SCENARIO_PROMPT="Follow this repository working protocol exactly — it is the entire task. Working protocol (run log): Create a file named run-log.md in the current project root if it does not exist. Then append the following lines to run-log.md in order, exactly one line per work cycle (one write tool call per line — never batch multiple lines into a single write): run 01: cycle logged / run 02: cycle logged / run 03: cycle logged. After all three lines are appended, the protocol loop is complete — stop."

rm -f tmp/.behavior-run.lock

# ── Fixture: duplicate-event over-count injection watcher (background) ───────
# Waits for the run's live session DB to carry >=1 COMPLETED tool part, then
# inserts 2 duplicate rows (fresh event ids, same tool+input) — the
# duplicate-event over-count that reproduced the #2454 wrong abort.
INJECTION_MARK="$EV_ROOT/injection-done"
(
    for i in $(seq 1 40); do
        db=$(ls -t "$PARENT_REPO_DIR"/tmp/test-home-*/.local/share/opencode/opencode.db 2>/dev/null | head -1)
        if [ -n "$db" ] && [ -f "$db" ]; then
            python3 - "$db" <<INJPY
import json, sqlite3, sys, time
db = sys.argv[1]
conn = sqlite3.connect(db, timeout=20)
c = conn.cursor()
rows = c.execute("SELECT id, aggregate_id, seq, type, data FROM event ORDER BY seq").fetchall()
target = None
for rid, agg, seq, typ, data in rows:
    try:
        d = json.loads(data or "{}")
    except Exception:
        continue
    part = d.get("part")
    if not isinstance(part, dict):
        continue
    if part.get("type") == "tool" and (part.get("state") or {}).get("status") == "completed":
        target = (rid, agg, seq, typ, data)
if target:
    rid, agg, seq, typ, data = target
    nxt = c.execute("SELECT MAX(seq) FROM event WHERE aggregate_id=?", (agg,)).fetchone()[0] + 1
    base = rid.rstrip()
    for k in (1, 2):
        c.execute(
            "INSERT OR IGNORE INTO event (id, aggregate_id, seq, type, data) VALUES (?,?,?,?,?)",
            (f"{base}dup{k}", agg, nxt, typ, data),
        )
        nxt += 1
    conn.commit()
    print(f"injected dup of {rid} into {db}", flush=True)
else:
    print("no completed tool part found", flush=True)
conn.close()
INJPY
            if [ "$(sqlite3 "$db" "SELECT COUNT(*) FROM event WHERE id LIKE '%dup%';" 2>/dev/null || echo 0)" -ge 2 ]; then
                echo "injected" > "$INJECTION_MARK"
                break
            fi
        fi
        sleep 5
    done
) > "$EV_ROOT/injection.log" 2>&1 &
inject_pid=$!

# ── The monitored run (full behavior_run path, FRESH test home) ───────────────
BEHAVIOR_SEMANTIC_MONITOR=1
# 60 polls x 30s = 30 min monitored budget; SHORT run (three tool calls)
BEHAVIOR_MONITOR_MAX_POLLS=60
export BEHAVIOR_SEMANTIC_MONITOR BEHAVIOR_MONITOR_MAX_POLLS

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT" || true
kill "$inject_pid" 2>/dev/null || true
rm -f tmp/.behavior-run.lock

# ── SC-10 assertion: false_signal annotation folded into the record ──────────
artifact_dir="${BEHAVIOR_ARTIFACT_DIR:-}"
if [ -z "$artifact_dir" ] || [ ! -d "$artifact_dir" ]; then
    echo "PRECONDITION-FAIL: no scenario evidence directory produced (BEHAVIOR_ARTIFACT_DIR='${artifact_dir:-unset}') — harness failure, not a RED verdict" >&2
    exit 2
fi
if [ ! -f "$artifact_dir/monitor.log" ]; then
    echo "PRECONDITION-FAIL: monitor.log missing from $artifact_dir — the semantic monitor did not run; not a RED verdict" >&2
    exit 2
fi
if [ ! -f "$INJECTION_MARK" ]; then
    echo "PRECONDITION-FAIL: duplicate-event injection never landed (no marker at $INJECTION_MARK; see $EV_ROOT/injection.log) — the over-count fixture state was never produced; not a RED verdict" >&2
    exit 2
fi
if ! grep -q "ABORT: signal 1 (identical tool input" "$artifact_dir/monitor.log"; then
    echo "PRECONDITION-FAIL: the identical-input signal never fired against the run (monitor.log at $artifact_dir/monitor.log) — a wrong abort was not reproduced; annotation contract not exercised, not a RED verdict" >&2
    exit 2
fi
if [ ! -f "$artifact_dir/determination.yaml" ]; then
    echo "PRECONDITION-FAIL: determination.yaml missing from $artifact_dir — no determination record written; not a RED verdict" >&2
    exit 2
fi
if ! grep -q 'run_path: monitor-abort' "$artifact_dir/determination.yaml"; then
    echo "PRECONDITION-FAIL: determination record does not carry run_path: monitor-abort — the abort was not recorded as a monitor abort; not a RED verdict" >&2
    exit 2
fi
# The SC-10 predicate: a NON-EMPTY false_signal_annotations list (or an
# appended annotation entry) naming the wrong abort.
det="$artifact_dir/determination.yaml"
annotated=0
if grep -q '^  false_signal_annotations: \[\( *\)\]$' "$det"; then
    annotated=0
elif grep -q 'false_signal_annotations' "$det" && ! grep -q '^  false_signal_annotations: \[\]$' "$det"; then
    annotated=1
fi

PHASE="${BEHAVIOR_PHASE:-RED}"

if [ "$PHASE" = "GREEN" ]; then
    if [ "$annotated" = "1" ]; then
        echo "GREEN: the wrong abort was annotated — false_signal_annotations carries an appended annotation naming the over-count wrong abort (record: $det)" >&2
        exit 0
    fi
    echo "GREEN NOT SATISFIED (RED confirmed in GREEN phase): after a reproduced wrong abort (monitor-abort, identical-input signal fired), $det still carries the DECLARED-EMPTY false_signal_annotations: [] — no appender exists (known gap, .opencode#2456 SC-10 / R-6)" >&2
    exit 1
fi

if [ "$annotated" = "1" ]; then
    echo "RED ABORT — ALREADY_GREEN: false_signal_annotations already carries an annotation after the wrong abort, so a failing RED test cannot be validly produced" >&2
    exit 3
fi

{ echo "== SC-10 RED evidence (.opencode#2456) =="
  echo "test: ${SCENARIO_NAME}"
  echo "sc_ref: SC-10 (plan-03 Item 10, phase 4, item 10)"
  echo "evidence_type: behavioral"
  echo "wrong_abort_reproduced: run_path monitor-abort + ABORT signal 1 (identical tool input) fired against a healthy heartbeat run (injected duplicate)"
  echo "injection: $INJECTION_MARK"
  echo "determination_record: $det"
  echo "false_signal_annotations: DECLARED-EMPTY ([]) — no appender in helpers.sh/with-test-home"
  echo "phase: RED"
  echo "verdict: RED (exit 1) — the #2454-style duplicate-event over-count wrong abort produced NO false_signal annotation in the determination record"
  echo "blocker_class: none (red is the expected terminal state; GREEN implementer: Item 10 fix — fold the wrong abort into false_signal_annotations under the R-8 append-only semantics)"
} > "$ER/pipeline-red-10-${SCENARIO_NAME}.yaml" 2>&1

echo "RED CONFIRMED: the reproduced wrong abort (monitor-abort after the duplicate-event over-count) was NOT annotated — $det carries the declared-empty false_signal_annotations: [] with no appender anywhere (R-6 gap, .opencode#2456 SC-10). GATE EXPECTATION FOR GREEN: after a wrong abort, the determination record must carry a NON-EMPTY false_signal_annotations list (or an equivalent appended annotation entry) naming the over-count wrong abort (abort_reason + wrong-abort classification), appended under R-8 append-only semantics — never silently left empty." >&2
exit 1
