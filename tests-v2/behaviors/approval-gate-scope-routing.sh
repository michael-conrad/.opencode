#!/bin/bash
# Behavioral test: approval-gate-scope-routing
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC: Scope verification, label application, revision revocation, and bug
# discovery operations MUST route to approval-gate-scope sub-skill.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="approval-gate-scope-routing"
SCENARIO_PROMPT="Check the authorization scope for issue #42. Verify whether the issue has been approved for implementation."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
