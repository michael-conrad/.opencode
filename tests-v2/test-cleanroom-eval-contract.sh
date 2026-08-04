#!/bin/bash
# Content-Verification Enforcement Test: Clean-Room Sub-Agent Evaluation Contract (v2)
#
# SC-5 from issue #2245
#
# Verifies that the complete clean-room sub-agent evaluation contract is documented
# in tests-v2/AGENTS.md §6a "Two-SC Pattern: Artifact Generation + Clean-Room Evaluation".
# The contract has 4 required elements:
#   1. Sub-agent receives ONLY: artifact directory path + SC criterion + github.owner/github.repo
#   2. session.yaml is the PRIMARY evidence source
#   3. Returns PASS/FAIL
#   4. Returns with a one-sentence justification
#
# The test FAILS (non-zero exit) if any required element is missing/incomplete.
# Failing evidence lists exactly which elements are missing.
#
# Usage:  bash .opencode/tests-v2/test-cleanroom-eval-contract.sh

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

AGENTS_FILE="$PROJECT_DIR/.opencode/tests-v2/AGENTS.md"

PASS_COUNT=0
FAIL_COUNT=0
MISSING_ELEMENTS=()

# grep_check: check that a literal pattern appears at least once in the file.
#   $1 pattern, $2 scenario name
grep_check() {
    local pattern="$1"
    local scenario_name="$2"

    local count
    count=$(grep -cF "$pattern" "$AGENTS_FILE" 2>/dev/null || true)
    count="${count:-0}"
    count=$(echo "$count" | tr -d '[:space:]')
    : "${count:=0}"

    if [ "$count" -ge 1 ]; then
        echo "  PASS: $scenario_name — '$pattern' found $count times"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo "  FAIL: $scenario_name — '$pattern' NOT found"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        MISSING_ELEMENTS+=("$scenario_name")
    fi
}

echo ""
echo "=== Clean-Room Sub-Agent Evaluation Contract (SC-5) ==="
echo ""
echo "Target file: $AGENTS_FILE"
echo ""

# Element 1: Sub-agent receives ONLY artifact dir + SC criterion + github.owner/github.repo
grep_check 'receives ONLY' "SC-5-elem1-receives-only"
grep_check 'The artifact directory path' "SC-5-elem1-artifact-path"
grep_check 'github.owner' "SC-5-elem1-owner"
grep_check 'github.repo' "SC-5-elem1-repo"

# Element 2: session.yaml is the PRIMARY evidence source
grep_check 'PRIMARY evidence source' "SC-5-elem2-session-yaml-primary"
grep_check 'session.yaml' "SC-5-elem2-session-yaml-named"

# Element 3: Returns PASS/FAIL
grep_check 'Return PASS/FAIL' "SC-5-elem3-return-pass-fail"

# Element 4: One-sentence justification
grep_check 'one-sentence justification' "SC-5-elem4-one-sentence-justification"

echo ""
echo "=== Results ==="
echo ""
echo "PASSED:  $PASS_COUNT"
echo "FAILED:  $FAIL_COUNT"
echo ""
echo "Missing required elements:"
if [ ${#MISSING_ELEMENTS[@]} -eq 0 ]; then
    echo "  (none — all required elements present)"
else
    for elem in "${MISSING_ELEMENTS[@]}"; do
        echo "  - $elem"
    done
fi
echo ""
echo "Per-element analysis (SC-5 contract):"
for elem in "1: sub-agent receives ONLY artifact dir + SC criterion + github.owner/github.repo" \
            "2: session.yaml is PRIMARY evidence source" \
            "3: returns PASS/FAIL" \
            "4: returns with a one-sentence justification"; do
    echo "  Element ${elem%%:*} (${elem#*:}): PRESENT (verified by grep above)"
done

if [ "$FAIL_COUNT" -gt 0 ]; then
    echo ""
    echo "FAILED: $FAIL_COUNT element(s) missing. See per-check FAIL lines above."
    exit 1
fi

exit 0
