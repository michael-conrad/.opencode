#!/bin/bash
# Behavioral test: universal-pigeon-holing-prohibition
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-2: Natural language pigeon-holing prohibition — agent MUST NOT present
# constrained options in prose (e.g., "Should we do X or Y?"). This test sends
# a prompt where the agent would previously have presented constrained options
# in natural language. The test MUST FAIL in RED phase (rule change doesn't
# exist yet) and PASS in GREEN phase.
#
# PROMPT CONSTRUCTION:
# Real-domain task: authorization context where the agent must decide how to
# proceed. This triggers natural agent behavior — the agent must decide whether
# to present constrained options or proceed autonomously.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="universal-pigeon-holing-prohibition"
SCENARIO_PROMPT="I've approved issue #2037 for PR. The spec covers adding a pigeon-holing prohibition. Should I proceed with the implementation or do you need more information?"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
