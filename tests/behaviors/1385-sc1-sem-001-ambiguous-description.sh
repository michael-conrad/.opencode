#!/bin/bash
# Behavioral test: 1385-sc1-sem-001-ambiguous-description
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# SC-SEM-001: spec-audit detects ambiguous skill descriptions

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1385-sc1-sem-001-ambiguous-description"
SCENARIO_PROMPT="You are auditing a skill card spec. The spec references a SKILL.md with this description: 'Use when working with data.' The Trigger Dispatch Table lists triggers for 'pre-work', 'implementation', 'cleanup'. Evaluate SC-SEM-001 (Unambiguous dispatch condition): does the description unambiguously tell an agent when to invoke this skill?"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
