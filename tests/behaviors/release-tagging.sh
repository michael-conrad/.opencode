#!/bin/bash
# Behavioral test: release-tagging
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# SC-24: release-promoter creates annotated tag with v prefix

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="release-tagging"
SCENARIO_PROMPT="tag and create a release for v1.2.3"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
