#!/bin/bash
# Content-Verification Test: 1321-sc6-repo-routing-skill (SC-6)
#
# Grep-based checks verifying that writing-plans/SKILL.md Operating
# Protocol includes a repo-routing step. No such reference exists yet,
# so all grep checks will FAIL — this is the expected RED state.
#
# Issue #1321: Fix issues-data URL construction — Phase 4, TDD-9

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

SKILL_MD="$PROJECT_DIR/.opencode/skills/writing-plans/SKILL.md"

OVERALL_RESULT=0

echo "=== Content-Verification: 1321-sc6-repo-routing-skill (SC-6) ==="

# SC-6: SKILL.md Operating Protocol contains repo-routing step
if grep -q "repo-routing\|repo_routing\|repo routing\|Repo Information\|per-repo" "$SKILL_MD" 2>/dev/null; then
    echo "PASS: SKILL.md Operating Protocol has repo-routing step"
else
    echo "FAIL: SKILL.md Operating Protocol missing repo-routing step (expected RED)"
    OVERALL_RESULT=1
fi

# SC-6: SKILL.md Operating Protocol step references session-init for repo resolution
if grep -q "session-init\|github\.owner\|github\.repo" "$SKILL_MD" 2>/dev/null; then
    echo "PASS: SKILL.md Operating Protocol references session-init for repo resolution"
else
    echo "FAIL: SKILL.md Operating Protocol missing session-init reference (expected RED)"
    OVERALL_RESULT=1
fi

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: 1321-sc6-repo-routing-skill"
else
    echo "FAIL: 1321-sc6-repo-routing-skill"
fi

exit $OVERALL_RESULT
