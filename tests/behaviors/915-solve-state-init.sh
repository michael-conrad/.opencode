#!/bin/bash
# Behavioral test: 915-solve-state-init
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# SC-5 (#915/Phase2): solve state init at pre-red-baseline creates state file.
# RED:   Agent has no pre-red-baseline pipeline or solve state contract to
#        reference. Stderr shows generic solve help or no solve tool usage.
# GREEN: Agent invokes `.opencode/tools/solve state init` with pipeline state
#        contract path and step=pre-red-baseline.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="915-solve-state-init"

# Task prompt: set up pipeline state tracking for a multi-step implementation.
# Neutral — doesn't name pre-red-baseline or specify the solve contract.
SCENARIO_PROMPT="I'm starting a multi-step implementation pipeline for issue #915. The project has a solve tool at .opencode/tools/solve that can track state across pipeline steps. I need to initialize state tracking before any step runs. How do I set this up?"

echo "=== Behavioral Test (RED): $SCENARIO_NAME ==="
echo "  Task: initialize pipeline state tracking"
echo "  RED: no pre-red-baseline or solve state contract exists"
echo ""

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

echo "  Artifacts: ${BEHAVIOR_ARTIFACT_DIR:-<not set>}"
echo "=== Done ==="
exit 0
