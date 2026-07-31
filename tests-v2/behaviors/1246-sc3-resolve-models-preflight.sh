#!/bin/bash
# Behavioral test: 1246-sc3-resolve-models-preflight
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# SC-9 (behavioral): Orchestrator dispatches an implementation audit when asked
#
# Artifact-only generator: produces model-run artifacts for clean-room evaluation.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1246-sc3-resolve-models-preflight"

echo "=== Behavioral Test (Artifact-Only Generator): $SCENARIO_NAME ==="
echo ""

# Prompt: ask the agent to do an implementation audit
SCENARIO_PROMPT="Do an implementation audit on #1246."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

echo ""
echo "Artifacts produced at: $BEHAVIOR_ARTIFACT_DIR"
echo ""

exit 0
