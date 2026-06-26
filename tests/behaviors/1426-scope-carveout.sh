#!/bin/bash
# Behavioral test: 1426-scope-carveout
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# SC-4: Agent does NOT close an issue with valid SCs and problem statement
# when the only defect is a removable section in the body — instead, the agent
# edits the body.
#
# The fixture issue #5 has a valid problem statement and valid SCs but contains
# an "Implementation Plan" section that belongs in the plan, not the spec.
# The agent MUST edit the body to remove the defective section rather than
# closing the issue as not_planned or discarding the entire artifact.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1426-scope-carveout"
SCENARIO_PROMPT="Issue #5 has a valid problem statement and valid SCs but contains an 'Implementation Plan' section that belongs in the plan, not the spec. Handle this issue appropriately."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
