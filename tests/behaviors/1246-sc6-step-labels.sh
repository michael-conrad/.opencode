#!/bin/bash
# Behavioral test: 1246-sc6-step-labels
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# SC-6 (string): Step Labels section includes resolve-models or references
# the multi-dispatch pattern.
#
# RED phase: greps for the NEW text pattern — should FAIL because old text is still there.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1246-sc6-step-labels"
SKILL_FILE="$SCRIPT_DIR/../../skills/implementation-pipeline/SKILL.md"

echo "=== Content-Verification Test: $SCENARIO_NAME ==="
echo "Checking for resolve-models in Step Labels section of $SKILL_FILE"
echo ""

OVERALL_RESULT=0

# SC-6: Step Labels section should include resolve-models as a standalone label
# Scope to Step Labels section (lines 82-84)
STEP_LABELS=$(sed -n '82,84p' "$SKILL_FILE")
if echo "$STEP_LABELS" | grep -q "resolve-models"; then
    echo "PASS: Step Labels section includes resolve-models as a standalone label"
else
    echo "FAIL: Step Labels section does NOT include resolve-models (expected RED — change not yet made)"
    OVERALL_RESULT=1
fi

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME (RED phase — expected to fail until GREEN implementation)"
fi

exit $OVERALL_RESULT
