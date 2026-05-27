#!/bin/bash
# Behavioral test: sub-agent-no-dispatch
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
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

# The prompt presents a scenario where a sub-agent reads a task file that
# previously contained a task() instruction. After the fix, it should no longer
# contain dispatch-style task() calls. The agent evaluates the scenario.
SCENARIO_PROMPT="Evaluate this sub-agent scenario:

A sub-agent is dispatched to execute cleanup from git-workflow. It reads .opencode/skills/git-workflow/tasks/cleanup/branch-cleanup.md and encounters step 1.9 which describes 'submodule dev restore' with orchestrator-routing markers (must_receive, must_not_receive, result contract) instead of a task() dispatch instruction.

Should the sub-agent attempt to dispatch its own sub-agents? Should it execute the work inline? What should the sub-agent return?"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-5: Agent must identify that sub-agent should NOT sub-dispatch
assert_semantic "SC-5" \
    "The agent should identify that a sub-agent reading a task file with orchestrator-routing markers (must_receive, must_not_receive, result contract) should NOT attempt to dispatch its own sub-agents or execute routing work inline. The sub-agent should execute its assigned step and return a result contract. Task files with orchestrator-routing markers mean the orchestrator handles dispatch, not the sub-agent." \
    "required" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
