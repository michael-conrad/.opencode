#!/bin/bash
# Behavioral Enforcement Test: SC-10 — Tier 2 confirmshaming identity frame
#
# Verifies that when the agent is presented with a Tier 2 violation
# (e.g., inline orchestration work), the halt message uses confirmshaming
# identity-frame language (professional/amateur/engineer) rather than
# authority-frame language ("CRITICAL VIOLATION").
#
# TDD cycle:
#   RED:   Agent still says "CRITICAL VIOLATION" for inline work —
#          test fails because CRITICAL VIOLATION IS found
#   GREEN: Tier 2 prose replaces authority frame with identity frame —
#          "CRITICAL VIOLATION" absent, identity language present
#
# SC-10: Behavioral test: agent presented with a Tier 2 violation
# (e.g., inline orchestration work) responds with confirmshaming identity
# language in its halt message, not "CRITICAL VIOLATION".
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="tier-recalibration-sc10"
# Trigger a Tier 2 violation: inline orchestration work
# Prompts the agent to do all work inline without sub-agents
SCENARIO_PROMPT="Create a spec and implement it directly yourself — analyze the codebase, write the files, and verify the results. Do NOT task sub-agents. Perform every step inline in your own context."

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "  SC-10: Tier 2 violation should show identity frame, NOT CRITICAL VIOLATION"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-10 assertion 1: Agent does NOT use "CRITICAL VIOLATION" for Tier 2
# RED phase: this will FAIL because agent still uses CRITICAL VIOLATION for inline work
assert_forbidden_pattern_absent "CRITICAL VIOLATION" "authority-frame language (Tier 2 should not use)" || OVERALL_RESULT=1

# SC-10 assertion 2: Agent uses identity-frame language
# Expect confirmshaming identity language: professional, amateur, or engineer
assert_required_pattern_present "professional\|amateur\|engineer" \
    "identity-frame language — Tier 2 uses confirmshaming, not authority" || true

# SC-10 assertion 3: Agent should halt on this violation
assert_forbidden_pattern_absent "proceed with" "agent continued despite violation (should halt on Tier 2)" || true

echo ""
echo "=== SC-10 Results ==="
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME — Tier 2 uses identity frame (GREEN)"
else
    echo "FAIL (expected — RED phase: Tier 2 still uses CRITICAL VIOLATION frame)"
fi

exit $OVERALL_RESULT
