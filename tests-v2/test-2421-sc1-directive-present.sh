#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: live-registry verification directive present
# Maps to SC-5 from issue #2421: the standalone content test asserts the
# directive text (live-registry verification mandate, justified-older-pin
# exception, training-data recall prohibition) exists in
# .opencode/guidelines/070-environment.md.
#
# RED phase: the directive text is absent from 070-environment.md — this
# test FAILS (exit 1).
# GREEN phase: after the directive is present, this test PASSES (exit 0).
#
# Usage: bash .opencode/tests-v2/test-2421-sc1-directive-present.sh
# Exit: 0 if all checks pass, 1 if any check fails

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
    echo "  FAIL: $label -- $detail" >&2
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

echo ""
echo "=== Live-registry verification directive present -- SC-5 (#2421) ==="
echo ""

GUIDELINE_FILE="$PROJECT_DIR/.opencode/guidelines/070-environment.md"

# SC-5: the live-registry verification mandate is present (naming the
# registries and the verification step before pinning).
if grep -qi "live-registry verification\|Live-Registry Verification" "$GUIDELINE_FILE"; then
    check_pass "SC-5: live-registry verification mandate present in 070-environment.md"
else
    check_fail "SC-5: live-registry verification mandate present in 070-environment.md" "no live-registry verification mandate found in $GUIDELINE_FILE"
fi

# SC-5: the justified-older-pin exception is present.
if grep -qi "justified-older-pin exception\|Justified-older-pin exception" "$GUIDELINE_FILE"; then
    check_pass "SC-5: justified-older-pin exception present in 070-environment.md"
else
    check_fail "SC-5: justified-older-pin exception present in 070-environment.md" "justified-older-pin exception wording not found in $GUIDELINE_FILE"
fi

# SC-5: the training-data recall prohibition is present.
if grep -qi "training data is always stale\|recall dependency version numbers from training data\|SHALL NOT recall dependency version" "$GUIDELINE_FILE"; then
    check_pass "SC-5: training-data recall prohibition present in 070-environment.md"
else
    check_fail "SC-5: training-data recall prohibition present in 070-environment.md" "training-data recall prohibition wording not found in $GUIDELINE_FILE"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""

if [ "$FAIL_COUNT" -gt 0 ]; then
    exit 1
fi
exit 0
