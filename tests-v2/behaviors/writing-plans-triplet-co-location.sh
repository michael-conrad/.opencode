#!/bin/bash
# Behavioral test: writing-plans-triplet-co-location
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1: structure.md rejects phase decomposition where any SC's RED and GREEN
# are in different phases.
#
# RED phase: structure.md does NOT have triplet co-location validation yet.
# Expected to FAIL (non-zero exit) because the structure task will not reject
# split SCs — the BLOCKED signal will be absent from stderr.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="writing-plans-triplet-co-location"
SCENARIO_PROMPT="Create an implementation plan for issue #2081 using the writing-plans skill. The spec has SC-1 and SC-2 that must be in the same phase because SC-2 depends on SC-1's output. Do not split SC-1's RED and GREEN across different phases."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

# RED phase check: structure task should reject split SCs with BLOCKED.
# In RED phase (feature doesn't exist yet), BLOCKED will NOT appear → exit 1.
# In GREEN phase (feature exists), BLOCKED WILL appear → exit 0.
if grep -q 'BLOCKED' "$BEHAVIOR_STDERR" 2>/dev/null; then
    echo "UNEXPECTED PASS: structure.md rejected split SCs (BLOCKED found in stderr)"
    exit 0
else
    echo "EXPECTED FAIL: structure.md did not reject split SCs (BLOCKED not found in stderr - RED phase confirmed)"
    exit 1
fi
