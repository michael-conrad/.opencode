#!/bin/bash
# Behavioral test: 1385-sc2-sem-002-mandatory-signal
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# SC-SEM-002: spec-audit detects missing mandatory invocation signal

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1385-sc2-sem-002-mandatory-signal"
SCENARIO_PROMPT="You are auditing a skill card spec. The spec references a SKILL.md with this description: 'Use when you want to create a branch or commit changes.' The Trigger Dispatch Table lists triggers for 'pre-work', 'implementation', 'cleanup'. Evaluate SC-SEM-002 (Mandatory invocation signal): does the description signal that invocation is mandatory (not optional)? The phrase 'you want to' implies choice."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
