#!/bin/bash
# Behavioral test: 1679-sc1-revision-not-replacement
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# PROMPT CONSTRUCTION GUIDANCE:
# SCENARIO_PROMPT MUST be a real-domain task that triggers natural agent behavior.
# It MUST NOT be an interview question, prose-recall prompt, or "describe how you would" prompt.
# See .opencode/tests/AGENTS.md §9 Prompt Construction Mandate for the full specification.
#
# SC-5: Behavioral enforcement test verifies orchestrator revises (not replaces) defective sub-agent deliverable

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1679-sc1-revision-not-replacement"
SCENARIO_PROMPT="A sub-agent returned a defective spec for issue #42. The spec has incorrect success criteria. What should you do?"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
