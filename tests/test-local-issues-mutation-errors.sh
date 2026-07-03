#!/usr/bin/env bash
# RED-phase test: local-issues mutation error handling
#
# Tests for the PRESENCE of "Available qualifiers" in error output.
# In RED phase, this will FAIL (feature not yet implemented).
# After GREEN implementation, this test will PASS.
#
# SC-1: bare number on update  → error + "Available qualifiers"
# SC-2: non-existent repo      → error + "Available qualifiers"
# SC-6: exit code 1 unchanged

set -euo pipefail
OVERALL_RESULT=0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
LOCAL_ISSUES="$PROJECT_DIR/.opencode/tools/local-issues"

echo "=== RED-phase: local-issues mutation error handling ==="
echo ""

# SC-1: bare number on update → error + "Available qualifiers"
echo "--- SC-1: update bare number ---"
output=$($LOCAL_ISSUES update --number 1 --status closed 2>&1 || true)
if echo "$output" | grep -q "Available qualifiers"; then
    echo "PASS (SC-1): update bare number shows qualifier listing"
else
    echo "FAIL (SC-1): update bare number missing qualifier listing"
    OVERALL_RESULT=1
fi
if echo "$output" | grep -q "Use qualified form"; then
    echo "PASS (SC-1): update bare number shows qualifier error"
else
    echo "FAIL (SC-1): update bare number missing qualifier error"
    OVERALL_RESULT=1
fi

# SC-2: non-existent repo → error + "Available qualifiers"
echo "--- SC-2: update bad qualifier ---"
output=$($LOCAL_ISSUES update --number nonexistent#1 --status closed 2>&1 || true)
if echo "$output" | grep -q "Available qualifiers"; then
    echo "PASS (SC-2): update bad qualifier shows qualifier listing"
else
    echo "FAIL (SC-2): update bad qualifier missing qualifier listing"
    OVERALL_RESULT=1
fi
if echo "$output" | grep -q "not found"; then
    echo "PASS (SC-2): update bad qualifier shows not-found error"
else
    echo "FAIL (SC-2): update bad qualifier missing not-found error"
    OVERALL_RESULT=1
fi

# SC-6: exit code 1 (bare number)
echo "--- SC-6: exit code 1 (bare number) ---"
if $LOCAL_ISSUES update --number 1 --status closed >/dev/null 2>&1; then
    echo "FAIL (SC-6): bare number should exit 1"
    OVERALL_RESULT=1
else
    echo "PASS (SC-6): exit code 1"
fi

# SC-6: exit code 1 (bad qualifier)
echo "--- SC-6: exit code 1 (bad qualifier) ---"
if $LOCAL_ISSUES update --number nonexistent#1 --status closed >/dev/null 2>&1; then
    echo "FAIL (SC-6): bad qualifier should exit 1"
    OVERALL_RESULT=1
else
    echo "PASS (SC-6): exit code 1"
fi

echo ""
echo "=== RESULT ==="
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "GREEN PASS — _print_available_repos is implemented"
else
    echo "RED FAIL — _print_available_repos not yet implemented ($OVERALL_RESULT failures)"
fi

exit $OVERALL_RESULT
