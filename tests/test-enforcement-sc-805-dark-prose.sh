#!/usr/bin/env bash
# GREEN tests for .opencode#805 SC-5 through SC-12
# Expected: ALL PASS (bright-line section exists in 250-dark-prose-reference.md)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../.opencode" && pwd)"
DP_REF="$ROOT/guidelines/250-dark-prose-reference.md"
OVERALL_RESULT=0

# SC-5: Bright-Line Mandates section must exist in 250-dark-prose-reference.md
sc_5_test() {
    echo "=== SC-5: Bright-Line section exists ==="
    if grep -qi "bright.ine\|Bright-Line" "$DP_REF"; then
        echo "  PASS: Bright-Line section found"
    else
        echo "  FAIL: Bright-Line section not found"
        OVERALL_RESULT=1
    fi
}

# SC-6: Each bright-line rule must have absolute-rule / exception-carve-out / failure-definition
sc_6_test() {
    echo "=== SC-6: Three-part structure ==="
    local parts=("absolute rule" "exception carve-out" "failure definition")
    local found=0
    for part in "${parts[@]}"; do
        if grep -qF "$part" "$DP_REF"; then
            found=$((found + 1))
            echo "  FOUND: $part"
        else
            echo "  MISSING: $part"
        fi
    done
    if [ "$found" -eq 3 ]; then
        echo "  PASS: All three parts found"
    else
        echo "  FAIL: Only $found/3 parts found"
        OVERALL_RESULT=1
    fi
}

# SC-7: 4 dark-prose rules must pair with bright-line companions (001, 002, 003, 006)
sc_7_test() {
    echo "=== SC-7: Pattern pairings ==="
    local patterns=("001" "002" "003" "006")
    local found=0
    for pat in "${patterns[@]}"; do
        if grep -qE "$pat.*companion|companion.*$pat" "$DP_REF"; then
            found=$((found + 1))
            echo "  FOUND: Pattern $pat paired"
        else
            echo "  MISSING: Pattern $pat pairing"
        fi
    done
    if [ "$found" -eq 4 ]; then
        echo "  PASS: All 4 patterns paired"
    else
        echo "  FAIL: Only $found/4 patterns paired"
        OVERALL_RESULT=1
    fi
}

# SC-8: 001 (confirmshaming) must have non-waivable/hard-gate companion
sc_8_test() {
    echo "=== SC-8: 001 confirmshaming bright-line companion ==="
    if grep -qE "001.*non.waivable|non.waivable.*001|001.*hard.gate|hard.gate.*001" "$DP_REF"; then
        echo "  PASS: Companion with non-waivable/hard gate found"
    else
        echo "  FAIL: 001 bright-line companion not found"
        OVERALL_RESULT=1
    fi
}

# SC-9: 002 (identity-frame) must have IS/is-not/Period binary compliance language
sc_9_test() {
    echo "=== SC-9: 002 identity-frame binary compliance ==="
    if grep -qE "002.*IS|IS.*002|002.*is not|is not.*002|002.*Period|Period.*002" "$DP_REF"; then
        echo "  PASS: Binary compliance language found"
    else
        echo "  FAIL: 002 binary compliance not found"
        OVERALL_RESULT=1
    fi
}

# SC-10: 003 (goal-hijacking) must have REJECTED/rejection/termination language
sc_10_test() {
    echo "=== SC-10: 003 consequence-assertion rejection/termination ==="
    if grep -qE "003.*REJECTED|REJECTED.*003|003.*reject|reject.*003|003.*must be remediated|003.*termination|termination.*003" "$DP_REF"; then
        echo "  PASS: Rejection/termination language found"
    else
        echo "  FAIL: 003 rejection language not found"
        OVERALL_RESULT=1
    fi
}

# SC-11: 006 (agency-respecting) must have trust-but-verify/evidence-required companion
sc_11_test() {
    echo "=== SC-11: 006 agency-respecting trust-but-verify ==="
    if grep -qE "006.*trust.*verify|trust.*verify.*006|006.*evidence.*required|evidence.*required.*006" "$DP_REF"; then
        echo "  PASS: Trust-but-verify companion found"
    else
        echo "  FAIL: 006 trust-but-verify not found"
        OVERALL_RESULT=1
    fi
}

# SC-12: Bright-line section must be complementary (not replacement) to existing dark prose rules
sc_12_test() {
    echo "=== SC-12: Complementary (not replacement) ==="
    if grep -qi "companion.*not.*replace\|not.*replacement\|reinforce.*not.*replace\|complementary\|additive\|alongside" "$DP_REF"; then
        echo "  PASS: Non-replacement language found"
    else
        echo "  FAIL: Complementary language not found"
        OVERALL_RESULT=1
    fi
}

# Run all tests
echo "==========================================="
echo "  GREEN Tests for 250-dark-prose-reference.md"
echo "  (SC-5 through SC-12)"
echo "  Expected: ALL PASS"
echo "==========================================="
echo ""
sc_5_test
sc_6_test
sc_7_test
sc_8_test
sc_9_test
sc_10_test
sc_11_test
sc_12_test
echo ""
echo "==========================================="
if [ "$OVERALL_RESULT" -ne 0 ]; then
    echo "  OVERALL: FAIL"
else
    echo "  OVERALL: PASS"
fi
echo "==========================================="
exit "$OVERALL_RESULT"
