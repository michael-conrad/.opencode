#!/bin/bash
# Behavioral test: 915-solve-state-update
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# SC-6 (#915/Phase2): solve state update records step transitions.
# RED:   Agent has no pipeline-state-machine.yaml or per-variable update
#        convention. Stderr shows no solve state update tool dispatch.
# GREEN: Agent invokes `solve state update --var-name` calls for
#        previous_step, current_step, pipeline_state.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="915-solve-state-update"

# Task prompt: record a pipeline transition. Neutral — doesn't name specific
# variables or the YAML contract path.
SCENARIO_PROMPT="I completed one step in my implementation pipeline and need to record the transition in the solve state tracker at .opencode/tools/solve. What does the update command look like?"

echo "=== Behavioral Test (RED): $SCENARIO_NAME ==="
echo "  Task: record a pipeline step transition"
echo "  RED: no per-variable solve update pattern exists"
echo ""

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

echo "  Artifacts: ${BEHAVIOR_ARTIFACT_DIR:-<not set>}"
echo "=== Done ==="
exit 0
