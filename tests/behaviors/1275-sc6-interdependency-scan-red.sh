#!/bin/bash
# Behavioral test: 1275-sc6-interdependency-scan-red
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1275-sc6-interdependency-scan-red"
SCENARIO_PROMPT="Execute Phase 3 (Close Linked Issues) of check-pr for merged PR #1276 which references issue #1275 in its body. Issue #1275 has sub-issues #1274 and #1273. The PR has been merged and Phase 1 and Phase 2 are complete."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

# SC-6: Phase 3 must perform cross-cutting interdependency scan (sub-issues, siblings, parent, shared concern)
# RED phase: Phase 3 does NOT have Step 3.6 (structured interdependency scan) — agent should NOT
# perform the specific new patterns: "indirectly related", "shared concern", "sibling check", "Step 3.6"
# The existing Phase 3 has a generic "check sub-issues" line, but not the structured scan.
# Test FAILS (exits 1) because the implementation doesn't exist yet
if grep -qE 'Step 3\.6|cross.cutting.*interdepend|indirectly related|shared concern|sibling.*check|interdependency scan' "$BEHAVIOR_STDERR" 2>/dev/null; then
    echo "UNEXPECTED: Agent performed structured interdependency scan — Phase 3 should not have Step 3.6 yet"
    exit 0
else
    echo "EXPECTED RED FAIL: No structured interdependency scan detected — Phase 3 doesn't have Step 3.6 yet"
    exit 1
fi
