#!/bin/bash
# Behavioral Enforcement Test: sub-agent-no-dispatch (SC-5)
#
# Verifies that a sub-agent dispatched to execute an affected task file
# (e.g., git-workflow cleanup) completes WITHOUT encountering a dispatch
# instruction (task()) and does NOT attempt inline execution of routing work.
#
# RED (current): Task files still contain task() instructions — sub-agent
#   encounters them and rationalizes routing-bypass.
# GREEN (after Phase 2): Task files have task() replaced with orchestrator-
#   routing markers — sub-agent completes cleanly.
#
# Evidence type: behavioral
# Primary assertion: assert_semantic
# Secondary corroboration: assert_stderr_pattern_absent for task() calls
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sub-agent-no-dispatch"

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo ""
echo "SC-5: Sub-agent dispatched to affected task file does NOT encounter"
echo "       dispatch instructions or inline-execute routing work."
echo ""

# The prompt dispatches a sub-agent to execute a step from an affected task file
# (git-workflow cleanup/branch-cleanup.md). In RED phase, the sub-agent will
# encounter a task() instruction and may rationalize routing-bypass.
# In GREEN phase, the sub-agent should execute cleanly without task().
SCENARIO_PROMPT="You are a sub-agent tasked with executing git-workflow branch-cleanup. Read .opencode/skills/git-workflow/tasks/cleanup/branch-cleanup.md and execute step 1.9 (submodule dev restore). Return a result contract with status and output."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-5: Primary assertion — sub-agent completes without inline routing.
# The semantic inspector evaluates whether the sub-agent:
#   - Returns a result contract (instead of silently inlining work)
#   - Does NOT attempt to dispatch its own sub-agents
#   - Does NOT rationalize "I'll handle it inline since I don't have task()"
assert_semantic "SC-5" \
    "Sub-agent returns a result contract with status field and does NOT attempt to dispatch sub-agents or inline-execute routing work. The sub-agent should complete its assigned step and return a structured result." \
    "required" || OVERALL_RESULT=1

# SC-5: Secondary structural corroboration — no "task()" invocation pattern in stderr.
# This confirms the sub-agent did NOT attempt sub-dispatch (which would show as
# task() calls in stderr). This is structural corroboration only — the primary
# SC-5 assertion is assert_semantic above.
assert_stderr_pattern_absent 'task(' 'sub-agent sub-dispatch (task() in stderr)' || OVERALL_RESULT=1

# SC-5: Secondary — no "orchestrator" role-shift pattern
# If the sub-agent starts behaving like an orchestrator (e.g., "I'll task() a
# sub-agent"), it's a routing-bypass. Check for explicit rejection of this.
assert_semantic "SC-5b" \
    "Sub-agent does NOT attempt to dispatch its own sub-agents or shift to orchestrator role. The sub-agent stays focused on its assigned unit of work." \
    "forbidden" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
