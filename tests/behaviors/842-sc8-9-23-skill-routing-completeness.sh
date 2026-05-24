#!/bin/bash
# SC-8, SC-9, SC-23: SKILL.md routing table must contain verification-gate,
# commit-prep, and individual pre-work sub-tasks. No word counts (≈) in task table.
#
# RED test: Current SKILL.md is missing these entries. The test MUST fail.
#
# Behavioral TDD cycle:
#   RED:   This test — agent cannot find verification-gate, commit-prep, or
#          pre-work sub-tasks in SKILL.md routing
#   GREEN: Add missing entries to SKILL.md with dark prose purposes
#   REFACTOR: Verify IS/IS NOT binary definitions and no word counts
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="842-sc8-9-23-skill-routing-completeness"
SCENARIO_PROMPT="You need to find the right task for verification-gate in the git-workflow skill. You read the SKILL.md routing table to find which task handles verification between VbC/audit and review-prep. Also find commit-prep and the individual pre-work sub-tasks (verify-auth, sync-dev, create-branch, init-env, report-ready).

What tasks does the git-workflow SKILL.md routing table contain for verification-gate, commit-prep, and pre-work sub-tasks?"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Capture evidence for orchestrator auditor dispatch by task() sub-agent
capture_and_cleanup "$SCENARIO_NAME"

# Structural check: no word counts in task table
# This is a content-verification on the file itself, NOT on agent prose — appropriate.
SKILL_FILE="$SCRIPT_DIR/../../skills/git-workflow/SKILL.md"
if [ -f "$SKILL_FILE" ]; then
    WORD_COUNTS=$(grep -c "≈" "$SKILL_FILE" 2>/dev/null || echo 0)
    WORD_COUNTS=$(echo "$WORD_COUNTS" | head -1 | tr -d '[:space:]')
    if [ "$WORD_COUNTS" -ne 0 ]; then
        echo "FAIL: SKILL.md still contains $WORD_COUNTS word-count markers (≈) in task table"
        OVERALL_RESULT=1
    else
        echo "STRUCTURAL PASS: SKILL.md has 0 word-count markers in task table"
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