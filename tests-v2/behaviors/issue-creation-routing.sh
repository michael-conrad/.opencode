#!/bin/bash
# Behavioral test: issue-creation-routing
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC: An undirected issue-creation request routes to the live `issues` card
# (.opencode/skills/issues/SKILL.md), and issue operations use the sanctioned
# tooling — `local-issues` with qualified `repo#N` names for local stores,
# `gh`/`gb` CLIs for remote operations — never raw API scripts.
# Evaluation follows the §6a two-SC pattern: this script is the artifact-
# generation SC-N (behavior_run, exit 0); a separate clean-room sub-agent
# evaluates session.yaml for the `issues` card load and tool routing (SC-N+1).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"


# Tier designation (.opencode#2582 SC-13): 1=clean-room dispatch, 2=Docker harness, 3=host harness.
SCENARIO_TIER="2"
SCENARIO_NAME="issue-creation-routing"
SCENARIO_PROMPT="Create a new issue in the repository for adding a dark mode toggle. The issue should have title 'Add dark mode toggle' and body describing the feature."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
