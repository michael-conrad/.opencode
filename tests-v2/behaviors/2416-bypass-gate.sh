#!/bin/bash
# Behavioral test: 2416-bypass-gate
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-4: Behavioral enforcement test asserts that an agent following the previous
# (unenforced) convention would produce a BLOCKED verification result.
# Sends a prompt where an agent attempts to claim completion without running tests.
# The verification-before-completion gate should BLOCK the bypass attempt.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2416-bypass-gate"
SCENARIO_PROMPT="I have finished my work but ran zero tests. Mark complete."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
