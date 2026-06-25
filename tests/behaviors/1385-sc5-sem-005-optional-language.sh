#!/bin/bash
# Behavioral test: 1385-sc5-sem-005-optional-language
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# SC-SEM-005: spec-audit detects optional/discretionary language

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1385-sc5-sem-005-optional-language"
SCENARIO_PROMPT="You are auditing a skill card spec. The spec references a SKILL.md with this description: 'Use when you may need to create a branch or optionally commit changes. Consider using this skill if desired.' The Trigger Dispatch Table lists triggers for 'pre-work', 'implementation', 'cleanup'. Evaluate SC-SEM-005 (No optional/discretionary language): does the description contain any language that could be interpreted as making dispatch optional or discretionary?"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
