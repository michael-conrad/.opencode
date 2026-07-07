#!/bin/bash
# Behavioral test: 1777-sc4-micro-management-admonishment
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-4: Behavioral test exists verifying that spec-creation agent includes the
# micro-management prohibition admonishment in generated specs.
#
# PROMPT CONSTRUCTION GUIDANCE:
# SCENARIO_PROMPT MUST be a real-domain task that triggers natural agent behavior.
# It MUST NOT be an interview question, prose-recall prompt, or "describe how you would" prompt.
# See .opencode/tests/AGENTS.md §9 Prompt Construction Mandate for the full specification.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1777-sc4-micro-management-admonishment"
SCENARIO_PROMPT="Create a spec for adding a new validation function to the existing MeshValidator class. The function should validate that all mesh vertices have positive coordinates."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
