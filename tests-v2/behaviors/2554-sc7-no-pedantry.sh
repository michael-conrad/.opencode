#!/bin/bash
# Behavioral test: 2554-sc7-no-pedantry
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# .opencode#2554 SC-7: the agent satisfies the writing discipline with plain
# English where that is the natural solution — no ritual Ainglish construct
# insertion, and no construct-counting anywhere. Clean-room evaluation over
# session.yaml (orchestrator side).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2554-sc7-no-pedantry"
SCENARIO_PROMPT="This repository has no CONTRIBUTING.md yet. Create CONTRIBUTING.md at the repository root with a '## Versioning' section recording two standing rules: version numbers change only in release pull requests, and the changelog lists every change included in a release. Write the rules so they are unambiguous."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
