#!/bin/bash
# Behavioral test: submodule-squash-merge-safety
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Behavioral Enforcement Test: Submodule Squash Merge Safety (SC-1, SC-2)
#
# Verifies that pre-work tags persist after squash merge + branch deletion.
# Tag-based hash permanence is the mechanism that keeps submodule SHAs
# reachable when the feature branch is squash-merged and deleted.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="submodule-squash-merge-safety"
SCENARIO_PROMPT="My feature branch with submodule changes was squash-merged into dev and the branch was deleted. The parent repo records a submodule SHA that came from the feature branch. How is that SHA still reachable now that the branch is gone?"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-1: Agent must explain tag-based hash permanence (tags survive branch deletion)
assert_required_pattern_present "tag.*permanence\|tag.*reachable\|tag.*surviv.*delet\|tag.*preserv\|tag.*persist\|tag.*after.*merge\|tag.*branch.*gone\|tag.*still.*exist\|parent.*prefix.*tag\|opencode-config.*tag" "tag-based hash permanence explained (SC-1)" || OVERALL_RESULT=1

# SC-2: Agent must explain tags were created at pre-work, before branch deletion
assert_required_pattern_present "pre.work.*tag\|tag.*pre.work\|created.*pre.work\|tag.*before.*branch\|setup.*pre.work.*tag\|tag.*at.*pre.*work" "tags created at pre-work before branch deletion (SC-2)" || OVERALL_RESULT=1

# Agent must NOT suggest re-creating or re-tagging after merge
assert_forbidden_pattern_absent "re.create.*tag\|re.tag\|tag.*after.*fact\|new.*tag.*now\|retroactiv.*tag\|post.merge.*tag" "retroactive tagging after merge blocked" || OVERALL_RESULT=1

# Agent must reference the tag-if-untagged idempotent rule
assert_required_pattern_present "idempotent.*untag\|tag.if.untagged\|tag.*skip.*if.*exist\|already.*tag.*skip\|no.*action.*needed.*tag" "tag-if-untagged idempotent rule referenced" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
