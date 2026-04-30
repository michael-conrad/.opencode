#!/bin/bash
# Behavioral Enforcement Test: vbc-evidence-artifacts-dispatch-mapped
# Verifies that verification-before-completion SKILL.md has dispatch-chain-mapped
# evidence_artifacts — each artifact maps to a specific pipeline stage
# (verify, collect, structural-verify, or completion), not just generic entries.
#
# Issue #43: Formalize verification-before-completion Skill Card to v2.0
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="vbc-evidence-artifacts-dispatch-mapped"
SCENARIO_PROMPT="Verify the implementation of github issue #1 is complete. Use verification-before-completion."

OPENDIR="$SCRIPT_DIR"
while [ "$(basename "$OPENDIR")" != ".opencode" ]; do
    OPENDIR="$(dirname "$OPENDIR")"
done
SKILL_FILE="$OPENDIR/skills/verification-before-completion/SKILL.md"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

assert_skill_invoked "verification-before-completion" || OVERALL_RESULT=1

# Content-verification: evidence_artifacts section exists and contains dispatch_stage
if ! grep -q "evidence_artifacts:" "$SKILL_FILE"; then
    echo "FAIL: content-check — evidence_artifacts section not found in SKILL.md"
    OVERALL_RESULT=1
else
    echo "PASS: content-check — evidence_artifacts section found in SKILL.md"
fi

# Verify each evidence_artifact entry has a dispatch_stage field
ARTIFACT_NAMES=$(grep -A3 '^\s*- name:' "$SKILL_FILE" | grep '^\s*- name:' | sed 's/.*name: *//' | tr -d ' ')
EXPECTED_STAGES="verify collect structural-verify completion"
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

if [ "$STAGE_FOUND_COUNT" -lt 3 ]; then
    echo "FAIL: content-check — expected at least 3 dispatch_stage values, found $STAGE_FOUND_COUNT"
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