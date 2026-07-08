#!/bin/bash
# Behavioral test: sc10-audit-touchpoint-implementation-pipeline
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-10: Agent invokes audit during implementation pipeline execution — the
#        pipeline dispatches an audit sub-agent at the coherence gate to verify
#        spec fidelity before RED/GREEN sub-agents begin work.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc10-audit-touchpoint-implementation-pipeline"

SCENARIO_PROMPT="Execute the implementation plan for spec #1785 starting with the coherence gate. Run an audit to verify the plan is coherent with the spec before dispatching any RED/GREEN sub-agents. Report the audit findings."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

exit 0
