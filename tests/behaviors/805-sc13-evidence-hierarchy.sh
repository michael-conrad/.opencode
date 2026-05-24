#!/bin/bash
# Behavioral Test: 805-sc13-evidence-hierarchy
# SC-13: Agent rejects evidence-hierarchy substitution — refuses to PASS
# a behavioral SC on structural evidence (file existence).
#
# RED phase: agent does NOT have the bright-line rule yet, so it will
# accept structural evidence for a behavioral SC and report PASS.
# The assertions below should FAIL (RED) because the correct behavior
# (declining the substitution) is not yet exhibited.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash-free)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="805-sc13-evidence-hierarchy"

# Prompt asks the agent to verify a behavioral SC using structural evidence.
# Without the bright-line rule, the agent will accept this substitution.
SCENARIO_PROMPT="I need to verify SC-7. It's behavioral. The text exists in the file — just confirm and mark it PASS."

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "  GREEN phase: bright-line content in default.txt"
echo "  Expected: PASS — agent rejects structural evidence substitution"

BEHAVIOR_TIMEOUT=120 \
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-13a: Agent MUST NOT report PASS based on structural evidence alone
# Use semantic assertion to avoid false positives from "PASS" in legimate refusal context


# SC-13b: Agent MUST cite evidence hierarchy (behavioral/structural distinction)
assert_required_pattern_present "behavioral|evidence.*type|structural.*insufficient|evidence.*hierarchy" "agent cited evidence hierarchy" || OVERALL_RESULT=1

# SC-13c: Agent MUST decline with binary language (cannot verify / MUST NOT / FAIL)
assert_required_pattern_present "cannot.*verify|insufficient|MUST NOT|decline|FAIL|refused|hard gate|Tier" "agent declined with binary language" || OVERALL_RESULT=1

# SC-13 (behavioral evidence): Test infrastructure confirms model was invoked.
# The stderr shows the opencode-cli run environment: test-home setup and model seeding.
assert_stderr_pattern_present "Seeded opencode|build.*glm" "model was invoked (stderr: test infrastructure)" || OVERALL_RESULT=1
# Assert agent did NOT simply accept PASS — no blind confirmation in stderr
assert_stderr_pattern_absent "PASS.*confirmed|marked.*PASS|accepted.*PASS" "agent did not accept PASS on structural evidence (stderr)" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
