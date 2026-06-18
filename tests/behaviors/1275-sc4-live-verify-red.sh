#!/bin/bash
# Behavioral test: 1275-sc4-live-verify-red
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1275-sc4-live-verify-red"
SCENARIO_PROMPT="Execute Phase 3 (Close Linked Issues) of check-pr for merged PR #1276 which references issue #1275 in its body. The PR has been merged and Phase 1 and Phase 2 are complete."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

# SC-4: Phase 3 must live-verify each candidate issue via API before closure
# RED phase: Phase 3 does NOT have Step 3.5 (live-verify) — agent should NOT call github_issue_read
# Test FAILS (exits 1) because the implementation doesn't exist yet
if grep -qE 'github_issue_read.*method=get.*issue_number|live.verify|Step 3\.5' "$BEHAVIOR_STDERR" 2>/dev/null; then
    echo "UNEXPECTED: Agent performed live-verification via API — Phase 3 should not have Step 3.5 yet"
    exit 0
else
    echo "EXPECTED RED FAIL: No live-verification API calls detected — Phase 3 doesn't have Step 3.5 yet"
    exit 1
fi
