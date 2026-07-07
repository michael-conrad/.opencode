#!/bin/bash
# SC-4/SC-13: plan-fidelity.md Step 1 requires sub-agent dispatch (NOT orchestrator inline)
# SC-13: Step 1 uses authority-rejection + sycophancy framing
#
# Content-verification test for spec #578 Defect 3.
# SC-4: Step 1 language must require sub-agent dispatch, not orchestrator inline work.
# SC-13: Step 1 must state "TAINTED by definition" and reference critical-rules-034.
#
# RED: Expect FAIL against dev baseline (Step 1 says "orchestrator generated").
# GREEN: Expect PASS after implementation.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="578-sc4-sc13-plan-fidelity-sub-agent-dispatch"

PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

PF_FILE="$PROJECT_DIR/.opencode/skills/audit/tasks/plan-fidelity.md"

echo "=== Content-Verification Test: $SCENARIO_NAME ==="

OVERALL_RESULT=0

if [ ! -f "$PF_FILE" ]; then
    echo "FAIL: $SCENARIO_NAME — plan-fidelity.md not found at $PF_FILE"
    OVERALL_RESULT=1
else
    # SC-4/SC-13 Assertion 1: "TAINTED" appears (sycophancy-rejection language)
    if grep -q "TAINTED" "$PF_FILE"; then
        echo "PASS: SC-4/SC-13 — plan-fidelity.md contains sycophancy-rejection language 'TAINTED'"
    else
        echo "FAIL: SC-4/SC-13 — plan-fidelity.md missing 'TAINTED' in Step 1"
        OVERALL_RESULT=1
    fi

    # SC-4 Assertion 2: MISSING_CLEAN_ROOM_PLAN non-recovery gate present
    if grep -q "MISSING_CLEAN_ROOM_PLAN" "$PF_FILE"; then
        echo "PASS: SC-4 — plan-fidelity.md contains MISSING_CLEAN_ROOM_PLAN non-recovery gate"
    else
        echo "FAIL: SC-4 — plan-fidelity.md missing MISSING_CLEAN_ROOM_PLAN"
        OVERALL_RESULT=1
    fi

    # SC-4 Assertion 3: No PERMISSIVE "orchestrator generated" language in Step 1
    # The rejection context "Any orchestrator-generated plan is TAINTED" is CORRECT.
    # Only permissive uses ("the orchestrator generated the plan") should fail.
    STEP1_SECTION=$(sed -n '/### Step 1/,/### Step 2/p' "$PF_FILE" 2>/dev/null || true)
    PERMISSIVE_MATCH=$(echo "$STEP1_SECTION" | grep -i 'orchestrator.*generat' | grep -iv 'tainted\|NOT.*orchestrator\|conflict of interest\|prohibited\|forbidden\|violation' || true)
    if [ -n "$PERMISSIVE_MATCH" ]; then
        echo "FAIL: SC-4 — plan-fidelity.md Step 1 has permissive 'orchestrator generated' language: $PERMISSIVE_MATCH"
        OVERALL_RESULT=1
    else
        echo "PASS: SC-4 — plan-fidelity.md Step 1 does not contain permissive 'orchestrator generated' language"
    fi

    # SC-13 Assertion 1: "CRITICAL VIOLATION per critical-rules-034" reference
    if grep -q "critical-rules-034" "$PF_FILE"; then
        echo "PASS: SC-13 — plan-fidelity.md references critical-rules-034"
    else
        echo "FAIL: SC-13 — plan-fidelity.md missing reference to critical-rules-034"
        OVERALL_RESULT=1
    fi

    # SC-13 Assertion 2: "TAINTED by definition" authority-rejection framing
    if grep -q "TAINTED.*by.*definition\|by definition.*TAINTED\|TAINTED by definition" "$PF_FILE"; then
        echo "PASS: SC-13 — plan-fidelity.md contains 'TAINTED by definition' authority-rejection framing"
    else
        echo "FAIL: SC-13 — plan-fidelity.md missing 'TAINTED by definition' framing"
        OVERALL_RESULT=1
    fi
fi

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT