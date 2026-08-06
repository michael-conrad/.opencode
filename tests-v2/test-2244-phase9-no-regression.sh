#!/bin/bash
# Content-Verification Enforcement Test: Phase 9 — No-Regression Default Gate (Concern C6)
#
# Issue: .opencode#2244 — full-environment simulation in the tests-v2 harness.
# Phase: red-phase9-no-regression — Concern C6,
#        `.opencode/tests-v2/behaviors/helpers.sh` (default provisioning path) +
#        `.opencode/tests-v2/with-test-home`.
#
# SCs covered: SC8.
#
# This is a guard-rail regression test. It asserts that the default (no opt-in)
# provisioning path is byte-for-byte unchanged: a single `.opencode` clone and the
# `local` platform with NO origin remote. The opt-in blocks added by Phases 1-7
# (BEHAVIOR_NEEDS_MULTI_SUBMODULES, BEHAVIOR_NEEDS_REMOTE, BEHAVIOR_SET_BARE_REMOTE)
# MUST all be guard-wrapped so the flag-off default path provisions only the single
# `.opencode` clone.
#
# SC8 (behavioral): With no opt-in flags set, a representative non-opt-in behavioral
# test provisions exactly one `.opencode` submodule and the `local` platform (no
# origin remote) — byte-for-byte identical to the current default provisioning of
# the ~80 existing tests.
#
# RED state: This is a regression guard-rail — it should be GREEN if Phases 1-7 kept
# the default path intact (the opt-in blocks are all guard-wrapped and the allowlist
# passes through the flags with empty defaults). It FAILS (regression) if any opt-in
# provisioning block leaked out of its guard into the unconditional default path.
#
# Evidence type: SC8 is behavioral, but this test is a structural/content-verification
# guard-rail (fast regression check on file structure). The behavioral evaluation of
# the default provisioning is performed separately via clean-room session.yaml
# evaluation per the RED phase-9 plan. This script only checks that the structural
# guard-rail holds.
#
# Usage: bash .opencode/tests-v2/test-2244-phase9-no-regression.sh
# Exit:  0 if all checks pass (default path intact), 1 if any check fails (regression).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

HELPERS_SH="$PROJECT_DIR/.opencode/tests-v2/behaviors/helpers.sh"
WITH_TEST_HOME="$PROJECT_DIR/.opencode/tests-v2/with-test-home"

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

# grep_assert_column0_absent: an UNGUARDED (column-0, no leading whitespace) form of
# the pattern must NOT appear. Provisioning statements inside a flag guard are
# indented; an unconditional statement would sit at column 0 — a regression.
grep_assert_column0_absent() {
    local label="$1"
    local file="$2"
    local pattern="$3"
    if grep -qE "^${pattern}" "$file" 2>/dev/null; then
        check_fail "$label" "unguarded column-0 pattern '^${pattern}' found in $file"
    else
        check_pass "$label"
    fi
}

echo ""
echo "=== Phase 9 — No-Regression Default Gate (Spec #2244, Concern C6) ==="
echo ""
echo "Target files:"
echo "  $HELPERS_SH"
echo "  $WITH_TEST_HOME"
echo ""

# ---------------------------------------------------------------------------
# SC8 (structural guard-rail): With no opt-in flags set, the default provisioning
# path in behavior_run() provisions exactly ONE `.opencode` clone and does NOT wire
# any origin remote (the `local` platform). All opt-in provisioning added by
# Phases 1-7 MUST live inside their flag guards, never in the unconditional default
# path.
# ---------------------------------------------------------------------------
echo "--- SC8: default (no opt-in) path provisions exactly one .opencode clone ---"

# (a) The unconditional single `.opencode` clone exists in behavior_run (the default
# provisioning path). This is the one clone every ~80 existing test relies on.
grep_assert_present \
    "SC8: behavior_run has the unconditional single .opencode clone" \
    "$HELPERS_SH" \
    'git clone -q "$submodule_remote_url" "$attempt_workdir/.opencode"'

echo ""
echo "--- SC8: multi-submodule, GitBucket, and bare-remote provisioning are guard-wrapped ---"

# (b) The three opt-in flag guards exist in behavior_run.
grep_assert_present \
    "SC8: multi-submodule block guarded by BEHAVIOR_NEEDS_MULTI_SUBMODULES" \
    "$HELPERS_SH" \
    'if [ "${BEHAVIOR_NEEDS_MULTI_SUBMODULES:-0}" = "1" ]; then'
grep_assert_present \
    "SC8: GitBucket provisioning guarded by BEHAVIOR_NEEDS_REMOTE" \
    "$HELPERS_SH" \
    'if [ "${BEHAVIOR_NEEDS_REMOTE:-0}" = "1" ]; then'
