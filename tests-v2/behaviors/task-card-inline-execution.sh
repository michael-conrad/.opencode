#!/bin/bash
# Behavioral test: task-card-inline-execution
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-7: Sub-agent receiving remediated task card executes inline
# (does not attempt to call task() or dispatch other sub-agents)
#
# RED phase: Task cards may still contain dispatch-level markers.
# GREEN phase: After remediation, task cards are self-contained inline procedures.
#
# Prompt is a real-domain task that triggers audit skill dispatch.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="task-card-inline-execution"
SCENARIO_PROMPT="Run a spec audit on issue #2032. The spec is at .opencode/.issues/2032/spec.md."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
