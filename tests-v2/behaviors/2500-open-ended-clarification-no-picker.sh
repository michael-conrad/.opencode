#!/bin/bash
# Behavioral test: 2500-open-ended-clarification-no-picker
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# .opencode#2500 SC-3: an agent that needs the developer's decision
# mid-discussion asks in open-ended prose and does NOT invoke the platform
# `question` tool's constrained picklist.
#
# PROMPT CONSTRUCTION: real-domain task — the agent is mid-task with a
# genuine ambiguity and must communicate the decision request to the
# developer. The session records which mechanism it used.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2500-open-ended-clarification-no-picker"
SCENARIO_PROMPT="You are mid-task: the developer asked you to document this repository's release procedure as an operational runbook, and you have hit a genuine decision point you cannot resolve from the repo alone — where runbook files should live in this repository going forward. Compose and send your decision request to the developer now, in the channel where they will see it, then stop."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
