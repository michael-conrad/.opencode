#!/bin/bash
# SC-20: Behavioral test traceability — every structural SC has a corresponding test
#
# Meta-verification test for spec #578 Revision B.
# Verifies that each SC (SC-1 through SC-19) has at least one behavioral/content
# test file with a # SC-N: comment prefix identifying which SC it verifies.
#
# This test ALWAYS passes once the test suite is complete — it verifies
# traceability, not code behavior. It is the meta-SC.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="578-sc20-behavioral-test-traceability"

PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

echo "=== Content-Verification Test: $SCENARIO_NAME ==="

OVERALL_RESULT=0

# Map each SC to its expected test file(s)
declare -A SC_FILES=(
    ["1"]="578-sc1-cross-validate-no-auditor-dispatch.sh"
    ["2"]="578-sc2-cross-validate-verdicts-entry.sh"
    ["3"]="578-sc3-per-audit-type-reference-tables.sh"
    ["4"]="578-sc4-sc13-plan-fidelity-sub-agent-dispatch.sh"
    ["5"]="578-sc5-sc12-resolve-models-single-entry.sh"
    ["6"]="578-sc6-auditor-descriptions-programmatic.sh"
    ["7"]="578-sc7-8-cross-validate-result-contract.sh"
    ["8"]="578-sc7-8-cross-validate-result-contract.sh"
    ["9"]="578-sc9-10-completion-dependency-continuity.sh"
    ["10"]="578-sc9-10-completion-dependency-continuity.sh"
    ["11"]="578-sc11-cross-validate-step6-stacking.sh"
    ["12"]="578-sc5-sc12-resolve-models-single-entry.sh"
    ["13"]="578-sc4-sc13-plan-fidelity-sub-agent-dispatch.sh"
    ["14"]="578-sc14-15-symbolic-rules-and-non-recovery-gates.sh"
    ["15"]="578-sc14-15-symbolic-rules-and-non-recovery-gates.sh"
    ["16"]="578-sc16-17-18-skill-md-structure.sh"
    ["17"]="578-sc16-17-18-skill-md-structure.sh"
    ["18"]="578-sc16-17-18-skill-md-structure.sh"
    ["19"]="578-sc19-completion-dispatch-model.sh"
    ["21"]="578-sc21-skill-card-frontmatter.sh"
)

BEHAVIOR_DIR="$SCRIPT_DIR"

for SC_NUM in $(echo "${!SC_FILES[@]}" | tr ' ' '\n' | sort -n); do
    EXPECTED_FILE="${SC_FILES[$SC_NUM]}"
    FILEPATH="$BEHAVIOR_DIR/$EXPECTED_FILE"

    if [ -f "$FILEPATH" ]; then
        # Check for # SC-N: traceability comment
        if grep -qE "# SC-${SC_NUM}[ :]" "$FILEPATH"; then
            echo "PASS: SC-20 — SC-${SC_NUM} has traceability comment in $EXPECTED_FILE"
        else
            echo "FAIL: SC-20 — SC-${SC_NUM} missing traceability comment in $EXPECTED_FILE"
            OVERALL_RESULT=1
        fi
    else
        echo "FAIL: SC-20 — Test file $EXPECTED_FILE for SC-${SC_NUM} not found"
        OVERALL_RESULT=1
    fi
done

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT