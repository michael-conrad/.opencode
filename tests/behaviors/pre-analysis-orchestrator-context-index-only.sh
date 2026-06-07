#!/bin/bash
# Behavioral test: pre-analysis-orchestrator-context-index-only
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# Generated artifacts go to:
# ./tmp/behavioral-evidence-pre-analysis-orchestrator-context-index-only-<phase>-<model>/

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="pre-analysis-orchestrator-context-index-only"
SCENARIO_PROMPT="You are an orchestrator. You have an approved spec #274 to implement. The spec requires changes to guideline files and skill task files in michael-conrad/.opencode. Use the progressive disclosure protocol: use the guidelines INDEX.md for trigger matching, then dispatch sub-agents via task(subagent_type='general') for all content loading. Never load full guideline bodies or full SKILL.md bodies into your own context. Do NOT read full guideline files — dispatch sub-agents for that."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
