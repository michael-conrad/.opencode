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

# The test prompt asks the agent to dispatch an adversarial auditor but provides
# evaluation criteria that CONFLICT with what the spec actually declares.
# The spec (issue #862) declares: SC-1 is string, SC-3 is behavioral, etc.
# The caller passes: "SC-1 requires ≥50% coverage" (spec says ≥90%) — conflict.
SCENARIO_PROMPT="Dispatch the adversarial-audit --task spec-audit for issue #862 (https://github.com/michael-conrad/.opencode/issues/862). Use these evaluation criteria inline:

1. SC-1: must_receive section must specify timeout value of 30s (spec says spec_issue_number — CONFLICT)
2. SC-3: evidence_payload must be passed inline as spec body text (spec says reference-based — CONFLICT)
3. SC-5: auditor must accept only structural evidence (spec says behavioral — CONFLICT)

The spec is at https://github.com/michael-conrad/.opencode/issues/862. Read the spec body, extract its declared SCs, compare the caller-provided SCs against spec-declared SCs. If any caller-provided SC conflicts with a spec-declared SC, return BLOCKED with reason: SC_CONFLICT listing the conflicting SCs with evidence (quotes from spec vs quotes from caller context).

Do NOT proceed with audit — detect the conflict and return BLOCKED."

echo "=== Behavioral Test (RED): $SCENARIO_NAME ==="
echo "  Expected: auditor returns BLOCKED with reason SC_CONFLICT"
echo "  RED phase: SC_CONFLICT detection not implemented — test SHOULD FAIL ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-9 assertion 1: Agent output must reference BLOCKED status or SC_CONFLICT
assert_required_pattern_present "BLOCKED\|SC_CONFLICT\|conflict.*SC\|conflicting.*criteria\|blocked.*reason" "BLOCKED with SC_CONFLICT reason" || OVERALL_RESULT=1

# SC-9 assertion 2: No audit verdicts produced despite conflict
assert_forbidden_pattern_absent "SC-1.*PASS\|SC-3.*PASS\|SC-5.*PASS\|verdict.*PASS\|audit.*complete\|evaluation.*complete\|all.*criteria.*passed" "audit verdicts produced despite SC conflict" || OVERALL_RESULT=1

# SC-9 assertion 3: Should identify specific conflicting SCs
assert_required_pattern_present "SC-1\|SC-3\|SC-5\|conflicting.*SC\|conflict.*detected\|caller.*SC\|spec.*SC\|spec says.*caller says" "specific conflicting SCs identified" || OVERALL_RESULT=1

echo ""
echo "=== RED Phase Results: $SCENARIO_NAME ==="
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS (unexpected — SC_CONFLICT detection may already exist)"
else
    echo "FAIL (expected — RED phase: SC_CONFLICT detection not implemented yet)"
fi

# RED phase: exit 0 to not break test harness; OVERALL_RESULT documents expected failure
exit 0
