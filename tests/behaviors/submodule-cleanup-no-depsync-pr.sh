#!/bin/bash
# Behavioral test: submodule-cleanup-no-depsync-pr
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Behavioral Enforcement Test: No Dependency-Sync PR After Cleanup (SC-8, SC-11)
#
# Verifies the agent does NOT create a dependency-sync PR after cleanup
# and explains that the dirty submodule pointer on dev is expected.
#
# Evidence type: behavioral — verified by clean-room semantic inspection.
# Per 080-code-standards.md §Rule 5, grep/string assertions on agent output
# prose are EVIDENCE_TYPE_MISMATCH for behavioral SCs.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="submodule-cleanup-no-depsync-pr"
SCENARIO_PROMPT="I just merged the feature PR and ran cleanup. The submodule pointer in the parent repo is dirty because the submodule was updated to dev tip. Should I create a PR to update the submodule pointer?"

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "SC-8: Agent must NOT create a dependency-sync PR"
echo "SC-11: Agent must acknowledge dirty pointer is expected"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-8: Behavioral evidence — agent does NOT suggest creating a PR for the submodule pointer
assert_semantic "SC-8" "Agent does NOT suggest creating a PR to update the submodule pointer. The agent must NOT propose or recommend creating a PR whose sole purpose is updating the submodule pointer. The agent must NOT say 'yes create a PR' or 'go ahead and create a PR' for the submodule pointer update." "forbidden" || OVERALL_RESULT=1

# SC-11: Behavioral evidence — agent acknowledges dirty pointer is expected
assert_semantic "SC-11" "Agent explains that the dirty submodule pointer on dev after cleanup is expected, normal, and correct. The agent must state or imply that no action is needed for the dirty pointer — it will naturally advance when the next feature branch merges. The agent must reference that leaving the dirty pointer is the correct behavior, not something to fix." "required" || OVERALL_RESULT=1

# Structural corroboration — agent does NOT suggest committing any submodule pointer
assert_stderr_pattern_absent "git add.*submodule.*commit\|commit.*submodule.*pointer\|commit.*dirty.*pointer\|dirty.*pointer.*to dev" "committing submodule pointer during cleanup" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT