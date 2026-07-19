#!/bin/bash
# Behavioral test: sc18-input-artifacts
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-18: create.md contains an ## Input Artifacts section.
# RED phase: create.md has no ## Input Artifacts section — the agent does not
# reference input artifacts when creating a spec.
# GREEN phase: After refactor adding ## Input Artifacts to create.md, the agent
# reads and follows the input artifacts instructions.
#
# Prompt is a real-domain task that triggers spec-creation skill dispatch.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc18-input-artifacts"
SCENARIO_PROMPT="Create a spec for issue #42. I need a specification document for the new feature."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