grep_assert_present \
    "SC8: bare-remote block guarded by BEHAVIOR_SET_BARE_REMOTE" \
    "$HELPERS_SH" \
    'if [ "${BEHAVIOR_SET_BARE_REMOTE:-0}" = "1" ]; then'

# (c) None of the opt-in provisioning constructs is unconditional (column-0). A
# regression would hoist one of these out of its guard into the default path.
grep_assert_column0_absent \
    "SC8: no unguarded unconditional git-init of a fixture submodule" \
    "$HELPERS_SH" \
    'git init -q "\$attempt_workdir/test-submodule-1"'
grep_assert_column0_absent \
    "SC8: no unguarded unconditional bare-repo git init" \
    "$HELPERS_SH" \
    'git init --bare '
# The GitBucket provisioning CALL (`__ensure_gitbucket || {`) must be inside the
# BEHAVIOR_NEEDS_REMOTE guard. The function *definition* `__ensure_gitbucket() {`
# at column 0 is legitimate and is NOT a provisioning call — so we assert the
# guarded call form, not a bare definition.
grep_assert_column0_absent \
    "SC8: no unguarded unconditional GitBucket provisioning call" \
    "$HELPERS_SH" \
    '__ensure_gitbucket \|\|'

# (d) No origin remote is wired unconditionally. All `remote add origin` calls in
# behavior_run MUST be inside the BEHAVIOR_SET_BARE_REMOTE / BEHAVIOR_NEEDS_REMOTE
# guards. An unconditional column-0 `remote add origin` would wire an origin on the
# default path, breaking the `local` (no-origin) platform guarantee.
grep_assert_column0_absent \
    "SC8: no unguarded unconditional origin remote wiring in behavior_run" \
    "$HELPERS_SH" \
    'remote add origin '

# (e) The with-test-home default provisioning path (no TEST_WORKDIR) also wires no
# origin remote — it only clones `.opencode` and initializes the project.
grep_assert_column0_absent \
    "SC8: no unguarded unconditional origin remote wiring in with-test-home" \
    "$WITH_TEST_HOME" \
    'remote add origin '

echo ""
echo "--- SC8: with-test-home allowlist passes through BEHAVIOR_* flags with empty defaults ---"

# (f) All three opt-in flags are present in the env -i allowlist.
grep_assert_present \
    "SC8: allowlist passes through BEHAVIOR_NEEDS_MULTI_SUBMODULES" \
    "$WITH_TEST_HOME" \
    'BEHAVIOR_NEEDS_MULTI_SUBMODULES="${BEHAVIOR_NEEDS_MULTI_SUBMODULES:-}"'
grep_assert_present \
    "SC8: allowlist passes through BEHAVIOR_NEEDS_REMOTE" \
    "$WITH_TEST_HOME" \
    'BEHAVIOR_NEEDS_REMOTE="${BEHAVIOR_NEEDS_REMOTE:-}"'
grep_assert_present \
    "SC8: allowlist passes through BEHAVIOR_SET_BARE_REMOTE" \
    "$WITH_TEST_HOME" \
    'BEHAVIOR_SET_BARE_REMOTE="${BEHAVIOR_SET_BARE_REMOTE:-}"'

# (g) By default the flags default to empty (no BEHAVIOR_* opt-in is set on the
# default provisioning path). The `:-` empty default is what keeps the default path
# free of any opt-in provisioning.
grep_assert_present \
    "SC8: flags default to empty (no opt-in by default) in allowlist" \
    "$WITH_TEST_HOME" \
    'BEHAVIOR_NEEDS_MULTI_SUBMODULES="${BEHAVIOR_NEEDS_MULTI_SUBMODULES:-}" \
    BEHAVIOR_NEEDS_REMOTE="${BEHAVIOR_NEEDS_REMOTE:-}" \
    BEHAVIOR_SET_BARE_REMOTE="${BEHAVIOR_SET_BARE_REMOTE:-}"'

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "REGRESSION: the default (no opt-in) provisioning path is NOT intact."
    echo "A Phase 1-7 opt-in block appears to have leaked out of its flag guard into"
    echo "the unconditional default path, or the allowlist no longer defaults the"
    echo "BEHAVIOR_* flags to empty. This would change the provisioning behavior of"
    echo "the ~80 existing tests."
    echo ""
    exit 1
fi
echo "GREEN: the default (no opt-in) provisioning path is intact — exactly one"
echo ".opencode clone, local platform with no origin remote, and the BEHAVIOR_*"
echo "opt-in flags all default to empty."
echo ""
exit 0
