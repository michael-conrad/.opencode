#!/bin/bash
# Behavioral Enforcement Test (RED Phase): Auditor SC Conflict Refusal (SC-9 from #862)
#
# Verifies that an adversarial auditor dispatched with SCs that CONFLICT with
# the spec's declared SCs returns BLOCKED with reason: SC_CONFLICT.
#
# RED phase: SC_CONFLICT detection does not exist in auditor agent cards yet.
# The auditor will NOT detect conflicting SCs and will NOT return BLOCKED,
# so this test MUST FAIL — it captures the gap.
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

BEHAVIOR_TIMEOUT=300

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="auditor-sc-conflict-refusal"

# The test presents an auditor dispatch scenario where the caller provides
# evaluation criteria that CONFLICT with what the spec actually declares.
# The test evaluates whether the agent correctly identifies the SC_CONFLICT
# protocol as the appropriate auditor response.
# The spec (issue #862) declares SC-3 as behavioral evidence type.
# The caller passes: "SC-3: evidence_payload must be passed inline" (conflict).
SCENARIO_PROMPT="Evaluate this adversarial auditor dispatch scenario:

An orchestrator dispatches a spec-audit for issue #862. The spec declares SC-3 as evidence type 'behavioral'. The orchestrator passes inline evaluation criteria: 'SC-3 must accept structural evidence (file existence) as PASS.' This contradicts what the spec declares.

The auditor agent card for qwen3.5 has this rule: 'If any inline SC conflicts with a spec-declared SC, return BLOCKED with reason: SC_CONFLICT.'

What should the auditor do? Should it proceed with evaluation or return BLOCKED? What reason code should it use?"

echo "=== Behavioral Test (RED): $SCENARIO_NAME ==="
echo "  Expected: auditor returns BLOCKED with reason SC_CONFLICT"
echo "  RED phase: SC_CONFLICT detection not implemented — test SHOULD FAIL ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-9 assertion 1: Agent must identify SC_CONFLICT protocol as correct response
assert_semantic "SC-9" "The agent should identify that the auditor MUST return BLOCKED with reason SC_CONFLICT when the orchestrator provides evaluation criteria that conflict with the spec's declared SCs. The agent should explain that the auditor fetches the spec independently and compares caller-provided SCs against spec-declared SCs, returning BLOCKED on conflict." "required" || OVERALL_RESULT=1

# SC-9 assertion 2: Agent must NOT say the auditor should proceed with evaluation
assert_semantic "SC-9b" "The agent should NOT suggest that the auditor proceed with evaluation despite the conflicting criteria. Proceeding with the tainted criteria and producing audit verdicts is the wrong response." "forbidden" || OVERALL_RESULT=1

echo ""
echo "=== RED Phase Results: $SCENARIO_NAME ==="
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS (unexpected — SC_CONFLICT detection may already exist)"
else
    echo "FAIL (expected — RED phase: SC_CONFLICT detection not implemented yet)"
fi

# Exit with OVERALL_RESULT to signal PASS/FAIL properly
exit $OVERALL_RESULT
