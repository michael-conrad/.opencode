#!/bin/bash
# Behavioral test: 1871-spec-correction-routing
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-5: Agent routes spec corrections to spec-creation --task change-control,
# not to issue-operations --task comment.
# Real-domain task: user asks to correct a spec, agent should route to spec-creation.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1871-spec-correction-routing"
SCENARIO_PROMPT="I need to correct the spec for issue #42 — the success criteria table is missing an evidence type column. Please update the spec body."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
