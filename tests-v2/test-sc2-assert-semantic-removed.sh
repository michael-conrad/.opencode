#!/usr/bin/env bash
# RED test for SC-2 (#2245): All 12 behavior scripts remove the inline assert_semantic
# call and its "# Evaluate with assert_semantic" comment.
#
# This test asserts the assert_semantic token is ABSENT from each of the 12 call-site
# scripts. It currently IS present (the removal has not happened yet), so this test
# MUST FAIL (RED phase).
#
# Usage: bash .opencode/tests-v2/test-sc2-assert-semantic-removed.sh
# Exit: 0 if all 12 scripts are free of assert_semantic, 1 if any still contains it

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

# Dynamic scan: every behaviors script (including subdirectories) must be free
# of the forbidden self-evaluation tokens — the artifact-only paradigm forbids
# scripts evaluating model output (tests-v2/AGENTS.md §1).
EXCLUDE="helpers.sh"

PASS_COUNT=0
FAIL_COUNT=0
FAILED_SCRIPTS=()

echo ""
echo "=== SC-2 (#2245): assert_semantic removed from 12 behavior scripts ==="
echo ""

for f in "$PROJECT_DIR"/.opencode/tests-v2/behaviors/*.sh \
         "$PROJECT_DIR"/.opencode/tests-v2/behaviors/secret-redaction/*.sh; do
    [ -f "$f" ] || continue
    scenario=$(basename "$f")
    [ "$scenario" = "$EXCLUDE" ] && continue
    if grep -q "assert_semantic" "$f"; then
        echo "  FAIL: $scenario -- assert_semantic token still present"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        FAILED_SCRIPTS+=("$scenario")
    else
        echo "  PASS: $scenario -- no assert_semantic token"
        PASS_COUNT=$((PASS_COUNT + 1))
    fi
done

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: assert_semantic token still present in:"
    for f in "${FAILED_SCRIPTS[@]}"; do
        echo "  - $f"
    done
    echo ""
    exit 1
fi
exit 0
