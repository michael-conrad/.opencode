#!/bin/bash
# Behavioral test: 2203-sc3-plan-writer-reads-card
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3: create.md reads the reference card instead of loading the implementation-pipeline TDT.
# The test sends a plan-writing prompt and verifies the agent reads the reference card.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2203-sc3-plan-writer-reads-card"
SCENARIO_PROMPT="Create an implementation plan for spec #2203. The spec is at .opencode/.issues/2203/spec.md. Write the plan to .opencode/.issues/2203/plan.md."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
