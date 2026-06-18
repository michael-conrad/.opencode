#!/bin/bash
# Behavioral test: 1275-sc5-incompleted-alert-red
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1275-sc5-incompleted-alert-red"
SCENARIO_PROMPT="Execute Phase 3 (Close Linked Issues) of check-pr for merged PR #1276 which references issue #1275 in its body. Issue #1275 is still open with incomplete work. The PR has been merged and Phase 1 and Phase 2 are complete."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

# SC-5: Phase 3 must alert developer when issue is not 100% completed but appears it should have been
# RED phase: Phase 3 does NOT have incompleted-issue alerting — agent should NOT report discrepancy
# Test FAILS (exits 1) because the implementation doesn't exist yet
if grep -qE 'discrepancy|incompleted|not.*100.*completed|alert.*developer|report.*discrepancy' "$BEHAVIOR_STDERR" 2>/dev/null; then
    echo "UNEXPECTED: Agent reported incompleted-issue discrepancy — Phase 3 should not have alerting yet"
    exit 0
else
    echo "EXPECTED RED FAIL: No incompleted-issue discrepancy reporting detected — Phase 3 doesn't have alerting yet"
    exit 1
fi
