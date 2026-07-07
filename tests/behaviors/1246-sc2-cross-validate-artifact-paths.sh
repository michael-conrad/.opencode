#!/bin/bash
# Behavioral test: 1246-sc2-cross-validate-artifact-paths
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# SC-2 (string): cross-validate row documents receiving auditor_artifact_paths
# from the audit step.
#
# RED phase: greps for the NEW text pattern — should FAIL because old text is still there.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1246-sc2-cross-validate-artifact-paths"
SKILL_FILE="$SCRIPT_DIR/../../skills/implementation-pipeline/SKILL.md"

echo "=== Content-Verification Test: $SCENARIO_NAME ==="
echo "Checking for auditor_artifact_paths in cross-validate row of $SKILL_FILE"
echo ""

OVERALL_RESULT=0

# SC-2: The cross-validate row should document receiving auditor_artifact_paths
if grep -q "auditor_artifact_paths" "$SKILL_FILE" 2>/dev/null; then
    echo "PASS: cross-validate row documents auditor_artifact_paths"
else
    echo "FAIL: cross-validate row does NOT document auditor_artifact_paths (expected RED — change not yet made)"
    OVERALL_RESULT=1
fi

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME (RED phase — expected to fail until GREEN implementation)"
fi

exit $OVERALL_RESULT
