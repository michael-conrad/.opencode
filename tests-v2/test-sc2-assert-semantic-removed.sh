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

SCENARIOS=(
    "2219-sc10-non-pointer-guard"
    "2219-sc11-existing-cleanup"
    "2219-sc15-decline-submodule-pr"
    "2219-sc16-stale-pointer-block"
    "2219-sc19-release-pr-prework"
    "2219-sc3-prework-ordering"
    "2219-sc6-dead-branch-detection"
    "2219-sc7-submodule-pr-verification"
    "2219-sc8-dead-branch-deletion"
    "2219-sc9-dirty-pointer"
    "2239-sc8-check-pr-routing"
    "skill-deck-completeness"
)

PASS_COUNT=0
FAIL_COUNT=0
FAILED_SCRIPTS=()

echo ""
echo "=== SC-2 (#2245): assert_semantic removed from 12 behavior scripts ==="
echo ""

for scenario in "${SCENARIOS[@]}"; do
    script="$PROJECT_DIR/.opencode/tests-v2/behaviors/${scenario}.sh"
    if [ ! -f "$script" ]; then
        echo "  FAIL: $scenario -- script not found: $script"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        FAILED_SCRIPTS+=("$scenario (missing)")
        continue
    fi
    if grep -q "assert_semantic" "$script"; then
        echo "  FAIL: $scenario -- assert_semantic token still present in $script"
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
