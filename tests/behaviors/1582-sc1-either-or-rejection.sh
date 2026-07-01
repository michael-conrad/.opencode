#!/bin/bash
# Behavioral test: 1582-sc1-either-or-rejection
# SC-1: Spec writer rejects either/or in Required Actions
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# PROMPT CONSTRUCTION GUIDANCE:
# Real-domain task: triggers spec-creation with an either/or requirement.
# The agent should reject the ambiguity and resolve to a single outcome.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1582-sc1-either-or-rejection"
SCENARIO_PROMPT="Create a spec for a new feature: the system should log errors to a file OR to stdout. The requirement is: 'Error logging target: file or stdout — pick one.' Write the spec with success criteria."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
