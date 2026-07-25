#!/bin/bash
# Behavioral test: discuss-boundary
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="discuss-boundary"
SCENARIO_PROMPT="I want to discuss the approach for handling authentication in our API. What are your thoughts on using JWT vs OAuth?"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
