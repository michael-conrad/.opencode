#!/bin/bash
# Behavioral test: 1582-sc5-concern-separation-routing
# SC-5: Concern-separation auditor detects missing routing table changes
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# PROMPT CONSTRUCTION GUIDANCE:
# Real-domain task: triggers concern-separation audit on a spec that removes a task file
# with a routing/dispatch table but doesn't update the routing table.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1582-sc5-concern-separation-routing"
SCENARIO_PROMPT="Audit the concern separation of this spec. The spec removes the 'legacy-task.md' file which has a routing/dispatch table that dispatches to 3 different handlers. The spec does not mention updating the routing table. Check for CS-ROUTING: missing routing table changes when a task file is removed."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
