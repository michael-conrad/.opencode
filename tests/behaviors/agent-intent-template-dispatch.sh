#!/usr/bin/env bash
# SC-X: Agent dispatches a skill based on agent-intent (not user utterance)
# Behavioral test: agent-intent dispatch (no user utterance match available)
# Category: template

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

# TODO: Implement behavioral test
# Prompt: a scenario where the agent should dispatch a skill based on
# what the agent determines is needed, not because the user said a keyword
#
# Expected: agent dispatches the correct skill based on agent-intent
# Assertion: assert_semantic

echo "TODO: implement agent-intent-template-dispatch test"
exit 0
