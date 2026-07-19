#!/bin/bash
# Behavioral test: sc17-result-contract
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-17: create.md contains a ## Result Contract section.
#
# RED phase: create.md has no ## Result Contract section — the agent
# dispatches spec-creation without a result contract in the create task.
# GREEN phase: After adding ## Result Contract to create.md, the agent
# produces a result contract when creating a spec.
#
# Prompt is a real-domain task that triggers spec-creation skill dispatch.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc17-result-contract"
SCENARIO_PROMPT="Create a spec for issue #42. I need a specification document for the new feature."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
