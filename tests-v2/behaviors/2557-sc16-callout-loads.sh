#!/bin/bash
# Behavioral test: 2557-sc16-callout-loads
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# .opencode#2557 SC-16: when a task touches a language, tool, or engineering-
# practice concern whose card exists, the agent loads that card via the
# pipeline call outs BEFORE the first code modification of the task —
# session.yaml shows the language/tool cards and `programming-principles`
# loaded before any code is written.
#
# PROMPT CONSTRUCTION: real-domain task — a Python utility module + unit
# tests. The pipeline call outs (spec/plan/implement) direct the loads; the
# clean-room evaluation checks event ordering in session.yaml.
#
# FIXTURE: fixtures/setup/2557-sc16-callout-loads.sh creates a Python project
# with a build manifest.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2557-sc16-callout-loads"
SCENARIO_PROMPT="Add a rate limiter utility module to this project — a token-bucket implementation with unit tests. Follow the project's standards."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

BEHAVIOR_GOAL_ACTIONS="edit,write,bash"
BEHAVIOR_FIXTURE_ISSUES=0 \
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
