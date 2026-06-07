#!/bin/bash
# SC-6: Auditor agent types are consistently available for programmatic dispatch
#
# Content-verification test for spec #578 Defect 5.
# Verifies auditor-*.md descriptions do NOT contain "should only be called manually by the user".
#
# RED: Expect FAIL against dev baseline (auditor cards say "should only be called manually").
# GREEN: Expect PASS after implementation.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="578-sc6-auditor-descriptions-programmatic"

PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

AGENTS_DIR="$PROJECT_DIR/.opencode/agents"

echo "=== Content-Verification Test: $SCENARIO_NAME ==="

OVERALL_RESULT=0

# Find all auditor agent files
AUDITOR_FILES=$(find "$AGENTS_DIR" -name "auditor-*.md" -type f 2>/dev/null || true)

if [ -z "$AUDITOR_FILES" ]; then
    echo "FAIL: $SCENARIO_NAME — No auditor-*.md files found in $AGENTS_DIR"
    OVERALL_RESULT=1
else
    MANUAL_COUNT=0
    for FILE in $AUDITOR_FILES; do
        FILENAME=$(basename "$FILE")
        # Check for the old "should only be called manually" language
        if grep -qi "should only be called manually\|only be called manually" "$FILE"; then
            echo "FAIL: $SCENARIO_NAME — $FILENAME contains 'should only be called manually' restriction"
            MANUAL_COUNT=$((MANUAL_COUNT + 1))
            OVERALL_RESULT=1
        else
            echo "PASS: $SCENARIO_NAME — $FILENAME allows programmatic dispatch"
        fi
    done

    if [ "$MANUAL_COUNT" -eq 0 ]; then
        echo "PASS: $SCENARIO_NAME — All auditor agent files support programmatic dispatch"
    fi
fi

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT