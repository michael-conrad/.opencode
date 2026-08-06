#!/bin/bash
# Content-Verification Enforcement Test: Phase 5 — Cleanup of Provisioned State (Concern C7)
#
# Issue: .opencode#2244 — full-environment simulation in the tests-v2 harness.
# Phase: red-phase5-cleanup — Concern C7, cleanup of provisioned state.
#        Targets `.opencode/tests-v2/behaviors/helpers.sh` (__kill_gitbucket, __reset_gitbucket)
#        and `.opencode/tests-v2/with-test-home` (do_clean_all, do_clean).
#
# SCs covered: SC9.
#
# This is a RED-phase test. The GREEN implementation has NOT been applied yet, so the
# assertions below are expected to FAIL (non-zero exit). The GREEN phase will:
#   1. Extend __kill_gitbucket() to also remove the GitBucket data dir (it currently
#      removes only the pid file and port file — the data dir is left behind).
#   2. Extend do_clean_all() (and __kill_gitbucket()) to explicitly remove the
#      multi-submodule fixture clones (test-submodule-1, test-submodule-2) that Phase 3
#      provisioned inside the test project — they currently fall through cleanup.
#
# Evidence type: SC9 is behavioral (cleanup of provisioned state). Per the #2244 plan,
# the RED gate for Phase 5 uses structural/content-verification assertions on the
# cleanup functions checking that all provisioned state is handled. The behavioral
# runtime verification (a --clean-all run removes a live provisioned GitBucket + test
# homes + multi-submodule clones, idempotently) is the GREEN doublecheck / VbC step.
#
# RED state:
#   - __kill_gitbucket() (helpers.sh) removes the GitBucket pid file and port file but
#     NOT the data dir ($PARENT_REPO_DIR/tmp/gitbucket-data). Only __reset_gitbucket()
#     and do_clean_all() remove the data dir. So the data-dir assertion for
#     __kill_gitbucket() is RED.
#   - Neither do_clean_all() (with-test-home) nor __kill_gitbucket() references the
#     test-submodule-1/test-submodule-2 fixture clones that Phase 3 (SC1) provisioned
#     inside the test project. So the multi-submodule-clone assertions are RED.
#
# Usage: bash .opencode/tests-v2/test-2244-phase5-cleanup.sh
# Exit:  0 if all checks pass (GREEN), 1 if any check fails (expected RED).

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
    if grep -qF -- "$pattern" "$file" 2>/dev/null; then
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
    if grep -qE -- "$pattern" "$file" 2>/dev/null; then
        check_fail "$label" "forbidden pattern '$pattern' found in $file"
    else
        check_pass "$label"
    fi
}

# func_body: echo the body of a named function from a file (between "name() {"
# and the next top-level "name() {" or "name()" line). Used to scope content
# assertions to a specific function so a string present elsewhere in the file
# does not produce a false pass.
func_body() {
    local file="$1"
    local func="$2"
    awk -v f="$func" '
        $0 ~ "^" f "\\s*\\(" { infunc=1; next }
        infunc && /^[A-Za-z_][A-Za-z0-9_]*\s*\(\)/ { exit }
        infunc { print }
    ' "$file"
}

echo ""
echo "=== Phase 5 — Cleanup of Provisioned State (Spec #2244, Concern C7) ==="
echo ""
echo "Target files: $HELPERS_SH"
echo "              $WITH_TEST_HOME"
echo ""

# ---------------------------------------------------------------------------
# SC9 (behavioral via content-verification for the RED gate): Cleanup —
# --clean-all / __kill_gitbucket removes new clones (test-submodule-1/2,
# .opencode) + GitBucket state (pid, port, data dir) and test homes, and is
# idempotent.
#
# The cleanup must handle five classes of provisioned state:
#   (a) GitBucket pid file  -> tmp/.gitbucket.pid
#   (b) GitBucket port file -> tmp/.gitbucket.port
#   (c) GitBucket data dir  -> tmp/gitbucket-data
#   (d) test home dirs      -> tmp/test-home-*
#   (e) multi-submodule fixture clones -> test-submodule-1, test-submodule-2
#        (provisioned by Phase 3 / SC1 inside the test project)
#
# GREEN adds (c) to __kill_gitbucket() and (e) to both do_clean_all() and
# __kill_gitbucket(). Assertions for the already-handled classes are presence
# checks (PASS-now); assertions for (c)-in-__kill_gitbucket and (e) are RED.
# ---------------------------------------------------------------------------
echo "--- SC9: cleanup of provisioned state ---"

# --- (a) GitBucket pid file ---
# Handled today by both do_clean_all (with-test-home) and __kill_gitbucket (helpers.sh).
grep_assert_present \
    "SC9: do_clean_all removes the GitBucket pid file" \
    "$WITH_TEST_HOME" \
    "rm -f \"\$gb_pid_file\""
