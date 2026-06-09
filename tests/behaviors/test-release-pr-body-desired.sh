#!/usr/bin/env bash
# SC: Release promotion PR body uses dynamically generated content from git log/git diff,
# NOT generic boilerplate like "Automated dev → main promotion"
# RED phase: test FAILS because boilerplate IS still present
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RELEASE_TASK="$SCRIPT_DIR/../../skills/git-workflow/tasks/release-promotion.md"

if [ ! -f "$RELEASE_TASK" ]; then
  echo "FAIL: release-promotion.md not found at $RELEASE_TASK"
  exit 1
fi

# Check for generic boilerplate pattern — if found, test fails (RED = bug exists)
if grep -q "Automated dev → main promotion" "$RELEASE_TASK"; then
  echo "RED: Boilerplate 'Automated dev → main promotion' IS present (bug confirmed, test fails as expected)"
  exit 1
else
  echo "GREEN: Boilerplate removed (desired behavior achieved)"
  exit 0
fi