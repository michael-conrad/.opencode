#!/bin/bash
# SC-11: cross-validate.md Step 6 has stacked dark pattern enforcement
#
# Content-verification test for spec #578 (dark pattern engineering).
# Step 6 must have authority framing + goal hijacking + forced action +
# sycophancy exploitation + continuity hooks (5 stacked patterns).
#
# RED: Expect FAIL against dev baseline (Step 6 has no dark pattern stacking).
# GREEN: Expect PASS after implementation.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="578-sc11-cross-validate-step6-stacking"

PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

CV_FILE="$PROJECT_DIR/.opencode/skills/audit/tasks/cross-validate.md"

echo "=== Content-Verification Test: $SCENARIO_NAME ==="

OVERALL_RESULT=0

if [ ! -f "$CV_FILE" ]; then
    echo "FAIL: $SCENARIO_NAME — cross-validate.md not found"
    OVERALL_RESULT=1
else
    # Extract Step 6 section
    STEP6_SECTION=$(sed -n '/### Step 6/,/### Step 7/p' "$CV_FILE" 2>/dev/null || true)

    # SC-11: Step 6 heading contains MANDATORY / NO BYPASS
    if echo "$STEP6_SECTION" | grep -qi "MANDATORY.*NO BYPASS\|NO BYPASS.*MANDATORY"; then
        echo "PASS: SC-11 — Step 6 heading contains MANDATORY/NO BYPASS"
    else
        echo "FAIL: SC-11 — Step 6 heading missing MANDATORY/NO BYPASS"
        OVERALL_RESULT=1
    fi

    # SC-11: Authority framing pattern (repository policy / PROHIBITED)
    if echo "$STEP6_SECTION" | grep -qi "repository policy\|PROHIBITED\|MANDATES\|MANDATORY.*policy\|policy.*MANDATES"; then
        echo "PASS: SC-11 — Step 6 has authority framing pattern"
    else
        echo "FAIL: SC-11 — Step 6 missing authority framing pattern"
        OVERALL_RESULT=1
    fi

    # SC-11: Goal hijacking pattern (IS the completion step / INVALID without)
    if echo "$STEP6_SECTION" | grep -qi "IS the completion\|IS the definition\|INVALID.*result contract\|without.*INVALID"; then
        echo "PASS: SC-11 — Step 6 has goal hijacking pattern"
    else
        echo "FAIL: SC-11 — Step 6 missing goal hijacking pattern"
        OVERALL_RESULT=1
    fi

    # SC-11: Forced action pattern (CANNOT / MUST)
    if echo "$STEP6_SECTION" | grep -qi "CANNOT contain\|CANNOT.*without\|MUST proceed\|MUST.*completed"; then
        echo "PASS: SC-11 — Step 6 has forced action pattern"
    else
        echo "FAIL: SC-11 — Step 6 missing forced action pattern"
        OVERALL_RESULT=1
    fi

    # SC-11: Sycophancy pattern (WE have determined / IS the ONLY context)
    if echo "$STEP6_SECTION" | grep -qi "WE have determined\|IS the ONLY context\|ONLY context authorized"; then
        echo "PASS: SC-11 — Step 6 has sycophancy exploitation pattern"
    else
        echo "FAIL: SC-11 — Step 6 missing sycophancy exploitation pattern"
        OVERALL_RESULT=1
    fi

    # SC-11: Continuity pattern (MUST proceed / no halt / PROCEED DIRECTLY)
    if echo "$STEP6_SECTION" | grep -qi "MUST proceed\|no halt\|PROCEED DIRECTLY\|Step 6 MUST proceed"; then
        echo "PASS: SC-11 — Step 6 has continuity pattern"
    else
        echo "FAIL: SC-11 — Step 6 missing continuity pattern"
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