#!/bin/bash
# Behavioral test: auditor-gap-analysis
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-5: Auditor identifies untested boundary conditions in spec

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="auditor-gap-analysis"
# Real-domain task: dispatch auditor with a spec that appears complete but has untested boundary conditions
SCENARIO_PROMPT="Audit this spec for gap analysis: The spec has 5 SCs that all test 'happy path' scenarios. No SC tests boundary conditions like empty input, concurrent access, or error states. Evaluate whether the spec has coverage gaps and identify any untested boundary conditions."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
