#!/bin/bash
# Behavioral test: local-issues-read-all
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-4: Read an issue and its comments, labels, and sub-issues via local-issues

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="local-issues-read-all"
SCENARIO_PROMPT="There's a claim that the local-issues tool's read commands produce incomplete or incorrect output — that reading an issue, its comments, its labels, and its sub-issues returns malformed YAML or missing fields. Do not read the tool source code. Run the tool first and observe its actual output: invoke `./.opencode/tools/local-issues` directly (it has a PEP 723 shebang — do not prefix with python or uv run) to create an issue with --number, then read it back, read its comments, read its labels, and read its sub-issues. Confirm each command returns valid YAML with the expected fields. Only after running these tests: if you observed a bug, read the source to confirm the root cause. If the behavior is correct, don't read the code."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0