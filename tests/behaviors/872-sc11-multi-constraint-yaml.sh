#!/bin/bash
# Behavioral test: 872-sc11-multi-constraint-yaml
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-11: Multi-constraint YAML parsing test — solve tool should parse
# YAML files with multiple constraints. RED phase: No solve tool exists yet.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="872-sc11-multi-constraint-yaml"
SCENARIO_PROMPT="Run the solve tool with --file that contains multiple constraints in YAML format to verify proper multi-constraint parsing"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
