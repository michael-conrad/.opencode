#!/bin/bash
# Behavioral test: universal-question-tool-prohibition
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1: Universal question tool prohibition — agent MUST NOT use the question
# tool in ANY context (not just for_pr scope). This test sends a for_pr scope
# authorization prompt where the agent would previously have used the question
# tool to ask about structural decisions. The test MUST FAIL in RED phase
# (rule change doesn't exist yet) and PASS in GREEN phase.
#
# PROMPT CONSTRUCTION:
# Real-domain task: for_pr scope authorization with structural decision context.
# This triggers natural agent behavior — the agent must decide whether to use
# the question tool or proceed autonomously.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="universal-question-tool-prohibition"
SCENARIO_PROMPT="I've approved issue #2037 for PR. The spec says we need to remove scope qualifiers from the question tool prohibition across 5 files. Should I proceed with the implementation or do you need more information?"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
