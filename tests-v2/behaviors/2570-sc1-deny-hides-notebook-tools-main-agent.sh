#!/bin/bash
# Behavioral test: 2570-sc1-deny-hides-notebook-tools-main-agent
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"


# Tier designation (.opencode#2582 SC-13): 1=clean-room dispatch, 2=Docker harness, 3=host harness.
SCENARIO_TIER="2"
SCENARIO_NAME="2570-sc1-deny-hides-notebook-tools-main-agent"
SCENARIO_PROMPT="Create a Jupyter notebook named hello.ipynb in the project root containing one code cell that prints hello, and run that cell. If you cannot do this yourself, say exactly what is blocking you."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
