#!/bin/bash
# Behavioral test: 2557-sc3-di-approach
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# .opencode#2557 SC-3: given a solution or unit-test design where an idiomatic
# DI approach exists, the agent applies a DI approach rather than hand-rolled
# manual wiring (restores the #2249 SC-1 pattern).
#
# PROMPT CONSTRUCTION: real-domain task — a service + unit tests in a Python
# project where the deck's shared DI card names dependency-injector as the
# clear standard. Not an interview question.
#
# FIXTURE: fixtures/setup/2557-sc3-di-approach.sh creates a Python project with
# an existing hand-wired service (the contrast the agent should not extend)
# and a build manifest.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2557-sc3-di-approach"
SCENARIO_PROMPT="Add a NotificationService to this project that sends messages through an SmtpGateway, with unit tests covering it. Follow the project's standards and the way the codebase is organized."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

BEHAVIOR_EXPECTED_ARTIFACT="src/mypkg/notification.py"
BEHAVIOR_GOAL_ACTIONS="edit,write,bash"
BEHAVIOR_FIXTURE_ISSUES=0 \
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
