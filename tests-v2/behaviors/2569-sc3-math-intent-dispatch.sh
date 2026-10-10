#!/bin/bash
# Behavioral test: 2569-sc3-math-intent-dispatch
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC under test (.opencode#2569 SC-3): given a developer request for explicit
# math-tool work, the main agent routes the work by dispatching to the
# math-ops subagent. The prompt names the math MCP explicitly (the spec's
# trigger phrasing) as a real-domain task so the dispatch decision is the
# agent's own, not an interview answer.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2569-sc3-math-intent-dispatch"
SCENARIO_PROMPT="Use the math MCP to calculate the standard deviation of 4, 8, 6, 5, 3, 9 and report the result."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
