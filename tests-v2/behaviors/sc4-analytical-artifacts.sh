#!/bin/bash
# Behavioral test: sc4-analytical-artifacts
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-4: analytical-artifacts.md contains no orchestrator-level instructions
# (no 'orchestrator dispatches', no '(*orchestrator*)').
#
# RED phase: This test MUST FAIL because analytical-artifacts.md currently
# contains orchestrator dispatches and (*orchestrator*) labels. When the agent
# processes a spec-creation request, it reads analytical-artifacts.md and
# encounters orchestrator-level instructions that a task card must not contain.
# The agent's response will show it either dispatching from a task card or
# following orchestrator-level instructions embedded in the task card —
# both violate SC-4.
#
# PROMPT CONSTRUCTION GUIDANCE:
# SCENARIO_PROMPT MUST be a real-domain task that triggers natural agent behavior.
# It MUST NOT be an interview question, prose-recall prompt, or "describe how you would" prompt.
# See .opencode/tests-v2/AGENTS.md §9 Prompt Construction Mandate for the full specification.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc4-analytical-artifacts"
SCENARIO_PROMPT="Create a spec for issue #42. The issue is about adding a new search feature to the API."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
