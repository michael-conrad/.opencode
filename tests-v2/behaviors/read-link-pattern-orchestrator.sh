#!/bin/bash
# Behavioral test: read-link-pattern-orchestrator
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# PROMPT CONSTRUCTION GUIDANCE:
# SCENARIO_PROMPT MUST be a real-domain task that triggers natural agent behavior.
# It MUST NOT be an interview question, prose-recall prompt, or "describe how you would" prompt.
# See .opencode/tests-v2/AGENTS.md §9 Prompt Construction Mandate for the full specification.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="read-link-pattern-orchestrator"
SCENARIO_PROMPT="A developer said 'yes, looks good' to your proposal. What do you do?"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
