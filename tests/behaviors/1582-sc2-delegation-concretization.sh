#!/bin/bash
# Behavioral test: 1582-sc2-delegation-concretization
# SC-2: Spec writer requires concrete delegation targets
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# PROMPT CONSTRUCTION GUIDANCE:
# Real-domain task: triggers spec-creation with a vague "delegate to" reference.
# The agent should require concrete file changes, routing updates, and capability migration.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1582-sc2-delegation-concretization"
SCENARIO_PROMPT="Create a spec that delegates the user authentication module to a new centralized auth service. The requirement says: 'Delegate login, logout, and session management to the auth service.' Write the spec with concrete file changes, routing table updates, and capability migration details."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
