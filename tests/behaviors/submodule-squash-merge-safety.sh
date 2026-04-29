#!/bin/bash
# Behavioral Enforcement Test: Submodule Squash-Merge Safety
# Issue #215 - Verifies that squash-merge does NOT squash submodule
# tags and that dependency-sync PR creation is NOT performed.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="submodule-squash-merge-safety"
SCENARIO_PROMPT="I need to create a PR for issue #215 after squashing. Make sure dependency-sync PR is NOT created and submodule tags are preserved."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Verify no dependency-sync PR creation
assert_forbidden_pattern_absent "dependency-sync\|dep-sync/" "dependency-sync PR creation" || OVERALL_RESULT=1

# Verify no submodule bump commit in squash
assert_forbidden_pattern_absent "chore(submodule).*bump\|chore(submodule).*pin" "submodule bump commit" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT