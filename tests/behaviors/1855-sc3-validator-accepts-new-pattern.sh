#!/bin/bash
# Behavioral test: 1855-sc3-validator-accepts-new-pattern
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3: validate_skill_cards.py accepts descriptions matching the new pattern

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1855-sc3-validator-accepts-new-pattern"
SCENARIO_PROMPT="Run the validate_skill_cards.py script against a test SKILL.md file that has a new-pattern description starting with a noun phrase and containing 'Dispatch when' and 'User phrases:'. The script should accept it with exit code 0."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
