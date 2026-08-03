#!/bin/bash
# Skill deck completeness content-verification test.
# Maps to SC-2 from issue #2229: skildeck lint produces skill-deck-completeness findings.
#
# Usage: bash .opencode/tests-v2/test-skilledeck-completeness.sh
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
echo "=== Skill Deck Completeness -- SC-2 (#2229) ==="
echo ""

SKILDECK="$PROJECT_DIR/.opencode/tools/skildeck"

# SC-2: skildeck lint --json produces skill-deck-completeness findings
JSON_OUTPUT=$("$SKILDECK" lint --json 2>/dev/null || true)

if [ -z "$JSON_OUTPUT" ]; then
    check_fail "SC-2: skildeck lint --json" "output is empty"
elif ! echo "$JSON_OUTPUT" | python3 -c "import sys,json; data=json.load(sys.stdin); assert isinstance(data, list) and len(data) > 0, 'expected non-empty list'" 2>/dev/null; then
    check_fail "SC-2: skildeck lint --json" "output is not a non-empty JSON array"
else
    check_pass "SC-2: skildeck lint --json produces non-empty findings"
fi

# Verify at least one finding is in the skill-deck-completeness category
COMPLETENESS_COUNT=$(echo "$JSON_OUTPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
count = sum(1 for f in data if f.get('category') == 'skill-deck-completeness')
print(count)
" 2>/dev/null || echo "0")

if [ "$COMPLETENESS_COUNT" -gt 0 ]; then
    check_pass "SC-2: findings include skill-deck-completeness category ($COMPLETENESS_COUNT findings)"
else
    check_fail "SC-2: findings include skill-deck-completeness category" "no findings in skill-deck-completeness category"
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
