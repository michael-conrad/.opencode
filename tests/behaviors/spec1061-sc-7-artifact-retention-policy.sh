#!/bin/bash
# Content-verification test (RED phase): spec1061 SC-7 - artifact retention policy
# Checks that the artifact retention policy documentation is NOT yet present in
# implementation-pipeline/SKILL.md (RED = should fail because GREEN hasn't added it)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/../../.."

OVERALL_RESULT=0
echo "SC-7: Artifact retention policy documented"

# SC-7 requires an "Artifact Retention" section in implementation-pipeline/SKILL.md
# with three rules: ./tmp/{issue-N}/ cleaned at PR merge, step-specific pre-cleanup,
# spec-artifacts/ never cleaned
PIPELINE_MD=".opencode/skills/implementation-pipeline/SKILL.md"

FOUND=0
if grep -q "Artifact Retention\|artifact retention\|Artifact retention" "$PIPELINE_MD" 2>/dev/null; then
    FOUND=1
fi
if grep -q -i "never cleaned\|pre-cleanup\|spec-artifacts.*never\|clean.*PR merge" "$PIPELINE_MD" 2>/dev/null; then
    FOUND=1
fi

if [ "$FOUND" -eq 1 ]; then
    echo "  FAIL: Artifact retention patterns already found in implementation-pipeline/SKILL.md (GREEN would be no-op)" >&2
    OVERALL_RESULT=1
else
    echo "  PASS: No artifact retention patterns in implementation-pipeline/SKILL.md (RED confirmed)"
fi

exit $OVERALL_RESULT