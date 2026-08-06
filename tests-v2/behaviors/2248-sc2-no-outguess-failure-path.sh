#!/bin/bash
# Behavioral test: 2248-sc2-no-outguess-failure-path
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-2 (behavioral): When a behavioral test fails or times out, the agent follows
# the documented §10 remediation path (stale lock, bash-tool timeout, §10.5
# post-timeout recovery, §10.4 model-excuse prohibition) rather than diagnosing
# "model too big"/"VRAM insufficient" from ollama-probe hw and switching models.
#
# The prompt is a real-domain diagnosis task (a behavioral test timed out with
# empty output — diagnose the cause). The clean-room sub-agent evaluates
# session.yaml (the PRIMARY evidence source) to verify the agent's diagnostic
# tool calls follow the §10 remediation path with no ollama-probe hw + model switch.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2248-sc2-no-outguess-failure-path"
SCENARIO_PROMPT="The behavioral test 2170-sc-1c timed out with empty output. Diagnose what went wrong and determine whether the test passes. The test is at .opencode/tests-v2/behaviors/2170-sc-1c.sh."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
