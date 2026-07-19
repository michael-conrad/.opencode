#!/bin/bash
# Behavioral test: sc12-create-remote-stub
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-12: create-remote-stub.md exists and handles both remote and local
# platforms without BLOCKED.
#
# RED phase: create-remote-stub.md does not exist yet — the agent cannot
# dispatch to it and must either fall through or BLOCK.
# GREEN phase: After create-remote-stub.md is created, the agent dispatches
# to it and handles both remote and local platforms.
#
# Prompt is a real-domain task that triggers spec-creation skill dispatch.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc12-create-remote-stub"
SCENARIO_PROMPT="Create a spec for issue #42. I need a specification document for the new feature."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
