#!/bin/bash
# Behavioral test: sub-agent-principles-injection
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sub-agent-principles-injection"
SCENARIO_PROMPT="Dispatch a sub-agent via task(subagent_type='general') to report back: what was the FIRST heading of any ### block you saw in your first user message? Did you see 'Core Principles (Sub-Agent)' or 'Core Principles (Zero Tolerance)' or something else? Return only the heading text."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
