#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral test: 2456-sc8-resume-gate-red
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# SC-8 (.opencode#2456, plan-02 Item 8, phase-3 RED): the with-test-home
# resume/re-run gate — after an ABORTED (killed) dispatch, a resume
# (--resume-home) or re-run (--continue) whose run has NO recorded
# non-undetermined determination must be BLOCKED with a FATAL-class message;
# a valid determination (e.g. decision recorded: continue-new-dispatch)
# PERMITS the resume.
#
# Exercise surface — the cross-invocation resume path (#2432 SC-11):
#   with-test-home --resume-home <prior-home> opencode run --continue '<msg>'
#
# RED design (practical, no long model runs):
#   Phase A (provision + abort): launch a SHORT monitored heartbeat dispatch
#   DETACHED (setsid) with the sc6/sc7 heartbeat prompt shape, wait until
#   with-test-home emits TEST_HOME= and the session store has events, then
#   KILL the process group — leaving (i) a surviving test home with a live
#   session store and (ii) NO determination record (helpers.sh writes the
#   determination.yaml only in behavior_run()'s post-run block, which a
#   killed dispatch never reaches). This is a real aborted dispatch state.
#
#   Phase B (resume gate probe): launch the resume attempt DETACHED and poll
#   its stderr. GRENaSATION — when the gate EXISTS: a FATAL-class block line
#   naming the missing determination must appear on resume stderr and no
#   inference proceeds. TODAY (known gap): --resume-home only guards home
#   presence, binary presence, and store readability — there is NO
#   determination gate — so the resume PROCEEDS ungated (a model run starts,
#   no FATAL block ever appears) → the assertion FAILED → exit 1.
#
# GREEN expectation (after the Item-8 fix — gate expectation recorded here
# for GREEN):
#   1. BLOCK path: resuming/re-running a test home whose run ended without a
#      recorded non-undetermined determination FAILS FAST with a FATAL-class
#      message that names BOTH the resume/re-run context AND the missing
#      determination requirement (stderr line: ^FATAL: … determination …
#      resume|re-run|continue), and no model inference is dispatched.
#   2. PERMIT path: a run with a recorded valid orchestrator decision
#      (determination record carrying decision: continue-new-dispatch or
#      terminate-with-root-cause with root-cause) IS permitted to resume
#      (the gate must not fire).
#
# ASSERTION TARGET — harness infrastructure, not model output: the verdict-
# bearing assertion is deterministic (a FATAL-class gate line on the resume
# invocation's stderr). The §1 exit-0 unconditional paradigm does NOT apply
# to a harness-behavior enforcement test whose assertion target is the
# harness itself (same exception as 2456-sc1..sc7).
#
# PRECONDITION GUARDS (exit 2 = invalid RED, requires diagnosis — never a
# verdict): (a) the aborted-dispatch state was actually produced — a test
# home exists, its session store exists and carries >=1 event row, and the
# dispatch process is gone; without (a) the resume path was never exercised
# against a genuinely aborted dispatch; (b) the resume stderr capture
# exists. Without these, NOT a RED verdict.
#
# Isolation mandates honored: FRESH test home provisioned via with-test-home
# (NO manual home construction); DETACHED setsid launches; own kill is the
# abort signal (GNU `timeout` FORBIDDEN per §5); stderr-only TEST_HOME
# discovery; the resume attempt runs through the harness's own --resume-home
# surface.
#
# §15 targeted-execution mandate: run this ONE named scenario via
#   BEHAVIOR_PHASE=RED bash .opencode/tests-v2/behaviors/2456-sc8-resume-gate-red.sh
# launched DETACHED and polled with the bash tool timeout >= 600000 ms.
#
# Ordered precondition cycle (§4): the scenario file itself is committed and
# pushed to the submodule remote BEFORE the isolated run (SC-16 commit
# discipline; NEVER --no-verify).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2456-sc8-resume-gate-red"

ER="$(cd "$SCRIPT_DIR/../../.." && pwd)/tmp/2456/artifacts"
mkdir -p "$ER"
EV_ROOT="$ER/${SCENARIO_NAME}"
rm -rf "$EV_ROOT"
mkdir -p "$EV_ROOT"

# §11 real-domain heartbeat prompt (same heartbeat protocol shape as sc6/sc7 —
# mechanically light, bounded, one append per cycle, explicit stop).
SCENARIO_PROMPT="Follow this repository working protocol exactly — it is the entire task. Working protocol (run log): Create a file named run-log.md in the current project root if it does not exist. Then append the following lines to run-log.md in order, exactly one line per work cycle (one write tool call per line — never batch multiple lines into a single write): run 01: cycle logged / run 02: cycle logged / run 03: cycle logged / run 04: cycle logged / run 05: cycle logged / run 06: cycle logged / run 07: cycle logged / run 08: cycle logged. After all eight lines are appended, the protocol loop is complete — stop."

# ─── Phase A: provision a fresh test home via a SHORT dispatch, then abort it ──
rm -f tmp/.behavior-run.lock

