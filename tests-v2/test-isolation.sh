#!/bin/bash
# Test isolation structural verification — maps to spec #309 SCs.
# Specification recorded in the issues-data store.
#
# Usage: bash .opencode/tests-v2/test-isolation.sh
# Exit: 0 if all checks pass, 1 if any check fails
#
# SC-1 through SC-12: Structural invariants for test isolation.
# SC-10 and SC-11 are behavioral — covered by secret-redaction/SC-9-isolation-verify.sh.

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

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

grep_assert_present() {
    local label="$1"
    local file="$2"
    local pattern="$3"
    if grep -q "$pattern" "$file" 2>/dev/null; then
        check_pass "$label"
    else
        check_fail "$label" "pattern '$pattern' not found in $file"
    fi
}

grep_assert_absent() {
    local label="$1"
    local file="$2"
    local pattern="$3"
    if grep -q "$pattern" "$file" 2>/dev/null; then
        check_fail "$label" "forbidden pattern '$pattern' found in $file"
    else
        check_pass "$label"
    fi
}

echo ""
echo "=== Test Isolation — Spec #309 Structural Verification ==="
echo ""

WITH_TEST_HOME="$PROJECT_DIR/.opencode/tests-v2/with-test-home"
HELPERS="$PROJECT_DIR/.opencode/tests-v2/behaviors/helpers.sh"
SC2_SCRIPT="$PROJECT_DIR/.opencode/tests-v2/behaviors/secret-redaction/SC-3.sh"

# SC-1: with-test-home execution block uses env -i with explicit allowlist
# The env -i mechanism is the ONLY way to guarantee no parent env leaks.
grep_assert_present \
    "SC-1: with-test-home execution block uses env -i" \
    "$WITH_TEST_HOME" \
    "env -i"

# SC-2: with-test-home sets HOME to test home in execution block
# Missing HOME means $HOME/.local/share/opencode/ fallback paths hit production.
grep_assert_present \
    "SC-2: with-test-home sets HOME to test home" \
    "$WITH_TEST_HOME" \
    '[[:space:]]HOME="'

# SC-3: with-test-home copies .tools/opencode/opencode to $TEST_HOME/bin/opencode
# The standalone binary must be placed in the test home so env -i PATH resolution finds it.
grep_assert_present \
    "SC-3: with-test-home copies standalone binary to \$TEST_HOME/bin" \
    "$WITH_TEST_HOME" \
    'TEST_HOME/bin/opencode'

# SC-4: with-test-home prepends $TEST_HOME/bin to PATH
# PATH must include the test home bin directory so bare "opencode" resolves to the standalone binary.
grep_assert_present \
    "SC-4: with-test-home prepends \$TEST_HOME/bin to PATH" \
    "$WITH_TEST_HOME" \
    'PATH=.*TEST_HOME/bin'

# SC-5: helpers.sh does NOT run opencode models at source time
# Source-time execution hits production DB because helpers.sh is sourced outside with-test-home.
# The literal "opencode models" only appears in an echo string inside __init_model_pool().
# The actual call uses ${OPENCODE_CMD[@]} — check that no bare command exists at file scope.
grep_assert_absent \
    "SC-5: helpers.sh no opencode models at source time" \
    "$HELPERS" \
    '^opencode models'

# SC-6: with-test-home and helpers.sh use bare "opencode" not absolute path
# Absolute path bypasses env -i PATH resolution, making $TEST_HOME/bin/opencode dead code.
grep_assert_present \
    "SC-6: with-test-home uses bare opencode" \
    "$WITH_TEST_HOME" \
    'OPENCODE_CMD=("opencode")'

grep_assert_present \
    "SC-6: helpers.sh uses bare opencode" \
    "$HELPERS" \
    'OPENCODE_CMD=("opencode")'

# SC-7: secret-redaction/SC-3.sh uses behavior_run() from helpers.sh
# Direct opencode run bypasses with-test-home isolation.
grep_assert_present \
    "SC-7: SC-3.sh uses behavior_run()" \
    "$SC2_SCRIPT" \
    'behavior_run'

# SC-8 (dynamic): NO behaviors script contains an executable `snap run` —
# occurrences must be comment-only (forbidden-pattern examples are allowed).
# snap run opencode hardcodes SNAP_USER_DATA=~/snap/opencode/ and writes to production DB.
for f in "$PROJECT_DIR"/.opencode/tests-v2/behaviors/*.sh \
         "$PROJECT_DIR"/.opencode/tests-v2/behaviors/secret-redaction/*.sh; do
    [ -f "$f" ] || continue
    bad=$(grep -n 'snap run' "$f" 2>/dev/null | grep -v '^[0-9]*:[[:space:]]*#' || true)
    if [ -n "$bad" ]; then
        check_fail "SC-8: no executable snap run ($(basename "$f"))" "$bad"
    else
        check_pass "SC-8: no executable snap run ($(basename "$f"))"
    fi
done

# SC-9 (dynamic): every model-executing behaviors script isolates through
# behavior_run() (helpers.sh) or with-test-home directly; the library
# (helpers.sh) and the harness diagnostic (source-db-missing.sh) are exempt.
for f in "$PROJECT_DIR"/.opencode/tests-v2/behaviors/*.sh; do
    base=$(basename "$f")
    [ "$base" = "helpers.sh" ] && continue
    [ "$base" = "source-db-missing.sh" ] && continue
    if grep -qE 'behavior_run|with-test-home' "$f"; then
        check_pass "SC-9: $base isolates via behavior_run/with-test-home"
    else
        check_fail "SC-9: $base isolation entry point" "no behavior_run or with-test-home reference"
    fi
done

# SC-12: with-test-home prints diagnostic [test-env] lines before running command
# Diagnostic output proves the test environment variables are set correctly.
grep_assert_present \
    "SC-12: with-test-home prints [test-env] diagnostics" \
    "$WITH_TEST_HOME" \
    '\[test-env\]'

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""

# SC-10 and SC-11 are behavioral — run separately:
#   bash .opencode/tests-v2/behaviors/secret-redaction/SC-9-isolation-verify.sh

if [ "$FAIL_COUNT" -gt 0 ]; then
    exit 1
fi
exit 0
