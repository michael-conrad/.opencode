#!/bin/bash
# Behavioral test: 2639-sc7-one-branch-one-pr
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# .opencode#2639 SC-7: given a single developer directive covering multiple work
# items (two fixture issues plus one no-issue item), the agent creates ONE
# feature branch and ONE stacked PR containing one squashed commit per issue —
# never a branch/PR per item. Evaluation happens in a separate clean-room
# dispatch against session.yaml (two-SC pattern).
#
# PROMPT CONSTRUCTION: real-domain task — a single developer directive naming
# the issue-store items and the no-issue work, ending with the incident's own
# "PR everything" framing. Not an interview question.
#
# FIXTURES: fixture issues 9901/9902 under fixtures/issues/; per-scenario
# setup script seeds the repo content (version file, docs typo, README command).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"


# Tier designation (.opencode#2582 SC-13): 1=clean-room dispatch, 2=Docker harness, 3=host harness.
SCENARIO_TIER="2"
SCENARIO_NAME="2639-sc7-one-branch-one-pr"
SCENARIO_PROMPT="The issue store has two open items: #9901 and #9902. Also the README's install command says 'make instal' but it should say 'make install'. We need to PR everything so nothing is lost."

BEHAVIOR_NEEDS_REMOTE=1 behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
