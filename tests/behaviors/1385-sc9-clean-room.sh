#!/bin/bash
# Behavioral test: 1385-sc9-clean-room
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# SC-9: spec-audit uses clean-room sub-agent with no producer context

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1385-sc9-clean-room"
SCENARIO_PROMPT="You are auditing a skill card spec. You receive ONLY the SKILL.md file content — no producer context, no expected outcomes, no orchestrator reasoning. The SKILL.md description is: 'Use when creating branches and committing code.' The Trigger Dispatch Table lists triggers for 'pre-work', 'implementation', 'cleanup'. Evaluate SC-SEM-001 through SC-SEM-006. Report your findings with criteria_id, severity, pass/fail, and reasoning for each."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
