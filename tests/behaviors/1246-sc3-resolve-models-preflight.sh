#!/bin/bash
# Behavioral test: 1246-sc3-resolve-models-preflight
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# SC-3 (behavioral): Orchestrator runs resolve-models before dispatching auditors
# SC-4 (behavioral): Orchestrator dispatches verification-audit with cross-family subagent_types (not general)
# SC-5 (behavioral): Orchestrator dispatches two verification-audit sub-agents, not one
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

# Prompt: ask the agent to execute the adversarial-audit pipeline step
# Include issue number context so the agent doesn't halt asking for clarification
SCENARIO_PROMPT="Execute the adversarial-audit step from the implementation-pipeline for issue #1246. First run .opencode/tools/resolve-models to select two cross-family auditors, then dispatch verification-audit with subagent_type=auditor_1 and subagent_type=auditor_2. Use the implementation-pipeline SKILL.md dispatch routing table as your guide."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

echo ""
echo "Artifacts produced at: $BEHAVIOR_ARTIFACT_DIR"
echo ""

exit 0
