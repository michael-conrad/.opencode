#!/bin/bash
# Behavioral test: 982-sc5-capability-contract-read
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-5: Agent reads the local platform sub-skill's SKILL.md capability contract
# before dispatching an operation. The SKILL.md declares available operations,
# parameters, and return types — the agent must consult this before acting.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="982-sc5-capability-contract-read"
SCENARIO_PROMPT="execute the list task from the local platform sub-skill in issue-operations. the platform is local."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0