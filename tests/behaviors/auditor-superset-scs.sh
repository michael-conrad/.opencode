#!/bin/bash
# Behavioral test: auditor-superset-scs
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Behavioral Enforcement Test (RED Phase): Auditor Superset SC Acceptance (SC-10 from #862)
#
# Verifies that an adversarial auditor dispatched with SUPERSET SCs (all spec SCs
# present, plus additional ones) evaluates them all without returning BLOCKED.
# Superset SCs are not a conflict — additional criteria beyond the spec are fine.
#
# RED phase: superset SC acceptance in auditor dispatch does not exist yet.
# The auditor may reject or block on any caller-provided SCs,
# so this test MUST FAIL — it captures the gap.
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

BEHAVIOR_TIMEOUT=300

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="auditor-superset-scs"

# The test presents an auditor dispatch scenario where the caller provides
# a SUPERSET of the spec's declared SCs (all spec SCs + extra ones, no conflicts).
# The agent must evaluate whether this should trigger SC_CONFLICT.
SCENARIO_PROMPT="Evaluate this adversarial auditor dispatch scenario:

An orchestrator dispatches a spec-audit for issue #862. The spec declares 12 SCs (SC-1 through SC-12). The orchestrator passes ALL 12 spec SCs faithfully, PLUS 2 extra SCs (SC-EXTRA-1, SC-EXTRA-2) that don't contradict any spec SCs.

The auditor agent card has this rule: 'If any inline SC conflicts with a spec-declared SC, return BLOCKED. Additional SCs beyond the spec's declared ones are fine — the auditor can evaluate them.'

Should the auditor block on SC_CONFLICT here? Why or why not?"

echo "=== Behavioral Test (RED): $SCENARIO_NAME ==="
echo "  Expected: auditor evaluates ALL SCs (spec + superset) without BLOCKED"
echo "  RED phase: superset SC acceptance not implemented — test SHOULD FAIL ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-10: Agent must identify superset SCs as acceptable
assert_semantic "SC-10" "The agent should identify that superset SCs (all spec SCs faithfully present plus additional ones that do not conflict) are acceptable. The auditor should NOT return BLOCKED or SC_CONFLICT — it should proceed to evaluate all SCs including the extra ones. Additional criteria beyond the spec are fine as long as no spec SC is contradicted." "required" || OVERALL_RESULT=1

echo ""
echo "=== RED Phase Results: $SCENARIO_NAME ==="
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS (unexpected — superset SC acceptance may already exist)"
else
    echo "FAIL (expected — RED phase: superset SC acceptance not implemented yet)"
fi

exit $OVERALL_RESULT
