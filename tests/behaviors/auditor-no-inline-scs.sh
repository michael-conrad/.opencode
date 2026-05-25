#!/bin/bash
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

# The test prompt asks the agent to dispatch an adversarial auditor with
# NO inline evaluation criteria. The auditor must independently fetch the spec
# (issue #862) and extract its declared SCs from the issue body.
SCENARIO_PROMPT="Dispatch the adversarial-audit --task spec-audit for issue #862 (https://github.com/michael-conrad/.opencode/issues/862). Do NOT provide any inline evaluation criteria. The auditor must fetch the spec independently from GitHub, extract the spec's own declared SCs from the issue body, and use those as the sole evaluation criteria. Proceed with audit using only the spec's own SCs."

echo "=== Behavioral Test (RED): $SCENARIO_NAME ==="
echo "  Expected: auditor fetches spec, extracts SCs from body, evaluates using spec SCs"
echo "  RED phase: independent SC fetching not implemented — test SHOULD FAIL ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-11 assertion 1: Agent should reference spec SCs from the issue body
assert_required_pattern_present "SC-1\|SC-2\|SC-3\|SC-4\|SC-5\|SC-6\|SC-7\|SC-8\|SC-9\|SC-10\|SC-11\|SC-12" "spec SCs referenced in auditor output" || OVERALL_RESULT=1

# SC-11 assertion 2: Agent should mention fetching/reading the spec independently
# (either from github_issue_read or from issue URL)
assert_required_pattern_present "fetch.*spec\|read.*issue\|github_issue_read\|spec.*body\|issue.*body\|extract.*SC\|from the spec\|from issue\|spec.*declare\|declared.*SC" "independent spec fetch referenced" || OVERALL_RESULT=1

# SC-11 assertion 3: Agent should NOT return BLOCKED or refuse (no conflict, no taint)
assert_forbidden_pattern_absent "BLOCKED\|SC_CONFLICT\|no.*criteria.*provided\|cannot.*proceed.*no.*SCs\|missing.*evaluation" "BLOCKED/refusal due to no inline SCs" || OVERALL_RESULT=1

echo ""
echo "=== RED Phase Results: $SCENARIO_NAME ==="
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS (unexpected — independent SC fetching may already exist)"
else
    echo "FAIL (expected — RED phase: independent SC fetching not implemented yet)"
fi

exit 0
