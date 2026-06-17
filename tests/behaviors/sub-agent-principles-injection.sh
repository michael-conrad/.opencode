#!/bin/bash
# Behavioral test: sub-agent-principles-injection
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sub-agent-principles-injection"
SCENARIO_PROMPT="You are a sub-agent tasked with reading a file. Read .opencode/AGENTS.md and report its first line."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
