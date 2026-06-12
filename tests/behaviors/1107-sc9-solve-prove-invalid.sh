#!/bin/bash
# Behavioral test: 1107-sc9-solve-prove-invalid
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# SC-9 (#1107/Phase3): Invalid theorem (preconditions+invariants do not imply
#   theorem) → solve prove returns INVALID
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1107-sc9-solve-prove-invalid"

SCENARIO_PROMPT="I need to prove that x == y holds given my contract has precondition x > 0 and y < 0. The solve tool is at .opencode/tools/solve. Run solve prove with a contract that establishes this theorem is NOT valid."

echo "=== Behavioral Test (GREEN): $SCENARIO_NAME ==="
echo "  Task: prove invalid theorem via solve prove"
echo ""

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

echo "  Artifacts: ${BEHAVIOR_ARTIFACT_DIR:-<not set>}"
echo "=== Done ==="
exit 0