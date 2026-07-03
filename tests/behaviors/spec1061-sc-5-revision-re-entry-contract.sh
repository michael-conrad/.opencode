#!/bin/bash
# Content-verification test (RED phase): spec1061 SC-5 - revision re-entry protocol contract
# Checks that the revision re-entry protocol solve contract does NOT exist yet
# (RED = should fail because GREEN hasn't generated it)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/../../.."

OVERALL_RESULT=0
echo "SC-5: Revision re-entry protocol contract"

# SC-5 requires revision-re-entry-contract.yaml at 
ARTIFACT=".opencode/.issues/1061/revision-re-entry-contract.yaml"
if [ -f "$ARTIFACT" ]; then
    echo "  FAIL: $ARTIFACT already exists (GREEN would be no-op)" >&2
    OVERALL_RESULT=1
else
    echo "  PASS: $ARTIFACT does NOT exist (RED confirmed)"
fi

# Also check the generation pattern isn't in write.md
WRITE_MD=".opencode/skills/spec-creation/tasks/write.md"
if grep -q "revision-re-entry-contract\|revision.*re-entry.*protocol\|revision.*re-entry.*contract" "$WRITE_MD" 2>/dev/null; then
    echo "  FAIL: revision re-entry contract generation pattern already in write.md" >&2
    OVERALL_RESULT=1
fi

# Check it is not in approval-gate SKILL.md either (GREEN adds pre-approval gate read)
APPROVAL_MD=".opencode/skills/approval-gate/SKILL.md"
if grep -q "revision-re-entry-contract\|re-entry.*protocol" "$APPROVAL_MD" 2>/dev/null; then
    echo "  FAIL: revision re-entry pattern already in approval-gate SKILL.md" >&2
    OVERALL_RESULT=1
fi

exit $OVERALL_RESULT