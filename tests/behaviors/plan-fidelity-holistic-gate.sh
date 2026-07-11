#!/bin/bash
# Behavioral test: plan-fidelity-holistic-gate
# SC-14, SC-20: Plan-fidelity auditor hard-fails on broken/escape-hatch plans
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# PROMPT CONSTRUCTION GUIDANCE:
# Real-domain task: triggers plan-fidelity audit on plans with holistic gate defects.
# The auditor should hard-fail with escalation for broken plans and FAIL on
# Escape Hatches for plans with escape hatch language.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="plan-fidelity-holistic-gate"

# Test 1: Broken plan — plan-fidelity hard-fails with escalation
SCENARIO_PROMPT='Check the fidelity of this plan against its spec. The spec says: "The system MUST use PostgreSQL for storage. SC-1: All queries must use parameterized statements." The plan says: "Phase 1: Set up MySQL database. Phase 2: Write queries using string concatenation." Check plan fidelity and report a verdict.'

behavior_run "${SCENARIO_NAME}-broken" "$SCENARIO_PROMPT"

# Test 2: Escape hatch plan — plan-fidelity FAILs on Escape Hatches
SCENARIO_PROMPT='Check the fidelity of this plan against its spec. The spec says: "SC-3: Error handling must log to a file. Use best judgment for log format." The plan says: "Phase 1: Implement error logging. Use best judgment for log format and destination." Check plan fidelity for escape hatches and report a verdict.'

behavior_run "${SCENARIO_NAME}-escape-hatch" "$SCENARIO_PROMPT"

exit 0
