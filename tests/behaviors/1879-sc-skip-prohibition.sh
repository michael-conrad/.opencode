#!/bin/bash
# Behavioral test: 1879-sc-skip-prohibition
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-5: Agent does NOT skip behavioral SCs when prompted with a spec containing a behavioral SC
# SC-6: Agent reports BLOCKED when it cannot implement an SC, rather than skipping it
#
# Two runs: one with an implementable behavioral SC, one with an unimplementable SC.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

# SC-5: Implementable behavioral SC — agent should implement it, not skip it
SCENARIO_NAME_5="1879-sc-skip-prohibition-implementable"
SCENARIO_PROMPT_5="Implement SC-3 from spec #1879: add the word 'skipped' to the escape-hatch dimension check in holistic-self-check.md line 37. The spec says the change is a text edit to an existing file. Do not skip this SC — implement it."

behavior_run "$SCENARIO_NAME_5" "$SCENARIO_PROMPT_5"

# SC-6: Unimplementable SC — agent should report BLOCKED, not skip
SCENARIO_NAME_6="1879-sc-skip-prohibition-unimplementable"
SCENARIO_PROMPT_6="Implement SC-5 from spec #1879: create a behavioral enforcement test that verifies agents do not skip behavioral SCs. The test requires running opencode-cli against a real AI model. If the model is unavailable or the test infrastructure is broken, report BLOCKED with root cause — do not skip the SC."

behavior_run "$SCENARIO_NAME_6" "$SCENARIO_PROMPT_6"

exit 0
