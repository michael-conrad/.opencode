#!/bin/bash
# SC-17: SKILL.md Overview must contain dark-prose-001 identity-anchoring language
# (confirmshaming identity-frame, not procedural description).
# SC-18: Task table Purpose entries must contain IS/IS NOT binary definitions
# per dark-prose-002.
#
# RED test: Current SKILL.md Overview uses procedural language, not dark prose.
# The test MUST fail.
#
# Behavioral TDD cycle:
#   RED:   This test — Overview lacks dark-prose-001 identity-anchoring
#   GREEN: Rewrite Overview with dark-prose-001
#   REFACTOR: Verify Use when trigger pattern preserved, no advisory language
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="842-sc17-18-skill-md-dark-prose"
SCENARIO_PROMPT="You are reviewing the git-workflow SKILL.md Overview section. Does the Overview use professional identity language (dark prose pattern 001: confirmshaming identity-frame) that contrasts professional engineers with amateurs? And do the task Purpose entries use binary IS/IS NOT definitions (dark prose pattern 002)?

Read the git-workflow SKILL.md and describe: (1) the Overview tone and framing, and (2) whether Purpose entries use IS/IS NOT definitions."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-17: Agent MUST describe Overview as using identity-anchoring (professional/amateur) language
# Dark-prose-001 uses confirmshaming identity-frame: "Professional engineers X. Amateurs Y."
assert_required_pattern_present "professional\|amateur\|Professional\|Amateur" "agent recognizes identity-anchoring language" || OVERALL_RESULT=1

# SC-18: Agent MUST describe Purpose entries as using IS/IS NOT binary definitions
assert_required_pattern_present "IS\|IS NOT\|is.*not\|are.*not" "agent recognizes IS/IS NOT pattern" || OVERALL_RESULT=1

# Structural check: SKILL.md Overview should NOT use advisory language
# (should, please, recommended, make sure are advisory — forbidden by SC-16)
SKILL_FILE="$SCRIPT_DIR/../../skills/git-workflow/SKILL.md"
if [ -f "$SKILL_FILE" ]; then
    # After GREEN: this should find 0 advisory words in the Overview section
    # Currently: the old Overview likely contains advisory language
    OVERVIEW_START=$(grep -n "^# " "$SKILL_FILE" | head -1 | cut -d: -f1)
    TASK_TABLE_START=$(grep -n "^## Tasks\|^## Task\|Task.*Words" "$SKILL_FILE" | head -1 | cut -d: -f1)
    if [ -n "$OVERVIEW_START" ] && [ -n "$TASK_TABLE_START" ]; then
        if [ "$TASK_TABLE_START" -gt "$OVERVIEW_START" ]; then
            OVERVIEW_LINES=$((TASK_TABLE_START - OVERVIEW_START))
        else
            OVERVIEW_LINES=50
        fi
        ADVISORY_COUNT=$(sed -n "${OVERVIEW_START},+${OVERVIEW_LINES}p" "$SKILL_FILE" | grep -ci "should\|please\|recommended\|make sure" || echo "0")
        if [ "$ADVISORY_COUNT" -ne 0 ]; then
            echo "FAIL: Overview contains $ADVISORY_COUNT advisory language instances (should/please/recommended/make sure)"
            OVERALL_RESULT=1
        else
            echo "STRUCTURAL PASS: Overview has 0 advisory language instances"
        fi
    else
        echo "SKIP: Could not locate Overview section boundaries for structural check"
    fi
else
    echo "FAIL: SKILL.md not found at $SKILL_FILE"
    OVERALL_RESULT=1
fi

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT