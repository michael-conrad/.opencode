#!/bin/bash
# Content-Verification Test: 1321-sc6-repo-routing-write (SC-6)
#
# Grep-based checks verifying that writing-plans/tasks/write.md contains
# a repo-routing step in its Operating Protocol. The write.md file does
# not exist yet, so all grep checks will FAIL — this is the expected RED
# state.
#
# Issue #1321: Fix issues-data URL construction — Phase 4, TDD-8

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

WRITE_MD="$PROJECT_DIR/.opencode/skills/writing-plans/tasks/write.md"

OVERALL_RESULT=0

echo "=== Content-Verification: 1321-sc6-repo-routing-write (SC-6) ==="

# SC-6: write.md exists
if [ -f "$WRITE_MD" ]; then
    echo "PASS: write.md exists"
else
    echo "FAIL: write.md does not exist (expected RED)"
    OVERALL_RESULT=1
fi

# SC-6: write.md Operating Protocol contains repo-routing step
if grep -q "repo-routing\|repo_routing\|repo routing\|Repo Information\|per-repo" "$WRITE_MD" 2>/dev/null; then
    echo "PASS: write.md has repo-routing step in Operating Protocol"
else
    echo "FAIL: write.md missing repo-routing step in Operating Protocol (expected RED)"
    OVERALL_RESULT=1
fi

# SC-6: write.md references session-init for repo resolution
if grep -q "session-init\|github\.owner\|github\.repo" "$WRITE_MD" 2>/dev/null; then
    echo "PASS: write.md references session-init for repo resolution"
else
    echo "FAIL: write.md missing session-init reference for repo resolution (expected RED)"
    OVERALL_RESULT=1
fi

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: 1321-sc6-repo-routing-write"
else
    echo "FAIL: 1321-sc6-repo-routing-write"
fi

exit $OVERALL_RESULT
