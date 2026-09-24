#!/bin/bash
# Behavioral test: 2456-sc11-redetermination-gate-enforcement
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-11 (.opencode#2456, plan-04 Item 11, phase-4): the standalone behavioral
# enforcement scenario for the with-test-home resume gate — re-dispatch/re-run
# of a surviving test home whose aborted run carries NO recorded
# non-undetermined determination is BLOCKED; unregulated (determination-
# gate-less) state dispatches ungated.
#
# Registered as a new `test-enforcement.sh --list` entry (enabling precondition
# of the same single deliverable — spec.md SC-11). Depends on Phase 3: the
# scenario exercises exactly the SC-8 gate predicates.
#
# Exercise surface — the cross-invocation resume path (#2432 SC-11):
#   with-test-home --resume-home <prior-home> opencode run --continue '<msg>'
#
# RED instrumentation (demonstrates the assertion CAN FAIL — without touching
# with-test-home itself): the identical gate-exercise is run against a
# SIMULATED pre-gate state — a copy of with-test-home with
# __sc8_determination_gate stubbed out, placed under tmp/2456/artifacts/ —
# where the resume proceeds UNGATED (no FATAL gate line appears; inference is
# dispatched). That observed failure is the RED evidence, committed under
# tmp/. The real harness is never touched.
#
# GREEN expectation (gated harness): a fresh
# 2456-sc11-redetermination-gate-enforcement run against the real harness FAILS
# FAST with a FATAL-class block line naming the missing non-undetermined
# determination: ^FATAL: .*determination.*(resume|re-run|continue) — no
# inference dispatched.
#
# ASSERTION TARGET — harness infrastructure, not model output: the verdict-
# bearing assertion is deterministic (a FATAL-class gate line on the resume
# invocation's stderr). The §1 exit-0 unconditional paradigm does NOT apply
# to a harness-behavior enforcement test whose assertion target is the
# harness itself (same exception as 2456-sc1..sc8).
#
# Isolation mandates honored: FRESH test home provisioned via with-test-home
# (NO manual home construction); DETACHED setsid launches; own kill is the
# abort signal (GNU `timeout` FORBIDDEN per §5); stderr-only TEST_HOME
# discovery; the resume attempt runs through the harness's own --resume-home
# surface (or the simulated stub copy in RED mode only).
#
# Phase dispatch: BEHAVIOR_PHASE=GREEN run the exercise against the real
# gated harness and expect the FATAL block. BEHAVIOR_PHASE=RED (default)
# run the exercise against the simulated pre-gate copy and expect UNGATED
# dispatch — the RED condition recorded: unregulated state dispatches ungated.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2456-sc11-redetermination-gate-enforcement"

ER="$(cd "$SCRIPT_DIR/../../.." && pwd)/tmp/2456/artifacts"
mkdir -p "$ER"
EV_ROOT="$ER/${SCENARIO_NAME}"
rm -rf "$EV_ROOT"
mkdir -p "$EV_ROOT"

# §11 real-domain heartbeat protocol (same shape as sc6/sc7/sc8 — bounded).
SCENARIO_PROMPT="Follow this repository working protocol exactly — it is the entire task. Working protocol (run log): Create a file named run-log.md in the current project root if it does not exist. Then append the following lines to run-log.md in order, exactly one line per work cycle (one write tool call per line — never batch multiple lines into a single write): run 01: cycle logged / run 02: cycle logged / run 03: cycle logged / run 04: cycle logged. After all four lines are appended, the protocol loop is complete — stop."

RED_STATUS="${RED_STATUS:-}"
if [ -z "$RED_STATUS" ]; then
    # RED condition recorded: unregulated state (determination-gate stubbed)
    # dispatches ungated. Populated by the RED instrumentation run.
    RED_STATUS="unregulated-state-not-yet-exercised"
fi

# ─── Simulated pre-gate copy (RED instrumentation surface) ───
# Copy of with-test-home with __sc8_determination_gate stubbed out. This copy
# lives ONLY under tmp/2456/artifacts/ — with-test-home itself is untouched.
STUB_COPY="$ER/${SCENARIO_NAME}/with-test-home-pregate-stub"
if [ ! -f "$STUB_COPY" ]; then
    sed -E 's/^ *__sc8_determination_gate "?\$TEST_HOME"?$/    # [RED-INSTRUMENTATION-ONLY] pre-gate: determination gate stubbed out for assertion-failure demonstration/' \
        ".opencode/tests-v2/with-test-home" > "$STUB_COPY" \
        || true
    chmod +x "$STUB_COPY" 2>/dev/null || true
fi

# ─── Phase A: provision a fresh test home via a SHORT dispatch, then abort ──
rm -f tmp/.behavior-run.lock

run_dir="$EV_ROOT/probe-dispatch"
mkdir -p "$run_dir"
setsid bash .opencode/tests-v2/with-test-home \
    opencode run "$SCENARIO_PROMPT" \
    > "$run_dir/stdout.log" 2> "$run_dir/stderr.log" &
dispatch_pid=$!

# Poll (≤240-290s budget): wait for TEST_HOME emission + a live session store;
# every poll reads the live SQLite event stream (full range).
home=""
polls=0
while [ "$polls" -lt 12 ]; do
    polls=$((polls+1))
    row="polls=$polls pid_alive=$(kill -0 "$dispatch_pid" 2>/dev/null && echo yes || echo no)"
    if grep -q '^TEST_HOME=' "$run_dir/stderr.log" 2>/dev/null; then
        home=$(grep '^TEST_HOME=' "$run_dir/stderr.log" | head -1 | sed 's/^TEST_HOME=//')
        store="$home/.local/share/opencode/opencode.db"
        etotal=0
        if [ -f "$store" ]; then
            etotal=$(sqlite3 "$store" "SELECT COUNT(*) FROM event;" 2>/dev/null || echo 0)
        fi
        row="$row home=$home events=${etotal:-0}"
        if [ "${etotal:-0}" -ge 1 ]; then
            printf '%s RED-INSTRUMENT poll: %s\n' "$SCENARIO_NAME" "$row" >&2
            break
        fi
    else
        row="$row no_test_home_yet"
    fi
    printf '%s RED-INSTRUMENT poll: %s\n' "$SCENARIO_NAME" "$row" >&2
    kill -0 "$dispatch_pid" 2>/dev/null || break
    sleep 20
done

# Abort (kill) the dispatch — the aborted-dispatch state under test. The own
# kill is the monitored abort signal (GNU timeout FORBIDDEN per §5).
kill -- -"$dispatch_pid" 2>/dev/null || true
sleep 2
kill -- -"$dispatch_pid" -9 2>/dev/null || true
sleep 1

printf '%s' "$polls" > "$EV_ROOT/provision-polls"
[ -n "$home" ] && printf '%s' "$home" > "$EV_ROOT/test-home-path"

# ─── Phase B: gate probe (the enforcement assertion surface) ───
# Invocation wrapper depends on phase: RED → simulated pre-gate copy;
# GREEN → the real gated harness.
PHASE="${BEHAVIOR_PHASE:-RED}"
probe_bin=".opencode/tests-v2/with-test-home"
if [ "$PHASE" = "RED" ]; then
    probe_bin="$STUB_COPY"
fi

gate_dir="$EV_ROOT/gate-probe"
mkdir -p "$gate_dir"
setsid bash "$probe_bin" \
    --resume-home "$home" \
    opencode run --continue "Continue the aborted run-log protocol exactly where it left off." \
    > "$gate_dir/stdout.log" 2> "$gate_dir/probe-stderr.log" &
probe_pid=$!

gate_line=""
rp=0
while [ "$rp" -lt 10 ]; do
    rp=$((rp+1))
    gate_line=$(grep -E '^FATAL:.*(determination).*(resume|re-run|continue)' "$gate_dir/probe-stderr.log" 2>/dev/null | head -1 || true)
    [ -n "$gate_line" ] && break
    kill -0 "$probe_pid" 2>/dev/null || break
    sleep 20
done

# SAFE cleanup: kill the probe regardless — enforcement only; in RED mode an
# ungated probe dispatches inference, which is itself the RED gap signal.
kill -- -"$probe_pid" 2>/dev/null || true
sleep 1
kill -- -"$probe_pid" -9 2>/dev/null || true
rm -f tmp/.behavior-run.lock

printf '%s' "$gate_line" > "$EV_ROOT/gate-line"
printf '%s' "$rp" > "$EV_ROOT/gate-polls"

# ─── Precondition guards (exit 2 = invalid RED, requires diagnosis) ───
store="$home/.local/share/opencode/opencode.db"
if [ ! -d "$home" ] || [ ! -f "$store" ]; then
    echo "PRECONDITION-FAIL: no surviving test home / session store at '$home' — the aborted-dispatch state was never produced; harness failure, not a RED verdict" >&2
    cp "$run_dir/stderr.log" "$EV_ROOT/provision-stderr.log" 2>/dev/null || true
    exit 2
fi
evt=$(sqlite3 "$store" "SELECT COUNT(*) FROM event;" 2>/dev/null || echo 0)
if [ "${evt:-0}" -lt 1 ]; then
    echo "PRECONDITION-FAIL: session store at '$store' carries no events — the dispatch was never provisioned; not a RED verdict" >&2
    exit 2
fi
if kill -0 "$dispatch_pid" 2>/dev/null; then
    echo "PRECONDITION-FAIL: dispatch '$dispatch_pid' still alive — the abort (kill) did not produce an aborted-dispatch state; not a RED verdict" >&2
    exit 2
fi
if [ ! -f "$gate_dir/probe-stderr.log" ]; then
    echo "PRECONDITION-FAIL: gate probe stderr capture missing at $gate_dir/probe-stderr.log — the resume path was never exercised; not a RED verdict" >&2
    exit 2
fi

cp "$gate_dir/probe-stderr.log" "$EV_ROOT/probe-stderr.log" 2>/dev/null || true

# Write the manifest — artifact-only generation contract.
cat > "$EV_ROOT/manifest.yaml" <<MF.EOF
scenario: $SCENARIO_NAME
phase: $PHASE
model: unknown-harness-probe
exit_code: 0
harness_version: 2
MF.EOF

if [ "$PHASE" = "GREEN" ]; then
    if [ -n "$gate_line" ]; then
        echo "GREEN CONFIRMED: re-dispatch of $home after an aborted dispatch (no recorded non-undetermined determination) was BLOCKED with a FATAL-class determination-gate message and no inference dispatched ('${gate_line}') — .opencode#2456 SC-11" >&2
        exit 0
    fi
    echo "GREEN NOT SATISFIED: re-dispatch of $home proceeded UNGATED — no FATAL-class determination-gate line appeared on probe stderr" >&2
    exit 1
fi

# RED phase: the gate must be demonstrable as blocking. Run against the
# simulated pre-gate copy, the ungated dispatch IS the RED confirmation.
if [ -z "$gate_line" ]; then
    echo "RED CONFIRMED: the unregulated state dispatches UNGATED — with __sc8_determination_gate stubbed out in the tmp copy '${STUB_COPY}', re-dispatch of surviving home '$home' (session store with events, no determination record) launched inference with NO FATAL-class determination-gate line on probe stderr ('${gate_dir}/probe-stderr.log', budget: $rp polls) — the assertion FAILS against a pre-gate harness, so it has teeth — .opencode#2456 SC-11" >&2
    exit 1
fi

echo "RED ABORT — ALREADY_GREEN: the gate line appeared even against the simulated pre-gate copy — unexpected harness state; a failing RED demonstration cannot be validly produced" >&2
exit 3
