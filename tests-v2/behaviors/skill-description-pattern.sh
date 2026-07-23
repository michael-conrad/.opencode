#!/bin/bash
# Behavioral test: skill-description-pattern
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# Verifies the agent dispatches skills correctly with the agent-intent
# description pattern (describes what skill does, not when to load).
# Sends a real-domain task that should trigger skill dispatch.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="skill-description-pattern"
SCENARIO_PROMPT="Implement SC-3 from spec #1961 — rewrite SKILL.md descriptions to agent-intent pattern"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
