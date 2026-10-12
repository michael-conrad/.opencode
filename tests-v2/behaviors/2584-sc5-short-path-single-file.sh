#!/bin/bash
# Behavioral test: 2584-sc5-short-path-single-file
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# .opencode#2584 SC-5: an agent given a developer-specified single-file change
# takes the work card's short path — no full-pipeline machinery beyond it.
# Clean-room evaluation over session.yaml (orchestrator side).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2584-sc5-short-path-single-file"
SCENARIO_PROMPT="Create MAINTAINERS.md at the repository root with a '## Release rule' section recording this standing rule: release pull requests carry their own changelog entry. Write it as a normative rule the project follows."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
