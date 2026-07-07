#!/bin/bash
# Phase 2 RED: audit skill file existence test (Items 11-14)
#
# Verifies that the audit skill directory and all required
# task files exist. This test MUST FAIL in RED phase (no skill exists yet).
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done

SCENARIO_NAME="audit-skill-exists"
SKILL_DIR="$PROJECT_DIR/skills/audit"

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

# --- SC-5: Skill audit phase identity (spec #397) ---
SKILL_MD="$SKILL_DIR/SKILL.md"
if [ -f "$SKILL_MD" ]; then
    if grep -q "audit_phase" "$SKILL_MD"; then
        echo "  PASS: SKILL.md declares audit_phase identity (SC-5)"
    else
        echo "  FAIL: SKILL.md missing audit_phase identity declaration (SC-5)"
        OVERALL_RESULT=1
    fi
else
    echo "  SKIP: SKILL.md not found for audit_phase check (SC-5)"
fi

# --- SC-3/SC-4: Agent card MANDATORY FIRST CHECK (spec #397) ---
AGENT_DIR="$PROJECT_DIR/agents"
if [ -d "$AGENT_DIR" ]; then
    AUDITOR_CARDS=$(find "$AGENT_DIR" -maxdepth 1 -name "auditor-*.md" 2>/dev/null | head -1)
    if [ -n "$AUDITOR_CARDS" ]; then
        CARD_FILE="$AUDITOR_CARDS"
        if grep -q "MANDATORY FIRST CHECK" "$CARD_FILE"; then
            echo "  PASS: Agent card has MANDATORY FIRST CHECK (SC-1/SC-4)"
        else
            echo "  FAIL: Agent card missing MANDATORY FIRST CHECK (SC-1/SC-4)"
            OVERALL_RESULT=1
        fi
        if grep -q "clean_room" "$CARD_FILE"; then
            echo "  PASS: Agent card has clean_room output block (SC-3)"
        else
            echo "  FAIL: Agent card missing clean_room output block (SC-3)"
            OVERALL_RESULT=1
        fi
    else
        echo "  SKIP: No auditor agent cards found for MANDATORY FIRST CHECK check"
    fi
else
    echo "  SKIP: agents directory not found for MANDATORY FIRST CHECK check"
fi

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
