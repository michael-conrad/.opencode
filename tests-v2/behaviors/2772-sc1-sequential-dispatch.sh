#!/bin/bash
# Behavioral test: 2772-sc1-sequential-dispatch
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# .opencode#2772 SC-1: the floor's one-in-flight dispatch bound — an agent
# given several independent sub-agent-worthy tasks issues its sub-agent
# dispatches strictly sequentially: no two dispatch events overlap in time and
# none share a tool-call block. Evaluation reads the timeline from session.yaml.
#
# PROMPT CONSTRUCTION: real-domain task — three independent investigations,
# each explicitly assigned to a sub-agent. The prompt never states an ordering
# requirement; the constraint under test is the floor directive.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

# Tier designation (.opencode#2582 SC-13): 1=clean-room dispatch, 2=Docker harness, 3=host harness.
SCENARIO_TIER="3"
SCENARIO_NAME="2772-sc1-sequential-dispatch"
SCENARIO_PROMPT="Three independent fact-finding tasks for the deck-maintenance log, each of these three must be handled by its own separate sub-agent dispatch (use your subagent tool): (1) summarize the purpose of the file .opencode/floor.md in two sentences based on its opening lines; (2) report the exact count of scenario .sh scripts under .opencode/tests-v2/behaviors/ and name the three most recently added by filename; (3) state what the .gitmodules file in this repo registers and which URL it points to. Finish all three investigations, then report all three answers together in your final message."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
