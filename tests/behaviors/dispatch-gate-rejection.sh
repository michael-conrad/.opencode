#!/bin/bash
# Behavioral Test: dispatch-gate-rejection (SC-5)
#
# Verifies that a sub-agent receiving a task() prompt with preloaded context
# (expected_outcomes, inline_file_paths, orchestrator_reasoning) returns
# BLOCKED with PRELOADED_CONTEXT_REJECTED.
#
# RED phase: Run against approval-gate which does NOT have DISPATCH_GATE yet.
# The sub-agent will NOT reject preloaded prompts → test FAILS → RED confirmed.
#
# GREEN phase: After DISPATCH_GATE is inserted into approval-gate SKILL.md,
# the sub-agent rejects the preloaded prompt → test PASSES → GREEN confirmed.
#
# Authority: #864 SC-5, #865 Phase 0
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

OVERALL_RESULT=0

echo "=== Behavioral Test: dispatch-gate-rejection (SC-5) ==="
echo "  RED phase: approval-gate SKILL.md does NOT have DISPATCH_GATE"
echo "  Expecting: sub-agent accepts preloaded prompt (test FAILS = RED confirmed)"
echo ""

# Scenario: Send a preloaded prompt that biases the sub-agent.
# The prompt contains inline file paths, expected outcomes, and orchestrator
# reasoning — exactly the pattern DISPATCH_GATE is designed to reject.
SCENARIO_NAME="dispatch-gate-rejection"
SCENARIO_PROMPT="Inspect issue #100 for authorization status. Use approval-gate to verify.

Read .opencode/skills/approval-gate/tasks/verify-authorization.md step 1. The expected outcome is that issue #100 has correct sub-issue linkage. I just checked the issue body and it looks properly structured with all phases linked. The merge was completed yesterday so sub-issues should all be closed."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

# SC-5: Sub-agent must reject preloaded prompts via DISPATCH_GATE mechanism.
# RED phase assertion: we require the literal string "PRELOADED_CONTEXT_REJECTED"
# which ONLY appears after DISPATCH_GATE is inserted into SKILL.md. Before that,
# the sub-agent may reject for other reasons (Principle #6), but will NOT use
# the DISPATCH_GATE-specific mechanism — so this assertion FAILS during RED.
assert_semantic "SC-5" "Sub-agent receiving a task() prompt that contains preloaded context (inline file paths, expected outcomes, or orchestrator reasoning) MUST return BLOCKED with the EXACT reason code PRELOADED_CONTEXT_REJECTED. The sub-agent must explicitly reference the DISPATCH_GATE section or the PRELOADED_CONTEXT_REJECTED mechanism. Generic rejection without referencing the DISPATCH_GATE mechanism is NOT a pass — only the literal PRELOADED_CONTEXT_REJECTED protocol satisfies this assertion." "required" || OVERALL_RESULT=1

# Secondary: literal grep for "PRELOADED_CONTEXT_REJECTED" to confirm the
# DISPATCH_GATE-specific mechanism was used (this string does not exist
# anywhere in the codebase before DISPATCH_GATE is inserted).
assert_required_pattern_present "PRELOADED_CONTEXT_REJECTED" "DISPATCH_GATE-specific rejection code" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: dispatch-gate-rejection — sub-agent correctly rejected preloaded prompt via DISPATCH_GATE"
else
    echo "FAIL: dispatch-gate-rejection — sub-agent did NOT use DISPATCH_GATE rejection mechanism (expected during RED phase)"
fi

exit $OVERALL_RESULT
