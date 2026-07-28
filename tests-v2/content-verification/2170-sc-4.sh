#!/bin/bash
# Content-verification test for SC-4 (issue #2170)
# Asserts: Pre-push hook Gate 2 message states only the block and reason
#          — no instructions, no workarounds, no guidance on bypassing.
# Expected: FAIL (current message contains instructional text)

set -euo pipefail

HOOK_FILE=".git/hooks/pre-push"
ARTIFACT_DIR="tmp/issue-2170/artifacts"
mkdir -p "$ARTIFACT_DIR"

# Extract Gate 2 message block: lines between "HARD BLOCK:" and the next blank line
# that ends the block (or the next echo "" before ALLOWED=false)
GATE2_MSG=$(sed -n '/HARD BLOCK:.*push prevented/,/^$/p' "$HOOK_FILE" | grep -v '^$' || true)

echo "=== Gate 2 message ===" > "$ARTIFACT_DIR/sc-4-test-output.log"
echo "$GATE2_MSG" >> "$ARTIFACT_DIR/sc-4-test-output.log"

# Define instructional patterns that MUST NOT appear in a block-only message
INSTRUCTIONAL_PATTERNS=(
    "You MUST"
    "you MUST"
    "you must"
    "delete this branch"
    "There is NO bypass"
    "Do NOT create"
    "To clean up"
    "To override"
    "To bypass"
    "If you have no"
)

FAILED=0
for pattern in "${INSTRUCTIONAL_PATTERNS[@]}"; do
    if echo "$GATE2_MSG" | grep -qiF "$pattern"; then
        echo "FAIL: Found instructional pattern '$pattern' in Gate 2 message" >> "$ARTIFACT_DIR/sc-4-test-output.log"
        FAILED=1
    fi
done

if [ "$FAILED" -eq 1 ]; then
    echo "" >> "$ARTIFACT_DIR/sc-4-test-output.log"
    echo "RESULT: FAIL — Gate 2 message contains instructional text" >> "$ARTIFACT_DIR/sc-4-test-output.log"
    exit 1
fi

echo "RESULT: PASS — Gate 2 message is block-and-reason only" >> "$ARTIFACT_DIR/sc-4-test-output.log"
exit 0
