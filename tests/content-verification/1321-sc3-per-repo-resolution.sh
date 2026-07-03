#!/bin/bash
# Content-Verification Test: 1321-sc3-per-repo-resolution (SC-3)
#
# Grep-based checks verifying that write.md contains per-repo resolution
# rules for URL construction: html_url, owner, repo come from session-init
# repo entry matching the issue's repo.
#
# RED phase: write.md still has hardcoded github.html_url and no per-repo
# resolution rule. These grep checks will FAIL.
#
# Issue #1321: Fix issues-data URL construction

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

WRITE_MD="$PROJECT_DIR/.opencode/skills/spec-creation/tasks/write.md"

OVERALL_RESULT=0

echo "=== Content-Verification: 1321-sc3-per-repo-resolution (SC-3) ==="

# SC-3: URL construction includes per-repo resolution rule referencing session-init
if grep -q "session-init\|Repo Information\|per-repo" "$WRITE_MD" 2>/dev/null; then
    echo "PASS: write.md references session-init or Repo Information for per-repo resolution"
else
    echo "FAIL: write.md missing session-init/Repo Information reference for per-repo resolution"
    OVERALL_RESULT=1
fi

# SC-3: URL construction instructions mention resolving html_url from repo entry
if grep -q "html_url.*repo\|repo.*html_url\|per-repo.*url\|url.*per-repo" "$WRITE_MD" 2>/dev/null; then
    echo "PASS: write.md has per-repo html_url resolution rule"
else
    echo "FAIL: write.md missing per-repo html_url resolution rule"
    OVERALL_RESULT=1
fi

# SC-3: No hardcoded github.html_url in URL construction lines
if grep -n "github.html_url" "$WRITE_MD" 2>/dev/null | grep -i "tree/issues-data" > /dev/null 2>&1; then
    echo "FAIL: write.md still has hardcoded github.html_url in URL construction"
    OVERALL_RESULT=1
else
    echo "PASS: write.md has no hardcoded github.html_url in URL construction"
fi

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: 1321-sc3-per-repo-resolution"
else
    echo "FAIL: 1321-sc3-per-repo-resolution"
fi

exit $OVERALL_RESULT
