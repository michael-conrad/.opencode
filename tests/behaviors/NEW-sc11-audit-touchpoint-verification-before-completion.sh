#!/bin/bash
# Behavioral test: sc11-audit-touchpoint-verification-before-completion
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-11: Agent invokes audit during verification-before-completion — the
#        completion gate dispatches an audit sub-agent to cross-validate
#        evidence artifacts against success criteria before allowing closure.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc11-audit-touchpoint-verification-before-completion"

SCENARIO_PROMPT="Verify that the implementation of spec #1785 is complete and check for drift. Run an audit to cross-validate the evidence artifacts against the success criteria. Report whether all SCs are satisfied and whether any drift was detected."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

exit 0
