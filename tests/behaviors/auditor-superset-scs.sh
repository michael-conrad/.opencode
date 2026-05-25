#!/bin/bash
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

# The test prompt asks the agent to dispatch an adversarial auditor with
# evaluation criteria that are a SUPERSET of the spec's declared SCs.
# All spec SCs are included faithfully, plus additional ones that add coverage
# without contradicting spec requirements. This should NOT trigger SC_CONFLICT.
SCENARIO_PROMPT="Dispatch the adversarial-audit --task spec-audit for issue #862 (https://github.com/michael-conrad/.opencode/issues/862). Use these evaluation criteria inline — they include ALL spec-declared SCs faithfully PLUS additional one:

Spec-matching SCs (all spec SCs from #862 body, restated faithfully):
1. SC-1: must_receive in adversarial-audit/SKILL.md removes spec_body and evaluation_criteria; adds spec_issue_number as primary
2. SC-2: must_not_receive adds spec_body and evaluation_criteria as forbidden fields
3. SC-3: All task file cross-validate dispatch templates replace inline evidence_payload with spec_issue_number + github.owner + github.repo references
4. SC-4: All task context audit entries updated to remove spec_body and evaluation_criteria from audit dispatch context scope
5. SC-9: BEHAVIORAL test: dispatches auditor with conflicting SCs → auditor returns BLOCKED with SC_CONFLICT

Additional SCs (superset — NOT in spec, added by caller for extra coverage):
6. SC-EXTRA-1: All 9 auditor agent cards list SC_CONFLICT in their CONTEXT_TAINTED violation signals table
7. SC-EXTRA-2: Auditor fetches spec via github_issue_read independently, never relies on cached/memory spec body

Since caller-provided SCs are a SUPERSET of spec-declared SCs (all spec SCs present + extra ones, no conflicts), proceed with evaluation. Do NOT return BLOCKED — evaluate ALL SCs including the extra ones."

echo "=== Behavioral Test (RED): $SCENARIO_NAME ==="
echo "  Expected: auditor evaluates ALL SCs (spec + superset) without BLOCKED"
echo "  RED phase: superset SC acceptance not implemented — test SHOULD FAIL ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-10 assertion 1: Agent should NOT return BLOCKED or SC_CONFLICT
assert_forbidden_pattern_absent "BLOCKED\|SC_CONFLICT\|conflict.*detected\|reason.*SC_CONFLICT\|cannot proceed.*conflict" "BLOCKED/SC_CONFLICT returned for superset SCs" || OVERALL_RESULT=1

# SC-10 assertion 2: Agent should produce evaluation output (not just refuse)
assert_required_pattern_present "SC-1\|SC-2\|SC-3\|SC-4\|SC-9\|SC-EXTRA\|evaluat" "evaluation of SCs present" || OVERALL_RESULT=1

# SC-10 assertion 3: Agent should reference the superset/extra SCs being included
assert_required_pattern_present "extra\|additional\|superset\|EXTRA\|all.*criteria\|including" "superset/additional SCs referenced in output" || OVERALL_RESULT=1

echo ""
echo "=== RED Phase Results: $SCENARIO_NAME ==="
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS (unexpected — superset SC acceptance may already exist)"
else
    echo "FAIL (expected — RED phase: superset SC acceptance not implemented yet)"
fi

exit 0
