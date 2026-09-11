#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)
#
# RED-phase enforcement test: SC-3 — behavior_run() pre-flight git-state gate
#
# Issue: .opencode#2434 — test-framework commit/push/fetch/checkout cycle.
# Spec:   .opencode/.issues/2434/spec.md (SC-3, evidence type: behavioral)
# Plan:   .opencode/.issues/2434/plan.md — Item 3, step 24 (RED)
#
# SC-3: behavior_run() must enforce a pre-flight git-state gate — submodule
# working tree clean AND the effective submodule commit (BEHAVIOR_SUBMODULE_COMMIT
# pin when set, local HEAD otherwise) present on the remote after a fresh fetch —
# that FAILS (exit non-zero, FATAL/HARNESS_FAILURE message naming the
# commit+push+fetch remediation) BEFORE the flock acquisition completes and
# before any model dispatch. A pinned unpushed SHA FAILS (no bypass, R-4).
#
# RED state (today): helpers.sh behavior_run() has NO pre-flight git-state gate.
# The function resolves the submodule URL and pin, then immediately opens the
# lock file (exec 200> tmp/.behavior-run.lock) and acquires flock, then enters
# the attempt loop (creates a behavior-isolated workdir, clones .opencode from
# the remote) and only fails LATE — at the in-loop checkout of the unpushed
# SHA ("FATAL: could not checkout submodule commit <sha>", no push/fetch
# remediation) — after the lock was taken and after a full remote clone. The
# assertions below target the DESIRED gate ordering and message, so they FAIL
# today. That non-zero exit IS the RED verdict (RED != FALSE: the probes
# execute the real behavior_run() code path and observe the failing behavior).
#
# Fixture: a fixture project root at tmp/2434/fixture-sc3-parent/ containing a
# fixture .opencode git repo with a byte-faithful copy of helpers.sh and
# default-model.sh. Sourcing the copied helpers resolves PARENT_REPO_DIR to the
# fixture root (__find_project_root walk-up), so behavior_run()'s lock file,
# log dirs, and isolated workdirs all live under the fixture tree and the real
# repo and the real tmp/.behavior-run.lock are never touched. The fixture
# substitutes the submodule STATE, not the code under test — helpers.sh is
# copied byte-faithfully. Probe A fixture: uncommitted working-tree change AND
# an unpushed HEAD (both SC-3 failing states combined). Probe B: clean fixture,
# BEHAVIOR_SUBMODULE_COMMIT pinned to the fixture's unpushed HEAD SHA.
#
# Probe isolation guarantees:
#   - The fixture's .opencode/tests-v2/with-test-home path is intentionally
#     NOT populated. The probes are designed to fail before model dispatch
#     (today: in-loop checkout FATAL; post-GREEN: the pre-flight gate). If a
#     defect ever carried a probe past the gate into dispatch, the missing
#     with-test-home path fails fast with zero model inference burned.
#   - No GNU timeout anywhere; the invoking bash tool call carries
#     timeout >= 600000ms per the tests-v2 mandate.
#
# Control probe note: the pushed-state control ("proceeds to lock acquisition
# and model dispatch, no false positive", plan step 27) requires a real model
# dispatch and is exercised at GREEN/verify — it is deliberately NOT part of
# this RED probe set (tests-v2/AGENTS.md §15 targeted-run mandate: one run per
# SC need; the RED need here is the two failing probes only). The lock-file
# observation instrument is self-validating: the RED runs prove the lock block
# executes today (lock file created with a fresh mtime), so an unchanged/absent
# lock file after a post-GREEN run is a true negative, not a dead probe.
#
# Artifacts: tmp/2434/artifacts/pipeline-red-sc3-*
# Usage:   bash .opencode/tests-v2/test-2434-sc3-behavior-run-preflight-red.sh
# Exit:    0 = all assertions pass (GREEN state reached)
#          1 = RED state confirmed (expected today)

