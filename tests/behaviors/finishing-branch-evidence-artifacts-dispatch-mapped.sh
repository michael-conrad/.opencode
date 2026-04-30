#!/bin/bash
# Behavioral Enforcement Test: finishing-branch-evidence-artifacts-dispatch-mapped
# Verifies that finishing-a-development-branch SKILL.md has dispatch-chain-mapped
# evidence_artifacts — each artifact maps to a specific pipeline stage
# (prepare, checklist, or completion), not just generic entries.
#
# Issue #45: Formalize finishing-a-development-branch Skill Card to v2.0
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="finishing-branch-evidence-artifacts-dispatch-mapped"
SCENARIO_PROMPT="Implementation is complete on this branch. Run the finishing-a-development-branch checklist."

SKILL_FILE="$PROJECT_DIR/.opencode/skills/finishing-a-development-branch/SKILL.md"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

assert_skill_invoked "finishing-a-development-branch" || OVERALL_RESULT=1

# Content-verification: evidence_artifacts section exists and contains dispatch_stage
if ! grep -q "evidence_artifacts:" "$SKILL_FILE"; then
    echo "FAIL: content-check — evidence_artifacts section not found in SKILL.md"
    OVERALL_RESULT=1
else
    echo "PASS: content-check — evidence_artifacts section found in SKILL.md"
fi

# Verify each expected dispatch_stage value is present
EXPECTED_STAGES="prepare checklist completion"
STAGE_FOUND_COUNT=0

for stage in $EXPECTED_STAGES; do
    if grep -q "dispatch_stage:.*$stage" "$SKILL_FILE"; then
        STAGE_FOUND_COUNT=$((STAGE_FOUND_COUNT + 1))
        echo "PASS: content-check — dispatch_stage '$stage' found in evidence_artifacts"
    else
        echo "FAIL: content-check — dispatch_stage '$stage' NOT found in evidence_artifacts"
        OVERALL_RESULT=1
    fi
done

if [ "$STAGE_FOUND_COUNT" -lt 2 ]; then
    echo "FAIL: content-check — expected at least 2 dispatch_stage values, found $STAGE_FOUND_COUNT"
    OVERALL_RESULT=1
fi

# Verify evidence_artifacts entries have dispatch_stage (not just name/type/verification)
ARTIFACT_ENTRIES=$(awk '/^evidence_artifacts:/,/^```/' "$SKILL_FILE")
ENTRIES_WITHOUT_STAGE=$(echo "$ARTIFACT_ENTRIES" | grep -c '- name:' || true)
ENTRIES_WITH_STAGE=$(echo "$ARTIFACT_ENTRIES" | grep -c 'dispatch_stage:' || true)

if [ "$ENTRIES_WITH_STAGE" -lt "$ENTRIES_WITHOUT_STAGE" ]; then
    echo "FAIL: content-check — not all evidence_artifacts have dispatch_stage ($ENTRIES_WITH_STAGE/$ENTRIES_WITHOUT_STAGE)"
    OVERALL_RESULT=1
else
    echo "PASS: content-check — all $ENTRIES_WITH_STAGE evidence_artifacts have dispatch_stage"
fi

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT