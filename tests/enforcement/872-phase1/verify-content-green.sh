#!/bin/bash
# Content-Verification Test: #872 Phase 1 GREEN State Verification
#
# Verifies all Phase 1 GREEN items are implemented.
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

OVERALL_RESULT=0

echo "=== #872 Phase 1 GREEN State Content-Verification ==="
echo ""

check_file() {
    local label="$1"
    local path="$2"
    if [ -f "$PROJECT_DIR/.opencode/$path" ]; then
        echo "PASS: $label — exists"
        return 0
    else
        echo "FAIL: $label — MISSING at .opencode/$path"
        return 1
    fi
}

check_absent() {
    local label="$1"
    local path="$2"
    if [ -f "$PROJECT_DIR/.opencode/$path" ]; then
        echo "FAIL: $label — STILL EXISTS at .opencode/$path (should be removed)"
        return 1
    else
        echo "PASS: $label — removed"
        return 0
    fi
}

# SC-1: rules dispatcher exists
check_file "SC-1: rules dispatcher" "tools/rules" || OVERALL_RESULT=1

# SC-2b: symbolic dispatcher removed
check_absent "SC-2b: symbolic dispatcher removed" "tools/symbolic" || OVERALL_RESULT=1

# SC-3: solve tool exists
check_file "SC-3: solve tool" "tools/solve" || OVERALL_RESULT=1

# SC-9: guideline exists
check_file "SC-9: guideline 092" "guidelines/092-spec-reasoning-tools.md" || OVERALL_RESULT=1

# SC-10: INDEX.md entry
echo "--- SC-10: INDEX.md 092 entry ---"
if grep -q "092-" "$PROJECT_DIR/.opencode/guidelines/INDEX.md" 2>/dev/null; then
    echo "PASS: SC-10 — INDEX.md has 092- entry"
else
    echo "FAIL: SC-10 — INDEX.md missing 092- entry"
    OVERALL_RESULT=1
fi

# Rules-* impl scripts exist (check subset)
echo "--- rules-* impl scripts ---"
RULES_COUNT=0
for script in "$PROJECT_DIR/.opencode/tools/impl/rules-"*; do
    if [ -f "$script" ]; then
        RULES_COUNT=$((RULES_COUNT + 1))
    fi
done
if [ "$RULES_COUNT" -ge 15 ]; then
    echo "PASS: $RULES_COUNT rules-* scripts exist"
else
    echo "FAIL: Only $RULES_COUNT rules-* scripts (expected 15+)"
    OVERALL_RESULT=1
fi

# Skildeck ANALYSIS dict uses rules-*
echo "--- skildeck ANALYSIS dict ---"
SKILDECK_FILE="$PROJECT_DIR/.opencode/tools/skildeck"
if grep -q '"rules-' "$SKILDECK_FILE" 2>/dev/null; then
    echo "PASS: skildeck ANALYSIS dict references rules-* scripts"
else
    echo "FAIL: skildeck ANALYSIS dict does NOT reference rules-*"
    OVERALL_RESULT=1
fi

# No sym-extract in skildeck impl
echo "--- no sym-extract in skildeck impl ---"
if grep -r 'sym-extract' "$PROJECT_DIR/.opencode/tools/impl/skildeck/" 2>/dev/null | grep -q .; then
    echo "FAIL: skildeck impl scripts still reference sym-extract"
    OVERALL_RESULT=1
else
    echo "PASS: no sym-extract references in skildeck impl"
fi

# No symbolic in README tools table
echo "--- README symbolic reference ---"
README_FILE="$PROJECT_DIR/.opencode/README.md"
if grep -q "symbolic" "$README_FILE" 2>/dev/null; then
    echo "FAIL: README still references 'symbolic'"
    OVERALL_RESULT=1
else
    echo "PASS: README has no 'symbolic' reference"
fi

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "ALL PASS: #872 Phase 1 GREEN implementation verified"
else
    echo "FAILURES DETECTED: $OVERALL_RESULT checks failed"
fi
exit $OVERALL_RESULT
