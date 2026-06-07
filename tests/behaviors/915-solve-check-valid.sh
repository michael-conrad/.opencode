#!/bin/bash
# Behavioral test: 915-solve-check-valid
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# SC-7 (#915/Phase2): solve check validates legal step transitions.
# RED:   Agent has no pipeline-state-machine.yaml contract so cannot validate
#        transitions. Stderr shows no solve check against pipeline contract.
# GREEN: Agent invokes `solve check --state-path ... --contract-path ...`
#        using pipeline-state-machine.yaml as the transition contract.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="915-solve-check-valid"

# Task prompt: validate whether a step sequence in the pipeline is legal.
# Neutral — doesn't name the contract file or specify step labels.
SCENARIO_PROMPT="I have a solve state file tracking my pipeline position and I want to check whether my current step sequence is valid according to the pipeline's transition rules. The solve tool is at .opencode/tools/solve. How do I run this validation?"

echo "=== Behavioral Test (RED): $SCENARIO_NAME ==="
echo "  Task: validate pipeline step sequence"
echo "  RED: no pipeline-state-machine.yaml contract exists"
echo ""

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

echo "  Artifacts: ${BEHAVIOR_ARTIFACT_DIR:-<not set>}"
echo "=== Done ==="
exit 0
