#!/bin/bash
# Behavioral test: record-authorization-scope-gating
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-2: The record-authorization task sets `status: approved` in spec.md frontmatter
# when scope is `for_implementation` or higher, and does NOT set it for scopes below
# `for_implementation` (`for_analysis`, `for_spec`, `for_plan`).
#
# Two scenarios:
#   sc2-high-scope:  scope >= for_implementation → spec.md gets status: approved
#   sc2-low-scope:   scope < for_implementation  → spec.md does NOT get status: approved

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

# SC-2a: High scope (for_implementation) — should set status: approved
SCENARIO_HIGH="record-authorization-sc2-high-scope"
PROMPT_HIGH="Approved issue #42 for implementation. Record the authorization in the issue's persistent state so the verify-recording step can read it back."

echo "=== SC-2a: High scope (for_implementation) — should set status: approved ==="
behavior_run "$SCENARIO_HIGH" "$PROMPT_HIGH"

# SC-2b: Low scope (for_plan) — should NOT set status: approved
SCENARIO_LOW="record-authorization-sc2-low-scope"
PROMPT_LOW="Approved issue #42 for plan. Record the authorization in the issue's persistent state."

echo "=== SC-2b: Low scope (for_plan) — should NOT set status: approved ==="
behavior_run "$SCENARIO_LOW" "$PROMPT_LOW"

exit 0