set -uo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
HELPERS="$PROJECT_ROOT/.opencode/tests-v2/behaviors/helpers.sh"
DEFAULT_MODEL_SH="$PROJECT_ROOT/.opencode/tests-v2/default-model.sh"
WORK_DIR="$PROJECT_ROOT/tmp/2434"
ART_DIR="$WORK_DIR/artifacts"
FIXTURE_PARENT="$WORK_DIR/fixture-sc3-parent"
FIXTURE_OC="$FIXTURE_PARENT/.opencode"
FIXTURE_HELPERS="$FIXTURE_OC/tests-v2/behaviors/helpers.sh"
RUNNER="$WORK_DIR/sc3-probe-runner.sh"
LOCK_PATH="$FIXTURE_PARENT/tmp/.behavior-run.lock"
mkdir -p "$ART_DIR"

# Idempotence: clear this test's own stale artifacts and stale fixture state.
rm -f "$ART_DIR"/pipeline-red-sc3-*
rm -rf "$FIXTURE_PARENT" "$RUNNER"

exec > >(tee "$ART_DIR/pipeline-red-sc3-test-output.log") 2> >(tee "$ART_DIR/pipeline-red-sc3-test-output.err" >&2)

PASS_COUNT=0
FAIL_COUNT=0
check_pass() {
    echo "  PASS: $1"
    PASS_COUNT=$((PASS_COUNT + 1))
}
check_fail() {
    echo "  FAIL: $1 — $2" >&2
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

echo "== SC-3 RED probe: behavior_run() pre-flight git-state gate (.opencode#2434) =="

# ---------------------------------------------------------------------------
# Sanity: the code under test must exist and carry the expected shape.
# ---------------------------------------------------------------------------
if [ ! -f "$HELPERS" ] || [ ! -f "$DEFAULT_MODEL_SH" ]; then
    echo "HARNESS_FAILURE: helpers.sh or default-model.sh not found at $PROJECT_ROOT/.opencode/tests-v2/" >&2
    exit 2
fi

# ---------------------------------------------------------------------------
# Structural assertion: a pre-flight gate block (fresh-fetch containment check)
# must exist inside behavior_run() BEFORE the lock block (exec 200> / flock).
# Per plan step 25 the gate is an inline block inside behavior_run() performing
# a fresh `git fetch`; the pattern also accepts a dedicated gate helper call so
# a function-extracted implementation is not falsely failed.
# ---------------------------------------------------------------------------
BR_START=$(awk '/^behavior_run\(\) \{/{print NR; exit}' "$HELPERS")
LOCK_LINE=$(awk -v s="$BR_START" 'NR>s && /exec 200>/{print NR; exit}' "$HELPERS")
if [ -z "$BR_START" ] || [ -z "$LOCK_LINE" ]; then
    echo "HARNESS_FAILURE: could not locate behavior_run() or its lock block in helpers.sh" >&2
    exit 2
fi
echo "  [structural] behavior_run() starts at line $BR_START; lock block (exec 200>) at line $LOCK_LINE"
prelock_region="$(sed -n "${BR_START},${LOCK_LINE}p" "$HELPERS")"
status_porcelain_sites=$(echo "$prelock_region" | grep -c 'git status' || true)
if echo "$prelock_region" | grep -qE 'git fetch|__pre_?flight|__assert_git_state|__git_state_gate'; then
    check_pass "structural: pre-flight gate (fresh-fetch containment) present before the lock block in behavior_run()"
else
    check_fail "structural: pre-flight gate present before the lock block in behavior_run()" \
        "no git fetch / gate helper between behavior_run() line $BR_START and lock line $LOCK_LINE — the gate does not exist ($status_porcelain_sites git-status sites in region)"
fi
{
    echo "behavior_run_start_line: $BR_START"
    echo "lock_block_line: $LOCK_LINE"
    echo "prelock_git_status_sites: $status_porcelain_sites"
    echo "prelock_has_fetch_gate: $(echo "$prelock_region" | grep -qE 'git fetch|__pre_?flight|__assert_git_state|__git_state_gate' && echo yes || echo no)"
} > "$ART_DIR/pipeline-red-sc3-structural.txt"

# ---------------------------------------------------------------------------
# Probe runner: sources the fixture copy of helpers.sh (PARENT_REPO_DIR then
# resolves to the fixture root) and invokes behavior_run. Env for the probe
# (scenario/message, optional BEHAVIOR_SUBMODULE_COMMIT pin) is passed through.
# ---------------------------------------------------------------------------
cat > "$RUNNER" <<RUNEOF
#!/bin/bash
# Generated SC-3 RED probe runner — sources the fixture helpers copy and calls
# behavior_run. The || rc=\$? guard is set -e safe (helpers.sh sets -euo pipefail
# on source); behavior_run's rc (exit 1 or return 1) propagates as the runner rc.
set -uo pipefail
source "$FIXTURE_HELPERS"
rc=0
behavior_run "\${SC3_SCENARIO}" "\${SC3_MESSAGE}" || rc=\$?
exit "\$rc"
RUNEOF
chmod +x "$RUNNER"

build_fixture() {
    # $1 = dirty|clean — rebuild the fixture project root from scratch.
    rm -rf "$FIXTURE_PARENT"
    mkdir -p "$FIXTURE_OC/tests-v2/behaviors"
    cp "$DEFAULT_MODEL_SH" "$FIXTURE_OC/tests-v2/default-model.sh"
    cp "$HELPERS" "$FIXTURE_HELPERS"
    git init -q "$FIXTURE_OC"
    git -C "$FIXTURE_OC" config user.email "red-fixture@test.dev"
    git -C "$FIXTURE_OC" config user.name "RED Fixture"
    git -C "$FIXTURE_OC" add -A
    git -C "$FIXTURE_OC" commit -q -m "fixture: sc3 pre-flight gate probe fixture (helpers copy)"
    echo "fixture-marker $(date -u +%Y%m%dT%H%M%SZ)" > "$FIXTURE_OC/marker.txt"
    git -C "$FIXTURE_OC" add -A
    git -C "$FIXTURE_OC" commit -q -m "fixture: sc3 marker commit"
    if [ "$1" = "dirty" ]; then
        echo "uncommitted change $(date -u +%Y%m%dT%H%M%SZ)" >> "$FIXTURE_OC/marker.txt"
    fi
    git -C "$FIXTURE_OC" rev-parse HEAD
}

run_probe() {
    # $1 = probe label; $2 = dirty|clean; $3 = pinned SHA or ""
    #     $4..$6 = stdout/stderr/exit artifact stems
    local label="$1" state="$2" pin="$3"
    local out="$4" err="$5" exitf="$6"
    local fixture_sha
    fixture_sha=$(build_fixture "$state")
    rm -rf "$FIXTURE_PARENT/tmp"
    local lock_before="absent"
    [ -e "$LOCK_PATH" ] && lock_before="present"

    echo "== Probe $label: fixture state=$state pin=${pin:-<unset>} (fixture SHA $fixture_sha) =="
    if [ -n "$pin" ]; then
        BEHAVIOR_SUBMODULE_COMMIT="$pin" \
        SC3_SCENARIO="2434-sc3-red-$label" \
        SC3_MESSAGE="probe message (never dispatched — probe must fail before model dispatch)" \
        env -u TEST_WORKDIR -u BEHAVIOR_SHARED_HOME -u BEHAVIOR_SEMANTIC_MONITOR \
            -u BEHAVIOR_NEEDS_REMOTE -u BEHAVIOR_SET_BARE_REMOTE \
            bash "$RUNNER" > "$out" 2> "$err"
    else
        SC3_SCENARIO="2434-sc3-red-$label" \
        SC3_MESSAGE="probe message (never dispatched — probe must fail before model dispatch)" \
        env -u TEST_WORKDIR -u BEHAVIOR_SHARED_HOME -u BEHAVIOR_SEMANTIC_MONITOR \
            -u BEHAVIOR_NEEDS_REMOTE -u BEHAVIOR_SET_BARE_REMOTE \
            -u BEHAVIOR_SUBMODULE_COMMIT \
            bash "$RUNNER" > "$out" 2> "$err"
    fi
    local rc=$?
    echo "$rc" > "$exitf"
    echo "  [probe $label] exit: $rc (assertion target: 1)"

    local lock_after="absent"
    [ -e "$LOCK_PATH" ] && lock_after="present"
    local lock_mtime="n/a"
    [ -e "$LOCK_PATH" ] && lock_mtime=$(stat -c %Y "$LOCK_PATH" 2>/dev/null || echo unknown)
    local workdirs=0
    workdirs=$(find "$FIXTURE_PARENT/tmp" -maxdepth 1 -name 'behavior-isolated-*' 2>/dev/null | wc -l | tr -d ' ')
    {
        echo "probe: $label"
        echo "fixture_state: $state"
        echo "pinned_sha: ${pin:-<unset>}"
        echo "fixture_head_sha: $fixture_sha"
        echo "lock_file_before: $lock_before"
        echo "lock_file_after: $lock_after"
        echo "lock_file_mtime_after: $lock_mtime"
        echo "behavior_isolated_workdirs: $workdirs"
        echo "probe_exit: $rc"
    } > "${exitf%.exit}.lock-state.yaml"

    # --- Assertions (targets are the DESIRED gate behavior) ---

    if [ "$rc" -eq 1 ]; then
        check_pass "probe $label: exit 1 on failing git state"
    else
        check_fail "probe $label: exit 1 on failing git state" \
            "observed exit $rc — expected the pre-flight gate to fail with exit 1"
    fi

    if grep -qE 'FATAL:|HARNESS_FAILURE:' "$err"; then
        check_pass "probe $label: FATAL/HARNESS_FAILURE message emitted"
    else
        check_fail "probe $label: FATAL/HARNESS_FAILURE message emitted" \
            "stderr carries no FATAL/HARNESS_FAILURE failure message"
    fi

    if grep -qi "push" "$err" && grep -qi "fetch" "$err" && grep -qi "commit" "$err"; then
        check_pass "probe $label: failure message names the commit+push+fetch remediation"
    else
        check_fail "probe $label: failure message names the commit+push+fetch remediation" \
            "stderr lacks the commit+push+fetch remediation (today: late in-loop 'could not checkout submodule commit' FATAL with no remediation)"
    fi

    # Gate ordering vs flock: the gate must fail BEFORE exec 200> opens the lock
    # file. Given the lock file is absent before the probe, it must still be
    # absent after — presence proves the lock block ran before the failure.
    if [ "$lock_before" = "absent" ] && [ "$lock_after" = "absent" ]; then
        check_pass "probe $label: failure precedes the flock acquisition (lock file never created)"
    else
        check_fail "probe $label: failure precedes the flock acquisition (lock file never created)" \
            "lock file was $lock_before before and $lock_after after (mtime $lock_mtime) — behavior_run reached the exec 200>/flock block before failing"
    fi
    # Instrument self-validation: when the lock file WAS created by this probe,
    # record it explicitly so the clean-room evaluator can distinguish a genuine
    # lock-block execution from a dead instrument (lock file stale from earlier
    # state would show lock_after=present with an unchanged mtime).
    if [ "$lock_after" = "present" ]; then
        echo "lock_created_by_this_probe: yes (mtime $lock_mtime)" >> "${exitf%.exit}.lock-state.yaml"
    fi

    # Gate ordering vs attempt loop: no behavior-isolated workdir may be created
    # before the failure (the workdir is created after flock, before dispatch).
    if [ "$workdirs" -eq 0 ]; then
        check_pass "probe $label: failure precedes attempt-loop workdir creation and clone"
    else
        check_fail "probe $label: failure precedes attempt-loop workdir creation and clone" \
            "$workdirs behavior-isolated workdir(s) created — the run entered the attempt loop (post-lock) before failing"
    fi

    # Attempt-loop entry marker must never appear for a pre-flight FAIL.
    # The marker goes to stdout ("  [attempt 1/2]") — check BOTH streams.
    if grep -q '\[attempt 1/' "$out" || grep -q '\[attempt 1/' "$err"; then
        check_fail "probe $label: no attempt-loop entry before failure" \
            "output shows '[attempt 1/…]' — the run passed the lock block and entered the retry loop before failing"
    else
        check_pass "probe $label: no attempt-loop entry before failure"
    fi

    # Model dispatch must never start: with-test-home emits TEST_HOME= on dispatch.
    if grep -q '^TEST_HOME=' "$err"; then
        check_fail "probe $label: no model dispatch before failure" \
            "stderr carries TEST_HOME= — a model dispatch started before the failure"
    else
        check_pass "probe $label: no model dispatch before failure (no TEST_HOME emission)"
    fi

    echo "  [probe $label] evidence: ${exitf%.exit}.lock-state.yaml"
}

# ---------------------------------------------------------------------------
# Probe A (RED target): uncommitted working tree AND unpushed HEAD — both
# SC-3 failing states — with no pin (effective commit = local HEAD).
# ---------------------------------------------------------------------------
run_probe "unpushed-uncommitted" "dirty" "" \
    "$ART_DIR/pipeline-red-sc3-probe-unpushed.stdout" \
    "$ART_DIR/pipeline-red-sc3-probe-unpushed.stderr" \
    "$ART_DIR/pipeline-red-sc3-probe-unpushed.exit"

# ---------------------------------------------------------------------------
# Probe B (negative, no-bypass): clean fixture, BEHAVIOR_SUBMODULE_COMMIT
# pinned to the fixture's unpushed HEAD SHA. The pin selects WHICH commit to
# test — it must not bypass the gate (R-4). Expect FAIL before flock.
# ---------------------------------------------------------------------------
pinned_sha=$(git -C "$FIXTURE_OC" rev-parse HEAD 2>/dev/null || true)
if [ -z "$pinned_sha" ]; then
    echo "HARNESS_FAILURE: could not read fixture HEAD for the pinned probe" >&2
    exit 2
fi
run_probe "pinned-unpushed" "clean" "$pinned_sha" \
    "$ART_DIR/pipeline-red-sc3-probe-pinned.stdout" \
    "$ART_DIR/pipeline-red-sc3-probe-pinned.stderr" \
    "$ART_DIR/pipeline-red-sc3-probe-pinned.exit"

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
echo "== Results =="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo ""
    echo "RED state confirmed: SC-3 pre-flight gate not implemented — behavior_run()"
    echo "acquires the flock and enters the attempt loop (clone/workdir) before any"
    echo "git-state check, failing late at the in-loop checkout with no commit+push+fetch"
    echo "remediation, and the BEHAVIOR_SUBMODULE_COMMIT pin provides no pre-flight"
    echo "verification (no bypass guard exists to bypass)."
    verdict="RED"
    final_rc=1
else
    echo ""
    echo "GREEN: all SC-3 assertions pass."
    verdict="GREEN"
    final_rc=0
fi

local_head="$(git -C "$PROJECT_ROOT/.opencode" rev-parse HEAD 2>/dev/null || echo unknown)"
{
    echo "test: SC-3 behavior_run() pre-flight git-state gate (.opencode#2434)"
    echo "spec: .opencode/.issues/2434/spec.md (SC-3, behavioral)"
    echo "plan_item: Item 3 step 24 (RED)"
    echo "date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "helpers_behavior_run_line: $BR_START"
    echo "helpers_lock_block_line: $LOCK_LINE"
    echo "live_submodule_head: $local_head"
    echo "probe_unpushed_exit: $(cat "$ART_DIR/pipeline-red-sc3-probe-unpushed.exit" 2>/dev/null || echo n/a)"
    echo "probe_pinned_exit: $(cat "$ART_DIR/pipeline-red-sc3-probe-pinned.exit" 2>/dev/null || echo n/a)"
    echo "control_probe: deferred to GREEN/verify (plan step 27) — requires real model dispatch; §15 targeted-run mandate"
    echo "passed: $PASS_COUNT"
    echo "failed: $FAIL_COUNT"
    echo "verdict: $verdict"
    echo "evidence:"
    echo "  - tmp/2434/artifacts/pipeline-red-sc3-test-output.log"
    echo "  - tmp/2434/artifacts/pipeline-red-sc3-test-output.err"
    echo "  - tmp/2434/artifacts/pipeline-red-sc3-structural.txt"
    echo "  - tmp/2434/artifacts/pipeline-red-sc3-probe-unpushed.{stdout,stderr,exit,lock-state.yaml}"
    echo "  - tmp/2434/artifacts/pipeline-red-sc3-probe-pinned.{stdout,stderr,exit,lock-state.yaml}"
    echo "  - tmp/2434/artifacts/pipeline-red-sc3-exit-code"
} > "$ART_DIR/pipeline-red-sc3-summary.yaml"

echo "$final_rc" > "$ART_DIR/pipeline-red-sc3-exit-code"
exit "$final_rc"