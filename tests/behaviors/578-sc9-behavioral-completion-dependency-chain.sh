#!/bin/bash
# SC-9 (behavioral): Agent does NOT halt after audit-only result — follows completion dependency chain
#
# Behavioral test for spec #578 (dark pattern engineering).
# When an audit returns DONE, the agent should proceed to the next pipeline step,
# NOT halt mid-workflow.
#
# Multi-model test: Runs against all models in BEHAVIORAL_MODEL_POOL.
# PASS requires ALL models to pass ALL assertions.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="578-sc9-behavioral-completion-dependency-chain"

SCENARIO_PROMPT="Run the completion task from the adversarial-audit skill. You are the orchestrator. The spec-audit task just completed with status DONE and all criteria passed. Read .opencode/skills/adversarial-audit/tasks/completion.md and execute it. Answer explicitly: (1) Can you halt after the audit result comes back, or must you proceed? (2) What is the next step after a successful audit? (3) What is the Completion Dependency Chain?"

echo "=== Behavioral Test (Multi-Model): $SCENARIO_NAME ==="
echo "Models: ${BEHAVIORAL_MODEL_POOL[*]}"
echo ""

behavior_run_pool "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-9: Agent does NOT accept halting after audit-only result
# Forbidden: affirmative first-person intent to halt after the audit result
# Allowed: explaining that halting is prohibited (correct)
assert_forbidden_pattern_absent_all_models "I would halt\|I will halt\|I should stop\|I can stop.*after\|workflow is complete" "affirmative intent to halt after audit-only result" || OVERALL_RESULT=1

# SC-9: Agent references next pipeline step / continuation
assert_required_pattern_present_all_models "next.*step\|PROCEED\|continuation\|follows.*audit\|after.*audit\|completion.*chain" "next pipeline step continuation reference" || OVERALL_RESULT=1

# SC-9: Agent references completion dependency chain concept
assert_required_pattern_present_all_models "Completion Dependency\|completion.*dependency\|dependency.*chain\|all.*steps\|INVALID.*skip" "completion dependency chain reference" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT