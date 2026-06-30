#!/bin/bash
# Behavioral test: frontmatter-compatibility
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3: All SKILL.md files must have a compatibility: field in frontmatter.
# RED phase: count of files WITH compatibility is < 42 (some are missing).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="frontmatter-compatibility"

# Count files that have compatibility: field (grep -c returns per-file count;
# we count how many files have count > 0 by filtering for :[1-9] or :[0-9][0-9])
COMPAT_COUNT=$(grep -c '^compatibility:' .opencode/skills/*/SKILL.md .opencode/skills/issue-operations/platforms/*/SKILL.md 2>/dev/null | grep -c ':[1-9]' || echo 0)

# SC-3: Assert count >= 42 (all files should have compatibility)
# RED phase: this FAILS because only 39 of 41 files have compatibility
if [ "$COMPAT_COUNT" -ge 42 ]; then
  echo "SC-3: PASS — $COMPAT_COUNT files have compatibility: field"
else
  echo "SC-3: FAIL — $COMPAT_COUNT files have compatibility: field (expected >= 42)"
fi

echo "compatibility_count=$COMPAT_COUNT" > "$SCRIPT_DIR/../../tmp/frontmatter-compatibility-count.txt"

exit 0
