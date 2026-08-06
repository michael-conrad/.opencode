#!/bin/bash
# Content-Verification Enforcement Test: Phase 1 — env -i Allowlist Extension + Isolation (Concern C4)
#
# Issue: .opencode#2244 — full-environment simulation in the tests-v2 harness.
# Phase: red-phase1-allowlist — Concern C4, `.opencode/tests-v2/with-test-home`.
#
# SCs covered: SC5, SC6, SC7, SC14, SC15.
#
# This is a RED-phase test. The GREEN implementation has NOT been applied yet, so the
# assertions below are expected to FAIL (non-zero exit). The GREEN phase will:
#   1. Add BEHAVIOR_NEEDS_MULTI_SUBMODULES / BEHAVIOR_NEEDS_REMOTE / BEHAVIOR_SET_BARE_REMOTE
#      to the env -i allowlist as a strict superset (no removals/reorders)  -> SC5
#   2. Record the three flags in set-env.sh                                   -> SC6
#   3. Keep the isolation procedure clean (no production leak admitted)       -> SC7
#   4. Keep the allowlist to exactly the minimal infrastructure set           -> SC14
#   5. Exclude all parent-sourced secret/credential/token/env vars            -> SC15
#
# Evidence types: SC5/SC6/SC7 are structural; SC14/SC15 are string. All are
# content-verification assertions on `.opencode/tests-v2/with-test-home`.
#
# Usage: bash .opencode/tests-v2/test-2244-phase1-allowlist.sh
# Exit:  0 if all checks pass (GREEN), 1 if any check fails (expected RED).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

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
echo "=== Phase 1 — env -i Allowlist Extension + Isolation (Spec #2244, Concern C4) ==="
echo ""
echo "Target file: $WITH_TEST_HOME"
echo ""

# ---------------------------------------------------------------------------
# SC5 (structural): env -i allowlist passes the three new BEHAVIOR_* flags
# through as a strict superset (no removals, no reorders).
# Currently the three flags are set only in helpers.sh (behavior_run()), NOT
# passed through the env -i allowlist in with-test-home — so these are RED.
# ---------------------------------------------------------------------------
echo "--- SC5: allowlist passes the three new BEHAVIOR_* flags ---"
grep_assert_present \
    "SC5: allowlist passes BEHAVIOR_NEEDS_MULTI_SUBMODULES" \
    "$WITH_TEST_HOME" \
    "BEHAVIOR_NEEDS_MULTI_SUBMODULES"
grep_assert_present \
    "SC5: allowlist passes BEHAVIOR_NEEDS_REMOTE" \
    "$WITH_TEST_HOME" \
    "BEHAVIOR_NEEDS_REMOTE"
grep_assert_present \
    "SC5: allowlist passes BEHAVIOR_SET_BARE_REMOTE" \
    "$WITH_TEST_HOME" \
    "BEHAVIOR_SET_BARE_REMOTE"

# Strict superset: the previously allowlisted infrastructure vars must remain.
# These anchor the allowlist so GREEN cannot silently remove existing entries.
echo "--- SC5: strict superset — previously allowlisted vars remain ---"
for var in "HOME=" "PATH=" "XDG_CONFIG_HOME=" "XDG_CACHE_HOME=" "XDG_RUNTIME_DIR=" \
           "XDG_DATA_HOME=" "XDG_STATE_HOME=" "SNAP_USER_DATA=" "SNAP_USER_COMMON=" \
           "USER=" "GIT_CONFIG_NOSYSTEM=" "SHELL=" "LOGNAME=" "LANG=" "TERM="; do
    grep_assert_present \
        "SC5: allowlist keeps $var" \
        "$WITH_TEST_HOME" \
        "$var"
done

# ---------------------------------------------------------------------------
# SC6 (structural): set-env.sh records the three new flags.
# Currently set-env.sh only records GB_TOKEN/GB_HOST/GITBUCKET_PORT — RED.
# ---------------------------------------------------------------------------
echo "--- SC6: set-env.sh records the three new flags ---"
grep_assert_present \
    "SC6: set-env.sh records BEHAVIOR_NEEDS_MULTI_SUBMODULES" \
    "$WITH_TEST_HOME" \
    "BEHAVIOR_NEEDS_MULTI_SUBMODULES"
grep_assert_present \
    "SC6: set-env.sh records BEHAVIOR_NEEDS_REMOTE" \
    "$WITH_TEST_HOME" \
    "BEHAVIOR_NEEDS_REMOTE"
grep_assert_present \
    "SC6: set-env.sh records BEHAVIOR_SET_BARE_REMOTE" \
    "$WITH_TEST_HOME" \
    "BEHAVIOR_SET_BARE_REMOTE"

