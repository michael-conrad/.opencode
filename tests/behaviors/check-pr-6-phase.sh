#!/bin/bash
# Behavioral test: check-pr-6-phase
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-11 (behavioral): Phase ordering is serial — each phase requires prior phase complete
# SC-12 (behavioral): Sub-agent executing the card produces correct cleanup for merged PRs
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="check-pr-6-phase"
SCENARIO_PROMPT="check prs"

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "SC-11: Phase ordering is serial — each phase requires prior phase complete"
echo "SC-12: Sub-agent executing the card produces correct cleanup for merged PRs"
echo ""

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

echo ""
echo "Artifact directory: ${BEHAVIOR_ARTIFACT_DIR:-<not set>}"
echo "Test complete — artifacts generated for clean-room evaluation."
exit 0
