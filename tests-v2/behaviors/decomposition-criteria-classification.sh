#!/bin/bash
# Behavioral test: decomposition-criteria-classification
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-9: sub-agent reads master decomposition criteria reference and correctly
# identifies PASS/FAIL for a sample SC.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="decomposition-criteria-classification"
SCENARIO_PROMPT="Read the decomposition criteria reference at audit/reference/decomposition-criteria.md. Then classify each of the following success criteria as PASS or FAIL against the Atomicity criterion (criterion 1). Explain your reasoning for each.

1. \"The system validates email format on registration.\"
2. \"The system validates email format AND sends confirmation email AND logs the attempt.\"
3. \"The system validates email format, sends confirmation email, and logs the attempt.\"
4. \"The system validates email format.\"
5. \"The system validates email format or sends confirmation email.\""

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
