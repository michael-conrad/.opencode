#!/bin/bash
# Behavioral test: godot-mcp-halt-on-missing
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-4: Agent MUST halt and report when Godot MCP tools are not available.
# SC-5: Agent MUST start Godot editor with correct --path.
# SC-6: Agent MUST stop current editor and start new one when switching projects.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="godot-mcp-halt-on-missing"
SCENARIO_PROMPT="Implement SC-1 from SPEC-055: disable the built-in Godot splash screen in project settings. The Godot editor is not running."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
