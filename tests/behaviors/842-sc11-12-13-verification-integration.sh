#!/bin/bash
# SC-11: enforcement-gate.md must reference VbC/audit YAML artifacts and evidence chain.
# SC-12: create-pr.md must NOT contain "dispatch log" references.
# SC-13: review-prep.md must reference verification-gate as prerequisite.
#
# RED test: Current files don't have these references. The tests MUST fail.
#
# Behavioral TDD cycle:
#   RED:   This test — structural checks fail on current files
#   GREEN: Add verification-gate references to the three files
#   REFACTOR: Verify no accidental removals of existing content
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="842-sc11-12-13-verification-integration"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

# This is primarily a structural test — the behavioral component is that the
# agent would correctly route through verification-gate before review-prep.
# For RED phase, we verify the files don't have the required content yet.

OVERALL_RESULT=0

# Helper: grep count that returns 0 instead of failing on no matches
grep_count() {
    local pattern="$1"
    local file="$2"
    local count
    count=$(grep -cE "$pattern" "$file" 2>/dev/null) && echo "$count" || echo "0"
}

# SC-11: enforcement-gate.md must reference YAML artifacts and evidence chain
ENFORCEMENT_GATE="$SCRIPT_DIR/../../skills/git-workflow/tasks/pr-creation/enforcement-gate.md"
if [ -f "$ENFORCEMENT_GATE" ]; then
    ARTIFACT_REFS=$(grep_count "verification-.*\.yaml|audit-cross-validate-.*\.yaml|behavioral-evidence|evidence.chain|evidence_chain_integrity" "$ENFORCEMENT_GATE")
    if [ "$ARTIFACT_REFS" -eq 0 ]; then
        echo "FAIL: enforcement-gate.md has 0 YAML artifact/evidence chain references (SC-11)"
        OVERALL_RESULT=1
    else
        echo "STRUCTURAL PASS: enforcement-gate.md has $ARTIFACT_REFS YAML artifact/evidence chain references"
    fi
else
    echo "FAIL: enforcement-gate.md not found at $ENFORCEMENT_GATE"
    OVERALL_RESULT=1
fi

# SC-12: create-pr.md must NOT contain "dispatch log" references
CREATE_PR="$SCRIPT_DIR/../../skills/git-workflow/tasks/pr-creation/create-pr.md"
if [ -f "$CREATE_PR" ]; then
    DISPATCH_LOG_COUNT=$(grep_count "dispatch.log|dispatch log" "$CREATE_PR")
    if [ "$DISPATCH_LOG_COUNT" -ne 0 ]; then
        echo "FAIL: create-pr.md contains $DISPATCH_LOG_COUNT 'dispatch log' references (expected 0 for SC-12)"
        OVERALL_RESULT=1
    else
        echo "STRUCTURAL PASS: create-pr.md has 0 'dispatch log' references"
    fi
else
    echo "FAIL: create-pr.md not found at $CREATE_PR"
    OVERALL_RESULT=1
fi

# SC-13: review-prep.md must reference verification-gate as prerequisite
REVIEW_PREP="$SCRIPT_DIR/../../skills/git-workflow/tasks/review-prep.md"
if [ -f "$REVIEW_PREP" ]; then
    VG_REFS=$(grep_count "verification-gate|verification_gate" "$REVIEW_PREP")
    if [ "$VG_REFS" -eq 0 ]; then
        echo "FAIL: review-prep.md has 0 verification-gate references (SC-13 requires at least 1)"
        OVERALL_RESULT=1
    else
        echo "STRUCTURAL PASS: review-prep.md has $VG_REFS verification-gate references"
    fi
else
    echo "FAIL: review-prep.md not found at $REVIEW_PREP"
    OVERALL_RESULT=1
fi

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME (expected — this is RED phase)"
fi

exit $OVERALL_RESULT