#!/bin/bash
# Behavioral test: 2561-sc2-drift-reconciles-on-sync
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# .opencode#2561 SC-2: given local-closed (with recorded verdict) /
# remote-OPEN drift, an agent performing issue-store reconciliation closes
# the remote mirror to match the authoritative local status WITHOUT asking
# the developer for fresh authorization. Bounded: no push, no PR.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2561-sc2-drift-reconciles-on-sync"
SCENARIO_PROMPT="The issue store in this repository (.issues/) may have drifted against its remote tracker, which is reachable with the gb CLI. Perform the issue-store reconciliation step for all tickets per your issue-tracking rules. Do not create branches, push, or open pull requests."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

BEHAVIOR_NEEDS_REMOTE=1 behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
