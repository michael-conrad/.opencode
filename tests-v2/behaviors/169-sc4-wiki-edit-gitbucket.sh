#!/bin/bash
# Behavioral test: 169-sc4-wiki-edit-gitbucket
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-4 (.opencode#169): an agent session equipped with the wiki-operations card
# set and generic tools performs a correct wiki edit on the GitBucket wiki
# provisioned by the harness (BEHAVIOR_NEEDS_REMOTE=1). Evaluation happens in a
# separate clean-room dispatch against session.yaml (two-SC pattern).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="169-sc4-wiki-edit-gitbucket"
SCENARIO_PROMPT="This project's documentation lives in its wiki. Add a wiki page named 'Development Setup' that documents how to get the project building locally (clone, install the toolchain, run the build), and make sure the page is reachable from the wiki sidebar navigation."

BEHAVIOR_NEEDS_REMOTE=1 behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
