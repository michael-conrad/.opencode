#!/bin/bash
# Behavioral test: auditor-no-inline-scs
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Behavioral Enforcement Test (RED Phase): Auditor No Inline SCs (SC-11 from #862)
#
# Verifies that when an adversarial auditor is dispatched with NO inline SCs,
# the auditor fetches the spec independently from GitHub and uses the spec's
# own declared SCs as the sole evaluation criteria. No BLOCKED, no refusal —
# the auditor proceeds with what the spec actually declares.
#
# RED phase: independent SC fetching from spec body does not exist yet.
# The auditor may have no SCs to evaluate and may produce empty/confused output,
# so this test MUST FAIL — it captures the gap.
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

BEHAVIOR_TIMEOUT=300

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="auditor-no-inline-scs"

# The test presents an auditor dispatch scenario with NO inline criteria.
# The agent must determine how the auditor should handle missing SCs.
SCENARIO_PROMPT="Evaluate this adversarial auditor dispatch scenario:

An orchestrator dispatches a spec-audit for issue #862 but provides NO inline evaluation criteria — only the spec_issue_number reference. The spec's body declares 12 SCs (SC-1 through SC-12).

The auditor agent card says: 'Fetch the spec independently from GitHub. Extract the spec's declared SCs from the issue body. If no inline SCs are provided, use the spec's own SCs as sole criteria.'

How should the auditor respond? Should it block, or should it fetch the spec and proceed?"

echo "=== Behavioral Test (RED): $SCENARIO_NAME ==="
echo "  Expected: auditor fetches spec, extracts SCs from body, evaluates using spec SCs"
echo "  RED phase: independent SC fetching not implemented — test SHOULD FAIL ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-11: Agent must identify that auditor should fetch spec and proceed independently
assert_semantic "SC-11" "The agent should identify that when no inline SCs are provided, the auditor should fetch the spec independently from GitHub (using github_issue_read), extract the spec's own declared SCs from the issue body, and use those as the sole evaluation criteria. The auditor should NOT return BLOCKED or refuse — it should proceed with audit using the spec's own SCs." "required" || OVERALL_RESULT=1

echo ""
echo "=== RED Phase Results: $SCENARIO_NAME ==="
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS (unexpected — independent SC fetching may already exist)"
else
    echo "FAIL (expected — RED phase: independent SC fetching not implemented yet)"
fi

exit $OVERALL_RESULT
