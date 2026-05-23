#!/bin/bash
# SC-15: pre-merge-verification.md must NOT be a 67-word stub.
# Either absorbed into verify-merge.md or expanded to useful content (>200 words).
#
# RED test: Current file is a 67-word stub. The test MUST fail.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="842-sc15-pre-merge-verification-cleanup"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

OVERALL_RESULT=0

# SC-15: pre-merge-verification.md must not be a 67-word stub
# It should either be absorbed into verify-merge.md or expanded to >200 words
PMV_FILE="$SCRIPT_DIR/../../skills/git-workflow/tasks/cleanup/pre-merge-verification.md"

if [ -f "$PMV_FILE" ]; then
    WORD_COUNT=$(wc -w < "$PMV_FILE")
    if [ "$WORD_COUNT" -lt 200 ]; then
        echo "FAIL: pre-merge-verification.md has $WORD_COUNT words (expected >200 or absorbed)"
        echo "      File still exists as a stub — needs absorption or expansion"
        OVERALL_RESULT=1
    else
        echo "STRUCTURAL PASS: pre-merge-verification.md has $WORD_COUNT words (>=200)"
    fi
else
    # File was absorbed into verify-merge.md — that's also acceptable
    echo "STRUCTURAL PASS: pre-merge-verification.md has been absorbed (file deleted)"
fi

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME (expected — this is RED phase)"
fi

exit $OVERALL_RESULT