# ---------------------------------------------------------------------------
# SC7 (structural): isolation — the allowlist does not admit any parent-sourced
# production secret/credential/platform-token/env-specific variable.
# Parent-sourced GB_*/GITBUCKET_PORT would appear as an unguarded "${GB_TOKEN:-}"
# passthrough (parent-leak). Phase 2 (Concern C5) legitimately admits TEST-
# PROVISIONED GB_* ONLY inside a BEHAVIOR_NEEDS_REMOTE=1 guard — those are the
# test-generated values, not parent secrets. The parent-source-detecting pattern
# is the unguarded passthrough, which must remain absent.
# ---------------------------------------------------------------------------
echo "--- SC7: isolation — allowlist does not admit parent-sourced secrets/tokens ---"
grep_assert_absent \
    "SC7: allowlist excludes parent-sourced GB_TOKEN passthrough" \
    "$WITH_TEST_HOME" \
    'GB_TOKEN=\${GB_TOKEN'
grep_assert_absent \
    "SC7: allowlist excludes parent-sourced GB_HOST passthrough" \
    "$WITH_TEST_HOME" \
    'GB_HOST=\${GB_HOST'
grep_assert_absent \
    "SC7: allowlist excludes parent-sourced GITBUCKET_PORT passthrough" \
    "$WITH_TEST_HOME" \
    'GITBUCKET_PORT=\${GITBUCKET_PORT'

# ---------------------------------------------------------------------------
# SC14 (string): the allowlist contains ONLY the minimal, explicitly enumerated
# infrastructure set (PATH, SHELL, TERM, LANG, USER, LOGNAME, GIT_CONFIG_NOSYSTEM,
# XDG_*, SNAP_USER_DATA/SNAP_USER_COMMON, and test-provisioned values).
# Test-provisioned GB_*/GITBUCKET_PORT (guarded by BEHAVIOR_NEEDS_REMOTE=1) ARE
# part of the minimal test-provisioned set. Parent-sourced GB_* (unguarded
# "${VAR}" passthrough) are NOT and must remain absent.
# ---------------------------------------------------------------------------
echo "--- SC14: allowlist admits ONLY the minimal infrastructure set ---"
grep_assert_absent \
    "SC14: allowlist admits no parent-sourced GB_* outside minimal set" \
    "$WITH_TEST_HOME" \
    'GB_[A-Z_]*=\${GB_[A-Z_]*'
grep_assert_absent \
    "SC14: allowlist admits no parent-sourced GITBUCKET_PORT passthrough" \
    "$WITH_TEST_HOME" \
    'GITBUCKET_PORT=\${GITBUCKET_PORT'

# ---------------------------------------------------------------------------
# SC15 (string): the allowlist excludes all parent-sourced secret/credential/
# token/env-specific variables: GB_*, GITHUB_*, GH_*, NODE_ENV, VIRTUAL_ENV,
# CONDA_DEFAULT_ENV, OPENCODE_CONFIG_CONTENT, and API keys.
# "Parent-sourced" GB_* means the unguarded "${GB_*}" passthrough form. The
# test-provisioned guarded entries (BEHAVIOR_NEEDS_REMOTE=1) are not parent-
# sourced and are excluded from this SC (covered by Phase 2 SC17).
# ---------------------------------------------------------------------------
echo "--- SC15: allowlist excludes secret/credential/token/env vars ---"
grep_assert_absent \
    "SC15: allowlist excludes parent-sourced GB_* passthrough" \
    "$WITH_TEST_HOME" \
    'GB_[A-Z_]*=\${GB_[A-Z_]*'
grep_assert_absent \
    "SC15: allowlist excludes GITHUB_*" \
    "$WITH_TEST_HOME" \
    'GITHUB_[A-Z_]*='
grep_assert_absent \
    "SC15: allowlist excludes GH_*" \
    "$WITH_TEST_HOME" \
    'GH_[A-Z_]*='
grep_assert_absent \
    "SC15: allowlist excludes NODE_ENV" \
    "$WITH_TEST_HOME" \
    'NODE_ENV='
grep_assert_absent \
    "SC15: allowlist excludes VIRTUAL_ENV" \
    "$WITH_TEST_HOME" \
    'VIRTUAL_ENV='
grep_assert_absent \
    "SC15: allowlist excludes CONDA_DEFAULT_ENV" \
    "$WITH_TEST_HOME" \
    'CONDA_DEFAULT_ENV='
grep_assert_absent \
    "SC15: allowlist excludes OPENCODE_CONFIG_CONTENT" \
    "$WITH_TEST_HOME" \
    'OPENCODE_CONFIG_CONTENT='

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: Phase 1 (allowlist extension + isolation) not yet implemented."
    echo "The allowlist/set-env.sh do not yet pass/record the three BEHAVIOR_* flags,"
    echo "and the allowlist still admits parent-sourced GB_*/GITBUCKET_PORT."
    echo ""
    exit 1
fi
exit 0
