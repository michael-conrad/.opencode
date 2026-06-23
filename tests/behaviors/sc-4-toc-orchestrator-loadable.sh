#!/bin/bash
# Behavioral test: sc-4-toc-orchestrator-loadable
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc-4-toc-orchestrator-loadable"
SCENARIO_PROMPT="Read .issues/1346/plan.md and list all phases with their concerns. Do NOT open any plan-phase-N.md files."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