run_dir="$EV_ROOT/probe-dispatch"
mkdir -p "$run_dir"
setsid bash .opencode/tests-v2/with-test-home \
    opencode run "$SCENARIO_PROMPT" \
    > "$run_dir/stdout.log" 2> "$run_dir/stderr.log" &
dispatch_pid=$!

# Poll (≤240s budget): wait for TEST_HOME emission + a live session store.
home=""
polls=0
while [ "$polls" -lt 12 ]; do
    polls=$((polls+1))
    if grep -q '^TEST_HOME=' "$run_dir/stderr.log" 2>/dev/null; then
        home=$(grep '^TEST_HOME=' "$run_dir/stderr.log" | head -1 | sed 's/^TEST_HOME=//')
        store="$home/.local/share/opencode/opencode.db"
        if [ -n "$home" ] && [ -f "$store" ]; then
            evt=$(sqlite3 "$store" "SELECT COUNT(*) FROM event;" 2>/dev/null || echo 0)
            if [ "${evt:-0}" -ge 1 ]; then
                break
            fi
        fi
    fi
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

# ─── Phase B: resume gate probe (the RED exercise surface) ───
resume_dir="$EV_ROOT/resume-attempt"
mkdir -p "$resume_dir"
setsid bash .opencode/tests-v2/with-test-home \
    --resume-home "$home" \
    opencode run --continue "Continue the aborted run-log protocol exactly where it left off." \
    > "$resume_dir/stdout.log" 2> "$resume_dir/resume-stderr.log" &
resume_pid=$!

gate_line=""
rp=0
while [ "$rp" -lt 10 ]; do
    rp=$((rp+1))
    gate_line=$(grep -E '^FATAL:.*(determination).*(resume|re-run|continue)' "$resume_dir/resume-stderr.log" 2>/dev/null | head -1 || true)
    [ -n "$gate_line" ] && break
    kill -0 "$resume_pid" 2>/dev/null || break
    sleep 20
done

printf '%s' "$gate_line" > "$EV_ROOT/gate-line"
printf '%s' "$rp" > "$EV_ROOT/resume-polls"

# Kill the probe regardless — enforcement only (no model inference should
# outlive the verdict); today the ungated resume dispatches inference, which
# is the RED gap signal in itself.
kill -- -"$resume_pid" 2>/dev/null || true
sleep 1
kill -- -"$resume_pid" -9 2>/dev/null || true
rm -f tmp/.behavior-run.lock

# ─── Precondition guards ───
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
if [ ! -f "$resume_dir/resume-stderr.log" ]; then
    echo "PRECONDITION-FAIL: resume stderr capture missing at $resume_dir/resume-stderr.log — the resume path was never exercised; not a RED verdict" >&2
    exit 2
fi

cp "$resume_dir/resume-stderr.log" "$EV_ROOT/resume-stderr.log" 2>/dev/null || true

if [ -n "$gate_line" ]; then
    GREEN_OK=1
    BLOCKED=1
else
    GREEN_OK=0
    BLOCKED=0
fi

PHASE="${BEHAVIOR_PHASE:-RED}"

if [ "$PHASE" = "GREEN" ]; then
    if [ "$BLOCKED" = "1" ]; then
        echo "GREEN: the resume gate exists — the aborted-dispatch resume was BLOCKED on dispatch with a FATAL-class determination message ('${gate_line}') and no ungated inference proceeded (test home: $home)" >&2
        exit 0
    fi
    echo "GREEN NOT SATISFIED (RED confirmed in GREEN phase): resuming $home after an aborted dispatch dispatched inference UNGATED — no FATAL-class determination gate line appeared on resume stderr (known gap: --resume-home guards home/binary/store only, no determination gate)" >&2
    exit 1
fi

# RED phase: the gate must block. If the gate already blocks, RED cannot be
# validly produced.
if [ "$BLOCKED" = "1" ]; then
    echo "RED ABORT — ALREADY_GREEN: the resume gate already exists — the resume of an aborted dispatch was BLOCKED ('${gate_line}') without inference, so a failing RED test cannot be validly produced" >&2
    exit 3
fi

echo "RED CONFIRMED: the resume path PROCEEDED UNGATED — after aborting dispatch '$dispatch_pid' (test home: $home, session store with events surviving), '$resume_dir/resume-stderr.log' carries NO FATAL-class determination gate line (budget: $rp polls) — the resume/re-run dispatches inference without any determination record (no non-undetermined determination exists for this run; known gap: with-test-home --resume-home guards home presence, binary presence, and store readability only, and helpers.sh writes determination.yaml only in behavior_run()'s post-run block that a killed dispatch never reaches). GATE EXPECTATION FOR GREEN: an aborted dispatch's resume (--resume-home / re-run --continue) must FAIL FAST with a FATAL-class message naming the missing non-undetermined determination (^FATAL: … determination … resume|re-run|continue) with no inference dispatched, and a run carrying a valid recorded decision (continue-new-dispatch / terminate-with-root-cause with root-cause) must be PERMITTED to resume (.opencode#2456 SC-8)." >&2
exit 1
