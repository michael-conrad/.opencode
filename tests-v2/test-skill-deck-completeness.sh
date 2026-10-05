#!/bin/bash
# Skill deck completeness content-verification test.
# Verifies the deck-completeness mechanism end to end:
#   1. The live deck lints with ZERO skill-deck-completeness findings
#      (a healthy deck — the old version of this test asserted the opposite,
#      passing only when the deck was broken; retired per .opencode#2490 SC-4
#      and the §6b ceremony-test retirement policy).
#   2. The mechanism is non-vacuous: a scratch skills/ tree containing a
#      directory without SKILL.md produces a MISSING_SKILL_MD finding.
#
# Usage: bash .opencode/tests-v2/test-skill-deck-completeness.sh
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
echo "=== Skill Deck Completeness — mechanism verification ==="
echo ""

SKILDECK="$PROJECT_DIR/.opencode/tools/skildeck"

# Check 1: live deck lints to parseable JSON
JSON_OUTPUT=$("$SKILDECK" lint --json 2>/dev/null || true)
if [ -z "$JSON_OUTPUT" ]; then
    check_fail "live deck lint --json" "output is empty"
elif ! echo "$JSON_OUTPUT" | python3 -c "import sys,json; data=json.load(sys.stdin); assert isinstance(data, list)" 2>/dev/null; then
    check_fail "live deck lint --json" "output is not a JSON array"
else
    check_pass "live deck lint --json produces parseable JSON"
fi

# Check 2: zero skill-deck-completeness findings on the live deck
COMPLETENESS_COUNT=$(echo "$JSON_OUTPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(sum(1 for f in data if f.get('category') == 'skill-deck-completeness'))
" 2>/dev/null || echo "-1")
if [ "$COMPLETENESS_COUNT" = "0" ]; then
    check_pass "live deck has zero skill-deck-completeness findings"
else
    check_fail "live deck completeness" "expected 0 findings, got $COMPLETENESS_COUNT"
fi

# Check 3: mechanism is non-vacuous — scratch skill dir without SKILL.md is flagged
SCRATCH="$(mktemp -d "${TMPDIR:-/tmp}/skilldeck-probe.XXXXXX")"
trap 'rm -rf "$SCRATCH"' EXIT
mkdir -p "$SCRATCH/skills/zz-mechanism-probe"
PROBE_OUTPUT=$("$SKILDECK" lint --json --dir "$SCRATCH/skills" 2>/dev/null || true)
MISSING_COUNT=$(echo "$PROBE_OUTPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(sum(1 for f in data if f.get('rule_id') == 'MISSING_SKILL_MD'))
" 2>/dev/null || echo "0")
if [ "$MISSING_COUNT" -ge 1 ]; then
    check_pass "mechanism flags MISSING_SKILL_MD on scratch probe ($MISSING_COUNT)"
else
    check_fail "mechanism non-vacuousness" "MISSING_SKILL_MD not produced for scratch skill dir without SKILL.md"
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
