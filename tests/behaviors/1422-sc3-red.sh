#!/usr/bin/env bash
# ============================================================
# RED test for SC-3 — #1422: Cost-blind universal scope
#
# Verifies: 020-go-prohibitions.md still has old "Cost-blind
# verification" section header (not yet renamed to universal).
# This test MUST FAIL in RED phase because the old header exists.
# ============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/helpers.sh"

OVERALL_RESULT=0
TEST_NAME="1422-sc3-red"

echo "=== RED: SC-3 cost-blind universal scope ==="

# SC-3 content verification: old header should exist in RED phase
echo "Checking for old section header 'Cost-blind verification'..."
if grep -q 'Cost-blind verification' .opencode/guidelines/020-go-prohibitions.md 2>/dev/null; then
    echo "  [EXPECTED FAIL] Old header 'Cost-blind verification' exists — RED phase test correctly FAILS"
    OVERALL_RESULT=1
else
    echo "  [UNEXPECTED] Old header not found — may already be renamed"
fi

# Verify the new header does NOT exist yet
echo "Checking for new header 'Cost-blind universal'..."
if grep -q 'Cost-blind universal' .opencode/guidelines/020-go-prohibitions.md 2>/dev/null; then
    echo "  [UNEXPECTED] New header already present"
fi

echo "---"
if [ "$OVERALL_RESULT" -ne 0 ]; then
    echo "RED test FAIL (expected): SC-3 old header still present, rename not yet applied"
fi
exit $OVERALL_RESULT
