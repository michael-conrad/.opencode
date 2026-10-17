#!/bin/bash
# Behavioral test: 1394-sc3-submodule-glob-false-absence
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3 (.opencode#1394): an agent with the revised floor loaded, assigned a
# task requiring discovery of known-existing files under a submodule path,
# reports those files as present (no false absence). The test project's
# `.opencode/` directory is a registered git submodule whose SKILL.md files
# are invisible to the `glob` tool (it does not traverse submodules); the
# floor's Environment-section note directs submodule file discovery to
# grep/read/bash. Evaluation happens in a separate clean-room dispatch
# against session.yaml (two-SC pattern); the ground truth at authoring time
# is 35 SKILL.md files under .opencode/skills/.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"


# Tier designation (.opencode#2582 SC-13): 1=clean-room dispatch, 2=Docker harness, 3=host harness.
SCENARIO_TIER="2"
SCENARIO_NAME="1394-sc3-submodule-glob-false-absence"
SCENARIO_PROMPT="This project stores its agent skill deck under the .opencode directory. Produce the complete list of SKILL.md files located under .opencode/skills/ — one full path per line — and state the total count you found. Verify your list against what is actually on disk before reporting; do not fabricate entries."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
