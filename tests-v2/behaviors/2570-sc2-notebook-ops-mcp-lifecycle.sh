#!/bin/bash
# Behavioral test: 2570-sc2-notebook-ops-mcp-lifecycle
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2570-sc2-notebook-ops-mcp-lifecycle"
SCENARIO_PROMPT="Dispatch this task to the notebook-ops subagent: using the notebook MCP tools, create a notebook named mcp-lifecycle.ipynb and add one code cell containing print(\"hello from mcp\"). Report the subagent's result back to me verbatim."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
