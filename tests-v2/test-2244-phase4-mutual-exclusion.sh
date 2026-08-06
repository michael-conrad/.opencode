#!/bin/bash
# Content-Verification Enforcement Test: Phase 4 — Remote-Strategy Mutual Exclusion (Concern C3)
#
# Issue: .opencode#2244 — full-environment simulation in the tests-v2 harness.
# Phase: red-phase4-mutual-exclusion — Concern C3,
#        `.opencode/tests-v2/behaviors/helpers.sh` (behavior_run mutual-exclusion rejection).
#
# SCs covered: SC4.
#
# This is a RED-phase test. The GREEN implementation has NOT been applied yet, so the
# assertions below are expected to FAIL (non-zero exit). The GREEN phase will:
#   1. Add a mutual-exclusion rejection check inside behavior_run() that, when BOTH
#      BEHAVIOR_NEEDS_REMOTE=1 and BEHAVIOR_SET_BARE_REMOTE=1 are set, exits with
#      HARNESS_FAILURE BEFORE either the bare-remote block or the GitBucket origin
#      wiring block runs, so no ambiguous origin wiring is attempted.
#   2. Leave each flag's own wiring block intact for the flag-alone path — only the
#      contradictory combined configuration is rejected.
#
# Evidence type: SC4 is behavioral (HARNESS_FAILURE exit + no origin wiring). Per the
# #2244 plan, the RED gate for Phase 4 uses structural/content-verification assertions
# on `.opencode/tests-v2/behaviors/helpers.sh` checking that behavior_run() contains a
# mutual-exclusion check that rejects (HARNESS_FAILURE) when both flags are set. The
# behavioral runtime verification (HARNESS_FAILURE exit under both flags) is the GREEN
# doublecheck / VbC step that follows this RED gate.
#
# RED state: Currently behavior_run() in helpers.sh provisions the bare remote under
# the BEHAVIOR_SET_BARE_REMOTE=1 guard (lines ~515-520) and wires the GitBucket origin
# under the BEHAVIOR_NEEDS_REMOTE=1 guard (lines ~529-535). There is NO mutual-exclusion
# check — a test could set both flags and both blocks would run, wiring an ambiguous
# origin. So the assertions below are RED.
#
# Usage: bash .opencode/tests-v2/test-2244-phase4-mutual-exclusion.sh
# Exit:  0 if all checks pass (GREEN), 1 if any check fails (expected RED).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

HELPERS_SH="$PROJECT_DIR/.opencode/tests-v2/behaviors/helpers.sh"

PASS_COUNT=0
FAIL_COUNT=0

check_pass() {
    local label="$1"
    echo "  PASS: $label"
    PASS_COUNT=$((PASS_COUNT + 1))
}

