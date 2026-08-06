#!/bin/bash
# Content-Verification Enforcement Test: Phase 3 — Multi-Submodule Provisioning (Concern C1)
#
# Issue: .opencode#2244 — full-environment simulation in the tests-v2 harness.
# Phase: red-phase3-multi-submodule — Concern C1,
#        `.opencode/tests-v2/behaviors/helpers.sh` (behavior_run multi-submodule provisioning).
#
# SCs covered: SC1.
#
# This is a RED-phase test. The GREEN implementation has NOT been applied yet, so the
# assertions below are expected to FAIL (non-zero exit). The GREEN phase will:
#   1. Add a BEHAVIOR_NEEDS_MULTI_SUBMODULES branch inside behavior_run() that, when the
#      flag is set to 1, `git init`s test-submodule-1 and test-submodule-2 as local git
#      repos (from fixture templates) inside the attempt workdir, in addition to the
#      existing single `.opencode` clone.
#   2. Leave the flag-off path provisioning ONLY the existing `.opencode` clone — no
#      test-submodule-* dirs appear when the flag is unset or absent.
#
# Evidence type: SC1 is structural — content-verification assertions on
# `.opencode/tests-v2/behaviors/helpers.sh` checking that the provisioning block exists
# (the fixture repo names, the git-init of the fixture repos, and the flag wiring).
#
# RED state: Currently `behavior_run()` in helpers.sh provisions only the single
# `.opencode` clone (lines ~436-461) and has NO `test-submodule-1` / `test-submodule-2`
# provisioning. The BEHAVIOR_NEEDS_MULTI_SUBMODULES flag is passed through the env -i
# allowlist by Phase 1 but is NOT wired to any provisioning block in behavior_run — so
# the assertions below are RED.
#
# Usage: bash .opencode/tests-v2/test-2244-phase3-multi-submodule.sh
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
echo "=== Phase 3 — Multi-Submodule Provisioning (Spec #2244, Concern C1) ==="
echo ""
echo "Target file: $HELPERS_SH"
echo ""

# ---------------------------------------------------------------------------
# SC1 (structural): When BEHAVIOR_NEEDS_MULTI_SUBMODULES=1 is set, behavior_run()
# in helpers.sh provisions test-submodule-1 and test-submodule-2 as local git repos
# (created via git init from fixture templates) inside the attempt workdir, in
# addition to the existing `.opencode` clone. When the flag is unset or absent,
# behavior_run() provisions only the existing single `.opencode` clone.
#
# RED-now: no multi-submodule provisioning block exists. The only provisioning in
# behavior_run() is the `.opencode` clone (git clone "$submodule_remote_url"
# "$attempt_workdir/.opencode" / submodule add .opencode). There are no
# test-submodule-1/test-submodule-2 names, no fixture-template git-init for the two
# fixture repos, and no BEHAVIOR_NEEDS_MULTI_SUBMODULES branch. GREEN adds that block.
# ---------------------------------------------------------------------------
echo "--- SC1: multi-submodule fixture provisioning in behavior_run ---"

# (a) The flag is wired to a provisioning block in behavior_run.
grep_assert_present \
    "SC1: behavior_run branches on BEHAVIOR_NEEDS_MULTI_SUBMODULES" \
    "$HELPERS_SH" \
    "BEHAVIOR_NEEDS_MULTI_SUBMODULES"

# (b) The two fixture repo names are provisioned.
grep_assert_present \
    "SC1: provisions test-submodule-1" \
    "$HELPERS_SH" \
    "test-submodule-1"
grep_assert_present \
    "SC1: provisions test-submodule-2" \
    "$HELPERS_SH" \
    "test-submodule-2"

# (c) The fixture repos are created as local git repos via git init from fixture
# templates, alongside the existing .opencode clone.
grep_assert_present \
    "SC1: git-inits the fixture submodule repos" \
    "$HELPERS_SH" \
    "git init"
grep_assert_present \
    "SC1: provisions fixture submodules from fixture templates" \
    "$HELPERS_SH" \
    "fixtures"

# (d) The flag-off path provisions ONLY the single .opencode clone — the two
# test-submodule-* repos must not be created unconditionally. GREEN MUST NOT
# provision them outside the BEHAVIOR_NEEDS_MULTI_SUBMODULES=1 guard. Because
# test-submodule-1/test-submodule-2 do not appear at all right now (RED for b),
# this absence check passes trivially and becomes a meaningful guard only once
# GREEN introduces the names.
grep_assert_absent \
    "SC1: test-submodule-1 provisioned ONLY inside the flag guard (no bare unconditional init)" \
    "$HELPERS_SH" \
    '^[[:space:]]*git init -q "\$attempt_workdir/test-submodule-1"'

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: Phase 3 (multi-submodule fixture provisioning) not yet implemented."
    echo "behavior_run() in helpers.sh provisions only the single .opencode clone and has"
    echo "no BEHAVIOR_NEEDS_MULTI_SUBMODULES branch, no test-submodule-1/test-submodule-2"
    echo "fixture provisioning, and no git-init of the fixture repos."
    echo ""
    exit 1
fi
exit 0
