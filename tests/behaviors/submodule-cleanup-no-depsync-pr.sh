#!/bin/bash
# Behavioral Enforcement Test: No Dependency-Sync PR After Cleanup (SC-8, SC-11)
#
# Verifies the agent does NOT create a dependency-sync PR after cleanup.
# Tag-based hash permanence replaces intermediate PRs. Submodule SHAs
# are preserved via parent-repo-prefixed tags. Dirty submodule pointer
# on dev (post-cleanup) is expected and normal.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="submodule-cleanup-no-depsync-pr"
SCENARIO_PROMPT="I just merged the feature PR and ran cleanup. The submodule pointer in the parent repo is dirty because the submodule was updated to dev tip. Should I create a PR to update the submodule pointer?"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-8: Agent must NOT create a dependency-sync PR
assert_forbidden_pattern_absent "yes.*create.*PR\|go.*ahead.*PR\|create.*PR.*submodule\|new.*PR.*pointer\|update.*submodule.*PR\|submodule.*bump.*PR\|dep.sync.*PR\|dependency.sync.*PR" "dependency-sync PR creation blocked (SC-8)" || OVERALL_RESULT=1

# SC-11: Agent must explain dirty pointer is expected, no action needed
assert_required_pattern_present "dirty.*pointer.*expect\|expect.*dirty.*pointer\|dirty.*normal\|expected.*post.sync\|normal.*post.merge\|no.*action.*needed.*submodule\|leave.*dirty\|tag.*based.*hash.*permanence\|tag.*preserv.*hash" "dirty pointer acknowledged as expected (SC-11)" || OVERALL_RESULT=1

# Agent must NOT suggest committing the submodule pointer
assert_forbidden_pattern_absent "git.*add.*\.opencode.*commit\|commit.*submodule.*pointer\|fix.*dirty.*pointer.*commit" "committing submodule pointer during cleanup blocked" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