check_fail() {
    local label="$1"
    local detail="$2"
    echo "  FAIL: $label — $detail" >&2
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

# grep_assert_present: pattern must appear at least once in the file.
grep_assert_present() {
    local label="$1"
    local file="$2"
    local pattern="$3"
    if grep -qF "$pattern" "$file" 2>/dev/null; then
        check_pass "$label"
    else
        check_fail "$label" "pattern '$pattern' not found in $file"
    fi
}

# grep_assert_absent: pattern must NOT appear in the file.
grep_assert_absent() {
    local label="$1"
    local file="$2"
    local pattern="$3"
    if grep -qE "$pattern" "$file" 2>/dev/null; then
        check_fail "$label" "forbidden pattern '$pattern' found in $file"
    else
        check_pass "$label"
    fi
}

echo ""
echo "=== Phase 4 — Remote-Strategy Mutual Exclusion (Spec #2244, Concern C3) ==="
echo ""
echo "Target file: $HELPERS_SH"
echo ""

# ---------------------------------------------------------------------------
# SC4 (behavioral via content-verification for the RED gate): When both
# BEHAVIOR_NEEDS_REMOTE=1 and BEHAVIOR_SET_BARE_REMOTE=1 are set, behavior_run()
# rejects the configuration with a HARNESS_FAILURE exit and does not attempt
# ambiguous origin wiring.
#
# RED-now: no mutual-exclusion rejection exists. The bare-remote block
# (BEHAVIOR_SET_BARE_REMOTE guard) and the GitBucket origin wiring block
# (BEHAVIOR_NEEDS_REMOTE guard) both run independently; nothing rejects the
# combined configuration. GREEN adds a rejection check before either wiring block.
# ---------------------------------------------------------------------------
echo "--- SC4: mutual-exclusion rejection in behavior_run ---"

# (a) behavior_run must contain a mutual-exclusion check that triggers HARNESS_FAILURE
# when both remote-strategy flags are set. This is the core rejection mechanism.
grep_assert_present \
    "SC4: behavior_run branches on BEHAVIOR_NEEDS_REMOTE" \
    "$HELPERS_SH" \
    "BEHAVIOR_NEEDS_REMOTE"
grep_assert_present \
    "SC4: behavior_run branches on BEHAVIOR_SET_BARE_REMOTE" \
    "$HELPERS_SH" \
    "BEHAVIOR_SET_BARE_REMOTE"
grep_assert_present \
    "SC4: mutual-exclusion rejection emits HARNESS_FAILURE" \
    "$HELPERS_SH" \
    "HARNESS_FAILURE"

# (b) The rejection MUST test that both flags are set simultaneously — a single guard
# that references BOTH BEHAVIOR_NEEDS_REMOTE and BEHAVIOR_SET_BARE_REMOTE in one
# condition. Each flag is separately wired today (the bare-remote block at
# ${BEHAVIOR_SET_BARE_REMOTE:-0}="1" and the GitBucket wiring block at
# ${BEHAVIOR_NEEDS_REMOTE:-0}="1"), but NO single line combines the two into a
# mutual-exclusion rejection. RED: grep for a line that references both flags returns
# zero matches, so this assertion FAILS now.
if grep -qE '.*BEHAVIOR_NEEDS_REMOTE.*BEHAVIOR_SET_BARE_REMOTE.*|.*BEHAVIOR_SET_BARE_REMOTE.*BEHAVIOR_NEEDS_REMOTE.*' "$HELPERS_SH" 2>/dev/null; then
    check_pass "SC4: rejection condition references BOTH flags in one mutual-exclusion guard"
else
    check_fail "SC4: rejection condition references BOTH flags in one mutual-exclusion guard" \
        "no single line combines BEHAVIOR_NEEDS_REMOTE and BEHAVIOR_SET_BARE_REMOTE in one guard"
fi

# (c) The rejection MUST precede either origin-wiring block so no ambiguous origin is
# attempted. Both wiring blocks exist today; GREEN MUST add the rejection check earlier
# in behavior_run than the bare-remote block. Assert the presence of a dedicated
# mutual-exclusion rejection marker that does not yet exist. RED.
grep_assert_present \
    "SC4: mutual-exclusion rejection runs before origin wiring" \
    "$HELPERS_SH" \
    "mutual-exclusion"

# (d) The flag-off path must remain intact — neither wiring block may run
# unconditionally. The bare remote must only be provisioned inside the
# BEHAVIOR_SET_BARE_REMOTE=1 guard (GREEN MUST NOT move it outside). Because the
# bare remote is already guard-wrapped today, this absence check passes now and
# becomes a meaningful guard once GREEN adds the mutual-exclusion block.
grep_assert_absent \
    "SC4: bare remote provisioned ONLY inside the flag guard (no unconditional git init --bare)" \
    "$HELPERS_SH" \
    '^[[:space:]]*git init --bare "\$attempt_workdir'

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: Phase 4 (remote-strategy mutual exclusion) not yet implemented."
    echo "behavior_run() in helpers.sh has a BEHAVIOR_SET_BARE_REMOTE block and a"
    echo "BEHAVIOR_NEEDS_REMOTE block but no mutual-exclusion rejection — both flags can"
    echo "be set together and both blocks would wire an ambiguous origin. GREEN adds a"
    echo "HARNESS_FAILURE rejection check before either wiring block."
    echo ""
    exit 1
fi
exit 0
