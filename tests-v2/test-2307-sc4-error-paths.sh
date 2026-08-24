#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral Enforcement Test: 2307-sc4-error-paths
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# Issue: .opencode#2307 — git-workflow/enforcement/url_validation.sh hardcodes base
# branch 'dev' instead of $DEFAULT_BRANCH.
#
# SC-4: The existing `set -euo pipefail`, owner/repo character-match verification, and
#       error returns remain intact after the base resolution change.
#
# Evidence type: behavioral — the test SOURCES url_validation.sh, INVOKES
# `construct_compare_url` with missing required arguments, and asserts the function
# emits ERROR and returns non-zero. It also asserts the `set -euo pipefail` guard is
# retained in the script. This is runtime-output verification of the shell function
# (bash test.sh behavioral testing per the evidence type taxonomy).
#
# NOTE: The owner/repo character-match check is a tautology — the URL is constructed
# from the owner/repo strings, so the URL always contains them by construction. A
# failing character-match assertion is therefore not behaviorally testable and is NOT
# attempted. The behaviorally testable error-path behaviors asserted here are:
#   (a) missing required arguments (no --owner/--repo/--branch) -> ERROR + non-zero exit
#   (b) `set -euo pipefail` retained in the script
#
# RED state: if the base resolution change removed the missing-argument guard or the
# `set -euo pipefail` guard, the assertions below would FAIL. The test is RED until the
# error/verification paths are preserved.
#
# Usage: bash .opencode/tests-v2/test-2307-sc4-error-paths.sh
# Exit:  0 if all checks pass (GREEN), 1 if any check fails (expected RED).

# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done

URL_VALIDATION_SH="$PROJECT_DIR/skills/git-workflow/enforcement/url_validation.sh"

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

echo ""
echo "=== SC-4: error paths and set -euo pipefail retained ==="
echo ""
echo "Target file: $URL_VALIDATION_SH"
echo ""

# (a) Missing required arguments (no --owner/--repo/--branch) -> ERROR + non-zero exit.
# Invoke construct_compare_url with no arguments and capture stdout+stderr and the
# function's exit code. The `|| rc=$?` guard captures the non-zero return without
# letting `set -e` abort the inner script before the rc is echoed.
OUTPUT="$(bash -c '
set -euo pipefail
source "$1"
rc=0
construct_compare_url || rc=$?
echo "rc=$rc"
' _ "$URL_VALIDATION_SH" 2>&1)" || true

echo "  (construct_compare_url output: $(echo "$OUTPUT" | tr '\n' ' '))"

if echo "$OUTPUT" | grep -q "ERROR: Missing required arguments for URL construction"; then
    check_pass "SC-4: missing required arguments emits ERROR"
else
    check_fail "SC-4: missing required arguments emits ERROR" \
        "got output without 'ERROR: Missing required arguments for URL construction' (RED)"
fi

RC="$(echo "$OUTPUT" | grep -o 'rc=[0-9]*' | tail -1 || true)"
if [ "$RC" = "rc=1" ]; then
    check_pass "SC-4: missing required arguments returns non-zero exit (rc=1)"
else
    check_fail "SC-4: missing required arguments returns non-zero exit (rc=1)" \
        "got '$RC' (expected 'rc=1' — RED: missing-argument guard removed)"
fi

# (b) `set -euo pipefail` retained in the script.
if grep -q '^set -euo pipefail' "$URL_VALIDATION_SH"; then
    check_pass "SC-4: 'set -euo pipefail' retained in url_validation.sh"
else
    check_fail "SC-4: 'set -euo pipefail' retained in url_validation.sh" \
        "no 'set -euo pipefail' found in $URL_VALIDATION_SH (RED)"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-4 (error paths / set -euo pipefail) not yet applied."
    echo "The base resolution change must not remove the missing-argument guard, the"
    echo "ERROR + non-zero return, or the 'set -euo pipefail' guard."
    echo ""
    exit 1
fi
exit 0
