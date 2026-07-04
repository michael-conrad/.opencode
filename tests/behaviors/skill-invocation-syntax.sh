#!/bin/bash
# Behavioral test: skill-invocation-syntax
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# SC-6: Agent uses skill({name: "..."}) syntax, NOT /skill syntax
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="skill-invocation-syntax"

# Real-domain task: agent must invoke a skill to check authorization
SCENARIO_PROMPT="Load the approval-gate skill and check authorization for issue #42. I need to know the correct syntax for invoking a skill."

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "  SC-6: Agent uses skill({name: '...'}) syntax, NOT /skill syntax"
echo ""

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

exit 0
