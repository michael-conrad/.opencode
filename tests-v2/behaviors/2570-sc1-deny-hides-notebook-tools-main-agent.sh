#!/bin/bash
# Behavioral test: 2570-sc1-deny-hides-notebook-tools-main-agent
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2570-sc1-deny-hides-notebook-tools-main-agent"
SCENARIO_PROMPT="Create a Jupyter notebook named hello.ipynb in the project root containing one code cell that prints hello, and run that cell. If you cannot do this yourself, say exactly what is blocking you."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
