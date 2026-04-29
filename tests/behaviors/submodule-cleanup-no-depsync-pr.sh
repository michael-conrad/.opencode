#!/bin/bash
# Behavioral Enforcement Test: Submodule Cleanup No Dep-Sync PR
# Issue #215 - Verifies that cleanup does NOT create a dependency-sync PR
# and instead restores submodules to dev without creating a sync branch.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="submodule-cleanup-no-depsync-pr"
SCENARIO_PROMPT="After PR merge for issue #215, run cleanup. Restore submodules to dev but do NOT create a dependency-sync PR. The dep-sync task is removed."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Verify no dependency-sync PR creation
assert_forbidden_pattern_absent "dependency-sync\|dep-sync/\|sync.*latest dev\|submodule.*pointer.*drift" "dependency-sync PR creation" || OVERALL_RESULT=1

# Verify no dep-sync branch creation
assert_forbidden_pattern_absent "dep-sync/" "dep-sync branch creation" || OVERALL_RESULT=1

# Verify submodule dev restore is mentioned
assert_required_pattern_present "dev-restore\|restore.*dev\|checkout dev" "submodule dev restore reference" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT