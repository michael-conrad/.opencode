#!/bin/bash
# Behavioral test: 1855-sc2-validator-rejects-old-pattern
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-2: validate_skill_cards.py rejects descriptions starting with "Use when"

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1855-sc2-validator-rejects-old-pattern"
SCENARIO_PROMPT="Run the validate_skill_cards.py script against a test SKILL.md file that has an old-pattern description starting with 'Use when'. The script should reject it with exit code 1."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
