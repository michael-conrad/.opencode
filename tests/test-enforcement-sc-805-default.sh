#!/usr/bin/env bash
# GREEN tests for .opencode#805 SC-1 through SC-4
# Expected: ALL PASS (content exists in default.txt)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../.opencode" && pwd)"
DEFAULT_TXT="$ROOT/prompts/default.txt"
OVERALL_RESULT=0

# Use the helpers from .opencode/tests/behaviors/helpers.sh if available
HERE="$(cd "$(dirname "$0")" && pwd)"
if [ -f "$HERE/behaviors/helpers.sh" ]; then
    source "$HERE/behaviors/helpers.sh"
fi

# SC-1: 9 forbidden rationalization patterns must all be present
sc_1_test() {
    echo "=== SC-1: Forbidden rationalizations section ==="
    local count=0
    local missing=0
    
    while IFS= read -r phrase; do
        if grep -qF "$phrase" "$DEFAULT_TXT"; then
            count=$((count + 1))
        else
            echo "  MISSING: $phrase"
            missing=$((missing + 1))
        fi
    done << 'PHRASES'
This is too small for a skill
I can just quickly implement this
I'll gather context first
A grep check is good enough for this SC
This behavioral test doesn't need to run against a real model
Running the sub-agent costs too many tokens, I can do this inline
The user said continue so the gates don't apply
This is just a documentation change, it doesn't need verification
I've already verified this earlier, no need to re-verify
PHRASES
    
    if [ "$missing" -eq 0 ]; then
        echo "  PASS: All $count forbidden rationalizations found"
    else
        echo "  FAIL: $missing forbidden rationalizations missing"
        OVERALL_RESULT=1
    fi
}

# SC-2: Evidence hierarchy table must order behavioral > semantic > string > structural
sc_2_test() {
    echo "=== SC-2: Evidence hierarchy ordering ==="
    local ok=0
    
    # Check that behavioral is listed as HIGHEST priority (table row 1)
    if grep -qE "1.*HIGHEST.*behavioral" "$DEFAULT_TXT"; then
        echo "  PASS: behavioral = highest priority"
        ok=$((ok + 1))
    else
        echo "  FAIL: behavioral not listed as highest priority"
    fi
    
    # Check that semantic is listed as priority 2
    if grep -qE "2.*semantic" "$DEFAULT_TXT"; then
        echo "  PASS: semantic = priority 2"
        ok=$((ok + 1))
    else
        echo "  FAIL: semantic not listed as priority 2"
    fi
    
    # Check that string is listed as priority 3
    if grep -qE "3.*string" "$DEFAULT_TXT"; then
        echo "  PASS: string = priority 3"
        ok=$((ok + 1))
    else
        echo "  FAIL: string not listed as priority 3"
    fi
    
    # Check that structural is listed as LOWEST priority (table row 4)
    if grep -qE "4.*LOWEST.*structural" "$DEFAULT_TXT"; then
        echo "  PASS: structural = lowest priority"
        ok=$((ok + 1))
    else
        echo "  FAIL: structural not listed as lowest priority"
    fi
    
    # Check for the bright-line rule statement (behavioral MUST use behavioral evidence)
    if grep -qE "behavioral.*MUST.*behavioral" "$DEFAULT_TXT"; then
        echo "  PASS: Bright-line evidence rule found"
        ok=$((ok + 1))
    else
        echo "  Note: Bright-line evidence rule not found (informational)"
    fi
    
    if [ "$ok" -ge 4 ]; then
        echo "  PASS: Evidence hierarchy table found with correct priority ordering"
    else
        echo "  FAIL: Evidence hierarchy not complete ($ok/4 minimum)"
        OVERALL_RESULT=1
    fi
}

# SC-3: Cost model override — rework cost and correct-path statements must exist
sc_3_test() {
    echo "=== SC-3: Cost model override ==="
    local found=0
    if grep -qE "rework cost" "$DEFAULT_TXT"; then
        echo "  FOUND: rework cost"
        found=$((found + 1))
    fi
    if grep -qE "execution cost|cost.*model|defect-discovery-latency" "$DEFAULT_TXT"; then
        echo "  FOUND: cost metric reference"
        found=$((found + 1))
    fi
    if grep -qE "expensive one.*works the first time|correct path.*expensive" "$DEFAULT_TXT"; then
        echo "  FOUND: expensive-first statement"
        found=$((found + 1))
    fi
    if [ "$found" -ge 2 ]; then
        echo "  PASS: Cost model override found"
    else
        echo "  FAIL: Cost model override not found ($found/2 minimum)"
        OVERALL_RESULT=1
    fi
}

# SC-4: Rework cost recognition — cheap-creates-endless-work pattern
sc_4_test() {
    echo "=== SC-4: Rework cost recognition ==="
    if grep -qE "trying to be cheap|cheap creates|endless repeated work" "$DEFAULT_TXT"; then
        echo "  PASS: Rework cost recognition found"
    else
        echo "  FAIL: Rework cost recognition not found"
        OVERALL_RESULT=1
    fi
}

# Run all tests
echo "=========================================="
echo "  GREEN Tests for default.txt (SC-1 through SC-4)"
echo "  Expected: ALL PASS"
echo "=========================================="
echo ""
sc_1_test
sc_2_test
sc_3_test
sc_4_test
echo ""
echo "=========================================="
if [ "$OVERALL_RESULT" -ne 0 ]; then
    echo "  OVERALL: FAIL"
else
    echo "  OVERALL: PASS"
fi
echo "=========================================="
exit "$OVERALL_RESULT"
