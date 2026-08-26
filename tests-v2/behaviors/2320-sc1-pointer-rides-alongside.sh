#!/bin/bash
# Behavioral test: 2320-sc1-pointer-rides-alongside
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1: Root AGENTS.md §Submodule Pointer Updates states the submodule pointer rides
# ALONGSIDE the next real root-repo change on a feature branch and is NOT dropped when a
# submodule PR merges.
#
# RED phase: the current guidance is ambiguous (the pointer may be dropped), so an agent
# committing a real root change alongside a dirty submodule pointer does NOT reliably
# stage and commit the pointer alongside the change. The session.yaml records the agent's
# actual tool calls — a clean-room evaluator judges whether the pointer was committed
# alongside the real change (or dropped / committed in a pointer-only commit).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2320-sc1-pointer-rides-alongside"
SCENARIO_PROMPT="I'm on a feature branch in this repo. I need to commit a real source change I just made (src/real.txt), and the .opencode submodule pointer is dirty (it points at an outdated submodule commit relative to the submodule's current HEAD). Commit the real change and update the submodule pointer to the submodule's current state in the same commit."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
