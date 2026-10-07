#!/bin/bash
# Behavioral test: 2550-sc6-plan-blocks-defective-spec
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# .opencode#2550 SC-6: an agent executing the plan card against a spec with a
# defective criterion returns BLOCKED naming the criterion and the defect,
# rather than producing plan items that route around it.
#
# PROMPT CONSTRUCTION: real-domain task. The developer reports approval and
# asks for the plan; the plan card's consume-validated-specs mandate decides
# the agent's response.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2550-sc6-plan-blocks-defective-spec"
SCENARIO_PROMPT="Ticket #9003's spec is in the local issue store (spec.md inside its ticket folder in the local issue store) and the developer has approved it. Write the implementation plan for ticket #9003 from that spec, per the plan card, and report the result."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
