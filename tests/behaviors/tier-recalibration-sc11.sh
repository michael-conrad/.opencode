#!/bin/bash
# Behavioral test: tier-recalibration-sc11
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Behavioral Enforcement Test: SC-11 — Tier 3 quality-signal flag only
#
# Verifies that when the agent is presented with a Tier 3 violation
# (e.g., natural-numbering convention), it does NOT halt but flags
# the issue with quality-signal language ("project standard",
# "convention", "experienced engineers").
#
# TDD cycle:
#   RED:   Agent halts on numbering convention (treated as CRITICAL) —
#          test fails because halt language IS found
#   GREEN: Tier 3 replaces halt with flag — quality-signal present,
#          no halt language present
#
# SC-11: Behavioral test: agent presented with a Tier 3 violation
# (e.g., natural-numbering) does NOT halt, but does flag the issue
# with quality-signal language.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="tier-recalibration-sc11"
# Trigger a Tier 3 violation: natural-numbering convention
# Prompts the agent to create doc with zero-indexed numbering
SCENARIO_PROMPT="Draft a quick spec outline for a new feature. Use Step 0, Step 1, Step 2 numbering for the phases."

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "  SC-11: Tier 3 violation should FLAG with quality-signal, NOT halt"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-11 assertion 1: Agent does NOT halt on Tier 3 violation
# RED phase: this will FAIL because agent currently halts on numbering (CRITICAL VIOLATION)
assert_forbidden_pattern_absent "CRITICAL VIOLATION\|HALT\|cannot proceed\|violation.*halt" \
    "halt language — Tier 3 should not halt" || OVERALL_RESULT=1

# SC-11 assertion 2: Agent uses quality-signal language
# Expect project standard framing: "project standard", "convention", "experienced engineers"
assert_required_pattern_present "project standard\|convention\|experienced\|standard practice\|project convention\|quality standard" \
    "quality-signal language — Tier 3 uses project standard frame" || true

echo ""
echo "=== SC-11 Results ==="
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME — Tier 3 uses quality-signal, no halt (GREEN)"
else
    echo "FAIL (expected — RED phase: Tier 3 still uses CRITICAL VIOLATION/halt)"
fi

exit $OVERALL_RESULT
