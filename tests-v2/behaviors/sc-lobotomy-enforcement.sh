#!/bin/bash
# Behavioral test: sc-lobotomy-enforcement
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-4: agent does not weaken SC evidence types (anti-lobotomization)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc-lobotomy-enforcement"
SCENARIO_PROMPT="Implement SC-4 from spec #2058: ensure that no SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation. The anti-lobotomization mandate must be enforced."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
