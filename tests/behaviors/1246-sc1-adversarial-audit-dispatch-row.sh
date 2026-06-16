#!/bin/bash
# Behavioral test: 1246-sc1-adversarial-audit-dispatch-row
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# SC-1 (string): Dispatch routing table's adversarial-audit row documents
# resolve-models + dual-dispatch sequence instead of single --task verification-audit call.
#
# RED phase: greps for the NEW text pattern — should FAIL because old text is still there.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1246-sc1-adversarial-audit-dispatch-row"
SKILL_FILE="$SCRIPT_DIR/../../skills/implementation-pipeline/SKILL.md"

echo "=== Content-Verification Test: $SCENARIO_NAME ==="
echo "Checking for new dispatch row pattern in $SKILL_FILE"
echo ""

OVERALL_RESULT=0

# SC-1: The new adversarial-audit row should document resolve-models + dual-dispatch
# Scope to Dispatch Routing Table section (lines 46-64)
# Pattern: "resolve-models" in the adversarial-audit row (line 60)
DISPATCH_TABLE=$(sed -n '46,64p' "$SKILL_FILE")
if echo "$DISPATCH_TABLE" | grep -qi "resolve.m*models\|resolve-models"; then
    echo "PASS: adversarial-audit row in Dispatch Routing Table documents resolve-models"
else
    echo "FAIL: adversarial-audit row in Dispatch Routing Table does NOT document resolve-models (expected RED — change not yet made)"
    OVERALL_RESULT=1
fi

# Also check for dual-dispatch or multi-dispatch pattern in the dispatch table
if echo "$DISPATCH_TABLE" | grep -q "dispatch.*auditor_1\|dispatch.*auditor_2\|dual.*dispatch\|multi.*dispatch"; then
    echo "PASS: adversarial-audit row in Dispatch Routing Table documents dual/multi-dispatch"
else
    echo "FAIL: adversarial-audit row in Dispatch Routing Table does NOT document dual/multi-dispatch (expected RED — change not yet made)"
    OVERALL_RESULT=1
fi

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME (RED phase — expected to fail until GREEN implementation)"
fi

exit $OVERALL_RESULT
