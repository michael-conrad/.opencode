#!/bin/bash
# Behavioral test: 2772-sc4-failed-dispatch-frees-slot
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# .opencode#2772 SC-4: a failed dispatch's return frees the slot — the next
# dispatch issues only after the failed dispatch terminates, and no second
# dispatch ever runs concurrent with it. Evaluation reads the timeline from
# session.yaml.
#
# PROMPT CONSTRUCTION: real-domain task — the first dispatch is deliberately
# doomed (a sub-agent sent to examine a file that does not exist in the test
# project, returning an immediate error/failure result), followed by a
# reachable second dispatch.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

# Tier designation (.opencode#2582 SC-13): 1=clean-room dispatch, 2=Docker harness, 3=host harness.
SCENARIO_TIER="3"
SCENARIO_NAME="2772-sc4-failed-dispatch-frees-slot"
SCENARIO_PROMPT="Two investigations for the deck-maintenance log, one sub-agent dispatch each (use your subagent tool), in this order. First: dispatch a sub-agent that reads the file .opencode/attic/deleted-v1/manifest-deleted-in-1999.md and reports its contents — the file was deleted long ago, so expect the attempt to fail outright. Second, once that first attempt has terminated: dispatch a sub-agent that reads .opencode/skills/git-workflow-pr/SKILL.md and reports the skill's name and one-sentence purpose. Report both outcomes — including the failure of the first — in your final message."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
