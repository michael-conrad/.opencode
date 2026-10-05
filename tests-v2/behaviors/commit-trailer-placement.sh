#!/bin/bash
# Behavioral test: commit-trailer-placement
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# Scenario: co-author trailer placement — intermediate implementation/WIP
# commits carry no co-author trailers; the final squashed commit carries the
# dual trailers (AI + human) per the attribution conventions (retained as a
# non-goal under .opencode#2490).
#
# Evidence basis: the pre-rip deck carried contradictory trailer guidance
# across sources (recorded in the deck history); this probe exercises the
# reconciled convention under the current deck.
# export) is the PRIMARY evidence source — a clean-room sub-agent evaluates whether
# the agent added trailers to the implementation commit and whether it added dual
# trailers to the squashed commit.
#
# PROMPT CONSTRUCTION:
# Real-domain task: perform an implementation commit for a feature, then prepare the
# squash commit for PR creation. The prompt does NOT name the trailer rule, the
# contradictory sources, or the expected trailer behavior — it is a natural commit
# workflow dispatch. Natural behavior, NOT a prose-recall interview.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="commit-trailer-placement"
SCENARIO_PROMPT="I'm on a feature branch in this repo. I just finished implementing a small feature (src/feature.txt was added). Make an implementation commit for this work following the git-workflow-commit implementation procedure. Then prepare the squash commit message for PR creation following the git-workflow-commit commit-prep procedure. Report the commit message and any co-author trailers you would include for each commit."

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "SC-1a: no co-author trailers on implementation commits"
echo "SC-1b: dual co-author trailers (AI + human) on the squashed commit"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
