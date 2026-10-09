#!/bin/bash
# Behavioral test: 2557-sc4-di-tier-selection
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# .opencode#2557 SC-4: the agent selects the DI approach per the tier table and
# selection guidance — driven by code analysis and spec requirements, not a
# fixed pin — and combinations are allowed where the table documents two or
# more idiomatic options for the language.
#
# PROMPT CONSTRUCTION: real-domain task — a service + unit tests in a
# TypeScript project (Contested tier: tsyringe/InversifyJS both idiomatic).
# The clean-room evaluation confirms the selection is tier-guided (an idiomatic
# option per the shared table, chosen for the code's needs) rather than
# hand-rolled wiring or an arbitrary pin.
#
# FIXTURE: fixtures/setup/2557-sc4-di-tier-selection.sh creates a TypeScript
# project with an existing service and a build manifest.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2557-sc4-di-tier-selection"
SCENARIO_PROMPT="Add an OrderService to this TypeScript project that depends on a PaymentGateway for charging, with unit tests covering the service. Follow the project's standards."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

BEHAVIOR_GOAL_ACTIONS="edit,write,bash"
BEHAVIOR_FIXTURE_ISSUES=0 \
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