grep_assert_present \
    "SC9: __kill_gitbucket removes the GitBucket pid file" \
    "$HELPERS_SH" \
    'rm -f "$pid_file"'

# --- (b) GitBucket port file ---
# Handled today by both do_clean_all and __kill_gitbucket.
grep_assert_present \
    "SC9: do_clean_all removes the GitBucket port file" \
    "$WITH_TEST_HOME" \
    "rm -f \"\$PROJECT_DIR/tmp/.gitbucket.port\""
grep_assert_present \
    "SC9: __kill_gitbucket removes the GitBucket port file" \
    "$HELPERS_SH" \
    'rm -f "$PARENT_REPO_DIR/tmp/.gitbucket.port"'

# --- (c) GitBucket data dir ---
# do_clean_all removes the data dir today; __kill_gitbucket does NOT. The
# __kill_gitbucket body must be extended to remove the data dir. RED.
grep_assert_present \
    "SC9: do_clean_all removes the GitBucket data dir" \
    "$WITH_TEST_HOME" \
    "rm -rf \"\$PROJECT_DIR/tmp/gitbucket-data\""

# __kill_gitbucket body must reference the data dir variable. GREEN introduces
# GITBUCKET_DATA_DIR (and an rm -rf on it) inside __kill_gitbucket. RED now.
if func_body "$HELPERS_SH" "__kill_gitbucket" | grep -qF "GITBUCKET_DATA_DIR"; then
    check_pass "SC9: __kill_gitbucket references the GitBucket data dir variable"
else
    check_fail "SC9: __kill_gitbucket references the GitBucket data dir variable" \
        "__kill_gitbucket body has no GITBUCKET_DATA_DIR reference (data dir left behind)"
fi

# __kill_gitbucket body must remove the data dir. RED now.
if func_body "$HELPERS_SH" "__kill_gitbucket" | grep -qE 'rm -rf[[:space:]]+"\$?\{?GITBUCKET_DATA_DIR'; then
    check_pass "SC9: __kill_gitbucket removes the GitBucket data dir"
else
    check_fail "SC9: __kill_gitbucket removes the GitBucket data dir" \
        "__kill_gitbucket body has no rm -rf on the GitBucket data dir"
fi

# --- (d) test home dirs ---
# do_clean_all removes ALL test-home-* dirs under tmp/. Handled today.
grep_assert_present \
    "SC9: do_clean_all removes all test home dirs" \
    "$WITH_TEST_HOME" \
    "-name 'test-home-*'"

# --- (e) multi-submodule fixture clones (test-submodule-1/2) ---
# Phase 3 (SC1) provisions test-submodule-1 and test-submodule-2 inside the test
# project. Cleanup MUST explicitly remove these new clones. do_clean_all does NOT
# reference them today — the clones fall through cleanup. RED.
grep_assert_present \
    "SC9: do_clean_all explicitly removes the multi-submodule fixture clones" \
    "$WITH_TEST_HOME" \
    "test-submodule"

# __kill_gitbucket must also handle the multi-submodule fixture clones. RED now.
if func_body "$HELPERS_SH" "__kill_gitbucket" | grep -qE 'test-submodule'; then
    check_pass "SC9: __kill_gitbucket handles the multi-submodule fixture clones"
else
    check_fail "SC9: __kill_gitbucket handles the multi-submodule fixture clones" \
        "__kill_gitbucket body has no test-submodule reference"
fi

# --- Idempotence guard ---
# Cleanup must be idempotent: each removal must be safe when the state is already
# absent. do_clean_all guards the pid-file kill behind -f and uses rm -f / rm -rf
# which are no-op on absent paths. Assert the port/data removals are unconditional
# (rm -f / rm -rf) rather than wrapped in a guarded block that could skip them.
grep_assert_present \
    "SC9: do_clean_all port-file removal is unconditional (rm -f, idempotent)" \
    "$WITH_TEST_HOME" \
    "rm -f \"\$PROJECT_DIR/tmp/.gitbucket.port\""

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: Phase 5 (cleanup of provisioned state) not yet implemented."
    echo "Gaps found:"
    echo "  - __kill_gitbucket() removes the GitBucket pid + port files but NOT the"
    echo "    data dir (tmp/gitbucket-data). GREEN adds data-dir removal to"
    echo "    __kill_gitbucket()."
    echo "  - Neither do_clean_all() (with-test-home) nor __kill_gitbucket() explicitly"
    echo "    removes the multi-submodule fixture clones (test-submodule-1/2) that Phase 3"
    echo "    provisions inside the test project. GREEN adds explicit clone cleanup."
    echo ""
    exit 1
fi
exit 0
