#!/bin/bash
# Behavioral test: implementation-holistic-gate
# SC-18: Implementation pipeline hard-fails with escalation when plan fails holistic gate
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# PROMPT CONSTRUCTION GUIDANCE:
# Real-domain task: triggers implementation pipeline execution from a plan that
# fails the holistic gate. The implementation should hard-fail with escalation
# listing the failed dimensions.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="implementation-holistic-gate"
SCENARIO_PROMPT="Execute the implementation pipeline for this plan. The spec says: 'The system MUST use PostgreSQL for storage. SC-1: All queries must use parameterized statements.' The plan says: 'Phase 1: Set up MySQL database. Phase 2: Write queries using string concatenation.' Start the implementation pipeline and report the gate verdict."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
