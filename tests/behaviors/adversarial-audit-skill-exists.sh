#!/bin/bash
# Phase 2 RED: adversarial-audit skill file existence test (Items 11-14)
#
# Verifies that the adversarial-audit skill directory and all required
# task files exist. This test MUST FAIL in RED phase (no skill exists yet).
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done

SCENARIO_NAME="adversarial-audit-skill-exists"
SKILL_DIR="$PROJECT_DIR/skills/adversarial-audit"

echo "=== Content-Verification Test: $SCENARIO_NAME ==="

OVERALL_RESULT=0

check_file() {
    local path="$1"
    local label="$2"
    if [ -f "$path" ]; then
        echo "  PASS: $label exists ($path)"
    else
        echo "  FAIL: $label does NOT exist ($path)"
        OVERALL_RESULT=1
    fi
}

check_file "$SKILL_DIR/SKILL.md" "skill manifest"
check_file "$SKILL_DIR/tasks/cross-validate.md" "cross-validate task"
check_file "$SKILL_DIR/tasks/resolve-models.md" "resolve-models task"
check_file "$SKILL_DIR/tasks/completion.md" "completion task"

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
