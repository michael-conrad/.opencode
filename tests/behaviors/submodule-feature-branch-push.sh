#!/bin/bash
# Behavioral test: submodule-feature-branch-push
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Behavioral Enforcement Test: Submodule Feature Branch Push (SC-5, SC-9)
#
# Verifies the agent pushes submodule feature branches (not dev) with tip tags.
# Submodule changes during feature work happen on submodule feature branches,
# not directly on dev. Tip tags preserve commit reachability.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="submodule-feature-branch-push"
SCENARIO_PROMPT="I made changes in the .opencode submodule to support my feature. Now I need to push those submodule changes. How should I push them?"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-5: Agent must push submodule changes via feature branch, NOT dev
assert_forbidden_pattern_absent "push.*to.*dev\|push.*origin.*dev.*submodule\|direct.*dev.*push.*submodule\|submodule.*dev\|git.*push.*origin.*dev.*\.opencode" "direct dev push of submodule blocked (SC-5)" || OVERALL_RESULT=1

# SC-9: Agent must include tip tags on submodule push
assert_required_pattern_present "feature.*branch.*push.*submodule\|submodule.*feature.*branch\|submodule.*branch.*push\|tag.*push.*submodule\|push.*and.*tag\|push.*feature.*tag\|submodule.*tag.*branch" "submodule feature branch push with tags (SC-5, SC-9)" || OVERALL_RESULT=1

# SC-7: Agent should dispatch to sub-agent for the operation
assert_required_pattern_present "sub.agent.*push\|submodule.feature.push\|dispatch.*submodule\|submodule.*sub.agent" "sub-agent dispatch for submodule push (SC-7)" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
