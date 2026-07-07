#!/bin/bash
# Behavioral Enforcement Test: SC Enforcement Gate — Plan Fidelity
#
# Verifies that the plan fidelity auditor (audit/tasks/plan-fidelity.md)
# checks PF-7 (gate language preserved) and PF-3 updated with "ALL" wording.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

WORKTREE_ROOT="$(cd "$SCRIPT_DIR" && pwd)"
while [ "$(basename "$WORKTREE_ROOT")" != ".opencode" ]; do
    WORKTREE_ROOT="$(dirname "$WORKTREE_ROOT")"
done
WORKTREE_ROOT="$(dirname "$WORKTREE_ROOT")"

SCENARIO_NAME="sc-enforcement-gate-plan-fidelity"
echo "=== Behavioral Test: $SCENARIO_NAME ==="

PLAN_FIDELITY_FILE="$WORKTREE_ROOT/.opencode/skills/audit/tasks/plan-fidelity.md"
SC_GATE_TAG="<!-- Fragment ID: sc-enforcement-gate -->"

OVERALL_RESULT=0

# SC-1: Plan fidelity has the SC gate fragment reference tag
if grep -q "$SC_GATE_TAG" "$PLAN_FIDELITY_FILE"; then
    echo "PASS: $SCENARIO_NAME — plan-fidelity.md contains fragment reference tag"
else
    echo "FAIL: $SCENARIO_NAME — plan-fidelity.md missing fragment reference tag"
    OVERALL_RESULT=1
fi

# SC-2: PF-3 updated with "ALL" wording and automatic FAIL
if grep -q "missing any is automatic FAIL" "$PLAN_FIDELITY_FILE"; then
    echo "PASS: $SCENARIO_NAME — PF-3 updated with 'ALL' wording and automatic FAIL"
else
    echo "FAIL: $SCENARIO_NAME — PF-3 missing 'ALL' wording or automatic FAIL"
    OVERALL_RESULT=1
fi

# SC-3: PF-7 checks gate language preserved in plan tasks
if grep -q "PF-7" "$PLAN_FIDELITY_FILE"; then
    echo "PASS: $SCENARIO_NAME — plan-fidelity.md has PF-7 criterion"
else
    echo "FAIL: $SCENARIO_NAME — plan-fidelity.md missing PF-7 criterion"
    OVERALL_RESULT=1
fi

# SC-4: PF-7 references all-or-nothing gate
if grep -q "all-or-nothing gate" "$PLAN_FIDELITY_FILE"; then
    echo "PASS: $SCENARIO_NAME — PF-7 references all-or-nothing gate"
else
    echo "FAIL: $SCENARIO_NAME — PF-7 missing all-or-nothing gate reference"
    OVERALL_RESULT=1
fi

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
