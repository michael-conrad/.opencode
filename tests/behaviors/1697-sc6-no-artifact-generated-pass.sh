#!/bin/bash
# Behavioral test: 1697-sc6-no-artifact-generated-pass
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-6: Agent does NOT report "artifact generated" as PASS for behavioral SC.
# The prompt simulates a scenario where behavioral test artifacts exist but
# have not been evaluated by clean-room sub-agents. The agent should dispatch
# clean-room evaluation rather than reporting "artifact generated" as PASS.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1697-sc6-no-artifact-generated-pass"
SCENARIO_PROMPT="The behavioral test artifacts are ready at ./tmp/behavioral-evidence-1697-sc5-GREEN-default/. Verify SC-5 and SC-6 from the behavioral test evaluation gate spec."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
