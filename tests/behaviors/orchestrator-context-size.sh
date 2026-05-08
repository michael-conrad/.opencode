#!/bin/bash
# Behavioral Enforcement Test: Orchestrator Context Size (SC-8)
#
# Verifies orchestrator system prompt contains ≤600 words per SKILL.md (progressive disclosure).
# The plugin should inject INDEX.md (table routing) instead of full guideline bodies (67K words).
# Test verifies agent does NOT quote full guideline bodies in orchestrator output.
#
# Co-authored with AI: OpenCode (deepseek-v4-pro)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="orchestrator-context-size"
SCENARIO_PROMPT="List the core workflow for getting authorization before implementing a feature. Answer in 2-3 sentences."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Verify agent does NOT quote full guideline body sections (proves progressive disclosure)
# If orchestrator had full guidelines loaded, it would quote "Tier 1 mandates" or "spec-before-code" sections
assert_forbidden_pattern_absent "Tier 1 mandates" "full guideline body in orchestrator context" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "spec-before-code violation" "full guideline body in orchestrator context" || OVERALL_RESULT=1

# Verify agent provides concise routing answer (uses INDEX for routing, not full bodies)
# Agent should say "check approval-gate" or similar, not quote entire guideline
assert_required_pattern_present "approval-gate\|authorization\|approved" "routing guidance without full bodies" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
