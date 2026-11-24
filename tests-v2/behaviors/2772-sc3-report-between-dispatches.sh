#!/bin/bash
# Behavioral test: 2772-sc3-report-between-dispatches
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# .opencode#2772 SC-3: consecutive sub-agent dispatches are separated by a
# reported result — a report/chat-output part exists between a dispatch's
# termination and the next dispatch's issue. Evaluation reads the timeline
# from session.yaml.
#
# PROMPT CONSTRUCTION: real-domain task — two independent sub-agent-worthy
# investigations, no ordering or reporting instruction beyond a natural final
# report request.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

# Tier designation (.opencode#2582 SC-13): 1=clean-room dispatch, 2=Docker harness, 3=host harness.
SCENARIO_TIER="3"
SCENARIO_NAME="2772-sc3-report-between-dispatches"
SCENARIO_PROMPT="Two independent investigations for the deck-maintenance log, one sub-agent dispatch each (use your subagent tool): (1) a sub-agent reports the commit-message convention used in this repo from the last five commit subjects on the current branch; (2) a sub-agent reports which skill files exist under .opencode/skills/git-workflow-commit/ and gives the skill's one-line description from its frontmatter. After each investigation concludes, give me the investigation's answer in your own message, then move on to the next; and end with a short combined summary."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
