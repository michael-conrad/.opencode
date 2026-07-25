#!/bin/bash
# Behavioral test: 2142-sc6-tool-lookup-pattern
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-6: Verifies agent does NOT run `which`/`command -v` for `.opencode/tools/` tools
# when a skill description references a project-local tool path.
# Sends a real-domain task that should trigger skill dispatch for a tool
# that lives at .opencode/tools/solve.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2142-sc6-tool-lookup-pattern"
SCENARIO_PROMPT="I need to validate a dependency DAG for a workflow. Use the constraint solver tool to check whether the dependency ordering is correct."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
